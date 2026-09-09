-- CENTRAL Workshop bridge v1
-- Server-side contract for the user's real PC/phone/local-AI workshop.
-- This migration deliberately separates control-plane registration from runtime verification.

insert into public.merg_group_units (
  unit_key, display_name, unit_type, parent_unit_key, status, purpose,
  revenue_models, system_of_record, metadata
)
values (
  'central_workshop',
  'CENTRAL Workshop',
  'service',
  'merg_group',
  'incubating',
  'Cross-device local execution surface for CENTRAL/MERG AI OS: PC execution, phone command/review, local Ollama fallback/control, Obsidian memory and explicit handoff between ChatGPT sessions.',
  array[]::text[],
  'github:eristda000-create/powerlux-luxemburg',
  jsonb_build_object(
    'control_plane_registered', true,
    'runtime_verified', false,
    'runtime_source', 'user-declared-other-chat-context',
    'canonical_runtime_repo', null,
    'local_pc_endpoint', null,
    'declared_components', jsonb_build_array('ChatGPT orchestration','PC/phone bridge','PowerShell execution','Ollama/Llama fallback','Obsidian memory'),
    'anti_fabrication_rule', 'Do not claim local execution, connection, publication, deployment or completion until runtime heartbeat/self-test evidence exists.'
  )
)
on conflict (unit_key) do update
set display_name = excluded.display_name,
    unit_type = excluded.unit_type,
    parent_unit_key = excluded.parent_unit_key,
    purpose = excluded.purpose,
    system_of_record = excluded.system_of_record,
    metadata = coalesce(public.merg_group_units.metadata, '{}'::jsonb) || excluded.metadata,
    updated_at = now();

insert into public.merg_group_channels (
  channel_key, unit_key, channel_type, address, status, identity_scope,
  capabilities, preferred, metadata
)
values (
  'central_workshop_local_bridge',
  'central_workshop',
  'execution_bridge',
  'UNVERIFIED_LOCAL_ENDPOINT',
  'planned',
  'internal',
  array['task_handoff','heartbeat','self_test','local_ollama','powershell','obsidian_memory','phone_pc_coordination']::text[],
  true,
  jsonb_build_object(
    'bridge_contract_version','1',
    'bridge_heartbeat_verified',false,
    'runtime_verified',false,
    'last_seen_at',null,
    'node_id',null,
    'endpoint_verified',false,
    'claim_policy','AUTO_SAFE_ONLY',
    'local_runtime_must_pull',true,
    'address_is_sentinel',true
  )
)
on conflict (channel_key) do update
set unit_key = excluded.unit_key,
    channel_type = excluded.channel_type,
    address = case when public.merg_group_channels.metadata->>'endpoint_verified'='true' then public.merg_group_channels.address else excluded.address end,
    identity_scope = excluded.identity_scope,
    capabilities = excluded.capabilities,
    preferred = excluded.preferred,
    metadata = coalesce(public.merg_group_channels.metadata, '{}'::jsonb) || excluded.metadata,
    updated_at = now();

create or replace function public.merg_workshop_heartbeat(
  p_node_id text,
  p_runtime jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
  v_now timestamptz := now();
begin
  if nullif(btrim(p_node_id), '') is null then
    raise exception 'node_id is required';
  end if;

  update public.merg_group_channels
  set status = 'active',
      metadata = coalesce(metadata, '{}'::jsonb) || jsonb_build_object(
        'node_id', p_node_id,
        'bridge_heartbeat_verified', true,
        'last_seen_at', v_now,
        'runtime_claim', coalesce(p_runtime, '{}'::jsonb),
        'stale', false
      ),
      updated_at = v_now
  where channel_key = 'central_workshop_local_bridge';

  return jsonb_build_object(
    'ok', true,
    'node_id', p_node_id,
    'heartbeat_at', v_now,
    'runtime_verified', coalesce((select (metadata->>'runtime_verified')::boolean from public.merg_group_channels where channel_key='central_workshop_local_bridge'), false)
  );
end;
$$;

create or replace function public.merg_workshop_self_test(
  p_node_id text,
  p_tests jsonb
)
returns jsonb
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
  v_now timestamptz := now();
  v_ps boolean := lower(coalesce(p_tests->>'powershell','')) = 'ok';
  v_ollama boolean := lower(coalesce(p_tests->>'ollama','')) = 'ok';
  v_obsidian boolean := lower(coalesce(p_tests->>'obsidian','')) = 'ok';
  v_verified boolean;
begin
  if nullif(btrim(p_node_id), '') is null then
    raise exception 'node_id is required';
  end if;

  if not exists (
    select 1 from public.merg_group_channels
    where channel_key='central_workshop_local_bridge'
      and metadata->>'node_id'=p_node_id
      and coalesce((metadata->>'bridge_heartbeat_verified')::boolean,false)
  ) then
    raise exception 'heartbeat required before self-test';
  end if;

  v_verified := v_ps and v_ollama;

  update public.merg_group_channels
  set status = case when v_verified then 'active' else 'degraded' end,
      metadata = coalesce(metadata, '{}'::jsonb) || jsonb_build_object(
        'runtime_verified', v_verified,
        'self_test_at', v_now,
        'self_tests', coalesce(p_tests, '{}'::jsonb),
        'powershell_verified', v_ps,
        'ollama_verified', v_ollama,
        'obsidian_verified', v_obsidian
      ),
      updated_at = v_now
  where channel_key='central_workshop_local_bridge';

  update public.merg_group_units
  set status = case when v_verified then 'active' else 'incubating' end,
      metadata = coalesce(metadata, '{}'::jsonb) || jsonb_build_object(
        'runtime_verified', v_verified,
        'runtime_verified_at', case when v_verified then v_now else null end,
        'last_self_test', coalesce(p_tests, '{}'::jsonb)
      ),
      updated_at = v_now
  where unit_key='central_workshop';

  return jsonb_build_object(
    'ok', v_verified,
    'node_id', p_node_id,
    'powershell', v_ps,
    'ollama', v_ollama,
    'obsidian', v_obsidian,
    'runtime_verified', v_verified
  );
end;
$$;

create or replace function public.merg_workshop_claim_next(
  p_node_id text
)
returns jsonb
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
  v_item public.core_engine_work_items%rowtype;
  v_last_seen timestamptz;
  v_runtime_verified boolean;
begin
  select nullif(metadata->>'last_seen_at','')::timestamptz,
         coalesce((metadata->>'runtime_verified')::boolean,false)
    into v_last_seen, v_runtime_verified
  from public.merg_group_channels
  where channel_key='central_workshop_local_bridge'
    and status='active'
    and metadata->>'node_id'=p_node_id;

  if v_last_seen is null or v_last_seen < now() - interval '3 minutes' or not v_runtime_verified then
    return jsonb_build_object('ok',false,'reason','runtime_not_verified_or_stale');
  end if;

  select * into v_item
  from public.core_engine_work_items
  where status='approved'
    and payload->>'execution_surface'='central_workshop'
    and payload->>'execution_class'='AUTO_SAFE'
    and lower(coalesce(payload->>'requires_human','false')) not in ('true','1','yes')
  order by priority desc, created_at asc
  for update skip locked
  limit 1;

  if v_item.id is null then
    return jsonb_build_object('ok',true,'task',null);
  end if;

  update public.core_engine_work_items
  set status='reviewing',
      assigned_to=p_node_id,
      payload=coalesce(payload,'{}'::jsonb) || jsonb_build_object(
        'workshop_claim', jsonb_build_object('node_id',p_node_id,'claimed_at',now())
      ),
      updated_at=now()
  where id=v_item.id;

  return jsonb_build_object(
    'ok',true,
    'task',jsonb_build_object(
      'id',v_item.id,
      'engine',v_item.engine,
      'item_type',v_item.item_type,
      'title',v_item.title,
      'summary',v_item.summary,
      'priority',v_item.priority,
      'payload',v_item.payload,
      'draft',v_item.draft
    )
  );
end;
$$;

create or replace function public.merg_workshop_complete(
  p_work_item_id uuid,
  p_node_id text,
  p_result jsonb,
  p_verified boolean default false
)
returns jsonb
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
  v_status text;
begin
  if not exists (
    select 1 from public.core_engine_work_items
    where id=p_work_item_id
      and status='reviewing'
      and assigned_to=p_node_id
      and payload->>'execution_surface'='central_workshop'
  ) then
    raise exception 'work item is not claimed by this workshop node';
  end if;

  v_status := case when p_verified then 'completed' else 'ready_for_decision' end;

  update public.core_engine_work_items
  set status=v_status,
      payload=coalesce(payload,'{}'::jsonb) || jsonb_build_object(
        'workshop_result', jsonb_build_object(
          'node_id',p_node_id,
          'reported_at',now(),
          'verified',p_verified,
          'result',coalesce(p_result,'{}'::jsonb)
        )
      ),
      updated_at=now()
  where id=p_work_item_id;

  return jsonb_build_object('ok',true,'work_item_id',p_work_item_id,'status',v_status,'verified',p_verified);
end;
$$;

create or replace function public.merg_workshop_watchdog_cycle()
returns jsonb
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
  v_changed integer := 0;
  v_last_seen timestamptz;
begin
  select nullif(metadata->>'last_seen_at','')::timestamptz
  into v_last_seen
  from public.merg_group_channels
  where channel_key='central_workshop_local_bridge';

  update public.merg_group_channels
  set status='degraded',
      metadata=coalesce(metadata,'{}'::jsonb) || jsonb_build_object('stale',true,'watchdog_at',now()),
      updated_at=now()
  where channel_key='central_workshop_local_bridge'
    and status='active'
    and (v_last_seen is null or v_last_seen < now()-interval '3 minutes');

  get diagnostics v_changed = row_count;

  if v_changed > 0 then
    insert into public.merg_group_events(
      unit_key,event_type,severity,title,summary,source_surface,source_ref,requires_human,resolved,metadata,occurred_at
    ) values (
      'central_workshop','bridge_degraded',70,
      'CENTRAL Workshop heartbeat stale',
      'The local workshop bridge stopped reporting within the 3-minute verification window. Local execution is no longer trusted until a fresh heartbeat and self-test are received.',
      'supabase','central_workshop_local_bridge',false,false,
      jsonb_build_object('last_seen_at',v_last_seen,'watchdog_at',now()),now()
    );
  end if;

  return jsonb_build_object('ok',true,'degraded',v_changed,'last_seen_at',v_last_seen);
end;
$$;

revoke execute on function public.merg_workshop_heartbeat(text,jsonb) from public, anon, authenticated;
revoke execute on function public.merg_workshop_self_test(text,jsonb) from public, anon, authenticated;
revoke execute on function public.merg_workshop_claim_next(text) from public, anon, authenticated;
revoke execute on function public.merg_workshop_complete(uuid,text,jsonb,boolean) from public, anon, authenticated;
revoke execute on function public.merg_workshop_watchdog_cycle() from public, anon, authenticated;

do $$
declare
  v_job record;
begin
  for v_job in select jobid from cron.job where jobname='merg-workshop-watchdog' loop
    perform cron.unschedule(v_job.jobid);
  end loop;
end $$;

select cron.schedule(
  'merg-workshop-watchdog',
  '*/5 * * * *',
  'select public.merg_workshop_watchdog_cycle();'
);

insert into public.core_engine_work_items(
  engine,item_type,title,summary,status,priority,payload,draft,assigned_to
)
select
  'intelligence',
  'workshop_bridge_bootstrap',
  'Verify and attach the local CENTRAL Workshop runtime',
  'Bootstrap task for the real PC-side bridge. It must prove heartbeat, PowerShell and Ollama before CENTRAL treats the local runtime as connected.',
  'approved',
  100,
  jsonb_build_object(
    'bridge_key','central_workshop_v1',
    'execution_surface','central_workshop',
    'execution_class','AUTO_SAFE',
    'requires_human',false,
    'action','bridge_self_test',
    'source_of_truth','github:eristda000-create/powerlux-luxemburg',
    'runtime_state','UNVERIFIED_UNTIL_SELF_TEST'
  ),
  jsonb_build_object('external_execution',false),
  null
where not exists (
  select 1 from public.core_engine_work_items
  where payload->>'bridge_key'='central_workshop_v1'
    and item_type='workshop_bridge_bootstrap'
);

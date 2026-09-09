-- Replace service-role-on-PC bootstrap with scoped owner-authenticated RPC access.
-- The bridge functions run as SECURITY DEFINER but verify the caller email against
-- the existing canonical core_admin_users owner ACL on every request.

create or replace function public.merg_workshop_authorized_owner()
returns boolean
language sql
stable
security definer
set search_path = public, auth, pg_temp
as $$
  select exists (
    select 1
    from public.core_admin_users
    where enabled = true
      and role = 'owner'
      and lower(email) = lower(coalesce(auth.jwt()->>'email',''))
  );
$$;

revoke execute on function public.merg_workshop_authorized_owner() from public, anon, authenticated;
grant execute on function public.merg_workshop_authorized_owner() to service_role;

create or replace function public.merg_workshop_heartbeat(p_node_id text, p_runtime jsonb default '{}'::jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
declare
  v_now timestamptz := now();
begin
  if not public.merg_workshop_authorized_owner() then
    raise exception 'owner authorization required' using errcode='42501';
  end if;
  if nullif(btrim(p_node_id), '') is null then raise exception 'node_id is required'; end if;

  update public.merg_group_channels
  set status='active',
      metadata=coalesce(metadata,'{}'::jsonb) || jsonb_build_object(
        'node_id',p_node_id,
        'bridge_heartbeat_verified',true,
        'last_seen_at',v_now,
        'runtime_claim',coalesce(p_runtime,'{}'::jsonb),
        'stale',false,
        'authenticated_owner',auth.jwt()->>'email'
      ),
      updated_at=v_now
  where channel_key='central_workshop_local_bridge';

  return jsonb_build_object(
    'ok',true,'node_id',p_node_id,'heartbeat_at',v_now,
    'runtime_verified',coalesce((select (metadata->>'runtime_verified')::boolean from public.merg_group_channels where channel_key='central_workshop_local_bridge'),false)
  );
end;
$$;

create or replace function public.merg_workshop_self_test(p_node_id text, p_tests jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
declare
  v_now timestamptz := now();
  v_ps boolean := lower(coalesce(p_tests->>'powershell',''))='ok';
  v_ollama boolean := lower(coalesce(p_tests->>'ollama',''))='ok';
  v_obsidian boolean := lower(coalesce(p_tests->>'obsidian',''))='ok';
  v_verified boolean;
begin
  if not public.merg_workshop_authorized_owner() then
    raise exception 'owner authorization required' using errcode='42501';
  end if;
  if nullif(btrim(p_node_id), '') is null then raise exception 'node_id is required'; end if;

  if not exists (
    select 1 from public.merg_group_channels
    where channel_key='central_workshop_local_bridge'
      and metadata->>'node_id'=p_node_id
      and coalesce((metadata->>'bridge_heartbeat_verified')::boolean,false)
      and metadata->>'authenticated_owner'=auth.jwt()->>'email'
  ) then
    raise exception 'authenticated heartbeat required before self-test';
  end if;

  v_verified := v_ps and v_ollama;

  update public.merg_group_channels
  set status=case when v_verified then 'active' else 'degraded' end,
      metadata=coalesce(metadata,'{}'::jsonb) || jsonb_build_object(
        'runtime_verified',v_verified,
        'self_test_at',v_now,
        'self_tests',coalesce(p_tests,'{}'::jsonb),
        'powershell_verified',v_ps,
        'ollama_verified',v_ollama,
        'obsidian_verified',v_obsidian
      ),
      updated_at=v_now
  where channel_key='central_workshop_local_bridge';

  update public.merg_group_units
  set status=case when v_verified then 'active' else 'incubating' end,
      metadata=coalesce(metadata,'{}'::jsonb) || jsonb_build_object(
        'runtime_verified',v_verified,
        'runtime_verified_at',case when v_verified then v_now else null end,
        'last_self_test',coalesce(p_tests,'{}'::jsonb)
      ),
      updated_at=v_now
  where unit_key='central_workshop';

  return jsonb_build_object('ok',v_verified,'node_id',p_node_id,'powershell',v_ps,'ollama',v_ollama,'obsidian',v_obsidian,'runtime_verified',v_verified);
end;
$$;

create or replace function public.merg_workshop_claim_next(p_node_id text)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
declare
  v_item public.core_engine_work_items%rowtype;
  v_last_seen timestamptz;
  v_runtime_verified boolean;
begin
  if not public.merg_workshop_authorized_owner() then
    raise exception 'owner authorization required' using errcode='42501';
  end if;

  select nullif(metadata->>'last_seen_at','')::timestamptz,
         coalesce((metadata->>'runtime_verified')::boolean,false)
  into v_last_seen,v_runtime_verified
  from public.merg_group_channels
  where channel_key='central_workshop_local_bridge'
    and status='active'
    and metadata->>'node_id'=p_node_id
    and metadata->>'authenticated_owner'=auth.jwt()->>'email';

  if v_last_seen is null or v_last_seen < now()-interval '3 minutes' or not v_runtime_verified then
    return jsonb_build_object('ok',false,'reason','runtime_not_verified_or_stale');
  end if;

  select * into v_item
  from public.core_engine_work_items
  where status='approved'
    and payload->>'execution_surface'='central_workshop'
    and payload->>'execution_class'='AUTO_SAFE'
    and lower(coalesce(payload->>'requires_human','false')) not in ('true','1','yes')
  order by priority desc,created_at asc
  for update skip locked
  limit 1;

  if v_item.id is null then return jsonb_build_object('ok',true,'task',null); end if;

  update public.core_engine_work_items
  set status='reviewing',assigned_to=p_node_id,
      payload=coalesce(payload,'{}'::jsonb) || jsonb_build_object(
        'workshop_claim',jsonb_build_object('node_id',p_node_id,'owner_email',auth.jwt()->>'email','claimed_at',now())
      ),
      updated_at=now()
  where id=v_item.id;

  return jsonb_build_object('ok',true,'task',jsonb_build_object(
    'id',v_item.id,'engine',v_item.engine,'item_type',v_item.item_type,'title',v_item.title,
    'summary',v_item.summary,'priority',v_item.priority,'payload',v_item.payload,'draft',v_item.draft
  ));
end;
$$;

create or replace function public.merg_workshop_complete(p_work_item_id uuid,p_node_id text,p_result jsonb,p_verified boolean default false)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
declare
  v_status text;
begin
  if not public.merg_workshop_authorized_owner() then
    raise exception 'owner authorization required' using errcode='42501';
  end if;

  if not exists (
    select 1 from public.core_engine_work_items
    where id=p_work_item_id
      and status='reviewing'
      and assigned_to=p_node_id
      and payload->>'execution_surface'='central_workshop'
      and payload#>>'{workshop_claim,owner_email}'=auth.jwt()->>'email'
  ) then
    raise exception 'work item is not claimed by this authenticated workshop node';
  end if;

  v_status := case when p_verified then 'completed' else 'ready_for_decision' end;

  update public.core_engine_work_items
  set status=v_status,
      payload=coalesce(payload,'{}'::jsonb) || jsonb_build_object(
        'workshop_result',jsonb_build_object(
          'node_id',p_node_id,'owner_email',auth.jwt()->>'email','reported_at',now(),
          'verified',p_verified,'result',coalesce(p_result,'{}'::jsonb)
        )
      ),
      updated_at=now()
  where id=p_work_item_id;

  return jsonb_build_object('ok',true,'work_item_id',p_work_item_id,'status',v_status,'verified',p_verified);
end;
$$;

revoke execute on function public.merg_workshop_heartbeat(text,jsonb) from public, anon;
revoke execute on function public.merg_workshop_self_test(text,jsonb) from public, anon;
revoke execute on function public.merg_workshop_claim_next(text) from public, anon;
revoke execute on function public.merg_workshop_complete(uuid,text,jsonb,boolean) from public, anon;
grant execute on function public.merg_workshop_heartbeat(text,jsonb) to authenticated, service_role;
grant execute on function public.merg_workshop_self_test(text,jsonb) to authenticated, service_role;
grant execute on function public.merg_workshop_claim_next(text) to authenticated, service_role;
grant execute on function public.merg_workshop_complete(uuid,text,jsonb,boolean) to authenticated, service_role;

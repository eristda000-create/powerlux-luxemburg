-- CENTRAL assistant-request loop v1
-- Authenticated local workshop nodes may enqueue a bounded request for
-- ChatGPT/controller review without receiving cloud credentials or write authority.

create or replace function public.merg_workshop_submit_assistant_request(
  p_node_id text,
  p_parent_work_item_id uuid,
  p_request jsonb
)
returns jsonb
language plpgsql
set search_path to 'public','pg_temp'
as $function$
declare
  v_now timestamptz := now();
  v_id uuid;
  v_title text;
  v_summary text;
  v_kind text;
  v_project text;
  v_target_path text;
  v_instruction text;
  v_request_id text;
begin
  if nullif(btrim(p_node_id),'') is null then
    raise exception 'node_id is required';
  end if;

  if not exists (
    select 1
    from public.merg_group_channels
    where channel_key='central_workshop_local_bridge'
      and status='active'
      and metadata->>'node_id'=p_node_id
      and coalesce((metadata->>'runtime_verified')::boolean,false)
      and nullif(metadata->>'last_seen_at','')::timestamptz >= now()-interval '3 minutes'
  ) then
    raise exception 'runtime_not_verified_or_stale';
  end if;

  if p_parent_work_item_id is not null and not exists (
    select 1 from public.core_engine_work_items where id=p_parent_work_item_id
  ) then
    raise exception 'parent_work_item_not_found';
  end if;

  v_kind := lower(coalesce(nullif(btrim(p_request->>'kind'),''),'review'));
  if v_kind not in ('review','verify','research','write_repo','write_content','connected_source','decision') then
    raise exception 'unsupported_assistant_request_kind';
  end if;

  v_project := lower(coalesce(nullif(btrim(p_request->>'project'),''),'central'));
  if v_project not in ('central','powerlux','powertv','merg','cogni') then
    raise exception 'unsupported_project';
  end if;

  v_instruction := left(coalesce(p_request->>'instruction',''),4000);
  if nullif(btrim(v_instruction),'') is null then
    raise exception 'assistant_request_instruction_required';
  end if;

  v_target_path := nullif(left(coalesce(p_request->>'target_path',''),500),'');
  if v_target_path is not null then
    if v_target_path ~ '(^[A-Za-z]:|^/|\.\.|(^|/|\\)(\.git|\.central|\.codex|node_modules|AppData)(/|\\|$))'
       or lower(v_target_path) ~ '(\.env|credential|secret|service[-_]?role|refresh[_-]?token|access[_-]?token|cookie|session\.sqlite|keychain)' then
      raise exception 'blocked_target_path';
    end if;
  end if;

  v_request_id := coalesce(nullif(btrim(p_request->>'request_id'),''), gen_random_uuid()::text);

  select id into v_id
  from public.core_engine_work_items
  where payload->>'request_schema'='central_assistant_request_v1'
    and payload->>'request_id'=v_request_id
    and status not in ('rejected','archived')
  order by created_at desc
  limit 1;

  if v_id is not null then
    return jsonb_build_object('ok',true,'work_item_id',v_id,'deduplicated',true);
  end if;

  v_title := left('Assistant request · ' || v_project || ' · ' || v_kind,180);
  v_summary := left(coalesce(nullif(btrim(p_request->>'summary'),''),v_instruction),1200);

  insert into public.core_engine_work_items(
    engine,item_type,title,summary,status,priority,payload,draft,assigned_to,created_at,updated_at
  ) values (
    'intelligence',
    'assistant_request',
    v_title,
    v_summary,
    'ready_for_decision',
    96,
    jsonb_build_object(
      'request_schema','central_assistant_request_v1',
      'request_id',v_request_id,
      'request_type','assistant_request',
      'execution_surface','chatgpt_controller',
      'source_node',p_node_id,
      'parent_work_item_id',p_parent_work_item_id,
      'project',v_project,
      'kind',v_kind,
      'target_repo',nullif(left(coalesce(p_request->>'target_repo',''),300),''),
      'target_path',v_target_path,
      'instruction',v_instruction,
      'evidence',coalesce(p_request->'evidence','[]'::jsonb),
      'requested_at',v_now,
      'controller_status','pending',
      'requires_controller_review',true,
      'local_model_has_write_authority',false,
      'relay_to_chatgpt',true
    ),
    '{}'::jsonb,
    null,
    v_now,
    v_now
  ) returning id into v_id;

  return jsonb_build_object('ok',true,'work_item_id',v_id,'deduplicated',false);
end;
$function$;

revoke all on function public.merg_workshop_submit_assistant_request(text,uuid,jsonb) from public, anon, authenticated;
grant execute on function public.merg_workshop_submit_assistant_request(text,uuid,jsonb) to service_role;

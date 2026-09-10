-- CENTRAL Obsidian knowledge context v1
-- Injects the canonical management home + project state into every local_agent_team claim
-- unless the work item explicitly supplies obsidian_paths.

create or replace function public.merg_workshop_claim_next(p_node_id text)
returns jsonb
language plpgsql
set search_path to 'public','pg_temp'
as $function$
declare
  v_item public.core_engine_work_items%rowtype;
  v_last_seen timestamptz;
  v_runtime_verified boolean;
  v_payload jsonb;
  v_project text;
  v_obsidian_paths jsonb;
begin
  select nullif(metadata->>'last_seen_at','')::timestamptz,
         coalesce((metadata->>'runtime_verified')::boolean,false)
  into v_last_seen,v_runtime_verified
  from public.merg_group_channels
  where channel_key='central_workshop_local_bridge'
    and status='active'
    and metadata->>'node_id'=p_node_id;

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

  v_payload := coalesce(v_item.payload,'{}'::jsonb);
  v_project := lower(coalesce(nullif(v_payload->>'project',''),'central'));

  if coalesce(v_payload->>'action','')='local_agent_team' and not (v_payload ? 'obsidian_paths') then
    v_obsidian_paths := case v_project
      when 'powerlux' then jsonb_build_array('CENTRAL/00_HOME.md','CENTRAL/PROJECTS/POWERLUX/STATE.md')
      when 'powertv' then jsonb_build_array('CENTRAL/00_HOME.md','CENTRAL/PROJECTS/POWERTV/STATE.md')
      when 'merg' then jsonb_build_array('CENTRAL/00_HOME.md','CENTRAL/PROJECTS/MERG/STATE.md')
      when 'cogni' then jsonb_build_array('CENTRAL/00_HOME.md','CENTRAL/PROJECTS/COGNI/STATE.md')
      when 'vendetta' then jsonb_build_array('CENTRAL/00_HOME.md','CENTRAL/PROJECTS/VENDETTA/STATE.md')
      else jsonb_build_array('CENTRAL/00_HOME.md','CENTRAL/PROJECTS/CENTRAL/STATE.md')
    end;
    v_payload := v_payload || jsonb_build_object(
      'obsidian_paths',v_obsidian_paths,
      'knowledge_policy','obsidian_mckinsey_inspired_v1',
      'knowledge_required',true
    );
  end if;

  update public.core_engine_work_items
  set status='reviewing',assigned_to=p_node_id,
      payload=v_payload || jsonb_build_object(
        'workshop_claim',jsonb_build_object('node_id',p_node_id,'claimed_at',now())
      ),
      updated_at=now()
  where id=v_item.id;

  return jsonb_build_object('ok',true,'task',jsonb_build_object(
    'id',v_item.id,'engine',v_item.engine,'item_type',v_item.item_type,'title',v_item.title,
    'summary',v_item.summary,'priority',v_item.priority,'payload',v_payload,'draft',v_item.draft
  ));
end;
$function$;

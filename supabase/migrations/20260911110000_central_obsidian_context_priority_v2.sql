create or replace function public.central_enforce_obsidian_knowledge_first_v1()
returns trigger
language plpgsql
set search_path to 'public','pg_temp'
as $function$
declare
  v_project text;
  v_knowledge_project text;
  v_state_path text;
  v_existing_obsidian jsonb;
  v_existing_repo jsonb;
  v_first_requested_repo text;
  v_repo_paths jsonb := jsonb_build_array('AGENTS.md');
  v_obsidian_paths jsonb;
  v_brainstorm boolean := false;
begin
  new.payload := coalesce(new.payload, '{}'::jsonb);
  if coalesce(new.payload->>'action','') <> 'local_agent_team' then return new; end if;

  v_project := lower(coalesce(nullif(btrim(new.payload->>'project'),''),'central'));
  if v_project not in ('central','powerlux','powertv','merg','cogni') then v_project := 'central'; end if;

  v_knowledge_project := lower(coalesce(nullif(btrim(new.payload->>'knowledge_project'),''),v_project));
  if v_knowledge_project not in ('central','powerlux','powertv','vendetta','merg','cogni') then v_knowledge_project := v_project; end if;

  v_state_path := case v_knowledge_project
    when 'powerlux' then 'CENTRAL/PROJECTS/POWERLUX/STATE.md'
    when 'powertv' then 'CENTRAL/PROJECTS/POWERTV/STATE.md'
    when 'vendetta' then 'CENTRAL/PROJECTS/VENDETTA/STATE.md'
    when 'merg' then 'CENTRAL/PROJECTS/MERG/STATE.md'
    when 'cogni' then 'CENTRAL/PROJECTS/COGNI/STATE.md'
    else 'CENTRAL/PROJECTS/CENTRAL/STATE.md'
  end;

  v_existing_obsidian := new.payload->'obsidian_paths';
  if jsonb_typeof(v_existing_obsidian) = 'array' and jsonb_array_length(v_existing_obsidian) > 0 then
    new.payload := jsonb_set(new.payload, '{requested_obsidian_paths}', v_existing_obsidian, true);
  end if;

  v_existing_repo := new.payload->'context_paths';
  if jsonb_typeof(v_existing_repo) = 'array' and jsonb_array_length(v_existing_repo) > 0 then
    new.payload := jsonb_set(new.payload, '{requested_context_paths}', v_existing_repo, true);
    v_first_requested_repo := nullif(btrim(v_existing_repo->>0),'');
    if v_first_requested_repo is not null and v_first_requested_repo <> 'AGENTS.md' then
      v_repo_paths := v_repo_paths || jsonb_build_array(v_first_requested_repo);
    end if;
  end if;

  v_brainstorm := lower(coalesce(new.payload->>'brainstorming_mode', new.payload->>'opportunity_radar', 'false')) in ('true','1','yes','diverge','broad');

  v_obsidian_paths := jsonb_build_array('CENTRAL/AI_INSTRUCTIONS.md', v_state_path, 'CENTRAL/OPERATING_MODEL.md');
  if v_brainstorm then
    v_obsidian_paths := jsonb_build_array('CENTRAL/AI_INSTRUCTIONS.md', v_state_path, 'CENTRAL/OPPORTUNITY_RADAR.md', 'CENTRAL/OPERATING_MODEL.md');
  end if;

  new.payload := new.payload || jsonb_build_object(
    'project', v_project,
    'knowledge_project', v_knowledge_project,
    'knowledge_standard', 'mckinsey_inspired_v2',
    'knowledge_first_enforced', true,
    'knowledge_home_path', 'CENTRAL/00_HOME.md',
    'context_budget_policy', 'ai_rules_plus_state_plus_rag_v2',
    'max_context_chars', case when v_brainstorm then 12000 else 9000 end,
    'context_paths', v_repo_paths,
    'obsidian_paths', v_obsidian_paths,
    'opportunity_radar_enforced', v_brainstorm,
    'knowledge_rag', true,
    'knowledge_rag_scope', 'CENTRAL',
    'knowledge_rag_exclude', jsonb_build_array('INBOX','DRAFTS','ARCHIVE'),
    'embedding_model', coalesce(nullif(btrim(new.payload->>'embedding_model'),''),'nomic-embed-text')
  );
  return new;
end;
$function$;

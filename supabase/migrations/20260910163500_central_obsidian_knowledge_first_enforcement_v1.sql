-- CENTRAL Obsidian knowledge-first enforcement v1
-- Every local_agent_team work item receives the canonical management operating model
-- plus the relevant project STATE page as its first two Obsidian context files.
-- This is an internal McKinsey-inspired operating standard, not an official McKinsey template.

create or replace function public.central_enforce_obsidian_knowledge_first_v1()
returns trigger
language plpgsql
set search_path to 'public','pg_temp'
as $function$
declare
  v_project text;
  v_knowledge_project text;
  v_state_path text;
  v_existing_paths jsonb;
begin
  new.payload := coalesce(new.payload, '{}'::jsonb);

  if coalesce(new.payload->>'action','') <> 'local_agent_team' then
    return new;
  end if;

  v_project := lower(coalesce(nullif(btrim(new.payload->>'project'),''),'central'));
  if v_project not in ('central','powerlux','powertv','merg','cogni') then
    v_project := 'central';
  end if;

  v_knowledge_project := lower(coalesce(nullif(btrim(new.payload->>'knowledge_project'),''),v_project));
  if v_knowledge_project not in ('central','powerlux','powertv','vendetta','merg','cogni') then
    v_knowledge_project := v_project;
  end if;

  v_state_path := case v_knowledge_project
    when 'powerlux' then 'CENTRAL/PROJECTS/POWERLUX/STATE.md'
    when 'powertv' then 'CENTRAL/PROJECTS/POWERTV/STATE.md'
    when 'vendetta' then 'CENTRAL/PROJECTS/VENDETTA/STATE.md'
    when 'merg' then 'CENTRAL/PROJECTS/MERG/STATE.md'
    when 'cogni' then 'CENTRAL/PROJECTS/COGNI/STATE.md'
    else 'CENTRAL/PROJECTS/CENTRAL/STATE.md'
  end;

  v_existing_paths := new.payload->'obsidian_paths';
  if jsonb_typeof(v_existing_paths) = 'array' and jsonb_array_length(v_existing_paths) > 0 then
    new.payload := jsonb_set(new.payload, '{requested_obsidian_paths}', v_existing_paths, true);
  end if;

  new.payload := new.payload || jsonb_build_object(
    'project', v_project,
    'knowledge_project', v_knowledge_project,
    'knowledge_standard', 'mckinsey_inspired_v1',
    'knowledge_first_enforced', true,
    'knowledge_home_path', 'CENTRAL/00_HOME.md',
    'obsidian_paths', jsonb_build_array(
      'CENTRAL/OPERATING_MODEL.md',
      v_state_path
    )
  );

  return new;
end;
$function$;

revoke all on function public.central_enforce_obsidian_knowledge_first_v1() from public, anon, authenticated;

drop trigger if exists trg_central_obsidian_knowledge_first_v1 on public.core_engine_work_items;
create trigger trg_central_obsidian_knowledge_first_v1
before insert or update of payload on public.core_engine_work_items
for each row
execute function public.central_enforce_obsidian_knowledge_first_v1();

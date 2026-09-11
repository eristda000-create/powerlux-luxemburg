-- Management coverage + live AI quality metrics for CENTRAL.

create or replace view public.central_management_coverage_v1 as
with scoped as (
  select * from public.core_engine_work_items
  where created_at >= now()-interval '7 days'
    and coalesce(payload->>'execution_surface','')='central_workshop'
    and coalesce(payload->>'action','') not in ('git_fast_forward_update','bridge_self_test')
), scored as (
  select *,
    (coalesce(payload->>'value_stream','')<>'')::int has_value_stream,
    (coalesce(payload->>'initiative_key','')<>'')::int has_initiative,
    (coalesce(payload->>'expected_outcome','')<>'')::int has_outcome,
    (coalesce(payload->>'proof_of_value','')<>'')::int has_proof
  from scoped
)
select count(*)::int substantive_jobs_7d,
  coalesce(sum(has_value_stream),0)::int with_value_stream,
  coalesce(sum(has_initiative),0)::int with_initiative,
  coalesce(sum(has_outcome),0)::int with_outcome,
  coalesce(sum(has_proof),0)::int with_proof,
  coalesce(sum(case when has_value_stream+has_initiative+has_outcome+has_proof=4 then 1 else 0 end),0)::int fully_managed,
  case when count(*)=0 then 100.0 else round(100.0*sum(case when has_value_stream+has_initiative+has_outcome+has_proof=4 then 1 else 0 end)/count(*),1) end full_management_coverage_pct
from scored;

create or replace view public.central_ai_performance_live_v1 as
with jobs as (
 select
   coalesce(nullif(payload->'workshop_result'->'result'->>'model',''),nullif(payload->>'model',''),'unknown') model_key,
   coalesce(nullif(payload->>'agent_role',''),case when payload->>'action'='local_agent_team' then 'local_agent_team' else coalesce(payload->>'action','unknown') end) agent_role,
   status,payload,updated_at
 from public.core_engine_work_items
 where updated_at>=now()-interval '7 days'
   and coalesce(payload->>'execution_surface','')='central_workshop'
   and coalesce(payload->>'action','') in ('ollama_prompt','local_agent_team')
)
select model_key,agent_role,
 count(*) filter(where status='completed')::int jobs_completed,
 count(*) filter(where status in ('ready_for_decision','rejected') or payload->'workshop_result'->>'verified'='false')::int jobs_failed_or_unverified,
 count(*) filter(where lower(payload::text) like '%timeout%')::int timeouts,
 count(*) filter(where payload->'chatgpt_review' is not null)::int controller_reviewed,
 count(*) filter(where lower(coalesce(payload->'chatgpt_review'->>'review_status','')) like '%correct%' or jsonb_array_length(coalesce(payload->'chatgpt_review'->'rejected_or_corrected','[]'::jsonb))>0)::int controller_corrected,
 count(*) filter(where lower(payload::text) like '%unsupported%' or lower(payload::text) like '%hallucin%')::int unsupported_or_hallucination_markers,
 min(updated_at) measured_from,max(updated_at) measured_to
from jobs group by model_key,agent_role;

create or replace function public.central_validate_management_context_v1(p_payload jsonb,p_item_type text default null)
returns jsonb language sql stable set search_path=public,pg_temp as $$
with x as (
 select array_remove(array[
   case when coalesce(p_payload->>'value_stream','')='' then 'missing_value_stream' end,
   case when coalesce(p_payload->>'initiative_key','')='' then 'missing_initiative_key' end,
   case when coalesce(p_payload->>'expected_outcome','')='' then 'missing_expected_outcome' end,
   case when coalesce(p_payload->>'proof_of_value','')='' then 'missing_proof_of_value' end
 ],null) issues
)
select jsonb_build_object('valid',cardinality(issues)=0,'issues',to_jsonb(issues),'item_type',p_item_type,'kernel_version','central_management_kernel_v1') from x;
$$;

revoke all on function public.central_validate_management_context_v1(jsonb,text) from public,anon;
grant execute on function public.central_validate_management_context_v1(jsonb,text) to authenticated,service_role;

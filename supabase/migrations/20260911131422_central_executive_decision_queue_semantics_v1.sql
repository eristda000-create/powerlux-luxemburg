-- Distinguish decisions needing the human now from merely human-gated work in flight.

create or replace function public.central_executive_scorecard_v2()
returns jsonb language sql stable set search_path=public,pg_temp as $$
with streams as (
  select jsonb_agg(jsonb_build_object(
    'stream_key',s.stream_key,'name',s.display_name,'status',s.status,'north_star_metric',s.north_star_metric,
    'active_objectives',(select count(*) from public.central_objectives o where o.stream_key=s.stream_key and o.status='active'),
    'active_initiatives',(select count(*) from public.central_initiatives i join public.central_objectives o on o.id=i.objective_id where o.stream_key=s.stream_key and i.status='active'),
    'running_experiments',(select count(*) from public.central_experiments e join public.central_initiatives i on i.id=e.initiative_id join public.central_objectives o on o.id=i.objective_id where o.stream_key=s.stream_key and e.status='running')
  ) order by s.stream_key) v from public.central_value_streams s where s.status='active'
), value_totals as (
  select jsonb_build_object(
    'expected_eur',coalesce(sum(amount) filter(where value_type='expected' and unit='EUR'),0),
    'validated_eur',coalesce(sum(amount) filter(where value_type='validated' and unit='EUR'),0),
    'realized_eur',coalesce(sum(amount) filter(where value_type='realized' and unit='EUR'),0),
    'cost_eur',coalesce(sum(amount) filter(where value_type='cost' and unit='EUR'),0),
    'savings_eur',coalesce(sum(amount) filter(where value_type='saving' and unit='EUR'),0)
  ) v from public.central_value_ledger
), execution as (
  select jsonb_build_object(
    'approved',count(*) filter(where status='approved'),
    'reviewing',count(*) filter(where status='reviewing'),
    'ready_for_decision',count(*) filter(where status='ready_for_decision'),
    'completed_24h',count(*) filter(where status='completed' and updated_at>=now()-interval '24 hours'),
    'stale_reviewing',count(*) filter(where status='reviewing' and updated_at<now()-interval '10 minutes'),
    'human_gated_inflight',count(*) filter(where status in ('reviewing','approved') and coalesce((payload->>'requires_human')::boolean,false))
  ) v from public.core_engine_work_items
), decisions as (
  select jsonb_build_object(
    'needs_human_now',count(*) filter(where status='ready_for_decision' and coalesce((payload->>'requires_human')::boolean,false)),
    'controller_decisions',count(*) filter(where status='ready_for_decision' and not coalesce((payload->>'requires_human')::boolean,false)),
    'human_gated_inflight',count(*) filter(where status in ('reviewing','approved') and coalesce((payload->>'requires_human')::boolean,false))
  ) v from public.core_engine_work_items
), bridge as (
  select jsonb_build_object('status',status,'last_seen_at',metadata->>'last_seen_at','runtime_claim',metadata->'runtime_claim') v
  from public.merg_group_channels where channel_key='central_workshop_local_bridge'
), releases as (
  select coalesce(jsonb_agg(jsonb_build_object('project',project_key,'release_key',release_key,'url',release_url,'verified_at',verified_at,'fingerprint',feature_fingerprint) order by project_key),'[]'::jsonb) v
  from public.central_release_registry where status='latest_verified'
), mgmt as (select to_jsonb(c) v from public.central_management_coverage_v1 c),
ai as (select coalesce(jsonb_agg(to_jsonb(a) order by a.model_key,a.agent_role),'[]'::jsonb) v from public.central_ai_performance_live_v1 a)
select jsonb_build_object(
  'generated_at',now(),'management_kernel_version','v1.3',
  'value',coalesce((select v from value_totals),'{}'::jsonb),
  'streams',coalesce((select v from streams),'[]'::jsonb),
  'execution',coalesce((select v from execution),'{}'::jsonb),
  'decision_queue',coalesce((select v from decisions),'{}'::jsonb),
  'management_coverage',coalesce((select v from mgmt),'{}'::jsonb),
  'ai_quality',coalesce((select v from ai),'[]'::jsonb),
  'bridge',coalesce((select v from bridge),'{}'::jsonb),
  'latest_verified_releases',coalesce((select v from releases),'[]'::jsonb),
  'evidence_verified',(select count(*) from public.central_evidence where evidence_status='verified'),
  'evidence_stale',(select count(*) from public.central_evidence where evidence_status='verified' and valid_until is not null and valid_until<now()),
  'active_initiatives',(select count(*) from public.central_initiatives where status='active'),
  'running_experiments',(select count(*) from public.central_experiments where status='running'),
  'recommended_local_execution_profile',jsonb_build_object('default','ollama_prompt_microjob','deep_synthesis','local_agent_team_only_when_needed','reason','Observed 7-day runtime quality favors bounded ollama_prompt jobs over heavy local_agent_team runs.')
);
$$;

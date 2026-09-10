-- CENTRAL operating scorecard v1
-- Compact controller-facing snapshot for flow, reliability and current project execution.

create or replace function public.central_operating_scorecard_v1()
returns jsonb
language sql
stable
set search_path to 'public','pg_temp'
as $$
with bridge as (
  select jsonb_build_object(
    'status',status,
    'last_seen_at',metadata->>'last_seen_at',
    'runtime_verified',coalesce((metadata->>'runtime_verified')::boolean,false),
    'supervisor_verified',coalesce((metadata->'runtime_claim'->>'supervisor_verified')::boolean,false),
    'safe_repo_update_available',coalesce((metadata->'runtime_claim'->>'safe_repo_update_available')::boolean,false),
    'models',coalesce(metadata->'self_tests'->'ollama_models','[]'::jsonb)
  ) v
  from public.merg_group_channels
  where channel_key='central_workshop_local_bridge'
), queue as (
  select jsonb_build_object(
    'local_approved',count(*) filter (where status='approved' and payload->>'execution_surface'='central_workshop'),
    'local_reviewing',count(*) filter (where status='reviewing' and payload->>'execution_surface'='central_workshop'),
    'local_stale_reviewing',count(*) filter (where status='reviewing' and payload->>'execution_surface'='central_workshop' and updated_at<now()-interval '10 minutes'),
    'business_reviewing',count(*) filter (where status='reviewing' and coalesce(payload->>'execution_surface','')<>'central_workshop'),
    'ready_for_decision',count(*) filter (where status='ready_for_decision'),
    'completed_local_24h',count(*) filter (where status='completed' and payload->>'execution_surface'='central_workshop' and updated_at>=now()-interval '24 hours'),
    'pending_controller_requests',count(*) filter (where payload->>'request_schema'='central_assistant_request_v1' and payload->>'controller_status'='pending'),
    'unreviewed_local_results',count(*) filter (where status='completed' and payload->>'execution_surface'='central_workshop' and coalesce((payload->>'relay_to_chatgpt')::boolean,false) and payload->'chatgpt_review' is null)
  ) v
  from public.core_engine_work_items
), pipeline as (
  select jsonb_build_object(
    'total',count(*),
    'ready',count(*) filter (where status='ready'),
    'replied',count(*) filter (where status='replied'),
    'research',count(*) filter (where status='research'),
    'lost',count(*) filter (where status='lost'),
    'overdue_followups',count(*) filter (where next_action_at is not null and next_action_at<now() and status not in ('lost'))
  ) v
  from public.money_outreach_leads
), tv as (
  select jsonb_build_object(
    'catalog_total',count(*),
    'published_total',count(*) filter (where is_published),
    'published_replays',count(*) filter (where is_published and content_type='replay'),
    'published_upcoming',count(*) filter (where is_published and content_type='upcoming'),
    'unpublished_live_rows',count(*) filter (where not is_published and content_type='live')
  ) v
  from public.powertv_content
), vendetta as (
  select jsonb_build_object(
    'draft_exists',true,
    'status',status,
    'approval_status',approval_status,
    'rights_status',rights_status,
    'planning_date',metadata->>'planning_date',
    'planning_date_status',metadata->>'planning_date_status',
    'venue_status',metadata->>'venue_status',
    'auto_publish',coalesce((metadata->>'auto_publish')::boolean,false),
    'publication_gates',coalesce(metadata->'publication_gates','[]'::jsonb)
  ) v
  from public.powerlux_content_queue
  where event_title='Vendetta 2026 · Luxembourg'
  order by updated_at desc
  limit 1
)
select jsonb_build_object(
  'generated_at',now(),
  'bridge',coalesce((select v from bridge),'{}'::jsonb),
  'queue',coalesce((select v from queue),'{}'::jsonb),
  'powerlux_pipeline',coalesce((select v from pipeline),'{}'::jsonb),
  'powertv',coalesce((select v from tv),'{}'::jsonb),
  'vendetta',coalesce((select v from vendetta),jsonb_build_object('draft_exists',false))
);
$$;

revoke all on function public.central_operating_scorecard_v1() from public, anon, authenticated;
grant execute on function public.central_operating_scorecard_v1() to service_role;

update public.merg_group_units
set metadata=coalesce(metadata,'{}'::jsonb) || jsonb_build_object(
  'operating_model',jsonb_build_object(
    'version','v1',
    'principle','outcome_first_human_accountable',
    'value_streams',jsonb_build_array(
      jsonb_build_object('key','reliability','owner','chatgpt_controller','outcome','CENTRAL + Git + local agents stay available and consistent','proof','fresh heartbeat, clean/safe git, reviewed escalations'),
      jsonb_build_object('key','powerlux_growth','owner','chatgpt_controller','outcome','convert existing PowerLux assets into measurable leads/revenue/partners','proof','pipeline movement, verified follow-ups, conversion evidence'),
      jsonb_build_object('key','powertv_distribution','owner','chatgpt_controller','outcome','improve existing PowerTV catalog/editorial/distribution without rebuilds','proof','rights-safe published content, engagement/distribution evidence'),
      jsonb_build_object('key','vendetta_execution','owner','human_final_accountability','outcome','make 7 Nov event executable and monetizable without unsupported claims','proof','date, venue, matchups, rights, sponsor/content gates')
    ),
    'decision_rights',jsonb_build_object(
      'local_qwen','analyze, critique, request controller help, bounded local reads',
      'chatgpt_controller','verify, research, use connected systems, prepare safe repo/content changes',
      'human','production promotion, external commitments, spending, contracts, sensitive/destructive actions'
    ),
    'anti_patterns',jsonb_build_array('rebuild_existing_project','parallel_frontend','unverified_qwen_claim_as_fact','busywork_without_outcome','direct_main_writes')
  ),
  'agent_routing_policy',jsonb_build_object(
    'version','v1',
    'qwen3_4b',jsonb_build_object('role','local_analyst','authority','proposal_only'),
    'qwen3_1_7b',jsonb_build_object('role','fast_critic_planner','authority','advisory_only','single_point_of_failure',false),
    'chatgpt_controller',jsonb_build_object('role','source_verifier_and_execution_controller','production_or_external_commitment','human_required'),
    'routing_rule','Current/external truth goes to controller; bounded local reasoning goes to Qwen; all consequential outputs require evidence before promotion.'
  )
),updated_at=now()
where unit_key='central_workshop';

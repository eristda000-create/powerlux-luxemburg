-- CENTRAL Management Kernel v1
-- Applied to production on 2026-09-11.
-- Portfolio layer above core_engine_work_items; execution queue remains intact.

create table if not exists public.central_value_streams (
  stream_key text primary key,
  display_name text not null,
  purpose text not null,
  owner_role text not null default 'chatgpt_controller',
  status text not null default 'active' check (status in ('active','paused','archived')),
  north_star_metric text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.central_objectives (
  id uuid primary key default gen_random_uuid(),
  stream_key text not null references public.central_value_streams(stream_key) on delete cascade,
  objective_key text not null unique,
  title text not null,
  outcome text not null,
  horizon text not null default 'quarter',
  status text not null default 'active' check (status in ('draft','active','achieved','paused','archived')),
  target_value numeric,
  target_unit text,
  target_date date,
  owner_role text not null default 'chatgpt_controller',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.central_initiatives (
  id uuid primary key default gen_random_uuid(),
  objective_id uuid not null references public.central_objectives(id) on delete cascade,
  initiative_key text not null unique,
  title text not null,
  hypothesis text not null,
  status text not null default 'active' check (status in ('candidate','active','validated','stopped','completed','archived')),
  expected_value_eur numeric,
  probability_pct smallint check (probability_pct between 0 and 100),
  time_to_evidence_days integer check (time_to_evidence_days is null or time_to_evidence_days >= 0),
  strategic_leverage smallint check (strategic_leverage between 0 and 100),
  owner_role text not null default 'chatgpt_controller',
  proof_of_value text,
  stop_rule text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.central_experiments (
  id uuid primary key default gen_random_uuid(),
  initiative_id uuid not null references public.central_initiatives(id) on delete cascade,
  experiment_key text not null unique,
  title text not null,
  smallest_test text not null,
  success_metric text not null,
  success_threshold text,
  status text not null default 'planned' check (status in ('planned','running','passed','failed','stopped','archived')),
  started_at timestamptz,
  ended_at timestamptz,
  evidence_status text not null default 'hypothesis' check (evidence_status in ('hypothesis','partial','verified')),
  result_summary text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.central_evidence (
  id uuid primary key default gen_random_uuid(),
  claim_key text not null unique,
  project_key text,
  entity_key text,
  claim text not null,
  evidence_status text not null default 'unverified' check (evidence_status in ('unverified','reviewed','verified','superseded','rejected')),
  source_type text not null,
  source_ref text not null,
  source_authority smallint not null default 50 check (source_authority between 0 and 100),
  confidence smallint not null default 50 check (confidence between 0 and 100),
  verified_at timestamptz,
  valid_until timestamptz,
  supersedes_claim_key text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.central_value_ledger (
  id uuid primary key default gen_random_uuid(),
  initiative_id uuid references public.central_initiatives(id) on delete set null,
  experiment_id uuid references public.central_experiments(id) on delete set null,
  value_type text not null check (value_type in ('expected','validated','realized','cost','saving','learning')),
  amount numeric,
  unit text not null default 'EUR',
  probability_pct smallint check (probability_pct between 0 and 100),
  evidence_id uuid references public.central_evidence(id) on delete set null,
  note text,
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists public.central_capabilities (
  capability_key text primary key,
  display_name text not null,
  purpose text not null,
  system_of_record text,
  reuse_scope text[] not null default '{}'::text[],
  maturity smallint not null default 20 check (maturity between 0 and 100),
  status text not null default 'active' check (status in ('planned','active','degraded','retired')),
  owner_role text not null default 'chatgpt_controller',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.central_ai_performance (
  id uuid primary key default gen_random_uuid(),
  model_key text not null,
  agent_role text not null,
  jobs_completed integer not null default 0,
  jobs_failed integer not null default 0,
  timeouts integer not null default 0,
  controller_accepted integer not null default 0,
  controller_corrected integer not null default 0,
  unsupported_claims integer not null default 0,
  avg_latency_ms numeric,
  measured_from timestamptz not null,
  measured_to timestamptz not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique(model_key,agent_role,measured_from,measured_to)
);

create table if not exists public.central_release_registry (
  id uuid primary key default gen_random_uuid(),
  project_key text not null,
  release_key text not null,
  release_url text,
  source_ref text,
  commit_sha text,
  status text not null default 'candidate' check (status in ('candidate','latest_verified','stale','blocked','retired')),
  feature_fingerprint jsonb not null default '{}'::jsonb,
  verified_at timestamptz,
  verification_method text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(project_key,release_key)
);

create table if not exists public.central_decision_rights (
  decision_key text primary key,
  description text not null,
  risk_score smallint not null check (risk_score between 0 and 100),
  ambiguity_score smallint not null check (ambiguity_score between 0 and 100),
  reversible boolean not null default true,
  external_commitment boolean not null default false,
  production_change boolean not null default false,
  decision_owner text not null check (decision_owner in ('ai_autonomous','controller_review','human_approval')),
  rationale text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.central_classify_decision_rights(
  p_risk_score smallint,
  p_ambiguity_score smallint,
  p_reversible boolean default true,
  p_external_commitment boolean default false,
  p_production_change boolean default false
) returns text language plpgsql immutable as $$
begin
  if p_external_commitment or p_production_change or not p_reversible then return 'human_approval'; end if;
  if p_risk_score >= 60 or p_ambiguity_score >= 60 then return 'controller_review'; end if;
  if p_risk_score <= 30 and p_ambiguity_score <= 30 then return 'ai_autonomous'; end if;
  return 'controller_review';
end;
$$;

create or replace view public.central_execution_items_v1 as
select w.id,w.title,w.status,w.priority,w.assigned_to,w.updated_at,
 nullif(w.payload->>'value_stream','') value_stream,
 nullif(w.payload->>'initiative_key','') initiative_key,
 nullif(w.payload->>'experiment_key','') experiment_key,
 coalesce(w.payload->>'execution_surface','unknown') execution_surface,
 coalesce((w.payload->>'requires_human')::boolean,false) requires_human,
 w.payload
from public.core_engine_work_items w;

insert into public.central_value_streams(stream_key,display_name,purpose,north_star_metric,metadata) values
('reliability','CENTRAL Reliability','Keep the control plane, local bridge, knowledge and release truth reliable.','verified_runtime_rate',jsonb_build_object('framework','MIT_modularity_plus_McKinsey_execution')),
('powerlux_growth','PowerLux Growth','Convert the sports network into measurable commercial and ecosystem value.','qualified_value_created',jsonb_build_object('framework','value_creation')),
('powertv_distribution','PowerTV Distribution','Build rights-safe niche-sport discovery, distribution and cross-project leverage.','verified_distribution_journeys',jsonb_build_object('framework','platform_reuse')),
('merg_commerce','MERG Commerce','Reach repeatable low-capital commerce revenue using evidence-first tests.','realized_gross_margin',jsonb_build_object('framework','value_creation')),
('cogni_platform','Cogni Platform','Deliver a reliable multi-model product and reusable AI orchestration capability.','successful_fused_runs',jsonb_build_object('framework','modularity_reuse')),
('portfolio_opportunity','Portfolio Opportunity Radar','Continuously discover, verify and test cross-project opportunities without tunnel vision.','validated_opportunities',jsonb_build_object('framework','innovation_velocity'))
on conflict(stream_key) do update set display_name=excluded.display_name,purpose=excluded.purpose,north_star_metric=excluded.north_star_metric,metadata=excluded.metadata,updated_at=now();

with seeds(stream_key,objective_key,title,outcome,horizon,owner_role) as (values
('reliability','obj_central_reliable','Make CENTRAL self-recovering and auditable','Sustain a verified control plane where failures are detected, classified and recovered without silent state drift.','quarter','chatgpt_controller'),
('powerlux_growth','obj_powerlux_value','Turn PowerLux into measurable network value','Increase verified commercial, club, athlete and event value without duplicate systems.','quarter','chatgpt_controller'),
('powertv_distribution','obj_powertv_distribution','Make PowerTV a rights-safe niche-sport distribution layer','Increase useful verified event-to-content-to-official-provider and PowerLux journeys.','quarter','chatgpt_controller'),
('merg_commerce','obj_merg_first_revenue','Reach repeatable MERG revenue','Validate low-capital commercial lanes before inventory-heavy expansion.','quarter','chatgpt_controller'),
('cogni_platform','obj_cogni_reliable_product','Make Cogni reliable and reusable','Deliver stable multi-model orchestration with transparent provenance and reusable platform capabilities.','quarter','chatgpt_controller'),
('portfolio_opportunity','obj_portfolio_learning','Increase portfolio learning velocity','Generate broad opportunities, verify them quickly and fund only reversible high-evidence tests.','quarter','chatgpt_controller'))
insert into public.central_objectives(stream_key,objective_key,title,outcome,horizon,owner_role)
select stream_key,objective_key,title,outcome,horizon,owner_role from seeds
on conflict(objective_key) do update set title=excluded.title,outcome=excluded.outcome,horizon=excluded.horizon,owner_role=excluded.owner_role,updated_at=now();

insert into public.central_capabilities(capability_key,display_name,purpose,system_of_record,reuse_scope,maturity,status) values
('identity','Identity & Access','Shared identity and authorization boundaries.','Supabase/Auth',array['powerlux','powertv','merg','cogni'],60,'active'),
('evidence','Evidence & Provenance','Store source-backed claims and freshness.','CENTRAL/Supabase',array['central','powerlux','powertv','merg','cogni'],55,'active'),
('knowledge','Knowledge & RAG','Canonical reviewed context via Git-backed Obsidian and semantic retrieval.','GitHub+Obsidian',array['central','powerlux','powertv','merg','cogni'],75,'active'),
('opportunity_radar','Opportunity Radar','Portfolio-wide divergent discovery followed by evidence-based convergence.','CENTRAL',array['powerlux','powertv','merg','cogni'],60,'active'),
('work_queue','Execution Queue','Bounded work dispatch and local-controller handoff.','core_engine_work_items',array['central','powerlux','powertv','merg','cogni'],80,'active'),
('decision_rights','Decision Rights','Route decisions by risk, ambiguity, reversibility and commitment.','CENTRAL',array['central','powerlux','powertv','merg','cogni'],50,'active'),
('release_truth','Latest Verified Release','Resolve current canonical releases by source evidence and functional fingerprints.','CENTRAL',array['powerlux','powertv','merg','cogni'],60,'active'),
('commercial_pipeline','Commercial Pipeline','Shared commercial evidence, outreach and conversion capability without duplicate CRMs.','money_outreach_leads',array['powerlux','merg','powertv'],70,'active')
on conflict(capability_key) do update set display_name=excluded.display_name,purpose=excluded.purpose,system_of_record=excluded.system_of_record,reuse_scope=excluded.reuse_scope,maturity=excluded.maturity,status=excluded.status,updated_at=now();

insert into public.central_release_registry(project_key,release_key,release_url,source_ref,commit_sha,status,feature_fingerprint,verified_at,verification_method,notes)
select 'powertv','powertv_latest',site_url,source_ref,substring(source_ref from 'github:[^@]+@([0-9a-f]{40})'),'latest_verified',feature_fingerprint,last_verified_at,verification_source,'Mirrors verified PowerTV resolver; Associate Player is required.'
from public.powertv_resolve_latest_site()
on conflict(project_key,release_key) do update set release_url=excluded.release_url,source_ref=excluded.source_ref,commit_sha=excluded.commit_sha,status='latest_verified',feature_fingerprint=excluded.feature_fingerprint,verified_at=excluded.verified_at,verification_method=excluded.verification_method,notes=excluded.notes,updated_at=now();

insert into public.central_decision_rights(decision_key,description,risk_score,ambiguity_score,reversible,external_commitment,production_change,decision_owner,rationale) values
('safe_research','Read-only research and evidence gathering',10,25,true,false,false,'ai_autonomous','Low-risk reversible work.'),
('bounded_draft','Draft internal content or reversible experiment plan',20,40,true,false,false,'controller_review','Ambiguity benefits from controller review.'),
('verified_data_cleanup','Correct a verified non-destructive data inconsistency',30,20,true,false,false,'ai_autonomous','Low ambiguity, auditable cleanup with evidence.'),
('external_message','Send message or make external representation',55,45,false,true,false,'human_approval','External commitment/reputation exposure.'),
('contract_or_spend','Accept contract, pricing commitment or spend money',85,50,false,true,false,'human_approval','Financial/legal commitment.'),
('production_release','Promote or materially change production',70,45,false,false,true,'human_approval','Production impact requires explicit approval.'),
('strategy_selection','Select portfolio initiative or stop a major initiative',45,70,true,false,false,'controller_review','High ambiguity requires controller synthesis.')
on conflict(decision_key) do update set description=excluded.description,risk_score=excluded.risk_score,ambiguity_score=excluded.ambiguity_score,reversible=excluded.reversible,external_commitment=excluded.external_commitment,production_change=excluded.production_change,decision_owner=excluded.decision_owner,rationale=excluded.rationale,updated_at=now();

revoke all on function public.central_classify_decision_rights(smallint,smallint,boolean,boolean,boolean) from public,anon;
grant execute on function public.central_classify_decision_rights(smallint,smallint,boolean,boolean,boolean) to authenticated,service_role;

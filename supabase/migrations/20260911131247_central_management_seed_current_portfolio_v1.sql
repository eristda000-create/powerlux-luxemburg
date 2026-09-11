-- Seed the current evidence-backed CENTRAL portfolio. Idempotent by stable keys.

with defs(stream_key,objective_key,initiative_key,title,hypothesis,status,time_to_evidence_days,strategic_leverage,proof_of_value,stop_rule) as (
 values
 ('reliability','obj_central_reliable','init_central_self_recovery','CENTRAL self-recovery & runtime reliability','Runtime updates and local-agent work should continue without manual repair after safe sync/restart events.','active',7,95,'Fresh heartbeat, successful queued work after restart, lower stale-reviewing and restart failure rate.','Stop adding automation if it increases silent failure or requires unsafe reset/rebase/force behavior.'),
 ('powerlux_growth','obj_powerlux_value','init_powerlux_warm_lead_conversion','PowerLux warm-lead conversion','Existing warm commercial signals can be converted faster by evidence-led follow-up and a shared commercial capability instead of more prospecting.','active',14,85,'Verified progression of existing warm lead(s) to concrete next stage, reply, pilot or commercial decision.','Do not send externally or imply partnership without human approval.'),
 ('powertv_distribution','obj_powertv_distribution','init_powertv_event_companion','PowerTV Event Companion Network','Rights-light event journeys can create recurring value without owning every livestream right.','active',14,92,'Three source-safe event journeys from discovery to official access/result/replay follow-up with measurable outbound or engagement instrumentation.','No invented rights, restream claims, or replacement frontend.'),
 ('merg_commerce','obj_merg_first_revenue','init_merg_low_capital_revenue','MERG low-capital revenue lanes','Affiliate/rev-share and supplier/surplus lanes can validate demand before own-inventory risk.','active',21,82,'At least one verified revenue-bearing or qualified commercial lane progresses beyond research with measurable conversion evidence.','Do not buy inventory or commit spend before evidence and human approval.'),
 ('cogni_platform','obj_cogni_reliable_product','init_cogni_release_reliability','Cogni release reliability','A smaller verified execution path can improve multi-model reliability before feature expansion.','active',14,88,'Repeatable successful end-to-end run with provenance and no broken core UI path.','No parallel replacement app; verify actual source/deployment before code changes.'),
 ('portfolio_opportunity','obj_portfolio_learning','init_portfolio_opportunity_radar','Portfolio Opportunity Radar','Broad divergence followed by evidence-based convergence should improve opportunity quality and reduce tunnel vision.','active',7,90,'At least 24 distinct candidates across eight lenses, then 3-5 reversible evidence-seeking experiments.','No single event/entity may dominate the portfolio; do not create backlog clutter from every idea.')
)
insert into public.central_initiatives(objective_id,initiative_key,title,hypothesis,status,time_to_evidence_days,strategic_leverage,proof_of_value,stop_rule)
select o.id,d.initiative_key,d.title,d.hypothesis,d.status,d.time_to_evidence_days,d.strategic_leverage,d.proof_of_value,d.stop_rule
from defs d join public.central_objectives o on o.objective_key=d.objective_key
on conflict(initiative_key) do update set title=excluded.title,hypothesis=excluded.hypothesis,status=excluded.status,time_to_evidence_days=excluded.time_to_evidence_days,strategic_leverage=excluded.strategic_leverage,proof_of_value=excluded.proof_of_value,stop_rule=excluded.stop_rule,updated_at=now();

with defs(initiative_key,experiment_key,title,smallest_test,success_metric,success_threshold,status,evidence_status) as (
 values
 ('init_central_self_recovery','exp_central_restart_reliability','Safe-sync restart reliability','Observe safe sync -> supervisor restart -> fresh heartbeat -> successful queued local work.','verified post-restart work cycle','Fresh heartbeat and at least one completed local work item after restart','running','partial'),
 ('init_powerlux_warm_lead_conversion','exp_powerlux_atc_next_stage','ATC warm-lead next-stage test','Prepare the smallest evidence-backed next step for the existing replied ATC Sports lead; external send remains human-gated.','lead stage progression','Concrete reply/pilot/meeting/decision evidence rather than another generic draft','planned','partial'),
 ('init_powertv_event_companion','exp_powertv_three_event_companion','Three-event companion journey','Define three existing catalog journeys: verified event -> official watch/attend link -> story context -> result/replay follow-up.','complete verified journeys','3 rights-safe complete journeys with measurable CTA instrumentation plan','running','partial'),
 ('init_merg_low_capital_revenue','exp_merg_affiliate_supplier_lane','Affiliate / supplier lane evidence','Test existing low-capital affiliate/rev-share or supplier/surplus candidates before inventory purchase.','qualified commercial progression','At least one lane reaches verified application/partner/supplier stage or measurable conversion','planned','hypothesis'),
 ('init_cogni_release_reliability','exp_cogni_core_smoke_path','Cogni core smoke path','Verify source/deployment, then test login/new-chat/solver-fusion/provenance as one bounded core path.','successful end-to-end core run','One repeatable verified core run without crash/freeze','planned','partial'),
 ('init_portfolio_opportunity_radar','exp_portfolio_30_candidate_universe','30-candidate opportunity universe','Maintain a broad opportunity universe across eight lenses and select only 3-5 reversible experiments.','portfolio breadth and conversion to tests','>=24 distinct candidates, >=50% independent of focal event, 3-5 tests selected','passed','verified')
)
insert into public.central_experiments(initiative_id,experiment_key,title,smallest_test,success_metric,success_threshold,status,evidence_status,started_at,ended_at,result_summary)
select i.id,d.experiment_key,d.title,d.smallest_test,d.success_metric,d.success_threshold,d.status,d.evidence_status,
       case when d.status in ('running','passed') then now() else null end,
       case when d.status='passed' then now() else null end,
       case when d.experiment_key='exp_portfolio_30_candidate_universe' then 'Initial CENTRAL universe contains 30 candidates across multiple lenses; follow-up experiments selected without making Vendetta the portfolio center.' else null end
from defs d join public.central_initiatives i on i.initiative_key=d.initiative_key
on conflict(experiment_key) do update set title=excluded.title,smallest_test=excluded.smallest_test,success_metric=excluded.success_metric,success_threshold=excluded.success_threshold,status=excluded.status,evidence_status=excluded.evidence_status,result_summary=coalesce(excluded.result_summary,central_experiments.result_summary),updated_at=now();

insert into public.central_evidence(claim_key,project_key,entity_key,claim,evidence_status,source_type,source_ref,source_authority,confidence,verified_at,valid_until,metadata)
values
('powertv_latest_release_20260911','powertv','release','PowerTV latest verified release is https://powertv-vercel-release.vercel.app and its verified feature fingerprint includes associate_player=true.','verified','system_record','public.powertv_resolve_latest_site(); github commit 5dc8008380ce4bf04e0ca42ed117ff0e9485f3c7',95,95,'2026-09-11T12:07:10.823332Z',null,jsonb_build_object('feature','associate_player','value',true)),
('central_bridge_active_20260911_1444','central','DESKTOP-FP4OP26-User','CENTRAL local bridge returned active with supervisor_verified=true and local agents available at the recorded heartbeat.','verified','system_record','merg_group_channels:central_workshop_local_bridge',95,95,'2026-09-11T12:44:02.140749Z','2026-09-11T13:44:02.140749Z',jsonb_build_object('freshness','1 hour operational claim')),
('powertv_micro_b_completed_20260911','powertv','work_item:3e574f9e-209f-472a-957a-3d794fb12633','PowerTV backend/integration microjob completed on DESKTOP-FP4OP26-User after CENTRAL recovery.','verified','system_record','core_engine_work_items:3e574f9e-209f-472a-957a-3d794fb12633',90,95,'2026-09-11T12:45:15.819903Z',null,'{}'::jsonb)
on conflict(claim_key) do update set claim=excluded.claim,evidence_status=excluded.evidence_status,source_ref=excluded.source_ref,confidence=excluded.confidence,verified_at=excluded.verified_at,valid_until=excluded.valid_until,metadata=excluded.metadata,updated_at=now();

update public.core_engine_work_items
set payload=payload || jsonb_build_object(
 'initiative_key','init_powertv_event_companion',
 'experiment_key','exp_powertv_three_event_companion',
 'expected_outcome','Improve the existing PowerTV backend/editorial/product workflow without inventing source, rights or replacement UI.',
 'proof_of_value','Controller-reviewed source-safe improvement tied to existing objects.'
),updated_at=now()
where id in ('3e574f9e-209f-472a-957a-3d794fb12633','5e64a1c9-61fa-478f-a5dd-4db3ae92929c','90d0bf29-e737-431e-a672-c88ead7c59b7','88b6de2d-732f-45ea-891d-a74665eddb03')
 and coalesce(payload->>'value_stream','')='powertv_distribution';

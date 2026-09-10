# CENTRAL Operating Model v1

Status: ACTIVE operating contract

## North Star

CENTRAL exists to turn verified project context into measurable project outcomes with the minimum number of handoffs. Agent activity is not a success metric. A task is valuable only when it advances a real outcome, closes a verified blocker, improves evidence, or safely prepares an executable next action.

## Value streams

### 1. Reliability
Outcome: CENTRAL, Git, local agents and controller handoffs stay available, current and internally consistent.
Proof: fresh verified heartbeat, supervisor OK, safe Git state, controller escalations reviewed, no stale local jobs.
Owner: ChatGPT Controller.

### 2. PowerLux Growth / Revenue
Outcome: existing PowerLux assets produce measurable conversations, partners, event participation or revenue opportunities.
Proof: movement in the existing `money_outreach_leads` pipeline, verified follow-ups, meetings/replies/conversions, fulfilled sponsor assets.
Owner: ChatGPT Controller for analysis/coordination; human for outbound commitments.

### 3. PowerTV Content / Distribution
Outcome: improve the existing PowerTV catalog/editorial/distribution system without rebuilding or replacing the product.
Proof: rights-safe catalog state, verified event/source data, useful editorial assets, measurable distribution/engagement evidence.
Owner: ChatGPT Controller for verification/coordination; human for external/public commitments where required.

### 4. Vendetta 7 Nov Execution
Outcome: make the existing Vendetta 2026 Luxembourg project executable and monetizable without unsupported claims.
Proof: organizer date, venue, matchups, media rights, sponsor/artist approvals and result-source gates are explicitly closed.
Owner: human final accountability; CENTRAL prepares and verifies.

## Decision rights

| Actor | May do | May not do |
| --- | --- | --- |
| Local Qwen 4B | bounded local analysis, repo-context reasoning, QA, identify blockers, request controller help | claim cloud facts as verified, write/deploy real project changes, send messages, invent source/rights/data |
| Local Qwen 1.7B | fast critique/planning, lightweight checks | be a single point of failure or final authority |
| ChatGPT Controller | verify GitHub/Supabase/Vercel/web/connected sources; correct model claims; prepare safe content/repo changes; create controlled PRs | production promotion, spending, contracts, external commitments, destructive/sensitive actions without human authority |
| Human | final decision on production, external commitments, spending, contracts and sensitive changes | n/a |

`CONTROLLER_NEEDED` from the 4B analyst is sufficient escalation. The 1.7B planner is advisory and must never block escalation if it returns an empty/invalid plan.

## Routing policy

- Current or external truth -> ChatGPT Controller first.
- Bounded local repository reasoning -> Qwen 4B.
- Fast critique/planning -> Qwen 1.7B.
- Any consequential model output -> controller evidence check before promotion.
- Existing PowerLux and PowerTV must never be rebuilt, replicated, mocked up or replaced because a source surface is temporarily unclear.

## Work-in-progress rules

- The local workshop executes one claimed item at a time per PC node.
- New work should be attached to one value stream and include `outcome`, `proof_of_done` and `stop_rule` whenever practical.
- Do not create a new system if an existing table, queue, repo, draft or workflow can be improved.
- `reviewing` used by business engines is not the same as a locally running workshop job; operating metrics must distinguish these semantics.
- Finished local-agent output without controller review is unfinished management work.

## Evidence hierarchy

1. Current production/runtime evidence.
2. Current canonical repository and connected backend state.
3. Current verified source/provider evidence.
4. User-provided project facts.
5. Agent inference/draft.

Agent inference never promotes itself to a higher evidence class.

## Core KPIs

The controller uses `public.central_operating_scorecard_v1()` as the compact operating snapshot.

- `local_stale_reviewing`: target 0.
- `unreviewed_local_results`: target 0 after controller cycle.
- `pending_controller_requests`: target 0 after controller cycle.
- `bridge.runtime_verified`: must remain true while PC operation is expected.
- `bridge.safe_repo_update_available`: must remain true after local bootstrap.
- `powerlux_pipeline.ready/replied/overdue_followups`: measure commercial flow, not lead-list size alone.
- `powertv.published_total` plus rights-safe draft state: measure usable distribution inventory without inflating live/rights claims.
- Vendetta publication gates: measure gate closure, not number of brainstorms.

## Commercial flow rule

PowerLux already has an existing commercial pipeline in `money_outreach_leads`; do not create a second CRM merely because a local model fails to see cloud data. Warm replied leads outrank new cold research unless a verified dependency blocks them.

## PowerTV flow rule

PowerTV already exists. Work on its existing catalog/editorial/backend objects. Prioritize near-term verified events while preserving source and rights boundaries. Never invent domains, stream availability, rights, prices or source repositories.

## Git rule

Follow `powerlux_os/GIT_OPERATING_POLICY.md`:
- current `main` as base,
- short-lived work branch,
- no routine direct writes to `main`,
- no force/reset/rebase automation,
- no rebuild/replica/mockup branches,
- CI/Git Hygiene Gate before merge.

## Management cadence

During an active ChatGPT session, controller escalations may be handled immediately. Outside an active session, `CENTRAL Local AI Controller Relay` is the fallback controller cycle. Local agents may continue bounded work, but they cannot self-promote unverified conclusions into project truth.

## Stop rules

Stop or escalate when:
- the requested target is not a verified existing project/resource;
- a source/right/current fact is missing;
- a proposed change would create a parallel/replacement implementation;
- Git is dirty/diverged or target branch is not safely based on current main;
- a model asks for credentials, unrestricted shell, production deployment, outbound messages, spending or contracts;
- work cannot name a concrete outcome or proof of done.

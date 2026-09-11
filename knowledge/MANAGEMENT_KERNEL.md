---
type: management-system
status: canonical
owner: chatgpt-controller
updated: 2026-09-11
---

# CENTRAL Management Kernel v1

This is an internal operating model inspired by McKinsey-style value realization / transformation governance and MIT CISR-style decision rights / modularity / reuse. It is not an official McKinsey or MIT standard.

## Purpose

CENTRAL is no longer primarily a task queue. The queue is the execution layer underneath a management system that links strategy to evidence and realized value.

Required hierarchy:

**Value Stream → Objective → Initiative → Experiment → Work Item → Evidence → Value**

`core_engine_work_items` remains the execution queue. It must not become the portfolio database.

## Management Kernel objects

- `central_value_streams` — durable portfolio value streams.
- `central_objectives` — measurable outcomes inside a stream.
- `central_initiatives` — strategic hypotheses with proof-of-value and stop rules.
- `central_experiments` — smallest reversible tests.
- `central_evidence` — source-backed claim/provenance graph.
- `central_value_ledger` — expected, validated and realized value kept distinct.
- `central_capabilities` — reusable shared platform capabilities.
- `central_ai_performance` / `central_ai_performance_live_v1` — model/agent quality evidence.
- `central_release_registry` — latest verified project/release truth with functional fingerprints.
- `central_decision_rights` — decision ownership based on risk, ambiguity, reversibility and commitment.

## Mandatory management context for substantive work

Before a substantive CENTRAL / PowerLux / PowerTV / MERG / Cogni work item is accepted, it should carry:

- `value_stream`
- `initiative_key`
- `expected_outcome`
- `proof_of_value`
- `experiment_key` when part of a defined experiment

Use `central_validate_management_context_v1(...)` to measure this coverage. Infrastructure-only self-test and safe-sync jobs are exempt.

## Decision rights

Use the function `central_classify_decision_rights(...)` plus canonical decision records.

### AI autonomous
Low-risk, low-ambiguity, reversible work such as read-only research or verified non-destructive cleanup.

### Controller review
High-ambiguity reasoning, portfolio selection, non-trivial synthesis, or work where model claims need current source verification.

### Human approval
External messages, contracts, spend, irreversible actions, credential/auth changes, publication and production promotion.

External commitment or production impact overrides low numerical risk scores.

## AI execution profile

Observed 7-day CENTRAL runtime evidence on 2026-09-11 showed:

- `qwen3:4b-instruct` with heavy `local_agent_team`: materially timeout-prone.
- `qwen3:4b-instruct` with bounded `ollama_prompt`: materially higher completion rate.

Therefore:

1. bounded 4B microjobs are the default local reasoning profile;
2. `local_agent_team` is reserved for genuine multi-source/deep synthesis that cannot be decomposed;
3. Qwen output is always advisory until controller-reviewed against owning sources;
4. 1.7B remains support/critic/planner only.

Do not optimize agent count. Optimize verified outcome per unit of latency, human attention and risk.

## Value realization

Never infer monetary value from activity.

Track separately:

- `expected` — hypothesis or forecast;
- `validated` — evidence-backed value that has not necessarily been realized;
- `realized` — actual captured revenue/value;
- `cost` — real cost;
- `saving` — verified avoided cost;
- `learning` — non-monetary evidence gained.

No invented EUR values. A blank ledger is better than fabricated precision.

## Evidence graph

Important claims should record:

- claim
- source type
- source reference
- authority
- confidence
- verification time
- optional expiry/freshness
- supersession relationship

Owning systems beat stale notes. Git preserves knowledge history; Supabase owns operational state; Vercel owns deployment evidence; Gmail owns message state; official external sources own public facts.

## Latest verified release

A project name or old URL is not release truth.

Use `central_release_registry` plus project-specific resolvers and functional fingerprints. For PowerTV, `associate_player=true` is currently a required marker for the canonical latest release.

Never fall back silently to an older release when current verification fails.

## Reusable capabilities

CENTRAL should build shared capabilities once and reuse them across projects:

- identity / authorization
- evidence / provenance
- knowledge / semantic RAG
- opportunity radar
- execution queue
- decision rights
- latest verified release
- commercial pipeline

Avoid duplicate CRM, duplicate catalog, duplicate outreach or substitute frontends.

## Portfolio cadence

### Diverge
For growth/strategy/opportunity work, generate a broad opportunity universe across mandatory lenses.

### Converge
Verify, deduplicate and select only 3–5 reversible experiments.

### Execute
Run the smallest evidence-producing action.

### Review
Ask: what changed, what evidence appeared, what value moved, what should stop?

### Reallocate
Increase attention to validated opportunities; stop weak initiatives early.

## Executive scorecard

`central_executive_scorecard_v2()` is the management readout. It includes:

- value realization
- active streams/objectives/initiatives/experiments
- execution state
- management coverage
- AI quality
- bridge/runtime health
- latest verified releases
- evidence freshness
- true open human decisions

Task volume is diagnostic only. It is not success.

## Current baseline — 2026-09-11

Initial live measurement after kernel activation:

- management coverage for recent substantive local jobs: **7.1% fully managed**;
- PowerTV and CENTRAL Reliability have active running experiments;
- PowerTV latest verified release is registered with `associate_player=true`;
- bounded 4B microjobs substantially outperform heavy 4B team runs on timeout rate;
- no monetary value is recorded until evidence supports it.

The 7.1% baseline is not a target. New substantive work should move toward 100% management-context coverage without retroactively forcing false mappings onto legacy jobs.

## Controls

- No task-count theater.
- No raw Qwen output as fact.
- No invented money values.
- No hardcoded stale release URLs.
- No duplicate systems when a shared capability exists.
- No external commitment or production release without human approval.
- No force/reset/rebase shortcuts.
- No silent fallback when verification fails.

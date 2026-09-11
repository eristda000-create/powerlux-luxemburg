---
type: project-state
project: central
status: canonical
owner: chatgpt-controller
updated: 2026-09-11
---

# CENTRAL — Current State

## Value at stake
Create a reliable human+agent management operating system that links strategy to evidence and realized value, while keeping local AI fast, bounded and auditable.

## Verified fact base

- Verified Windows node: `DESKTOP-FP4OP26-User`.
- CENTRAL Supervisor and Workshop Bridge are active.
- Ollama models available on the verified node: `qwen3:4b-instruct`, `qwen3.5:4b`, `qwen3.5:9b`, `qwen3:1.7b`, plus `nomic-embed-text:latest` for embeddings.
- `qwen3.5:9b` was present in the verified-node Ollama inventory on 2026-09-11 and returned the exact bounded smoke-test response `CENTRAL_DEEP_OK`.
- Benchmark v3 on 2026-09-11 measured `qwen3.5:9b` at 3/4 exact-pass (75%, 183.029 s total), versus 2/4 for both `qwen3:4b-instruct` (49.614 s) and `qwen3.5:4b` (52.069 s). The 9B deep-reasoning case still failed exact-output acceptance and produced 501 thinking characters with an empty final response.
- A live 9B Hybrid-RAG `local_agent_team` smoke after PR47 exceeded the configured 300 s HttpClient timeout and did not meet its expected outcome. This is negative runtime evidence, not a model-quality proof.
- GitHub `main` subsequently merged PR48 at `974ecacdaf15fbe0e0f650a34bfdaeed9f974bc7`, bounding the deep 9B runtime after that timeout evidence; the verified desktop fast-forwarded to the same commit.
- `qwen3:4b-instruct` remains the routine bounded reasoning default. `qwen3.5:9b` remains deep-only: its benchmark correctness signal is stronger in this small sample, but latency and full-RAG timeout behavior do not justify broader routing.
- Local arbitrary shell is disabled.
- Safe Git fast-forward update is available and has completed real updates on the PC.
- Local-to-controller escalation is supported through `CONTROLLER_NEEDED` and the assistant-request control plane.
- Obsidian vault is connected and CENTRAL knowledge is mounted under `CENTRAL/`.
- Knowledge-first use is enforced for substantive local work; canonical project state and operating model remain mandatory context.
- CENTRAL Management Kernel v1 is live in Supabase. It separates portfolio management from task execution through: Value Stream → Objective → Initiative → Experiment → Work Item → Evidence → Value.
- Management objects now include value streams, objectives, initiatives, experiments, evidence, value ledger, reusable capabilities, AI performance, release registry and decision rights.
- `central_executive_scorecard_v2()` is live and reads value, portfolio, execution, management coverage, AI quality, bridge health, latest verified releases and open human decisions.
- Initial live management-coverage baseline on 2026-09-11 was 7.1% for recent substantive local jobs. This is a legacy baseline, not the target.
- Live 7-day AI evidence shows bounded `qwen3:4b-instruct` `ollama_prompt` work has materially better completion/timeout behavior than heavy `local_agent_team` runs. Bounded 4B microjobs are now the default execution profile.
- The release registry currently contains the latest verified PowerTV release with `associate_player=true` in its functional fingerprint.
- No monetary value is entered into the value ledger without evidence; zero is preferable to fabricated precision.

## Current bottlenecks

1. Most legacy work items predate the Management Kernel and are not yet tied to initiative/outcome/proof-of-value context.
2. Heavy multi-agent local runs remain timeout-prone and should not be the default path.
3. `qwen3.5:9b` now has comparative evidence, but the sample is small and the full-RAG deep path timed out before PR48; post-PR48 bounded verification is still needed before any routing expansion.
4. Too many historical `requires_human` flags can distort executive views unless restricted to open decision states.
5. Evidence and value realization are still sparse because the kernel is new; quality matters more than backfilling speculative values.
6. Git governance needs strict branch/PR discipline; a direct-main placeholder write on 2026-09-11 was an operator error and must not be normalized as an allowed workflow.

## Current decision

Operate CENTRAL as a management system, not a task factory:

- `core_engine_work_items` = execution queue only;
- portfolio truth lives in the Management Kernel;
- substantive work should carry `value_stream`, `initiative_key`, `expected_outcome`, `proof_of_value`, and `experiment_key` when relevant;
- bounded `qwen3:4b-instruct` microjobs remain default local reasoning;
- `qwen3.5:9b` remains explicit deep-only; benchmark v3 is encouraging on exact correctness but is outweighed for broader routing by materially higher latency and the observed full-RAG timeout until post-PR48 verification succeeds;
- decision rights depend on risk, ambiguity, reversibility and commitment;
- humans retain production/external/financial accountability.

## Next actions

1. Raise management-context coverage from the 7.1% legacy baseline toward 100% for new substantive work.
2. Keep heavy `local_agent_team` usage exceptional and evidence-justified.
3. Run one bounded post-PR48 deep/RAG verification on the verified node; require a nonempty final response inside the bounded runtime before treating PR48 as behavioral proof.
4. Keep 4B as routine default and 9B as deep-only unless repeated post-fix evidence shows a better correctness/latency/value trade-off.
5. Populate the value ledger only when expected/validated/realized value is actually supportable.
6. Expand the release registry to PowerLux, MERG and Cogni using functional fingerprints rather than names/URLs alone.
7. Use the Executive Scorecard as the management readout instead of raw task counts.
8. Keep canonical knowledge, Supabase kernel and controller policy aligned through safe Git PRs.

## KPIs

- new substantive work with full management context → target 100%
- stale reviewing jobs = 0
- unreviewed local results = 0
- unsafe Git operations = 0
- controller escalations resolved with evidence
- bounded local-job timeout rate materially below heavy team-run timeout rate
- deep 9B post-fix verification returns a nonempty accepted result inside the configured bound
- verified value ledger entries with source evidence = 100%
- latest verified releases resolved by evidence + functional fingerprint = 100% for managed frontends

## Controls

No task-count theater, no invented value, no raw Qwen output promoted to fact, no stale hardcoded release URL, no duplicate system where a shared capability exists, no external commitment or production release without human approval, no force/reset/rebase shortcuts, and no silent verification fallback.

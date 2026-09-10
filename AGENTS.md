# MERG AI OPERATING RULES — ROOT

This repository participates in the MERG group operating system. These rules are mandatory for AI agents, Codex sessions, copilots and automation that modify or assess this repository.

## Mandatory bootstrap
Before making a substantive claim or write, read in this order:
1. `merg_os/CURRENT_STATE.md`
2. `merg_os/PROJECT_REGISTRY.md`
3. `merg_os/PRODUCTION_GATES.md`
4. `merg_os/TOOL_ROUTER.md`
5. Project-specific state. For PowerLux: `powerlux_os/CURRENT_STATE.md`, `powerlux_os/ROUTER.md`, `powerlux_os/DECISION_LOG.md`.
6. Before any Git write: `powerlux_os/GIT_OPERATING_POLICY.md`.

If any required file is missing or stale, treat the affected fact as `UNVERIFIED` rather than guessing.

## Production-first rule
The existing real implementation is canonical whenever it exists. Never recreate a website, app, database, workflow or document from screenshots, chat memory, prose descriptions or visual imitation when an original implementation/source can be found.

## NO MOCKUPS by default
Do not create mockups, static replicas, fake dashboards, placeholder backends, synthetic production data, replacement landing pages or demo deployments unless the user explicitly asks for a prototype/mockup.

If source is missing:
- search for the original repository, deployment, project, file or connected source first;
- record the blocker;
- do not substitute a newly invented implementation and call it the original.

## Source-of-truth hierarchy
For technical facts use this order:
1. Current repository/source code and branch state
2. Current production deployment and runtime behavior
3. Current backend/database configuration and logs
4. Canonical project state files in this repository
5. Current explicit user instruction
6. Chat history and model memory only as supplementary context

When sources conflict, verify the live system and record the divergence. Never silently merge contradictory states.

## Before every write
Identify and verify:
- target project and repository;
- target branch;
- existing implementation/path;
- current deployment/environment when relevant;
- current backend resource when relevant;
- whether another agent/session already owns the same change.

Prefer editing the existing implementation over introducing parallel replacements.

## Git discipline
- Canonical repository is `eristda000-create/powerlux-luxemburg`; canonical integration branch is `main`.
- Normal work must start from current `origin/main` on a short-lived branch and go through a PR. Do not routinely write directly to `main`.
- One work item owns one branch. Never let ChatGPT, Codex, Qwen/Ollama or another session concurrently write the same branch without an explicit handoff.
- Before continuing a feature branch, fetch `origin/main` and verify current `main` is contained in the branch. If not, synchronize first; do not continue piling work onto a stale branch.
- Never solve drift with automatic `reset --hard`, force push, destructive cleanup or unreviewed rebases of shared branches.
- Local PC updates of `main` are fast-forward only and require the expected remote plus a clean working tree.
- Closed/abandoned rebuild, recovery, replica and mockup branches are non-canonical. Do not reopen or use them as production source without a new explicit owner decision.
- Run `scripts/git_preflight.ps1 -RequireMainCurrent` before substantial branch work when operating locally.
- Full policy: `powerlux_os/GIT_OPERATING_POLICY.md`.

## Before every deployment
Verify:
- exact repository + branch + commit being deployed;
- build/test result;
- correct Vercel/project target or other host;
- environment (preview vs production);
- required backend/env dependencies;
- rollback path.

## Definition of done
Never say `done`, `live`, `fixed`, `deployed`, `connected`, `working` or equivalent until the real state is verified.

For web releases, verification requires at minimum:
- target URL actually loads;
- no unintended auth/login gate;
- expected page/product identity matches the source being changed;
- critical interaction or endpoint is tested;
- deployment status is confirmed;
- no mockup/replacement was accidentally promoted.

## State discipline
Use evidence labels consistently: `FACT`, `DONE`, `OPEN`, `BLOCKED`, `UNVERIFIED`, `DECISION`.

After a material production change, update the relevant `CURRENT_STATE.md` with date, evidence location, impact and next action.

## Parallel work / device handoff
PC/Desktop/Codex is the default execution surface for code and multi-step technical work. Phone is the command, review and approval surface. Do not let two sessions modify the same file/branch concurrently without an explicit ownership handoff.

Every substantial handoff must state:
- project;
- repository;
- branch;
- base/main commit;
- latest branch commit;
- work item / owner;
- files changed;
- deployment/environment;
- tests/checks completed;
- open blockers;
- next exact action.

## Safety against false confidence
If a connector/tool cannot resolve a project or deployment that another tool claims exists, the state is not verified. Report the inconsistency and stop short of a production claim.

Never convert a tool error into a success narrative.

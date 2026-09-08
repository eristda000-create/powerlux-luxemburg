# MERG AI OS — PRODUCTION GATES

These gates exist to prevent fake completion, accidental replacement builds, wrong-project deployments and silent divergence between chat context and real systems.

## Gate 0 — Identify the real object
Before changing anything, answer internally and verify:
- What exact product/project is being changed?
- Does an original implementation already exist?
- What repository/file/project owns it?
- What is production vs preview vs historical/recovery?

If the original is uncertain, status = `BLOCKED: SOURCE NOT VERIFIED`.
Do not build a substitute.

## Gate 1 — Source preflight
Required evidence before write:
- repository name;
- branch;
- relevant existing file(s) or application structure;
- latest relevant commit/state;
- project-specific state docs read.

For an external/no-repo product, retrieve/export the original project source before migration work.

## Gate 2 — Tool preflight
Use the real system of record:
- GitHub for code and commit truth;
- Vercel for Vercel project/deployment/domain truth;
- Supabase for database/Auth/Edge Function truth;
- Drive/Docs/Sheets for canonical business documents/data;
- public web/runtime checks for user-visible behavior.

Do not infer live state from chat memory when a connector exists.

## Gate 3 — Change isolation
Before writing:
- check for concurrent work on the same branch/files;
- prefer a branch/PR for risky structural changes;
- do not create a second implementation path when an existing path should be fixed;
- preserve rollback capability.

## Gate 4 — No-mockup check
A change fails this gate if any of the following is true without explicit user request:
- static page substituted for dynamic product;
- fake cards/metrics/users/orders/leads inserted as if real;
- placeholder API treated as connected backend;
- screenshots or scraped copy used to recreate an existing app;
- new deployment called "current release" without original source lineage;
- demo UI is presented as production functionality.

## Gate 5 — Build and functional verification
Run the checks appropriate to the project. At minimum:
- syntax/build succeeds;
- relevant tests/checks pass;
- critical changed path is exercised;
- external dependencies return expected behavior;
- errors are not converted into synthetic success/empty data without an explicit degraded-state design.

## Gate 6 — Deployment verification
Before saying `deployed` or `live`, verify:
- correct target project;
- correct environment;
- exact commit/source lineage;
- deployment status;
- public URL resolves;
- unintended authentication is absent when public access is expected;
- visible application identity matches the expected real product;
- critical interaction/API path works.

A deployment tool returning `READY` is insufficient if the project cannot subsequently be resolved or the public URL cannot be accessed as intended. Mark such cases `UNVERIFIED` and investigate.

## Gate 7 — Backend verification
When Supabase is involved:
- verify the exact project by project name/context;
- never expose service-role/secret credentials;
- verify RLS/security implications for schema changes;
- test the actual query/function after change;
- run relevant security/performance advisors after DDL/security changes;
- ensure production data is not replaced by synthetic fixtures.

## Gate 8 — State update
After a material verified change, update the relevant `CURRENT_STATE.md` and/or decision log with:
- date;
- status label;
- evidence (commit/deployment/issue/test);
- impact;
- remaining blocker or next action.

## Gate 9 — Handoff
A task is not handoff-ready without:
- project;
- repo;
- branch;
- latest commit;
- deployment/environment;
- tests performed;
- what is verified vs unverified;
- open blockers;
- next exact action.

## Forbidden completion language
Do not say these words as factual status unless verification supports them:
`done`, `finished`, `live`, `fixed`, `working`, `connected`, `deployed`, `production-ready`, `public`, `released`.

If verification is partial, use precise language such as:
- `build succeeded; production not verified`;
- `deployment created; public access still blocked`;
- `source recovered; migration not yet deployed`;
- `preview verified; production unchanged`.

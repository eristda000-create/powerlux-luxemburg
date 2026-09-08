# MERG AI OS — CURRENT STATE

**As-of date:** 2026-09-08
**Role:** interim group-level control state for MERG / PowerLux / PowerTV / Cogni.

## Executive truth
`FACT` This GitHub repository (`eristda000-create/powerlux-luxemburg`) is currently the strongest verified shared technical control plane available to the connected ChatGPT environment.

`FACT` PowerLux has an existing dedicated operating system under `powerlux_os/`. Do not replace it; the MERG AI OS sits above it and governs cross-tool truth, release discipline and handoffs.

`FACT` A separate private GitHub repository named `eristda000-create/cogni` exists and is accessible with admin/write permission.

`FACT` Supabase management access on 2026-09-08 verified an active healthy project named `Cogni` plus one additional active healthy general project. Internal project refs/hosts are deliberately not duplicated into this public repository.

`FACT` Authenticated Vercel management access on 2026-09-08 verified the connected Vercel team and the real `powerlux-luxembourg` project with a READY latest deployment. A public `*.vercel.app` hostname must still not be assumed to belong to that connected team without project/deployment evidence.

## PowerLux
`FACT` Canonical Git repository: `eristda000-create/powerlux-luxemburg`.

`FACT` Known production hostname: `powerlux-luxembourg.vercel.app`.

`FACT` Authenticated Vercel management verification on 2026-09-08 confirmed the `powerlux-luxembourg` project and a READY latest deployment in the connected team.

`FACT` The existing PowerLux state documents record unresolved production/release-chain issues, including the need to canonicalize source → Git → preview → tests → rollback → production.

`FACT` An open canonical-release pull request exists and should be inspected before making structural release claims.

`RULE` For PowerLux details, read `powerlux_os/CURRENT_STATE.md` and related audit/release documents. This group file must not flatten or overwrite those facts.

## PowerTV
`FACT` The real current PowerTV product is an existing ChatGPT Sites application whose visible identity is `PowerTV — Sport jenseits des Mainstreams`, with PowerTV branding, `BY POWERLUX`, `MY PLX`, search/library behavior and a dynamically loaded catalog.

`FACT` No canonical PowerTV GitHub repository is currently verified in the connected GitHub account.

`FACT` Previous ad-hoc Vercel deployments named around `powertv-internal`, `powertv-public` and `powertv-network` were not a verified migration of the real PowerTV source and must NOT be treated as canonical PowerTV.

`FACT` Authenticated Vercel lookups on 2026-09-08 for `powertv-public`, `powertv-internal` and `powertv-network` returned not found in the connected team. No canonical PowerTV Vercel project was recovered there.

`FACT` Targeted File Library searches on 2026-09-08 did not recover a PowerTV source/export package.

`DONE` An incorrect static PowerTV replacement that had been committed under `powertv/index.html` was removed from this repository on 2026-09-08.

`DONE` A verified recovery ledger was added at `merg_os/POWERTV_SOURCE_RECOVERY.md`; it records checked GitHub/Vercel/File-Library paths and the exact criteria required before PowerTV may be called source-verified.

`OPEN / P0` Recover or export the ORIGINAL PowerTV source/project from ChatGPT Sites, then establish canonical Git source and only after that deploy to a neutral production hostname.

`RULE` Until canonical source is recovered, do not recreate PowerTV from screenshots, scraped text, descriptions or memory and do not call any replacement deployment "the current PowerTV release".

## Cogni / Diffuse
`FACT` Canonical Git repository currently verified: `eristda000-create/cogni` (private).

`FACT` The canonical Cogni repository's `AGENTS.md` and `README.md` were re-verified through authenticated GitHub access on 2026-09-08. The README records the canonical public host `https://cogni-release.vercel.app` and the multi-model release policy.

`DONE` A private-repo-native hourly source integrity watcher exists at `.github/workflows/cogni-source-integrity.yml` in `eristda000-create/cogni`. It uses that repository's own GitHub token and does not require a cross-repo personal token.

`OPEN / P0` Authenticated verification on 2026-09-08 found real Cogni source/runtime drift: canonical Git `cogni-ui-cognition` declares `ui-cognition-v21-event-only`, while the deployed Supabase Edge Function is ACTIVE version 30 and identifies as `ui-cognition-v30-jarvis-standalone`. Existing `Cogni Release Gate` failed specifically on the deployed Cognition UI health check while preceding source invariants and Core Status passed. The hourly integrity watcher now checks this exact contract and opened the automatically managed GitHub alert `eristda000-create/cogni#132`.

`RULE` Do not silently roll back or bless deployed Cogni v30. Reconcile whether it is an intentional Jarvis extension that must be represented in canonical Git while preserving single-owner/presentation-only invariants, or an out-of-band runtime deployment that must be reverted.

`FACT` A Supabase project named `Cogni` is active and healthy at the management/project level; that does not override the function-level source/runtime drift above.

`UNVERIFIED` The public `cogni-release.vercel.app` runtime is known and independently reachable, but direct authenticated lookup of project/deployment `cogni-release` in the currently connected Vercel team returned not found on 2026-09-08. Therefore its Vercel account/team ownership remains unresolved and must not be guessed.

`RULE` Cogni-specific state should live in the Cogni repository; this file stores only cross-project truth.

## MERG group
`DECISION` MERG is the umbrella operating context. PowerLux, PowerTV, Cogni/Diffuse and future businesses should use a common production-first AI operating discipline.

`OPEN` A dedicated MERG HQ repository is not currently verified/available through the connected GitHub account. Until one exists, this repository temporarily hosts the group AI operating rules.

## Non-negotiable truth rule
Chat memory is not a deployment database. A statement such as "we already connected/deployed/built this" must be checked against the relevant real system whenever the answer or action depends on it.

## Update protocol
Update this file only for material cross-project changes such as:
- canonical repository added/changed;
- production host verified/changed;
- backend ownership changed;
- source-of-truth recovered;
- major incident or release gate changed;
- project moves to a dedicated control repository.

Each update must include a date and one of: `FACT`, `DONE`, `OPEN`, `BLOCKED`, `UNVERIFIED`, `DECISION`.

# MERG AI OS — CURRENT STATE

**As-of date:** 2026-09-08
**Role:** interim group-level control state for MERG / PowerLux / PowerTV / Cogni.

## Executive truth
`FACT` This GitHub repository (`eristda000-create/powerlux-luxemburg`) is currently the strongest verified shared technical control plane available to the connected ChatGPT environment.

`FACT` PowerLux has an existing dedicated operating system under `powerlux_os/`. Do not replace it; the MERG AI OS sits above it and governs cross-tool truth, release discipline and handoffs.

`FACT` A separate private GitHub repository named `eristda000-create/cogni` exists and is accessible with admin/write permission.

`FACT` Supabase has an active healthy project named `Cogni` plus one additional active healthy general project. Internal project refs/hosts are deliberately not duplicated into this public repository.

## PowerLux
`FACT` Canonical Git repository: `eristda000-create/powerlux-luxemburg`.

`FACT` Known production hostname: `powerlux-luxembourg.vercel.app`.

`FACT` The existing PowerLux state documents record unresolved production/release-chain issues, including the need to canonicalize source → Git → preview → tests → rollback → production.

`FACT` An open canonical-release pull request exists and should be inspected before making structural release claims.

`RULE` For PowerLux details, read `powerlux_os/CURRENT_STATE.md` and related audit/release documents. This group file must not flatten or overwrite those facts.

## PowerTV
`FACT` The real current PowerTV product is an existing ChatGPT Sites application whose visible identity is `PowerTV — Sport jenseits des Mainstreams`, with PowerTV branding, `BY POWERLUX`, `MY PLX`, search/library behavior and a dynamically loaded catalog.

`FACT` No canonical PowerTV GitHub repository is currently verified in the connected GitHub account.

`FACT` Previous ad-hoc Vercel deployments named around `powertv-internal`, `powertv-public` and `powertv-network` were not a verified migration of the real PowerTV source and must NOT be treated as canonical PowerTV.

`DONE` An incorrect static PowerTV replacement that had been committed under `powertv/index.html` was removed from this repository on 2026-09-08.

`OPEN / P0` Recover or export the ORIGINAL PowerTV source/project from ChatGPT Sites, then establish canonical Git source and only after that deploy to a neutral production hostname.

`RULE` Until canonical source is recovered, do not recreate PowerTV from screenshots, scraped text, descriptions or memory and do not call any replacement deployment "the current PowerTV release".

## Cogni / Diffuse
`FACT` Canonical Git repository currently verified: `eristda000-create/cogni` (private).

`FACT` A Supabase project named `Cogni` is active and healthy.

`OPEN` Vercel canonical production project/domain for Cogni must be verified from Vercel before making release claims.

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

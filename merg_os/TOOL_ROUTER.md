# MERG AI OS — TOOL ROUTER

Use the tool that owns the truth. Do not use whichever tool is merely convenient.

## Core routing

| Need | Primary tool/system | Rule |
|---|---|---|
| Code, files, branches, commits, PRs | GitHub / local Git / Codex | Read existing source before writing. Code truth lives here. |
| Local implementation, tests, terminal, repo work | Codex on desktop/PC | Work on the actual checked-out repository. Verify build/tests before handoff. |
| Vercel projects, deployments, domains, logs | Vercel | Resolve actual project/deployment before claiming live state. |
| Database, Auth, Edge Functions, RLS | Supabase | Query the real project. Never infer backend state from frontend code alone. |
| Business docs, contracts, operating docs, Sheets | Google Drive / Docs / Sheets | Treat the designated canonical document as business-document truth. |
| Current public facts, competitors, pricing, rules, external websites | Web | Search current sources; timestamp material facts. |
| Cross-app multi-step research/operations | ChatGPT Work | Use when substantial multi-system work is needed; still respect each system of record. |
| Conversation/project coordination | ChatGPT Project | Use for command context and intent, not as the sole record of technical production state. |
| Visual marketing/design | Canva | Do not let design files become the source of product functionality. |
| Business/KPI analysis | Data Analytics | Read actual data sources; label assumptions separately from actuals. |

## Connector-first rule
When a connected authoritative tool exists, use it before relying on memory or generic web search for the user's own assets.

Examples:
- "our latest deploy" → Vercel, not memory;
- "our code" → GitHub/repo, not a previous chat snippet;
- "our database" → Supabase, not frontend assumptions;
- "our contract" → Drive/document source, not recollection.

## Conflict resolution
If tools disagree:
1. Do not choose the most convenient answer.
2. Identify which system actually owns the disputed fact.
3. Verify runtime/live behavior where relevant.
4. Mark the state `UNVERIFIED` until reconciled.
5. Record the divergence if it can cause future errors.

## Creation guard
Never create a new repository, Vercel project, Supabase project, site, database or replacement implementation merely because a connector search returned no result on the first attempt.

Before creating:
- retry discovery with alternate names;
- inspect project registry/current state;
- search connected sources;
- check whether the object exists under a legacy/alternate name.

## Tool-result honesty
A tool response is evidence, not permission to exaggerate.

Examples:
- `Deployment READY` + URL requires login when it should be public → not publicly released.
- API call succeeds but downstream UI still fails → not fixed.
- file committed but not deployed → source updated, not live.
- preview works but production not promoted → preview verified, production unchanged.

## Write authority
For consequential writes, prefer the narrowest real target. Do not modify unrelated systems to work around a missing connection. If the intended source is inaccessible, report the blocker instead of manufacturing a parallel system.

# MERG AI OS — PROJECT REGISTRY

**As-of date:** 2026-09-08

This registry tells AI agents what is canonical, what is provisional and what must be verified before action.

| Project | Role | Canonical code source | Production truth | Status / rule |
|---|---|---|---|---|
| MERG | Group / umbrella operating context | No dedicated HQ repo verified yet | No single production surface | This repository temporarily hosts the group AI OS only. Do not infer that all MERG businesses share this codebase. |
| PowerLux | Sports / athlete / discovery ecosystem | `eristda000-create/powerlux-luxemburg` | Verify Vercel + runtime; known hostname `powerlux-luxembourg.vercel.app` | Read `powerlux_os/*` before substantive action. Existing canonicalization/release issues remain relevant. |
| PowerTV | Sport / niche-sport streaming and editorial platform | **No canonical Git source verified yet** | Existing real ChatGPT Sites product titled `PowerTV — Sport jenseits des Mainstreams` | Do not recreate. Recover/export original source first. Ad-hoc Vercel replacements are non-canonical. |
| Cogni / Diffuse | Multi-LLM platform | `eristda000-create/cogni` (private) | Verify Vercel before release claims; Supabase project `Cogni` verified active/healthy | Cogni-specific truth belongs in Cogni repo. |
| MERG Trading | Cross-industry trading / sourcing / intermediary engine | `UNVERIFIED` | `UNVERIFIED` | Do not invent repo/backend/deployment. Find original source before implementation changes. |
| Jarvis / Automation | Cross-project AI/automation control layer | `UNVERIFIED` as a dedicated repo | `UNVERIFIED` | Treat as an operating capability, not as deployed software, until source/runtime is verified. |

## Canonicality levels

### CANONICAL
A source is canonical only when the original implementation and ownership are verified and it is the intended base for future changes.

### PROVISIONAL
A preview, recovery layer, migration branch, temporary deployment or copied asset can be useful, but it must never silently become the canonical source.

### NON-CANONICAL
Mockups, screenshots, scraped reconstructions, one-off HTML replicas and ad-hoc deployments are non-canonical unless the user explicitly promotes them through a recorded decision after comparing them with the real product.

## New-project registration rule
Before a new project is created, search connected GitHub, Vercel, Supabase, Drive/Sites and current project state for an existing original. If an existing original might exist, creation is blocked until that uncertainty is resolved.

When a new canonical project is established, add:
- project name and role;
- canonical repository;
- default branch;
- production host/project name;
- backend/system of record;
- owner/decision authority if relevant;
- last verified date;
- migration/legacy sources that must not be mistaken for canonical.

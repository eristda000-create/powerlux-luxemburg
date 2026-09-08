# MERG AI Operating System v1

Purpose: keep AI work consistent across ChatGPT, Codex, GitHub, Vercel, Supabase and other coding assistants by forcing every session to use the same verified project truth.

## Read order
1. `/AGENTS.md`
2. `CURRENT_STATE.md`
3. `PROJECT_REGISTRY.md`
4. `PRODUCTION_GATES.md`
5. `TOOL_ROUTER.md`
6. `DEVICE_WORKFLOW.md`
7. project-specific operating/state documents.

## What this prevents
- mockup substituted for existing product;
- new repo/project created because the original was not searched thoroughly;
- preview called production;
- deployment `READY` called public even though auth blocks it;
- code existence called working functionality;
- two PC/phone sessions building competing versions;
- model memory overriding Git/Vercel/Supabase reality.

## Tool adapters currently installed in this repo
- Codex / general agents: `/AGENTS.md`
- GitHub Copilot: `/.github/copilot-instructions.md`
- Claude Code: `/CLAUDE.md`
- Gemini: `/GEMINI.md`
- Cursor: `/.cursor/rules/production-first.mdc`
- ChatGPT Project copy text: `/merg_os/CHATGPT_PROJECT_INSTRUCTIONS.md`

## Current rollout
- PowerLux/control repo: installed.
- Cogni repo: production-first agent adapters installed separately.
- PowerTV: original-source recovery remains required before canonical Git/Vercel migration.

## Governing principle
AI is the operator, not the source of truth. The real systems are the source of truth.

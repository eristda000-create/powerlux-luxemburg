# MERG AI OS — NEW REPOSITORY BOOTSTRAP

Use this checklist whenever a new MERG-group repository is established or an existing repo is brought under the common AI operating system.

## Required files
Create or adapt:
- `/AGENTS.md`
- `/.github/copilot-instructions.md`
- `/CLAUDE.md`
- `/GEMINI.md`
- `/.cursor/rules/production-first.mdc`
- project-specific `CURRENT_STATE.md` or equivalent

## Minimum AGENTS rules
Every project adapter must contain these requirements:
1. find the original implementation before building;
2. no mockups/replacements unless explicitly requested;
3. authoritative system-of-record routing;
4. production claims require real verification;
5. if tools disagree, mark UNVERIFIED and reconcile;
6. parallel sessions require branch/task ownership;
7. substantial handoffs include repo, branch, commit, deployment, tests, blockers and next action.

## Registration
After establishing a new canonical project, update `/merg_os/PROJECT_REGISTRY.md` with:
- project role;
- canonical repo;
- production host/project name;
- backend/system of record;
- canonical branch;
- legacy/non-canonical sources to avoid;
- last verification date.

Do not put secrets, private keys, service-role credentials, private database hosts or sensitive account identifiers into a public repository.

## ChatGPT setup
Copy the relevant rules from `/merg_os/CHATGPT_PROJECT_INSTRUCTIONS.md` into the corresponding ChatGPT Project Instructions so chat-level coordination follows the same source-first behavior.

## First session test
A newly configured agent should be able to answer these questions before doing work:
- What project am I in?
- What repo/branch is canonical?
- What is the current production target?
- What backend owns runtime data?
- What sources are explicitly non-canonical?
- What must I verify before saying done/live/fixed?

If it cannot answer, setup is incomplete.

# PowerLux Git Operating Policy

**Status:** DECIDED / CURRENT
**Applies to:** humans, ChatGPT, Codex, Qwen/Ollama, GitHub automation and CENTRAL.

## Canonical repository
- Canonical repository: `eristda000-create/powerlux-luxemburg`.
- Canonical integration branch: `main`.
- Existing PowerLux and PowerTV projects are improved in place. Do not create rebuilds, replicas, replacement frontends or parallel product trees unless the owner explicitly requests a prototype.

## Single-writer rule
- One work item owns one branch at a time.
- Do not let two agents/sessions modify the same branch concurrently.
- Before a substantive write, record or verify project, repository, branch, owner/work item and latest base commit.
- If ownership is unclear, stop the write and treat the branch as busy.

## Branch lifecycle
1. Start from a freshly fetched `main`.
2. Branch from current `origin/main` using a short-lived branch such as `feature/*`, `fix/*`, `chore/*`, `docs/*`, `central/*` or `hotfix/*`.
3. Keep the branch focused on one work item.
4. Before review/merge, the branch must contain the current `main`; stale branches must be synchronized before more feature work is added.
5. Run required tests/CI.
6. Merge only after evidence passes.
7. Close the PR immediately after merge or abandonment. Do not resurrect abandoned rebuild/recovery branches as canonical work.

## Main discipline
- Normal feature/code work must not be committed directly to `main`.
- Direct `main` writes are reserved for narrowly scoped repository-control emergencies or owner-authorized administrative fixes.
- Agents must prefer branch + PR for all ordinary code, product and infrastructure changes.

## Safe local sync
The PC may update `main` only through a clean fast-forward:
- correct repository;
- branch `main`;
- exact expected `origin`;
- clean working tree;
- local HEAD is an ancestor of `origin/main`;
- `git merge --ff-only origin/main` only.

Never use automatic `reset --hard`, force push, rebase of shared branches, arbitrary checkout/switch, or deletion of local work to solve drift.

## Pull request gates
A PR is not ready if any of the following is true:
- base branch is not `main`;
- branch does not contain current `origin/main`;
- merge conflicts exist;
- tests/checks fail;
- branch mixes unrelated work items;
- it introduces a rebuild/replica/mockup of an existing PowerLux or PowerTV product without explicit owner instruction;
- deployment/source identity is not verified for release work.

## Stale/legacy branches
Historical branches may remain for audit until safely deleted, but they are non-canonical. Closed PRs #6, #8 and #9 are explicitly non-canonical and must not be reopened or used as production source without a new owner decision.

## Agent handoff packet
Every code handoff must include:
- repository;
- branch;
- base/main commit;
- latest branch commit;
- work-item/owner;
- files changed;
- tests run;
- deployment/environment if any;
- blockers;
- next exact action.

## Definition of Git-clean
`GIT CLEAN` means all of the following are verified:
- working tree clean;
- expected branch;
- expected remote;
- branch relationship to `origin/main` known;
- no unreviewed concurrent writer on that branch;
- no unresolved merge/rebase/cherry-pick state.

Never report Git as clean based only on `git status` without checking branch and remote identity.

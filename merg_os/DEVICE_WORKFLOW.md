# MERG AI OS — PC + PHONE WORKFLOW

## Operating model
**PC/Desktop = execution surface.**
Use it for Codex, repository work, terminal, builds, tests, browser verification, deployments and complex multi-step Work sessions.

**Phone = command / review / approval surface.**
Use it to issue priorities, review status, approve consequential actions, inspect links/results and redirect work.

The phone and PC must operate on the same canonical project state; they are not separate sources of truth.

## Work-first / Chat-fallback routing
For substantial multi-step, multi-app, browser/computer-use or artifact-producing work, **ChatGPT Work is the preferred ChatGPT execution surface when it is available for the user/session**.

If Work is unavailable, not selected, temporarily limited, or the task is being handled in normal Chat, normal Chat becomes the fallback surface **without resetting context**.

Surface selection must never create a second project state. Work, normal Chat, phone and PC all resume from the same canonical task state.

Before substantive execution in either Work or normal Chat, the active session must load or verify, as applicable:
1. `merg_os/CURRENT_STATE.md`;
2. `merg_os/PROJECT_REGISTRY.md`;
3. `merg_os/TOOL_ROUTER.md`;
4. this `DEVICE_WORKFLOW.md`;
5. the project-specific current state / router / decision log;
6. the active canonical work item and latest handoff packet when one exists;
7. current repository branch/commit and owning execution session when code is involved.

**No-context-loss rule:** a new normal Chat or Work session must not continue a production task from chat memory alone. It must reconstruct the working context from the canonical state sources above before making substantive claims or writes.

**Work → Chat fallback:** if a Work session cannot continue, preserve the current work item, repo, branch, latest commit, verified results, blockers and next exact action. Normal Chat then continues the **same** work item; it must not create a duplicate task or replacement implementation.

**Chat → Work promotion:** if Work becomes available later and the task benefits from it, Work resumes the **same** canonical work item and handoff state. Promotion to Work changes the execution surface, not the source of truth or task identity.

A UI/session switch that cannot be performed programmatically must be treated as a surface limitation, not as permission to lose context or invent a new workflow.

## Start-of-task protocol
Before substantial work, the active agent records internally:
- PROJECT
- REPOSITORY
- BRANCH
- TASK
- SOURCE OF TRUTH
- PRODUCTION TARGET (if any)
- CURRENT OWNER/SESSION
- EXECUTION SURFACE (`work`, `chat`, `codex`, `central_workshop`, etc.)
- ACTIVE WORK ITEM / HANDOFF ID (if applicable)

If any field is unknown and relevant, discover it before writing.

## Parallel-session rule
Two agents/sessions must not edit the same branch/files at the same time without explicit coordination.

Preferred pattern:
- one task = one branch/PR or clearly owned write path;
- parallel tasks operate on non-overlapping branches/areas;
- the current owner is stated in the handoff/status;
- incoming phone instructions modify the goal/priority, not silently start a competing implementation.

## Phone command examples
Good commands:
- `PowerTV: continue original-source recovery. Do not rebuild. Report only verified progress.`
- `PowerLux: inspect production + GitHub before touching code; fix the P0 discovery defect on a branch and verify preview.`
- `Cogni: check the latest real Vercel deployment and Supabase health, then tell me the single highest release blocker.`

Avoid ambiguous commands such as `build it again` when an original may already exist. The agent must still resolve source identity before creation.

## Handoff packet
At the end of substantial PC/Codex/Work/Chat work, provide or persist this exact state packet:

```text
PROJECT:
REPO:
BRANCH:
LATEST COMMIT:
DEPLOYMENT / ENVIRONMENT:
SOURCE USED:
EXECUTION SURFACE:
ACTIVE WORK ITEM / HANDOFF ID:
VERIFIED:
NOT VERIFIED:
TESTS / CHECKS:
OPEN BLOCKERS:
NEXT EXACT ACTION:
```

A new phone, desktop, Work or normal Chat session must read this packet plus the canonical repository state before continuing.

## Release command protocol
If the phone says `release`, `deploy`, `make public`, `ship`, or equivalent, that does NOT waive production gates.
The execution agent must still verify source lineage, target environment, tests, public access and real product identity.

## Interruption protocol
If a new instruction arrives while another agent is mid-task:
1. preserve the current branch/state;
2. note what is complete vs incomplete;
3. apply the new instruction to the same task owner when possible;
4. do not create a duplicate implementation just because a second chat or Work session was opened.

## Daily control habit
For active production projects, the useful daily phone view is:
- what changed since last verified state;
- what is blocked;
- what can make money / reduce risk / unblock release today;
- next exact action and owner.

Do not generate ceremonial status reports when nothing material changed.

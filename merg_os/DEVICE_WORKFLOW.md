# MERG AI OS — PC + PHONE WORKFLOW

## Operating model
**PC/Desktop = execution surface.**
Use it for Codex, repository work, terminal, builds, tests, browser verification, deployments and complex multi-step Work sessions.

**Phone = command / review / approval surface.**
Use it to issue priorities, review status, approve consequential actions, inspect links/results and redirect work.

The phone and PC must operate on the same canonical project state; they are not separate sources of truth.

## Start-of-task protocol
Before substantial work, the active agent records internally:
- PROJECT
- REPOSITORY
- BRANCH
- TASK
- SOURCE OF TRUTH
- PRODUCTION TARGET (if any)
- CURRENT OWNER/SESSION

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
At the end of substantial PC/Codex work, provide this exact state packet:

```text
PROJECT:
REPO:
BRANCH:
LATEST COMMIT:
DEPLOYMENT / ENVIRONMENT:
SOURCE USED:
VERIFIED:
NOT VERIFIED:
TESTS / CHECKS:
OPEN BLOCKERS:
NEXT EXACT ACTION:
```

A new phone or desktop session should request/read this packet plus the repository state files before continuing.

## Release command protocol
If the phone says `release`, `deploy`, `make public`, `ship`, or equivalent, that does NOT waive production gates.
The execution agent must still verify source lineage, target environment, tests, public access and real product identity.

## Interruption protocol
If a new instruction arrives while another agent is mid-task:
1. preserve the current branch/state;
2. note what is complete vs incomplete;
3. apply the new instruction to the same task owner when possible;
4. do not create a duplicate implementation just because a second chat was opened.

## Daily control habit
For active production projects, the useful daily phone view is:
- what changed since last verified state;
- what is blocked;
- what can make money / reduce risk / unblock release today;
- next exact action and owner.

Do not generate ceremonial status reports when nothing material changed.

# POWERLUX MOBILE COMMANDS

Use these short commands directly in the ChatGPT phone app.

## CENTRAL mobile operations

`CENTRAL: PC status`
→ verifies the real Workshop node through the connected control plane and reports heartbeat, runtime verification, Ollama models, active local job, waiting jobs and the exact boundary of what is not observable remotely. Never infer CPU/screen/UI activity from heartbeat alone.

`CENTRAL: Qwen`
→ returns what local Ollama/Qwen actually completed, what is currently `reviewing`, what is waiting, and the ChatGPT control review of each result. Qwen output is draft evidence, not automatically project truth.

`CENTRAL: arbeiten — <objective>`
→ creates a bounded `AUTO_SAFE` local execution sequence for the verified PC when the objective can be handled by supported Workshop capabilities. Relevant verified context is brokered into the job. External messages, deployments, purchases, contracts and arbitrary PowerShell remain excluded unless a later named capability is explicitly approved and verified.

`CENTRAL: weiter`
→ continues the current project objective from canonical state: check the PC/queue, review completed Qwen outputs, reject unsupported claims, enqueue the next smallest useful local jobs, and execute available cloud-side GitHub/Supabase/Vercel/research work. Do not create filler jobs merely to keep the PC busy.

`CENTRAL: Context <topic>`
→ refreshes a Verified Context Packet from authoritative connected systems. Labels must distinguish `FACT`, `CONNECTOR_FACT`, `USER_FACT`, `OPEN`, `QWEN_DRAFT` and `REJECTED` so local models do not silently promote previous suggestions into truth.

`CENTRAL: PC update`
→ reports whether the local checkout is behind canonical Git and what update is needed. It must not claim a pull/restart happened unless a supported remote capability actually performed it and runtime evidence confirms the new commit. The current Workshop deliberately has no unrestricted remote shell.

### Mobile operating loop

Preferred phone → PC loop:

```text
Phone / ChatGPT command
        ↓
authoritative connector checks
        ↓
CENTRAL Verified Context Packet
        ↓
approved AUTO_SAFE work item
        ↓
Windows Workshop bridge
        ↓
Ollama / Qwen local work
        ↓
CENTRAL result
        ↓
ChatGPT control review
        ↓
next execution action / user-visible result
```

A completed Qwen response is not enough to call a task complete. ChatGPT must compare consequential claims with the owning source (GitHub, Vercel, Supabase, web evidence, etc.) before accepting them.

## Daily control
`PowerLux OS: heute`
→ reads Bootstrap + Current State + Dashboard; returns the 3 highest-value next actions.

`PowerLux OS: Update`
→ returns what is verified, open, blocked and what changed since the latest dated evidence available.

`PowerLux OS: P0`
→ returns only current P0 blockers/actions, ranked by revenue/risk impact.

## Revenue / sales
`PowerLux OS: Geld diese Woche`
→ routes Sales → Offer → Finance → Execution; prioritises actions that can create real cash/proof quickly.

`PowerLux OS: Leads`
→ reviews target accounts, qualification, next steps and stale follow-ups.

`PowerLux OS: Angebot <name>`
→ checks scope, buyer, price floor, direct costs, margin, risk and proposal logic.

`PowerLux OS: Sponsor <name>`
→ checks give/get economics, rights, conflicts, proposal and next step.

## Website / product
`PowerLux OS: Website`
→ routes Digital → QA/Risk → Conversion → Execution; starts with live-production truth and critical user journeys.

`PowerLux OS: Login`
→ focuses authentication/account creation, mobile/desktop behavior, telemetry and rollback.

`PowerLux OS: Map`
→ focuses PowerMap/PLX Radar scalability, relevance, clustering, data source quality and UX.

## Events / operations
`PowerLux OS: Event <name>`
→ checks feasibility, P&L, owner, run-of-show, insurance/permit/safety, KPI capture and 48h review.

`PowerLux OS: Pilot`
→ identifies the strongest next pilot based on demand, delivery risk, economics, case-study value and speed.

## Strategy
`PowerLux OS: Strategie`
→ reviews current strategic choices and unresolved gates without rebuilding the full business plan.

`PowerLux OS: SWOT`
→ returns only evidence-backed SWOT items with strategic consequences and actions.

`PowerLux OS: PESTEL`
→ checks external factors and identifies which current assumptions/decisions they change.

## Finance
`PowerLux OS: Cash`
→ checks actual cash evidence, 13-week view, commitments and biggest cash risks; does not treat planning targets as actuals.

`PowerLux OS: Kalkulation <offer/event>`
→ builds/checks price, direct cost, contribution margin, break-even and downside case.

## Governance / legal
`PowerLux OS: Entscheidung <topic>`
→ checks Decision Log first, then produces a decision memo with options, evidence, trade-offs and recommendation.

`PowerLux OS: Recht <topic>`
→ routes Legal/Compliance and requires current authoritative validation before a high-stakes implementation claim.

`PowerLux OS: Entscheidung eintragen — <text>`
→ prepare/update the Decision Log when explicitly requested.

## Deep-dive mode
Add `deep` to any command:

`PowerLux OS: deep — wie verdienen wir mit Gemeinden Geld?`

Deep mode means:
1. Bootstrap
2. Current State
3. Decision Log
4. relevant Strategy OS workstreams
5. primary PowerLux documents
6. authoritative external research where useful
7. McKinsey-style synthesis: issue tree, evidence, economics, risks, recommendation, milestones and next actions.

## Output standard on mobile
Default response should be concise enough to operate from a phone, but decision-grade:

**STATUS**
- verified truth

**DECISION**
- recommended move

**DO NOW**
1. action
2. action
3. action

**OWNER / DEADLINE**
- named owner and timeframe

**KPI / EVIDENCE**
- what proves completion

**BLOCKER / RISK**
- what can invalidate the move

## No-mockup rule
If the user asks to implement, deploy, send, update or fix something and an authorized connected tool can perform the real action, prefer the real action over merely describing/mockuping it. Report clearly what was actually changed versus what still requires approval/access.

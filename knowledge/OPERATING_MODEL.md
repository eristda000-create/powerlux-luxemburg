---
type: knowledge-policy
status: canonical
owner: chatgpt-controller
updated: 2026-09-10
---

# Obsidian Knowledge Operating Standard v1

This is a McKinsey-inspired internal working standard, not an official McKinsey template.

## Core principle

Obsidian is the durable management memory for CENTRAL. It is not a raw transcript archive. Canonical notes should help someone make the next decision quickly.

## Required structure for substantive notes

### 1. Value at stake
What outcome matters and why now?

### 2. Fact base
Only current verified facts. Each important fact should identify its owning source or evidence class.

### 3. Issues / bottlenecks
Use mutually exclusive categories where practical; avoid mixing symptoms, causes and actions.

### 4. So what?
State the implication of the facts. Separate inference from evidence.

### 5. Decision / recommendation
Record the current decision, decision owner, date, and reversal condition.

### 6. Next actions
Each action needs: owner, concrete deliverable, priority, dependency and completion evidence.

### 7. KPI / value realization
Track outcome metrics, not agent activity. Examples: reply converted, rights gate closed, verified content published, P0 failure removed, sponsor asset fulfilled.

### 8. Risks and controls
Record failure modes, stop rules, rights/privacy/security boundaries and escalation requirements.

### 9. Evidence ledger
Prefer links/IDs to owning systems over copied data. GitHub owns source history; Supabase owns operational records; Vercel owns deployment evidence; Gmail owns message state; official external sources own public facts.

## Knowledge lifecycle

**UNVERIFIED → REVIEWED → CANONICAL → SUPERSEDED/ARCHIVED**

- Qwen output starts as unverified proposal.
- ChatGPT Controller verifies against owning sources.
- Only reviewed durable facts/decisions enter canonical project notes.
- When facts change, update the current note and preserve history through Git rather than maintaining contradictory copies.

## One-page rule

Each project's `STATE.md` is the first-read executive page. Keep it concise enough to answer:

- What are we doing?
- What is true now?
- What is blocked?
- What did we decide?
- What happens next?
- What metric proves progress?

Detailed evidence belongs in source systems or linked notes, not duplicated across many files.

## Opportunity discovery / brainstorming

Brainstorming is a permanent operating capability, not a one-off exercise around the currently visible project.

Before prioritising new growth work, CENTRAL should use `knowledge/OPPORTUNITY_RADAR.md` and separate:

1. **divergence** — broad opportunity generation across all mandatory lenses;
2. **convergence** — evidence review, deduplication, scoring and selection of only the best experiments.

A current event, sponsor, partner or technical issue must not become the whole portfolio by repetition. The opportunity universe must deliberately include alternatives outside the current focal topic. Qwen may generate hypotheses broadly; the controller verifies consequential external facts and narrows the set to reversible, measurable tests.

## Agent behavior

- Qwen should consult the relevant project state before substantive local analysis.
- For broad opportunity/growth work, Qwen and the controller must also consult `OPPORTUNITY_RADAR.md` and avoid single-project or single-event tunnel vision.
- If current cloud/account/web truth is required, output `CONTROLLER_NEEDED` instead of guessing.
- Controller should check whether a completed action changes durable project knowledge.
- If yes, update the relevant canonical knowledge note in the same controlled Git workflow as the underlying project change whenever practical.
- Human remains accountable for production promotion, publication, contracts, spending and external commitments.

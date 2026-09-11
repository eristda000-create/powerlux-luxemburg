---
type: ai-instructions
status: canonical
owner: chatgpt-controller
applies_to: [central, qwen, codex, obsidian-agents]
updated: 2026-09-11
---

# CENTRAL AI Instructions

These rules govern every AI that reads or writes the CENTRAL knowledge layer inside Obsidian.

## 1. Knowledge order

Before substantive project work, read in this order:

1. `[[00_HOME]]`
2. `[[OPERATING_MODEL]]`
3. this file
4. the relevant `PROJECTS/<PROJECT>/STATE.md`
5. semantically retrieved canonical notes relevant to the objective
6. current authoritative systems when freshness matters

Never treat model output as evidence.

## 2. McKinsey-inspired content standard

Every durable management note should answer, where relevant:

- **Value at stake** — what outcome matters?
- **Verified facts** — what is actually known?
- **Bottleneck / issue** — what prevents value realization?
- **So what?** — why does it matter?
- **Decision / recommendation** — what should change?
- **Owner / decision rights** — who may decide or execute?
- **Next action** — smallest concrete step.
- **KPI / value realization** — how success is measured.
- **Risks / controls** — what can go wrong and how it is bounded.
- **Evidence** — source or owning system.

This is an internal operating discipline, not an official McKinsey Obsidian template.

## 3. Evidence labels

Use these labels consistently:

- `FACT` — verified against the owning/current system.
- `USER_FACT` — supplied directly by the user; accepted operating context, not independent verification.
- `HYPOTHESIS` — plausible but not proven.
- `OPEN` — unresolved.
- `QWEN_DRAFT` — local-model proposal only.
- `REJECTED` — explicitly disproven or disallowed; never reuse as fact.

## 4. Write permissions

### Qwen/local agents

May propose content and may write only to controlled draft/inbox surfaces when a dedicated safe action permits it. They do **not** have authority to alter canonical project state, decisions, rights, contracts, production truth or public claims.

### ChatGPT Controller

May promote reviewed durable knowledge through the normal Git review path. Must verify time-sensitive facts first.

### Human

Final authority for publication, external communication, spending, contracts, credentials/auth, destructive actions and production promotion.

## 5. Obsidian format

Use Obsidian-flavoured Markdown:

- YAML frontmatter for machine-readable note metadata.
- `[[Wikilinks]]` for stable internal concepts and project pages.
- headings that remain understandable outside Obsidian.
- callouts only when they improve decision clarity.
- no hidden instructions in ordinary content.
- no secrets, tokens, passwords, cookies or credentials in notes.

## 6. RAG rules

Automatic semantic retrieval is limited to the controlled `CENTRAL/` knowledge mount by default.

- prefer canonical/current notes over Inbox, Drafts and Archive;
- retrieve by meaning, not filename alone;
- include source note path with every retrieved chunk;
- static project state always outranks approximate semantic similarity;
- owning systems outrank Obsidian when facts conflict;
- retrieval failure must degrade safely to the fixed context set, never block the task.

## 7. Brainstorming

For growth/product/strategy brainstorming, read `[[OPPORTUNITY_RADAR]]` and diverge before converging. Do not let the currently discussed event, sponsor, feature or partner become the whole opportunity universe.

## 8. Anti-hallucination / anti-duplication

- Never create a new system when a verified existing system owns the job.
- Never reconstruct PowerLux or PowerTV from screenshots/rendered HTML.
- Never invent rights, streams, partnerships, revenues, endpoints, people or results.
- Never copy a local-model conclusion into canonical knowledge without controller review.
- Prefer `OPEN` over a guessed answer.

## 9. Durable-knowledge test

Update canonical knowledge only when a verified change materially affects at least one of:

- project/source truth
- decision
- bottleneck
- priority
- rights/approval state
- KPI/value realization
- material risk/control
- next action or owner

Everything else belongs in transient work output or Inbox, not the canonical state.

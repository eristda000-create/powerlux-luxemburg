---
type: project-state
project: central
status: canonical
owner: chatgpt-controller
updated: 2026-09-10
---

# CENTRAL — Current State

## Value at stake
Create a reliable human+agent operating layer where local AI can analyze continuously, escalate uncertainty, and hand verified work to the controller without losing project context.

## Verified fact base

- Verified Windows node: `DESKTOP-FP4OP26-User`.
- CENTRAL Supervisor and Workshop Bridge are active.
- Ollama models available: `qwen3:4b-instruct` and `qwen3:1.7b`.
- Qwen 4B is the primary local analyst; 1.7B is the fast critic/planner.
- Local arbitrary shell is disabled.
- Local repository access is bounded; consequential truth must be verified by the controller.
- Safe Git fast-forward update is available and has completed real updates on the PC.
- Local-to-controller escalation is supported through `CONTROLLER_NEEDED` and the assistant-request control plane.
- Obsidian vault is connected at the verified Windows vault path and is used as the durable knowledge layer.
- CENTRAL knowledge is mounted into the vault under `CENTRAL/`.
- Knowledge-first use is enforced for every `local_agent_team` work item by the control plane: the internal standard is `mckinsey_inspired_v1`, and the first mandatory Obsidian pages are `CENTRAL/OPERATING_MODEL.md` plus the relevant project `STATE.md`.
- A live end-to-end PowerLux verification on 2026-09-10 returned `context_sources` containing `repo:AGENTS.md`, `obsidian:CENTRAL/OPERATING_MODEL.md`, and `obsidian:CENTRAL/PROJECTS/POWERLUX/STATE.md`.
- The local agent's context budget is reserved so repository snippets cannot crowd the mandatory Obsidian management pages out.

## Current bottlenecks

- Small local model can return empty planner/guardian output; controller escalation must never depend on it alone.
- Long multi-agent jobs can exceed runtime timeouts; route bounded business/content tasks to smaller single-model jobs.
- Obsidian knowledge must remain evidence-gated so model errors do not become durable facts.

## Current decision
Use outcome-based, knowledge-first routing: mandatory Obsidian operating model + project state first, local Qwen for bounded reasoning, ChatGPT Controller for current/connected truth and controlled writes, human for consequential external/production decisions.

## Next actions

1. Keep PC runtime healthy and current via safe fast-forward only.
2. Keep Obsidian operating model + project state mandatory for substantive local-agent work.
3. Update canonical knowledge whenever a controller-verified durable fact, decision, bottleneck, KPI, risk, rights state, source truth, priority, or next action changes.
4. Never promote raw Qwen output directly into canonical knowledge.
5. Route long/open-ended agent work into smaller bounded jobs.

## KPIs

- local stale reviewing jobs = 0
- unreviewed local results = 0
- unsafe Git operations = 0
- controller escalations resolved with evidence
- substantive local-agent work with mandatory Obsidian management context = 100%
- canonical knowledge changes with source provenance/controller review = 100%

## Controls

No force/reset/rebase shortcuts, no arbitrary remote shell, no secret harvesting, no unverified model output promoted to canonical knowledge, no silent bypass of the mandatory Obsidian operating model/project-state context.

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

## Current bottlenecks

- Small local model can return empty planner/guardian output; controller escalation must never depend on it alone.
- Long multi-agent jobs can exceed runtime timeouts; route bounded business/content tasks to smaller single-model jobs.
- Obsidian knowledge must remain evidence-gated so model errors do not become durable facts.

## Current decision
Use outcome-based routing: local Qwen for bounded reasoning, ChatGPT Controller for current/connected truth and controlled writes, human for consequential external/production decisions.

## Next actions

1. Keep PC runtime healthy and current via safe fast-forward only.
2. Use Obsidian project state as the default first-read context for substantive project tasks.
3. Update canonical knowledge when verified durable state changes.
4. Route long/open-ended agent work into smaller bounded jobs.

## KPIs

- local stale reviewing jobs = 0
- unreviewed local results = 0
- unsafe Git operations = 0
- controller escalations resolved with evidence
- percentage of substantive project work grounded in canonical project state

## Controls

No force/reset/rebase shortcuts, no arbitrary remote shell, no secret harvesting, no unverified model output promoted to canonical knowledge.

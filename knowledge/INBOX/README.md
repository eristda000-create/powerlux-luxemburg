---
type: inbox-policy
status: canonical
owner: chatgpt-controller
updated: 2026-09-11
---

# CENTRAL Inbox

The Inbox is a quarantine zone for unverified or not-yet-promoted knowledge.

Allowed:
- research captures
- Qwen proposals
- copied source excerpts within copyright limits
- hypotheses
- ideas awaiting verification
- temporary meeting/work notes

Required metadata for AI-created notes:

```yaml
status: unverified
created_by: qwen|codex|chatgpt
project: central|powerlux|powertv|merg|cogni|other
evidence_status: OPEN|HYPOTHESIS|QWEN_DRAFT
created: YYYY-MM-DD
```

Rules:
- Nothing in Inbox is canonical truth.
- Local agents may never silently promote Inbox content into `PROJECTS/*/STATE.md`.
- Promotion requires controller review against the owning system.
- Rejected material should be marked `REJECTED` or removed from active retrieval.
- Secrets and credentials are forbidden.

---
type: system-architecture
status: canonical
owner: chatgpt-controller
updated: 2026-09-11
---

# Obsidian AI Stack

## Purpose

Use Obsidian as CENTRAL's durable local knowledge surface while keeping truth, retrieval and write authority controlled.

## Layer 1 — Canonical knowledge

Git-versioned Markdown under `knowledge/` is mounted into the user's Obsidian vault as `CENTRAL/`.

Canonical pages include:

- `[[00_HOME]]`
- `[[OPERATING_MODEL]]`
- `[[AI_INSTRUCTIONS]]`
- `[[OPPORTUNITY_RADAR]]`
- `PROJECTS/<PROJECT>/STATE.md`

Git history is the audit trail.

## Layer 2 — Agent skills

Recommended upstream skill source:

- `kepano/obsidian-skills`

Use it for Obsidian Markdown, Bases, JSON Canvas and Obsidian CLI conventions. Skills teach syntax and tool use; they do not own project truth or overwrite CENTRAL governance.

## Layer 3 — Retrieval / RAG

CENTRAL semantic retrieval is independent of any Obsidian community plugin.

Default scope: `CENTRAL/` only.

Default embedding model target: `nomic-embed-text` through local Ollama.

Retrieval order:

1. fixed governance + project state
2. semantic top matches from canonical CENTRAL notes
3. explicit task context
4. connected authoritative sources when current verification is required

RAG failure falls back safely to fixed context.

## Layer 4 — Obsidian local API / MCP

Preferred integration is the Obsidian Local REST API community plugin. Current versions expose both REST search/file operations and a built-in MCP endpoint. A separate third-party MCP bridge is not required by default.

MCP/REST permissions should be treated as privileged local access. Tokens stay local and never enter Git/Obsidian notes/CENTRAL payloads.

## Layer 5 — Optional human-facing plugins

### Smart Connections

Useful for local-first semantic note discovery inside Obsidian. It is optional and must not become CENTRAL's sole retrieval engine.

### Copilot for Obsidian

Useful as an in-vault agent/chat surface. It may connect to local or external agents/providers, but canonical writes remain governed by `[[AI_INSTRUCTIONS]]`.

## Layer 6 — Prompt patterns

Fabric is used as a pattern library, not as an uncontrolled second operating system. CENTRAL keeps a small curated registry of useful patterns and adapts them to current evidence/decision rules.

See `[[PROMPTS/FABRIC_CURATED]]`.

## Security boundary

- no secrets in notes
- no arbitrary vault-wide AI writes
- default semantic retrieval limited to `CENTRAL/`
- no delete/rename/move operations by local models unless separately human-authorized
- canonical changes require controller review + Git history

## Desired steady state

User question/work item → fixed management context → semantic Obsidian retrieval → local Qwen analysis → controller verification → safe execution → durable knowledge decision → reviewed Git writeback.

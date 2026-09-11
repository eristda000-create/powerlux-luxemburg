---
type: capability-state
project: central
capability: deep-intelligence
status: proposed-for-merge
updated: 2026-09-11
---

# CENTRAL Deep Intelligence

## Value at stake
Make local AI materially stronger on complex work without granting arbitrary shell access or polluting canonical memory.

## Architecture

1. **Canonical memory first** — `CENTRAL/` remains governed, versioned and source-backed.
2. **Context capsule** — every deep task receives project, objective, mandatory sources, retrieved evidence and a reasoning contract.
3. **Hybrid RAG v2** — Markdown is split by headings; retrieval combines lexical relevance, project-path relevance, recency and Ollama embeddings when available.
4. **Model profiles** — `fast`, `standard`, `deep`, `critic` route only to models actually installed in Ollama.
5. **Controller verification** — local outputs remain advisory; current owning systems win over memory.
6. **PowerShell capability layer** — bounded functions expose hardware inventory, model benchmarks and allowlisted lab-vault sync without arbitrary remote shell.

## CENTRAL_LAB policy

`CENTRAL_LAB/` is a non-canonical research zone inside the Obsidian vault. Third-party repositories are cloned only from a fixed allowlist and are treated as **UNTRUSTED_REFERENCE_ONLY**. Their scripts are not executed automatically. Patterns can enter `CENTRAL/` only after controller review and explicit reimplementation/adoption.

Initial allowlist:

- `kepano/obsidian-skills`
- `mithunyc/obsidian-agent-memory`
- `georgeracu/obsidian-agent-vault`
- `kkonstvol-lab/obsidian-memory`
- `Weliviti/obsidian-rag`

## Model policy

Current known local baseline is Qwen 4B primary + Qwen 1.7B support. Larger models are selected only after hardware inventory. No deep model is assumed available until Ollama confirms it is installed.

Observed CENTRAL evidence currently favors bounded `ollama_prompt` microjobs over the heavy `local_agent_team` path for routine work. Deep jobs should use better retrieval, context capsules and a larger model where hardware permits, not simply a longer prompt.

## KPIs

- complex-task controller acceptance rate
- unsupported-claim rate
- timeout rate by model/profile
- retrieval hit usefulness
- context chars per accepted decision
- benchmark score and latency by installed model
- percentage of deep tasks with Context Capsule + Hybrid RAG

## Controls

- no arbitrary remote PowerShell
- no automatic execution of third-party vault code
- no raw vendor note promotion to canonical memory
- no model download outside the allowlist
- no deep-model routing until installation is verified
- canonical project state remains higher priority than semantic retrieval

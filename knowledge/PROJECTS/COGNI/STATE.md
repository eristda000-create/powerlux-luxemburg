---
type: project-state
project: cogni
status: canonical
owner: chatgpt-controller
updated: 2026-09-10
---

# Cogni — Current State

## Value at stake
Develop the existing multi-LLM platform as a reliable orchestration product, using CENTRAL knowledge and governance without duplicating its responsibilities.

## Verified fact base

- Cogni is a separate existing project/repository from PowerLux.
- CENTRAL can hold cross-project context and controller escalation, but Cogni source changes must target the actual Cogni repository.
- Local Qwen must not infer Cogni source state from the PowerLux working directory; connected GitHub/controller verification is required.

## Current bottlenecks

- maintain clean boundaries between Cogni application code and CENTRAL operating infrastructure
- verify current deployment/source state before any code change
- prevent duplicate orchestration features from being created in the wrong repository

## Current decision
Use Obsidian as the durable cross-project fact/decision layer, while actual Cogni source truth stays in its own repository and deployment systems.

## Next actions

- verify Cogni repo/deployment before each consequential change
- log durable decisions here after controller review
- reuse CENTRAL governance rather than recreating controller/queue logic inside Cogni without a product requirement

## KPIs

- verified releases
- failure/recovery rate
- provider fallback reliability
- source/deployment consistency
- zero cross-repo accidental writes

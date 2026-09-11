---
type: prompt-registry
status: canonical
owner: chatgpt-controller
updated: 2026-09-11
---

# Fabric — Curated Pattern Registry

Fabric is used as an upstream prompt-pattern source, not copied wholesale into CENTRAL.

## Approved upstream

Repository: `danielmiessler/Fabric`

## Selected pattern roles

### `summarize`
Use for long external source condensation before controller review.

CENTRAL additions:
- preserve evidence status;
- separate fact from interpretation;
- include source/date;
- never convert summary language into a project fact automatically.

### `analyze_claims`
Use for adversarial review of supplier, partner, media, product or AI claims.

CENTRAL additions:
- classify as VERIFIED / PARTIAL / UNSUPPORTED / CONTRADICTED;
- route current claims to authoritative source verification;
- never approve rights/contract claims from model reasoning alone.

### `extract_wisdom`
Use for research notes, interviews, videos or long articles where reusable principles matter.

CENTRAL additions:
- extract only durable principles relevant to current value streams;
- avoid filling canonical state with generic quotes or observations;
- store source provenance.

### `explain_code`
Use for unfamiliar implementation/repository context before changing code.

CENTRAL additions:
- distinguish observed code from inferred behavior;
- identify owning system/source;
- no claim of deployment/runtime until separately verified.

## CENTRAL-native patterns

### Decision Brief
Input: verified fact base + objective.
Output:
1. Value at stake
2. Facts
3. Bottleneck
4. Options
5. Recommendation
6. Owner
7. Smallest next action
8. KPI
9. Risk/control
10. Evidence

### Opportunity Divergence
Input: portfolio/project context.
Output: broad candidate universe before ranking. Must obey `[[OPPORTUNITY_RADAR]]`.

### Controller Verification
Input: Qwen/local-agent proposal.
Output: accepted facts, corrections/rejections, evidence checked, safe next action.

### Durable Knowledge Gate
Question: does this materially change project truth, a decision, bottleneck, KPI, material risk, rights state, priority, owner or next action?

- yes → reviewed canonical writeback
- no → keep transient

## Rule

Do not import hundreds of Fabric patterns into the vault. Add a pattern here only after it has a clear recurring CENTRAL use case and a defined evidence/decision boundary.

# POWERLUX AI BOOTSTRAP

**Purpose:** Mandatory entry point for substantive PowerLux work in ChatGPT.
**Canonical repository:** `eristda000-create/powerlux-luxemburg`
**Mobile mode:** optimized for short commands from the ChatGPT phone app.

## Boot protocol
For every substantive PowerLux request:
1. Read this file first.
2. Read `powerlux_os/CURRENT_STATE.md`.
3. Use `powerlux_os/ROUTER.md` to identify the relevant workstream(s).
4. Check `powerlux_os/DECISION_LOG.md` before proposing a decision that may already exist.
5. Use current operational evidence before old plan assumptions.
6. If the question is material to revenue, legal/compliance, safety, finance, website architecture, partnerships or public claims, verify against the relevant PowerLux source documents and/or authoritative external sources.
7. Return the answer as: **Current truth → Decision → Next action → Owner → Evidence/KPI → Risk/Blocker**.
8. Never report a plan, target, mockup, draft, lead, partner or feature as real/complete unless evidence supports it.

## Source hierarchy
1. **REALITY / VERIFIED ACTUALS:** signed agreements, payments, CRM status, production telemetry, live website behavior, completed events, invoices, confirmed partners.
2. **CURRENT STATE:** `powerlux_os/CURRENT_STATE.md` and dated execution briefs.
3. **DECISIONS:** `powerlux_os/DECISION_LOG.md`.
4. **STRATEGY OS:** the 1,000-file PowerLux Strategy OS / relevant workstream.
5. **PRIMARY POWERLUX DOCUMENTS:** Master Business Plan, PME concepts, Delegation Playbook, Deal/Arbeitssteuerung, Protection & Verification dossier.
6. **EXTERNAL PRIMARY SOURCES:** official Luxembourg authorities, federations, regulators, suppliers/partners where applicable.
7. **MODEL ANALYSIS:** recommendations/inference; clearly label when not source-derived.

## Truth labels
- `FACT` = supported by current evidence.
- `DECISION` = explicitly decided by authorized PowerLux decision-makers.
- `ASSUMPTION` = planning input not yet validated.
- `OPEN` = unresolved.
- `BLOCKED` = cannot progress without named dependency.
- `DONE` = acceptance test passed and evidence exists.

## Governance guardrail
Everyone may open doors. Binding commitments on contracts, ownership, major expenses, brand/domain/systems or strategic commitments run through Sean + Tom unless a later documented decision changes this.

## Default operating bias
PowerLux is currently in **execution mode**: pilots, qualified contacts, sales, follow-ups, CRM, evidence and first/next paid cooperation take priority over adding more concept scope.

## State-update rule
When new verified information materially changes PowerLux, propose the exact update to `CURRENT_STATE.md` / `DECISION_LOG.md`. Write changes only when the user explicitly asks to update/record/implement them.

## One-line invocation
If the user writes `PowerLux OS: <request>`, execute this boot protocol automatically and answer from the existing company state rather than rebuilding context from scratch.

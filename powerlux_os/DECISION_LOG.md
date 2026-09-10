# POWERLUX DECISION LOG

**Purpose:** Prevent PowerLux from re-deciding the same questions in different chats or documents.

## Decision authority
Current delegation rule: only Sean + Tom may bind PowerLux on contracts, ownership, major expenses, brand/domain/systems or strategic commitments unless a later documented governance decision changes this.

## Active decisions

### D-001 — PowerLux operating principle
**Status:** DECIDED / CURRENT
**Decision:** PowerLux does not replace clubs. It operates as a professional production/coordination layer around sport while partner clubs/structures remain independent.
**Implication:** Commercial growth must preserve sport-technical authority and partner identity.

### D-002 — Execution over further concept expansion
**Date:** 2026-09-06 operating brief
**Status:** DECIDED / CURRENT OPERATING BIAS
**Decision:** The immediate focus is a 30-day execution phase: pilot, partner conversations, content, qualified leads and first/next paid cooperation.
**Implication:** New concepts/features should not displace sales, pilot proof, CRM follow-up or reliability work without explicit reason.

### D-003 — Evidence-first management
**Status:** DECIDED / CURRENT
**Decision:** Targets, planning ranges and concepts must not be reported as actual results. Real payments, signed deals, completed pilots, telemetry and documented outputs supersede old assumptions.

### D-004 — Canonical website release path
**Date:** 2026-09-06 website audit
**Status:** DECIDED / TECHNICAL CONTROL
**Decision:** Public frontend work must be performed on the existing real project/source and follow `existing canonical source → Git → preview → acceptance tests → known rollback → production`. Do not create or reconstruct a replacement website, and do not deepen the current recovery-loader chain.
**Reason:** The objective is to improve the existing PowerLux project, not to recreate it from screenshots, deployed HTML, memory or inferred behavior.
**Implication:** Backend/security/product work may continue on verified existing systems. Frontend changes require the actual existing source/project path; if that source path is not available in the currently connected tool surface, the work remains blocked rather than being reconstructed.
**Evidence:** `powerlux_os/WEBSITE_AUDIT_2026-09-06.md` plus owner correction recorded 2026-09-10.

### D-005 — Existing-project-only rule for PowerLux and PowerTV
**Date:** 2026-09-10
**Status:** DECIDED / CURRENT / NON-NEGOTIABLE
**Decision:** PowerLux and PowerTV are existing projects. AI agents must continue and improve those projects only. They must not create a substitute site, recovery copy, parallel frontend, screenshot-based rebuild or new project presented as the original/current product.
**Implementation consequence:** Draft PR #6 (`canonical-release-2026-09-06`) and draft PR #8 (`feature/powerlux-powertv-integration-v1`) were closed without merge on 2026-09-10 because they represented or depended on a reconstruction/integration path that was not the intended development path.
**PowerLux source rule:** Work in the existing `eristda000-create/powerlux-luxemburg` repository and verified existing PowerLux backend/runtime services. Do not infer missing website source from deployed output.
**PowerTV source rule:** Work on verified existing PowerTV backend/content/editorial objects and the actual PowerTV project when its source/project surface is directly available. Absence of a separate PowerTV repository in the currently connected GitHub installation is not permission to reconstruct one.
**Agent rule:** Ollama/Qwen may analyze and execute only against verified existing project objects/context supplied by CENTRAL. Proposed output remains draft until checked against the owning system.

## Open decision gates

### O-001 — Sport beachhead
**Status:** OPEN
**Question:** Armwrestling-first narrow beachhead or broader multi-pilot entry across several realistic sport opportunity fields?
**Why open:** Different PowerLux plan generations use different emphasis.
**Decision evidence required:** fastest credible paid pilot, strongest warm network, sport-technical capacity, safety/insurance complexity, repeatability, sponsor/customer demand.

### O-002 — Company / ASBL timing and architecture
**Status:** OPEN
**Question:** Exact timing and legal relationship between commercial company and sport/non-profit structure.
**Decision evidence required:** qualified legal/tax/accounting advice, activity list, funding requirements, liability, contracts, governance and cash-flow needs.

### O-003 — Hero Offer #1
**Status:** OPEN
**Candidates:** Community Sport Activation; Partner Workshop & Course; Athlete & Talent Day; Public Event & Challenge.
**Required decision criterion:** shortest path to real buyer + controlled delivery risk + acceptable contribution margin + case-study potential.

### O-004 — Hero Offer #2
**Status:** OPEN
**Decision criterion:** complements Offer #1 without creating excessive operational breadth.

### O-005 — First pilot
**Status:** OPEN until evidence of confirmation is stored.
**Must include:** customer/partner, date, scope, owner, minimum economics, legal/insurance/safety gate, KPI capture and 48-hour review.

### O-006 — Price floor / free-work rule
**Status:** OPEN
**Principle from current material:** free only where the strategic/economic countervalue is strong and explicit.
**Need:** quantified minimum-price logic and approval rule.

### O-007 — Website production architecture
**Status:** OPEN / TECHNICAL
**Verified:** production and backend services exist; current release architecture has reliability/source-control debt and the connected Vercel project is not Git-linked.
**Current rule:** repair and improve the existing project only. Do not use a recovered/reconstructed frontend as the solution.
**Need to close gate:** identify/use the actual existing public frontend source/project path, connect it to reproducible release control, prove core journeys and rollback, and then make changes there.

### O-008 — Brand/IP filing sequence
**Status:** OPEN
**Need:** complete POWERLUX / PLX RADAR / logo clearance and decide owner/applicant before filing.

## How to add a decision
Use:

`PowerLux OS: Entscheidung eintragen — <decision>`

Record:
- ID;
- date;
- decision;
- decision owner;
- evidence/reason;
- financial/operational implication;
- review/expiry condition;
- replaced decision if applicable.

Never delete superseded strategic decisions. Mark them `SUPERSEDED` and link the replacement so history remains auditable.

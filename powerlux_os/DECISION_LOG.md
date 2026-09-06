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
**Decision:** New public frontend changes must move toward `canonical source → Git → preview → acceptance tests → known rollback → production`. Do not solve the current recovery-loader problem by adding another production runtime dependency to an old preview/deployment URL.
**Reason:** The live site currently works through a recovery/loader chain while the connected GitHub repository is not the complete public frontend source and the inspected Vercel project is not Git-linked.
**Implication:** Safe backend/security fixes may be applied independently when validated. Frontend UX/conversion changes should remain in a noindex preview until canonical source and release control are established.
**Evidence:** `powerlux_os/WEBSITE_AUDIT_2026-09-06.md`.

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
**Status:** OPEN / TECHNICAL — REMEDIATION ACTIVE
**Verified 2026-09-06:** production currently uses a recovery/loader chain; canonical public frontend source is not complete in connected GitHub; Vercel project is not Git-linked; `robots.txt` and `sitemap.xml` are absent.
**Already fixed live:** profile age-group self-escalation blocked; public Radar guard hardened.
**Preview ready:** `powerlux-preview-v3` tests conversion, accessibility, safer brand wording and lead intake without changing production.
**Need to close gate:** recover canonical source, Git-link deployment, prove core journeys, establish rollback, promote validated frontend changes, then remove historical runtime dependencies.

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

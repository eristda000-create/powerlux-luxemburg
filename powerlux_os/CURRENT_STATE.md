# POWERLUX CURRENT STATE

**As-of date:** 2026-09-06
**Status:** Execution phase / evidence-building

## Executive truth
`FACT` PowerLux already has substantial concept, planning and product assets: Master Business Plan, PME material, PowerLux Hub/website, PowerMap/Talent Radar/Rankings concepts, Free Armwrestling Playbook and Delegation Playbooks.

`FACT` The 06.09.2026 execution brief identifies the main bottleneck as **execution**, specifically contacts, pilots, sales, follow-ups, CRM discipline and evidence — not lack of ideas or branding.

`FACT` The near-term operating intent is a 30-day sprint aimed at a visible pilot, concrete partner conversations, content, leads and at least one paid or clearly value-equivalent cooperation.

`FACT` PowerLux’s operating model is positioned as a production/coordination layer around sport. Clubs and partners remain independent; PowerLux adds production, marketing, coordination and measurable reporting.

## Existing sellable starting offers
1. **Community Sport Activation** — 2–4h; municipalities, schools, youth structures, local events.
2. **Partner Workshop & Course** — 60–120 min; clubs, gyms, schools, companies. Current execution material describes this as a fast route to a paid workshop.
3. **Athlete & Talent Day** — 2–5h; scouting, trial modules, development pathways.
4. **Public Event & Challenge** — event/festival format with fixed-price, sponsor or hybrid logic depending on project.

## 30-day evidence targets from current playbook
- 3–5 pilots
- 30 qualified contacts
- 10 serious talks
- 2+ written references
- 1+ paid cooperation
- 48-hour review after each event

These are targets, not verified accomplishments.

## Governance / role truth
- **Sean Grethen — Co-CEO / Commercial & Partnerships:** clubs, municipalities, organizers, sponsors, sales, public positioning, retail/brand contacts.
- **Tom Harry — Co-CEO / Operations & Finance:** feasibility, cost, equipment, invoicing, safety, event operations, quality control.
- **Yves Miltgen — Strategy & Partnerships Advisor:** business model, marketing, documents, analysis, negotiation preparation, network logic; advisory, no final commitments.
- **Bogdan Ioan Roman — Sport Technical / Federation Relations:** technique, safety, sport flow, athlete/federation contacts.
- **Nils Davoine — Community & Event Operations / Ambassador:** promotion, recruiting, setup and practical execution.
- **Georg Probst — Consultant / Assistant:** research, coordination, preparation, follow-ups, operations support.
- **Marius Baica — Co-Organizer / Speaker:** stage/hosting, participant flow and on-site public energy.

`DECISION` Binding commitments on contracts, ownership, major expenses and strategic commitments are controlled by Sean + Tom in the current delegation model.

## Digital product truth
`FACT` A PowerLux production platform has been documented as live, with modules including Hub, PLX Radar / talent discovery, rankings, clubs/events and account functionality.

`OPEN` Current production architecture/reliability and conversion performance must be treated separately from feature existence. The 06.09 technical brief notes recovery/loader architecture and preview dependencies; production-source completeness in the GitHub repo was not fully aligned at that snapshot.

### Website audit update — 2026-09-06
`FACT` The current production root at `powerlux-luxembourg.vercel.app` is a recovery/loader layer that fetches the core Hub HTML from a historical Vercel deployment at runtime and injects release assets from another historical deployment.

`FACT` The connected GitHub repository does not currently contain the complete canonical public website source, and the inspected Vercel project is not Git-linked. This means source-of-truth, rollback and reproducible release controls are not yet at the target state.

`FACT` `robots.txt` and `sitemap.xml` currently return 404 on production.

`FACT / P0 DEFECT` Production `/api/sports` currently returns 404. The injected release layer redirects fresh PowerLux Discovery requests to that route and converts failure into an empty synthetic response, so live PowerMap discovery can silently lose fresh place results instead of showing an explicit outage/degraded state. The historical BASE deployment route also returns 404.

`FACT` The public website has extensive functionality, but the current contact form uses a `mailto:` handoff rather than the already-live server-side PowerLux revenue-intake pipeline.

`DONE` Production database hardening now prevents authenticated members from changing their own `profiles.age_group` after account creation. This closes a path by which an under-age account could otherwise attempt to self-escalate into adult-only Radar functionality.

`DONE` `powerlux-public-radar` is now hardened to fail closed when its abuse/rate-limit guard or client network identity is unreliable, rather than serving public Radar output without a dependable protection state.

`DONE / PREVIEW ONLY` `powerlux-preview-v3` v2 is live as a noindex test surface. It tests a smaller/more-readable hero, stronger B2B CTA, safer ranking/PowerMap wording, accessible modal behavior, external-link hardening and server-side lead submission with consent. It additionally bypasses the broken production `/api/sports` proxy on the preview by server-side proxying to the existing Discovery Edge Function, and proxies test lead intake same-origin so preview CORS does not invalidate the test.

`OPEN / P0` Do not promote frontend changes by deepening the existing loader chain. First establish canonical source → Git → preview → tests → rollback → production promotion.

Evidence and release gates: `powerlux_os/WEBSITE_AUDIT_2026-09-06.md`; tracked production discovery defect: GitHub Issue #5.

## Legal / structural truth
`OPEN` Final entity/legal/tax/insurance configuration is not treated as completed by the source material. The strategy documents discuss company + sport structure/ASBL variants, but implementation requires legal/tax/insurance validation.

`OPEN` POWERLUX, PLX RADAR and logo protection/clearance work is documented as in progress / to be completed rather than finished registration proof.

## Strategic contradiction to resolve
`OPEN` Different PowerLux document generations use different emphasis:
- some versions are more **Armwrestling-first / narrow beachhead**;
- later material presents a **broader multi-pilot entry** with several realistic sports opportunity fields and a complementary sport-structure/company model.

Do not silently merge these into one claim. Treat sport-focus and entity timing as explicit decision gates until a later decision is recorded.

## Immediate P0 priorities
1. Freeze the strategic truth set and resolve the sport-focus/entity-timing contradictions.
2. Select Hero Offer #1 and Hero Offer #2.
3. Build/maintain Top-20 target accounts and identify the first 5 warm contacts.
4. Hold serious conversations and record every next step/date in CRM.
5. Select first visible pilot and calculate budget/minimum price.
6. Check risk, insurance, permit, invoicing/TVA and contract requirements before binding delivery.
7. **Canonicalize the public website source/deployment chain and restore fresh PowerMap discovery in production; keep live security fixes in place; validate and then promote the conversion preview.**
8. Instrument conversion and operational evidence.
9. Produce a 48-hour review after each real pilot/event.
10. Convert first proof into a case study/reference and repeatable offer.

## Financial truth rule
Business-plan revenue ranges, budget ranges and break-even examples are **planning assumptions**, not actuals. Actual revenue, cash, margin and pipeline numbers must come from current operational evidence.

## Update protocol
When a real event occurs — payment, signed partner, completed pilot, verified website fix, legal clearance, trademark filing, material KPI change — update this file with:
- date;
- status (`FACT/DONE/OPEN/BLOCKED`);
- evidence location;
- KPI impact;
- next decision.

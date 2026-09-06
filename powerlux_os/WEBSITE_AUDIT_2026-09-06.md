# POWERLUX WEBSITE AUDIT — 2026-09-06

**Routing:** 11 Digital Product → 16 Risk/QA → 12 Conversion → 19 Execution  
**Status:** P0 remediation in progress  
**Rule:** Separate LIVE production changes from PREVIEW-only changes.

## Executive finding
The public PowerLux product is feature-rich, but the biggest technical risk is not missing functionality. It is **production architecture, source-of-truth, conversion integrity and privacy/security hardening**.

The live Vercel production root currently acts as a recovery/loader layer and downloads the real interface from historical Vercel deployment URLs at runtime. The connected GitHub repository does not contain the complete canonical website source and the Vercel project is not Git-linked. This makes rollback, auditability, repeatable deployment and SEO harder than they should be.

## Evidence observed in live systems

### Production architecture — P0
- Production URL: `https://powerlux-luxembourg.vercel.app`
- The production root loads the public Hub from a historical deployment at runtime, and additionally injects release assets from another historical deployment.
- The GitHub repository currently contains PowerLux OS material and a small `web/` integration layer, not the full public website source.
- Vercel project metadata shows no connected Git repository for this project.
- `robots.txt` returns 404.
- `sitemap.xml` returns 404.

**Implication:** the live experience can work while the deployment chain remains structurally fragile. Canonicalising the frontend source is therefore a P0 reliability task.

### Product / UX
The existing Hub already contains Home, PowerMap, News, Events, Results, Rankings, Clubs, Benefits, Talent Radar, Power Notes, Partner, Programs, Management and My PLX.

The product breadth is not the present bottleneck. The next layer of value comes from:
1. faster first-use comprehension;
2. a stronger B2B conversion path;
3. reliable account and location journeys;
4. fewer competing visual layers on mobile;
5. measurable lead capture rather than mail-client handoff.

### Commercial conversion — P0
The current public contact flow prepares a `mailto:` email instead of creating a server-side lead record.

PowerLux already has a live `powerlux-revenue-intake` backend that validates consent/contact data, rate-limits requests and creates a Money Engine work item. The public frontend should use this directly after preview validation.

### Security / privacy — live fixes completed
**DONE 2026-09-06 — Age-group integrity.** A member could previously update their own `profiles.age_group`, while adult-only Radar controls trust that field. Production now has `prevent_profile_age_group_self_change()` plus `trg_lock_profile_age_group_for_members`, blocking client-side age-group escalation after account creation. A database self-test confirmed the protection.

**DONE 2026-09-06 — Public Radar guard hardening.** `powerlux-public-radar` has been upgraded so public Radar requests do not proceed when a reliable abuse/rate-limit identity or guard state is unavailable. The public endpoint remains a coarse-output wrapper around the private database function and does not return raw user coordinates/user IDs.

### Open privacy/product questions
- Under-18 signup exists. Final parental-consent/safeguarding/legal treatment is not proven complete in current evidence. Do not expand youth account functionality until reviewed.
- The Radar implementation contains a location-flow path that can request geolocation before a deliberate user scan. Change this in canonical frontend source so permission is requested only from a clear user action unless permission is already granted.
- Current analytics uses a persistent visitor identifier/cookies. Consent/ePrivacy treatment and analytics-integrity design require review before treating analytics as decision-grade evidence.

### Runtime / technical debt
Vercel runtime monitoring reports recurring Node `url.parse()` deprecation warnings on `/api/playbook`, `/api/auth`, `/api/public` and `/api/check`. This is not currently evidence of a production outage, but the routes should migrate to the WHATWG `URL` API when canonical source is recovered.

## Preview implemented — not production yet
Active preview function:
`https://fgkowgpauqexcwwtrxyd.supabase.co/functions/v1/powerlux-preview-v3`

The preview intentionally keeps the PowerLux visual system while testing targeted improvements:
- smaller and more readable hero scale on desktop/mobile;
- stronger homepage B2B strip for clubs, brands and organisers;
- safer wording: `PowerMap` instead of unverified `PowerMap®`, and `Rankings` instead of ambiguous `Official Rankings` on the homepage;
- modal dialog accessibility / ESC close;
- `noopener noreferrer` hardening for external target-blank links;
- required contact-data consent;
- contact submissions routed to `powerlux-revenue-intake` with a server-side request reference and Money Engine work item;
- mail fallback only when online submission fails;
- preview remains `noindex` and carries security/privacy response headers.

## Why the frontend changes were not promoted directly
A safe production release currently lacks the required chain:

`canonical source → Git commit → preview deployment → automated/explicit acceptance tests → known rollback → production promotion`

Promoting a patch directly into the existing recovery-loader architecture would deepen the source-of-truth problem. This conflicts with the PowerLux OS evidence-first/reliability rule.

## P0 release plan

### Gate 1 — Canonical source
- Recover/import the exact current public Hub source and API routes into the connected GitHub repository.
- Store runtime assets there instead of relying on historical deployment URLs.
- Connect Vercel project to that repository/branch.

**Acceptance:** a fresh preview builds solely from repository source and does not fetch its core HTML from an old deployment.

### Gate 2 — Core journeys
Test on phone and desktop:
1. open Hub;
2. navigation/menu;
3. My PLX signup/login;
4. PowerMap scan after deliberate location action;
5. public Radar privacy behavior;
6. partner/contact lead submission;
7. rankings/events/news external-source links.

**Acceptance:** no P0 failure and all server-side lead/auth events are evidenced.

### Gate 3 — Conversion
- Promote preview-v3 contact flow and B2B CTA into canonical frontend.
- Instrument CTA → form start → valid lead → qualified conversation.

**Acceptance:** a test lead reaches `money_inbound_leads` and creates a Money Engine work item; real conversion is measured separately from tests.

### Gate 4 — SEO/security baseline
- Add `robots.txt` and `sitemap.xml` after canonical production is index-ready.
- Add canonical URL and structured metadata.
- Add/validate CSP, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy` without breaking required assets.
- Remove `url.parse()` usage from owned API code.

### Gate 5 — Cleanup
- Retire historical runtime-loader dependencies only after canonical deployment passes the release gate.
- Keep the old working release as rollback evidence, not as a runtime dependency.

## KPI impact expected
- production reliability / rollback confidence ↑
- signup and lead-journey observability ↑
- B2B lead conversion ↑
- analytics evidence quality ↑
- privacy/security exposure ↓
- SEO crawlability ↑ after index-ready production release

## Do not do
- Do not add more modules before core journeys are reliable.
- Do not call targets or test submissions real commercial traction.
- Do not use `®` where registration/clearance is not evidenced.
- Do not move under-18/public-location functionality forward without explicit privacy/safeguarding review.
- Do not promote directly from an untracked recovery/preview chain.

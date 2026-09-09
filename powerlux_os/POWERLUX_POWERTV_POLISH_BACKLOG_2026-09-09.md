# PowerLux + PowerTV Product Polish Backlog — 2026-09-09

**Status:** prioritized requirements; no PowerTV source replacement

## P0 — clarity + conversion

### PowerLux
1. Homepage must answer in the first screen:
   - What is PowerLux?
   - What can I do here now?
   - Why should an athlete / fan / sponsor care?
2. Primary CTA hierarchy:
   - Discover athletes / sports
   - Upcoming events
   - Partner / sponsor with PowerLux
3. Upcoming event card for 7 Nov only once ownership/date/venue are factually confirmed.
4. Athlete profile pages need a clean shareable summary: photo, sport, achievements, next event, links, verified sponsor/partner info only.
5. Event page requirement:
   - matchup card;
   - athlete links;
   - schedule/status;
   - attend/register CTA;
   - watch/replay CTA only when PowerTV source/rights path is verified.
6. Sponsor lead capture must go to the real revenue-intake path, not a dead-end mailto flow.

### PowerTV
Do not implement until original source is recovered.

Acceptance requirements for recovered source:
1. Top navigation prioritizes **LIVE / UPCOMING / REPLAYS / HIGHLIGHTS**.
2. Homepage leads with current/relevant sport rather than generic catalog density.
3. Every video/event has:
   - sport;
   - event/date;
   - athlete/entity links;
   - duration/status;
   - related content;
   - rights/source metadata internally.
4. `BY POWERLUX` must create a real ecosystem bridge, not decorative branding.
5. Browse should be low-friction; account is for follows/library/personalization where useful, not a needless wall.

## P1 — social/product flywheel

### PowerLux
- one-click athlete/matchup share cards;
- result cards generated from verified outcomes;
- `next match` and `where to watch` fields;
- sponsor inventory attached to real events/content;
- partner proof/case studies using actual analytics only;
- Benelux-local discovery filter.

### PowerTV
- vertical highlight/clip rail;
- `watch full replay` deep link from clips;
- sport-specific hubs;
- athlete story mini-doc rail;
- Benelux event calendar;
- `follow athlete / follow sport` personalization after account sign-in;
- sponsor/ad slots that do not obscure competition footage.

## P2 — differentiation

1. **Hidden Champions layer:** editorially surface athletes/sports that mainstream media undercovers.
2. **PowerLux profile graph:** content → athlete → club → event → sponsor/partner.
3. **Local-to-global pathway:** Luxembourg/Benelux event first, international comparable events/content second.
4. **Opportunity CTA:** athlete looking for sponsor / venue / coach / event or partner looking for activation.
5. **Proof score:** distinguish official result, self-submitted claim, editorial story and partner claim.

## 2026 research-backed execution delta — added 2026-09-10

These are strategy inputs from current external research, not PowerLux performance claims.

### R1 — Build for the core community first, then make it shareable
A July 2026 peer-reviewed niche-sport streaming study found the observed audience was strongly sport-embedded and relationally driven rather than a generic entertainment audience.

**PowerLux implication:**
- first-use experience should immediately connect fans to athletes, clubs, events and familiar sport context;
- do not optimize early PowerTV around anonymous catalog volume alone;
- every event/athlete object should be easy to share outside the platform so the core community becomes distribution.

**Smallest test:** one verified event page + athlete/match share assets; measure external shares → event/profile visits.

**Stop condition:** if share-driven traffic and athlete/community participation remain negligible after two real event/content cycles, do not keep expanding share-card variants.

### R2 — Highlights are a first-class product, not leftover promotion
Current 2026 sports-media evidence consistently points to highlights, clips and on-demand content as major consumption surfaces beyond full live viewing.

**PowerLux/PowerTV implication:**
- design each event as a content tree: event → matchup → decisive moment → result → athlete story → full/replay asset where rights allow;
- clip metadata must preserve the link back to event and athlete identity;
- PowerTV acceptance must treat `HIGHLIGHTS` as a primary navigation/content class.

**Smallest test:** for one event with cleared rights, compare clip → athlete/event clickthrough against generic event promotion.

**Stop condition:** do not scale clip production volume if capture/edit cost exceeds measurable reach, conversion or sponsor value.

### R3 — Direct fan relationship is more valuable than passive reach alone
Current sports strategy research emphasizes direct fan relationships, owned identity and measurable downstream actions rather than relying only on third-party reach.

**PowerLux implication:**
- event attendance/registration, athlete follows/profile visits, sponsor inquiries and opt-in leads are higher-value signals than raw impressions alone;
- social should feed PowerLux/PowerTV identity surfaces instead of becoming the only destination;
- account requirements should be introduced only where they add follow/library/personalization value.

**Smallest test:** tagged CTA from matchup/social asset → event/profile → opt-in/lead; compare conversion by source.

### R4 — Sponsor product must be measurable and non-disruptive
2026 live-sports advertising practice is shifting toward integrated sponsor touchpoints and measurable downstream action rather than only interruption-based ad inventory.

**PowerLux implication:**
- sell defined assets with fulfillment evidence: matchup sponsor, table/backdrop, athlete story, result/highlight asset, partner CTA;
- attach each paid package to a measurement plan before sale;
- do not place sponsor elements over decisive competition action if it harms the viewing product.

**Smallest test:** one sponsor activation with unique CTA/UTM or lead reference plus a post-event deliverable report.

**Stop condition:** do not renew an asset type that cannot be fulfilled reliably or measured at a useful level.

### R5 — Separate live-screen and mobile clip jobs
Live/long-form sports and on-demand highlights have different viewing contexts; product design should not assume one layout/content rhythm serves both equally well.

**PowerTV acceptance implication after source recovery:**
- live/replay surface optimized for stable viewing and event context;
- mobile/vertical clip surface optimized for fast discovery, share and next action;
- both resolve to the same canonical event/athlete graph.

This is an experiment/design requirement, not a claim about current PowerTV device analytics.

## Execution gates for every new feature

No new PowerLux/PowerTV feature enters implementation without all six fields:

1. **User problem** — what concrete friction/value gap it solves.
2. **Evidence** — why this problem is real now.
3. **Smallest test** — lowest-risk way to test value.
4. **Primary KPI** — one metric that can change the decision.
5. **Dependency** — source, rights, backend, data or operational prerequisite.
6. **Stop rule** — what result means we should not scale it.

If these cannot be stated, keep the idea in research rather than the execution backlog.

## Design direction

- modern, clean, performance-first;
- PowerLux: green/white core, restrained accents;
- PowerTV: darker media surface with PowerLux identity carried consistently;
- large imagery/video, minimal card clutter;
- one dominant CTA per section;
- no fake counters, fake `live` states, placeholder athletes or synthetic sponsor logos.

## Mobile requirements

- vertical-first match cards and clips;
- thumb-friendly bottom actions;
- quick share/save/follow;
- no horizontal overflow;
- event essentials visible without opening multiple modals;
- performance budget for mobile networks.

## Measurement requirements

PowerLux:
- event page → attendance/registration conversion;
- athlete profile shares;
- sponsor lead conversion;
- discovery search success;
- return visits.

PowerTV after source recovery:
- video start rate;
- completion/watch time;
- replay-to-related-content clickthrough;
- clip-to-full-event clickthrough;
- logged-out browse → account conversion;
- sponsor deliverables based on actual impressions.

Cross-platform execution metrics:
- social/share asset → PowerLux event/profile clickthrough;
- event/profile → attendance/opt-in/lead conversion;
- clip → full/replay/event clickthrough where rights permit;
- cost/time per published content unit;
- sponsor asset fulfillment rate;
- sponsor CTA/lead outcomes where contractually appropriate.

## Research references for the 2026-09-10 delta

- Fujak, Doyle & Wymer (2026), *Streaming for Whom? Exploring the Audience Composition and Perceptions of Niche Sport Streams*, Communication & Sport / SAGE.
- Nielsen (2026), *The multi-platform evolution of live sports* and *Tops of Sports 2026*.
- BCG (2026), *Beyond Media Rights: A Whole New Ballgame for Sports*.
- Amazon Ads (2026), *Live sports advertising trends in 2026* — used only as current industry practice input, not independent PowerLux evidence.

## Release guard

PowerLux current canonicalization/P0 production defects remain controlling constraints.
PowerTV is `SOURCE UNVERIFIED`; requirements may be refined now, but implementation waits for original-source recovery.

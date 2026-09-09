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

## Release guard

PowerLux current canonicalization/P0 production defects remain controlling constraints.
PowerTV is `SOURCE UNVERIFIED`; requirements may be refined now, but implementation waits for original-source recovery.

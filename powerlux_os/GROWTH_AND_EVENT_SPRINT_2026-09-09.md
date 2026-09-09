# PowerLux + PowerTV Growth & Event Sprint — 2026-09-09

**Status:** execution brief / opportunity pipeline
**Scope:** PowerLux polish, PowerTV product direction, 7 Nov 2026 Supermatch/Vendetta venue, social/media engine, Jacques Schneider opportunity, TitanGPT follow-up.

## Source-of-truth guardrails

- PowerLux canonical repo remains `eristda000-create/powerlux-luxemburg`.
- PowerTV original product exists as `PowerTV — Sport jenseits des Mainstreams`, but canonical source is still `SOURCE UNVERIFIED`; do not recreate or redeploy it from screenshots/descriptions. See `merg_os/POWERTV_SOURCE_RECOVERY.md`.
- This sprint may define product/marketing requirements and prepare implementation work, but PowerTV code changes must wait for original-source recovery.
- External irreversible actions (venue booking, paid spend, sponsor commitment, publishing, contracts) require explicit human approval.

## New user-supplied operating facts — 2026-09-09

- Target event date: **7 November 2026**.
- Working format: about **20 Supermatches** with roughly **60 people total** (athletes + spectators/team/crew).
- Munsbach/Schuttrange is an acceptable fallback area.
- Jacques Schneider has been approached for a collaboration; he reposted PowerLux and appears positive. Treat this as a **warm signal, not a confirmed partnership**.
- TitanGPT has not replied yet. Gmail searches across the two connected operating accounts did not surface a TitanGPT/Titan email thread, so the outreach channel/timestamp is currently **UNVERIFIED** and should not be guessed.

## Verified external context

### 7 November armwrestling anchor
A public `Vendetta 2026` page from Armwrestling Club Strassen currently lists **Saturday 7 November 2026 (to be confirmed)** and describes a full day of pre-built duels between Luxembourg federation members and invited opponents. This is a strong public-content anchor for a Supermatch-format event, but final ownership/venue/status must still be verified before PowerLux makes binding claims.

### Jacques Schneider strategic fit
Current Luxembourg coverage shows Jacques Schneider already sponsoring Luxembourg powerlifter Emma Weydert, including apparel/social representation and financial support for sport expenses. The same article explicitly discusses the visibility/funding problem facing Luxembourg niche sports and names **arm wrestling** among overlooked disciplines. Schneider's wider public collaborations also repeatedly combine Luxembourg identity, local creation and visible partnerships.

**Opportunity thesis:** PowerLux can credibly propose a collaboration around *Luxembourg's hidden / under-recognised athletes* rather than a generic art sponsorship.

Potential concepts to discuss with Jacques Schneider (names are working concepts only; artist approval required):
1. **Hidden Champions Luxembourg × Jacques Schneider × PowerLux** — portrait/story series for niche athletes.
2. **Nos héros du sport** — only if Jacques explicitly approves use/extension of his existing `Nos héros` creative territory.
3. 7 Nov event visual identity / limited poster / athlete cards / photo-wall / table artwork / trophy or award object.
4. Social mini-series pairing an athlete story with a Luxembourg cultural/art angle.
5. Limited ethical/local merchandise capsule where proceeds support athlete costs or a defined sport-development objective.

## Venue sprint — 7 Nov 2026

### #1 — SPORT4LUX / TIMEOUT Sportsbar, Munsbach — highest strategic fit
- 34 Rue Gabriel Lippmann, 5365 Munsbach.
- Official site describes TIMEOUT as a **300 m² sports bar** overlooking the courts, usable for personal or professional events, with food/drink, screens and sport-first atmosphere.
- Strong PowerLux fit: sport identity, spectators, bar economics, video/screens, existing sports infrastructure.
- **Next validation:** private-event terms, exclusive/partial privatization, usable floor area for armwrestling table + crowd, closing time, sound/music, livestream bandwidth, food/drink minimum, price, 7 Nov availability.

### #2 — LÉGÈRE HOTEL Luxembourg, Munsbach — strongest professional fallback
- 11 Rue Gabriel Lippmann, 5365 Munsbach.
- Official event page lists five rooms and private/corporate events.
- Conference Room A supports up to **140 theatre / 100 banquet / 55 cabaret**; other combinations go higher. Foyer is listed for max 60 on the German event page.
- Good parking, hotel rooms, A1/airport access and professional event tech.
- Likely more expensive / less raw-sport atmosphere than TIMEOUT.
- **Next validation:** 60-person sport-event quote, floor protection/table loading, bar/catering package, late hours, filming/livestream, branding rights.

### #3 — Hall des sports 2 / Campus an der Dällt, Munsbach — capacity/value option
- 185 Rue Principale, L-5366 Munsbach.
- Commune lists capacity up to **300 seated** and a reservation form that explicitly includes `Événement sportif` as an event type.
- Municipal rules also say the sports hall is reserved for sports activities; local associations may reserve it for cultural events.
- Available municipal equipment shown on the booking form includes stage elements, folding tables, floor-protection mats, barriers, fridges and even a mobile beer tap.
- **Next validation:** eligibility of PowerLux / federation / local club as applicant, 7 Nov availability, fees, alcohol/catering rules, insurance, setup/cleanup window, livestream/AV.

### #4 — Brasserie O', Niederanven — hospitality-first alternative
- 2A Rue de Munsbach, L-6941 Niederanven.
- Official site says spaces are **modular and privatizable** year-round and explicitly invites event/privatization requests.
- Good if event becomes a dinner/afterwork/brand activation hybrid.
- Capacity for 60 in the required match layout is **not verified**.

### Venue decision criteria
Required before booking:
- approx. 60 total people plus safe athlete/crew circulation;
- clear sightlines for 20 matches;
- competition table + referee zone + warm-up/athlete holding area;
- registration/check-in and small sponsor/media zone;
- livestream camera positions, power and reliable upload bandwidth;
- bar/catering economics and event duration;
- parking/public transport;
- floor loading/protection, safety and insurance;
- branding rights for PowerLux/PowerTV/sponsors;
- total venue + F&B + AV cost vs expected ticket/sponsor/bar economics.

**Current ranking:** TIMEOUT first contact, LÉGÈRE second, Hall des sports 2 third (especially if association eligibility creates a cost advantage), Brasserie O' fourth.

## PowerLux polish — no new feature sprawl

Near-term goal is not another concept layer. Polish should make the existing ecosystem easier to understand, buy and share.

Priority product requirements:
1. **One clear top-level promise:** discover athletes, events and under-recognised sports in Luxembourg/Benelux.
2. **Event conversion path:** event page → matchup cards → tickets/registration → watch on PowerTV → athlete profiles on PowerLux.
3. **Athlete share cards:** one-tap social card with photo, sport, matchup/result, ranking/profile URL.
4. **Sponsor surfaces:** event title sponsor, table sponsor, matchup sponsor, replay/highlight sponsor, athlete/story sponsor.
5. **Proof-first homepage:** real upcoming events, real athletes, real partner logos only after permission, real results/content.
6. **CRM capture:** every venue, sponsor, media and athlete conversation gets owner + next action + due date.
7. **Keep current P0 technical gate:** do not let growth work bury the unresolved production `/api/sports` / canonical source-release issue recorded in `powerlux_os/CURRENT_STATE.md`.

## PowerTV polish direction — source recovery first

Do not rebuild PowerTV yet. Once original source is recovered, prioritize:

1. **Event-first home:** LIVE / UPCOMING / REPLAY / HIGHLIGHTS as the dominant hierarchy.
2. **Sport hubs:** Armwrestling, MMA/combat, strength, emerging/niche sport, Benelux local.
3. **Free-first viewing:** browse/watch as much as rights allow with minimal friction; reserve accounts for library/follows/personalization where useful.
4. **Short-form bridge:** every full event creates matchup clips, results, reactions and vertical highlights linked back to full replay.
5. **Athlete → PowerLux identity:** visible profile card and discovery link under each piece of content.
6. **Sponsor inventory:** pre-roll/bumper, stream overlay, table/match sponsor, replay sponsor, branded athlete story, category partner.
7. **Editorial layer:** explain why the athlete/sport matters; do not become a raw video dump.
8. **Benelux calendar/discovery:** upcoming local niche-sport events with watch/attend CTAs.

Competitive patterns to borrow, not copy:
- Red Bull TV prominently separates live events, upcoming, replays, highlights and sport/category discovery.
- Rakuten TV shows the value of a free/ad-supported layer and uses sign-in for recommendations/benefits rather than blocking every experience.
- DAZN's free tier clearly labels free live events, highlights and non-live content as a top-of-funnel product.

## 7 Nov social/media engine

Treat 20 Supermatches as **20 content units**, not one event.

Pre-event:
- 4 matchup-reveal waves (5 matches each);
- athlete face-off cards;
- `Why this match matters` short clips;
- Luxembourg vs guest / club / story angles where factually correct;
- venue reveal + behind-the-scenes setup;
- sponsor/partner reveals only after confirmation.

Event day:
- entrance/weigh-in/face-off clips;
- winner-result cards immediately after each match;
- 10–20 second vertical decisive-moment clips where rights allow;
- crowd/reaction shots;
- short athlete interviews;
- PowerTV live/replay CTA and PowerLux profile CTA.

Post-event:
- 20 individual matchup replay/highlight assets;
- `Top 5 moments`;
- one 2–5 minute event recap;
- one sponsor-impact recap;
- athlete follower/traffic lift review;
- press/media follow-up with verified results/photos.

## Immediate media/opportunity targets

- **Luxembourg Times / Luxemburger Wort sports:** current coverage is already explicitly interested in under-recognised Luxembourg athletes and mentions arm wrestling as part of the niche-sport visibility problem.
- **RTL Luxembourg:** has recently profiled Luxembourg strength/powerlifting athletes; athlete-first human stories are a plausible earned-media angle.
- **LuxSportHub:** currently offers event promotion starting from €29 and featured sports listings; potentially useful only after checking audience/traffic quality and ROI.
- Local/Benelux gyms, supplement/fitness brands, automotive/mobility, hospitality, event-tech and SME sponsors should be approached through concrete inventory (match/table/media/athlete), not a vague `support us` pitch.

## TitanGPT

Status: **waiting / channel unverified**.

No TitanGPT/Titan thread was found in either connected Gmail operating account on 2026-09-09. Therefore:
- do not claim an email follow-up is due based on a guessed send date;
- locate the original outreach channel (Instagram/LinkedIn/website/other) before follow-up;
- once timestamp is known, follow up after an appropriate business interval with one concrete reason to reply (e.g. 7 Nov event, PowerTV niche-sport media proposition, sponsorship/AI collaboration package), not a generic `just checking in`.

## Next execution order

1. Lock venue shortlist and obtain 7 Nov availability/quotes — TIMEOUT first.
2. Turn Jacques Schneider warm signal into a one-page concrete collaboration proposition around under-recognised Luxembourg athletes.
3. Build 7 Nov event content + sponsorship inventory before selling individual sponsor packages.
4. Prepare PowerLux event conversion surfaces and social-share assets without introducing parallel frontend architecture.
5. Continue PowerTV original-source recovery; meanwhile prepare exact product acceptance requirements in this sprint.
6. Recover TitanGPT outreach channel/timestamp and send a concrete follow-up only when evidence is known.

## Evidence references

Public research on 2026-09-09 included:
- Armwrestling Club Strassen `Vendetta 2026` page;
- Sport4Lux TIMEOUT Sportsbar page;
- Commune de Schuttrange room/hall booking pages;
- LÉGÈRE HOTEL Luxembourg meeting/events pages;
- Brasserie O' official site;
- Luxembourg Times coverage of Emma Weydert / Jacques Schneider / niche-sport visibility;
- Jacques Schneider collaboration coverage (Forbes Luxembourg, Casino 2000, LuxVisual/Bionext examples);
- Red Bull TV, Rakuten TV and DAZN current free/live/replay product patterns.

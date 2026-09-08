# PowerLux + PowerTV — 20 Point Execution Plan

**Date:** 2026-09-08  
**Branch:** `feature/powerlux-powertv-integration-v1`  
**Operating rule:** production-first, evidence-first, no mockups.

## Product thesis
PowerLux is the sports/performance network. PowerTV is the media/watch layer. A user should move from **discover → understand → watch → follow → participate → partner/buy** without feeling that two unrelated products were bolted together.

Competitive patterns worth adapting, not copying:
- Red Bull TV: separate upcoming live, past events, recaps/replays and event series.
- DAZN Free: clearly mark free content and use account identity for retention.
- YouTube TV: Multiview, Key Plays and Stats View as high-value sports utilities.
- FloSports: event + athlete + rankings + replay graph rather than isolated videos.
- Rakuten TV FAST pattern: free access and broad discovery reduce entry friction.

---

## 1. Canonical source audit
**Status:** PARTLY DONE / P0

Verified:
- PowerLux production project exists and is reachable.
- PowerLux current public runtime is still a recovery/loader chain using historical deployments.
- PowerLux Git does not yet contain the complete production web source.
- original PowerTV ChatGPT Sites source remains unverified.
- a functioning PowerTV Vercel candidate exists, but is not automatically canonical/original.

**Acceptance:** both products have one documented canonical Git source and one reproducible production deployment each.

## 2. Shared product architecture
**Status:** DONE

Decision:
- PowerLux = athlete/club/event/performance/community graph.
- PowerTV = watch/media/discovery layer.

Contract: `merg_os/POWERLUX_POWERTV_PRODUCT_CONTRACT.md`.

**Acceptance:** no duplicated account system and no duplicated athlete/club/event truth.

## 3. Shared backend verification
**Status:** DONE

Verified shared Supabase tables:
- `profiles`
- `powertv_content`
- `powertv_watchlist`
- `powertv_reminders`
- `power_map_entities`
- `powerlux_content_queue`

PowerLux and the functioning PowerTV candidate already use the same Supabase project.

**Acceptance:** PowerTV reads content from the shared backend and account-owned records remain RLS-scoped.

## 4. Global PowerLux → PowerTV navigation
**Status:** SOURCE READY / NOT LIVE

Added:
- `web/powertv-integration.js`
- `web/powertv-integration.css`

Surfaces:
- desktop header;
- side navigation;
- home hero;
- mobile navigation.

Links point to the existing PowerTV runtime, not a newly invented replacement.

**Acceptance:** every entry is clickable, tracked and works desktop/mobile after release integration.

## 5. PowerTV → PowerLux navigation
**Status:** PARTLY LIVE

The functioning PowerTV candidate already links `MY PLX` and footer traffic to PowerLux.

**P0:** verify and reproduce this behavior in the canonical PowerTV source after recovery.

**Acceptance:** PowerTV can reach MY PLX, athlete/club/event context and PowerMap without dead links.

## 6. One network identity: MY PLX
**Status:** BACKEND READY / UI PENDING

PowerLux already uses Supabase Auth and `profiles`. PowerTV watchlist/reminder tables already use the same `auth.uid()` model.

Do not build a separate PowerTV login.

**Acceptance:** a signed-in user can use the same PLX account identity on both products; watchlist/reminders persist server-side.

## 7. Replace local-only PowerTV watchlist/reminders
**Status:** P1

Current functioning candidate stores these in localStorage even though real backend tables exist.

Target:
- anonymous user: local device fallback;
- signed-in MY PLX user: Supabase persistence;
- migration/merge from device list after login.

**Acceptance:** signed-in watchlist survives browser/device change.

## 8. Content lifecycle integrity
**Status:** PARTLY DONE

Found and corrected a real stale state: an August powerlifting event was still published as `live` on 2026-09-08. It has been unpublished and marked ended.

Target lifecycle:
`upcoming → live only with verified source → replay/news/past context`.

**Acceptance:** no expired event renders a red LIVE badge.

## 9. Live Desk truth model
**Status:** P0/P1

Three distinct states:
- EVENT NOW — event timing only;
- LIVE VERIFIED — playable official source confirmed;
- WATCH OFFICIAL — external rights-holder/PPV link.

**Acceptance:** no UI state implies PowerTV carries rights it does not have.

## 10. PowerTV taxonomy
**Status:** PARTLY IMPLEMENTED

Canonical taxonomy:
- Live
- Upcoming
- Replays
- Highlights
- News
- Originals
- Athletes
- Clubs
- Sports
- Event Hubs

**Acceptance:** search/filter and home rails use the same semantic model.

## 11. Event Hubs
**Status:** P1

Each important event should combine:
- date/time/local timezone;
- location;
- card/participants when verified;
- official provider;
- watch rights state;
- reminder;
- related PowerLux athletes/clubs/results;
- post-event replay/results when available.

**Acceptance:** one URL remains useful before, during and after an event.

## 12. Athlete media graph
**Status:** P1

PowerLux athlete profile → PowerTV appearances/replays/interviews.
PowerTV media item → PowerLux athlete profile/results/rankings.

Do not store duplicate biographies if a PowerLux entity exists.

**Acceptance:** athlete identity is one shared entity referenced from both products.

## 13. Club media graph
**Status:** P1

Club page gains:
- latest media;
- upcoming events;
- athletes;
- location/PowerMap link;
- training/contact source.

**Acceptance:** club discovery turns into media discovery and vice versa.

## 14. PowerMap ↔ PowerTV
**Status:** BLOCKED BY EMPTY CANONICAL ENTITY TABLE / P1

`power_map_entities` exists but currently has zero rows in the verified shared backend.

Target:
- verified events/clubs/athletes become PowerMap entities;
- PowerTV content references those entity IDs;
- map result can open related media.

**Acceptance:** no fabricated pins; every pin has source and verification evidence.

## 15. Search and discovery
**Status:** PARTLY IMPLEMENTED IN POWERTV CANDIDATE

Current candidate already searches title/sport/description/provider.

Upgrade target:
- sport;
- athlete;
- club;
- event;
- region;
- Live / Upcoming / Replay / Free / PPV;
- MY PLX interests.

**Acceptance:** search results expose rights/access state before click.

## 16. Commerce and sponsor layer
**Status:** P1

Contextual, not spammy:
- event presented-by;
- athlete sponsor slot;
- club partner slot;
- gear affiliate shelf attached to relevant content;
- sponsor CTA on event/athlete hub;
- PPV affiliate only with explicit program/terms.

**Acceptance:** every commercial surface has source/partner status and click tracking.

## 17. Editorial + content operations
**Status:** BACKEND EXISTS / P1

`powerlux_content_queue` already has source URL, rights status, approval status, languages and publish state.

Use it as an editorial intake/review lane feeding PowerLux and PowerTV instead of copy-pasting stories twice.

**Acceptance:** one reviewed content item can publish to the correct channels with source attribution.

## 18. Analytics and funnel
**Status:** PARTLY READY

PowerLux already has `/api/track` and visitor/session attribution.

Required shared events:
- PowerLux → PowerTV open;
- PowerTV → PowerLux open;
- content open;
- watch click;
- PPV click;
- watchlist/reminder;
- athlete/club click;
- sponsor/partner lead.

**Acceptance:** weekly funnel can answer where users enter, what they watch and which actions create business value.

## 19. Performance, security and QA
**Status:** P0/P1

Known findings:
- PowerLux production still depends on historical deployment URLs.
- no GitHub→Vercel deploy workflow currently exists in the PowerLux repo.
- Vercel reported repeated Node `url.parse()` deprecation warnings on `/api/playbook`, `/api/auth`, `/api/public`.
- shared Supabase security advisor reports leaked-password protection disabled and multiple SECURITY DEFINER functions requiring intentional review.

QA gate:
- desktop/mobile;
- keyboard/accessibility;
- 404/broken routes;
- auth;
- RLS;
- stream embeds;
- expired-event lifecycle;
- links/rights;
- Core Web Vitals;
- rollback.

**Acceptance:** zero P0 failures before production promotion.

## 20. Canonical release chain
**Status:** P0

Required chain:
`canonical Git → preview → automated checks → human smoke test → production → rollback candidate`.

Do not deploy a visual replacement of PowerTV simply because the original source is missing.

**Acceptance:** every LIVE claim includes commit, deployment ID, URL and test evidence.

---

# Brainstorming backlog — prioritized

| Idea | Product | Impact | Effort | Gate |
|---|---|---:|---:|---|
| PLX Event Hub: event + watch + card + results | Both | 10 | 5 | verified event sources |
| Shared MY PLX watchlist | PowerTV | 9 | 4 | canonical PowerTV source |
| Watch reminders in MY PLX | PowerTV | 8 | 4 | canonical source + notification channel |
| Athlete Media Timeline | Both | 9 | 5 | athlete IDs/content relations |
| Club Media Page | Both | 8 | 4 | verified club entities |
| Luxembourg/Benelux Sports Radar | Both | 10 | 6 | verified entity ingestion |
| “Free Now” rail | PowerTV | 8 | 2 | verified free playable source |
| “Official PPV” affiliate lane | PowerTV | 8 | 3 | signed affiliate agreement |
| Sponsored Event Hub | Both | 9 | 3 | sponsor inventory contract |
| Athlete Sponsor Match card | PowerLux | 9 | 5 | verified athlete/commercial data |
| Contextual gear shelf | Both | 7 | 3 | real affiliate partner |
| Result → Replay linking | Both | 9 | 4 | event/result/content IDs |
| Replay → Ranking context | Both | 8 | 4 | athlete/result graph |
| Community watchlist trends | PowerTV | 6 | 4 | privacy threshold + usage volume |
| Creator/Athlete submission inbox | Both | 8 | 4 | moderation + rights attestation |
| PowerTV Originals submission slate | PowerTV | 7 | 5 | production/rights workflow |
| Multiview for official free embeds | PowerTV | 7 | 3 | embeddable sources only |
| Key Moments / chapter markers | PowerTV | 8 | 6 | rights + metadata/manual tagging |
| Event calendar export | PowerTV | 6 | 2 | verified start/end times |
| Local “This Weekend” module | Both | 8 | 3 | Benelux event feed |
| Athlete verification badge | PowerLux | 8 | 5 | identity/evidence workflow |
| Club verification badge | PowerLux | 7 | 4 | club verification workflow |
| Sponsor-safe media kit generator | PowerLux | 8 | 4 | athlete profile/results/media graph |
| PowerMap media pins | Both | 9 | 5 | entity locations + content refs |
| Cross-product recommendation engine | Both | 8 | 6 | enough behavioral/content data |

## Highest-return sequence
1. Canonicalize source/release chain.
2. Ship PowerLux ↔ PowerTV global navigation.
3. Move PowerTV watchlist/reminders onto MY PLX backend.
4. Enforce live/upcoming/replay lifecycle.
5. Build shared event IDs/event hubs.
6. Add athlete/club media relationships.
7. Add Benelux discovery and sponsor inventory.

## Things explicitly NOT to build now
- fake premium subscription;
- fake live streams;
- invented sponsor logos;
- fake Originals episodes;
- second PowerTV account system;
- placeholder athlete profiles presented as real;
- reconstructed “original” PowerTV source from screenshots;
- ad inventory without a real tracking/partner path.

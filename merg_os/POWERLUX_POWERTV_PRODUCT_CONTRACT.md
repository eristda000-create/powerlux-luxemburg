# PowerLux ↔ PowerTV Product Contract

**As of:** 2026-09-08  
**Status:** implementation contract  
**Rule:** no mockups, no fake stream state, no invented source ownership.

## Product roles

### PowerLux
The sport network and performance graph:
- athletes and MY PLX profiles;
- clubs and coaches;
- PowerMap / discovery;
- events, results, rankings and talent;
- benefits, management, programs and partner conversion.

### PowerTV
The media and watch layer:
- verified live availability;
- upcoming events;
- free official embeds;
- replays;
- event hubs;
- news/context;
- watchlist and reminders;
- later: PowerLux Originals when an actual production exists.

## Verified shared backend
PowerLux and the functioning PowerTV Vercel candidate already use the same Supabase project and therefore the same account namespace.

Verified tables:
- `profiles`
- `powertv_content`
- `powertv_watchlist`
- `powertv_reminders`
- `power_map_entities`
- `powerlux_content_queue`

RLS is enabled on the account and PowerTV tables. `powertv_watchlist` and `powertv_reminders` are already scoped to `auth.uid()` for authenticated users.

## Identity rule
`MY PLX` is the network identity. Do not create a second fake PowerTV account system.

PowerTV may use the same Supabase Auth identity only after its canonical source is available and the auth flow can be implemented and tested there. Until then, the existing PowerTV candidate's localStorage watchlist/reminders are not to be described as synchronized MY PLX data.

## Content truth contract
Every PowerTV item must contain a real source/rights state:
- `provider_name`
- `provider_url` when a source exists
- `media_source_type`
- `access_model`
- `rights_note`
- `starts_at` / `ends_at` when time-bounded

### State semantics
- `live`: only while a verified playable live source is actually available.
- `upcoming`: confirmed future event; does not imply streaming rights.
- `replay`: an actual replay/watch source exists.
- `news`: source-backed editorial/result item.
- `original`: only actual released PowerLux/PowerTV-owned media is watchable. Development concepts must remain visibly `IN DEVELOPMENT` and must not behave like playable content.

## Cross-product navigation
PowerLux → PowerTV:
- global header entry;
- side navigation entry;
- home hero entry;
- mobile navigation entry;
- later event/profile deep links only after canonical PowerTV routing is verified.

PowerTV → PowerLux:
- `MY PLX` / network identity;
- athlete profile;
- club profile;
- PowerMap location;
- ranking/result context;
- sponsor/partner CTA where relevant.

## Shared entity model target
A media item should eventually be able to reference:
- athlete IDs;
- club IDs;
- event IDs;
- PowerMap entity IDs;
- sport tags;
- location/region;
- sponsor inventory IDs.

Do not duplicate athlete/club/event truth inside two separate products. PowerTV should reference the PowerLux graph.

## Rights / streaming gate
A playable surface is allowed only when one of these is true:
1. PowerTV/PowerLux owns the media rights;
2. the provider supplies an official embeddable player/source;
3. the content is opened on the official rights-holder source.

PPV events stay with the official provider unless an explicit distribution agreement exists.

## Analytics events
Minimum shared funnel:
- `powertv_open`
- `powertv_content_open`
- `powertv_watch_click`
- `powertv_ppv_click`
- `powertv_watchlist_add`
- `powertv_reminder_add`
- `powertv_to_powerlux`
- `powerlux_to_powertv`
- `athlete_profile_open`
- `club_profile_open`
- `sponsor_lead`
- `partner_lead`

## Release rule
No PowerTV replacement may be promoted to canonical because it looks better. Promotion requires:
1. original source recovery or an explicit product decision to supersede it;
2. canonical Git source;
3. preview deployment;
4. functional tests;
5. rights/source tests;
6. rollback path;
7. explicit production promotion.

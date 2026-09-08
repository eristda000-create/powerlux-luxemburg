# PowerTV Content Audit — 2026-09-08

**Scope:** verified shared Supabase `powertv_content` catalog used by the functioning PowerTV Vercel candidate.  
**Rule:** a catalog item is not evidence of PowerTV broadcast rights.

## Live correction applied

### World Classic & Equipped Sub-Junior & Junior Powerlifting 2026
- Found published as `content_type=live` after its event window had already ended.
- Action: `is_published=false`.
- Badge changed to `EVENT ENDED`.
- Result: it can no longer produce a stale public LIVE card.

## Automatic stale-LIVE protection

A production Supabase migration `powertv_expire_stale_live_v1` now provides `public.powertv_expire_stale_live()` and an active pg_cron job:
- job: `powertv-expire-stale-live`
- schedule: `7 * * * *`
- behavior: any still-published `content_type='live'` row with a non-null `ends_at` in the past is unpublished, marked `EVENT ENDED`, and timestamped.
- the function is `SECURITY INVOKER` and its API execution privilege is revoked from `public`, `anon`, and `authenticated`.
- immediate post-migration test returned `0` stale rows, confirming the cleaned feed had no remaining eligible stale LIVE entries.

This does not automatically promote an `upcoming` event to LIVE: broadcast/playability still requires explicit verification.

## Upcoming Luxembourg correction applied

### Western European Classic & Equipped Powerlifting Championships
Official PWFL event page:
- https://pwf.lu/event/western-european-championships/
- 16 September 2026, 09:00 → 20 September 2026, 18:00 local Luxembourg time.
- Hall Omnisports Hamm, Luxembourg.

Database was corrected to the official title and corresponding UTC timestamps.
Rights note explicitly says no stream is claimed until a watch source is confirmed.

## Verified events added

### IFA World Armwrestling Championship 2026
Official IFA source:
- https://armsportfederation.com/event/1360/
- 22–28 September 2026.
- Tsuchiura, Japan.
- Added as `upcoming` / `external` / `OFFICIAL EVENT`.
- No broadcast claim.

### Vendetta 2026 · Luxembourg
Organizer source:
- https://armwrestlingclubstrassen.com/vendetta.html
- organizer lists Saturday, 7 November 2026 **à confirmer**.
- Added with no `starts_at` value and badge `LUXEMBOURG · DATE TBC` so the system does not turn an unconfirmed date into a confirmed schedule entry.
- No broadcast claim.

### National Bench Press Championships Classic & Equipped
Official PWFL source:
- https://pwf.lu/event/national-bench-press-championships-classic-equipped/
- 29 November 2026, 09:00–18:00 local time.
- Hall Omnisports Hamm, Luxembourg.
- Added as upcoming external event.
- No broadcast claim.

## Result after audit
- 14 total catalog records.
- 13 published records.
- 5 published upcoming events.
- 0 published rows currently claiming `content_type=live`.
- 7 published armwrestling records.
- 5 published records with a Luxembourg location string.

## Next catalog gate
Before adding or changing a `live` item, verify all of:
1. event is currently inside the actual event window;
2. an official provider/source exists;
3. playable/live availability is verified separately from event timing;
4. rights wording is correct;
5. `ends_at` is populated so the automated lifecycle can terminate stale LIVE state.

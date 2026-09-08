# PowerTV Content Audit — 2026-09-08

**Scope:** verified shared Supabase `powertv_content` catalog used by the functioning PowerTV Vercel candidate.  
**Rule:** a catalog item is not evidence of PowerTV broadcast rights.

## Live correction applied

### World Classic & Equipped Sub-Junior & Junior Powerlifting 2026
- Found published as `content_type=live` after its event window had already ended.
- Action: `is_published=false`.
- Badge changed to `EVENT ENDED`.
- Result: it can no longer produce a stale public LIVE card.

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
5. end-of-event transition is planned.

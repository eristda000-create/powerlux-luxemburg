---
type: project-state
project: powertv
status: canonical
owner: chatgpt-controller
updated: 2026-09-10
---

# PowerTV — Current State

## Value at stake
Improve the existing PowerTV product as a rights-safe sport discovery, editorial and distribution layer that complements PowerLux, while always continuing the newest verified real PowerTV Site rather than an older or parallel version.

## Verified fact base

- PowerTV already exists; no rebuild, replica, mockup or replacement site is allowed.
- The old public runtime `https://powertv-network.lucienne-ruppert.chatgpt.site` is **STALE / DO NOT USE AS WORK TARGET**. The user verified on 2026-09-10 that it is an older PowerTV version because the Associate Player is missing.
- The exact URL of the newest authentic PowerTV ChatGPT Site is currently **LATEST_NOT_VERIFIED**. Do not infer it from the PowerTV name, a previous chat, a similarly named page, a Vercel deployment, or the stale public URL.
- The current mandatory version fingerprint includes `associate_player=true`. A candidate without an explicitly verified Associate Player cannot be promoted to latest canonical.
- Supabase now stores PowerTV Site candidates in `powertv_site_versions`, the selection policy in `powertv_site_policy`, and exposes `powertv_resolve_latest_site()` as the mandatory resolver for PowerTV frontend/editor work.
- The resolver is fail-closed: if no verified candidate satisfies every required feature, it returns no target. In that state frontend work is BLOCKED rather than falling back to an older version.
- Promotion to `latest_canonical` is controlled by `powertv_promote_latest_site(...)`; it requires an exact `*.chatgpt.site` URL, the complete required feature fingerprint, verification source and timestamp. Public/anon/authenticated roles cannot invoke promotion directly.
- ChatGPT Sites is the real editor surface for the existing product, but a Sites entry must still pass the version resolver/fingerprint before it is used as the current work target.
- The currently connected GitHub installation exposes no separate dedicated canonical PowerTV frontend repository; that is not evidence that PowerTV does not exist.
- The currently connected Vercel team exposes no canonical PowerTV frontend project and must not be used as a substitute.
- Current Supabase catalog contains 14 content rows, 13 published.
- Published content includes 6 replays and 5 upcoming items; the ended World Sub-Junior/Junior Powerlifting row remains unpublished and is explicitly marked `EVENT ENDED`, `lifecycle_status=ended`, `live_verified=false`.
- Existing PowerTV → PowerLux editorial drafts are rights-gated and do not auto-publish.
- East vs West 26 is an upcoming event on 12 Sep 2026; PowerTV does not have verified broadcast rights and must not claim to restream the PPV.

## Current bottlenecks

1. Identify the exact newest authentic PowerTV Site in the authenticated ChatGPT Sites surface and verify that the Associate Player is present.
2. Register/verify that exact candidate and promote it only after all required feature markers pass.
3. Keep rights/source truth explicit for every content item.
4. Continue backend/catalog/editorial improvements that do not require guessing the frontend target.
5. Never revive historical replacement/rebuild paths simply because they contain similar features.

## Current decision
PowerTV frontend work is version-gated. Before every frontend/editor/site action, CENTRAL must call `powertv_resolve_latest_site()`. A returned verified target may be continued; no returned target means `LATEST_NOT_VERIFIED` and frontend work remains BLOCKED. Identity/name alone is not sufficient evidence of freshness.

## Latest-version selection rule

1. Discover candidate only from the authenticated real ChatGPT Sites surface / original creation context.
2. Capture exact Site URL and verification timestamp.
3. Verify required feature fingerprint; currently at minimum `associate_player=true`.
4. Compare against current registry and newest verification timestamp.
5. Promote only through the controlled latest-site promotion path.
6. Demote older canonical versions when a newer verified version is promoted.
7. Never fall back to a stale or feature-incomplete Site.
8. Re-run the resolver before every future PowerTV frontend work session so a later version supersedes an earlier one automatically.

## Next actions

1. Find the exact PowerTV Site/version that visibly contains the Associate Player in the authenticated Sites list/original PowerTV creation chat.
2. Verify its exact URL and feature fingerprint, then register/promote it as `latest_canonical`.
3. Only after resolver success inspect and improve that exact existing Site; preview before publication.
4. Continue source-safe backend/catalog/editorial work independently of the frontend blocker.
5. Expand the required fingerprint when additional unmistakable newest-version features are verified, so freshness is based on functionality rather than a single marker forever.

## KPIs

- zero frontend edits against stale PowerTV versions
- resolver success only for feature-complete verified candidates
- newest verified PowerTV Site used in every frontend work session
- verified content items published without rights corrections
- zero invented live/rights claims

## Risks / controls

- **Wrong-version risk:** fail closed; no resolver result means no frontend work.
- **Name collision risk:** PowerTV identity/name is not freshness evidence.
- **Feature regression risk:** required feature fingerprint must pass before promotion.
- **Parallel-build risk:** no Vercel/GitHub/static substitute may become canonical merely because it contains the Associate Player.
- **Rights risk:** every stream, replay, highlight or rights claim requires explicit authoritative evidence. Local-model suggestions are never sufficient evidence.

---
type: project-state
project: powertv
status: canonical
owner: chatgpt-controller
updated: 2026-09-11
---

# PowerTV — Current State

## Value at stake
Improve the existing PowerTV product as a rights-safe sport discovery, editorial and distribution layer that complements PowerLux, while always continuing the newest verified real PowerTV release rather than an older or parallel version.

## Verified fact base

- PowerTV already exists; no rebuild, replica, mockup or replacement site is allowed.
- The old public runtime `https://powertv-network.lucienne-ruppert.chatgpt.site` is **STALE / DO NOT USE AS WORK TARGET**. The user verified on 2026-09-10 that it is an older PowerTV version because the Associate Player is missing.
- Supabase `public.powertv_resolve_latest_site()` is the mandatory resolver before PowerTV frontend/editor/site work.
- As of 2026-09-11 12:07:10 UTC, the resolver returns **`https://powertv-vercel-release.vercel.app`** as `latest_canonical` with the required fingerprint explicitly passing: `associate_player=true`, `catalog_present=true`, `public_without_login=true`, `source_snapshot_verified=true`, and `rights_safe_backend_known=true`.
- `central_release_registry` records the same target as `powertv_latest` / `latest_verified`, verified by `external_render_verification`, with source reference `github:eristda000-create/powerlux-luxemburg@5dc8008380ce4bf04e0ca42ed117ff0e9485f3c7; vercel:powertv-vercel-release`.
- GitHub commit `5dc8008380ce4bf04e0ca42ed117ff0e9485f3c7` exists in the canonical PowerLux repository and captures the published PowerTV asset graph under `powertv/`, including the Associate Player asset and source manifest.
- Current GitHub `main` is newer than that captured release commit. Release identity must therefore come from the resolver/registry, not from assuming the current repo head is automatically the deployed PowerTV release.
- The resolver remains fail-closed: if a future call returns no verified candidate satisfying every required feature, frontend work becomes BLOCKED again rather than falling back to an older version.
- Promotion/demotion remains controlled by the version registry/promotion path; identity/name alone is never freshness evidence.
- Current Supabase catalog contains 14 content rows, 13 published.
- Published content includes 6 replays and 5 upcoming items; the ended World Sub-Junior/Junior Powerlifting row remains unpublished and is explicitly marked `EVENT ENDED`, `lifecycle_status=ended`, `live_verified=false`.
- Existing PowerTV → PowerLux editorial drafts are rights-gated and do not auto-publish.
- East vs West 26 is an upcoming event on 12 Sep 2026; PowerTV does not have verified broadcast rights and must not claim to restream the PPV.

## Current bottlenecks

1. Keep the resolver/registry as the source of truth for the editable PowerTV release and re-run it before every frontend/editor action.
2. Verify frontend changes against the exact current release target and source snapshot rather than historical URLs or similarly named deployments.
3. Keep rights/source truth explicit for every content item.
4. Continue backend/catalog/editorial improvements without inventing usage metrics, user counts, partners, APIs or implemented features.
5. Resolve CENTRAL local-repo drift safely: the current PC sync is blocked by a dirty working tree and must not be bypassed with reset/rebase/force.

## Current decision
PowerTV frontend work is version-gated, not globally blocked. CENTRAL must call `powertv_resolve_latest_site()` before every frontend/editor/site action. The currently verified target is `https://powertv-vercel-release.vercel.app`; it may be treated as the latest release only while the resolver continues to return it with the required fingerprint. If the resolver returns no row or a newer verified target, the work target changes accordingly.

## Latest-version selection rule

1. Call `powertv_resolve_latest_site()` immediately before frontend/editor work.
2. Accept only the exact returned URL with a complete required feature fingerprint; currently at minimum `associate_player=true` plus the current policy markers.
3. Cross-check `central_release_registry` when release/source provenance matters.
4. Prefer the newest `last_verified_at`; identity/name alone is insufficient.
5. Promote/demote only through the controlled release/version path.
6. Never fall back to the stale ChatGPT Site or any historical Vercel/Netlify/Sites target merely because it looks similar.
7. If no resolver row is returned, status becomes `LATEST_NOT_VERIFIED` and frontend work is blocked.

## Next actions

1. Use the currently resolved `powertv-vercel-release.vercel.app` only for bounded verification/editor work that does not publish or promote production without human approval.
2. Re-run the resolver before every such work session and stop if the target/fingerprint changes or disappears.
3. Continue source-safe backend/catalog/editorial work, especially lifecycle/rights gates and PowerTV → PowerLux draft quality.
4. Review PowerTV opportunity proposals only against real available data; reject invented watch time, shares, engagement, user counts, rewards, discounts, forums or sponsor inventory unless separately verified.
5. Cleanly resolve the local dirty working tree before the next safe repo fast-forward; preserve changes and do not reset/rebase/force.

## KPIs

- zero frontend edits against stale PowerTV versions
- resolver success only for feature-complete verified candidates
- newest verified PowerTV release used in every frontend work session
- verified content items published without rights corrections
- zero invented live/rights/usage/partner claims
- zero destructive Git shortcuts used to clear local sync blockers

## Risks / controls

- **Wrong-version risk:** fail closed; no resolver result means no frontend work.
- **Name collision risk:** PowerTV identity/name is not freshness evidence.
- **Feature regression risk:** required feature fingerprint must pass before promotion/use.
- **Parallel-build risk:** no substitute may become canonical outside the controlled resolver/registry path.
- **Rights risk:** every stream, replay, highlight or rights claim requires explicit authoritative evidence. Local-model suggestions are never sufficient evidence.
- **Analytics hallucination risk:** `powertv_watchlist`/`powertv_reminders` existence does not prove watch duration, shares, engagement, user segmentation, discounts, reward balances or user counts.
- **Git integrity risk:** dirty local state blocks safe fast-forward; preserve work and escalate/clean intentionally rather than rewriting history.

# POWERLUX POWERMAP DISCOVERY CONTRACT

**As-of date:** 2026-09-09
**Status:** `FACT` upstream verified / `OPEN` production route remediation
**P0:** GitHub Issue #5

## Why this file exists
Production currently exposes no working same-origin `/api/sports` route, while the supported Supabase `powerlux-discovery` Edge Function is active and contains the real discovery logic. This document freezes the verified upstream contract so the future canonical web source can wire to it without inventing a second discovery engine or guessing request/response shapes.

## Verified runtime facts

`FACT` Production root `https://powerlux-luxembourg.vercel.app/` returns HTTP 200 but is a recovery/loader shell that fetches historical deployment assets at runtime.

`FACT / P0` `https://powerlux-luxembourg.vercel.app/api/sports?lat=49.6116&lng=6.1319&radius=10` currently returns HTTP 404 / Vercel `NOT_FOUND`.

`FACT` Supabase Edge Function `powerlux-discovery` is `ACTIVE`, version 12.

`FACT` The function is the current real discovery engine. It combines:
- PowerLux verified map entities;
- active map-enabled money partners;
- cached discovery candidates;
- fresh OpenStreetMap Overpass discovery;
- Photon/OSM fallback;
- ranking/diversity selection;
- source-health evidence;
- IP-hash based rate/abuse guarding.

## Verified request contract — `powerlux-discovery` v12

### Methods
- `GET`
- `POST`
- `OPTIONS`

Other methods return HTTP `405` with `{"error":"method_not_allowed"}`.

### Coordinates
Required:
- `lat`
- `lng`

Accepted from:
- GET query parameters; or
- POST JSON body.

Validation:
- latitude must be finite and between `-90` and `90`;
- longitude must be finite and between `-180` and `180`.

Invalid coordinates return HTTP `400`:

```json
{"error":"invalid_coordinates"}
```

### Radius
Field: `radius`

- GET query or POST JSON body;
- defaults to `10` km;
- clamped to `1..25` km.

### Optional sport filter
Accepted field names:
- `sport`
- `selectedSport`

GET uses `sport` query parameter.

The filter affects ranking/selection and matching metadata; it does not justify claiming a place is verified for that sport unless the returned source/evidence says so.

## Verified response contract — successful discovery

HTTP `200`, JSON object containing:

```json
{
  "places": [],
  "sources": {
    "powerlux": 0,
    "verified": 0,
    "cache": 0,
    "osmFresh": 0,
    "osmEndpoint": null,
    "osmError": null,
    "osmAttempts": []
  },
  "selection": {
    "sport": null,
    "eligible": 0,
    "returned": 0,
    "cap": 30,
    "matched": null
  },
  "freeFirst": true,
  "version": "2.4.0-ranked-cap",
  "durationMs": 0,
  "generatedAt": "<ISO timestamp>"
}
```

Each returned place can contain fields including:
- `source`
- `sourceRef`
- `name`
- `category`
- `sports`
- `lat`
- `lng`
- `label`
- `websiteUrl`
- `logoUrl`
- `confidence`
- `associate`
- `verified`
- `entityType`
- `distanceKm`
- optional `selectedSportMatch`

Some verified entities may additionally carry fields such as `instagramUrl`, `description`, or `featured`.

## Verified guard/degraded behavior

### Rate/abuse guard
The function hashes the client IP server-side and checks recent `discovery_scan` security events.

When the guard rejects a request, the function returns HTTP `429` with:

```json
{
  "error": "rate_limited",
  "retryAfterSeconds": 600
}
```

and a `Retry-After: 600` response header.

Do **not** replace this with an invented client-side or API-gateway limit unless a later decision deliberately changes the contract.

### Internal discovery failure
The outer catch path deliberately returns HTTP `200` with an explicit degraded payload:

```json
{
  "places": [],
  "error": "discovery_temporarily_unavailable",
  "freeFirst": true,
  "version": "2.4.0-ranked-cap"
}
```

A canonical frontend must treat this as **degraded/unavailable**, not as a legitimate zero-result search.

### Source-level fallback
The engine can fall back from Overpass endpoints to Photon/OSM and records source attempts/errors. This is different from masking a dead production route with synthetic empty data.

## Proposed canonical web integration

`PROPOSED` Once the exact canonical public web source/API structure is recovered, choose one of these two supported patterns:

### Option A — same-origin route
Implement `/api/sports` in the canonical web source as a thin server-side adapter to the existing `powerlux-discovery` Edge Function.

Requirements:
1. preserve `lat`, `lng`, `radius`, and optional `sport` semantics;
2. preserve upstream HTTP `400` and `429` behavior;
3. preserve the upstream JSON contract rather than translating failures into empty success;
4. return an explicit degraded state when upstream payload contains `error`;
5. do not expose Supabase service-role credentials to the browser;
6. retain source metadata useful for QA/observability;
7. test mobile and desktop PowerMap flows before promotion.

### Option B — supported direct endpoint
The canonical frontend may call the supported discovery endpoint directly only if CORS, security, observability and release architecture are deliberately validated for that design.

`DECISION BIAS` Prefer same-origin server-side integration when the canonical web source is recovered because it keeps the public browser contract stable and allows the backend URL to change without rewriting product UI code. This is a design preference, not a claim that a canonical route currently exists.

## Production acceptance tests

The release is not healthy until all are true:

1. production root loads expected PowerLux identity;
2. `/api/sports` (or the explicitly approved replacement path) returns a valid discovery JSON contract;
3. valid Luxembourg coordinates can return real place/source metadata when upstream sources are available;
4. invalid coordinates return an explicit validation error;
5. rate limiting remains effective;
6. upstream degraded payload is surfaced as degraded, not silently as zero results;
7. PowerMap user flow is tested on phone and desktop;
8. exact source commit, preview, production deployment and rollback path are recorded.

## Automated evidence
Read-only probe:

```text
scripts/powerlux_p0_probe.py
```

Workflow:

```text
.github/workflows/powerlux-p0-discovery-gate.yml
```

The probe checks production root, production `/api/sports`, and the supported Supabase discovery upstream independently.

## Do not do
- Do not create a second discovery engine.
- Do not invent `/discovery/sports`, GraphQL, gateway limits or response schemas that are not present in runtime evidence.
- Do not add a static cached JSON fallback that turns an outage into fake zero results.
- Do not deepen the historical recovery-loader chain to patch the route.
- Do not promote a route until it lives in the recovered canonical source/release path.

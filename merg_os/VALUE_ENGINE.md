# MERG VALUE ENGINE — MONEY OR KNOWLEDGE

**Version:** v1
**Date:** 2026-09-09
**Scope:** Group-level opportunity discovery and execution routing for MERG, PowerLux, PowerTV, Cogni/Diffuse and future registered businesses.

## North star
Every autonomous unit of work must produce one of:
1. **MONEY** — a credible path to revenue, cash, leads, sponsorship, affiliate income, paid partnerships, cost savings or monetizable product value.
2. **KNOWLEDGE** — differentiated, decision-relevant knowledge that materially improves strategy, product, operations, IP/FTO, market position or execution.
3. **BOTH** — knowledge with a defined commercial conversion path.

Work that produces neither is deprioritized.

## Engine loop
`SCAN -> NORMALIZE -> EVIDENCE -> SCORE -> ROUTE -> DRAFT/EXECUTE -> MEASURE -> LEARN`

### 1. Scan
The engine scans configured public discovery feeds and can ingest connected first-party sources such as MERG opportunities, intelligence events, content queues, CRM/commercial state, product telemetry and partner data.

### 2. Normalize
Every candidate is normalized into a value object with:
- project;
- source and source URL;
- timestamp;
- category;
- evidence status;
- money score;
- knowledge score;
- synergy score;
- confidence;
- execution risk;
- priority;
- route;
- next action.

### 3. Evidence
Discovery signals are not treated as verified commercial facts. High-stakes use requires verification against the authoritative original source before public claims, spend, contracts, pricing commitments or production changes.

### 4. Score
Default discovery priority score:
`35% money + 30% knowledge + 15% project synergy + 10% speed-to-value + 10% confidence - risk penalty`

The production MERG opportunity-to-work-item bridge uses existing opportunity fields and a money-weighted score so it remains compatible with the canonical `merg_opportunities` schema. The scoring models are routing heuristics, not accounting truth.

### 5. Route
Candidates are routed into one of:
- `research_intelligence`
- `content_revenue`
- `sales_partnership`
- `funding_sourcing`
- `product_innovation`
- `ip_fto`
- `powertv_editorial`
- `cogni_capability`
- `merg_trading`

### 6. Execution classes
**AUTO_SAFE**
- scan public sources;
- deduplicate and score signals;
- generate research briefs;
- generate fact-bound social/content drafts;
- generate outreach drafts;
- create internal opportunity/work-item queues;
- calculate hypotheses and test plans;
- update analytics summaries.

**REVIEW_REQUIRED**
- publish or schedule social media;
- send new outbound outreach;
- use third-party media, logos or athlete likeness;
- public commercial claims;
- production code changes;
- customer-facing pricing.

**OWNER_REQUIRED**
- spend money;
- sign contracts;
- accept binding commercial terms;
- file legal/IP actions;
- change ownership/governance;
- launch regulated/high-liability activity.

The engine can become more autonomous when a real connected execution adapter exists and the relevant approval policy is explicitly configured. It must never fake a connection.

## Content-to-money loop
A content candidate is valuable only when it has a defined role:
- **Authority** -> audience trust -> inbound lead;
- **Discovery** -> reach -> follower/email capture;
- **Partner value** -> sponsor inventory -> paid placement/activation;
- **Affiliate** -> product intent -> tracked commission;
- **Event conversion** -> registration/ticket/partner inquiry;
- **Product conversion** -> PowerLux/Cogni/PowerTV action.

Every generated content item should therefore contain:
- verified factual hook;
- target audience;
- channel;
- commercial or knowledge objective;
- CTA;
- evidence URL;
- rights status;
- monetization hypothesis;
- KPI to measure.

## Research-to-money loop
Research does not end at a summary. Each research item must answer:
1. What is newly learned?
2. Why does it matter to at least one registered project?
3. What can be built, sold, protected, avoided or tested because of it?
4. What is the fastest low-risk validation?
5. What evidence would invalidate the hypothesis?

For patent/FTO work, the engine may perform prior-art and design-around research but must label legal conclusions as preliminary until qualified counsel validates them.

## Anti-noise rules
- No duplicate opportunity without materially new evidence.
- No invented customers, revenue, demand, partnerships or performance.
- No content based on unverified event results.
- No auto-publishing copyrighted/third-party media without rights.
- No spam outreach.
- No vanity activity counted as revenue.
- No speculative planning number reported as actual cash/revenue.

## Current v1 repository implementation
The repository implementation consists of:
- `merg_os/value_sources.json` — public discovery source configuration;
- `scripts/merg_value_engine.py` — scanner, normalizer, scorer, router and draft generator;
- `tests/test_merg_value_engine.py` — routing and safety regression tests;
- `.github/workflows/merg-value-engine.yml` — scheduled public discovery and actionable GitHub audit queue;
- `supabase/migrations/20260909103600_merg_value_engine_cycle.sql` — canonical backend cycle;
- `supabase/migrations/20260909103800_merg_value_engine_title_limit_fix.sql` — canonical 180-character work-item title fix;
- `supabase/migrations/20260909111500_merg_value_engine_policy_sources.sql` — canonical policy and cross-project source registration.

Workflow artifacts are:
- `value_engine_report.md`;
- `value_engine_report.json`;
- `value_engine_queue.ndjson`.

## Verified production backend — 2026-09-09
The Value Engine is now integrated with the existing MERG control plane rather than a parallel database.

Verified production facts:
- `merg_ai_policy.value_engine` is enabled.
- The engine reads the existing `merg_opportunities` and `merg_intelligence_events` tables.
- It writes deduplicated internal work to the existing `core_engine_work_items` table.
- It logs each run to `core_engine_runs`.
- `pg_cron` job `merg-value-engine-cycle` is active at `8,38 * * * *` and calls `public.merg_value_engine_cycle()` every 30 minutes.
- Seven cross-project watch sources were registered for PowerLux sponsorship/sport, PowerTV rights/media, creator monetization, EU sport funding, Cogni AI/sports research and patent/prior-art research.
- The function has `EXECUTE` revoked from `public`, `anon` and `authenticated`.
- The function never performs external execution; it only creates internal work items.

Live verification:
- first verified run: `24` MONEY work items and `5` KNOWLEDGE work items created;
- immediate second run: `0` MONEY and `0` KNOWLEDGE created, proving idempotent deduplication against the same inputs;
- current stored Value Engine work items: `24` MONEY + `5` KNOWLEDGE.

The existing broader MERG/PowerLux database still has project-wide Supabase advisor findings that predate this change. They remain a separate hardening backlog and are not evidence that the Value Engine introduced a new RLS or SECURITY DEFINER exposure.

## Existing connected execution surfaces
Already verified in the same backend environment:
- `powerlux-content-engine` — ACTIVE and able to create rights-gated content packs/work items;
- `merg-jarvis` and `merg-jarvis-chat` — ACTIVE control surfaces;
- MERG revenue, market, supplier and demand functions;
- `merg_revenue_routes` for direct checkout, brokerage, affiliate/referral and sponsorship/media readiness;
- existing MERG 30-minute autonomy, market matching and opportunity freshness jobs.

The Value Engine is therefore the prioritization and value-routing layer above those existing capabilities, not a replacement for them.

## Next adapters
Priority order from this point:
1. connect a real social scheduler/publisher + analytics account so approved content can move from draft to measured distribution;
2. feed Value Engine outputs into `powerlux-content-engine` for sponsor/content opportunities where evidence and rights gates are met;
3. enrich CRM/email commercial actions with Value Engine priority and monetization hypotheses while preserving existing send-approval policy;
4. attach verified affiliate/deal tracking and revenue attribution;
5. route suitable media opportunities to the canonical PowerTV editorial pipeline once the original PowerTV source is recovered;
6. bridge qualified research items into Cogni solver synthesis after the current Cogni source/runtime drift is reconciled;
7. close the loop with actual payments, conversions, margin and ROI so scoring learns from real outcomes.

Each adapter must prove the real account/system connection before the engine can mark external execution as completed.

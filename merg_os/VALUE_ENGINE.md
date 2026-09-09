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
The engine scans configured public discovery feeds and can later ingest connected first-party sources such as analytics, CRM, email, content queues, product telemetry and partner data.

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
Default priority score:
`35% money + 30% knowledge + 15% project synergy + 10% speed-to-value + 10% confidence - risk penalty`

The scoring model is a routing heuristic, not accounting truth.

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
- create internal opportunity queues;
- calculate hypotheses and test plans;
- update analytics summaries.

**REVIEW_REQUIRED**
- publish or schedule social media;
- send outbound outreach;
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

## Current v1 implementation
The repository implementation consists of:
- `merg_os/value_sources.json` — discovery source configuration;
- `scripts/merg_value_engine.py` — scanner, normalizer, scorer, router and draft generator;
- `.github/workflows/merg-value-engine.yml` — scheduled execution and actionable GitHub queue;
- workflow artifacts: `value_engine_report.md`, `value_engine_report.json`, `value_engine_queue.ndjson`.

The first version deliberately uses public discovery feeds and GitHub-native queueing because those are verifiable and do not require pretending that an Instagram/CRM/payment publisher is connected.

## Next adapters
The engine is designed to add real adapters, in this order:
1. social scheduler/publisher + analytics;
2. PowerLux content queue / Supabase work items;
3. CRM/email lead execution;
4. affiliate/deal tracking;
5. PowerTV editorial queue;
6. Cogni research/solver synthesis;
7. financial actuals and ROI feedback.

Each adapter must prove the real account/system connection before the engine can mark external execution as completed.

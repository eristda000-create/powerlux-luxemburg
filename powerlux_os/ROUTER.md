# POWERLUX ROUTER

Use this file after `POWERLUX_BOOTSTRAP.md` + `CURRENT_STATE.md`.

## Routing table

| User intent / keyword | Primary domain | Secondary domains | Default first check |
|---|---|---|---|
| heute, nächste Schritte, Priorität, Update | 00 Command Center / 19 Execution | 17 KPI | CURRENT_STATE + DECISION_LOG |
| Strategie, Richtung, Fokus, Moat | 01 Strategy | 02 Market, 17 KPI | strategic contradiction + evidence gate |
| Markt, Konkurrenz, Zielgruppe, Nachfrage | 02 Market | 04 PESTEL, 07 GTM | buyer + willingness-to-pay evidence |
| SWOT | 03 SWOT | 01 Strategy, 16 Risk | materiality + action consequence |
| PESTEL, Umfeld, Regulierung | 04 PESTEL | 13 Legal, 16 Risk | current external source/date |
| Geld verdienen, Revenue, Geschäftsmodell | 05 Business Model | 06 Offers, 07 GTM, 14 Finance | payer + margin + repeatability |
| Preise, Angebot, Kalkulation | 06 Offers & Unit Economics | 14 Finance, 07 GTM | scope + price floor + contribution margin |
| Leads, Sales, Outreach, CRM, Follow-up | 07 GTM/Sales | 06 Offers, 08 Partners | next action/date + economic buyer |
| Sponsoren, Partner, Retail, Händler | 08 Partnerships | 07 GTM, 13 Legal, 14 Finance | give/get economics + rights |
| Athleten, Clubs, Federation, Talent | 09 Sport | 10 Events, 13 Legal | sport authority + club autonomy |
| Event, Stand, Workshop vor Ort, Sicherheit | 10 Event Ops | 13 Legal, 16 Risk, 14 Finance | permit/insurance/safety/P&L gate |
| Website, Login, Map, Supabase, AI, Daten | 11 Digital Product | 12 Brand, 13 Legal, 16 Risk | production truth + critical user journey |
| Instagram, Content, Marke, SEO, PR | 12 Brand/Content | 07 GTM, 11 Digital | proof-backed claim + CTA |
| Vertrag, ASBL, SARL, TVA, GDPR, Marke | 13 Legal | 14 Finance, 16 Risk | official/professional validation |
| Cash, Budget, P&L, Break-even, Funding | 14 Finance | 05 Model, 06 Offers | actuals vs planning assumptions |
| Team, Rollen, Sean/Tom/Yves, Governance | 15 Organisation | 00 Command, 13 Legal | authority + reserved matters |
| Risiko, Qualität, Incident | 16 Risk | 10 Event, 13 Legal | owner + control + evidence |
| Milestones, KPI, OKR, Ziele | 17 Milestones/KPI | 00 Command, 19 Execution | baseline + threshold + consequence |
| Deutschland/Belgien/Frankreich, Scale | 18 Scale | 01 Strategy, 13 Legal, 14 Finance | Luxembourg repeatability first |
| mach jetzt, umsetzen, Backlog | 19 Execution | relevant domain | smallest irreversible next step |

## Strategy-OS domain map
The canonical 1,000-file Strategy OS is structured as:
- `00` COMMAND CENTER
- `01` STRATEGY & NORTH STAR
- `02` MARKET, CUSTOMER & COMPETITION
- `03` SWOT
- `04` PESTEL
- `05` BUSINESS MODEL & REVENUE
- `06` OFFERS, PRICING & UNIT ECONOMICS
- `07` GTM, SALES & CRM
- `08` PARTNERSHIPS, SPONSORS & RETAIL
- `09` SPORT, ATHLETE & COMMUNITY
- `10` EVENT OPERATIONS & SAFETY
- `11` DIGITAL PRODUCT, DATA & AI
- `12` BRAND, CONTENT, MEDIA & SEO
- `13` LEGAL, COMPLIANCE & IP
- `14` FINANCE, FUNDING & CONTROL
- `15` ORGANISATION, GOVERNANCE & TALENT
- `16` RISK, PROCESS & QUALITY
- `17` MILESTONES, OKRS & KPIS
- `18` SCALE, INTERNATIONAL & OPTIONALITY
- `19` EXECUTION BACKLOG

## Multi-domain rule
Most important questions require 2–4 domains, not one. Examples:

**“Wie verdienen wir diese Woche Geld?”**
`07 Sales → 06 Offer → 14 Finance → 19 Execution`

**“Wir wollen Supplements verkaufen.”**
`08 Retail → 06 Unit Economics → 13 Legal/Product Compliance → 14 Cash → 19 Execution`

**“Website funktioniert nicht richtig.”**
`11 Digital → 16 Risk/QA → 12 Conversion → 19 Execution`

**“Wir haben einen Sponsor.”**
`08 Partnership → 13 Contract/IP → 14 Economics → 17 KPI → CURRENT_STATE update`

**“Wir wollen einen Event machen.”**
`10 Event Ops → 13 Permit/Insurance → 14 P&L → 09 Sport Technical → 16 Risk`

## Retrieval depth
- **Level A — Fast:** Bootstrap + Current State + one domain.
- **Level B — Decision:** add Decision Log + 2–4 relevant Strategy OS work packages.
- **Level C — High stakes:** add original PowerLux documents + authoritative external verification + explicit assumptions/risks.

Default to Level B for substantive PowerLux business decisions.

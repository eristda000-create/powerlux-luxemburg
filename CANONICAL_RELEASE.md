# PowerLux canonical release

This branch contains the recovered PowerLux hub as a reproducible Git source.

## Runtime contract

- index.html is the canonical entry.
- powerlux-runtime.js initializes the public Supabase client.
- plx-radar-v3.js calls the real powerlux-discovery Edge Function directly; it does not use the broken Vercel /api/sports proxy.
- The contact form sends to powerlux-revenue-intake, which creates a row in money_inbound_leads and a Money Engine work item. A request ID is shown only after the backend confirms storage.
- The form has explicit consent and does not silently fall back to mailto.

## Revenue and content automation

- powerlux-content-engine creates an event content pack, shot list, captions, rights/media gates and a Money Engine opportunity.
- Jarvis exposes the queue through content queries and the money/systems views.
- Automatic publishing is intentionally not enabled. A social publishing connector, rights-cleared media and owner approval are required before a post can leave the queue.
- Prices in opportunity drafts are planning ranges from the business plan, not customer-facing quotes.

## Release gates

1. Deploy this branch to a Vercel preview.
2. Test Home -> PowerMap scan and verify a non-empty or explicit degraded response.
3. Submit a consented test lead and verify money_inbound_leads plus core_engine_work_items.
4. Verify SEO/security headers and robots.txt/sitemap.xml.
5. Only then promote to powerlux-luxembourg.vercel.app and remove the recovery loader.
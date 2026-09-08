# PowerTV — Source Recovery Ledger

**As of:** 2026-09-08
**Status:** `SOURCE UNVERIFIED`
**Priority:** P0

## Goal
Recover the ORIGINAL PowerTV project/source that currently publishes through ChatGPT Sites. Do not recreate, approximate, scrape-and-rebuild, or substitute it.

## Canonical runtime currently verified
- Public product URL: `https://powertv-network.lucienne-ruppert.chatgpt.site`
- Product identity recorded by MERG state: `PowerTV — Sport jenseits des Mainstreams`
- Known original asset used by the runtime checker: `https://powertv-network.lucienne-ruppert.chatgpt.site/powertv-logo.jpg`

## What has been ruled out
### GitHub
No dedicated PowerTV repository is currently present in the connected GitHub installation. The connected repositories relevant to this investigation are:
- `eristda000-create/powerlux-luxemburg`
- `eristda000-create/cogni`

The only PowerTV implementation found in PowerLux Git history was the rejected static replacement added by commit `7c24e0cf5d29cf25f7a37ec710287d6766f2dcaf` under `powertv/index.html` with markers such as `PowerTV — Internal Release` and `Strength has a screen.` It was removed by commit `6b64855d0cc830d68fea64fe05638fe76810ed64`.

**Decision:** that historical file is evidence of the wrong replacement, not recoverable original PowerTV source.

### Vercel
Authenticated Vercel management access confirms the connected team and the real `powerlux-luxembourg` project. Direct lookups for the previously used candidate PowerTV project slugs returned 404 / not found:
- `powertv-public`
- `powertv-internal`
- `powertv-network`

A direct lookup for `cogni-release` in the same Vercel team also returned 404, so a public `*.vercel.app` hostname must not be assumed to belong to the currently connected Vercel team without management evidence.

**Decision:** no PowerTV Vercel project is canonical or currently recoverable from the connected Vercel team.

### File Library / exports
Targeted File Library searches for `PowerTV`, `MY PLX`, `Sport jenseits des Mainstreams`, `powertv-logo.jpg`, the ChatGPT Sites hostname, and source/export terms did not return a PowerTV source package or export.

**Decision:** no source export has been verified from the available File Library index.

## Current source-of-truth rule
Until an original ChatGPT Sites project/export is obtained, PowerTV remains `SOURCE UNVERIFIED`.

Do not:
- create `powertv/index.html` as a replacement;
- promote any Vercel PowerTV-named deployment as canonical;
- infer source code from screenshots or rendered HTML and call it original;
- treat copied text/assets as a source migration.

## What counts as successful recovery
PowerTV may change from `SOURCE UNVERIFIED` to `SOURCE VERIFIED` only when all of the following are available:
1. original ChatGPT Sites project/export or platform-provided source package;
2. evidence tying that source to the live `powertv-network.lucienne-ruppert.chatgpt.site` product;
3. source imported into a dedicated canonical Git repository;
4. original runtime behavior and identity reproduced from that source without redesign/substitution;
5. commit + deployment + rollback path recorded;
6. MERG `CURRENT_STATE` and `PROJECT_REGISTRY` updated in the same change.

## Next exact recovery path
The remaining missing boundary is the ChatGPT Sites project itself. Recovery must happen through the original ChatGPT Sites project/export/share/source mechanism or an original source package supplied from that project. All GitHub/Vercel/File-Library candidate paths checked on 2026-09-08 have been exhausted without finding the original source.

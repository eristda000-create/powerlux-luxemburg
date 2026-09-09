# CENTRAL Verified Context Broker

**Status:** ACTIVE cloud contract / LOCAL NATIVE PENDING NEXT PC PULL
**Purpose:** give local Ollama/Qwen agents the current verified project state without giving them unrestricted access to GitHub, Supabase, Gmail, browser sessions, credentials, or the whole PC.

## Core flow

`ChatGPT/connectors -> verified context packet -> CENTRAL work item -> Windows bridge -> Ollama/Qwen -> CENTRAL result -> ChatGPT control review -> user`

## Evidence labels

Every packet fact MUST have one label:

- `FACT` — current canonical project source such as GitHub state/decision documents.
- `CONNECTOR_FACT` — current evidence read from a connected authoritative system such as Supabase or Gmail.
- `USER_FACT` — operating context explicitly supplied by the user; usable as user-provided truth but not independent external verification.
- `OPEN` — unresolved or blocked state. Never promote to completion.
- `QWEN_DRAFT` — model output only. Advisory and untrusted until control review.
- `REJECTED` — known incorrect/unsafe output that must not be reused as fact.

## Packet minimum schema

```json
{
  "packet_version": "v1",
  "packet_status": "VERIFIED_WITH_OPEN_ITEMS",
  "scope": ["PowerLux", "PowerTV"],
  "rules": [],
  "facts": [
    {"label":"FACT","source":"...","as_of":"...","text":"..."}
  ],
  "current_objectives": [],
  "local_execution": {
    "node": "DESKTOP-FP4OP26-User",
    "safe_mode": true,
    "arbitrary_shell": false,
    "external_actions": false
  }
}
```

## Source precedence

1. Fresh verified runtime/production evidence for the exact question.
2. Canonical GitHub CURRENT_STATE / decision / recovery ledgers.
3. Current connector evidence (Supabase, Gmail, etc.).
4. Explicit current user facts.
5. Research evidence with source/date.
6. Qwen/LLM drafts — never authority.

When two sources conflict, keep both with labels and surface the conflict. Do not silently merge them.

## PowerLux / PowerTV rules

- PowerLux canonical repository: `eristda000-create/powerlux-luxemburg`.
- PowerLux production `/api/sports` and canonical release-chain issues remain P0 until verified fixed.
- PowerTV live product exists, but original canonical source remains `SOURCE UNVERIFIED` until recovery criteria in `merg_os/POWERTV_SOURCE_RECOVERY.md` are met.
- Never rebuild or substitute PowerTV from screenshots/descriptions and call it original.
- Event, athlete, sponsor, live, replay, result and partnership claims require evidence appropriate to the claim.

## Security boundary

The broker does NOT grant Qwen:

- Supabase service-role credentials;
- Gmail credentials;
- ChatGPT/Codex/OpenAI auth tokens;
- browser cookies or sessions;
- arbitrary PowerShell/shell execution;
- unrestricted filesystem traversal;
- automatic deploy/publish/send/book/pay/contract actions.

The broker may pass bounded text facts and identifiers after ChatGPT/control-plane verification.

## Result handling

Every local result must return with:

- packet version/id used;
- local node/model;
- output;
- whether the action changed anything (normally `false` for analysis);
- timestamp.

ChatGPT then reviews the result and records:

- `accepted` findings;
- `rejected_or_unverified` findings;
- `next_action`;
- optional refreshed packet facts.

## Current implementation

Cloud-side packet v1 is stored in CENTRAL as a completed `context_packet` work item and can already be embedded in current `ollama_prompt` jobs, so the existing PC runtime can use brokered context without a local software update.

Native local packet validation/rendering is implemented in `scripts/central_context_packet.ps1` and becomes available on the PC after the next repository pull. Until then, cloud-side rendering remains canonical.

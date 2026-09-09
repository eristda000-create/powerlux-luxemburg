# CENTRAL WORKSHOP BRIDGE

**As of:** 2026-09-09
**Control-plane repository:** `eristda000-create/powerlux-luxemburg`
**Backend system of record:** MERG Supabase project `fgkowgpauqexcwwtrxyd`

## What “CENTRAL Workshop” means

This name is the control-plane identity for the cross-device/local-AI workshop described by the user in the parallel ChatGPT work:

- ChatGPT is the orchestration/command layer;
- the PC is the local execution surface;
- the phone is a command/review/approval surface;
- PowerShell is a local automation surface;
- Ollama/Llama is a local fallback/control model;
- Obsidian is intended as local memory/context storage;
- work should be transferable between ChatGPT sessions without losing canonical project state.

These are **user-declared requirements/context**, not proof that every local component is currently running.

No separate canonical Git repository specifically named `Werkstatt` / `CENTRAL Workshop` has been verified. Do not invent one. The bridge contract and group-level state therefore live in the existing MERG AI OS control-plane repository until an original dedicated runtime source is identified and explicitly promoted.

## Verified now

The production MERG backend contains:

- group unit `central_workshop` / `CENTRAL Workshop`;
- bridge channel `central_workshop_local_bridge`;
- bridge contract version `1`;
- active Edge Function `central-workshop-bridge` as the authenticated client gateway;
- server RPCs:
  - `merg_workshop_heartbeat`;
  - `merg_workshop_self_test`;
  - `merg_workshop_claim_next`;
  - `merg_workshop_complete`;
  - `merg_workshop_watchdog_cycle`;
- a bootstrap work item `workshop_bridge_bootstrap` routed to `execution_surface=central_workshop`;
- watchdog cron `merg-workshop-watchdog` every 5 minutes.

The bridge channel is deliberately registered with `address=UNVERIFIED_LOCAL_ENDPOINT` until the real PC runtime checks in. This string is a sentinel, not a URL or endpoint.

## Runtime verification rule

CENTRAL must not claim that the workshop is connected merely because the database schema or Edge Function exists.

A local node becomes eligible to claim work only after:

1. an authenticated owner logs in through Supabase Auth;
2. the Edge gateway verifies the account against the existing enabled `owner` ACL in `core_admin_users`;
3. the PC sends a heartbeat through the Edge gateway;
4. the same node passes self-test;
5. PowerShell reports `ok`;
6. Ollama reports `ok`;
7. the latest heartbeat is less than 3 minutes old.

Obsidian is recorded separately and is not required for the first bridge handshake because the vault path may not yet be configured on every PC.

If heartbeat becomes stale, the watchdog changes the bridge to `degraded`. No local job may be claimed again until the connection is fresh and verified.

## Authentication and privilege boundary

The PC runner must **not** store a Supabase service-role or secret key.

The PC uses:

- the public/publishable Supabase key;
- a normal Supabase Auth user session;
- an email already enabled as `role=owner` in the canonical `core_admin_users` ACL.

Client traffic goes only to:

`/functions/v1/central-workshop-bridge`

The Edge Function authenticates the user, verifies the owner ACL server-side, then uses its server-side admin client to call the narrow internal RPCs. The four work RPCs themselves are `SECURITY INVOKER` and executable only by `service_role`; `public`, `anon` and `authenticated` direct RPC execution is revoked.

This keeps privileged backend credentials off the PC while avoiding broad table access for the authenticated user.

## PC runner

Canonical bridge runner:

`scripts/central_workshop_bridge.ps1`

One-command bootstrap:

`scripts/start-central-workshop.ps1`

The bootstrap contains only the verified Supabase project URL and public publishable key, automatically uses the checked-out repository as `CENTRAL_WORKDIR`, checks whether local Ollama answers, starts `ollama serve` when the executable exists but the service is not responding, and then launches the canonical runner. It contains no user password, service-role key or other backend secret.

Preferred start from the repository root:

```powershell
pwsh -File .\scripts\start-central-workshop.ps1
```

One-shot handshake/test:

```powershell
pwsh -File .\scripts\start-central-workshop.ps1 -Once
```

The runner then asks for the owner email/password unless those are supplied locally through `CENTRAL_SUPABASE_EMAIL` / `CENTRAL_SUPABASE_PASSWORD`.

Optional/local configuration:

- `CENTRAL_WORKSHOP_NODE_ID`
- `OLLAMA_URL` (defaults to `http://127.0.0.1:11434`)
- `CENTRAL_OLLAMA_MODEL` (optional; if omitted, the runner uses only a model actually reported by the local Ollama `/api/tags` endpoint)
- `OBSIDIAN_VAULT`
- `CENTRAL_WORKDIR`

The runner does not assume that `llama3.2` or any other named model is installed. If no configured or detected model exists, an `ollama_prompt` task fails explicitly instead of inventing a model.

The PC-side run itself is **not verified by this repository commit**. It becomes verified only when the production bridge metadata receives a real authenticated heartbeat and successful self-test from that machine.

## v1 execution policy

The bridge claims only work items that are all of:

- `status=approved`;
- `execution_surface=central_workshop`;
- `execution_class=AUTO_SAFE`;
- `requires_human=false`.

Supported local actions in v1:

- `bridge_self_test`;
- `ollama_prompt`;
- `git_status`;
- `git_diff`.

Unsupported actions are returned to `ready_for_decision` with `verified=false`.

### Why arbitrary PowerShell is not enabled yet

A remotely supplied unrestricted PowerShell command would effectively turn CENTRAL into a remote shell. That is too broad for the first authenticated bridge. Add command signing, narrow capability scopes and explicit approval rules before enabling write/destructive shell actions.

## Link to MONEY / KNOWLEDGE engine

The workshop is an **execution surface**, not a competing intelligence database.

The Value Engine remains responsible for determining MONEY / KNOWLEDGE / BOTH and placing canonical work in `core_engine_work_items`. The Workshop bridge only claims explicitly routed, approved `AUTO_SAFE` items and writes results back to the same work item.

This prevents the PC, phone and a second ChatGPT chat from creating parallel task truth.

## Phone / PC / other-chat handoff

Every ChatGPT session working on the workshop must first read:

1. `merg_os/CURRENT_STATE.md`
2. `merg_os/PROJECT_REGISTRY.md`
3. `merg_os/DEVICE_WORKFLOW.md`
4. `merg_os/TOOL_ROUTER.md`
5. this file

A parallel chat must **not** rebuild the bridge from memory. It should continue the current branch/runtime state and use the canonical handoff packet in `DEVICE_WORKFLOW.md`.

## Work-mode limit handoff

The user also wants a Work session that reaches its product limit to hand work to a new ChatGPT chat automatically and continue with full context.

That behavior is a declared target, but it is **not currently verified as an available programmatic ChatGPT session-control API in this connected environment**. Therefore v1 does not pretend it can open or control a new ChatGPT conversation automatically.

What v1 already provides is the durable state layer needed for such a future handoff:

- canonical repository state;
- canonical work items;
- current owner/node;
- result metadata;
- handoff packet format;
- no duplicate execution rule.

If a supported session-control surface becomes available, it should consume this state rather than create a separate memory system.

## Anti-fabrication rule

Never report any of the following as complete without live evidence from the owning system:

- local PC connected;
- Ollama running;
- Obsidian vault connected;
- PowerShell task executed;
- new ChatGPT chat created automatically;
- Git change applied locally;
- deployment completed;
- social post published;
- revenue generated.

A repository file, planned channel, draft or successful control-plane migration is evidence only of that specific state.

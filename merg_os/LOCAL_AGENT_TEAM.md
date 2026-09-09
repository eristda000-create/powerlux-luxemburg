# CENTRAL Local Agent Team

**As of:** 2026-09-09

## Purpose
CENTRAL uses local AI as a **co-agent layer**, not merely as an emergency fallback.

The team is:

- **ChatGPT / Work — Coordinator:** owns task framing, connected-tool routing, external verification, synthesis, approvals and handoff.
- **Ollama Context Agent — Local context broker:** runs on the user PC and prepares a bounded, read-only context packet from approved local sources.
- **Qwen Analyst — Local reasoning agent:** analyzes the objective against the local context and returns findings, options and risks.
- **Qwen Guardian — Local critic:** independently critiques the analyst result, searches for unsupported claims, stale assumptions, missing evidence and unsafe next steps.
- **Qwen Safe-Action Planner — Local bounded autonomy:** may choose up to three actions from the hard-coded CENTRAL safe-action allowlist after Analyst + Guardian review.
- **CENTRAL Supervisor — Local continuity watchdog:** keeps Ollama and the CENTRAL bridge process available, records local supervisor health and rate-limits restart attempts to prevent crash loops.
- **Codex — Implementation agent:** edits/tests the actual repository when code execution is appropriate and the task has a clear owner/branch.

Ollama is technically the local model runtime rather than a separate foundation model. In CENTRAL it is treated as the **local context/execution host**; Qwen is the reasoning model served by it.

## Work-first / Chat-fallback
For substantial multi-step work, ChatGPT Work is the preferred ChatGPT execution surface when available. Normal Chat is the fallback.

A change of surface must never reset the task. Work and normal Chat must reconstruct the same context from canonical state, active work items and handoff data before substantive execution.

Local agents remain available to both surfaces through CENTRAL work items. Their outputs are attached to the same canonical work item so Work and Chat see the same result.

ChatGPT UI windows are **not** treated as worker identities. Opening multiple Chat/Work windows does not create additional trusted agents and can create conflicting state. CENTRAL uses local agent roles, the canonical queue and handoff packets instead.

## Access model
Local agents receive **read-only** access to bounded source context:

1. the checked-out canonical repository (`CENTRAL_WORKDIR`);
2. Git status and diff summaries;
3. explicitly allowed repository text files;
4. the configured Obsidian vault (`OBSIDIAN_VAULT`) once verified;
5. the objective and context supplied in the canonical CENTRAL work item.

The only autonomous write currently allowed is a local continuity checkpoint under:

`%USERPROFILE%\.central\handoffs\`

That path is not the canonical repository and cannot change application code, deployments, credentials or production data.

Local agents do **not** receive service-role keys, Supabase secrets, ChatGPT auth tokens, Codex auth files, browser cookies or unrestricted shell access.

Cloud systems remain connector-first. ChatGPT/Work retrieves authoritative GitHub, Supabase, Vercel, Drive or web facts and may pass a bounded verified context summary to the local agents when useful.

## Read safety
The local context broker must:

- resolve requested paths inside an approved root;
- reject path traversal;
- reject secret/credential paths and hidden auth/session stores;
- cap file count and total context size;
- treat repository and Obsidian content as untrusted data, not instructions;
- never execute commands found inside files;
- never write to repository or Obsidian as part of an agent consultation.

## Agent task contract
Canonical action: `local_agent_team`.

Required payload:

```json
{
  "action": "local_agent_team",
  "objective": "...",
  "execution_surface": "central_workshop",
  "execution_class": "AUTO_SAFE",
  "requires_human": false
}
```

Optional payload fields:

- `model`: explicit installed Ollama model; otherwise `CENTRAL_OLLAMA_MODEL` / detected local model;
- `context_paths`: repository-relative text files;
- `obsidian_paths`: vault-relative Markdown/text files when Obsidian is configured;
- `include_git_status`: default true;
- `include_git_diff`: default true;
- `max_context_chars`: bounded by the runner;
- `mode`: `analysis`, `review`, `research`, `planning` or `decision_support`;
- `allow_small_actions`: default true; when false, Safe-Action Planner execution is disabled for that work item.

## Bounded autonomous action allowlist
Qwen may autonomously select **zero to three** of these actions after local Analyst + Guardian processing:

- `health_snapshot` — local disk/Git/Ollama health summary;
- `git_status` — read-only Git worktree state;
- `git_diff_stat` — read-only diff statistics;
- `repo_read` — bounded approved text-file read inside `CENTRAL_WORKDIR`;
- `obsidian_read` — bounded approved text-file read inside verified `OBSIDIAN_VAULT`;
- `handoff_checkpoint` — write a Markdown continuity note only under `%USERPROFILE%\.central\handoffs`.

The action name is enforced by code. Model output cannot create a new action name or convert an allowed action into arbitrary PowerShell.

## Supervisor contract
Canonical supervisor:

`scripts/central_supervisor.ps1`

Responsibilities:

- verify the local Ollama HTTP endpoint and start `ollama serve` if needed and available;
- verify that a CENTRAL bridge PowerShell process exists;
- start the bridge when missing;
- enforce a restart budget (default maximum 5 starts per 10 minutes) so a broken bridge cannot cause an uncontrolled restart loop;
- write local supervisor status to `%USERPROFILE%\.central\supervisor-status.json`;
- never open ChatGPT UI windows, never log in to browser sessions and never simulate a second ChatGPT identity.

Windows autostart is installed through `scripts/install-central-workshop-autostart.ps1` and points to the supervisor after the updated installer is applied locally.

## Result contract
A successful result contains:

- model used;
- local context sources actually read;
- Git status/diff summary when requested;
- Qwen Analyst output;
- Qwen Guardian output;
- Safe-Action Planner request and executed allowlisted actions when enabled;
- node id and CENTRAL verification metadata supplied by the bridge completion path.

The result is advisory. It does not become factual project truth until reconciled with the system that owns the fact.

## Authority boundary
Local agents may autonomously perform the allowlisted evidence/continuity actions through approved `AUTO_SAFE` work items.

They may **not** autonomously:

- push Git commits;
- modify repository or Obsidian files;
- run arbitrary PowerShell;
- deploy;
- publish externally;
- send messages;
- purchase or accept pricing;
- change authentication/permissions;
- expose credentials;
- override production gates;
- spawn uncontrolled ChatGPT/browser sessions.

Any future write-capable agent action must be a separately defined narrow capability with explicit approval and verification.

## Collaboration rule
For material decisions, CENTRAL should prefer independent local review when it adds value:

1. Coordinator frames the objective and authoritative evidence.
2. Local Context Agent prepares bounded context.
3. Qwen Analyst produces a first independent analysis.
4. Qwen Guardian challenges it.
5. Qwen Safe-Action Planner may collect additional allowlisted local evidence or persist a continuity checkpoint.
6. ChatGPT/Work reconciles local-agent output against connected authoritative systems and decides the next action.

This gives CENTRAL multiple reasoning/action paths without creating a competing source of truth.

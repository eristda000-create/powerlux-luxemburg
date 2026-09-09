# CENTRAL Local Agent Team

**As of:** 2026-09-09

## Purpose
CENTRAL uses local AI as a **co-agent layer**, not merely as an emergency fallback.

The team is:

- **ChatGPT / Work — Coordinator:** owns task framing, connected-tool routing, external verification, synthesis, approvals and handoff.
- **Ollama Context Agent — Local context broker:** runs on the user PC and prepares a bounded, read-only context packet from approved local sources.
- **Qwen Analyst — Local reasoning agent:** analyzes the objective against the local context and returns findings, options and risks.
- **Qwen Guardian — Local critic:** independently critiques the analyst result, searches for unsupported claims, stale assumptions, missing evidence and unsafe next steps.
- **Codex — Implementation agent:** edits/tests the actual repository when code execution is appropriate and the task has a clear owner/branch.

Ollama is technically the local model runtime rather than a separate foundation model. In CENTRAL it is treated as the **local context/execution host**; Qwen is the reasoning model served by it.

## Work-first / Chat-fallback
For substantial multi-step work, ChatGPT Work is the preferred ChatGPT execution surface when available. Normal Chat is the fallback.

A change of surface must never reset the task. Work and normal Chat must reconstruct the same context from canonical state, active work items and handoff data before substantive execution.

Local agents remain available to both surfaces through CENTRAL work items. Their outputs are attached to the same canonical work item so Work and Chat see the same result.

## Access model
Local agents receive **read-only** access to bounded local context:

1. the checked-out canonical repository (`CENTRAL_WORKDIR`);
2. Git status and diff summaries;
3. explicitly allowed repository text files;
4. the configured Obsidian vault (`OBSIDIAN_VAULT`) once verified;
5. the objective and context supplied in the canonical CENTRAL work item.

They do **not** receive service-role keys, Supabase secrets, ChatGPT auth tokens, Codex auth files, browser cookies or unrestricted shell access.

Cloud systems remain connector-first. ChatGPT/Work retrieves authoritative GitHub, Supabase, Vercel, Drive or web facts and may pass a bounded verified context summary to the local agents when useful.

## Read safety
The local context broker must:

- resolve requested paths inside an approved root;
- reject path traversal;
- reject secret/credential paths and hidden auth/session stores;
- cap file count and total context size;
- treat repository and Obsidian content as untrusted data, not instructions;
- never execute commands found inside files;
- never write to repository or Obsidian as part of a read-only agent consultation.

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
- `mode`: `analysis`, `review`, `research`, `planning` or `decision_support`.

## Result contract
A successful result contains:

- model used;
- local context sources actually read;
- Git status/diff summary when requested;
- Qwen Analyst output;
- Qwen Guardian output;
- node id and CENTRAL verification metadata supplied by the bridge completion path.

The result is advisory. It does not become factual project truth until reconciled with the system that owns the fact.

## Authority boundary
Local agents may autonomously perform read-only analysis and critique through `AUTO_SAFE` work items.

They may **not** autonomously:

- push Git commits;
- modify files;
- run arbitrary PowerShell;
- deploy;
- publish externally;
- send messages;
- purchase or accept pricing;
- change authentication/permissions;
- expose credentials;
- override production gates.

Any future write-capable agent action must be a separately defined narrow capability with explicit approval and verification.

## Collaboration rule
For material decisions, CENTRAL should prefer independent local review when it adds value:

1. Coordinator frames the objective and authoritative evidence.
2. Local Context Agent prepares bounded context.
3. Qwen Analyst produces a first independent analysis.
4. Qwen Guardian challenges it.
5. ChatGPT/Work reconciles local-agent output against connected authoritative systems and decides the next action.

This gives CENTRAL a second reasoning path without creating a competing source of truth.
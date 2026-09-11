$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path -Parent $PSScriptRoot
$files = @(
  'scripts/central_hardware_inventory.ps1',
  'scripts/central_lab_sync.ps1',
  'scripts/central_model_router.ps1',
  'scripts/central_model_benchmark.ps1',
  'scripts/central_model_pull.ps1',
  'scripts/central_context_capsule.ps1',
  'scripts/central_obsidian_rag_v2.ps1',
  'scripts/central_local_agent_team.ps1'
)

foreach ($rel in $files) {
  $path = Join-Path $root $rel
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing: $rel" }
  $tokens=$null; $errors=$null
  [void][System.Management.Automation.Language.Parser]::ParseFile($path,[ref]$tokens,[ref]$errors)
  if ($errors.Count -gt 0) { throw "PowerShell parse errors in ${rel}: $($errors[0].Message)" }
}

. (Join-Path $root 'scripts/central_context_capsule.ps1')
. (Join-Path $root 'scripts/central_obsidian_rag_v2.ps1')
. (Join-Path $root 'scripts/central_model_router.ps1')
. (Join-Path $root 'scripts/central_model_benchmark.ps1')

if (Test-CentralGenerativeModelName 'nomic-embed-text:latest') { throw 'Embedding model must not be accepted as a generative reasoning model.' }
if (Test-CentralGenerativeModelName 'mxbai-embed-large:latest') { throw 'Embedding model must not be accepted as a generative reasoning model.' }
if (-not (Test-CentralGenerativeModelName 'qwen3:4b-instruct')) { throw 'Known Qwen generative model was incorrectly filtered.' }

$elapsedProbe = Get-CentralBenchmarkElapsedTotal -TaskResults @(
  [pscustomobject]@{ elapsed_ms=[long]11 },
  [pscustomobject]@{ elapsed_ms=[long]29 }
)
if ($elapsedProbe -ne 40) { throw "Benchmark elapsed aggregation is wrong: $elapsedProbe" }

# Prove bounded PowerShell capability dispatch happens before any model/objective/RAG path.
. (Join-Path $root 'scripts/central_local_agent_team.ps1')
function Get-CentralHardwareInventory {
  param([string]$OllamaUrl)
  return [ordered]@{ probe='stubbed'; ollama_url=$OllamaUrl }
}
$capPayload = [pscustomobject]@{ mode='hardware_inventory' }
$capResult = Invoke-CentralLocalAgentTeam -Payload $capPayload -WorkDir $root -ObsidianVault $root -OllamaUrl 'http://127.0.0.1:9'
if ($capResult.performance_profile -ne 'powershell_capability_v2') { throw 'Direct capability did not bypass the reasoning path.' }
if ($capResult.capability_dispatch -ne 'direct_pre_reasoning') { throw 'Direct capability dispatch marker missing.' }
if ($capResult.result.probe -ne 'stubbed') { throw 'Direct capability stub result missing.' }

$tmp = Join-Path ([IO.Path]::GetTempPath()) ('central-deep-intelligence-' + [guid]::NewGuid().ToString('N'))
try {
  $central = Join-Path $tmp 'CENTRAL/PROJECTS/POWERTV'
  New-Item -ItemType Directory -Path $central -Force | Out-Null
  @'
# PowerTV State

## Latest release
The Associate Player is a required feature marker for the latest canonical PowerTV release.

## Rights
External streams require verified rights evidence.
'@ | Set-Content -LiteralPath (Join-Path $central 'STATE.md') -Encoding UTF8

  $hits = @(Get-CentralObsidianRagContextV2 -Vault $tmp -Query 'PowerTV Associate Player latest release' -OllamaUrl 'http://127.0.0.1:9' -EmbeddingModel 'missing-model' -Project 'powertv' -TopK 3)
  if ($hits.Count -lt 1) { throw 'Hybrid RAG lexical fallback returned no result.' }
  if ($hits[0].path -notlike '*POWERTV*STATE.md') { throw 'Hybrid RAG did not rank project state first.' }

  $capsule = New-CentralContextCapsule -Project 'powertv' -Objective 'Verify latest release' -MandatorySources @('CENTRAL/PROJECTS/POWERTV/STATE.md') -RagHits $hits
  if ($capsule.schema -ne 'central_context_capsule_v1') { throw 'Context capsule schema mismatch.' }
  if ($capsule.text -notmatch 'FACT / INFERENCE / HYPOTHESIS / OPEN') { throw 'Context capsule reasoning contract missing.' }

  Write-Host 'CENTRAL Deep Intelligence Gate: PASS'
} finally {
  Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

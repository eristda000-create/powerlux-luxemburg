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
  'scripts/central_local_agent_team.ps1',
  'scripts/start-central-workshop.ps1'
)

foreach ($rel in $files) {
  $path = Join-Path $root $rel
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing: $rel" }
  $tokens=$null; $errors=$null
  [void][System.Management.Automation.Language.Parser]::ParseFile($path,[ref]$tokens,[ref]$errors)
  if ($errors.Count -gt 0) { throw "PowerShell parse errors in ${rel}: $($errors[0].Message)" }
}

$startSource = Get-Content -LiteralPath (Join-Path $root 'scripts/start-central-workshop.ps1') -Raw
if ($startSource -notmatch 'function Get-CentralRepoHead') { throw 'Workshop start script is missing bounded repo-head restart detection.' }
if ($startSource -notmatch '\$headBeforeRunner\s*=\s*Get-CentralRepoHead') { throw 'Workshop start script does not capture HEAD before the bridge runner.' }
if ($startSource -notmatch '\$headAfterRunner\s*=\s*Get-CentralRepoHead') { throw 'Workshop start script does not capture HEAD after the bridge runner.' }
if ($startSource -notmatch '\$headBeforeRunner\s*-ne\s*\$headAfterRunner') { throw 'Workshop start script does not gate self-relaunch on an actual repo HEAD change.' }
if ($startSource -notmatch '-not\s+\$Once') { throw 'Workshop self-relaunch must be disabled for one-shot verification runs.' }
if ($startSource -notmatch 'Start-Process\s+-FilePath\s+\$pwsh\.Source') { throw 'Workshop start script is missing the bounded pwsh self-relaunch.' }

$teamSource = Get-Content -LiteralPath (Join-Path $root 'scripts/central_local_agent_team.ps1') -Raw
if ($teamSource -notmatch "hardware_14gb_v1") { throw 'Deep hardware-aware context compaction marker is missing.' }
if ($teamSource -notmatch 'capsuleMaxChars\s*=\s*if\s*\(\$isDeepProfile\)\s*\{\s*3000\s*\}') { throw 'Deep context capsule must be capped at 3000 characters.' }
if ($teamSource -notmatch 'max_context_chars.+4200') { throw 'Deep core context must be capped at 4200 characters after RAG compaction.' }
if ($teamSource -notmatch 'TopK\s+\$topK') { throw 'Deep RAG must use the bounded dynamic TopK path.' }

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

# Prove the router's Ollama override only enables native thinking for explicit deep Qwen3.5 9B calls.
$script:CapturedOllamaBody = $null
function Invoke-RestMethod {
  param(
    [string]$Method,
    [string]$Uri,
    [string]$ContentType,
    [string]$Body,
    [int]$TimeoutSec
  )
  $script:CapturedOllamaBody = $Body | ConvertFrom-Json
  return [pscustomobject]@{ response='FINAL_OK'; thinking='stubbed private reasoning' }
}

$deepOut = Invoke-CentralOllamaAgent -OllamaUrl 'http://127.0.0.1:9' -Model 'qwen3.5:9b' -Prompt "Project: central`nMode: deep`nObjective: test" -MaxTokens 180 -ContextTokens 3328 -TimeoutSec 120
if ($deepOut -ne 'FINAL_OK') { throw 'Deep Ollama override did not return the final response.' }
if (-not [bool]$script:CapturedOllamaBody.think) { throw 'Deep qwen3.5:9b must use native Ollama thinking.' }
$deepPredict = [int]$script:CapturedOllamaBody.options.num_predict
if ($deepPredict -lt 288 -or $deepPredict -gt 320) { throw "Deep qwen3.5:9b thinking budget must stay in the measured desktop-safe 288..320 range, got $deepPredict." }

$standardOut = Invoke-CentralOllamaAgent -OllamaUrl 'http://127.0.0.1:9' -Model 'qwen3:4b-instruct' -Prompt "Project: central`nMode: analysis`nObjective: test" -MaxTokens 180 -ContextTokens 3328 -TimeoutSec 120
if ($standardOut -ne 'FINAL_OK') { throw 'Standard Ollama override did not return the final response.' }
if ([bool]$script:CapturedOllamaBody.think) { throw 'Routine qwen3:4b-instruct must remain non-thinking for latency.' }
Remove-Item Function:\Invoke-RestMethod -Force

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

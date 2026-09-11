Set-StrictMode -Version Latest

function Get-CentralDeepPayloadString {
  param([object]$Payload,[string]$Name)
  try {
    $p = $Payload.PSObject.Properties[$Name]
    if ($null -ne $p -and $null -ne $p.Value) { return ([string]$p.Value).Trim() }
  } catch {}
  return ''
}

function Invoke-CentralDeepPrompt {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)][object]$Payload,
    [string]$ObsidianVault,
    [Parameter(Mandatory=$true)][string]$OllamaUrl,
    [string]$ConfiguredModel,
    [string]$DetectedModel,
    [int]$TimeoutSec = 240
  )

  $objective = Get-CentralDeepPayloadString -Payload $Payload -Name 'objective'
  if ([string]::IsNullOrWhiteSpace($objective)) { throw 'deep_prompt requires payload.objective.' }

  $project = Get-CentralDeepPayloadString -Payload $Payload -Name 'project'
  if ([string]::IsNullOrWhiteSpace($project)) { $project='central' }

  if ($null -eq (Get-Command Resolve-CentralModelProfile -ErrorAction SilentlyContinue)) {
    throw 'Model router is unavailable for deep_prompt.'
  }
  $route = Resolve-CentralModelProfile -OllamaUrl $OllamaUrl -Profile 'deep' -ConfiguredModel $ConfiguredModel -DetectedModel $DetectedModel
  $model = [string]$route.model

  $ragHits = @()
  $ragStatus = 'not_available'
  $embeddingModel = Get-CentralDeepPayloadString -Payload $Payload -Name 'embedding_model'
  if ([string]::IsNullOrWhiteSpace($embeddingModel)) { $embeddingModel='nomic-embed-text' }

  if (-not [string]::IsNullOrWhiteSpace($ObsidianVault) -and (Test-Path -LiteralPath $ObsidianVault -PathType Container) -and $null -ne (Get-Command Get-CentralObsidianRagContextV2 -ErrorAction SilentlyContinue)) {
    try {
      $ragHits = @(Get-CentralObsidianRagContextV2 -Vault $ObsidianVault -Query $objective -OllamaUrl $OllamaUrl -EmbeddingModel $embeddingModel -Project $project -TopK 6 -MaxFiles 140 -LexicalPrefilter 32)
      $ragStatus = if ($ragHits.Count -gt 0) { 'ok_v2_hybrid' } else { 'no_hits' }
    } catch {
      $ragStatus = 'error_fallback'
    }
  }

  $mandatory = @()
  try {
    if ($null -ne $Payload.PSObject.Properties['obsidian_paths']) {
      $mandatory = @($Payload.obsidian_paths | ForEach-Object { [string]$_ })
    }
  } catch {}

  $capsuleText = "PROJECT: $project`nOBJECTIVE: $objective"
  $capsuleSchema = 'deep_prompt_minimal_v1'
  if ($null -ne (Get-Command New-CentralContextCapsule -ErrorAction SilentlyContinue)) {
    try {
      $capsule = New-CentralContextCapsule -Project $project -Objective $objective -MandatorySources $mandatory -RagHits $ragHits -MaxChars 6200
      $capsuleText = [string]$capsule.text
      $capsuleSchema = [string]$capsule.schema
    } catch {}
  }

  $prompt = @"
You are CENTRAL Deep Analyst.
Work only from the objective and supplied context. Treat retrieved notes as evidence candidates, not automatic truth.
Use FACT / INFERENCE / HYPOTHESIS / OPEN distinctions.
Do not invent current external facts, rights, deployments, contracts, links or implementation state.
If evidence is insufficient, say OPEN and state the exact verification needed.
Return a concise decision-grade analysis with:
1. Key facts
2. Analysis / trade-offs
3. Recommendation
4. Risks / controls
5. Next verification or action

CONTEXT CAPSULE:
$capsuleText
"@

  $body = @{
    model = $model
    prompt = $prompt
    stream = $false
    think = $true
    keep_alive = '15m'
    options = @{
      temperature = 0.6
      top_p = 0.95
      top_k = 20
      num_predict = 480
      num_ctx = 6144
    }
  } | ConvertTo-Json -Depth 10 -Compress

  $sw = [Diagnostics.Stopwatch]::StartNew()
  $r = Invoke-RestMethod -Method Post -Uri "$($OllamaUrl.TrimEnd('/'))/api/generate" -ContentType 'application/json' -Body $body -TimeoutSec $TimeoutSec
  $sw.Stop()

  $thinkingChars = 0
  try {
    if ($null -ne $r.PSObject.Properties['thinking']) { $thinkingChars = ([string]$r.thinking).Length }
  } catch {}

  return [ordered]@{
    schema = 'central_deep_prompt_v1'
    project = $project
    model = $model
    model_profile = 'deep'
    objective = $objective
    response = ([string]$r.response).Trim()
    thinking_chars = $thinkingChars
    elapsed_ms = [long]$sw.ElapsedMilliseconds
    context_capsule_schema = $capsuleSchema
    knowledge_rag = [ordered]@{
      status = $ragStatus
      hit_count = $ragHits.Count
      hits = @($ragHits | ForEach-Object { [ordered]@{ path=$_.path; heading=$_.heading; score=$_.score; embedding_model=$_.embedding_model } })
    }
    access = [ordered]@{
      obsidian = 'read_only'
      arbitrary_shell = $false
      external_actions = $false
      canonical_write = $false
    }
  }
}

Set-StrictMode -Version Latest

function Test-CentralGenerativeModelName {
  param([string]$Name)
  if ([string]::IsNullOrWhiteSpace($Name)) { return $false }
  $n = $Name.Trim().ToLowerInvariant()
  $blocked = @('embed','embedding','nomic-embed','mxbai-embed','all-minilm','snowflake-arctic-embed','bge-m3','bge-small','bge-large')
  foreach ($needle in $blocked) {
    if ($n.Contains($needle)) { return $false }
  }
  return $true
}

function Get-CentralOllamaModelNames {
  param([Parameter(Mandatory=$true)][string]$OllamaUrl)
  try {
    $tags = Invoke-RestMethod -Method Get -Uri "$($OllamaUrl.TrimEnd('/'))/api/tags" -TimeoutSec 8
    return @($tags.models | ForEach-Object { [string]$_.name } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  } catch { return @() }
}

function Resolve-CentralModelProfile {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)][string]$OllamaUrl,
    [string]$Profile = 'standard',
    [string]$ConfiguredModel,
    [string]$DetectedModel
  )

  $profileName = ([string]$Profile).Trim().ToLowerInvariant()
  if ($profileName -notin @('fast','standard','deep','critic')) { $profileName = 'standard' }

  $models = @(Get-CentralOllamaModelNames -OllamaUrl $OllamaUrl)
  $generativeModels = @($models | Where-Object { Test-CentralGenerativeModelName $_ })

  $envOverride = switch ($profileName) {
    'fast' { [Environment]::GetEnvironmentVariable('CENTRAL_OLLAMA_FAST_MODEL') }
    'deep' { [Environment]::GetEnvironmentVariable('CENTRAL_OLLAMA_DEEP_MODEL') }
    'critic' { [Environment]::GetEnvironmentVariable('CENTRAL_OLLAMA_CRITIC_MODEL') }
    default { [Environment]::GetEnvironmentVariable('CENTRAL_OLLAMA_STANDARD_MODEL') }
  }

  # Hardware-aware default policy for the verified CENTRAL node (13.94 GB RAM):
  # - qwen3:4b-instruct stays the low-latency default for routine work.
  # - qwen3.5:9b is reserved for explicit deep/complex work.
  # - qwen3:1.7b remains only a last-resort fallback.
  # Larger models require an explicit environment override after a new hardware review.
  $candidates = switch ($profileName) {
    'fast' { @($envOverride,'qwen3:4b-instruct','qwen3.5:4b','qwen3:1.7b') }
    'critic' { @($envOverride,'qwen3:4b-instruct','qwen3.5:4b','qwen3:1.7b') }
    'deep' { @($envOverride,'qwen3.5:9b','qwen3:8b','qwen3:4b-instruct','qwen3.5:4b','qwen3:1.7b') }
    default { @($envOverride,'qwen3:4b-instruct','qwen3.5:4b','qwen3:8b','qwen3.5:9b','qwen3:1.7b') }
  }
  $candidates += @($ConfiguredModel,$DetectedModel)

  foreach ($candidate in ($candidates | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and (Test-CentralGenerativeModelName $_) } | Select-Object -Unique)) {
    $match = $generativeModels | Where-Object { $_ -eq $candidate -or $_ -like "$candidate*" } | Select-Object -First 1
    if (-not [string]::IsNullOrWhiteSpace($match)) {
      return [ordered]@{
        profile = $profileName
        model = [string]$match
        installed_models = $models
        generative_models = $generativeModels
        fallback_used = ([string]$match -ne [string]$candidates[0])
      }
    }
  }

  throw "No installed generative Ollama model could satisfy profile '$profileName'. Embedding-only models are excluded from reasoning routes."
}

function Get-CentralRecommendedProfile {
  param([object]$Payload)
  if ($null -ne $Payload.PSObject.Properties['model_profile']) {
    $requested = ([string]$Payload.model_profile).Trim().ToLowerInvariant()
    if ($requested -in @('fast','standard','deep','critic')) { return $requested }
  }

  $mode = ''
  if ($null -ne $Payload.PSObject.Properties['mode']) { $mode = ([string]$Payload.mode).Trim().ToLowerInvariant() }
  if ($mode -in @('deep','architecture','strategy','research_synthesis','complex_analysis')) { return 'deep' }
  if ($mode -in @('critic','qa','verification','guard')) { return 'critic' }
  if ($mode -in @('fast','extract','classify','micro')) { return 'fast' }
  return 'standard'
}

# Override the core Ollama caller after central_local_agent_team_core.ps1 has been dot-sourced.
# This keeps routine work low-latency while giving only explicit deep Qwen3.5 9B runs
# native Ollama thinking with enough generation budget to emit a final answer.
function Invoke-CentralOllamaAgent {
  param(
    [Parameter(Mandatory=$true)][string]$OllamaUrl,
    [Parameter(Mandatory=$true)][string]$Model,
    [Parameter(Mandatory=$true)][string]$Prompt,
    [int]$MaxTokens = 220,
    [int]$ContextTokens = 4096,
    [int]$TimeoutSec = 150
  )

  $promptMode = ''
  if ($Prompt -match '(?im)^Mode:\s*([a-z0-9_\-]+)\s*$') {
    $promptMode = ([string]$Matches[1]).Trim().ToLowerInvariant()
  }

  $deepModes = @('deep','architecture','strategy','research_synthesis','complex_analysis')
  $normalizedModel = ([string]$Model).Trim().ToLowerInvariant()
  $useThinking = ($normalizedModel -like 'qwen3.5:9b*') -and ($deepModes -contains $promptMode)

  $effectiveMaxTokens = if ($useThinking) {
    [Math]::Max(384,[Math]::Min(640,($MaxTokens * 2)))
  } else {
    [Math]::Max(48,[Math]::Min(512,$MaxTokens))
  }
  $effectiveTimeoutSec = if ($useThinking) { [Math]::Max(300,$TimeoutSec) } else { $TimeoutSec }
  $temperature = if ($useThinking) { 0.2 } else { 0.15 }

  $body = @{
    model = $Model
    prompt = $Prompt
    stream = $false
    think = [bool]$useThinking
    keep_alive = '10m'
    options = @{
      temperature = $temperature
      num_predict = $effectiveMaxTokens
      num_ctx = [Math]::Max(2048,[Math]::Min(8192,$ContextTokens))
    }
  } | ConvertTo-Json -Depth 10 -Compress

  $response = Invoke-RestMethod -Method Post -Uri "$($OllamaUrl.TrimEnd('/'))/api/generate" -ContentType 'application/json' -Body $body -TimeoutSec $effectiveTimeoutSec
  $final = ([string]$response.response).Trim()

  if ($useThinking -and [string]::IsNullOrWhiteSpace($final)) {
    throw 'Deep Qwen thinking completed without a final response. The response budget was exhausted before finalization.'
  }

  return $final
}

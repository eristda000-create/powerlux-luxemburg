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
  if ($profileName -notin @('fast','standard','deep','critic','independent','code','vision')) { $profileName = 'standard' }

  $models = @(Get-CentralOllamaModelNames -OllamaUrl $OllamaUrl)
  $generativeModels = @($models | Where-Object { Test-CentralGenerativeModelName $_ })

  $envOverride = switch ($profileName) {
    'fast' { [Environment]::GetEnvironmentVariable('CENTRAL_OLLAMA_FAST_MODEL') }
    'deep' { [Environment]::GetEnvironmentVariable('CENTRAL_OLLAMA_DEEP_MODEL') }
    'critic' { [Environment]::GetEnvironmentVariable('CENTRAL_OLLAMA_CRITIC_MODEL') }
    'independent' { [Environment]::GetEnvironmentVariable('CENTRAL_OLLAMA_INDEPENDENT_MODEL') }
    'code' { [Environment]::GetEnvironmentVariable('CENTRAL_OLLAMA_CODE_MODEL') }
    'vision' { [Environment]::GetEnvironmentVariable('CENTRAL_OLLAMA_VISION_MODEL') }
    default { [Environment]::GetEnvironmentVariable('CENTRAL_OLLAMA_STANDARD_MODEL') }
  }

  # Hardware-aware diversified policy for the verified CENTRAL node (13.94 GB RAM / 4 cores):
  # - Qwen stays the fast/generalist family.
  # - Gemma 3 4B is the preferred lightweight independent critic once installed.
  # - DeepSeek R1 7B is reserved for explicit independent/second-opinion work because a real
  #   full-context critic run exceeded the 120s CPU budget on 2026-09-12.
  # - Qwen Coder is the coding specialist.
  $candidates = switch ($profileName) {
    'fast' { @($envOverride,'qwen3.5:4b','qwen3:4b-instruct','qwen3:1.7b') }
    'critic' { @($envOverride,'gemma3:4b','qwen3.5:4b','qwen3:4b-instruct','qwen3:1.7b','deepseek-r1:7b') }
    'independent' { @($envOverride,'deepseek-r1:7b','qwen3.5:9b','gemma3:4b','qwen3.5:4b') }
    'deep' { @($envOverride,'qwen3.5:9b','deepseek-r1:7b','qwen3:4b-instruct','qwen3.5:4b','qwen3:1.7b') }
    'code' { @($envOverride,'qwen2.5-coder:7b','qwen3.5:9b','qwen3:4b-instruct','qwen3.5:4b','qwen3:1.7b') }
    'vision' { @($envOverride,'gemma3:4b','qwen3.5:9b','qwen3.5:4b','qwen3:4b-instruct') }
    default { @($envOverride,'qwen3:4b-instruct','qwen3.5:4b','gemma3:4b','qwen3.5:9b','qwen3:1.7b') }
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
    if ($requested -in @('fast','standard','deep','critic','independent','code','vision')) { return $requested }
  }

  $mode = ''
  if ($null -ne $Payload.PSObject.Properties['mode']) { $mode = ([string]$Payload.mode).Trim().ToLowerInvariant() }
  if ($mode -in @('coding','code','implementation','bugfix','debug','refactor','code_review')) { return 'code' }
  if ($mode -in @('vision','image_analysis','screenshot','multimodal')) { return 'vision' }
  if ($mode -in @('second_opinion','independent_review','independent')) { return 'independent' }
  if ($mode -in @('deep','architecture','strategy','research_synthesis','complex_analysis')) { return 'deep' }
  if ($mode -in @('critic','qa','verification','guard')) { return 'critic' }
  if ($mode -in @('fast','extract','classify','micro')) { return 'fast' }
  return 'standard'
}

# Override the core Ollama caller after central_local_agent_team_core.ps1 has been dot-sourced.
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
  $isDeepSeek = ($normalizedModel -like 'deepseek-r1:7b*')

  $effectiveMaxTokens = if ($useThinking) {
    $scaled = [int][Math]::Ceiling($MaxTokens * 1.6)
    [Math]::Max(288,[Math]::Min(320,$scaled))
  } elseif ($isDeepSeek) {
    [Math]::Max(64,[Math]::Min(120,$MaxTokens))
  } else {
    [Math]::Max(48,[Math]::Min(512,$MaxTokens))
  }
  $effectiveTimeoutSec = if ($useThinking) { [Math]::Max(300,$TimeoutSec) } elseif ($isDeepSeek) { [Math]::Max(210,$TimeoutSec) } else { $TimeoutSec }
  $temperature = if ($useThinking) { 0.2 } elseif ($isDeepSeek) { 0.1 } else { 0.15 }

  $body = @{
    model = $Model
    prompt = $Prompt
    stream = $false
    think = [bool]$useThinking
    keep_alive = '5m'
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

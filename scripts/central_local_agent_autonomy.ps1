function Get-CentralAutonomyModel {
  param([string]$ConfiguredModel,[string]$DetectedModel)
  if (-not [string]::IsNullOrWhiteSpace($ConfiguredModel)) { return $ConfiguredModel }
  if (-not [string]::IsNullOrWhiteSpace($DetectedModel)) { return $DetectedModel }
  throw 'No Ollama model is configured or detected for local autonomy.'
}

function Resolve-CentralAutonomySupportModel {
  param(
    [Parameter(Mandatory=$true)][string]$OllamaUrl,
    [Parameter(Mandatory=$true)][string]$FallbackModel
  )

  $preferred = [Environment]::GetEnvironmentVariable('CENTRAL_OLLAMA_FAST_MODEL')
  if ([string]::IsNullOrWhiteSpace($preferred)) { $preferred = 'qwen3:1.7b' }
  try {
    $tags = Invoke-RestMethod -Method Get -Uri "$($OllamaUrl.TrimEnd('/'))/api/tags" -TimeoutSec 5
    $names = @($tags.models | ForEach-Object { [string]$_.name })
    $match = $names | Where-Object { $_ -eq $preferred -or $_ -like "$preferred*" } | Select-Object -First 1
    if (-not [string]::IsNullOrWhiteSpace($match)) { return [string]$match }
  } catch {}
  return $FallbackModel
}

function ConvertFrom-CentralAgentJson {
  param([string]$Text)
  if ([string]::IsNullOrWhiteSpace($Text)) { return $null }
  try { return ($Text | ConvertFrom-Json -ErrorAction Stop) } catch {}
  $m = [regex]::Match($Text,'\{.*\}','Singleline')
  if ($m.Success) {
    try { return ($m.Value | ConvertFrom-Json -ErrorAction Stop) } catch {}
  }
  return $null
}

function Invoke-CentralAutonomySafeAction {
  param(
    [Parameter(Mandatory=$true)][object]$Action,
    [Parameter(Mandatory=$true)][string]$WorkDir,
    [string]$ObsidianVault,
    [Parameter(Mandatory=$true)][string]$OllamaUrl
  )

  $name = ([string]$Action.name).Trim().ToLowerInvariant()
  switch ($name) {
    'health_snapshot' {
      $git = (& git -C $WorkDir status --short --branch 2>&1 | Out-String).Trim()
      $tags = $null
      try { $tags = Invoke-RestMethod -Method Get -Uri "$($OllamaUrl.TrimEnd('/'))/api/tags" -TimeoutSec 5 } catch {}
      $models = if ($null -ne $tags) { @($tags.models | ForEach-Object { $_.name }) } else { @() }
      $drive = Get-Item -LiteralPath $WorkDir
      $freeGb = $null
      try { $freeGb = [math]::Round((Get-PSDrive -Name $drive.PSDrive.Name).Free / 1GB,2) } catch {}
      return [ordered]@{ name=$name; ok=$true; git=$git; ollama_models=$models; free_gb=$freeGb }
    }
    'git_status' {
      $output = (& git -C $WorkDir status --short --branch 2>&1 | Out-String).Trim()
      return [ordered]@{ name=$name; ok=($LASTEXITCODE -eq 0); output=$output }
    }
    'git_diff_stat' {
      $output = (& git -C $WorkDir diff --stat 2>&1 | Out-String).Trim()
      return [ordered]@{ name=$name; ok=($LASTEXITCODE -eq 0); output=$output }
    }
    'repo_read' {
      $relative = [string]$Action.path
      if ([string]::IsNullOrWhiteSpace($relative)) { throw 'repo_read requires path.' }
      if ($null -eq (Get-Command Resolve-CentralSafeTextFile -ErrorAction SilentlyContinue)) {
        throw 'Safe path resolver is unavailable.'
      }
      $file = Resolve-CentralSafeTextFile -Root $WorkDir -RelativePath $relative
      $text = Get-Content -LiteralPath $file -Raw -ErrorAction Stop
      $max = [Math]::Min(4000,$text.Length)
      return [ordered]@{ name=$name; ok=$true; path=$relative; content=$text.Substring(0,$max) }
    }
    'obsidian_read' {
      if ([string]::IsNullOrWhiteSpace($ObsidianVault) -or -not (Test-Path -LiteralPath $ObsidianVault -PathType Container)) {
        return [ordered]@{ name=$name; ok=$false; error='OBSIDIAN_VAULT is not configured/verified.' }
      }
      $relative = [string]$Action.path
      if ([string]::IsNullOrWhiteSpace($relative)) { throw 'obsidian_read requires path.' }
      $file = Resolve-CentralSafeTextFile -Root $ObsidianVault -RelativePath $relative
      $text = Get-Content -LiteralPath $file -Raw -ErrorAction Stop
      $max = [Math]::Min(4000,$text.Length)
      return [ordered]@{ name=$name; ok=$true; path=$relative; content=$text.Substring(0,$max) }
    }
    'handoff_checkpoint' {
      $text = [string]$Action.content
      if ([string]::IsNullOrWhiteSpace($text)) { throw 'handoff_checkpoint requires content.' }
      if ($text.Length -gt 8000) { $text = $text.Substring(0,8000) }
      $dir = Join-Path (Join-Path $HOME '.central') 'handoffs'
      if (-not (Test-Path -LiteralPath $dir -PathType Container)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
      }
      $namePart = [DateTimeOffset]::UtcNow.ToString('yyyyMMdd-HHmmssfff')
      $path = Join-Path $dir "agent-checkpoint-$namePart.md"
      @(
        '# CENTRAL Local Agent Checkpoint',
        '',
        "Created: $([DateTimeOffset]::UtcNow.ToString('o'))",
        '',
        $text
      ) | Set-Content -LiteralPath $path -Encoding UTF8
      return [ordered]@{ name=$name; ok=$true; path=$path }
    }
    default {
      return [ordered]@{ name=$name; ok=$false; error='Action is not in the CENTRAL local autonomy allowlist.' }
    }
  }
}

function Invoke-CentralLocalAutonomy {
  param(
    [Parameter(Mandatory=$true)][object]$Payload,
    [Parameter(Mandatory=$true)][object]$TeamResult,
    [Parameter(Mandatory=$true)][string]$WorkDir,
    [string]$ObsidianVault,
    [Parameter(Mandatory=$true)][string]$OllamaUrl,
    [string]$ConfiguredModel,
    [string]$DetectedModel
  )

  $enabled = $true
  if ($null -ne $Payload.PSObject.Properties['allow_small_actions']) {
    $enabled = [bool]$Payload.allow_small_actions
  }
  if (-not $enabled) {
    return [ordered]@{ enabled=$false; executed=@(); reason='disabled_by_work_item' }
  }

  $fallbackModel = Get-CentralAutonomyModel -ConfiguredModel $ConfiguredModel -DetectedModel $DetectedModel
  $model = Resolve-CentralAutonomySupportModel -OllamaUrl $OllamaUrl -FallbackModel $fallbackModel
  $objective = [string]$Payload.objective
  $analyst = [string]$TeamResult.agents.qwen_analyst.response
  $guardian = [string]$TeamResult.agents.qwen_guardian.response

  $plannerPrompt = @"
You are CENTRAL's local Safe-Action Planner.
Objective: $objective

Choose zero to three actions ONLY from:
- health_snapshot
- git_status
- git_diff_stat
- repo_read with repository-relative text path
- obsidian_read with vault-relative text path, only if configured
- handoff_checkpoint with short Markdown content

Rules:
- Evidence gathering and continuity only.
- Never request shell commands, repository modification, commit/push, deployment, browser control, messages, auth changes or external side effects.
- Prefer zero actions when evidence is sufficient.
- Output ONLY compact valid JSON, e.g. {"actions":[{"name":"git_status"}]}.

ANALYST:
$analyst

GUARDIAN:
$guardian
"@

  $raw = Invoke-CentralOllamaAgent -OllamaUrl $OllamaUrl -Model $model -Prompt $plannerPrompt -MaxTokens 72 -ContextTokens 2304 -TimeoutSec 60
  $plan = ConvertFrom-CentralAgentJson -Text $raw
  if ($null -eq $plan -or $null -eq $plan.actions) {
    return [ordered]@{ enabled=$true; performance_profile='dual_model_v3'; planner_model=$model; plan_valid=$false; raw=$raw; executed=@() }
  }

  $executed = [System.Collections.Generic.List[object]]::new()
  foreach ($action in @($plan.actions | Select-Object -First 3)) {
    try {
      $executed.Add((Invoke-CentralAutonomySafeAction -Action $action -WorkDir $WorkDir -ObsidianVault $ObsidianVault -OllamaUrl $OllamaUrl))
    } catch {
      $executed.Add([ordered]@{ name=[string]$action.name; ok=$false; error=$_.Exception.Message })
    }
  }

  return [ordered]@{
    enabled = $true
    performance_profile = 'dual_model_v3'
    planner_model = $model
    plan_valid = $true
    requested = @($plan.actions | Select-Object -First 3)
    executed = @($executed)
  }
}

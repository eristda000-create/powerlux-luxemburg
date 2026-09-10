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

function ConvertTo-CentralAssistantRequest {
  param([Parameter(Mandatory=$true)][object]$Action)

  $kind = ([string]$Action.kind).Trim().ToLowerInvariant()
  if ($kind -notin @('review','verify','research','write_repo','write_content','connected_source','decision')) {
    throw 'assistant_request kind is not allowed.'
  }

  $project = ([string]$Action.project).Trim().ToLowerInvariant()
  if ([string]::IsNullOrWhiteSpace($project)) { $project = 'central' }
  if ($project -notin @('central','powerlux','powertv','merg','cogni')) {
    throw 'assistant_request project is not allowed.'
  }

  $instruction = ([string]$Action.instruction).Trim()
  if ([string]::IsNullOrWhiteSpace($instruction)) { throw 'assistant_request requires instruction.' }
  if ($instruction.Length -gt 4000) { $instruction = $instruction.Substring(0,4000) }

  $summary = ([string]$Action.summary).Trim()
  if ($summary.Length -gt 1000) { $summary = $summary.Substring(0,1000) }

  $targetPath = ([string]$Action.target_path).Trim()
  if (-not [string]::IsNullOrWhiteSpace($targetPath)) {
    if ([IO.Path]::IsPathRooted($targetPath) -or $targetPath.Contains('..') -or (Test-CentralBlockedRelativePath $targetPath)) {
      throw 'assistant_request target_path is blocked.'
    }
    if ($targetPath.Length -gt 500) { $targetPath = $targetPath.Substring(0,500) }
  }

  $targetRepo = ([string]$Action.target_repo).Trim()
  if ($targetRepo.Length -gt 300) { $targetRepo = $targetRepo.Substring(0,300) }

  $evidence = @()
  if ($null -ne $Action.PSObject.Properties['evidence'] -and $null -ne $Action.evidence) {
    $evidence = @($Action.evidence | Select-Object -First 8 | ForEach-Object {
      $s = ([string]$_).Trim()
      if ($s.Length -gt 500) { $s.Substring(0,500) } else { $s }
    } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  }

  return [ordered]@{
    request_id = [guid]::NewGuid().ToString()
    kind = $kind
    project = $project
    summary = $summary
    instruction = $instruction
    target_repo = $targetRepo
    target_path = $targetPath
    evidence = $evidence
  }
}

function Invoke-CentralAutonomySafeAction {
  param(
    [Parameter(Mandatory=$true)][object]$Action,
    [Parameter(Mandatory=$true)][string]$WorkDir,
    [string]$ObsidianVault,
    [Parameter(Mandatory=$true)][string]$OllamaUrl,
    [string]$NodeId,
    [string]$ParentWorkItemId
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
    'assistant_request' {
      if ([string]::IsNullOrWhiteSpace($NodeId)) { throw 'assistant_request requires the verified workshop node id.' }
      if ($null -eq (Get-Command Invoke-CentralBridge -ErrorAction SilentlyContinue)) {
        throw 'CENTRAL bridge request function is unavailable.'
      }
      $request = ConvertTo-CentralAssistantRequest -Action $Action
      $response = Invoke-CentralBridge 'assistant_request' @{
        node_id = $NodeId
        parent_work_item_id = $ParentWorkItemId
        request = $request
      }
      return [ordered]@{
        name = $name
        ok = [bool]$response.ok
        request_id = $request.request_id
        controller_work_item_id = $response.data.work_item_id
        controller_status = 'queued_for_chatgpt_review'
      }
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
    [string]$DetectedModel,
    [string]$NodeId,
    [string]$ParentWorkItemId
  )

  if ([string]::IsNullOrWhiteSpace($NodeId)) {
    $NodeId = [Environment]::GetEnvironmentVariable('CENTRAL_WORKSHOP_NODE_ID')
    if ([string]::IsNullOrWhiteSpace($NodeId)) {
      $NodeId = "$([System.Net.Dns]::GetHostName())-$env:USERNAME"
    }
  }

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
- assistant_request when ChatGPT/controller help is genuinely needed. For assistant_request use:
  {"name":"assistant_request","kind":"review|verify|research|write_repo|write_content|connected_source|decision","project":"central|powerlux|powertv|merg|cogni","summary":"short reason","instruction":"what the controller should check or produce","target_repo":"optional owner/repo","target_path":"optional safe relative path","evidence":["short fact/source hints"]}

Rules:
- Evidence gathering and continuity only for local actions.
- assistant_request is a REQUEST, never an authorization or proof that work happened.
- Use assistant_request when cloud-connected verification, web/account data, GitHub/Supabase/Vercel access, or controlled repository/content writing is needed.
- Never include passwords, tokens, cookies, secrets, auth files or hidden credentials in a request.
- Never request arbitrary shell, force/reset/rebase, direct production deploy, purchases, messages, contracts, account/auth changes, or destructive actions.
- For existing PowerLux/PowerTV, never ask for a rebuild, replica, mockup or replacement frontend.
- Prefer zero actions when evidence is sufficient.
- Output ONLY compact valid JSON, e.g. {"actions":[{"name":"git_status"}]}.

ANALYST:
$analyst

GUARDIAN:
$guardian
"@

  $raw = Invoke-CentralOllamaAgent -OllamaUrl $OllamaUrl -Model $model -Prompt $plannerPrompt -MaxTokens 130 -ContextTokens 2560 -TimeoutSec 75
  $plan = ConvertFrom-CentralAgentJson -Text $raw
  if ($null -eq $plan -or $null -eq $plan.actions) {
    return [ordered]@{ enabled=$true; performance_profile='dual_model_v4'; planner_model=$model; plan_valid=$false; raw=$raw; executed=@() }
  }

  $executed = [System.Collections.Generic.List[object]]::new()
  foreach ($action in @($plan.actions | Select-Object -First 3)) {
    try {
      $executed.Add((Invoke-CentralAutonomySafeAction -Action $action -WorkDir $WorkDir -ObsidianVault $ObsidianVault -OllamaUrl $OllamaUrl -NodeId $NodeId -ParentWorkItemId $ParentWorkItemId))
    } catch {
      $executed.Add([ordered]@{ name=[string]$action.name; ok=$false; error=$_.Exception.Message })
    }
  }

  return [ordered]@{
    enabled = $true
    performance_profile = 'dual_model_v4'
    planner_model = $model
    plan_valid = $true
    requested = @($plan.actions | Select-Object -First 3)
    executed = @($executed)
  }
}

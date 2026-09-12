param(
  [switch]$Once,
  [int]$PollSeconds = 15,
  [int]$MaxRestartsPer10Minutes = 5
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$startScript = Join-Path $PSScriptRoot 'start-central-workshop.ps1'
$modelManagerScript = Join-Path $PSScriptRoot 'central_model_manager.ps1'
$statusDir = Join-Path $HOME '.central'
$statusPath = Join-Path $statusDir 'supervisor-status.json'
$ollamaUrl = if ([string]::IsNullOrWhiteSpace($env:OLLAMA_URL)) { 'http://127.0.0.1:11434' } else { $env:OLLAMA_URL.TrimEnd('/') }
$fastModel = [Environment]::GetEnvironmentVariable('CENTRAL_OLLAMA_FAST_MODEL')
if ([string]::IsNullOrWhiteSpace($fastModel)) { $fastModel = 'qwen3.5:4b' }

$poolFromEnv = [Environment]::GetEnvironmentVariable('CENTRAL_OLLAMA_MODEL_POOL')
if ([string]::IsNullOrWhiteSpace($poolFromEnv)) {
  $modelPool = @(
    'qwen3.5:4b',
    'qwen3:4b-instruct',
    'qwen3.5:9b',
    'deepseek-r1:7b',
    'qwen2.5-coder:7b',
    'gemma3:4b',
    'nomic-embed-text:latest'
  )
} else {
  $modelPool = @($poolFromEnv -split '[;,]' | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)
}
if ($modelPool -notcontains $fastModel) { $modelPool = @($fastModel) + @($modelPool) }

$restartTimes = [System.Collections.Generic.List[datetime]]::new()

if (-not (Test-Path -LiteralPath $startScript -PathType Leaf)) {
  throw "CENTRAL start script not found: $startScript"
}
if (-not (Test-Path -LiteralPath $statusDir -PathType Container)) {
  New-Item -ItemType Directory -Path $statusDir -Force | Out-Null
}

function Get-CentralOllamaModels {
  try {
    $tags = Invoke-RestMethod -Method Get -Uri "$ollamaUrl/api/tags" -TimeoutSec 4
    return @($tags.models | ForEach-Object { [string]$_.name } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  } catch { return @() }
}

function Test-CentralOllama {
  try {
    $null = Invoke-RestMethod -Method Get -Uri "$ollamaUrl/api/tags" -TimeoutSec 4
    return $true
  } catch { return $false }
}

function Start-CentralOllamaIfNeeded {
  if (Test-CentralOllama) { return $true }
  $ollama = Get-Command ollama -ErrorAction SilentlyContinue
  if ($null -eq $ollama) { return $false }
  try {
    if ($IsWindows) {
      Start-Process -FilePath $ollama.Source -ArgumentList 'serve' -WindowStyle Hidden | Out-Null
    } else {
      Start-Process -FilePath $ollama.Source -ArgumentList 'serve' | Out-Null
    }
    Start-Sleep -Seconds 2
  } catch {}
  return (Test-CentralOllama)
}

function Get-CentralBridgeProcesses {
  if (-not $IsWindows) { return @() }
  try {
    return @(Get-CimInstance Win32_Process -ErrorAction Stop | Where-Object {
      $_.ProcessId -ne $PID -and
      $_.Name -in @('pwsh.exe','powershell.exe') -and
      -not [string]::IsNullOrWhiteSpace($_.CommandLine) -and
      ($_.CommandLine -like '*start-central-workshop.ps1*' -or $_.CommandLine -like '*central_workshop_bridge.ps1*') -and
      $_.CommandLine -notlike '*central_supervisor.ps1*'
    })
  } catch { return @() }
}

function Get-CentralModelManagerProcesses {
  if (-not $IsWindows) { return @() }
  try {
    return @(Get-CimInstance Win32_Process -ErrorAction Stop | Where-Object {
      $_.ProcessId -ne $PID -and
      $_.Name -in @('pwsh.exe','powershell.exe') -and
      -not [string]::IsNullOrWhiteSpace($_.CommandLine) -and
      $_.CommandLine -like '*central_model_manager.ps1*'
    })
  } catch { return @() }
}

function Test-CentralModelInstalled {
  param([string]$Requested,[string[]]$Installed)
  return [bool]($Installed | Where-Object { $_ -eq $Requested -or $_ -like "$Requested*" } | Select-Object -First 1)
}

function Ensure-CentralModelPool {
  if (-not (Test-CentralOllama)) {
    return @{ status='ollama_unavailable'; installed=@(); missing=@($modelPool); pulling=$null; process_ids=@() }
  }

  $installed = @(Get-CentralOllamaModels)
  $missing = [System.Collections.Generic.List[string]]::new()
  foreach ($requested in $modelPool) {
    if (-not (Test-CentralModelInstalled -Requested $requested -Installed $installed)) { $missing.Add($requested) }
  }

  if ($missing.Count -eq 0) {
    return @{ status='ready'; installed=@($installed); missing=@(); pulling=$null; process_ids=@() }
  }

  $existing = Get-CentralModelManagerProcesses
  if ($existing.Count -gt 0) {
    return @{ status='pulling'; installed=@($installed); missing=@($missing); pulling='in_progress'; process_ids=@($existing.ProcessId) }
  }

  if (-not (Test-Path -LiteralPath $modelManagerScript -PathType Leaf)) {
    return @{ status='manager_missing'; installed=@($installed); missing=@($missing); pulling=$null; process_ids=@() }
  }

  $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
  if ($null -eq $pwsh) {
    return @{ status='pwsh_not_found'; installed=@($installed); missing=@($missing); pulling=$null; process_ids=@() }
  }

  # Pull exactly one missing model per manager process. The next supervisor cycles
  # continue the pool after the previous pull exits, avoiding parallel downloads.
  $nextModel = [string]$missing[0]
  try {
    Start-Process -FilePath $pwsh.Source -ArgumentList @(
      '-NoProfile','-ExecutionPolicy','Bypass','-File',$modelManagerScript,'-FastModel',$nextModel
    ) -WindowStyle Hidden | Out-Null
    Start-Sleep -Milliseconds 500
    $started = Get-CentralModelManagerProcesses
    return @{ status='pulling'; installed=@($installed); missing=@($missing); pulling=$nextModel; process_ids=@($started.ProcessId) }
  } catch {
    return @{ status='start_error'; installed=@($installed); missing=@($missing); pulling=$nextModel; error=$_.Exception.Message; process_ids=@() }
  }
}

function Test-CentralRestartBudget {
  $cutoff = (Get-Date).AddMinutes(-10)
  for ($i = $restartTimes.Count - 1; $i -ge 0; $i--) {
    if ($restartTimes[$i] -lt $cutoff) { $restartTimes.RemoveAt($i) }
  }
  return ($restartTimes.Count -lt $MaxRestartsPer10Minutes)
}

function Start-CentralBridgeIfNeeded {
  if (-not $IsWindows) { return @{ running=$false; started=$false; reason='windows_process_watch_only' } }
  $existing = Get-CentralBridgeProcesses
  if ($existing.Count -gt 0) {
    return @{ running=$true; started=$false; process_ids=@($existing.ProcessId) }
  }
  if (-not (Test-CentralRestartBudget)) {
    return @{ running=$false; started=$false; reason='restart_budget_exhausted' }
  }

  $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
  if ($null -eq $pwsh) {
    return @{ running=$false; started=$false; reason='pwsh_not_found' }
  }

  Start-Process -FilePath $pwsh.Source -ArgumentList @(
    '-NoProfile','-ExecutionPolicy','Bypass','-File',$startScript
  ) -WindowStyle Hidden | Out-Null
  $restartTimes.Add((Get-Date))
  Start-Sleep -Seconds 2
  $started = Get-CentralBridgeProcesses
  return @{ running=($started.Count -gt 0); started=$true; process_ids=@($started.ProcessId) }
}

while ($true) {
  $ollamaOk = Start-CentralOllamaIfNeeded
  $poolState = Ensure-CentralModelPool
  $bridge = Start-CentralBridgeIfNeeded

  $fastInstalled = $false
  if ($ollamaOk) { $fastInstalled = Test-CentralModelInstalled -Requested $fastModel -Installed @($poolState.installed) }

  $snapshot = [ordered]@{
    timestamp = [DateTimeOffset]::UtcNow.ToString('o')
    supervisor_pid = $PID
    repo_root = $repoRoot
    ollama = if ($ollamaOk) { 'ok' } else { 'error' }
    fast_model_requested = $fastModel
    fast_model_status = if ($fastInstalled) { 'ready' } else { [string]$poolState.status }
    fast_model_installed = $fastInstalled
    fast_model_active = if ($fastInstalled) { $fastModel } else { $null }
    model_pool_status = [string]$poolState.status
    model_pool_requested = @($modelPool)
    model_pool_installed = @($poolState.installed)
    model_pool_missing = @($poolState.missing)
    model_pool_pulling = $poolState.pulling
    model_manager_process_ids = @($poolState.process_ids)
    bridge_running = [bool]$bridge.running
    bridge_started_this_cycle = [bool]$bridge.started
    bridge_process_ids = @($bridge.process_ids)
    restart_budget_used_10m = $restartTimes.Count
    restart_budget_max_10m = $MaxRestartsPer10Minutes
    note = if ($bridge.reason) { [string]$bridge.reason } elseif ($poolState.error) { [string]$poolState.error } else { $null }
  }
  $snapshot | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $statusPath -Encoding UTF8

  if ($Once) { break }
  Start-Sleep -Seconds ([Math]::Max(10,$PollSeconds))
}

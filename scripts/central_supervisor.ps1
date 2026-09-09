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
if ([string]::IsNullOrWhiteSpace($fastModel)) { $fastModel = 'qwen3:1.7b' }
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

function Ensure-CentralFastModel {
  if (-not (Test-CentralOllama)) {
    return @{ status='ollama_unavailable'; installed=$false; process_ids=@() }
  }

  $models = Get-CentralOllamaModels
  $match = $models | Where-Object { $_ -eq $fastModel -or $_ -like "$fastModel*" } | Select-Object -First 1
  if (-not [string]::IsNullOrWhiteSpace($match)) {
    return @{ status='ready'; installed=$true; model=[string]$match; process_ids=@() }
  }

  $existing = Get-CentralModelManagerProcesses
  if ($existing.Count -gt 0) {
    return @{ status='pulling'; installed=$false; model=$fastModel; process_ids=@($existing.ProcessId) }
  }

  if (-not (Test-Path -LiteralPath $modelManagerScript -PathType Leaf)) {
    return @{ status='manager_missing'; installed=$false; model=$fastModel; process_ids=@() }
  }

  $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
  if ($null -eq $pwsh) {
    return @{ status='pwsh_not_found'; installed=$false; model=$fastModel; process_ids=@() }
  }

  try {
    Start-Process -FilePath $pwsh.Source -ArgumentList @(
      '-NoProfile','-ExecutionPolicy','Bypass','-File',$modelManagerScript,'-FastModel',$fastModel
    ) -WindowStyle Hidden | Out-Null
    Start-Sleep -Milliseconds 500
    $started = Get-CentralModelManagerProcesses
    return @{ status='pulling'; installed=$false; model=$fastModel; process_ids=@($started.ProcessId) }
  } catch {
    return @{ status='start_error'; installed=$false; model=$fastModel; error=$_.Exception.Message; process_ids=@() }
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
  $fastModelState = Ensure-CentralFastModel
  $bridge = Start-CentralBridgeIfNeeded

  $snapshot = [ordered]@{
    timestamp = [DateTimeOffset]::UtcNow.ToString('o')
    supervisor_pid = $PID
    repo_root = $repoRoot
    ollama = if ($ollamaOk) { 'ok' } else { 'error' }
    fast_model_requested = $fastModel
    fast_model_status = [string]$fastModelState.status
    fast_model_installed = [bool]$fastModelState.installed
    fast_model_active = if ($fastModelState.model) { [string]$fastModelState.model } else { $null }
    model_manager_process_ids = @($fastModelState.process_ids)
    bridge_running = [bool]$bridge.running
    bridge_started_this_cycle = [bool]$bridge.started
    bridge_process_ids = @($bridge.process_ids)
    restart_budget_used_10m = $restartTimes.Count
    restart_budget_max_10m = $MaxRestartsPer10Minutes
    note = if ($bridge.reason) { [string]$bridge.reason } elseif ($fastModelState.error) { [string]$fastModelState.error } else { $null }
  }
  $snapshot | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $statusPath -Encoding UTF8

  if ($Once) { break }
  Start-Sleep -Seconds ([Math]::Max(10,$PollSeconds))
}

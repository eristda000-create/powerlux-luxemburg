param(
  [switch]$Once,
  [int]$PollSeconds = 15,
  [int]$MaxRestartsPer10Minutes = 5
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$startScript = Join-Path $PSScriptRoot 'start-central-workshop.ps1'
$statusDir = Join-Path $HOME '.central'
$statusPath = Join-Path $statusDir 'supervisor-status.json'
$ollamaUrl = if ([string]::IsNullOrWhiteSpace($env:OLLAMA_URL)) { 'http://127.0.0.1:11434' } else { $env:OLLAMA_URL.TrimEnd('/') }
$restartTimes = [System.Collections.Generic.List[datetime]]::new()

if (-not (Test-Path -LiteralPath $startScript -PathType Leaf)) {
  throw "CENTRAL start script not found: $startScript"
}
if (-not (Test-Path -LiteralPath $statusDir -PathType Container)) {
  New-Item -ItemType Directory -Path $statusDir -Force | Out-Null
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
  $bridge = Start-CentralBridgeIfNeeded

  $snapshot = [ordered]@{
    timestamp = [DateTimeOffset]::UtcNow.ToString('o')
    supervisor_pid = $PID
    repo_root = $repoRoot
    ollama = if ($ollamaOk) { 'ok' } else { 'error' }
    bridge_running = [bool]$bridge.running
    bridge_started_this_cycle = [bool]$bridge.started
    bridge_process_ids = @($bridge.process_ids)
    restart_budget_used_10m = $restartTimes.Count
    restart_budget_max_10m = $MaxRestartsPer10Minutes
    note = if ($bridge.reason) { [string]$bridge.reason } else { $null }
  }
  $snapshot | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $statusPath -Encoding UTF8

  if ($Once) { break }
  Start-Sleep -Seconds ([Math]::Max(10,$PollSeconds))
}

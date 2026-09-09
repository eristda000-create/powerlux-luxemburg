param(
  [switch]$LocalOnly
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$startScript = Join-Path $PSScriptRoot 'start-central-workshop.ps1'
$agentScript = Join-Path $PSScriptRoot 'central_local_agent_team.ps1'
$autonomyScript = Join-Path $PSScriptRoot 'central_local_agent_autonomy.ps1'
$supervisorStatus = Join-Path (Join-Path $HOME '.central') 'supervisor-status.json'
$tokenCache = [Environment]::GetEnvironmentVariable('CENTRAL_WORKSHOP_TOKEN_CACHE')
if ([string]::IsNullOrWhiteSpace($tokenCache)) {
  $tokenCache = Join-Path (Join-Path $HOME '.central') 'workshop-auth.json'
}
$ollamaUrl = [Environment]::GetEnvironmentVariable('OLLAMA_URL')
if ([string]::IsNullOrWhiteSpace($ollamaUrl)) { $ollamaUrl = 'http://127.0.0.1:11434' }
$ollamaUrl = $ollamaUrl.TrimEnd('/')

$gitOk = $false
$ollamaOk = $false
$remoteOk = $LocalOnly

$checks = [ordered]@{
  timestamp = [DateTimeOffset]::UtcNow.ToString('o')
  repo_root = $repoRoot
  pwsh = $PSVersionTable.PSVersion.ToString()
  git = 'not_checked'
  ollama = 'not_checked'
  ollama_models = @()
  local_agent_team_source = if (Test-Path -LiteralPath $agentScript -PathType Leaf) { 'present' } else { 'missing' }
  local_autonomy_source = if (Test-Path -LiteralPath $autonomyScript -PathType Leaf) { 'present' } else { 'missing' }
  supervisor = 'not_detected'
  supervisor_pid = $null
  supervisor_bridge_running = $null
  windows_dpapi_session_cache = if ($IsWindows -and (Test-Path -LiteralPath $tokenCache -PathType Leaf)) { 'present' } else { 'absent' }
  remote_bridge = if ($LocalOnly) { 'not_tested' } else { 'pending' }
}

try {
  $git = (& git --version 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -eq 0) {
    $gitOk = $true
    $checks.git = $git
  } else {
    $checks.git = $git
  }
} catch { $checks.git = $_.Exception.Message }

try {
  $tags = Invoke-RestMethod -Method Get -Uri "$ollamaUrl/api/tags" -TimeoutSec 5
  $ollamaOk = $true
  $checks.ollama = 'ok'
  $checks.ollama_models = @($tags.models | ForEach-Object { $_.name })
} catch { $checks.ollama = $_.Exception.Message }

if (Test-Path -LiteralPath $supervisorStatus -PathType Leaf) {
  try {
    $s = Get-Content -LiteralPath $supervisorStatus -Raw | ConvertFrom-Json
    $age = [DateTimeOffset]::UtcNow - [DateTimeOffset]::Parse([string]$s.timestamp)
    $checks.supervisor_pid = $s.supervisor_pid
    $checks.supervisor_bridge_running = [bool]$s.bridge_running
    if ($age.TotalMinutes -le 2 -and [bool]$s.bridge_running) { $checks.supervisor = 'ok' }
    else { $checks.supervisor = 'stale' }
  } catch { $checks.supervisor = 'error' }
}

if (-not $LocalOnly) {
  if (-not (Test-Path -LiteralPath $startScript -PathType Leaf)) {
    $checks.remote_bridge = 'start_script_missing'
  } else {
    & $startScript -Once
    $remoteOk = $LASTEXITCODE -eq 0
    $checks.remote_bridge = if ($remoteOk) { 'verified' } else { 'not_verified' }
  }
}

$checks | ConvertTo-Json -Depth 6

if (-not $gitOk -or -not $ollamaOk -or -not $remoteOk) {
  exit 1
}

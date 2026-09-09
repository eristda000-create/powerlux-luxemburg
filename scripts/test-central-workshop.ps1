param(
  [switch]$LocalOnly
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$startScript = Join-Path $PSScriptRoot 'start-central-workshop.ps1'
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

param(
  [switch]$Remove,
  [switch]$SkipHandshake
)

$ErrorActionPreference = 'Stop'

if (-not $IsWindows) {
  throw 'This autostart installer is for Windows. The bridge runner itself remains cross-platform.'
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$startScript = Join-Path $PSScriptRoot 'start-central-workshop.ps1'
$supervisorScript = Join-Path $PSScriptRoot 'central_supervisor.ps1'
$pwsh = Get-Command pwsh -ErrorAction Stop
$runKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$valueName = 'CENTRALWorkshopBridge'
$tokenCache = Join-Path (Join-Path $HOME '.central') 'workshop-auth.json'

if ($Remove) {
  if (Test-Path $runKey) {
    Remove-ItemProperty -Path $runKey -Name $valueName -ErrorAction SilentlyContinue
  }
  Write-Host 'CENTRAL Workshop autostart removed for the current Windows user.'
  exit 0
}

if (-not (Test-Path -LiteralPath $startScript -PathType Leaf)) {
  throw "Start script not found: $startScript"
}
if (-not (Test-Path -LiteralPath $supervisorScript -PathType Leaf)) {
  throw "Supervisor script not found: $supervisorScript"
}

if (-not $SkipHandshake -and -not (Test-Path -LiteralPath $tokenCache -PathType Leaf)) {
  Write-Host 'No encrypted Workshop session exists yet. Running the first authenticated handshake now.'
  & $startScript -Once
  if ($LASTEXITCODE -ne 0) {
    throw 'First Workshop handshake did not verify. Autostart was not installed.'
  }
}

if (-not (Test-Path -LiteralPath $tokenCache -PathType Leaf)) {
  throw 'No Windows-DPAPI Workshop session cache exists. Run start-central-workshop.ps1 once interactively first.'
}

if (-not (Test-Path $runKey)) {
  New-Item -Path $runKey -Force | Out-Null
}

$command = '"' + $pwsh.Source + '" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $supervisorScript + '"'
New-ItemProperty -Path $runKey -Name $valueName -Value $command -PropertyType String -Force | Out-Null

Write-Host 'CENTRAL Workshop supervisor autostart installed for the current Windows user.'
Write-Host "Repository: $repoRoot"
Write-Host "Startup command: $command"
Write-Host 'The supervisor keeps Ollama and the CENTRAL bridge available and uses a restart budget to avoid crash loops.'
Write-Host 'The stored Supabase refresh token is DPAPI-encrypted for this Windows user; no password is stored by this installer.'

param(
  [string]$FastModel = $env:CENTRAL_OLLAMA_FAST_MODEL
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($FastModel)) { $FastModel = 'qwen3:1.7b' }

$statusDir = Join-Path $HOME '.central'
$statusPath = Join-Path $statusDir 'model-manager-status.json'
$ollamaUrl = if ([string]::IsNullOrWhiteSpace($env:OLLAMA_URL)) { 'http://127.0.0.1:11434' } else { $env:OLLAMA_URL.TrimEnd('/') }

if (-not (Test-Path -LiteralPath $statusDir -PathType Container)) {
  New-Item -ItemType Directory -Path $statusDir -Force | Out-Null
}

function Write-ModelManagerStatus {
  param([string]$Status,[string]$Message)
  [ordered]@{
    timestamp = [DateTimeOffset]::UtcNow.ToString('o')
    pid = $PID
    model = $FastModel
    status = $Status
    message = $Message
  } | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $statusPath -Encoding UTF8
}

function Test-FastModelInstalled {
  try {
    $tags = Invoke-RestMethod -Method Get -Uri "$ollamaUrl/api/tags" -TimeoutSec 5
    $names = @($tags.models | ForEach-Object { [string]$_.name })
    return [bool]($names | Where-Object { $_ -eq $FastModel -or $_ -like "$FastModel*" } | Select-Object -First 1)
  } catch { return $false }
}

if (Test-FastModelInstalled) {
  Write-ModelManagerStatus -Status 'ready' -Message 'Fast support model is already installed.'
  exit 0
}

$ollama = Get-Command ollama -ErrorAction SilentlyContinue
if ($null -eq $ollama) {
  Write-ModelManagerStatus -Status 'error' -Message 'Ollama executable not found.'
  exit 1
}

Write-ModelManagerStatus -Status 'pulling' -Message 'Downloading bounded CENTRAL support model.'
try {
  $output = (& $ollama.Source pull $FastModel 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) {
    Write-ModelManagerStatus -Status 'error' -Message ("ollama pull failed: " + $output)
    exit 1
  }
  if (-not (Test-FastModelInstalled)) {
    Write-ModelManagerStatus -Status 'error' -Message 'ollama pull returned without the model appearing in /api/tags.'
    exit 1
  }
  Write-ModelManagerStatus -Status 'ready' -Message 'Fast support model installed and visible to Ollama.'
  exit 0
} catch {
  Write-ModelManagerStatus -Status 'error' -Message $_.Exception.Message
  exit 1
}

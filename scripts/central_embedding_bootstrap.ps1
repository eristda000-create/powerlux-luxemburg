param(
  [string]$Model = $env:CENTRAL_OLLAMA_EMBED_MODEL
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($Model)) { $Model = 'nomic-embed-text' }

$statusDir = Join-Path $HOME '.central'
$statusPath = Join-Path $statusDir 'embedding-model-status.json'
$ollamaUrl = if ([string]::IsNullOrWhiteSpace($env:OLLAMA_URL)) { 'http://127.0.0.1:11434' } else { $env:OLLAMA_URL.TrimEnd('/') }

if (-not (Test-Path -LiteralPath $statusDir -PathType Container)) {
  New-Item -ItemType Directory -Path $statusDir -Force | Out-Null
}

function Write-EmbeddingStatus([string]$Status,[string]$Message) {
  [ordered]@{
    timestamp = [DateTimeOffset]::UtcNow.ToString('o')
    pid = $PID
    model = $Model
    status = $Status
    message = $Message
  } | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $statusPath -Encoding UTF8
}

function Test-EmbeddingModelInstalled {
  try {
    $tags = Invoke-RestMethod -Method Get -Uri "$ollamaUrl/api/tags" -TimeoutSec 5
    $names = @($tags.models | ForEach-Object { [string]$_.name })
    return [bool]($names | Where-Object { $_ -eq $Model -or $_ -like "$Model*" } | Select-Object -First 1)
  } catch { return $false }
}

if (Test-EmbeddingModelInstalled) {
  Write-EmbeddingStatus 'ready' 'Embedding model is already installed.'
  exit 0
}

$ollama = Get-Command ollama -ErrorAction SilentlyContinue
if ($null -eq $ollama) {
  Write-EmbeddingStatus 'error' 'Ollama executable not found.'
  exit 1
}

Write-EmbeddingStatus 'pulling' 'Downloading CENTRAL embedding model.'
try {
  $output = (& $ollama.Source pull $Model 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) {
    Write-EmbeddingStatus 'error' ("ollama pull failed: " + $output)
    exit 1
  }
  if (-not (Test-EmbeddingModelInstalled)) {
    Write-EmbeddingStatus 'error' 'ollama pull returned without the model appearing in /api/tags.'
    exit 1
  }
  Write-EmbeddingStatus 'ready' 'Embedding model installed and visible to Ollama.'
  exit 0
} catch {
  Write-EmbeddingStatus 'error' $_.Exception.Message
  exit 1
}

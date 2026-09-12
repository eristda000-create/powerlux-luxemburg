Set-StrictMode -Version Latest

function Start-CentralOllamaModelPull {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)][string]$Model,
    [string]$OllamaUrl='http://127.0.0.1:11434'
  )

  # Bounded model allowlist for the verified 13.94 GB CENTRAL desktop.
  # Keep individual models small enough to run one-at-a-time on this node.
  $allowlist = @(
    'nomic-embed-text',
    'qwen3.5:4b',
    'qwen3.5:9b',
    'qwen3.5:27b',
    'qwen3:14b',
    'qwen3:30b',
    'deepseek-r1:7b',
    'qwen2.5-coder:7b',
    'gemma3:4b'
  )
  if ($Model -notin $allowlist) { throw "Model is not in CENTRAL allowlist: $Model" }

  try {
    $tags = Invoke-RestMethod -Method Get -Uri "$($OllamaUrl.TrimEnd('/'))/api/tags" -TimeoutSec 8
    $names = @($tags.models | ForEach-Object { [string]$_.name })
    if ($names -contains $Model -or ($names | Where-Object { $_ -like "$Model*" } | Select-Object -First 1)) {
      return [ordered]@{ model=$Model; status='already_installed'; started=$false }
    }
  } catch {}

  $ollama = Get-Command ollama -ErrorAction Stop
  $args = @('pull',$Model)
  $proc = if ($IsWindows) {
    Start-Process -FilePath $ollama.Source -ArgumentList $args -WindowStyle Hidden -PassThru
  } else {
    Start-Process -FilePath $ollama.Source -ArgumentList $args -PassThru
  }

  return [ordered]@{
    model = $Model
    status = 'pull_started'
    started = $true
    pid = $proc.Id
    check = 'Use hardware_inventory or Ollama /api/tags to confirm completion before routing jobs to this model.'
  }
}

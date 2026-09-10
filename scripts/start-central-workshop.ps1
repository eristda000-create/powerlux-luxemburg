param(
  [switch]$Once,
  [int]$PollSeconds = 30
)

$ErrorActionPreference = 'Stop'

$env:CENTRAL_SUPABASE_URL = 'https://fgkowgpauqexcwwtrxyd.supabase.co'
$env:CENTRAL_SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_EsHCY_P-NxhOMNHRQCZqnw_nPPoCjqr'

$repoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($env:CENTRAL_WORKDIR)) {
  $env:CENTRAL_WORKDIR = $repoRoot
}

if ([string]::IsNullOrWhiteSpace($env:OLLAMA_URL)) {
  $env:OLLAMA_URL = 'http://127.0.0.1:11434'
}

$obsidianConnector = Join-Path $PSScriptRoot 'central_obsidian_connect.ps1'
if (Test-Path -LiteralPath $obsidianConnector -PathType Leaf) {
  try {
    $obsidianState = & $obsidianConnector
    if ($null -ne $obsidianState) {
      if ($obsidianState.status -in @('connected_existing','connected_auto')) {
        Write-Host "Obsidian connected: $($obsidianState.vault)"
      } elseif ($obsidianState.status -eq 'multiple_candidates') {
        Write-Warning "Multiple Obsidian vaults found. CENTRAL will not guess. Candidates are stored in ~/.central/obsidian-discovery.json."
      } else {
        Write-Host 'Obsidian vault not found in the approved discovery roots.'
      }
    }
  } catch {
    Write-Warning "Obsidian autodiscovery failed safely: $($_.Exception.Message)"
  }
}

$obsidianMount = Join-Path $PSScriptRoot 'central_obsidian_mount.ps1'
if ((Test-Path -LiteralPath $obsidianMount -PathType Leaf) -and -not [string]::IsNullOrWhiteSpace($env:OBSIDIAN_VAULT)) {
  try {
    $mountState = & $obsidianMount -Vault $env:OBSIDIAN_VAULT -RepoRoot $repoRoot
    if ($null -ne $mountState) {
      if ([bool]$mountState.mounted) {
        Write-Host "CENTRAL knowledge mounted in Obsidian: $($mountState.mount_path)"
      } elseif ($mountState.status -eq 'conflict_existing_path') {
        Write-Warning 'Obsidian/CENTRAL already exists and was not changed. See ~/.central/obsidian-knowledge-mount.json.'
      } else {
        Write-Warning "CENTRAL knowledge mount not active: $($mountState.status)"
      }
    }
  } catch {
    Write-Warning "CENTRAL knowledge mount failed safely: $($_.Exception.Message)"
  }
}

function Test-Ollama {
  try {
    $null = Invoke-RestMethod -Method Get -Uri "$($env:OLLAMA_URL.TrimEnd('/'))/api/tags" -TimeoutSec 4
    return $true
  } catch { return $false }
}

if (-not (Test-Ollama)) {
  $ollama = Get-Command ollama -ErrorAction SilentlyContinue
  if ($null -ne $ollama) {
    Write-Host 'Ollama is installed but not responding. Starting ollama serve...'
    if ($IsWindows) {
      Start-Process -FilePath $ollama.Source -ArgumentList 'serve' -WindowStyle Hidden | Out-Null
    } else {
      Start-Process -FilePath $ollama.Source -ArgumentList 'serve' | Out-Null
    }
    Start-Sleep -Seconds 2
  }
}

if (-not (Test-Ollama)) {
  Write-Warning 'Ollama is not reachable. The bridge will start, but runtime verification will remain false until Ollama responds.'
}

$runner = Join-Path $PSScriptRoot 'central_workshop_bridge.ps1'
if (-not (Test-Path -LiteralPath $runner -PathType Leaf)) {
  throw "Bridge runner not found: $runner"
}

& $runner -Once:$Once -PollSeconds $PollSeconds

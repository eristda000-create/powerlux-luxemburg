param(
  [string]$Vault,
  [string]$RepoRoot
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($Vault)) {
  $Vault = [Environment]::GetEnvironmentVariable('OBSIDIAN_VAULT')
}
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
  $RepoRoot = Split-Path -Parent $PSScriptRoot
}

function Save-CentralObsidianMountState([hashtable]$State) {
  $dir = Join-Path $HOME '.central'
  if (-not (Test-Path -LiteralPath $dir -PathType Container)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
  $path = Join-Path $dir 'obsidian-knowledge-mount.json'
  $State | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $path -Encoding UTF8
  return $path
}

if ([string]::IsNullOrWhiteSpace($Vault) -or -not (Test-Path -LiteralPath $Vault -PathType Container)) {
  $state = [ordered]@{ status='vault_not_configured'; mounted=$false; checked_at=[DateTimeOffset]::UtcNow.ToString('o') }
  $null = Save-CentralObsidianMountState $state
  return $state
}
if (-not (Test-Path -LiteralPath (Join-Path $Vault '.obsidian') -PathType Container)) {
  $state = [ordered]@{ status='not_an_obsidian_vault'; mounted=$false; vault=$Vault; checked_at=[DateTimeOffset]::UtcNow.ToString('o') }
  $null = Save-CentralObsidianMountState $state
  return $state
}

$repoFull = [IO.Path]::GetFullPath($RepoRoot).TrimEnd([char[]]'\/')
$knowledge = Join-Path $repoFull 'knowledge'
if (-not (Test-Path -LiteralPath $knowledge -PathType Container)) {
  $state = [ordered]@{ status='knowledge_directory_missing'; mounted=$false; vault=$Vault; repo_root=$repoFull; checked_at=[DateTimeOffset]::UtcNow.ToString('o') }
  $null = Save-CentralObsidianMountState $state
  return $state
}

$link = Join-Path $Vault 'CENTRAL'
$knowledgeFull = [IO.Path]::GetFullPath($knowledge).TrimEnd([char[]]'\/')

if (Test-Path -LiteralPath $link) {
  $item = Get-Item -LiteralPath $link -Force
  $targetResolved = $null
  try {
    $targets = @($item.Target)
    if ($targets.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace([string]$targets[0])) {
      $targetResolved = [IO.Path]::GetFullPath([string]$targets[0]).TrimEnd([char[]]'\/')
    }
  } catch {}

  if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -and $targetResolved -and $targetResolved.Equals($knowledgeFull,[StringComparison]::OrdinalIgnoreCase)) {
    $state = [ordered]@{ status='mounted_existing'; mounted=$true; vault=$Vault; mount_path=$link; target=$knowledgeFull; checked_at=[DateTimeOffset]::UtcNow.ToString('o') }
    $null = Save-CentralObsidianMountState $state
    return $state
  }

  $state = [ordered]@{
    status='conflict_existing_path'
    mounted=$false
    vault=$Vault
    mount_path=$link
    expected_target=$knowledgeFull
    note='CENTRAL path already exists and was not changed.'
    checked_at=[DateTimeOffset]::UtcNow.ToString('o')
  }
  $null = Save-CentralObsidianMountState $state
  return $state
}

if (-not $IsWindows) {
  $state = [ordered]@{ status='windows_junction_required'; mounted=$false; vault=$Vault; mount_path=$link; target=$knowledgeFull; checked_at=[DateTimeOffset]::UtcNow.ToString('o') }
  $null = Save-CentralObsidianMountState $state
  return $state
}

try {
  $created = New-Item -ItemType Junction -Path $link -Target $knowledgeFull -ErrorAction Stop
  $state = [ordered]@{
    status='mounted_created'
    mounted=$true
    vault=$Vault
    mount_path=$created.FullName
    target=$knowledgeFull
    checked_at=[DateTimeOffset]::UtcNow.ToString('o')
  }
} catch {
  $state = [ordered]@{
    status='mount_failed'
    mounted=$false
    vault=$Vault
    mount_path=$link
    target=$knowledgeFull
    error=$_.Exception.Message
    checked_at=[DateTimeOffset]::UtcNow.ToString('o')
  }
}

$null = Save-CentralObsidianMountState $state
return $state

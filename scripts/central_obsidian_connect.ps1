param(
  [string[]]$Roots,
  [switch]$NoPersist
)

$ErrorActionPreference = 'Stop'

function Get-CentralDefaultObsidianRoots {
  $candidates = @(
    (Join-Path $HOME 'Documents'),
    (Join-Path $HOME 'Desktop'),
    (Join-Path $HOME 'OneDrive'),
    (Join-Path (Join-Path $HOME 'OneDrive') 'Documents')
  )
  return @($candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Container } | Select-Object -Unique)
}

function Test-CentralObsidianVault([string]$Path) {
  if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
  if (-not (Test-Path -LiteralPath $Path -PathType Container)) { return $false }
  return (Test-Path -LiteralPath (Join-Path $Path '.obsidian') -PathType Container)
}

function Find-CentralObsidianVaults([string[]]$SearchRoots) {
  $found = [System.Collections.Generic.List[string]]::new()
  foreach ($root in @($SearchRoots | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)) {
    if (-not (Test-Path -LiteralPath $root -PathType Container)) { continue }
    try {
      Get-ChildItem -LiteralPath $root -Directory -Filter '.obsidian' -Recurse -Force -ErrorAction SilentlyContinue |
        ForEach-Object {
          $vault = $_.Parent.FullName
          if (-not [string]::IsNullOrWhiteSpace($vault) -and -not $found.Contains($vault)) {
            $found.Add($vault)
          }
        }
    } catch {}
  }
  return @($found | Sort-Object -Unique)
}

function Save-CentralObsidianDiscovery([hashtable]$State) {
  $dir = Join-Path $HOME '.central'
  if (-not (Test-Path -LiteralPath $dir -PathType Container)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
  $path = Join-Path $dir 'obsidian-discovery.json'
  $State | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $path -Encoding UTF8
  return $path
}

$existingProcess = [Environment]::GetEnvironmentVariable('OBSIDIAN_VAULT','Process')
$existingUser = if ($IsWindows) { [Environment]::GetEnvironmentVariable('OBSIDIAN_VAULT','User') } else { $null }

foreach ($candidate in @($existingProcess,$existingUser)) {
  if (Test-CentralObsidianVault $candidate) {
    $env:OBSIDIAN_VAULT = $candidate
    $state = [ordered]@{
      status = 'connected_existing'
      vault = $candidate
      candidates = @($candidate)
      persisted = (-not $NoPersist)
      detected_at = [DateTimeOffset]::UtcNow.ToString('o')
    }
    if (-not $NoPersist -and $IsWindows) {
      [Environment]::SetEnvironmentVariable('OBSIDIAN_VAULT',$candidate,'User')
    }
    $null = Save-CentralObsidianDiscovery $state
    return $state
  }
}

$searchRoots = if ($Roots -and $Roots.Count -gt 0) { @($Roots) } else { @(Get-CentralDefaultObsidianRoots) }
$vaults = @(Find-CentralObsidianVaults $searchRoots)

if ($vaults.Count -eq 1) {
  $vault = $vaults[0]
  $env:OBSIDIAN_VAULT = $vault
  if (-not $NoPersist -and $IsWindows) {
    [Environment]::SetEnvironmentVariable('OBSIDIAN_VAULT',$vault,'User')
  }
  $state = [ordered]@{
    status = 'connected_auto'
    vault = $vault
    candidates = $vaults
    search_roots = $searchRoots
    persisted = (-not $NoPersist)
    detected_at = [DateTimeOffset]::UtcNow.ToString('o')
  }
  $null = Save-CentralObsidianDiscovery $state
  return $state
}

$status = if ($vaults.Count -eq 0) { 'not_found' } else { 'multiple_candidates' }
$state = [ordered]@{
  status = $status
  vault = $null
  candidates = $vaults
  search_roots = $searchRoots
  persisted = $false
  detected_at = [DateTimeOffset]::UtcNow.ToString('o')
}
$null = Save-CentralObsidianDiscovery $state
return $state

$ErrorActionPreference = 'Stop'

$connector = Join-Path $PSScriptRoot 'central_obsidian_connect.ps1'
if (-not (Test-Path -LiteralPath $connector -PathType Leaf)) { throw 'connector missing' }

$originalProcess = [Environment]::GetEnvironmentVariable('OBSIDIAN_VAULT','Process')
try {
  [Environment]::SetEnvironmentVariable('OBSIDIAN_VAULT',$null,'Process')

  $root0 = Join-Path ([IO.Path]::GetTempPath()) ("central-obsidian-none-" + [guid]::NewGuid())
  New-Item -ItemType Directory -Path $root0 -Force | Out-Null
  $none = & $connector -Roots @($root0) -NoPersist
  if ($none.status -ne 'not_found') { throw "expected not_found, got $($none.status)" }

  $root1 = Join-Path ([IO.Path]::GetTempPath()) ("central-obsidian-one-" + [guid]::NewGuid())
  $vault1 = Join-Path $root1 'VaultA'
  New-Item -ItemType Directory -Path (Join-Path $vault1 '.obsidian') -Force | Out-Null
  $one = & $connector -Roots @($root1) -NoPersist
  if ($one.status -ne 'connected_auto') { throw "expected connected_auto, got $($one.status)" }
  if ([IO.Path]::GetFullPath([string]$one.vault) -ne [IO.Path]::GetFullPath($vault1)) { throw 'wrong single vault selected' }

  [Environment]::SetEnvironmentVariable('OBSIDIAN_VAULT',$null,'Process')
  $root2 = Join-Path ([IO.Path]::GetTempPath()) ("central-obsidian-multi-" + [guid]::NewGuid())
  foreach ($name in @('VaultA','VaultB')) {
    New-Item -ItemType Directory -Path (Join-Path (Join-Path $root2 $name) '.obsidian') -Force | Out-Null
  }
  $multi = & $connector -Roots @($root2) -NoPersist
  if ($multi.status -ne 'multiple_candidates') { throw "expected multiple_candidates, got $($multi.status)" }
  if (@($multi.candidates).Count -ne 2) { throw 'expected two candidates' }

  Write-Host 'PASS: Obsidian autodiscovery handles 0 / 1 / multiple vaults safely.'
} finally {
  [Environment]::SetEnvironmentVariable('OBSIDIAN_VAULT',$originalProcess,'Process')
  foreach ($p in @($root0,$root1,$root2)) {
    if ($p -and (Test-Path -LiteralPath $p)) { Remove-Item -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue }
  }
}

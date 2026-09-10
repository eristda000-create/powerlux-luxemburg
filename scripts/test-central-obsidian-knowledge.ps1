$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path $PSScriptRoot 'central_obsidian_mount.ps1'
if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) { throw 'mount script missing' }

$root = Join-Path ([IO.Path]::GetTempPath()) ('central-obsidian-knowledge-' + [guid]::NewGuid().ToString('N'))
$vault = Join-Path $root 'Vault'
$repo = Join-Path $root 'Repo'
$knowledge = Join-Path $repo 'knowledge'
New-Item -ItemType Directory -Path (Join-Path $vault '.obsidian') -Force | Out-Null
New-Item -ItemType Directory -Path $knowledge -Force | Out-Null
Set-Content -LiteralPath (Join-Path $knowledge '00_HOME.md') -Value '# test' -Encoding UTF8

try {
  $first = & $scriptPath -Vault $vault -RepoRoot $repo
  if (-not [bool]$first.mounted) { throw "first mount failed: $($first.status)" }
  $link = Join-Path $vault 'CENTRAL'
  if (-not (Test-Path -LiteralPath (Join-Path $link '00_HOME.md') -PathType Leaf)) { throw 'mounted knowledge is not readable through vault/CENTRAL' }

  $second = & $scriptPath -Vault $vault -RepoRoot $repo
  if (-not [bool]$second.mounted -or $second.status -ne 'mounted_existing') { throw "idempotent mount failed: $($second.status)" }

  Remove-Item -LiteralPath $link -Force
  New-Item -ItemType Directory -Path $link -Force | Out-Null
  Set-Content -LiteralPath (Join-Path $link 'user-note.md') -Value 'keep me' -Encoding UTF8
  $conflict = & $scriptPath -Vault $vault -RepoRoot $repo
  if ([bool]$conflict.mounted -or $conflict.status -ne 'conflict_existing_path') { throw 'existing user path was not blocked' }
  if (-not (Test-Path -LiteralPath (Join-Path $link 'user-note.md') -PathType Leaf)) { throw 'existing user content was modified' }

  Write-Host 'PASS: safe knowledge mount, idempotence and existing-path protection'
} finally {
  if (Test-Path -LiteralPath $root) { Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue }
}

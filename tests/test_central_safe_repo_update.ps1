$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot '..' 'scripts' 'central_safe_repo_update.ps1')

function Invoke-Git([string]$Dir, [Parameter(ValueFromRemainingArguments=$true)][string[]]$Args) {
  $output = (& git -C $Dir @Args 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) { throw "git $($Args -join ' ') failed: $output" }
  return $output
}

function Assert-True([bool]$Condition, [string]$Message) {
  if (-not $Condition) { throw "ASSERT FAILED: $Message" }
}

function Assert-Throws([scriptblock]$Action, [string]$Contains) {
  try {
    & $Action
    throw "ASSERT FAILED: expected exception containing '$Contains'"
  } catch {
    if ($_.Exception.Message -like 'ASSERT FAILED:*') { throw }
    if ($_.Exception.Message -notlike "*$Contains*") {
      throw "ASSERT FAILED: expected exception containing '$Contains', got '$($_.Exception.Message)'"
    }
  } finally {
    $global:LASTEXITCODE = 0
  }
}

$root = Join-Path ([IO.Path]::GetTempPath()) ("central-safe-repo-update-" + [guid]::NewGuid().ToString('N'))
$remote = Join-Path $root 'remote.git'
$seed = Join-Path $root 'seed'
$work = Join-Path $root 'work'

try {
  New-Item -ItemType Directory -Path $root -Force | Out-Null
  & git init --bare $remote | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'Unable to create bare test remote.' }

  New-Item -ItemType Directory -Path $seed -Force | Out-Null
  & git -C $seed init -b main | Out-Null
  Invoke-Git $seed config user.email 'central-test@example.invalid' | Out-Null
  Invoke-Git $seed config user.name 'CENTRAL Test' | Out-Null

  New-Item -ItemType Directory -Path (Join-Path $seed 'knowledge') -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $seed 'scripts') -Force | Out-Null
  Set-Content -LiteralPath (Join-Path $seed 'knowledge/state.txt') -Value 'v1' -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $seed 'scripts/central_workshop_bridge.ps1') -Value '# runtime v1' -Encoding UTF8
  Invoke-Git $seed add knowledge/state.txt scripts/central_workshop_bridge.ps1 | Out-Null
  Invoke-Git $seed commit -m 'seed v1' | Out-Null
  Invoke-Git $seed remote add origin $remote | Out-Null
  Invoke-Git $seed push -u origin main | Out-Null
  & git --git-dir $remote symbolic-ref HEAD refs/heads/main
  if ($LASTEXITCODE -ne 0) { throw 'Unable to point bare remote HEAD at main.' }

  & git clone $remote $work | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'Unable to clone test remote.' }
  Invoke-Git $work config user.email 'central-test@example.invalid' | Out-Null
  Invoke-Git $work config user.name 'CENTRAL Test' | Out-Null

  # Knowledge-only fast-forward: repository changes, runtime does not need restart.
  Set-Content -LiteralPath (Join-Path $seed 'knowledge/state.txt') -Value 'v2' -Encoding UTF8
  Invoke-Git $seed add knowledge/state.txt | Out-Null
  Invoke-Git $seed commit -m 'knowledge v2' | Out-Null
  Invoke-Git $seed push origin main | Out-Null

  $knowledgeUpdate = Invoke-CentralSafeRepoUpdate -WorkDir $work -CanonicalRemote $remote
  Assert-True ([bool]$knowledgeUpdate.changed) 'knowledge fast-forward should report changed=true to normal callers'
  Assert-True ([bool]$knowledgeUpdate.repo_changed) 'knowledge fast-forward should report repo_changed=true'
  Assert-True (-not [bool]$knowledgeUpdate.restart_required) 'knowledge-only update must not request runtime restart'
  Assert-True ($knowledgeUpdate.status -eq 'fast_forwarded') 'knowledge update should report fast_forwarded'
  Assert-True (@($knowledgeUpdate.runtime_impacting_files).Count -eq 0) 'knowledge-only update should have no runtime-impacting files'

  # Runtime fast-forward: bridge/runtime file changes and must request restart.
  Set-Content -LiteralPath (Join-Path $seed 'scripts/central_workshop_bridge.ps1') -Value '# runtime v2' -Encoding UTF8
  Invoke-Git $seed add scripts/central_workshop_bridge.ps1 | Out-Null
  Invoke-Git $seed commit -m 'runtime v2' | Out-Null
  Invoke-Git $seed push origin main | Out-Null

  $runtimeUpdate = Invoke-CentralSafeRepoUpdate -WorkDir $work -CanonicalRemote $remote
  Assert-True ([bool]$runtimeUpdate.changed) 'runtime fast-forward should report changed=true'
  Assert-True ([bool]$runtimeUpdate.repo_changed) 'runtime fast-forward should report repo_changed=true'
  Assert-True ([bool]$runtimeUpdate.restart_required) 'runtime update should request restart'
  Assert-True (@($runtimeUpdate.runtime_impacting_files) -contains 'scripts/central_workshop_bridge.ps1') 'runtime update should identify the bridge file'
  Assert-True ((Invoke-Git $work rev-parse HEAD) -eq (Invoke-Git $seed rev-parse HEAD)) 'local HEAD should equal remote main after update'

  $again = Invoke-CentralSafeRepoUpdate -WorkDir $work -CanonicalRemote $remote
  Assert-True (-not [bool]$again.changed) 'second update should be idempotent'
  Assert-True (-not [bool]$again.repo_changed) 'second update should report repo_changed=false'
  Assert-True ($again.status -eq 'up_to_date') 'second update should report up_to_date'

  Set-Content -LiteralPath (Join-Path $work 'untracked.txt') -Value 'dirty' -Encoding UTF8
  Assert-Throws { Invoke-CentralSafeRepoUpdate -WorkDir $work -CanonicalRemote $remote | Out-Null } 'completely clean working tree'
  Remove-Item -LiteralPath (Join-Path $work 'untracked.txt') -Force

  Invoke-Git $work switch -c feature-test | Out-Null
  Assert-Throws { Invoke-CentralSafeRepoUpdate -WorkDir $work -CanonicalRemote $remote | Out-Null } 'restricted to branch main'
  Invoke-Git $work switch main | Out-Null

  Set-Content -LiteralPath (Join-Path $work 'local-only.txt') -Value 'local' -Encoding UTF8
  Invoke-Git $work add local-only.txt | Out-Null
  Invoke-Git $work commit -m 'local divergence' | Out-Null

  Set-Content -LiteralPath (Join-Path $seed 'remote-only.txt') -Value 'remote' -Encoding UTF8
  Invoke-Git $seed add remote-only.txt | Out-Null
  Invoke-Git $seed commit -m 'remote divergence' | Out-Null
  Invoke-Git $seed push origin main | Out-Null

  Assert-Throws { Invoke-CentralSafeRepoUpdate -WorkDir $work -CanonicalRemote $remote | Out-Null } 'not an ancestor of origin/main'

  $global:LASTEXITCODE = 0
  Write-Host 'CENTRAL safe repo update behavioral tests: PASS'
} finally {
  Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
  $global:LASTEXITCODE = 0
}

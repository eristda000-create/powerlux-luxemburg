Set-StrictMode -Version Latest

function Normalize-CentralGitRemote([string]$Remote) {
  if ([string]::IsNullOrWhiteSpace($Remote)) { return '' }
  $value = $Remote.Trim().TrimEnd('/')
  if ($value.EndsWith('.git', [StringComparison]::OrdinalIgnoreCase)) {
    $value = $value.Substring(0, $value.Length - 4)
  }
  return $value.ToLowerInvariant()
}

function Invoke-CentralSafeRepoUpdate {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)][string]$WorkDir,
    [string]$CanonicalRemote = 'https://github.com/eristda000-create/powerlux-luxemburg.git'
  )

  if ([string]::IsNullOrWhiteSpace($WorkDir)) { throw 'CENTRAL_WORKDIR is not configured.' }
  if (-not (Test-Path -LiteralPath $WorkDir -PathType Container)) { throw 'CENTRAL_WORKDIR does not exist.' }
  if ($null -eq (Get-Command git -ErrorAction SilentlyContinue)) { throw 'git is not available.' }

  $resolvedWorkDir = (Resolve-Path -LiteralPath $WorkDir).Path.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)

  $repoRoot = (& git -C $resolvedWorkDir rev-parse --show-toplevel 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoRoot)) { throw "CENTRAL_WORKDIR is not a Git repository: $repoRoot" }
  $resolvedRepoRoot = (Resolve-Path -LiteralPath $repoRoot).Path.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
  if (-not [string]::Equals($resolvedRepoRoot, $resolvedWorkDir, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Safe repo update requires CENTRAL_WORKDIR to be the repository root.'
  }

  $branch = (& git -C $resolvedWorkDir branch --show-current 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) { throw "Unable to determine current branch: $branch" }
  if ($branch -ne 'main') { throw "Safe repo update is restricted to branch main; current branch is '$branch'." }

  $origin = (& git -C $resolvedWorkDir remote get-url origin 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) { throw "Unable to read origin remote: $origin" }
  if ((Normalize-CentralGitRemote $origin) -ne (Normalize-CentralGitRemote $CanonicalRemote)) {
    throw "Safe repo update refused unexpected origin remote: $origin"
  }

  $dirty = (& git -C $resolvedWorkDir status --porcelain=v1 --untracked-files=all 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) { throw "Unable to inspect working tree: $dirty" }
  if (-not [string]::IsNullOrWhiteSpace($dirty)) {
    throw 'Safe repo update requires a completely clean working tree, including no untracked files.'
  }

  $before = (& git -C $resolvedWorkDir rev-parse HEAD 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($before)) { throw "Unable to read local HEAD: $before" }

  $fetchOutput = (& git -C $resolvedWorkDir fetch --prune origin main 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) { throw "git fetch failed: $fetchOutput" }

  $remoteHead = (& git -C $resolvedWorkDir rev-parse origin/main 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($remoteHead)) { throw "Unable to read origin/main: $remoteHead" }

  if ($before -eq $remoteHead) {
    return [ordered]@{
      action = 'git_fast_forward_update'
      workdir = $resolvedWorkDir
      branch = $branch
      origin = $origin
      before = $before
      after = $before
      changed = $false
      restart_required = $false
      status = 'up_to_date'
    }
  }

  & git -C $resolvedWorkDir merge-base --is-ancestor $before origin/main 2>$null
  $ancestorExit = $LASTEXITCODE
  if ($ancestorExit -ne 0) {
    throw 'Safe repo update refused: local main is not an ancestor of origin/main. No reset/rebase/force operation is permitted.'
  }

  $mergeOutput = (& git -C $resolvedWorkDir merge --ff-only origin/main 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) { throw "Fast-forward merge failed: $mergeOutput" }

  $after = (& git -C $resolvedWorkDir rev-parse HEAD 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0 -or $after -ne $remoteHead) {
    throw "Post-update verification failed. expected=$remoteHead actual=$after"
  }

  $postDirty = (& git -C $resolvedWorkDir status --porcelain=v1 --untracked-files=all 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0 -or -not [string]::IsNullOrWhiteSpace($postDirty)) {
    throw 'Post-update verification failed: working tree is not clean.'
  }

  return [ordered]@{
    action = 'git_fast_forward_update'
    workdir = $resolvedWorkDir
    branch = $branch
    origin = $origin
    before = $before
    after = $after
    changed = $true
    restart_required = $true
    status = 'fast_forwarded'
    fetch_output = $fetchOutput
    merge_output = $mergeOutput
  }
}

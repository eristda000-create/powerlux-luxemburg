Set-StrictMode -Version Latest

function Normalize-CentralGitRemote([string]$Remote) {
  if ([string]::IsNullOrWhiteSpace($Remote)) { return '' }
  $value = $Remote.Trim().TrimEnd('/')
  if ($value.EndsWith('.git', [StringComparison]::OrdinalIgnoreCase)) {
    $value = $value.Substring(0, $value.Length - 4)
  }
  return $value.ToLowerInvariant()
}

function Test-CentralRuntimeImpactingPath([string]$Path) {
  if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
  $p = $Path.Replace('\\','/').TrimStart('/')
  $runtimeFiles = @(
    'scripts/central_workshop_bridge.ps1',
    'scripts/start-central-workshop.ps1',
    'scripts/central_supervisor.ps1',
    'scripts/central_local_agent_team.ps1',
    'scripts/central_local_agent_team_core.ps1',
    'scripts/central_local_agent_autonomy.ps1',
    'scripts/central_obsidian_connect.ps1',
    'scripts/central_obsidian_mount.ps1',
    'scripts/central_obsidian_rag.ps1',
    'scripts/central_obsidian_rag_v2.ps1',
    'scripts/central_context_capsule.ps1',
    'scripts/central_model_router.ps1',
    'scripts/central_model_benchmark.ps1',
    'scripts/central_model_pull.ps1',
    'scripts/central_hardware_inventory.ps1',
    'scripts/central_lab_sync.ps1',
    'scripts/central_embedding_bootstrap.ps1',
    'scripts/central_model_manager.ps1',
    'scripts/central_safe_repo_update.ps1'
  )
  foreach ($runtimeFile in $runtimeFiles) {
    if ($p.Equals($runtimeFile,[StringComparison]::OrdinalIgnoreCase)) { return $true }
  }
  return $false
}

function Test-CentralGitTreeCleanOrRefreshable {
  param([Parameter(Mandatory=$true)][string]$WorkDir)

  $dirty = (& git -C $WorkDir status --porcelain=v1 --untracked-files=all 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) { throw "Unable to inspect working tree: $dirty" }
  if ([string]::IsNullOrWhiteSpace($dirty)) {
    return [ordered]@{ clean=$true; refreshed=$false; status='' }
  }

  $lines = @($dirty -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  $untracked = @($lines | Where-Object { $_.StartsWith('??') })
  if ($untracked.Count -gt 0) {
    return [ordered]@{ clean=$false; refreshed=$false; status=$dirty; reason='untracked_files' }
  }

  # First try a non-destructive index metadata refresh.
  & git -C $WorkDir update-index --refresh 2>$null | Out-Null
  $afterRefresh = (& git -C $WorkDir status --porcelain=v1 --untracked-files=all 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -eq 0 -and [string]::IsNullOrWhiteSpace($afterRefresh)) {
    return [ordered]@{ clean=$true; refreshed=$true; status=''; prior_status=$dirty; reason='stat_only_index_refresh' }
  }

  # Windows/Obsidian can leave tracked Markdown files marked modified even when Git can
  # produce no actual worktree or staged diff. Only in that narrowly proven case may
  # CENTRAL restore those exact knowledge/*.md worktree paths from HEAD.
  $worktreeNames = @((& git -C $WorkDir diff --name-only -- 2>$null | ForEach-Object { ([string]$_).Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }))
  $worktreeNamesExit = $LASTEXITCODE
  $cachedNames = @((& git -C $WorkDir diff --cached --name-only -- 2>$null | ForEach-Object { ([string]$_).Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }))
  $cachedNamesExit = $LASTEXITCODE

  if ($worktreeNamesExit -eq 0 -and $cachedNamesExit -eq 0 -and $worktreeNames.Count -eq 0 -and $cachedNames.Count -eq 0) {
    $restorePaths = [System.Collections.Generic.List[string]]::new()
    $restoreSafe = $true
    foreach ($line in $lines) {
      if ($line.Length -lt 4) { $restoreSafe=$false; break }
      $pathText = $line.Substring(3).Trim()
      if ([string]::IsNullOrWhiteSpace($pathText) -or $pathText.Contains(' -> ')) { $restoreSafe=$false; break }
      $norm = $pathText.Replace('\\','/').TrimStart('/')
      if (-not ($norm.StartsWith('knowledge/',[StringComparison]::OrdinalIgnoreCase) -and $norm.EndsWith('.md',[StringComparison]::OrdinalIgnoreCase))) {
        $restoreSafe=$false; break
      }
      $restorePaths.Add($pathText)
    }

    if ($restoreSafe -and $restorePaths.Count -gt 0) {
      $restoreArgs = @('-C',$WorkDir,'restore','--worktree','--source=HEAD','--') + @($restorePaths)
      & git @restoreArgs 2>$null | Out-Null
      $restoreExit = $LASTEXITCODE
      $afterRestore = (& git -C $WorkDir status --porcelain=v1 --untracked-files=all 2>&1 | Out-String).Trim()
      if ($restoreExit -eq 0 -and [string]::IsNullOrWhiteSpace($afterRestore)) {
        return [ordered]@{
          clean=$true
          refreshed=$true
          status=''
          prior_status=$dirty
          reason='empty_diff_knowledge_worktree_restore'
          restored_paths=@($restorePaths)
        }
      }
    }
  }

  return [ordered]@{ clean=$false; refreshed=$false; status=$dirty; reason='real_or_unresolved_diff' }
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

  $treeCheck = Test-CentralGitTreeCleanOrRefreshable -WorkDir $resolvedWorkDir
  if (-not [bool]$treeCheck.clean) {
    throw "Safe repo update requires a completely clean working tree, including no untracked files. reason=$($treeCheck.reason) status=$($treeCheck.status)"
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
      repo_changed = $false
      changed = $false
      changed_files = @()
      runtime_impacting_files = @()
      restart_required = $false
      index_refreshed = [bool]$treeCheck.refreshed
      status = 'up_to_date'
    }
  }

  & git -C $resolvedWorkDir merge-base --is-ancestor $before origin/main 2>$null
  $ancestorExit = $LASTEXITCODE
  if ($ancestorExit -ne 0) {
    throw 'Safe repo update refused: local main is not an ancestor of origin/main. No reset/rebase/force operation is permitted.'
  }

  $changedFiles = @((& git -C $resolvedWorkDir diff --name-only $before origin/main 2>&1 | ForEach-Object { [string]$_ } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }))
  if ($LASTEXITCODE -ne 0) { throw 'Unable to determine changed files before safe update.' }
  $runtimeImpactingFiles = @($changedFiles | Where-Object { Test-CentralRuntimeImpactingPath $_ })
  $restartRequired = ($runtimeImpactingFiles.Count -gt 0)

  $mergeOutput = (& git -C $resolvedWorkDir merge --ff-only origin/main 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) { throw "Fast-forward merge failed: $mergeOutput" }

  $after = (& git -C $resolvedWorkDir rev-parse HEAD 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0 -or $after -ne $remoteHead) {
    throw "Post-update verification failed. expected=$remoteHead actual=$after"
  }

  $postTree = Test-CentralGitTreeCleanOrRefreshable -WorkDir $resolvedWorkDir
  if (-not [bool]$postTree.clean) {
    throw "Post-update verification failed: working tree is not clean. reason=$($postTree.reason) status=$($postTree.status)"
  }

  $bridgeCompat = [Environment]::GetEnvironmentVariable('CENTRAL_RUNTIME_AWARE_CHANGED_COMPAT')
  $changedForCaller = $true
  if ($bridgeCompat -in @('1','true','TRUE','yes','YES')) {
    $changedForCaller = $restartRequired
  }

  return [ordered]@{
    action = 'git_fast_forward_update'
    workdir = $resolvedWorkDir
    branch = $branch
    origin = $origin
    before = $before
    after = $after
    repo_changed = $true
    changed = $changedForCaller
    changed_semantics = if ($bridgeCompat) { 'runtime_restart_compatibility' } else { 'repository_changed' }
    changed_files = $changedFiles
    runtime_impacting_files = $runtimeImpactingFiles
    restart_required = $restartRequired
    index_refreshed = [bool]($treeCheck.refreshed -or $postTree.refreshed)
    status = 'fast_forwarded'
    fetch_output = $fetchOutput
    merge_output = $mergeOutput
  }
}

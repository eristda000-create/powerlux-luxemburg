[CmdletBinding()]
param(
    [switch]$RequireMainCurrent
)

$ErrorActionPreference = 'Stop'
$ExpectedRemote = 'https://github.com/eristda000-create/powerlux-luxemburg.git'

function Invoke-Git {
    param([Parameter(Mandatory=$true)][string[]]$Args)
    $output = & git @Args 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Args -join ' ') failed: $($output -join "`n")"
    }
    return ($output -join "`n").Trim()
}

$repoRoot = Invoke-Git @('rev-parse','--show-toplevel')
Set-Location $repoRoot
$branch = Invoke-Git @('rev-parse','--abbrev-ref','HEAD')
$origin = Invoke-Git @('remote','get-url','origin')

$originNormalized = $origin.TrimEnd('/')
$expectedNormalized = $ExpectedRemote.TrimEnd('/')
if ($originNormalized -ne $expectedNormalized -and $originNormalized -ne 'git@github.com:eristda000-create/powerlux-luxemburg.git') {
    throw "Unexpected origin remote: $origin"
}

$gitDir = Invoke-Git @('rev-parse','--git-dir')
$inProgressMarkers = @(
    (Join-Path $gitDir 'MERGE_HEAD'),
    (Join-Path $gitDir 'CHERRY_PICK_HEAD'),
    (Join-Path $gitDir 'REVERT_HEAD'),
    (Join-Path $gitDir 'rebase-merge'),
    (Join-Path $gitDir 'rebase-apply')
)
if ($inProgressMarkers | Where-Object { Test-Path $_ }) {
    throw 'Repository has an unfinished merge/rebase/cherry-pick/revert operation.'
}

$dirty = Invoke-Git @('status','--porcelain')
if ($dirty) {
    throw "Working tree is not clean:`n$dirty"
}

Invoke-Git @('fetch','origin','main','--prune') | Out-Null
$head = Invoke-Git @('rev-parse','HEAD')
$main = Invoke-Git @('rev-parse','origin/main')

& git merge-base --is-ancestor $head $main *> $null
$headIsAncestorOfMain = ($LASTEXITCODE -eq 0)
& git merge-base --is-ancestor $main $head *> $null
$mainIsAncestorOfHead = ($LASTEXITCODE -eq 0)
$global:LASTEXITCODE = 0

$relationship = if ($head -eq $main) {
    'equal_to_origin_main'
} elseif ($branch -eq 'main' -and $headIsAncestorOfMain) {
    'main_behind_origin'
} elseif ($branch -eq 'main') {
    'main_diverged_or_ahead'
} elseif ($mainIsAncestorOfHead) {
    'feature_contains_current_main'
} else {
    'feature_stale_or_diverged'
}

if ($branch -eq 'main' -and $relationship -eq 'main_diverged_or_ahead') {
    throw 'Local main is not a clean fast-forward candidate. Do not reset/rebase automatically.'
}

if ($RequireMainCurrent -and $branch -ne 'main' -and -not $mainIsAncestorOfHead) {
    throw 'Feature branch does not contain current origin/main. Synchronize before continuing work.'
}

[pscustomobject]@{
    repo_root = $repoRoot
    origin = $origin
    branch = $branch
    head = $head
    origin_main = $main
    working_tree_clean = $true
    operation_in_progress = $false
    relationship = $relationship
    safe_main_fast_forward_available = ($branch -eq 'main' -and $headIsAncestorOfMain -and $head -ne $main)
    feature_contains_current_main = ($branch -ne 'main' -and $mainIsAncestorOfHead)
} | ConvertTo-Json -Depth 4

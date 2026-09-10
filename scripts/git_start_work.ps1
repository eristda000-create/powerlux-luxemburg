[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidatePattern('^(feature|fix|chore|docs|central|hotfix)/[a-z0-9][a-z0-9._-]+$')]
    [string]$BranchName
)

$ErrorActionPreference = 'Stop'
$ExpectedHttpsRemote = 'https://github.com/eristda000-create/powerlux-luxemburg.git'
$ExpectedSshRemote = 'git@github.com:eristda000-create/powerlux-luxemburg.git'

function Git {
    param([Parameter(Mandatory=$true)][string[]]$Args)
    $output = & git @Args 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Args -join ' ') failed: $($output -join "`n")"
    }
    return ($output -join "`n").Trim()
}

$repoRoot = Git @('rev-parse','--show-toplevel')
Set-Location $repoRoot
$origin = Git @('remote','get-url','origin')
if ($origin -ne $ExpectedHttpsRemote -and $origin -ne $ExpectedSshRemote) {
    throw "Unexpected origin remote: $origin"
}

$branch = Git @('rev-parse','--abbrev-ref','HEAD')
if ($branch -ne 'main') {
    throw "Safe work start requires branch main; current branch is $branch"
}

$dirty = Git @('status','--porcelain')
if ($dirty) {
    throw "Working tree is not clean. Commit/stash/review it manually before starting new work.`n$dirty"
}

$gitDir = Git @('rev-parse','--git-dir')
foreach ($marker in @('MERGE_HEAD','CHERRY_PICK_HEAD','REVERT_HEAD','rebase-merge','rebase-apply')) {
    if (Test-Path (Join-Path $gitDir $marker)) {
        throw "Unfinished Git operation detected: $marker"
    }
}

Git @('fetch','origin','main','--prune') | Out-Null
$localMain = Git @('rev-parse','HEAD')
$originMain = Git @('rev-parse','origin/main')

if ($localMain -ne $originMain) {
    & git merge-base --is-ancestor $localMain $originMain *> $null
    $safeFastForward = ($LASTEXITCODE -eq 0)
    $global:LASTEXITCODE = 0
    if (-not $safeFastForward) {
        throw 'Local main is ahead/diverged from origin/main. Automatic repair is forbidden.'
    }
    Git @('merge','--ff-only','origin/main') | Out-Null
}

& git ls-remote --exit-code --heads origin $BranchName *> $null
$remoteBranchExists = ($LASTEXITCODE -eq 0)
$global:LASTEXITCODE = 0
if ($remoteBranchExists) {
    throw "Remote branch already exists: $BranchName. Reuse only through an explicit handoff; do not silently take ownership."
}

Git @('switch','-c',$BranchName,'origin/main') | Out-Null
$newHead = Git @('rev-parse','HEAD')

[pscustomobject]@{
    ok = $true
    repository = 'eristda000-create/powerlux-luxemburg'
    branch = $BranchName
    base = 'origin/main'
    base_commit = $newHead
    working_tree_clean = $true
    ownership_required = $true
} | ConvertTo-Json -Depth 3

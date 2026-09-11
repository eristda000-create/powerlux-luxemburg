Set-StrictMode -Version Latest

function Sync-CentralLabVault {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)][string]$ObsidianVault
  )

  if ([string]::IsNullOrWhiteSpace($ObsidianVault) -or -not (Test-Path -LiteralPath $ObsidianVault -PathType Container)) {
    throw 'OBSIDIAN_VAULT is not configured or does not exist.'
  }

  $labRoot = Join-Path $ObsidianVault 'CENTRAL_LAB'
  $vendorRoot = Join-Path $labRoot 'vendor'
  New-Item -ItemType Directory -Path $vendorRoot -Force | Out-Null

  $repos = @(
    [ordered]@{ key='obsidian-skills'; repo='kepano/obsidian-skills'; branch='main'; url='https://github.com/kepano/obsidian-skills.git'; purpose='Obsidian syntax and agent skills patterns' },
    [ordered]@{ key='obsidian-agent-memory'; repo='mithunyc/obsidian-agent-memory'; branch='master'; url='https://github.com/mithunyc/obsidian-agent-memory.git'; purpose='Context capsules, tiered retrieval and memory patterns' },
    [ordered]@{ key='obsidian-agent-vault'; repo='georgeracu/obsidian-agent-vault'; branch='main'; url='https://github.com/georgeracu/obsidian-agent-vault.git'; purpose='Agent vault organization and memory lifecycle patterns' },
    [ordered]@{ key='obsidian-memory'; repo='kkonstvol-lab/obsidian-memory'; branch='master'; url='https://github.com/kkonstvol-lab/obsidian-memory.git'; purpose='Memory qualification, review and lifecycle patterns' },
    [ordered]@{ key='obsidian-rag'; repo='Weliviti/obsidian-rag'; branch='main'; url='https://github.com/Weliviti/obsidian-rag.git'; purpose='Hybrid retrieval and reranking patterns' }
  )

  $items = [System.Collections.Generic.List[object]]::new()
  foreach ($r in $repos) {
    $target = Join-Path $vendorRoot $r.key
    $status = 'unknown'
    $commit = $null
    $detail = $null

    try {
      if (-not (Test-Path -LiteralPath $target -PathType Container)) {
        $out = (& git clone --depth 1 --branch $r.branch --single-branch $r.url $target 2>&1 | Out-String).Trim()
        if ($LASTEXITCODE -ne 0) { throw "git clone failed: $out" }
        $status = 'cloned'
      } elseif (Test-Path -LiteralPath (Join-Path $target '.git') -PathType Container) {
        $dirty = (& git -C $target status --porcelain 2>&1 | Out-String).Trim()
        if ($LASTEXITCODE -ne 0) { throw 'git status failed in lab repo.' }
        if (-not [string]::IsNullOrWhiteSpace($dirty)) {
          $status = 'skipped_dirty'
          $detail = 'Local lab copy has changes; CENTRAL never overwrites them.'
        } else {
          $out = (& git -C $target pull --ff-only origin $r.branch 2>&1 | Out-String).Trim()
          if ($LASTEXITCODE -ne 0) { throw "git pull --ff-only failed: $out" }
          $status = 'updated'
        }
      } else {
        $status = 'blocked_conflict'
        $detail = 'Target directory exists but is not a git repository.'
      }

      if (Test-Path -LiteralPath (Join-Path $target '.git') -PathType Container) {
        $commit = (& git -C $target rev-parse HEAD 2>$null | Out-String).Trim()
      }
    } catch {
      $status = 'error'
      $detail = $_.Exception.Message
    }

    $items.Add([ordered]@{
      key = $r.key
      repository = $r.repo
      purpose = $r.purpose
      target = $target
      status = $status
      commit = $commit
      detail = $detail
      executable_trust = 'UNTRUSTED_REFERENCE_ONLY'
    })
  }

  $manifest = [ordered]@{
    schema = 'central_lab_manifest_v1'
    generated_at = [DateTimeOffset]::UtcNow.ToString('o')
    policy = @{
      canonical_memory = 'CENTRAL/'
      lab_memory = 'CENTRAL_LAB/'
      vendor_code_execution = 'forbidden_by_default'
      promotion_rule = 'Patterns must be reviewed and reimplemented or explicitly approved before entering CENTRAL.'
    }
    repositories = @($items)
  }

  $manifestPath = Join-Path $labRoot 'LAB_MANIFEST.json'
  $manifest | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

  $readme = @"
# CENTRAL LAB

This directory is an isolated research zone for external Obsidian/agent-memory patterns.

- `CENTRAL/` remains canonical company/project memory.
- `CENTRAL_LAB/vendor/` contains allowlisted third-party repositories as **untrusted reference material only**.
- CENTRAL does not execute vendor scripts or promote vendor notes into canonical memory automatically.
- Useful mechanisms must pass controller review before being reimplemented or adopted.

See `LAB_MANIFEST.json` for pinned repositories and current commits.
"@
  $readme | Set-Content -LiteralPath (Join-Path $labRoot 'README.md') -Encoding UTF8

  return $manifest
}

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path -Parent $PSScriptRoot
$helper = Join-Path $root 'scripts/central_vercel_release.ps1'
$team = Join-Path $root 'scripts/central_local_agent_team.ps1'

foreach ($path in @($helper,$team)) {
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing required file: $path" }
  $tokens=$null; $errors=$null
  [void][System.Management.Automation.Language.Parser]::ParseFile($path,[ref]$tokens,[ref]$errors)
  if ($errors.Count -gt 0) { throw "PowerShell parse error in $path : $($errors[0].Message)" }
}

. $helper

$source = Test-CentralPowerTvReleaseSource -WorkDir $root
if (-not [bool]$source.valid) { throw 'Verified PowerTV source validation did not pass.' }
if ($source.project -ne 'powertv-vercel-release') { throw 'Capability target drifted away from canonical PowerTV project.' }
if ($source.canonical_url -ne 'https://powertv-vercel-release.vercel.app') { throw 'Canonical PowerTV URL drifted.' }

$helperSource = Get-Content -LiteralPath $helper -Raw
if ($helperSource -match '(?i)\bvercel\s+link\b') { throw 'Capability must not call vercel link because link can create/substitute projects.' }
if ($helperSource -match '(?i)project\s+(add|rm|remove|delete)') { throw 'Capability must not create or delete Vercel projects.' }
if ($helperSource -notmatch "CentralPowerTvVercelProject = 'powertv-vercel-release'") { throw 'Exact canonical project constant missing.' }
if ($helperSource -notmatch "rights_policy = 'public_youtube_embeds_plus_official_ppv_link_only'") { throw 'Rights-safe release policy marker missing.' }

# Probe succeeds only when the exact project is in a stubbed Vercel project list.
function Invoke-CentralBoundedVercelCli {
  param([string[]]$Arguments,[int]$TimeoutSec)
  return [ordered]@{
    available=$true
    exit_code=0
    stdout='[{"name":"powertv-vercel-release","id":"prj_exact"},{"name":"other","id":"prj_other"}]'
    stderr=''
    timed_out=$false
  }
}
$probe = Get-CentralPowerTvVercelProbe -WorkDir $root
if (-not [bool]$probe.ready -or $probe.status -ne 'ready') { throw 'Exact-project Vercel probe should be ready.' }
if ($probe.exact_project -ne 'powertv-vercel-release') { throw 'Probe returned the wrong Vercel project.' }

# A similar PowerTV project must never be accepted as a substitute.
function Invoke-CentralBoundedVercelCli {
  param([string[]]$Arguments,[int]$TimeoutSec)
  return [ordered]@{
    available=$true
    exit_code=0
    stdout='[{"name":"powertv-current-2026","id":"prj_wrong"},{"name":"powertv-preview","id":"prj_preview"}]'
    stderr=''
    timed_out=$false
  }
}
$negative = Get-CentralPowerTvVercelProbe -WorkDir $root
if ([bool]$negative.ready) { throw 'Probe incorrectly accepted a substitute PowerTV Vercel project.' }
if ($negative.status -ne 'exact_project_not_visible') { throw "Unexpected negative probe status: $($negative.status)" }

# Prove production deploy is hard-wired to the exact project and includes post-deploy canonical verification.
$script:CapturedDeployArgs = @()
function Get-CentralPowerTvVercelProbe {
  param([string]$WorkDir)
  return [ordered]@{ ready=$true; status='ready'; source=(Test-CentralPowerTvReleaseSource -WorkDir $WorkDir) }
}
function Invoke-CentralBoundedVercelCli {
  param([string[]]$Arguments,[int]$TimeoutSec)
  $script:CapturedDeployArgs = @($Arguments)
  return [ordered]@{ available=$true; exit_code=0; stdout='https://powertv-vercel-release-abc.vercel.app'; stderr=''; timed_out=$false }
}
function Test-CentralPowerTvCanonicalRelease {
  param([int]$Attempts=12,[int]$DelaySeconds=5)
  return [ordered]@{ verified=$true; canonical_url='https://powertv-vercel-release.vercel.app'; checks=@{ home_growth_marker=$true; evw_marker=$true; robots_marker=$true; sitemap_marker=$true } }
}
$publish = Publish-CentralPowerTvVercelRelease -WorkDir $root
if ($publish.status -ne 'deployed_verified') { throw 'Publish did not require verified canonical release.' }
$joined = $script:CapturedDeployArgs -join ' '
if ($joined -notmatch '^deploy\s') { throw 'Publish does not invoke Vercel deploy.' }
if ($joined -notmatch '--prod') { throw 'Publish is not a production deploy.' }
if ($joined -notmatch '--project\s+powertv-vercel-release') { throw 'Publish is not locked to exact canonical project.' }
if ($joined -match '\blink\b') { throw 'Publish must never link/create a substitute Vercel project.' }

# Dispatcher exposes only the bounded probe/deploy modes, not arbitrary command execution.
. $team
if ((Get-CentralCapabilityMode -Payload ([pscustomobject]@{ mode='vercel_probe' })) -ne 'vercel_probe') { throw 'vercel_probe is not dispatched as a direct capability.' }
if ((Get-CentralCapabilityMode -Payload ([pscustomobject]@{ mode='powertv_vercel_deploy' })) -ne 'powertv_vercel_deploy') { throw 'powertv_vercel_deploy is not dispatched as a direct capability.' }
if (-not [string]::IsNullOrWhiteSpace((Get-CentralCapabilityMode -Payload ([pscustomobject]@{ mode='shell' })))) { throw 'Arbitrary shell mode must remain unavailable.' }

Write-Host 'PowerTV bounded Vercel release gate: PASS'

Set-StrictMode -Version Latest

$script:CentralPowerTvVercelProject = 'powertv-vercel-release'
$script:CentralPowerTvCanonicalUrl = 'https://powertv-vercel-release.vercel.app'

function ConvertTo-CentralCmdToken {
  param([Parameter(Mandatory=$true)][string]$Value)
  if ($Value.Contains('"') -or $Value.Contains("`r") -or $Value.Contains("`n")) {
    throw 'Unsafe process argument was rejected.'
  }
  if ($Value -match '[\s&|<>^()]') { return '"' + $Value + '"' }
  return $Value
}

function ConvertTo-CentralSafeCliText {
  param([string]$Text,[int]$MaxChars=1800)
  if ([string]::IsNullOrWhiteSpace($Text)) { return '' }
  $safe = [string]$Text
  $safe = $safe -replace '(?i)(token|authorization|bearer)\s*[:=]\s*\S+', '$1=[redacted]'
  $safe = $safe.Trim()
  if ($safe.Length -gt $MaxChars) { $safe = $safe.Substring(0,$MaxChars) }
  return $safe
}

function Invoke-CentralBoundedVercelCli {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)][string[]]$Arguments,
    [int]$TimeoutSec = 90
  )

  $command = Get-Command vercel -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($null -eq $command) {
    $command = Get-Command vercel.cmd -ErrorAction SilentlyContinue | Select-Object -First 1
  }

  $commandPrefix = @()
  $transport = 'installed_cli'
  if ($null -eq $command) {
    $command = Get-Command npx -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $command) {
      $command = Get-Command npx.cmd -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    if ($null -eq $command) {
      return [ordered]@{ available=$false; exit_code=$null; stdout=''; stderr='Neither Vercel CLI nor npx is available on PATH.'; timed_out=$false; transport='unavailable' }
    }
    # Ephemeral package execution only: do not install Vercel globally or create/link projects.
    $commandPrefix = @('--yes','vercel@latest')
    $transport = 'npx_ephemeral'
  }

  $source = [string]$command.Source
  $extension = [IO.Path]::GetExtension($source).ToLowerInvariant()
  $psi = [Diagnostics.ProcessStartInfo]::new()
  $psi.UseShellExecute = $false
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.CreateNoWindow = $true
  $psi.Environment['NO_COLOR'] = '1'
  $psi.Environment['CI'] = '1'

  $allArguments = @($commandPrefix) + @($Arguments)
  if ($IsWindows -and $extension -in @('.cmd','.bat')) {
    $psi.FileName = if ([string]::IsNullOrWhiteSpace($env:ComSpec)) { 'cmd.exe' } else { $env:ComSpec }
    $tokens = [System.Collections.Generic.List[string]]::new()
    $tokens.Add((ConvertTo-CentralCmdToken -Value $source))
    foreach ($arg in $allArguments) { $tokens.Add((ConvertTo-CentralCmdToken -Value ([string]$arg))) }
    $psi.ArgumentList.Add('/d')
    $psi.ArgumentList.Add('/c')
    $psi.ArgumentList.Add(($tokens -join ' '))
  } elseif ($extension -eq '.ps1') {
    $pwsh = Get-Command pwsh -ErrorAction Stop
    $psi.FileName = $pwsh.Source
    $psi.ArgumentList.Add('-NoProfile')
    $psi.ArgumentList.Add('-NonInteractive')
    $psi.ArgumentList.Add('-File')
    $psi.ArgumentList.Add($source)
    foreach ($arg in $allArguments) { $psi.ArgumentList.Add([string]$arg) }
  } else {
    $psi.FileName = $source
    foreach ($arg in $allArguments) { $psi.ArgumentList.Add([string]$arg) }
  }

  $process = [Diagnostics.Process]::new()
  $process.StartInfo = $psi
  [void]$process.Start()
  $stdoutTask = $process.StandardOutput.ReadToEndAsync()
  $stderrTask = $process.StandardError.ReadToEndAsync()
  $finished = $process.WaitForExit([Math]::Max(5,$TimeoutSec) * 1000)
  if (-not $finished) {
    try { $process.Kill($true) } catch {}
    try { $process.WaitForExit(5000) | Out-Null } catch {}
  }

  $stdout = ''
  $stderr = ''
  try { $stdout = $stdoutTask.GetAwaiter().GetResult() } catch {}
  try { $stderr = $stderrTask.GetAwaiter().GetResult() } catch {}

  return [ordered]@{
    available = $true
    exit_code = if ($finished) { $process.ExitCode } else { $null }
    stdout = ConvertTo-CentralSafeCliText -Text $stdout -MaxChars 12000
    stderr = ConvertTo-CentralSafeCliText -Text $stderr -MaxChars 2400
    timed_out = (-not $finished)
    transport = $transport
  }
}

function ConvertFrom-CentralVercelProjectList {
  param([Parameter(Mandatory=$true)][string]$Text)
  $trimmed = $Text.Trim()
  if ([string]::IsNullOrWhiteSpace($trimmed)) { return @() }

  $candidate = $trimmed
  $arrayStart = $trimmed.IndexOf('[')
  $objectStart = $trimmed.IndexOf('{')
  if ($arrayStart -ge 0 -and ($objectStart -lt 0 -or $arrayStart -lt $objectStart)) {
    $arrayEnd = $trimmed.LastIndexOf(']')
    if ($arrayEnd -gt $arrayStart) { $candidate = $trimmed.Substring($arrayStart,$arrayEnd-$arrayStart+1) }
  } elseif ($objectStart -ge 0) {
    $objectEnd = $trimmed.LastIndexOf('}')
    if ($objectEnd -gt $objectStart) { $candidate = $trimmed.Substring($objectStart,$objectEnd-$objectStart+1) }
  }

  $parsed = $candidate | ConvertFrom-Json -Depth 20
  if ($parsed -is [System.Array]) { return @($parsed) }
  if ($null -ne $parsed.PSObject.Properties['projects']) { return @($parsed.projects) }
  return @($parsed)
}

function Test-CentralPowerTvReleaseSource {
  [CmdletBinding()]
  param([Parameter(Mandatory=$true)][string]$WorkDir)

  $root = [IO.Path]::GetFullPath($WorkDir).TrimEnd([char[]]'\/')
  if (-not (Test-Path -LiteralPath $root -PathType Container)) { throw 'CENTRAL_WORKDIR does not exist.' }
  $source = [IO.Path]::GetFullPath((Join-Path $root 'powertv'))
  $expectedPrefix = $root + [IO.Path]::DirectorySeparatorChar
  if (-not $source.StartsWith($expectedPrefix,[StringComparison]::OrdinalIgnoreCase)) { throw 'PowerTV source escaped CENTRAL_WORKDIR.' }
  if (-not (Test-Path -LiteralPath $source -PathType Container)) { throw 'Verified powertv source directory is missing from CENTRAL_WORKDIR.' }

  $required = @(
    'index.html',
    'assets/index-qo0EwjoB.js',
    'assets/index-C8bposip.css',
    'evw-growth.js',
    'evw-growth.css',
    'east-vs-west/index.html',
    'robots.txt',
    'sitemap.xml',
    'SOURCE_MANIFEST.txt'
  )
  foreach ($relative in $required) {
    $path = Join-Path $source $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing verified PowerTV release file: $relative" }
  }

  $bundle = Get-Content -LiteralPath (Join-Path $source 'assets/index-qo0EwjoB.js') -Raw
  $growth = Get-Content -LiteralPath (Join-Path $source 'evw-growth.js') -Raw
  $landing = Get-Content -LiteralPath (Join-Path $source 'east-vs-west/index.html') -Raw
  $homeMarkup = Get-Content -LiteralPath (Join-Path $source 'index.html') -Raw
  $manifest = Get-Content -LiteralPath (Join-Path $source 'SOURCE_MANIFEST.txt') -Raw

  if ($bundle -notmatch 'PowerLux Associates') { throw 'Authentic PowerTV Associate Player fingerprint is missing.' }
  if ($manifest -notmatch 'runtime_fingerprint_required=associate_player') { throw 'PowerTV source manifest no longer requires Associate Player.' }
  if ($growth -notmatch 'UC3Dw8OYsWmZqrM1qBBZUMhQ') { throw 'Official East vs West YouTube channel marker is missing.' }
  if ($growth -notmatch 'UCIEjGMfXbN4LFYSnV8qSgAQ') { throw 'Ryan Bowen commentary channel marker is missing.' }
  if ($growth -notmatch 'UCAH2krcji9uc3gYSqa33Zyw') { throw 'Voice of Armwrestling channel marker is missing.' }
  if ($landing -notmatch 'live\.evwsports\.com') { throw 'Official EVW PPV route is missing.' }
  if ($landing -notmatch 'FAQPage' -or $landing -notmatch 'SportsEvent') { throw 'EVW Google structured data is incomplete.' }
  if ($homeMarkup -notmatch '/evw-growth\.js' -or $homeMarkup -notmatch '/assets/index-qo0EwjoB\.js') { throw 'PowerTV homepage no longer composes the authentic runtime with the EVW growth layer.' }

  return [ordered]@{
    valid = $true
    source = $source
    project = $script:CentralPowerTvVercelProject
    canonical_url = $script:CentralPowerTvCanonicalUrl
    rights_policy = 'public_youtube_embeds_plus_official_ppv_link_only'
  }
}

function Get-CentralPowerTvVercelProbe {
  [CmdletBinding()]
  param([Parameter(Mandatory=$true)][string]$WorkDir)

  $sourceState = Test-CentralPowerTvReleaseSource -WorkDir $WorkDir
  $cli = Invoke-CentralBoundedVercelCli -Arguments @('project','ls','--json') -TimeoutSec 90
  if (-not [bool]$cli.available) {
    return [ordered]@{ status='cli_unavailable'; ready=$false; source=$sourceState; stderr=$cli.stderr; transport=$cli.transport }
  }
  if ([bool]$cli.timed_out) {
    return [ordered]@{ status='probe_timeout'; ready=$false; source=$sourceState; transport=$cli.transport }
  }
  if ([int]$cli.exit_code -ne 0) {
    return [ordered]@{ status='cli_not_authenticated_or_failed'; ready=$false; source=$sourceState; stderr=$cli.stderr; transport=$cli.transport }
  }

  try { $projects = @(ConvertFrom-CentralVercelProjectList -Text ([string]$cli.stdout)) }
  catch {
    return [ordered]@{ status='project_list_parse_failed'; ready=$false; source=$sourceState; error=$_.Exception.Message; transport=$cli.transport }
  }

  $match = $projects | Where-Object {
    $name = ''
    try { $name = [string]$_.name } catch {}
    $name -eq $script:CentralPowerTvVercelProject
  } | Select-Object -First 1

  if ($null -eq $match) {
    $visible = @($projects | ForEach-Object { try { [string]$_.name } catch { '' } } | Where-Object { $_ -like '*powertv*' } | Select-Object -Unique)
    return [ordered]@{
      status = 'exact_project_not_visible'
      ready = $false
      required_project = $script:CentralPowerTvVercelProject
      visible_powertv_projects = $visible
      source = $sourceState
      transport = $cli.transport
    }
  }

  $projectId = $null
  try { $projectId = [string]$match.id } catch {}
  return [ordered]@{
    status = 'ready'
    ready = $true
    exact_project = $script:CentralPowerTvVercelProject
    project_id = $projectId
    canonical_url = $script:CentralPowerTvCanonicalUrl
    source = $sourceState
    transport = $cli.transport
  }
}

function Test-CentralPowerTvCanonicalRelease {
  [CmdletBinding()]
  param([int]$Attempts=12,[int]$DelaySeconds=5)

  $checks = [ordered]@{}
  for ($attempt=1; $attempt -le [Math]::Max(1,$Attempts); $attempt++) {
    try {
      $stamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
      $homeResponse = Invoke-WebRequest -Uri "$script:CentralPowerTvCanonicalUrl/?central_verify=$stamp" -TimeoutSec 20
      $evwResponse = Invoke-WebRequest -Uri "$script:CentralPowerTvCanonicalUrl/east-vs-west/?central_verify=$stamp" -TimeoutSec 20
      $robotsResponse = Invoke-WebRequest -Uri "$script:CentralPowerTvCanonicalUrl/robots.txt?central_verify=$stamp" -TimeoutSec 20
      $sitemapResponse = Invoke-WebRequest -Uri "$script:CentralPowerTvCanonicalUrl/sitemap.xml?central_verify=$stamp" -TimeoutSec 20
      $checks = [ordered]@{
        home_http = [int]$homeResponse.StatusCode
        evw_http = [int]$evwResponse.StatusCode
        robots_http = [int]$robotsResponse.StatusCode
        sitemap_http = [int]$sitemapResponse.StatusCode
        home_growth_marker = ([string]$homeResponse.Content).Contains('evw-growth.js')
        evw_marker = ([string]$evwResponse.Content).Contains('East vs West 26 Live')
        robots_marker = ([string]$robotsResponse.Content).Contains('Sitemap:')
        sitemap_marker = ([string]$sitemapResponse.Content).Contains('east-vs-west')
      }
      if ($checks.home_http -eq 200 -and $checks.evw_http -eq 200 -and $checks.robots_http -eq 200 -and $checks.sitemap_http -eq 200 -and $checks.home_growth_marker -and $checks.evw_marker -and $checks.robots_marker -and $checks.sitemap_marker) {
        return [ordered]@{ verified=$true; attempt=$attempt; checks=$checks; canonical_url=$script:CentralPowerTvCanonicalUrl }
      }
    } catch {
      $checks = [ordered]@{ error=(ConvertTo-CentralSafeCliText -Text $_.Exception.Message -MaxChars 800) }
    }
    if ($attempt -lt $Attempts) { Start-Sleep -Seconds ([Math]::Max(1,$DelaySeconds)) }
  }
  return [ordered]@{ verified=$false; attempt=$Attempts; checks=$checks; canonical_url=$script:CentralPowerTvCanonicalUrl }
}

function Publish-CentralPowerTvVercelRelease {
  [CmdletBinding()]
  param([Parameter(Mandatory=$true)][string]$WorkDir)

  $probe = Get-CentralPowerTvVercelProbe -WorkDir $WorkDir
  if (-not [bool]$probe.ready) {
    throw "PowerTV production deploy refused because exact canonical project is not verified: $($probe.status)"
  }

  $source = [string]$probe.source.source
  $deploy = Invoke-CentralBoundedVercelCli -Arguments @('deploy','--prod','--yes','--project',$script:CentralPowerTvVercelProject,'--cwd',$source) -TimeoutSec 360
  if (-not [bool]$deploy.available) { throw 'Vercel CLI became unavailable before deployment.' }
  if ([bool]$deploy.timed_out) { throw 'Vercel production deployment timed out.' }
  if ([int]$deploy.exit_code -ne 0) { throw "Vercel production deployment failed: $($deploy.stderr)" }

  $deploymentUrl = $null
  $matches = [regex]::Matches(([string]$deploy.stdout),'https://[a-zA-Z0-9.-]+\.vercel\.app')
  if ($matches.Count -gt 0) { $deploymentUrl = [string]$matches[$matches.Count-1].Value }

  $verification = Test-CentralPowerTvCanonicalRelease
  if (-not [bool]$verification.verified) {
    throw 'Vercel deploy returned success but the canonical PowerTV alias did not expose the verified EVW release markers.'
  }

  return [ordered]@{
    status = 'deployed_verified'
    project = $script:CentralPowerTvVercelProject
    deployment_url = $deploymentUrl
    canonical_url = $script:CentralPowerTvCanonicalUrl
    source = $probe.source
    verification = $verification
    rights_policy = 'public_youtube_embeds_plus_official_ppv_link_only'
    transport = $deploy.transport
  }
}

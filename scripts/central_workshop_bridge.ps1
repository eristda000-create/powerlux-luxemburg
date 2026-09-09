param(
  [switch]$Once,
  [int]$PollSeconds = 30
)

$ErrorActionPreference = 'Stop'

function Get-EnvRequired([string]$Name) {
  $value = [Environment]::GetEnvironmentVariable($Name)
  if ([string]::IsNullOrWhiteSpace($value)) { throw "Missing required environment variable: $Name" }
  return $value
}

$SupabaseUrl = (Get-EnvRequired 'CENTRAL_SUPABASE_URL').TrimEnd('/')
$PublishableKey = Get-EnvRequired 'CENTRAL_SUPABASE_PUBLISHABLE_KEY'
$OwnerEmail = [Environment]::GetEnvironmentVariable('CENTRAL_SUPABASE_EMAIL')

$HostName = [System.Net.Dns]::GetHostName()
$NodeId = [Environment]::GetEnvironmentVariable('CENTRAL_WORKSHOP_NODE_ID')
if ([string]::IsNullOrWhiteSpace($NodeId)) { $NodeId = "$HostName-$env:USERNAME" }

$OllamaUrl = [Environment]::GetEnvironmentVariable('OLLAMA_URL')
if ([string]::IsNullOrWhiteSpace($OllamaUrl)) { $OllamaUrl = 'http://127.0.0.1:11434' }
$OllamaUrl = $OllamaUrl.TrimEnd('/')

$ObsidianVault = [Environment]::GetEnvironmentVariable('OBSIDIAN_VAULT')
$WorkDir = [Environment]::GetEnvironmentVariable('CENTRAL_WORKDIR')
$ConfiguredModel = [Environment]::GetEnvironmentVariable('CENTRAL_OLLAMA_MODEL')
$script:DetectedOllamaModel = $null

$TokenCachePath = [Environment]::GetEnvironmentVariable('CENTRAL_WORKSHOP_TOKEN_CACHE')
if ([string]::IsNullOrWhiteSpace($TokenCachePath)) {
  $TokenCachePath = Join-Path (Join-Path $HOME '.central') 'workshop-auth.json'
}

$script:AccessToken = $null
$script:RefreshToken = $null
$script:TokenExpiresAt = [DateTimeOffset]::MinValue
$script:LastCycleVerified = $false

function Convert-SecureStringToPlain([Security.SecureString]$Secure) {
  $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Secure)
  try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr) }
  finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
}

function Save-WorkshopSession {
  if (-not $IsWindows) { return }
  if ([string]::IsNullOrWhiteSpace($script:RefreshToken) -or [string]::IsNullOrWhiteSpace($OwnerEmail)) { return }

  $dir = Split-Path -Parent $TokenCachePath
  if (-not (Test-Path -LiteralPath $dir -PathType Container)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }

  $secure = ConvertTo-SecureString $script:RefreshToken -AsPlainText -Force
  $encrypted = ConvertFrom-SecureString $secure
  @{
    email = $OwnerEmail
    refresh_token_dpapi = $encrypted
    saved_at = [DateTimeOffset]::UtcNow.ToString('o')
  } | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $TokenCachePath -Encoding UTF8
}

function Clear-WorkshopSession {
  $script:AccessToken = $null
  $script:RefreshToken = $null
  $script:TokenExpiresAt = [DateTimeOffset]::MinValue
  if (Test-Path -LiteralPath $TokenCachePath -PathType Leaf) {
    Remove-Item -LiteralPath $TokenCachePath -Force -ErrorAction SilentlyContinue
  }
}

function Set-AuthTokens($Response) {
  $script:AccessToken = [string]$Response.access_token
  $script:RefreshToken = [string]$Response.refresh_token
  $expiresIn = if ($null -ne $Response.expires_in) { [int]$Response.expires_in } else { 3600 }
  $script:TokenExpiresAt = [DateTimeOffset]::UtcNow.AddSeconds($expiresIn)
  Save-WorkshopSession
}

function Refresh-CentralOwner {
  if ([string]::IsNullOrWhiteSpace($script:RefreshToken)) { throw 'No refresh token is available.' }
  $body = @{ refresh_token = $script:RefreshToken } | ConvertTo-Json -Compress
  $response = Invoke-RestMethod -Method Post -Uri "$SupabaseUrl/auth/v1/token?grant_type=refresh_token" -Headers @{ apikey = $PublishableKey } -ContentType 'application/json' -Body $body
  Set-AuthTokens $response
}

function Try-LoadCachedSession {
  if (-not $IsWindows) { return $false }
  if (-not (Test-Path -LiteralPath $TokenCachePath -PathType Leaf)) { return $false }

  try {
    $cache = Get-Content -LiteralPath $TokenCachePath -Raw | ConvertFrom-Json
    if ([string]::IsNullOrWhiteSpace($cache.email) -or [string]::IsNullOrWhiteSpace($cache.refresh_token_dpapi)) { return $false }

    if ([string]::IsNullOrWhiteSpace($script:OwnerEmail)) {
      $script:OwnerEmail = [string]$cache.email
    } elseif ($script:OwnerEmail.ToLowerInvariant() -ne ([string]$cache.email).ToLowerInvariant()) {
      return $false
    }

    $secure = ConvertTo-SecureString ([string]$cache.refresh_token_dpapi)
    $script:RefreshToken = Convert-SecureStringToPlain $secure
    Refresh-CentralOwner
    return $true
  } catch {
    Clear-WorkshopSession
    return $false
  }
}

function Login-CentralOwner {
  if ([string]::IsNullOrWhiteSpace($script:OwnerEmail)) {
    $script:OwnerEmail = Read-Host 'CENTRAL owner email'
  }
  $password = [Environment]::GetEnvironmentVariable('CENTRAL_SUPABASE_PASSWORD')
  if ([string]::IsNullOrWhiteSpace($password)) {
    $secure = Read-Host 'CENTRAL owner password' -AsSecureString
    $password = Convert-SecureStringToPlain $secure
  }
  try {
    $body = @{ email = $script:OwnerEmail; password = $password } | ConvertTo-Json -Compress
    $response = Invoke-RestMethod -Method Post -Uri "$SupabaseUrl/auth/v1/token?grant_type=password" -Headers @{ apikey = $PublishableKey } -ContentType 'application/json' -Body $body
    Set-AuthTokens $response
  } finally { $password = $null }
}

function Ensure-CentralSession {
  if (-not [string]::IsNullOrWhiteSpace($script:AccessToken) -and [DateTimeOffset]::UtcNow -lt $script:TokenExpiresAt.AddMinutes(-2)) { return }
  if (-not [string]::IsNullOrWhiteSpace($script:RefreshToken)) {
    try { Refresh-CentralOwner; return } catch { Clear-WorkshopSession }
  }
  if (Try-LoadCachedSession) { return }
  Login-CentralOwner
}

function Get-CentralHeaders {
  Ensure-CentralSession
  return @{ apikey = $PublishableKey; Authorization = "Bearer $script:AccessToken" }
}

function Invoke-CentralBridge([string]$Action, [hashtable]$Payload) {
  $body = @{ action = $Action; payload = $Payload } | ConvertTo-Json -Depth 20 -Compress
  $headers = Get-CentralHeaders
  try {
    return Invoke-RestMethod -Method Post -Uri "$SupabaseUrl/functions/v1/central-workshop-bridge" -Headers $headers -ContentType 'application/json' -Body $body
  } catch {
    $status = $null
    try { $status = $_.Exception.Response.StatusCode.value__ } catch {}
    if ($status -eq 401) {
      Clear-WorkshopSession
      Login-CentralOwner
      return Invoke-RestMethod -Method Post -Uri "$SupabaseUrl/functions/v1/central-workshop-bridge" -Headers (Get-CentralHeaders) -ContentType 'application/json' -Body $body
    }
    throw
  }
}

function Get-WorkshopTests {
  $tests = [ordered]@{
    powershell = 'ok'; ollama = 'error'; obsidian = 'not_configured'; git = 'not_checked';
    node_id = $NodeId; computer_name = $HostName; powershell_version = $PSVersionTable.PSVersion.ToString()
  }
  try {
    $tags = Invoke-RestMethod -Method Get -Uri "$OllamaUrl/api/tags" -TimeoutSec 8
    $models = @($tags.models | ForEach-Object { $_.name } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $tests.ollama = 'ok'
    $tests.ollama_models = $models
    if ([string]::IsNullOrWhiteSpace($ConfiguredModel) -and $models.Count -gt 0) {
      $script:DetectedOllamaModel = [string]$models[0]
    }
  } catch { $tests.ollama_error = $_.Exception.Message }

  if (-not [string]::IsNullOrWhiteSpace($ObsidianVault)) {
    if (Test-Path -LiteralPath $ObsidianVault -PathType Container) { $tests.obsidian = 'ok'; $tests.obsidian_vault = $ObsidianVault }
    else { $tests.obsidian = 'error'; $tests.obsidian_error = 'Configured vault path does not exist.' }
  }

  try {
    $gitVersion = (& git --version 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -eq 0) { $tests.git = 'ok'; $tests.git_version = $gitVersion } else { $tests.git = 'error' }
  } catch { $tests.git = 'error'; $tests.git_error = $_.Exception.Message }
  return $tests
}

function Send-Heartbeat($Tests) {
  $platform = if ($IsWindows) { 'windows-powershell' } elseif ($IsLinux) { 'linux-powershell' } elseif ($IsMacOS) { 'macos-powershell' } else { 'powershell' }
  $runtime = @{
    platform=$platform; powershell_version=$Tests.powershell_version; ollama_url=$OllamaUrl;
    obsidian_configured=-not [string]::IsNullOrWhiteSpace($ObsidianVault);
    workdir_configured=-not [string]::IsNullOrWhiteSpace($WorkDir);
    bridge_script='scripts/central_workshop_bridge.ps1'; token_cache_windows_dpapi=$IsWindows
  }
  return Invoke-CentralBridge 'heartbeat' @{ node_id=$NodeId; runtime=$runtime }
}

function Send-SelfTest($Tests) { return Invoke-CentralBridge 'self_test' @{ node_id=$NodeId; tests=$Tests } }

function Invoke-OllamaPrompt([object]$Payload) {
  $prompt = [string]$Payload.prompt
  if ([string]::IsNullOrWhiteSpace($prompt)) { throw 'ollama_prompt requires payload.prompt' }
  $model = [string]$Payload.model
  if ([string]::IsNullOrWhiteSpace($model)) { $model = $ConfiguredModel }
  if ([string]::IsNullOrWhiteSpace($model)) { $model = $script:DetectedOllamaModel }
  if ([string]::IsNullOrWhiteSpace($model)) { throw 'No Ollama model is configured or installed.' }
  $body = @{ model=$model; prompt=$prompt; stream=$false } | ConvertTo-Json -Depth 8 -Compress
  $response = Invoke-RestMethod -Method Post -Uri "$OllamaUrl/api/generate" -ContentType 'application/json' -Body $body -TimeoutSec 300
  return @{ action='ollama_prompt'; model=$model; response=$response.response }
}

function Invoke-GitStatus {
  if ([string]::IsNullOrWhiteSpace($WorkDir)) { throw 'CENTRAL_WORKDIR is not configured' }
  if (-not (Test-Path -LiteralPath $WorkDir -PathType Container)) { throw 'CENTRAL_WORKDIR does not exist' }
  $output = (& git -C $WorkDir status --short --branch 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) { throw "git status failed: $output" }
  return @{ action='git_status'; workdir=$WorkDir; output=$output }
}

function Invoke-GitDiff {
  if ([string]::IsNullOrWhiteSpace($WorkDir)) { throw 'CENTRAL_WORKDIR is not configured' }
  if (-not (Test-Path -LiteralPath $WorkDir -PathType Container)) { throw 'CENTRAL_WORKDIR does not exist' }
  $output = (& git -C $WorkDir diff --stat 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) { throw "git diff failed: $output" }
  return @{ action='git_diff'; workdir=$WorkDir; output=$output }
}

function Invoke-WorkshopTask([object]$Task, $Tests) {
  $action = [string]$Task.payload.action
  switch ($action) {
    'bridge_self_test' { return @{ verified=$true; result=@{ action=$action; tests=$Tests } } }
    'ollama_prompt' { return @{ verified=$true; result=(Invoke-OllamaPrompt $Task.payload) } }
    'git_status' { return @{ verified=$true; result=(Invoke-GitStatus) } }
    'git_diff' { return @{ verified=$true; result=(Invoke-GitDiff) } }
    default { return @{ verified=$false; result=@{ action=$action; error='Unsupported action. CENTRAL Workshop v1 does not execute arbitrary remote PowerShell commands.' } } }
  }
}

Write-Host "CENTRAL Workshop bridge starting as node: $NodeId"
Ensure-CentralSession

while ($true) {
  $script:LastCycleVerified = $false
  try {
    $tests = Get-WorkshopTests
    $null = Send-Heartbeat $tests
    $selfTest = Send-SelfTest $tests

    if ($selfTest.data.runtime_verified -eq $true) {
      $script:LastCycleVerified = $true
      $claim = Invoke-CentralBridge 'claim_next' @{ node_id=$NodeId }
      if ($null -ne $claim.data.task) {
        $task = $claim.data.task
        Write-Host "Claimed work item $($task.id): $($task.title)"
        try {
          $execution = Invoke-WorkshopTask $task $tests
          $completion = Invoke-CentralBridge 'complete' @{
            node_id=$NodeId; work_item_id=$task.id; result=$execution.result; verified=[bool]$execution.verified
          }
          Write-Host "Completed: status=$($completion.data.status), verified=$($completion.data.verified)"
        } catch {
          $null = Invoke-CentralBridge 'complete' @{
            node_id=$NodeId; work_item_id=$task.id; result=@{ action=[string]$task.payload.action; error=$_.Exception.Message }; verified=$false
          }
          Write-Warning $_.Exception.Message
        }
      }
    } else {
      Write-Warning 'Runtime is not verified. PowerShell and Ollama must both pass before jobs can be claimed.'
    }
  } catch { Write-Warning "Bridge cycle failed: $($_.Exception.Message)" }

  if ($Once) { break }
  Start-Sleep -Seconds ([Math]::Max(10,$PollSeconds))
}

if ($Once -and -not $script:LastCycleVerified) { exit 1 }

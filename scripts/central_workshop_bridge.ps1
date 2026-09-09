param(
  [switch]$Once,
  [int]$PollSeconds = 30
)

$ErrorActionPreference = 'Stop'

function Get-EnvRequired([string]$Name) {
  $value = [Environment]::GetEnvironmentVariable($Name)
  if ([string]::IsNullOrWhiteSpace($value)) {
    throw "Missing required environment variable: $Name"
  }
  return $value
}

$SupabaseUrl = (Get-EnvRequired 'CENTRAL_SUPABASE_URL').TrimEnd('/')
$ServiceRoleKey = Get-EnvRequired 'CENTRAL_SUPABASE_SERVICE_ROLE_KEY'
$NodeId = [Environment]::GetEnvironmentVariable('CENTRAL_WORKSHOP_NODE_ID')
if ([string]::IsNullOrWhiteSpace($NodeId)) {
  $NodeId = "$env:COMPUTERNAME-$env:USERNAME"
}

$OllamaUrl = [Environment]::GetEnvironmentVariable('OLLAMA_URL')
if ([string]::IsNullOrWhiteSpace($OllamaUrl)) { $OllamaUrl = 'http://127.0.0.1:11434' }
$OllamaUrl = $OllamaUrl.TrimEnd('/')

$ObsidianVault = [Environment]::GetEnvironmentVariable('OBSIDIAN_VAULT')
$WorkDir = [Environment]::GetEnvironmentVariable('CENTRAL_WORKDIR')
$DefaultModel = [Environment]::GetEnvironmentVariable('CENTRAL_OLLAMA_MODEL')
if ([string]::IsNullOrWhiteSpace($DefaultModel)) { $DefaultModel = 'llama3.2' }

$Headers = @{
  apikey = $ServiceRoleKey
  Authorization = "Bearer $ServiceRoleKey"
}

function Invoke-CentralRpc([string]$FunctionName, [hashtable]$Body) {
  $json = $Body | ConvertTo-Json -Depth 20 -Compress
  return Invoke-RestMethod -Method Post -Uri "$SupabaseUrl/rest/v1/rpc/$FunctionName" -Headers $Headers -ContentType 'application/json' -Body $json
}

function Get-WorkshopTests {
  $tests = [ordered]@{
    powershell = 'ok'
    ollama = 'error'
    obsidian = 'not_configured'
    git = 'not_checked'
    node_id = $NodeId
    computer_name = $env:COMPUTERNAME
    powershell_version = $PSVersionTable.PSVersion.ToString()
  }

  try {
    $tags = Invoke-RestMethod -Method Get -Uri "$OllamaUrl/api/tags" -TimeoutSec 8
    $tests.ollama = 'ok'
    $tests.ollama_models = @($tags.models | ForEach-Object { $_.name })
  } catch {
    $tests.ollama_error = $_.Exception.Message
  }

  if (-not [string]::IsNullOrWhiteSpace($ObsidianVault)) {
    if (Test-Path -LiteralPath $ObsidianVault -PathType Container) {
      $tests.obsidian = 'ok'
      $tests.obsidian_vault = $ObsidianVault
    } else {
      $tests.obsidian = 'error'
      $tests.obsidian_error = 'Configured vault path does not exist.'
    }
  }

  try {
    $gitVersion = (& git --version 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -eq 0) {
      $tests.git = 'ok'
      $tests.git_version = $gitVersion
    } else {
      $tests.git = 'error'
    }
  } catch {
    $tests.git = 'error'
    $tests.git_error = $_.Exception.Message
  }

  return $tests
}

function Send-Heartbeat($Tests) {
  $runtime = @{
    platform = 'windows-powershell'
    powershell_version = $Tests.powershell_version
    ollama_url = $OllamaUrl
    obsidian_configured = -not [string]::IsNullOrWhiteSpace($ObsidianVault)
    workdir_configured = -not [string]::IsNullOrWhiteSpace($WorkDir)
    bridge_script = 'scripts/central_workshop_bridge.ps1'
  }
  return Invoke-CentralRpc 'merg_workshop_heartbeat' @{
    p_node_id = $NodeId
    p_runtime = $runtime
  }
}

function Send-SelfTest($Tests) {
  return Invoke-CentralRpc 'merg_workshop_self_test' @{
    p_node_id = $NodeId
    p_tests = $Tests
  }
}

function Invoke-OllamaPrompt([object]$Payload) {
  $prompt = [string]$Payload.prompt
  if ([string]::IsNullOrWhiteSpace($prompt)) { throw 'ollama_prompt requires payload.prompt' }
  $model = [string]$Payload.model
  if ([string]::IsNullOrWhiteSpace($model)) { $model = $DefaultModel }

  $body = @{
    model = $model
    prompt = $prompt
    stream = $false
  } | ConvertTo-Json -Depth 8 -Compress

  $response = Invoke-RestMethod -Method Post -Uri "$OllamaUrl/api/generate" -ContentType 'application/json' -Body $body -TimeoutSec 300
  return @{
    action = 'ollama_prompt'
    model = $model
    response = $response.response
  }
}

function Invoke-GitStatus {
  if ([string]::IsNullOrWhiteSpace($WorkDir)) { throw 'CENTRAL_WORKDIR is not configured' }
  if (-not (Test-Path -LiteralPath $WorkDir -PathType Container)) { throw 'CENTRAL_WORKDIR does not exist' }
  $output = (& git -C $WorkDir status --short --branch 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) { throw "git status failed: $output" }
  return @{ action = 'git_status'; workdir = $WorkDir; output = $output }
}

function Invoke-GitDiff {
  if ([string]::IsNullOrWhiteSpace($WorkDir)) { throw 'CENTRAL_WORKDIR is not configured' }
  if (-not (Test-Path -LiteralPath $WorkDir -PathType Container)) { throw 'CENTRAL_WORKDIR does not exist' }
  $output = (& git -C $WorkDir diff --stat 2>&1 | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) { throw "git diff failed: $output" }
  return @{ action = 'git_diff'; workdir = $WorkDir; output = $output }
}

function Invoke-WorkshopTask([object]$Task, $Tests) {
  $action = [string]$Task.payload.action
  switch ($action) {
    'bridge_self_test' {
      return @{ verified = $true; result = @{ action = $action; tests = $Tests } }
    }
    'ollama_prompt' {
      return @{ verified = $true; result = (Invoke-OllamaPrompt $Task.payload) }
    }
    'git_status' {
      return @{ verified = $true; result = (Invoke-GitStatus) }
    }
    'git_diff' {
      return @{ verified = $true; result = (Invoke-GitDiff) }
    }
    default {
      return @{
        verified = $false
        result = @{
          action = $action
          error = 'Unsupported action. CENTRAL Workshop v1 does not execute arbitrary remote PowerShell commands.'
        }
      }
    }
  }
}

Write-Host "CENTRAL Workshop bridge starting as node: $NodeId"

while ($true) {
  try {
    $tests = Get-WorkshopTests
    $null = Send-Heartbeat $tests
    $selfTest = Send-SelfTest $tests

    if ($selfTest.runtime_verified -eq $true) {
      $claim = Invoke-CentralRpc 'merg_workshop_claim_next' @{ p_node_id = $NodeId }
      if ($null -ne $claim.task) {
        Write-Host "Claimed work item $($claim.task.id): $($claim.task.title)"
        try {
          $execution = Invoke-WorkshopTask $claim.task $tests
          $completion = Invoke-CentralRpc 'merg_workshop_complete' @{
            p_work_item_id = $claim.task.id
            p_node_id = $NodeId
            p_result = $execution.result
            p_verified = [bool]$execution.verified
          }
          Write-Host "Completed: status=$($completion.status), verified=$($completion.verified)"
        } catch {
          $errorResult = @{ action = [string]$claim.task.payload.action; error = $_.Exception.Message }
          $null = Invoke-CentralRpc 'merg_workshop_complete' @{
            p_work_item_id = $claim.task.id
            p_node_id = $NodeId
            p_result = $errorResult
            p_verified = $false
          }
          Write-Warning $_.Exception.Message
        }
      }
    } else {
      Write-Warning 'Runtime is not verified. PowerShell and Ollama must both pass the self-test before jobs can be claimed.'
    }
  } catch {
    Write-Warning "Bridge cycle failed: $($_.Exception.Message)"
  }

  if ($Once) { break }
  Start-Sleep -Seconds ([Math]::Max(10, $PollSeconds))
}

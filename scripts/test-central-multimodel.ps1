$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path -Parent $PSScriptRoot
$router = Join-Path $root 'scripts/central_model_router.ps1'
$supervisor = Join-Path $root 'scripts/central_supervisor.ps1'
$pull = Join-Path $root 'scripts/central_model_pull.ps1'
$autostart = Join-Path $root 'scripts/install-central-workshop-autostart.ps1'

foreach ($path in @($router,$supervisor,$pull,$autostart)) {
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing file: $path" }
  $tokens=$null; $errors=$null
  [void][System.Management.Automation.Language.Parser]::ParseFile($path,[ref]$tokens,[ref]$errors)
  if ($errors.Count -gt 0) { throw "PowerShell parse error in $path : $($errors[0].Message)" }
}

. $router

function Get-CentralOllamaModelNames {
  param([string]$OllamaUrl)
  return @(
    'qwen3.5:4b',
    'qwen3:4b-instruct',
    'qwen3.5:9b',
    'deepseek-r1:7b',
    'qwen2.5-coder:7b',
    'gemma3:4b',
    'nomic-embed-text:latest'
  )
}

$cases = @{
  fast = 'qwen3.5:4b'
  standard = 'qwen3:4b-instruct'
  deep = 'qwen3.5:9b'
  critic = 'deepseek-r1:7b'
  code = 'qwen2.5-coder:7b'
  vision = 'gemma3:4b'
}
foreach ($profile in $cases.Keys) {
  $route = Resolve-CentralModelProfile -OllamaUrl 'http://127.0.0.1:11434' -Profile $profile
  if ($route.model -ne $cases[$profile]) { throw "Profile $profile routed to $($route.model), expected $($cases[$profile])" }
}

$modeCases = @{
  bugfix = 'code'
  code_review = 'code'
  screenshot = 'vision'
  second_opinion = 'critic'
  strategy = 'deep'
  extract = 'fast'
}
foreach ($mode in $modeCases.Keys) {
  $resolved = Get-CentralRecommendedProfile -Payload ([pscustomobject]@{ mode=$mode })
  if ($resolved -ne $modeCases[$mode]) { throw "Mode $mode resolved to $resolved, expected $($modeCases[$mode])" }
}

$supervisorText = Get-Content -LiteralPath $supervisor -Raw
foreach ($model in @('qwen3.5:4b','qwen3:4b-instruct','qwen3.5:9b','deepseek-r1:7b','qwen2.5-coder:7b','gemma3:4b','nomic-embed-text:latest')) {
  if (-not $supervisorText.Contains("'$model'")) { throw "Supervisor model pool missing $model" }
}
if ($supervisorText -notmatch 'otherSupervisors') { throw 'Supervisor singleton guard is missing.' }
if ($supervisorText -notmatch 'one missing model per manager process|Pull exactly one missing model') { throw 'Sequential model-pool download guard is missing.' }
if ($supervisorText -match "'kimi-k3'") { throw 'Kimi K3 must not be auto-pulled on the 13.94 GB local node.' }

$pullText = Get-Content -LiteralPath $pull -Raw
foreach ($model in @('deepseek-r1:7b','qwen2.5-coder:7b','gemma3:4b')) {
  if (-not $pullText.Contains("'$model'")) { throw "Model-pull allowlist missing $model" }
}

$autostartText = Get-Content -LiteralPath $autostart -Raw
if ($autostartText -notmatch 'CurrentVersion\\Run') { throw 'Windows user-logon autostart registry path is missing.' }
if ($autostartText -notmatch 'central_supervisor\.ps1') { throw 'Autostart no longer targets the CENTRAL supervisor.' }

Write-Host 'CENTRAL_MULTIMODEL_AUTOSTART_GATE=PASS'

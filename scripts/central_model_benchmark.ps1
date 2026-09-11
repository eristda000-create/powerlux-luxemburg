Set-StrictMode -Version Latest

function Get-CentralBenchmarkElapsedTotal {
  param([object[]]$TaskResults)
  [long]$sum = 0
  foreach ($item in @($TaskResults)) {
    try { $sum += [long]$item.elapsed_ms } catch {}
  }
  return $sum
}

function Invoke-CentralModelBenchmark {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)][string]$OllamaUrl,
    [string[]]$Models,
    [int]$TimeoutSec = 180
  )

  if ($null -eq $Models -or $Models.Count -eq 0) {
    try {
      $tags = Invoke-RestMethod -Method Get -Uri "$($OllamaUrl.TrimEnd('/'))/api/tags" -TimeoutSec 8
      $Models = @($tags.models | ForEach-Object { [string]$_.name } | Where-Object { $_ -notmatch '(?i)(embed|embedding|minilm|bge)' })
    } catch { throw "Cannot list Ollama models: $($_.Exception.Message)" }
  }

  $tasks = @(
    [pscustomobject][ordered]@{ key='precision'; prompt='/no_think\nReturn exactly this token and nothing else: CENTRAL_OK'; expected='CENTRAL_OK' },
    [pscustomobject][ordered]@{ key='reasoning'; prompt='/no_think\nA system has 14 records, 13 published, and 5 published upcoming. How many published records are not upcoming? Return only the integer.'; expected='8' },
    [pscustomobject][ordered]@{ key='evidence'; prompt='/no_think\nGiven: FACT: source A says status=active. HYPOTHESIS: source B guesses status=blocked. Which status is supported? Return only active or blocked.'; expected='active' }
  )

  $results = [System.Collections.Generic.List[object]]::new()
  foreach ($model in ($Models | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and $_ -notmatch '(?i)(embed|embedding|minilm|bge)' } | Select-Object -Unique)) {
    $taskResults = [System.Collections.Generic.List[object]]::new()
    foreach ($task in $tasks) {
      $sw = [Diagnostics.Stopwatch]::StartNew()
      $ok = $false
      $responseText = ''
      $errorText = $null
      $evalCount = $null
      $evalDuration = $null
      try {
        $body = @{
          model = $model
          prompt = $task.prompt
          stream = $false
          keep_alive = '10m'
          options = @{ temperature=0; num_predict=80; num_ctx=4096 }
        } | ConvertTo-Json -Depth 8 -Compress
        $r = Invoke-RestMethod -Method Post -Uri "$($OllamaUrl.TrimEnd('/'))/api/generate" -ContentType 'application/json' -Body $body -TimeoutSec $TimeoutSec
        $responseText = ([string]$r.response).Trim()
        $ok = ($responseText -eq [string]$task.expected)
        $evalCount = $r.eval_count
        $evalDuration = $r.eval_duration
      } catch { $errorText = $_.Exception.Message }
      $sw.Stop()
      $taskResults.Add([pscustomobject][ordered]@{
        task = $task.key
        passed = $ok
        elapsed_ms = [long]$sw.ElapsedMilliseconds
        response = if ($responseText.Length -gt 160) { $responseText.Substring(0,160) } else { $responseText }
        error = $errorText
        eval_count = $evalCount
        eval_duration_ns = $evalDuration
      })
    }

    $passed = @($taskResults | Where-Object { [bool]$_.passed }).Count
    $elapsed = Get-CentralBenchmarkElapsedTotal -TaskResults @($taskResults)
    $results.Add([pscustomobject][ordered]@{
      model = $model
      passed = $passed
      total = $tasks.Count
      score_pct = [Math]::Round((100.0 * $passed / $tasks.Count),1)
      total_elapsed_ms = [long]$elapsed
      tasks = @($taskResults)
    })
  }

  $sorted = @($results | Sort-Object -Property @{Expression='score_pct';Descending=$true}, @{Expression='total_elapsed_ms';Descending=$false})
  return [ordered]@{
    schema = 'central_model_benchmark_v2'
    generated_at = [DateTimeOffset]::UtcNow.ToString('o')
    benchmark = $sorted
  }
}

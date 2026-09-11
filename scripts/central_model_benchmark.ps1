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
    [int]$TimeoutSec = 240
  )

  if ($null -eq $Models -or $Models.Count -eq 0) {
    try {
      $tags = Invoke-RestMethod -Method Get -Uri "$($OllamaUrl.TrimEnd('/'))/api/tags" -TimeoutSec 8
      $Models = @($tags.models | ForEach-Object { [string]$_.name } | Where-Object { $_ -notmatch '(?i)(embed|embedding|minilm|bge)' })
    } catch { throw "Cannot list Ollama models: $($_.Exception.Message)" }
  }

  # Benchmark v3 separates deterministic non-thinking behavior from one explicit thinking task.
  # Ollama exposes `think` as an API field; relying on /no_think in prompt text alone can produce false failures.
  $tasks = @(
    [pscustomobject][ordered]@{
      key='precision';
      prompt='Return exactly this token and nothing else: CENTRAL_OK';
      expected='CENTRAL_OK';
      think=$false;
      num_predict=16;
      temperature=0.0;
      top_p=1.0;
      top_k=20
    },
    [pscustomobject][ordered]@{
      key='reasoning';
      prompt='A system has 14 records, 13 published, and 5 published upcoming. How many published records are not upcoming? Return only the integer.';
      expected='8';
      think=$false;
      num_predict=32;
      temperature=0.0;
      top_p=1.0;
      top_k=20
    },
    [pscustomobject][ordered]@{
      key='evidence';
      prompt='Given: FACT: source A says status=active. HYPOTHESIS: source B guesses status=blocked. Which status is supported? Return only active or blocked.';
      expected='active';
      think=$false;
      num_predict=32;
      temperature=0.0;
      top_p=1.0;
      top_k=20
    },
    [pscustomobject][ordered]@{
      key='deep_reasoning';
      prompt='Three initiatives have scores defined as 2*value + speed - 2*risk. A: value=8 speed=4 risk=2. B: value=6 speed=5 risk=1. C: value=9 speed=2 risk=4. Which initiative has the highest score? Return only A, B, or C in the final answer.';
      expected='A';
      think=$true;
      num_predict=160;
      temperature=0.6;
      top_p=0.95;
      top_k=20
    }
  )

  $results = [System.Collections.Generic.List[object]]::new()
  foreach ($model in ($Models | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and $_ -notmatch '(?i)(embed|embedding|minilm|bge)' } | Select-Object -Unique)) {
    $taskResults = [System.Collections.Generic.List[object]]::new()
    foreach ($task in $tasks) {
      $sw = [Diagnostics.Stopwatch]::StartNew()
      $ok = $false
      $responseText = ''
      $thinkingText = ''
      $errorText = $null
      $evalCount = $null
      $evalDuration = $null
      try {
        $body = @{
          model = $model
          prompt = $task.prompt
          stream = $false
          think = [bool]$task.think
          keep_alive = '10m'
          options = @{
            temperature = [double]$task.temperature
            top_p = [double]$task.top_p
            top_k = [int]$task.top_k
            num_predict = [int]$task.num_predict
            num_ctx = 4096
          }
        } | ConvertTo-Json -Depth 8 -Compress
        $r = Invoke-RestMethod -Method Post -Uri "$($OllamaUrl.TrimEnd('/'))/api/generate" -ContentType 'application/json' -Body $body -TimeoutSec $TimeoutSec
        $responseText = ([string]$r.response).Trim()
        if ($null -ne $r.PSObject.Properties['thinking']) { $thinkingText = ([string]$r.thinking).Trim() }
        $ok = ($responseText -eq [string]$task.expected)
        $evalCount = $r.eval_count
        $evalDuration = $r.eval_duration
      } catch { $errorText = $_.Exception.Message }
      $sw.Stop()
      $taskResults.Add([pscustomobject][ordered]@{
        task = $task.key
        think = [bool]$task.think
        passed = $ok
        expected = [string]$task.expected
        elapsed_ms = [long]$sw.ElapsedMilliseconds
        response = if ($responseText.Length -gt 200) { $responseText.Substring(0,200) } else { $responseText }
        thinking_chars = $thinkingText.Length
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
    schema = 'central_model_benchmark_v3'
    generated_at = [DateTimeOffset]::UtcNow.ToString('o')
    benchmark = $sorted
  }
}

Set-StrictMode -Version Latest

function Test-CentralRagOllamaModelInstalled {
  param([string]$OllamaUrl,[string]$Model)
  try {
    $tags = Invoke-RestMethod -Method Get -Uri "$($OllamaUrl.TrimEnd('/'))/api/tags" -TimeoutSec 5
    $names = @($tags.models | ForEach-Object { [string]$_.name })
    return [bool]($names | Where-Object { $_ -eq $Model -or $_ -like "$Model*" } | Select-Object -First 1)
  } catch { return $false }
}

function Invoke-CentralRagEmbedBatch {
  param([string]$OllamaUrl,[string]$Model,[string[]]$Inputs,[int]$TimeoutSec=90)
  if (-not (Test-CentralRagOllamaModelInstalled -OllamaUrl $OllamaUrl -Model $Model)) {
    throw "Embedding model is not installed in Ollama: $Model"
  }
  $body = @{ model=$Model; input=@($Inputs); truncate=$true; keep_alive='10m' } | ConvertTo-Json -Depth 8 -Compress
  $response = Invoke-RestMethod -Method Post -Uri "$($OllamaUrl.TrimEnd('/'))/api/embed" -ContentType 'application/json' -Body $body -TimeoutSec $TimeoutSec
  $vectors = @($response.embeddings)
  if ($vectors.Count -ne $Inputs.Count) { throw "Unexpected embedding count. expected=$($Inputs.Count) actual=$($vectors.Count)" }
  return $vectors
}

function Get-CentralRagCosineSimilarity {
  param([object[]]$A,[object[]]$B)
  if ($A.Count -eq 0 -or $A.Count -ne $B.Count) { return 0.0 }
  [double]$dot=0; [double]$na=0; [double]$nb=0
  for ($i=0; $i -lt $A.Count; $i++) {
    [double]$av=$A[$i]; [double]$bv=$B[$i]
    $dot += $av*$bv; $na += $av*$av; $nb += $bv*$bv
  }
  if ($na -le 0 -or $nb -le 0) { return 0.0 }
  return $dot / ([Math]::Sqrt($na) * [Math]::Sqrt($nb))
}

function Get-CentralRagTerms {
  param([string]$Text)
  if ([string]::IsNullOrWhiteSpace($Text)) { return @() }
  return @(([regex]::Matches($Text.ToLowerInvariant(),'[\p{L}\p{N}_-]{3,}')) | ForEach-Object { $_.Value } | Select-Object -Unique)
}

function Split-CentralMarkdownChunks {
  param([string]$Text,[string]$Path,[DateTime]$Modified,[int]$MaxChunkChars=1800)
  $chunks = [System.Collections.Generic.List[object]]::new()
  $heading = '(document start)'
  $buffer = [System.Collections.Generic.List[string]]::new()

  function Flush-Chunk([string]$CurrentHeading,[System.Collections.Generic.List[string]]$Lines) {
    if ($Lines.Count -eq 0) { return }
    $raw = ($Lines -join "`n").Trim()
    if ([string]::IsNullOrWhiteSpace($raw)) { $Lines.Clear(); return }
    $offset = 0
    while ($offset -lt $raw.Length) {
      $take = [Math]::Min($MaxChunkChars,$raw.Length-$offset)
      $part = $raw.Substring($offset,$take)
      $chunks.Add([pscustomobject]@{ path=$Path; heading=$CurrentHeading; content=$part; modified=$Modified })
      $offset += $take
    }
    $Lines.Clear()
  }

  foreach ($line in ($Text -split "`r?`n")) {
    if ($line -match '^\s{0,3}(#{1,6})\s+(.+?)\s*$') {
      Flush-Chunk -CurrentHeading $heading -Lines $buffer
      $heading = $Matches[2].Trim()
      $buffer.Add($line)
    } else {
      $buffer.Add($line)
      $currentLen = (($buffer -join "`n").Length)
      if ($currentLen -ge $MaxChunkChars) { Flush-Chunk -CurrentHeading $heading -Lines $buffer }
    }
  }
  Flush-Chunk -CurrentHeading $heading -Lines $buffer
  return @($chunks)
}

function Get-CentralObsidianRagContextV2 {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)][string]$Vault,
    [Parameter(Mandatory=$true)][string]$Query,
    [Parameter(Mandatory=$true)][string]$OllamaUrl,
    [string]$EmbeddingModel=$env:CENTRAL_OLLAMA_EMBED_MODEL,
    [string]$Project='central',
    [int]$TopK=5,
    [int]$MaxFiles=120,
    [int]$LexicalPrefilter=28,
    [int]$MaxChunkChars=1800,
    [int]$MaxSnippetChars=1100
  )

  if ([string]::IsNullOrWhiteSpace($EmbeddingModel)) { $EmbeddingModel='nomic-embed-text' }
  if ([string]::IsNullOrWhiteSpace($Query)) { return @() }
  if ([string]::IsNullOrWhiteSpace($Vault) -or -not (Test-Path -LiteralPath $Vault -PathType Container)) { throw 'Obsidian vault is unavailable.' }
  $centralRoot = Join-Path $Vault 'CENTRAL'
  if (-not (Test-Path -LiteralPath $centralRoot -PathType Container)) { throw 'CENTRAL knowledge mount is missing.' }

  $files = @(Get-ChildItem -LiteralPath $centralRoot -Recurse -File -Filter '*.md' -ErrorAction Stop |
    Where-Object {
      $rel=$_.FullName.Substring($centralRoot.Length).TrimStart([char[]]'\\/')
      $norm='/' + $rel.Replace('\\','/').ToLowerInvariant()
      $norm -notmatch '/(inbox|drafts|archive|central_lab)/'
    } | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First ([Math]::Max(1,[Math]::Min(300,$MaxFiles))))

  $queryTerms = @(Get-CentralRagTerms -Text $Query)
  $projectTerm = ([string]$Project).Trim().ToLowerInvariant()
  $now = [DateTime]::UtcNow
  $candidates = [System.Collections.Generic.List[object]]::new()

  foreach ($file in $files) {
    try {
      $text = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop
      if ([string]::IsNullOrWhiteSpace($text)) { continue }
      $rel = 'CENTRAL/' + $file.FullName.Substring($centralRoot.Length).TrimStart([char[]]'\\/').Replace('\\','/')
      foreach ($chunk in @(Split-CentralMarkdownChunks -Text $text -Path $rel -Modified $file.LastWriteTimeUtc -MaxChunkChars $MaxChunkChars)) {
        $hay = ($chunk.heading + " `n" + $chunk.content).ToLowerInvariant()
        [double]$lex=0
        foreach ($term in $queryTerms) {
          $count = ([regex]::Matches($hay,[regex]::Escape($term))).Count
          if ($count -gt 0) { $lex += [Math]::Min(3,$count) }
        }
        if (-not [string]::IsNullOrWhiteSpace($projectTerm) -and $chunk.path.ToLowerInvariant().Contains('/' + $projectTerm + '/')) { $lex += 4 }
        if ($chunk.path.ToLowerInvariant().Contains('operating_model') -or $chunk.path.ToLowerInvariant().Contains('00_home')) { $lex += 0.5 }
        $ageDays = [Math]::Max(0,($now-$chunk.modified.ToUniversalTime()).TotalDays)
        $recency = 1.0 / (1.0 + ($ageDays / 30.0))
        $candidates.Add([pscustomobject]@{ path=$chunk.path; heading=$chunk.heading; content=$chunk.content; lexical=$lex; recency=$recency; modified=$chunk.modified })
      }
    } catch {}
  }

  if ($candidates.Count -eq 0) { return @() }
  $prefiltered = @($candidates | Sort-Object @{Expression='lexical';Descending=$true}, @{Expression='recency';Descending=$true} | Select-Object -First ([Math]::Max(8,[Math]::Min(60,$LexicalPrefilter))))

  $useVectors = Test-CentralRagOllamaModelInstalled -OllamaUrl $OllamaUrl -Model $EmbeddingModel
  $vectors = @()
  if ($useVectors) {
    try {
      $inputs = @([string]$Query) + @($prefiltered | ForEach-Object { "PATH: $($_.path)`nHEADING: $($_.heading)`n$($_.content)" })
      $vectors = @(Invoke-CentralRagEmbedBatch -OllamaUrl $OllamaUrl -Model $EmbeddingModel -Inputs $inputs -TimeoutSec 120)
    } catch { $useVectors = $false }
  }

  $maxLex = [double](($prefiltered | Measure-Object -Property lexical -Maximum).Maximum)
  if ($maxLex -le 0) { $maxLex = 1 }
  $ranked = [System.Collections.Generic.List[object]]::new()
  for ($i=0; $i -lt $prefiltered.Count; $i++) {
    $item=$prefiltered[$i]
    [double]$vector=0
    if ($useVectors -and $vectors.Count -gt ($i+1)) { $vector=Get-CentralRagCosineSimilarity -A @($vectors[0]) -B @($vectors[$i+1]) }
    [double]$lexNorm=[Math]::Min(1.0,([double]$item.lexical/$maxLex))
    [double]$final = if ($useVectors) { (0.62*$vector)+(0.28*$lexNorm)+(0.10*[double]$item.recency) } else { (0.80*$lexNorm)+(0.20*[double]$item.recency) }
    $text=[string]$item.content
    if ($text.Length -gt $MaxSnippetChars) { $text=$text.Substring(0,$MaxSnippetChars) }
    $ranked.Add([pscustomobject]@{
      path=[string]$item.path
      heading=[string]$item.heading
      score=[Math]::Round($final,6)
      vector_score=[Math]::Round($vector,6)
      lexical_score=[Math]::Round($lexNorm,6)
      recency_score=[Math]::Round([double]$item.recency,6)
      content=$text
      embedding_model=if($useVectors){$EmbeddingModel}else{'lexical_fallback'}
    })
  }

  return @($ranked | Sort-Object score -Descending | Select-Object -First ([Math]::Max(1,[Math]::Min(10,$TopK))))
}

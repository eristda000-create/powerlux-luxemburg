Set-StrictMode -Version Latest

function Test-CentralOllamaModelInstalled {
  param(
    [Parameter(Mandatory=$true)][string]$OllamaUrl,
    [Parameter(Mandatory=$true)][string]$Model
  )
  try {
    $tags = Invoke-RestMethod -Method Get -Uri "$($OllamaUrl.TrimEnd('/'))/api/tags" -TimeoutSec 5
    $names = @($tags.models | ForEach-Object { [string]$_.name })
    return [bool]($names | Where-Object { $_ -eq $Model -or $_ -like "$Model*" } | Select-Object -First 1)
  } catch { return $false }
}

function Get-CentralCosineSimilarity {
  param(
    [Parameter(Mandatory=$true)][object[]]$A,
    [Parameter(Mandatory=$true)][object[]]$B
  )
  if ($A.Count -eq 0 -or $A.Count -ne $B.Count) { return 0.0 }
  [double]$dot = 0.0
  [double]$normA = 0.0
  [double]$normB = 0.0
  for ($i = 0; $i -lt $A.Count; $i++) {
    [double]$av = [double]$A[$i]
    [double]$bv = [double]$B[$i]
    $dot += $av * $bv
    $normA += $av * $av
    $normB += $bv * $bv
  }
  if ($normA -le 0 -or $normB -le 0) { return 0.0 }
  return ($dot / ([Math]::Sqrt($normA) * [Math]::Sqrt($normB)))
}

function Invoke-CentralOllamaEmbedBatch {
  param(
    [Parameter(Mandatory=$true)][string]$OllamaUrl,
    [Parameter(Mandatory=$true)][string]$Model,
    [Parameter(Mandatory=$true)][string[]]$Inputs,
    [int]$TimeoutSec = 90
  )

  if (-not (Test-CentralOllamaModelInstalled -OllamaUrl $OllamaUrl -Model $Model)) {
    throw "Embedding model is not installed in Ollama: $Model"
  }

  $body = @{
    model = $Model
    input = @($Inputs)
    truncate = $true
    keep_alive = '10m'
  } | ConvertTo-Json -Depth 8 -Compress

  $response = Invoke-RestMethod -Method Post -Uri "$($OllamaUrl.TrimEnd('/'))/api/embed" -ContentType 'application/json' -Body $body -TimeoutSec $TimeoutSec
  $vectors = @($response.embeddings)
  if ($vectors.Count -ne $Inputs.Count) {
    throw "Unexpected embedding count. expected=$($Inputs.Count) actual=$($vectors.Count)"
  }
  return $vectors
}

function Get-CentralObsidianRagContext {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)][string]$Vault,
    [Parameter(Mandatory=$true)][string]$Query,
    [Parameter(Mandatory=$true)][string]$OllamaUrl,
    [string]$EmbeddingModel = $env:CENTRAL_OLLAMA_EMBED_MODEL,
    [int]$TopK = 3,
    [int]$MaxFiles = 60,
    [int]$MaxCharsPerFile = 5000,
    [int]$MaxSnippetChars = 1400
  )

  if ([string]::IsNullOrWhiteSpace($EmbeddingModel)) { $EmbeddingModel = 'nomic-embed-text' }
  if ([string]::IsNullOrWhiteSpace($Query)) { return @() }
  if ([string]::IsNullOrWhiteSpace($Vault) -or -not (Test-Path -LiteralPath $Vault -PathType Container)) {
    throw 'Obsidian vault is not configured or does not exist.'
  }

  $centralRoot = Join-Path $Vault 'CENTRAL'
  if (-not (Test-Path -LiteralPath $centralRoot -PathType Container)) {
    throw 'CENTRAL knowledge mount is not present inside the Obsidian vault.'
  }

  $files = @(Get-ChildItem -LiteralPath $centralRoot -Recurse -File -Filter '*.md' -ErrorAction Stop |
    Where-Object {
      $relative = $_.FullName.Substring($centralRoot.Length).TrimStart([char[]]'\/')
      $normalized = '/' + $relative.Replace('\','/').ToLowerInvariant()
      $normalized -notmatch '/(inbox|drafts|archive)/'
    } |
    Sort-Object FullName |
    Select-Object -First ([Math]::Max(1,[Math]::Min(200,$MaxFiles))))

  if ($files.Count -eq 0) { return @() }

  $paths = [System.Collections.Generic.List[string]]::new()
  $texts = [System.Collections.Generic.List[string]]::new()
  foreach ($file in $files) {
    try {
      $text = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop
      if ([string]::IsNullOrWhiteSpace($text)) { continue }
      $take = [Math]::Min($text.Length, [Math]::Max(500,[Math]::Min(8000,$MaxCharsPerFile)))
      $snippet = $text.Substring(0,$take)
      $relative = 'CENTRAL/' + $file.FullName.Substring($centralRoot.Length).TrimStart([char[]]'\/').Replace('\','/')
      $paths.Add($relative)
      $texts.Add($snippet)
    } catch {}
  }

  if ($texts.Count -eq 0) { return @() }

  $inputs = @([string]$Query) + @($texts)
  $vectors = Invoke-CentralOllamaEmbedBatch -OllamaUrl $OllamaUrl -Model $EmbeddingModel -Inputs $inputs
  $queryVector = @($vectors[0])

  $ranked = [System.Collections.Generic.List[object]]::new()
  for ($i = 0; $i -lt $texts.Count; $i++) {
    $score = Get-CentralCosineSimilarity -A $queryVector -B @($vectors[$i + 1])
    $text = [string]$texts[$i]
    $take = [Math]::Min($text.Length,[Math]::Max(400,[Math]::Min(2500,$MaxSnippetChars)))
    $ranked.Add([pscustomobject]@{
      path = [string]$paths[$i]
      score = [Math]::Round([double]$score,6)
      content = $text.Substring(0,$take)
      embedding_model = $EmbeddingModel
    })
  }

  return @($ranked | Sort-Object score -Descending | Select-Object -First ([Math]::Max(1,[Math]::Min(8,$TopK))))
}

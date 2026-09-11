$ErrorActionPreference = 'Stop'

$helper = Join-Path $PSScriptRoot 'central_obsidian_rag.ps1'
if (-not (Test-Path -LiteralPath $helper -PathType Leaf)) { throw 'RAG helper missing.' }
. $helper

$required = @('Get-CentralCosineSimilarity','Invoke-CentralOllamaEmbedBatch','Get-CentralObsidianRagContext')
foreach ($name in $required) {
  if ($null -eq (Get-Command $name -ErrorAction SilentlyContinue)) { throw "Missing function: $name" }
}

$same = Get-CentralCosineSimilarity -A @(1.0,0.0,0.0) -B @(1.0,0.0,0.0)
$orthogonal = Get-CentralCosineSimilarity -A @(1.0,0.0) -B @(0.0,1.0)
if ([Math]::Abs($same - 1.0) -gt 0.000001) { throw "Cosine self-test failed: $same" }
if ([Math]::Abs($orthogonal) -gt 0.000001) { throw "Cosine orthogonal test failed: $orthogonal" }

$result = [ordered]@{
  rag_helper = 'present'
  functions = $required
  cosine_identical = $same
  cosine_orthogonal = $orthogonal
  default_embedding_model = 'nomic-embed-text'
  live_embedding_test = 'not_run_in_ci'
  safety = 'CENTRAL-only; INBOX/DRAFTS/ARCHIVE excluded by helper'
}
$result | ConvertTo-Json -Depth 5

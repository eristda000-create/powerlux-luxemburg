Set-StrictMode -Version Latest

function New-CentralContextCapsule {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)][string]$Project,
    [Parameter(Mandatory=$true)][string]$Objective,
    [string[]]$MandatorySources = @(),
    [object[]]$RagHits = @(),
    [int]$MaxChars = 5000
  )

  $projectName = if ([string]::IsNullOrWhiteSpace($Project)) { 'central' } else { $Project.Trim().ToLowerInvariant() }
  $sections = [System.Collections.Generic.List[string]]::new()
  $sections.Add("PROJECT: $projectName")
  $sections.Add("OBJECTIVE: $Objective")
  if ($MandatorySources.Count -gt 0) {
    $sections.Add("MANDATORY SOURCES: " + ($MandatorySources -join ', '))
  }

  if ($RagHits.Count -gt 0) {
    $evidence = [System.Collections.Generic.List[string]]::new()
    foreach ($hit in ($RagHits | Select-Object -First 6)) {
      $heading = ''
      try { $heading = [string]$hit.heading } catch {}
      $label = "[$([string]$hit.path)"
      if (-not [string]::IsNullOrWhiteSpace($heading)) { $label += " :: $heading" }
      $label += " | score=$([string]$hit.score)]"
      $content = [string]$hit.content
      if ($content.Length -gt 900) { $content = $content.Substring(0,900) }
      $evidence.Add("$label`n$content")
    }
    $sections.Add("RETRIEVED EVIDENCE:`n" + ($evidence -join "`n---`n"))
  }

  $sections.Add(@"
REASONING CONTRACT:
- Distinguish FACT / INFERENCE / HYPOTHESIS / OPEN.
- Prefer current owning sources over memory.
- Do not convert missing evidence into a claim.
- Identify contradictions explicitly.
- Prefer the smallest reversible next action.
- If controller/cloud/web verification is required, say CONTROLLER_NEEDED and name the exact evidence gap.
"@)

  $text = $sections -join "`n`n"
  if ($text.Length -gt $MaxChars) { $text = $text.Substring(0,$MaxChars) }

  return [ordered]@{
    schema = 'central_context_capsule_v1'
    project = $projectName
    objective = $Objective
    chars = $text.Length
    text = $text
    rag_hit_count = $RagHits.Count
  }
}

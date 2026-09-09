function ConvertTo-CentralContextPacketText {
  param(
    [Parameter(Mandatory=$true)][object]$Packet,
    [int]$MaxChars = 12000
  )

  $allowedLabels = @('FACT','CONNECTOR_FACT','USER_FACT','OPEN','QWEN_DRAFT','REJECTED')
  $version = [string]$Packet.packet_version
  if ([string]::IsNullOrWhiteSpace($version)) { throw 'Context packet is missing packet_version.' }

  $status = [string]$Packet.packet_status
  if ([string]::IsNullOrWhiteSpace($status)) { $status = 'UNSPECIFIED' }

  $lines = [System.Collections.Generic.List[string]]::new()
  $lines.Add("CENTRAL VERIFIED CONTEXT PACKET $version")
  $lines.Add("STATUS: $status")

  if ($null -ne $Packet.scope) {
    $scope = @($Packet.scope | ForEach-Object { [string]$_ } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($scope.Count -gt 0) { $lines.Add('SCOPE: ' + ($scope -join ', ')) }
  }

  $lines.Add('')
  $lines.Add('EVIDENCE RULE: FACT/CONNECTOR_FACT are authoritative until superseded; USER_FACT is user-supplied; OPEN is unresolved; QWEN_DRAFT is advisory only; REJECTED must not be reused as fact.')

  if ($null -ne $Packet.rules) {
    $lines.Add('')
    $lines.Add('RULES:')
    foreach ($rule in @($Packet.rules | Select-Object -First 12)) {
      $text = ([string]$rule).Trim()
      if (-not [string]::IsNullOrWhiteSpace($text)) { $lines.Add("- $text") }
    }
  }

  if ($null -ne $Packet.facts) {
    $lines.Add('')
    $lines.Add('FACTS:')
    foreach ($fact in @($Packet.facts | Select-Object -First 40)) {
      $label = ([string]$fact.label).Trim().ToUpperInvariant()
      if ($allowedLabels -notcontains $label) { throw "Unsupported context label: $label" }
      $source = ([string]$fact.source).Trim()
      $asOf = ([string]$fact.as_of).Trim()
      $text = ([string]$fact.text).Trim()
      if ([string]::IsNullOrWhiteSpace($text)) { continue }
      $prefix = "[$label]"
      if (-not [string]::IsNullOrWhiteSpace($source)) { $prefix += "[$source]" }
      if (-not [string]::IsNullOrWhiteSpace($asOf)) { $prefix += "[$asOf]" }
      $lines.Add("$prefix $text")
    }
  }

  if ($null -ne $Packet.current_objectives) {
    $lines.Add('')
    $lines.Add('CURRENT OBJECTIVES:')
    foreach ($objective in @($Packet.current_objectives | Select-Object -First 12)) {
      $text = ([string]$objective).Trim()
      if (-not [string]::IsNullOrWhiteSpace($text)) { $lines.Add("- $text") }
    }
  }

  $lines.Add('')
  $lines.Add('AGENT RULES:')
  $lines.Add('- Never convert OPEN, USER_FACT or QWEN_DRAFT into independently verified facts.')
  $lines.Add('- Never reuse REJECTED material.')
  $lines.Add('- Never invent people, athletes, results, sponsors, links, rights, partnerships, availability or production state.')
  $lines.Add('- No external actions unless the work item explicitly carries a separately approved capability.')

  $textOut = ($lines -join "`n")
  $limit = [Math]::Max(3000,[Math]::Min(20000,$MaxChars))
  if ($textOut.Length -gt $limit) { $textOut = $textOut.Substring(0,$limit) + "`n[PACKET TRUNCATED]" }
  return $textOut
}

function New-CentralBrokeredPrompt {
  param(
    [Parameter(Mandatory=$true)][object]$Packet,
    [Parameter(Mandatory=$true)][string]$Objective,
    [string]$Role = 'CENTRAL local Qwen worker',
    [int]$MaxPacketChars = 10000
  )

  if ([string]::IsNullOrWhiteSpace($Objective)) { throw 'Objective is required.' }
  $packetText = ConvertTo-CentralContextPacketText -Packet $Packet -MaxChars $MaxPacketChars

  return @"
You are $Role.

OBJECTIVE:
$Objective

Use ONLY the evidence packet below as project context. Separate verified facts from user facts, open items and model drafts. If the packet lacks evidence for a claim, say UNVERIFIED. Do not invent successful actions. Do not perform external actions.

$packetText
"@
}

Set-StrictMode -Version Latest

function Get-CentralHardwareInventory {
  [CmdletBinding()]
  param(
    [string]$OllamaUrl = 'http://127.0.0.1:11434'
  )

  $result = [ordered]@{
    captured_at = [DateTimeOffset]::UtcNow.ToString('o')
    platform = if ($IsWindows) { 'windows' } elseif ($IsLinux) { 'linux' } elseif ($IsMacOS) { 'macos' } else { 'unknown' }
    powershell_version = $PSVersionTable.PSVersion.ToString()
    cpu = @{}
    memory = @{}
    gpu = @()
    disks = @()
    ollama = [ordered]@{ status='unknown'; models=@() }
  }

  if ($IsWindows) {
    try {
      $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
      $result.memory = [ordered]@{
        total_gb = [Math]::Round(([double]$cs.TotalPhysicalMemory / 1GB), 2)
        manufacturer = [string]$cs.Manufacturer
        model = [string]$cs.Model
      }
    } catch { $result.memory = @{ error=$_.Exception.Message } }

    try {
      $cpus = @(Get-CimInstance Win32_Processor -ErrorAction Stop)
      $result.cpu = [ordered]@{
        names = @($cpus | ForEach-Object { [string]$_.Name })
        physical_cores = [int](($cpus | Measure-Object -Property NumberOfCores -Sum).Sum)
        logical_processors = [int](($cpus | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum)
      }
    } catch { $result.cpu = @{ error=$_.Exception.Message } }

    try {
      $result.gpu = @(Get-CimInstance Win32_VideoController -ErrorAction Stop | ForEach-Object {
        [ordered]@{
          name = [string]$_.Name
          adapter_ram_gb = if ($null -ne $_.AdapterRAM) { [Math]::Round(([double]$_.AdapterRAM / 1GB),2) } else { $null }
          driver_version = [string]$_.DriverVersion
        }
      })
    } catch { $result.gpu = @(@{ error=$_.Exception.Message }) }

    try {
      $result.disks = @(Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        [ordered]@{
          name = $_.Name
          root = $_.Root
          free_gb = [Math]::Round(([double]$_.Free / 1GB),2)
          used_gb = [Math]::Round(([double]$_.Used / 1GB),2)
        }
      })
    } catch {}
  }

  $nvidiaSmi = Get-Command nvidia-smi -ErrorAction SilentlyContinue
  if ($null -ne $nvidiaSmi) {
    try {
      $rows = @(& $nvidiaSmi.Source --query-gpu=name,memory.total,memory.free,driver_version --format=csv,noheader,nounits 2>$null)
      if ($LASTEXITCODE -eq 0 -and $rows.Count -gt 0) {
        $result.gpu = @($rows | ForEach-Object {
          $parts = $_ -split ',' | ForEach-Object { $_.Trim() }
          [ordered]@{
            name = if ($parts.Count -gt 0) { $parts[0] } else { '' }
            vram_total_mb = if ($parts.Count -gt 1) { [int]$parts[1] } else { $null }
            vram_free_mb = if ($parts.Count -gt 2) { [int]$parts[2] } else { $null }
            driver_version = if ($parts.Count -gt 3) { $parts[3] } else { '' }
            source = 'nvidia-smi'
          }
        })
      }
    } catch {}
  }

  try {
    $tags = Invoke-RestMethod -Method Get -Uri "$($OllamaUrl.TrimEnd('/'))/api/tags" -TimeoutSec 8
    $result.ollama.status = 'ok'
    $result.ollama.models = @($tags.models | ForEach-Object {
      [ordered]@{
        name = [string]$_.name
        size_gb = if ($null -ne $_.size) { [Math]::Round(([double]$_.size / 1GB),2) } else { $null }
        modified_at = [string]$_.modified_at
      }
    })
  } catch {
    $result.ollama.status = 'error'
    $result.ollama.error = $_.Exception.Message
  }

  return $result
}

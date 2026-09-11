Set-StrictMode -Version Latest

function Invoke-CentralProcessWithTimeout {
  param(
    [Parameter(Mandatory=$true)][string]$FilePath,
    [string[]]$Arguments = @(),
    [int]$TimeoutSeconds = 8
  )

  $psi = [System.Diagnostics.ProcessStartInfo]::new()
  $psi.FileName = $FilePath
  $psi.UseShellExecute = $false
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.CreateNoWindow = $true
  foreach ($arg in $Arguments) { [void]$psi.ArgumentList.Add($arg) }

  $p = [System.Diagnostics.Process]::new()
  $p.StartInfo = $psi
  try {
    if (-not $p.Start()) { throw "Unable to start process: $FilePath" }
    if (-not $p.WaitForExit([Math]::Max(1,$TimeoutSeconds) * 1000)) {
      try { $p.Kill($true) } catch {}
      throw "Process timed out after $TimeoutSeconds seconds: $FilePath"
    }
    return [ordered]@{
      exit_code = $p.ExitCode
      stdout = $p.StandardOutput.ReadToEnd()
      stderr = $p.StandardError.ReadToEnd()
    }
  } finally {
    $p.Dispose()
  }
}

function Get-CentralHardwareInventory {
  [CmdletBinding()]
  param(
    [string]$OllamaUrl = 'http://127.0.0.1:11434'
  )

  $warnings = [System.Collections.Generic.List[string]]::new()
  $result = [ordered]@{
    captured_at = [DateTimeOffset]::UtcNow.ToString('o')
    platform = if ($IsWindows) { 'windows' } elseif ($IsLinux) { 'linux' } elseif ($IsMacOS) { 'macos' } else { 'unknown' }
    powershell_version = $PSVersionTable.PSVersion.ToString()
    cpu = @{}
    memory = @{}
    gpu = @()
    disks = @()
    ollama = [ordered]@{ status='unknown'; models=@() }
    warnings = @()
  }

  if ($IsWindows) {
    try {
      $cs = Get-CimInstance Win32_ComputerSystem -OperationTimeoutSec 8 -ErrorAction Stop
      $result.memory = [ordered]@{
        total_gb = [Math]::Round(([double]$cs.TotalPhysicalMemory / 1GB), 2)
        manufacturer = [string]$cs.Manufacturer
        model = [string]$cs.Model
      }
    } catch {
      $result.memory = @{ error=$_.Exception.Message }
      $warnings.Add("memory_cim: $($_.Exception.Message)")
    }

    try {
      $cpus = @(Get-CimInstance Win32_Processor -OperationTimeoutSec 8 -ErrorAction Stop)
      $result.cpu = [ordered]@{
        names = @($cpus | ForEach-Object { [string]$_.Name })
        physical_cores = [int](($cpus | Measure-Object -Property NumberOfCores -Sum).Sum)
        logical_processors = [int](($cpus | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum)
      }
    } catch {
      $result.cpu = @{ error=$_.Exception.Message }
      $warnings.Add("cpu_cim: $($_.Exception.Message)")
    }

    try {
      $result.gpu = @(Get-CimInstance Win32_VideoController -OperationTimeoutSec 8 -ErrorAction Stop | ForEach-Object {
        [ordered]@{
          name = [string]$_.Name
          adapter_ram_gb = if ($null -ne $_.AdapterRAM) { [Math]::Round(([double]$_.AdapterRAM / 1GB),2) } else { $null }
          driver_version = [string]$_.DriverVersion
          source = 'win32_video_controller'
        }
      })
    } catch {
      $result.gpu = @(@{ error=$_.Exception.Message; source='win32_video_controller' })
      $warnings.Add("gpu_cim: $($_.Exception.Message)")
    }

    try {
      $result.disks = @(Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        [ordered]@{
          name = $_.Name
          root = $_.Root
          free_gb = [Math]::Round(([double]$_.Free / 1GB),2)
          used_gb = [Math]::Round(([double]$_.Used / 1GB),2)
        }
      })
    } catch {
      $warnings.Add("disk_inventory: $($_.Exception.Message)")
    }
  }

  $nvidiaSmi = Get-Command nvidia-smi -ErrorAction SilentlyContinue
  if ($null -ne $nvidiaSmi) {
    try {
      $proc = Invoke-CentralProcessWithTimeout -FilePath $nvidiaSmi.Source -Arguments @('--query-gpu=name,memory.total,memory.free,driver_version','--format=csv,noheader,nounits') -TimeoutSeconds 8
      if ($proc.exit_code -eq 0 -and -not [string]::IsNullOrWhiteSpace($proc.stdout)) {
        $rows = @($proc.stdout -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        $result.gpu = @($rows | ForEach-Object {
          $parts = $_ -split ',' | ForEach-Object { $_.Trim() }
          [ordered]@{
            name = if ($parts.Count -gt 0) { $parts[0] } else { '' }
            vram_total_mb = if ($parts.Count -gt 1 -and $parts[1] -match '^\d+$') { [int]$parts[1] } else { $null }
            vram_free_mb = if ($parts.Count -gt 2 -and $parts[2] -match '^\d+$') { [int]$parts[2] } else { $null }
            driver_version = if ($parts.Count -gt 3) { $parts[3] } else { '' }
            source = 'nvidia-smi'
          }
        })
      } elseif (-not [string]::IsNullOrWhiteSpace($proc.stderr)) {
        $warnings.Add("nvidia_smi: $($proc.stderr.Trim())")
      }
    } catch {
      $warnings.Add("nvidia_smi: $($_.Exception.Message)")
    }
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
    $warnings.Add("ollama_tags: $($_.Exception.Message)")
  }

  $result.warnings = @($warnings)
  return $result
}

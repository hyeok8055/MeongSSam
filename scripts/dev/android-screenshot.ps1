param(
  [string]$DeviceId = "",
  [string]$OutputPath = "artifacts/android-screenshot.png"
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot/android-device.ps1"
$DeviceId = Resolve-AndroidDevice -DeviceId $DeviceId

$resolvedOutput = Join-Path (Get-Location) $OutputPath
$outputDirectory = Split-Path -Parent $resolvedOutput
if ($outputDirectory -and -not (Test-Path $outputDirectory)) {
  New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

$psi = [System.Diagnostics.ProcessStartInfo]::new()
$psi.FileName = "adb"
$psi.Arguments = "-s $DeviceId exec-out screencap -p"
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false

$process = [System.Diagnostics.Process]::Start($psi)
$file = [System.IO.File]::Create($resolvedOutput)
try {
  $process.StandardOutput.BaseStream.CopyTo($file)
} finally {
  $file.Dispose()
}

$process.WaitForExit()
if ($process.ExitCode -ne 0) {
  $errorText = $process.StandardError.ReadToEnd()
  Write-Error "adb screencap failed: $errorText"
  exit $process.ExitCode
}

Write-Host "Saved Android screenshot: $resolvedOutput"

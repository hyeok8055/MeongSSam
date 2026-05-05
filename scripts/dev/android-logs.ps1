param(
  [string]$DeviceId = ""
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot/android-device.ps1"
$DeviceId = Resolve-AndroidDevice -DeviceId $DeviceId

Write-Host "Streaming Flutter logs from Android device: $DeviceId"
flutter logs -d $DeviceId

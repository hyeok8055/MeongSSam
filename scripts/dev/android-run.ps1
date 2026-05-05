param(
  [string]$DeviceId = "",
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$FlutterArgs
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot/android-device.ps1"
$DeviceId = Resolve-AndroidDevice -DeviceId $DeviceId

Write-Host "Running Flutter on Android device: $DeviceId"
flutter run -d $DeviceId @FlutterArgs

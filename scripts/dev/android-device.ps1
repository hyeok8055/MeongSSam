function Get-ConnectedAndroidDevice {
  adb start-server | Out-Null

  return adb devices |
    Select-String "^\S+\s+device$" |
    ForEach-Object { ($_ -split "\s+")[0] } |
    Select-Object -First 1
}

function Resolve-AndroidDevice {
  param(
    [string]$DeviceId = ""
  )

  if ($DeviceId) {
    $state = adb -s $DeviceId get-state 2>$null
    if (($state | Select-Object -First 1) -ne "device") {
      Write-Error "Android device '$DeviceId' is not ready. Current state: $state"
      exit 1
    }

    return $DeviceId
  }

  $connectedDevice = Get-ConnectedAndroidDevice
  if ($connectedDevice) {
    return $connectedDevice
  }

  Write-Error "No ready Android device found. Start the emulator manually and wait until 'adb devices' shows '<id> device'."
  exit 1
}

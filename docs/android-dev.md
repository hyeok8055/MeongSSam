# Android Dev Workflow

Use Android emulator or a USB-debuggable Android device for mobile previews. This is the standard Flutter workflow for checking native Android behavior.

## Before Running

Start an Android emulator in Android Studio Device Manager, or connect a device with USB debugging enabled.
Wait until `adb devices` shows the target as `device`, not `offline`.

Check that Flutter can see it:

```powershell
flutter devices
adb devices
```

## Run The App

```powershell
.\scripts\dev\android-run.ps1
```

Pass a specific device ID when more than one device is connected:

```powershell
.\scripts\dev\android-run.ps1 -DeviceId emulator-5554
```

Pass extra Flutter args after the script arguments:

```powershell
.\scripts\dev\android-run.ps1 --dart-define=APP_NAME=MeongSSam
```

## Logs

```powershell
.\scripts\dev\android-logs.ps1
```

## Screenshot

```powershell
.\scripts\dev\android-screenshot.ps1
```

The screenshot is saved to `artifacts/android-screenshot.png` by default.

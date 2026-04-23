# Internal Distribution Automation

This repository keeps release automation in GitHub Actions and Fastlane, but it does not check in any signing material. The workflows are intended to stay safe in an unconfigured bootstrap state: they validate required secrets first, write temporary credential files on the runner, and then hand off to platform-specific Fastlane lanes.

## Workflows

### Android: Google Play Internal testing

- Workflow file: `.github/workflows/deploy-android-internal.yml`
- Runner: `ubuntu-latest`
- Environment: `internal-android`
- Entry point: manual `workflow_dispatch`
- Flow:
  1. Validate Android signing and Play API secrets.
  2. Restore a temporary keystore and Play service account JSON on the runner.
  3. Build a release AAB with `flutter build appbundle --release`.
  4. Run `android/fastlane/Fastfile` lane `internal`.
  5. Upload the built AAB to the Google Play `internal` track.

Required GitHub environment secrets:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `PLAY_SERVICE_ACCOUNT_JSON`

Notes:

- The Android project still needs release signing wired to consume `android/key.properties`.
- The lane assumes the release bundle is generated at `build/app/outputs/bundle/release/app-release.aab`.
- No keystore, key properties, or Play JSON file is committed to the repository.

### iOS: TestFlight

- Workflow file: `.github/workflows/deploy-ios-testflight.yml`
- Runner: `macos-26`
- Environment: `internal-ios`
- Entry point: manual `workflow_dispatch`
- Flow:
  1. Validate App Store Connect and `match` secrets.
  2. Restore the App Store Connect API key and SSH deploy key on the runner.
  3. Install CocoaPods dependencies.
  4. Run `ios/fastlane/Fastfile` lane `beta`.
  5. Use `match` to pull signing assets, archive `Runner`, and upload to TestFlight.

Required GitHub environment secrets:

- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY`
- `MATCH_GIT_URL`
- `MATCH_PASSWORD`
- `MATCH_SSH_PRIVATE_KEY`

Notes:

- The iOS lane is intentionally `readonly` for `match`; certificates and profiles must already exist in the signing repository.
- The workflow uses temporary files under `ios/fastlane/` on the runner only.
- No `.p8` key, provisioning profile, or SSH private key is committed to the repository.

## Intended Execution Flow

Use GitHub Environments to gate deployment with reviewer approval:

- `internal-android` for Google Play Internal testing
- `internal-ios` for TestFlight

Recommended setup order:

1. Configure store credentials and signing assets outside the repository.
2. Add the required environment secrets in GitHub.
3. Confirm the Android and iOS projects are wired for signed release builds.
4. Trigger the workflow manually from GitHub Actions.
5. Review the uploaded build in Google Play Console or App Store Connect.

## Local Expectations

These Fastlane files are structured so the same lanes can be reused locally later, but local execution is not expected to work until the same environment variables and signing prerequisites are available.

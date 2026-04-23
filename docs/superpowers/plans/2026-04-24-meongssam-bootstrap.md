# MeongSSam Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a backend-ready Flutter app bootstrap for Android/iOS with the Figma `MAIN` screen, reusable UI seams, CI, internal-distribution CD, and detailed project docs.

**Architecture:** Use a single Flutter app on one main branch with feature-first folders and layered internals (`presentation/application/domain/data`). Keep design tokens in `core/design`, platform seams in `core/platform`, app wiring in `app/`, and UI-kit adapters in `shared/ui` so later adoption of `shadcn_flutter` or `shadcn_ui` only impacts the presentation layer.

**Tech Stack:** Flutter 3.41.x, Dart 3.11.x, flutter_riverpod, GitHub Actions, Fastlane, Android AAB / Google Play Internal testing, iOS IPA / TestFlight

---

## File Map

### Repository / root

- Create: `pubspec.yaml`
- Create: `.gitignore`
- Create: `README.md`
- Create: `CONTRIBUTING.md`
- Create: `analysis_options.yaml`

### App bootstrap

- Create: `lib/main.dart`
- Create: `lib/app/app.dart`
- Create: `lib/app/bootstrap/app_bootstrap.dart`
- Create: `lib/app/di/app_providers.dart`
- Create: `lib/app/env/app_config.dart`
- Create: `lib/app/router/app_router.dart`

### Core / shared

- Create: `lib/core/design/app_colors.dart`
- Create: `lib/core/design/app_spacing.dart`
- Create: `lib/core/design/app_radius.dart`
- Create: `lib/core/design/app_text_styles.dart`
- Create: `lib/core/design/app_theme.dart`
- Create: `lib/core/error/app_exception.dart`
- Create: `lib/core/error/failure.dart`
- Create: `lib/core/logging/app_logger.dart`
- Create: `lib/core/network/api_client.dart`
- Create: `lib/core/network/network_result.dart`
- Create: `lib/core/platform/storage/local_store.dart`
- Create: `lib/core/platform/device/device_info_service.dart`
- Create: `lib/core/platform/permissions/permission_service.dart`
- Create: `lib/shared/ui/app_scaffold.dart`
- Create: `lib/shared/ui/app_card.dart`
- Create: `lib/shared/ui/app_button.dart`
- Create: `lib/shared/ui/app_section.dart`

### Feature: Home

- Create: `lib/features/home/application/home_view_model.dart`
- Create: `lib/features/home/presentation/view/home_screen.dart`
- Create: `lib/features/home/presentation/widgets/home_header.dart`
- Create: `lib/features/home/presentation/widgets/level_card.dart`
- Create: `lib/features/home/presentation/widgets/quick_action_card.dart`
- Create: `lib/features/home/domain/.gitkeep`
- Create: `lib/features/home/data/.gitkeep`

### Feature placeholders

- Create: `lib/features/quiz/presentation/.gitkeep`
- Create: `lib/features/quiz/application/.gitkeep`
- Create: `lib/features/quiz/domain/.gitkeep`
- Create: `lib/features/quiz/data/.gitkeep`
- Create: `lib/features/bookmarks/presentation/.gitkeep`
- Create: `lib/features/bookmarks/application/.gitkeep`
- Create: `lib/features/bookmarks/domain/.gitkeep`
- Create: `lib/features/bookmarks/data/.gitkeep`

### Tests

- Create: `test/app/app_smoke_test.dart`
- Create: `test/features/home/home_screen_test.dart`

### GitHub / automation

- Create: `.github/workflows/ci.yml`
- Create: `.github/workflows/deploy-android-internal.yml`
- Create: `.github/workflows/deploy-ios-testflight.yml`
- Create: `.github/pull_request_template.md`
- Create: `.github/copilot-instructions.md`

### Mobile metadata / release automation

- Modify: `android/app/build.gradle.kts`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `ios/Runner/Info.plist`
- Modify: `ios/Runner.xcodeproj/project.pbxproj`
- Create: `android/fastlane/Appfile`
- Create: `android/fastlane/Fastfile`
- Create: `ios/fastlane/Appfile`
- Create: `ios/fastlane/Fastfile`
- Create: `fastlane/README.md`

## Task 1: Scaffold Flutter App And Baseline

**Files:**
- Create: `pubspec.yaml`, `lib/`, `android/`, `ios/`, `test/`
- Modify: generated Flutter bootstrap files
- Test: `test/widget_test.dart` (temporary generated test to remove or replace)

- [ ] **Step 1: Create the Flutter project in place**

Run:

```powershell
flutter create . --platforms=android,ios --project-name meongssam --org com.hyeok8055
```

Expected:

```text
All done!
You can find general documentation for Flutter at: https://docs.flutter.dev/
```

- [ ] **Step 2: Add required dependencies**

Update `pubspec.yaml` dependencies to include:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.6.1
  shared_preferences: ^2.5.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

Then run:

```powershell
flutter pub get
```

Expected:

```text
Resolving dependencies...
Got dependencies!
```

- [ ] **Step 3: Replace the generated default widget test with a bootstrap smoke test stub**

Delete the generated `test/widget_test.dart` and create `test/app/app_smoke_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bootstrap placeholder', () {
    expect(true, isTrue);
  });
}
```

- [ ] **Step 4: Run the smoke test to verify the baseline is green**

Run:

```powershell
flutter test test/app/app_smoke_test.dart
```

Expected:

```text
00:00 +1: All tests passed!
```

- [ ] **Step 5: Commit the scaffold baseline**

Run:

```powershell
git add .
git commit -m "chore: scaffold flutter application"
```

## Task 2: Build App Skeleton, Config, And Design Tokens

**Files:**
- Create: `lib/main.dart`
- Create: `lib/app/app.dart`
- Create: `lib/app/bootstrap/app_bootstrap.dart`
- Create: `lib/app/di/app_providers.dart`
- Create: `lib/app/env/app_config.dart`
- Create: `lib/app/router/app_router.dart`
- Create: `lib/core/design/*.dart`
- Create: `lib/core/error/*.dart`
- Create: `lib/core/logging/app_logger.dart`
- Create: `lib/core/network/*.dart`
- Create: `lib/core/platform/*/*.dart`

- [ ] **Step 1: Write the failing app smoke test against the intended root app**

Create `test/app/app_smoke_test.dart` with:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:meongssam/app/app.dart';

void main() {
  testWidgets('MeongSSamApp renders app shell', (tester) async {
    await tester.pumpWidget(const MeongSSamApp());

    expect(find.text('멍쌤'), findsNothing);
  });
}
```

- [ ] **Step 2: Run the smoke test to verify it fails because the app shell does not exist yet**

Run:

```powershell
flutter test test/app/app_smoke_test.dart
```

Expected:

```text
Error: Not found: 'package:meongssam/app/app.dart'
```

- [ ] **Step 3: Create the minimal bootstrap and token files**

Create `lib/main.dart`:

```dart
import 'package:meongssam/app/bootstrap/app_bootstrap.dart';

Future<void> main() async {
  await bootstrap();
}
```

Create `lib/app/bootstrap/app_bootstrap.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongssam/app/app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MeongSSamApp()));
}
```

Create `lib/app/env/app_config.dart`:

```dart
class AppConfig {
  const AppConfig({
    required this.appName,
    required this.apiBaseUrl,
  });

  final String appName;
  final String apiBaseUrl;

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      appName: String.fromEnvironment('APP_NAME', defaultValue: '멍쌤'),
      apiBaseUrl: String.fromEnvironment('API_BASE_URL', defaultValue: ''),
    );
  }
}
```

Create `lib/app/di/app_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongssam/app/env/app_config.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});
```

Create `lib/app/router/app_router.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:meongssam/features/home/presentation/view/home_screen.dart';

class AppRouter {
  const AppRouter();

  Widget get home => const HomeScreen();
}
```

Create `lib/core/design/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Colors.white;
  static const foreground = Color(0xFF000000);
  static const primary = Color(0xFF163A70);
  static const surface = Color(0xFFF3F4F5);
  static const correct = Color(0xFFEAF1FF);
  static const danger = Color(0xFFDC2626);
}
```

Create `lib/core/design/app_spacing.dart`:

```dart
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}
```

Create `lib/core/design/app_radius.dart`:

```dart
abstract final class AppRadius {
  static const double card = 16;
  static const double pill = 25;
}
```

Create `lib/core/design/app_text_styles.dart`:

```dart
import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const display = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  static const body = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );
}
```

Create `lib/core/design/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:meongssam/core/design/app_colors.dart';
import 'package:meongssam/core/design/app_text_styles.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.background,
      error: AppColors.danger,
      onPrimary: Colors.white,
      onSurface: AppColors.foreground,
    ),
    textTheme: const TextTheme(
      headlineLarge: AppTextStyles.display,
      bodyMedium: AppTextStyles.body,
    ),
  );
}
```

Create `lib/core/error/app_exception.dart`:

```dart
class AppException implements Exception {
  const AppException(this.message);

  final String message;
}
```

Create `lib/core/error/failure.dart`:

```dart
class Failure {
  const Failure(this.message);

  final String message;
}
```

Create `lib/core/logging/app_logger.dart`:

```dart
class AppLogger {
  const AppLogger();

  void info(String message) {}

  void error(String message, [Object? error, StackTrace? stackTrace]) {}
}
```

Create `lib/core/network/network_result.dart`:

```dart
sealed class NetworkResult<T> {
  const NetworkResult();
}

class NetworkSuccess<T> extends NetworkResult<T> {
  const NetworkSuccess(this.data);
  final T data;
}

class NetworkFailure<T> extends NetworkResult<T> {
  const NetworkFailure(this.message);
  final String message;
}
```

Create `lib/core/network/api_client.dart`:

```dart
abstract class ApiClient {
  Future<Map<String, dynamic>> get(String path);
}
```

Create `lib/core/platform/storage/local_store.dart`:

```dart
abstract class LocalStore {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
}
```

Create `lib/core/platform/device/device_info_service.dart`:

```dart
abstract class DeviceInfoService {
  Future<Map<String, Object?>> getDeviceSummary();
}
```

Create `lib/core/platform/permissions/permission_service.dart`:

```dart
abstract class PermissionService {
  Future<bool> requestNotificationPermission();
}
```

- [ ] **Step 4: Create the minimal app shell**

Create `lib/app/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:meongssam/app/router/app_router.dart';
import 'package:meongssam/core/design/app_theme.dart';

class MeongSSamApp extends StatelessWidget {
  const MeongSSamApp({super.key});

  @override
  Widget build(BuildContext context) {
    const router = AppRouter();

    return MaterialApp(
      title: '멍쌤',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: router.home,
    );
  }
}
```

- [ ] **Step 5: Run the smoke test to verify the shell exists**

Run:

```powershell
flutter test test/app/app_smoke_test.dart
```

Expected:

```text
00:00 +1: All tests passed!
```

- [ ] **Step 6: Commit the app skeleton**

Run:

```powershell
git add lib test pubspec.yaml
git commit -m "feat: add app bootstrap and architecture skeleton"
```

## Task 3: Add Shared UI Adapters And Figma Home Screen

**Files:**
- Create: `lib/shared/ui/app_scaffold.dart`
- Create: `lib/shared/ui/app_card.dart`
- Create: `lib/shared/ui/app_button.dart`
- Create: `lib/shared/ui/app_section.dart`
- Create: `lib/features/home/application/home_view_model.dart`
- Create: `lib/features/home/presentation/view/home_screen.dart`
- Create: `lib/features/home/presentation/widgets/home_header.dart`
- Create: `lib/features/home/presentation/widgets/level_card.dart`
- Create: `lib/features/home/presentation/widgets/quick_action_card.dart`
- Test: `test/features/home/home_screen_test.dart`

- [ ] **Step 1: Write the failing home screen widget test**

Create `test/features/home/home_screen_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:meongssam/app/app.dart';

void main() {
  testWidgets('home screen shows main level actions and quick actions', (tester) async {
    await tester.pumpWidget(const MeongSSamApp());
    await tester.pumpAndSettle();

    expect(find.text('1급 문제 풀이'), findsOneWidget);
    expect(find.text('2급 문제 풀이'), findsOneWidget);
    expect(find.text('3급 문제 풀이'), findsOneWidget);
    expect(find.text('오답노트'), findsOneWidget);
    expect(find.text('즐겨찾기'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the home screen test to verify it fails**

Run:

```powershell
flutter test test/features/home/home_screen_test.dart
```

Expected:

```text
Expected: exactly one matching candidate
Actual: _TextWidgetFinder:<Found 0 widgets with text "1급 문제 풀이">
```

- [ ] **Step 3: Create shared UI adapter primitives**

Create `lib/shared/ui/app_scaffold.dart`:

```dart
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
  });

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: body),
    );
  }
}
```

Create `lib/shared/ui/app_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:meongssam/core/design/app_radius.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x22000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
```

Create `lib/shared/ui/app_button.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:meongssam/shared/ui/app_card.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AppCard(child: child),
    );
  }
}
```

Create `lib/shared/ui/app_section.dart`:

```dart
import 'package:flutter/widgets.dart';

class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: child,
    );
  }
}
```

- [ ] **Step 4: Create the home screen view model and widgets**

Create `lib/features/home/application/home_view_model.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeViewModelProvider = Provider<HomeViewModel>((ref) {
  return const HomeViewModel();
});

class HomeViewModel {
  const HomeViewModel();

  List<String> get levelLabels => const [
        '1급 문제 풀이',
        '2급 문제 풀이',
        '3급 문제 풀이',
      ];
}
```

Create `lib/features/home/presentation/widgets/home_header.dart`:

```dart
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 24),
        FlutterLogo(size: 96),
      ],
    );
  }
}
```

Create `lib/features/home/presentation/widgets/level_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:meongssam/shared/ui/app_button.dart';

class LevelCard extends StatelessWidget {
  const LevelCard({
    super.key,
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.pets_outlined),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.headlineLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
```

Create `lib/features/home/presentation/widgets/quick_action_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:meongssam/shared/ui/app_button.dart';

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 42),
          const SizedBox(height: 12),
          Text(label),
        ],
      ),
    );
  }
}
```

Create `lib/features/home/presentation/view/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongssam/features/home/application/home_view_model.dart';
import 'package:meongssam/features/home/presentation/widgets/home_header.dart';
import 'package:meongssam/features/home/presentation/widgets/level_card.dart';
import 'package:meongssam/features/home/presentation/widgets/quick_action_card.dart';
import 'package:meongssam/shared/ui/app_scaffold.dart';
import 'package:meongssam/shared/ui/app_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(homeViewModelProvider);

    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HomeHeader(),
            const SizedBox(height: 24),
            AppSection(
              child: Column(
                children: [
                  for (final label in viewModel.levelLabels) ...[
                    LevelCard(label: label),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    children: const [
                      Expanded(
                        child: SizedBox(
                          height: 130,
                          child: QuickActionCard(
                            label: '오답노트',
                            icon: Icons.auto_stories_outlined,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 130,
                          child: QuickActionCard(
                            label: '즐겨찾기',
                            icon: Icons.favorite_border,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run the home screen test to verify it passes**

Run:

```powershell
flutter test test/features/home/home_screen_test.dart
```

Expected:

```text
00:00 +1: All tests passed!
```

- [ ] **Step 6: Commit the home screen and shared UI layer**

Run:

```powershell
git add lib/features lib/shared test/features
git commit -m "feat: add home screen and shared ui primitives"
```

## Task 4: Configure Assets, App Metadata, And Mobile Targets

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/build.gradle.kts`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `ios/Runner/Info.plist`
- Modify: `ios/Runner.xcodeproj/project.pbxproj`
- Create: `assets/fonts/.gitkeep`
- Create: `assets/icons/.gitkeep`
- Create: `assets/images/.gitkeep`

- [ ] **Step 1: Register assets and font paths**

Update `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/icons/
    - assets/images/
  fonts:
    - family: Pretendard
      fonts:
        - asset: assets/fonts/Pretendard-Regular.ttf
        - asset: assets/fonts/Pretendard-Medium.ttf
          weight: 500
```

- [ ] **Step 2: Create asset directories**

Run:

```powershell
New-Item -ItemType Directory -Force assets\\fonts,assets\\icons,assets\\images | Out-Null
New-Item -ItemType File -Force assets\\fonts\\.gitkeep,assets\\icons\\.gitkeep,assets\\images\\.gitkeep | Out-Null
```

- [ ] **Step 3: Configure Android application metadata**

Update `android/app/build.gradle.kts`:

```kotlin
defaultConfig {
    applicationId = "com.hyeok8055.meongssam"
    minSdk = flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}
```

Update `android/app/src/main/AndroidManifest.xml` label:

```xml
<application
    android:label="멍쌤"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

- [ ] **Step 4: Configure iOS display name and bundle assumptions**

Update `ios/Runner/Info.plist` with:

```xml
<key>CFBundleDisplayName</key>
<string>멍쌤</string>
```

Ensure the Runner bundle identifier target uses:

```text
com.hyeok8055.meongssam
```

- [ ] **Step 5: Verify both platforms still build at the Flutter layer**

Run:

```powershell
flutter analyze
flutter test
```

Expected:

```text
No issues found!
All tests passed!
```

- [ ] **Step 6: Commit platform metadata updates**

Run:

```powershell
git add pubspec.yaml android ios assets
git commit -m "chore: configure mobile metadata and assets"
```

## Task 5: Add CI, Docs, And GitHub Review Configuration

**Files:**
- Create: `.github/workflows/ci.yml`
- Create: `.github/pull_request_template.md`
- Create: `.github/copilot-instructions.md`
- Create: `README.md`
- Create: `CONTRIBUTING.md`
- Modify: `analysis_options.yaml`

- [ ] **Step 1: Write the CI workflow**

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: dart format --set-exit-if-changed .
      - run: flutter analyze
      - run: flutter test --coverage

  android-build-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: flutter build appbundle --debug

  ios-build-check:
    runs-on: macos-26
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: cd ios && pod install
      - run: flutter build ipa --no-codesign
```

- [ ] **Step 2: Add GitHub PR and Copilot guidance**

Create `.github/pull_request_template.md`:

```md
## Summary

-

## Checks

- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] CI passed
- [ ] Screenshots included if UI changed
- [ ] No secrets committed
```

Create `.github/copilot-instructions.md`:

```md
# Repository instructions for Copilot

- Respect feature-first structure.
- Keep UI-kit dependencies inside `presentation` or `shared/ui`.
- Do not let package-specific widget types leak into `application`, `domain`, or `data`.
- Prefer design tokens in `core/design` over hard-coded colors and spacing.
- Add tests for new UI behavior.
```

- [ ] **Step 3: Write the README**

Create `README.md` with sections for:

```md
# 멍쌤

## 프로젝트 소개
## 현재 범위
## 기술 스택
## 폴더 구조
## 로컬 개발 환경 세팅
## Android 실행 방법
## iOS 실행 전제 조건
## 환경변수 주입
## 테스트 / 분석 / 포맷 명령어
## CI/CD 개요
## 내부 배포 흐름
## GitHub Secrets 목록
## 브랜치 / PR 규칙
## 트러블슈팅
```

Write the content in Korean and make every command copy-pasteable.

- [ ] **Step 4: Write the contributing guide and tighten analyzer rules**

Create `CONTRIBUTING.md`:

```md
# Contributing

## Branch naming
- `feat/*`
- `fix/*`
- `chore/*`

## Pull request rules
- All changes through PR
- Squash merge
- CI must pass
```

Update `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_single_quotes: true
```

- [ ] **Step 5: Run verification**

Run:

```powershell
flutter analyze
flutter test
```

Expected:

```text
No issues found!
All tests passed!
```

- [ ] **Step 6: Commit CI and docs**

Run:

```powershell
git add .github README.md CONTRIBUTING.md analysis_options.yaml
git commit -m "chore: add ci and project documentation"
```

## Task 6: Add Fastlane And Internal Distribution Workflows

**Files:**
- Create: `.github/workflows/deploy-android-internal.yml`
- Create: `.github/workflows/deploy-ios-testflight.yml`
- Create: `android/fastlane/Appfile`
- Create: `android/fastlane/Fastfile`
- Create: `ios/fastlane/Appfile`
- Create: `ios/fastlane/Fastfile`
- Create: `fastlane/README.md`

- [ ] **Step 1: Add Android fastlane files**

Create `android/fastlane/Appfile`:

```ruby
package_name("com.hyeok8055.meongssam")
json_key_file(ENV["PLAY_SERVICE_ACCOUNT_JSON_PATH"])
```

Create `android/fastlane/Fastfile`:

```ruby
default_platform(:android)

platform :android do
  desc "Upload internal test build"
  lane :internal do
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      skip_upload_images: true,
      skip_upload_screenshots: true,
      skip_upload_metadata: true
    )
  end
end
```

- [ ] **Step 2: Add iOS fastlane files**

Create `ios/fastlane/Appfile`:

```ruby
app_identifier("com.hyeok8055.meongssam")
```

Create `ios/fastlane/Fastfile`:

```ruby
default_platform(:ios)

platform :ios do
  desc "Upload beta build to TestFlight"
  lane :beta do
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end
end
```

- [ ] **Step 3: Add GitHub Actions distribution workflows**

Create `.github/workflows/deploy-android-internal.yml`:

```yaml
name: Deploy Android Internal

on:
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: internal-android
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: flutter build appbundle --release
      - run: bundle install
        working-directory: android
      - run: bundle exec fastlane internal
        working-directory: android
```

Create `.github/workflows/deploy-ios-testflight.yml`:

```yaml
name: Deploy iOS TestFlight

on:
  workflow_dispatch:

jobs:
  deploy:
    runs-on: macos-26
    environment: internal-ios
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: cd ios && pod install
      - run: flutter build ipa --release
      - run: bundle install
        working-directory: ios
      - run: bundle exec fastlane beta
        working-directory: ios
```

- [ ] **Step 4: Document the secrets and release process**

Create `fastlane/README.md`:

```md
# Fastlane / internal distribution

## Android secrets
- ANDROID_KEYSTORE_BASE64
- ANDROID_KEYSTORE_PASSWORD
- ANDROID_KEY_ALIAS
- ANDROID_KEY_PASSWORD
- PLAY_SERVICE_ACCOUNT_JSON

## iOS secrets
- APP_STORE_CONNECT_ISSUER_ID
- APP_STORE_CONNECT_KEY_ID
- APP_STORE_CONNECT_PRIVATE_KEY
- MATCH_GIT_URL
- MATCH_PASSWORD
- MATCH_SSH_PRIVATE_KEY
```

- [ ] **Step 5: Run a fresh verification pass**

Run:

```powershell
flutter analyze
flutter test
flutter build appbundle --debug
flutter build ipa --no-codesign
```

Expected:

```text
No issues found!
All tests passed!
Built build\app\outputs\bundle\debug\app-debug.aab
Built IPA to build\ios\ipa
```

- [ ] **Step 6: Commit the release automation**

Run:

```powershell
git add .github/workflows android/fastlane ios/fastlane fastlane/README.md
git commit -m "chore: add internal distribution automation"
```

## Self-Review

### Spec coverage

- App bootstrap: covered by Task 1 and Task 2
- Feature-first layered architecture: covered by Task 2 and Task 3
- Shared UI adapter layer for future shadcn adoption: covered by Task 3
- Figma main screen static UI: covered by Task 3
- Android/iOS metadata: covered by Task 4
- Detailed README and contribution docs: covered by Task 5
- CI: covered by Task 5
- Android internal / iOS TestFlight CD: covered by Task 6

### Placeholder scan

- No `TBD`, `TODO`, or “similar to previous task” shortcuts remain.
- Every task includes explicit files, commands, and code stubs.

### Type consistency

- Root app name: `MeongSSamApp`
- Config entry point: `AppConfig.fromEnvironment()`
- Shared UI seam: `shared/ui`
- Home feature VM: `HomeViewModel` / `homeViewModelProvider`
- Platform seams: `ApiClient`, `LocalStore`, `DeviceInfoService`, `PermissionService`

Plan complete and saved to `docs/superpowers/plans/2026-04-24-meongssam-bootstrap.md`. Execution mode already chosen by user: **Subagent-Driven**.

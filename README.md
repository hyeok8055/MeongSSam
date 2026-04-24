# MeongSSam

MeongSSam은 Android/iOS를 동시에 대상으로 하는 단일 Flutter 앱 저장소입니다. 현재 bootstrap 단계의 목표는 기능을 많이 넣는 것이 아니라, 이후 작업자가 바로 개발을 이어갈 수 있는 앱 구조, CI, 내부 배포 흐름, 운영 문서를 먼저 안정화하는 것입니다.

## 1. 현재 범위

포함 범위:

- 단일 Flutter 앱 저장소
- Android/iOS 동시 지원
- 메인 화면 중심의 초기 앱 부트스트랩
- feature-first + layered 아키텍처
- GitHub Actions 기반 CI
- Google Play Internal testing / TestFlight 기준의 내부 배포 준비
- 개발자 온보딩 문서

이번 단계의 제외 범위:

- 실제 백엔드 연동
- 프로덕션 도메인 로직 완성
- 광고, 결제, 분석 SDK
- 다중 flavor 운영
- 스토어 제출 자동화 완성

## 2. 기술 스택

- Flutter stable 3.41.x
- Dart 3.11.x
- Android / iOS
- `flutter_riverpod` 기반 상태 관리 및 DI
- GitHub Actions 기반 CI
- Fastlane 기반 내부 배포 자동화

권장 로컬 버전 확인:

```bash
flutter --version
dart --version
```

## 3. 목표 디렉터리 구조

bootstrap 설계 기준의 앱 구조는 아래와 같습니다.

```text
lib/
  app/
    bootstrap/
    di/
    env/
    router/
  core/
    design/
    error/
    logging/
    network/
    platform/
  shared/
    models/
    ui/
    widgets/
  features/
    home/
      presentation/
      application/
      domain/
      data/
    quiz/
      presentation/
      application/
      domain/
      data/
    bookmarks/
      presentation/
      application/
      domain/
      data/

assets/
  fonts/
  icons/
  images/

test/
  app/
  features/
  core/
```

구조 원칙:

- `lib/app/`: 앱 시작점, DI, 환경 설정, 라우팅
- `lib/core/`: 디자인 토큰, 에러, 로깅, 네트워크, 플랫폼 seam
- `lib/shared/`: 여러 feature가 공유하는 모델과 UI 어댑터
- `lib/features/`: 기능 단위 폴더
- UI kit 의존성은 `presentation` 또는 `shared/ui`에만 둡니다.
- 특정 UI 패키지 타입이 `application`, `domain`, `data` 레이어로 새면 안 됩니다.

## 4. 로컬 개발 환경 준비

### 필수 도구

- Flutter SDK
- Android Studio 또는 Android SDK + emulator
- Xcode 26 이상
- CocoaPods
- Git

### 저장소 준비

```bash
git clone <repo-url>
cd MeongSSam
flutter pub get
```

### 권장 초기 점검

```bash
flutter doctor -v
```

`flutter doctor`에서 Android toolchain, Xcode, CocoaPods 관련 에러가 없어야 합니다.

## 5. Android 실행 준비

Android는 내부 테스트 배포를 Google Play Internal testing 기준으로 맞춥니다.

확인 항목:

- Android SDK 설치
- emulator 또는 실제 기기 연결
- `ANDROID_SDK_ROOT`가 올바르게 인식되는지 확인

권장 실행 명령:

```bash
flutter devices
flutter run -d android
```

디버그 빌드 검증:

```bash
flutter build appbundle --debug
```

운영 기대 사항:

- `compileSdk` / `targetSdk`는 최신 요구사항을 따라갑니다.
- 내부 배포 채널은 Google Play `Internal testing`입니다.
- 서명 키와 Play 서비스 계정은 로컬 파일이 아니라 GitHub Secrets로 관리합니다.

## 6. iOS 실행 준비

iOS는 내부 테스트 배포를 TestFlight 기준으로 맞춥니다.

확인 항목:

- macOS 환경
- Xcode 26 이상
- iOS 26 SDK 사용 가능
- CocoaPods 설치 완료

초기 설치:

```bash
cd ios
pod install
cd ..
```

시뮬레이터 실행:

```bash
flutter devices
flutter run -d ios
```

서명 없이 빌드만 검증:

```bash
flutter build ipa --no-codesign
```

주의:

- `flutter build ipa --no-codesign`은 macOS에서만 가능합니다.
- 실제 TestFlight 업로드에는 인증서, 프로비저닝 프로파일, App Store Connect 키가 필요합니다.

## 7. 환경 변수 주입 규칙

앱 설정은 `--dart-define` 또는 `--dart-define-from-file` 기준으로 주입합니다. bootstrap 설계 기준의 대표 키는 아래와 같습니다.

- `APP_NAME`
- `API_BASE_URL`

단일 값으로 실행:

```bash
flutter run --dart-define=APP_NAME=MeongSSam --dart-define=API_BASE_URL=https://api.example.com
```

파일로 주입:

```bash
flutter run --dart-define-from-file=.env/dev.json
```

예시 파일:

```json
{
  "APP_NAME": "MeongSSam",
  "API_BASE_URL": "https://api.example.com"
}
```

원칙:

- 민감값은 저장소에 커밋하지 않습니다.
- 로컬용 파일은 `.gitignore`로 제외합니다.
- CI/CD에서는 GitHub Secrets와 Environment Secrets를 사용합니다.

## 8. 자주 쓰는 명령

의존성 설치:

```bash
flutter pub get
```

포맷 검사:

```bash
dart format --set-exit-if-changed .
```

정적 분석:

```bash
flutter analyze
```

테스트:

```bash
flutter test
```

커버리지 포함 테스트:

```bash
flutter test --coverage
```

Android 빌드 체크:

```bash
flutter build appbundle --debug
```

iOS 빌드 체크:

```bash
cd ios && pod install && cd ..
flutter build ipa --no-codesign
```

## 9. CI/CD 개요

### CI

GitHub Actions의 `.github/workflows/ci.yml`은 아래 이벤트에서 동작합니다.

- `pull_request`
- `push` to `main`

실행 항목:

1. 포맷 검사
2. `flutter analyze`
3. `flutter test --coverage`
4. Android 빌드 체크
5. iOS no-codesign 빌드 체크

iOS 잡은 `macos-26` runner를 사용합니다.

### CD

배포 workflow 자체는 별도 파일에서 관리합니다. 이 저장소의 기본 배포 방향은 다음과 같습니다.

- Android: Google Play `Internal testing`
- iOS: `TestFlight`

배포 자동화는 Fastlane을 기준으로 설계합니다.

## 10. 내부 배포 흐름

### Android Internal testing

1. release 준비 브랜치 또는 승인된 PR 기준으로 배포 시점 결정
2. GitHub Actions에서 signed AAB 생성
3. Fastlane `supply`로 Google Play Internal testing 업로드
4. QA 또는 내부 사용자가 Play 내부 테스트 트랙에서 설치

### iOS TestFlight

1. macOS runner에서 signing material 복원
2. signed IPA 생성
3. Fastlane `pilot`로 TestFlight 업로드
4. 내부 테스터 그룹에 배포

핵심 원칙:

- 앱 코드는 단일 브랜치 전략을 유지합니다.
- 플랫폼 차이는 코드 브랜치가 아니라 signing, workflow, 배포 환경에서 처리합니다.

## 11. GitHub Secrets / Environment Secrets 목록

### Android 내부 배포

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `PLAY_SERVICE_ACCOUNT_JSON`

### iOS 내부 배포

- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY`
- `MATCH_GIT_URL`
- `MATCH_PASSWORD`
- `MATCH_SSH_PRIVATE_KEY`

### 권장 GitHub Environments

- `ci`
- `internal-android`
- `internal-ios`

## 12. 브랜치 / PR 운영 규칙

- 기본 브랜치: `main`
- direct push 금지
- 모든 변경은 PR로 반영
- squash merge 사용
- 브랜치 이름:
  - `feat/*`
  - `fix/*`
  - `chore/*`
  - `docs/*`
  - `release/*`

PR 기본 기대 사항:

- 로컬 검증 선행
- CI 통과
- 최신 base branch 반영
- 최소 1명 리뷰
- UI 변경 시 스크린샷 첨부
- 문서/설정 변경 시 README 또는 CONTRIBUTING 동기화

## 13. Copilot / 코드 생성 가이드

Copilot이나 자동 코드 생성 도구를 사용할 때는 아래 원칙을 지킵니다.

- feature-first 구조를 깨지 않습니다.
- UI 의존성은 `presentation` 또는 `shared/ui`에만 둡니다.
- 공통 색상, 간격, radius, 텍스트 스타일은 `core/design` 토큰으로 뽑습니다.
- 플랫폼 연동은 `core/platform` seam 뒤에 둡니다.
- 한 화면 전용 위젯은 우선 feature 내부에 두고, 재사용이 명확해질 때만 공유 레이어로 올립니다.

## 14. 트러블슈팅

### `flutter analyze`가 실패할 때

- `flutter pub get`을 다시 실행합니다.
- 생성 코드나 의존성 변경이 있었는지 확인합니다.
- 현재 브랜치가 bootstrap 진행 중이면 다른 작업자의 변경과 충돌 없는지 먼저 확인합니다.

### `dart format --set-exit-if-changed .`가 실패할 때

아래 명령으로 포맷을 적용한 뒤 다시 검사합니다.

```bash
dart format .
```

### Android 빌드가 실패할 때

- `flutter doctor -v`에서 Android toolchain 상태를 확인합니다.
- SDK 라이선스, JDK, emulator 설정을 다시 확인합니다.
- Gradle 캐시 문제가 의심되면 Android Studio sync 또는 Gradle 캐시 정리를 검토합니다.

### `pod install` 또는 iOS 빌드가 실패할 때

```bash
cd ios
pod repo update
pod install
cd ..
```

추가 확인 항목:

- Xcode 버전이 저장소 기대 버전과 맞는지
- CocoaPods가 최신인지
- Apple Silicon 환경에서 Ruby/CocoaPods 경로가 꼬이지 않았는지

### `flutter build ipa --no-codesign`이 실패할 때

- macOS에서 실행 중인지 확인합니다.
- Xcode 첫 실행 설정과 라이선스 동의가 완료됐는지 확인합니다.
- iOS SDK / simulator runtime이 정상 설치됐는지 확인합니다.

### 내부 배포가 실패할 때

- GitHub Secrets 이름이 문서와 정확히 일치하는지 확인합니다.
- Environment 보호 규칙 때문에 workflow가 대기 중인지 확인합니다.
- Android는 Play 서비스 계정 권한, iOS는 App Store Connect 키와 `match` 저장소 접근 권한을 확인합니다.

## 15. 빠른 시작 체크리스트

새 작업자가 바로 시작할 때는 아래 순서를 권장합니다.

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build appbundle --debug
```

macOS라면 추가로:

```bash
cd ios && pod install && cd ..
flutter build ipa --no-codesign
```

문서, CI, 브랜치 규칙은 [CONTRIBUTING.md](CONTRIBUTING.md)와 함께 확인합니다.

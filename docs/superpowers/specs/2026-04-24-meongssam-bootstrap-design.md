# 멍쌤 Bootstrap Design Spec

## 1. 목적

`멍쌤(가제)`은 반려견 문제풀이 경험을 중심으로 하는 모바일 앱이다. 이번 1차 범위의 목표는 기능을 많이 만드는 것이 아니라, 이후 개발을 안전하게 시작할 수 있는 초기 제품 골격과 운영 기준을 확정하는 것이다.

이번 단계에서 반드시 끝내야 하는 것은 다음이다.

1. Flutter 기반 Android/iOS 앱 기본 프로젝트 생성
2. Figma 기준 메인 화면(`MAIN`) 정적 구현
3. 확장 가능한 초기 아키텍처와 디렉터리 구조 확정
4. GitHub Actions 기반 CI 구성
5. 내부 테스트 배포용 CD 구성
6. Copilot PR 자동 리뷰와 GitHub 운영 규칙 정리
7. 이후 팀원이 바로 개발을 시작할 수 있을 정도의 상세 README 작성

이번 단계에서 의도적으로 제외하는 것은 다음이다.

- 로그인/회원가입
- 실제 퀴즈 풀이 로직
- 문제 데이터 수집/관리 백엔드 구축
- 오답노트/즐겨찾기 실제 저장 동작
- 결제, 광고, 푸시, 분석 SDK

## 2. 범위 고정

### 포함

- 단일 Flutter 앱 저장소
- Android/iOS 동시 지원
- 앱 이름 `멍쌤`
- 메인 화면 1개
- 확장형 앱 구조
- 디자인 토큰 최소 세트
- 테스트/정적분석/빌드 검증 자동화
- Android `Google Play Internal testing` 배포 경로
- iOS `TestFlight` 배포 경로
- GitHub Copilot PR 자동 리뷰 설정 가이드
- 상세한 개발 문서와 운영 문서

### 제외

- 여러 앱 flavor 운영
- 다국어
- 실제 백엔드 선택 및 연결
- 퀴즈 도메인 상세 설계
- 프로덕션 스토어 릴리스 자동 제출

## 3. 제품/디자인 기준

메인 화면은 Figma `MAIN (node 16:133)`를 1차 기준안으로 사용한다. 현재 2026 기준 가장 표준적인 handoff 흐름은 Figma `Dev Mode + Ready for dev + Variables` 조합이므로, 이후 디자이너 협업 기준도 이 조합으로 통일한다.

이번 구현에서 반영할 디자인 요소:

- 상단 캐릭터/브랜드 이미지
- `1급 문제 풀이`, `2급 문제 풀이`, `3급 문제 풀이` 카드형 버튼 3개
- `오답노트`, `즐겨찾기` 보조 액션 카드 2개
- Pretendard 계열 타이포그래피
- Figma 스타일 가이드의 메인/서브 컬러

이번 단계에서는 인터랙션을 넣지 않는다. 탭 영역은 시각적으로만 준비하고, 실제 라우팅과 도메인 로직은 다음 단계로 넘긴다.

## 4. 아키텍처 방향

초기 버전이 단순하다고 해서 구조를 너무 얇게 시작하면, 페이지가 늘고 기기 기능이 붙는 순간 바로 파일 경계가 무너진다. 반대로 지금 당장 필요 없는 복잡한 도메인 레이어를 과하게 강제하면 초기 개발 속도만 떨어진다.

따라서 이번 프로젝트는 다음 원칙을 따른다.

- 상위는 `feature-first`
- 각 feature 내부는 `layered`
- 플랫폼 기능은 `core/platform` 또는 `service adapter`로 분리
- 실제 백엔드가 아직 없어도 `repository/service seam`은 먼저 만든다
- 플랫폼별 차이는 브랜치가 아니라 코드 경계와 배포 파이프라인에서 해결한다

이 방향은 Flutter 공식 가이드의 `View`, `ViewModel`, `Repository`, `Service` 분리 원칙과 맞는다.

## 5. 권장 디렉터리 구조

```text
lib/
  app/
    bootstrap/
      app_bootstrap.dart
    di/
      app_providers.dart
    env/
      app_config.dart
    router/
      app_router.dart
    app.dart
  core/
    design/
      app_colors.dart
      app_spacing.dart
      app_radius.dart
      app_text_styles.dart
      app_theme.dart
    error/
      app_exception.dart
      failure.dart
    logging/
      app_logger.dart
    network/
      api_client.dart
      network_result.dart
    platform/
      device/
        device_info_service.dart
      permissions/
        permission_service.dart
      storage/
        local_store.dart
    utils/
  shared/
    models/
    ui/
      app_button.dart
      app_card.dart
      app_scaffold.dart
      app_section.dart
    widgets/
  features/
    home/
      presentation/
        view/
          home_screen.dart
        widgets/
          level_card.dart
          quick_action_card.dart
      application/
        home_view_model.dart
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
main.dart

assets/
  fonts/
  icons/
  images/

test/
  features/
  core/
```

구조 원칙:

- `app/`: 앱 시작, DI, 환경설정, 라우팅
- `core/`: 공용 인프라와 플랫폼 추상화
- `core/design`: 디자인 토큰과 테마 소유
- `shared/`: 정말 여러 feature가 같이 쓰는 모델/위젯만 둠
- `shared/ui`: 외부 UI kit를 감싸는 앱 공용 UI 어댑터 층
- `features/`: 사용자 기능 단위
- feature 내부는 `presentation -> application -> domain -> data` 순서로 책임 분리

중요한 점:

- 모든 feature가 처음부터 `domain` 로직을 많이 가질 필요는 없다
- 하지만 폴더와 경계는 처음부터 만들어 둔다
- 실제 구현이 얇으면 파일 수도 적게 유지한다

## 6. Feature 내부 설계

각 feature는 다음 역할 분리를 따른다.

### `presentation`

- 화면 위젯
- 화면 전용 작은 위젯
- 사용자 입력 수집
- 접근성/레이아웃/시각 표현

### `application`

- ViewModel
- UI 상태 변환
- 여러 repository/service 호출 orchestration
- 화면 이벤트 처리

### `domain`

- 순수 도메인 모델
- use case가 정말 필요해지는 시점부터 추가
- 지금 단계에서는 대부분 비어 있어도 됨

### `data`

- repository 구현체
- DTO/mapper
- local/remote data source 연결

핵심 원칙:

- UI는 플랫폼 세부사항을 직접 알면 안 된다
- ViewModel은 네이티브 API나 패키지 호출을 직접 알면 안 된다
- repository는 데이터 출처를 숨기고 feature에 일관된 모델을 제공한다

## 7. 플랫폼 기능 대응 전략

사용자 질문처럼, 기기 정보, 권한, 저장소, 센서, 카메라, 알림, 파일 접근, OS별 리소스 제약은 앞으로 거의 확실히 생긴다. 이 문제는 브랜치를 나눠서 푸는 게 아니라, 플랫폼 경계를 분리해서 풀어야 한다.

권장 방식:

- 앱 코드는 `PermissionService`, `DeviceInfoService`, `LocalStore` 같은 공용 인터페이스만 본다
- 실제 구현은 Flutter plugin 또는 adapter 뒤로 숨긴다
- 네이티브 브리지 필요 시 가능하면 `Pigeon` 기반의 타입 안전한 방식으로 감싼다
- 커스텀 네이티브 통합이 커지면 나중에 `packages/` 아래 내부 패키지 또는 federated plugin 형태로 분리한다

이번 단계에서 만드는 기본 인터페이스:

- `AppConfig`
- `ApiClient`
- `LocalStore`
- `PermissionService`
- `DeviceInfoService`

이번 단계에서 실제 구현이 꼭 필요한 것:

- `AppConfig`
- `LocalStore` 기본형

이번 단계에서 인터페이스만 잡고 구현은 나중에 붙일 것:

- `ApiClient`
- `PermissionService`
- `DeviceInfoService`

## 8. 브랜치 전략

### 하지 않을 것

- Android 전용 `main`
- iOS 전용 `main`
- 플랫폼별 장기 분기 브랜치

이 방식은 Flutter 단일 코드베이스의 장점을 버리고, 공통 UI/로직 드리프트를 만든다. CI/CD, hotfix, 버전 태깅도 모두 복잡해진다.

### 사용할 것

- 기본 브랜치: `main`
- 기능 브랜치: `feat/*`, `fix/*`, `chore/*`
- 필요 시 릴리스 브랜치: `release/*`
- 태그 기반 배포

정리하면:

- 코드 브랜치는 하나
- 플랫폼 구현 경계는 코드 구조로 분리
- 플랫폼 배포는 workflow와 signing 설정으로 분리

## 9. 상태관리, DI, 환경설정

이번 프로젝트는 정적 메인 화면만 만들더라도, 이후 확장을 고려해 상태관리와 의존성 주입 구조를 초기에 잡아둔다.

권장 선택:

- 상태관리/DI: `flutter_riverpod`
- ViewModel은 Riverpod provider를 통해 주입
- 환경설정은 `--dart-define` 또는 `--dart-define-from-file` 기반
- `AppConfig`가 환경변수 접근을 한 곳으로 감싼다

이유:

- 지금은 단순해도, 나중에 API, 로컬 캐시, 인증, 권한 흐름이 생기면 provider 기반 주입이 확장에 유리하다
- 위젯 트리에 전역 싱글톤을 직접 박는 방식보다 테스트가 쉽다
- Flutter 공식 구조의 ViewModel/Repository/Service 흐름과도 잘 맞는다

이번 단계에서는 다음만 구현한다.

- Riverpod 기본 세팅
- `AppConfig`와 provider wiring
- 홈 화면용 `HomeViewModel` 골격

## 10. 기술 선택

- Framework: Flutter stable (`3.41.x`)
- Language: Dart `3.11.x`
- Targets: Android, iOS
- State/DI: `flutter_riverpod`
- Routing: 초기에는 단일 루트이지만 `app_router.dart` 파일로 진입 통일
- Styling: Flutter `ThemeData` + custom design tokens
- Fonts: Pretendard
- Assets: 로컬 asset 기반
- CI/CD: GitHub Actions
- Deployment automation: Fastlane

선택 이유:

- Flutter stable은 현재 Android 36 compile/target 기본값을 제공한다
- iOS는 `2026-04-28`부터 Xcode 26/iOS 26 SDK가 필수이므로, CI/CD도 이 기준으로 잡아야 한다
- Riverpod은 지금 단계에서 과도하게 무겁지 않으면서, 이후 ViewModel/Repository 주입 확장에 유리하다

## 11. 플랫폼/정책 기준

### Android

- Google Play 제출 최소 기준: `targetSdk >= 35`
- 초기 프로젝트는 `compileSdk 36`, `targetSdk 36` 기준 유지
- 내부 배포 채널: `Internal testing`
- 실제 데이터 수집 SDK를 넣는 순간 Play Console `Data safety` 즉시 갱신

### iOS

- App Store Connect 업로드 최소 기준: `2026-04-28`부터 `Xcode 26 + iOS 26 SDK`
- 내부 배포 채널: `TestFlight`
- iOS 실제 빌드/시뮬레이터/아카이브는 macOS 환경 필요
- App Privacy / Accessibility Nutrition Labels를 초기 체크리스트에 포함

### 공통 원칙

- 초기에는 Analytics, Ads, Social SDK, Push SDK를 넣지 않는다
- 이유: 메타데이터와 privacy disclosure 복잡도만 올리고 현재 가치가 낮다
- 실제 SDK 도입 시 Apple App Privacy와 Google Play Data Safety를 동시에 갱신한다

## 12. GitHub 운영 기준

### 브랜치/머지

- 기본 브랜치: `main`
- direct push 금지
- 모든 변경은 PR 경유
- squash merge 사용

### 필수 보호 규칙

- CI 통과 필수
- 최신 base branch 반영 필수
- 최소 1명 리뷰
- Copilot 자동 리뷰 요청 활성화

### 문서

- `README.md`
- `CONTRIBUTING.md`
- `.github/pull_request_template.md`
- `.github/copilot-instructions.md`

## 13. README 요구사항

`README.md`는 짧은 소개 문서가 아니라, 새 개발자가 바로 세팅하고 개발을 시작할 수 있는 운영 문서로 작성한다.

반드시 포함할 항목:

1. 프로젝트 소개
2. 현재 범위와 제외 범위
3. 사용 기술 스택
4. 폴더 구조 설명
5. 로컬 개발 환경 세팅
6. Android 실행 방법
7. iOS 실행/빌드 전제 조건
8. 환경변수 주입 방법
9. 테스트/분석/포맷 명령어
10. GitHub Actions CI/CD 개요
11. 내부 배포 흐름
12. 시크릿 목록과 저장 위치
13. 브랜치/PR 규칙
14. 자주 생길 문제와 해결 방법

README는 “아는 사람만 이해하는 메모”가 아니라 “처음 들어온 사람이 따라 할 수 있는 절차서”여야 한다.

## 14. CI 설계

PR 기준 CI는 빠르고 결정적인 검증만 넣는다.

### Workflow 1: `ci.yml`

트리거:

- `pull_request`
- `push` to `main`

잡 구성:

1. `lint-and-test` on `ubuntu-latest`
   - Flutter 설치
   - dependency fetch
   - `dart format --set-exit-if-changed .`
   - `flutter analyze`
   - `flutter test --coverage`

2. `android-build-check` on `ubuntu-latest`
   - signing 없는 Android 빌드 검증
   - `flutter build appbundle --debug` 또는 이에 준하는 build validate

3. `ios-build-check` on `macos-26`
   - Flutter 설치
   - CocoaPods install
   - `flutter build ipa --no-codesign`
   - Xcode 26/iOS 26 SDK 경로 검증

산출물:

- 테스트 결과
- coverage artifact
- 필요 시 빌드 artifact

## 15. CD 설계

CD는 “프로덕션 자동 제출”이 아니라 “내부 테스트용 배포 자동화”까지만 담당한다.

### Workflow 2: `deploy-android-internal.yml`

트리거:

- `workflow_dispatch`
- 필요 시 tag 기반 실행

동작:

- signed `AAB` 빌드
- Fastlane `supply` 사용
- Google Play `Internal testing` 업로드

필요 시크릿:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `PLAY_SERVICE_ACCOUNT_JSON`

### Workflow 3: `deploy-ios-testflight.yml`

트리거:

- `workflow_dispatch`
- 필요 시 `release/*` branch 또는 tag 기반 실행

동작:

- `macos-26` runner 사용
- certificates/profiles 복원
- signed `IPA` 빌드
- Fastlane `pilot`로 TestFlight 업로드

필요 시크릿:

- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY`
- `MATCH_GIT_URL`
- `MATCH_PASSWORD`
- `MATCH_SSH_PRIVATE_KEY`

### Environments

- `ci`
- `internal-android`
- `internal-ios`

배포 환경에는 reviewer approval을 걸 수 있게 설계한다.

## 16. Fastlane 전략

Fastlane은 배포 전용으로 사용한다.

- `android/fastlane/Fastfile`
  - `internal`
- `ios/fastlane/Fastfile`
  - `beta`

목표:

- GitHub Actions에서 store API 처리 로직을 단순화
- 로컬에서도 동일한 배포 절차 재현
- 추후 beta/release lane 확장 용이

## 17. 보안/비밀정보 원칙

- `.env` 커밋 금지
- signing key는 GitHub Secrets/Environments로만 관리
- Android는 Play App Signing 사용
- iOS는 `match` 기반 인증서 관리
- secret scanning, push protection 활성화 권장
- CI 로그에 민감 정보 출력 금지

## 18. 초기 UI 구현 원칙

- Figma를 그대로 기계적으로 옮기지 않고 Flutter 위젯 구조로 재해석
- 카드 버튼과 보조 액션 카드는 재사용 위젯으로 분리
- spacing, radius, shadow는 design token으로 위임
- 접근성을 기본 전제로 삼는다

### 컴포넌트 재사용 전략

- 전역 primitive는 `shared/ui`에 둔다
- 화면 전용 composite는 각 feature의 `presentation/widgets`에 둔다
- 한 화면에서만 쓰는 위젯은 공용으로 올리지 않는다
- 두 개 이상 feature에서 반복되면 `shared/ui` 또는 `shared/widgets`로 승격한다
- 외부 UI 라이브러리(`shadcn_flutter`, `shadcn_ui` 등)는 가능하면 `shared/ui`에서 감싼 뒤 feature에 노출한다
- `application/domain/data` 레이어에는 외부 UI 패키지 타입이 새지 않게 한다

이 전략을 따르면 나중에 UI kit를 바꾸더라도 `shared/ui`와 일부 `presentation`만 주로 수정하면 된다.

초기 접근성 기준:

- 충분한 터치 영역
- 텍스트 확대 시 레이아웃 붕괴 최소화
- semantic label을 붙일 수 있는 구조

## 19. 테스트 원칙

이번 단계에서 필요한 테스트는 많지 않지만, 최소한의 안전망은 둔다.

- widget test
  - 앱 기동
  - 메인 화면 주요 텍스트 표시
  - level 카드 개수
  - quick action 카드 개수
- golden test는 이번 단계에서는 선택 사항
- integration test는 다음 단계로 이월

## 20. 구현 완료 정의

다음 조건을 만족하면 이번 bootstrap 단계는 완료로 본다.

- Flutter 앱이 Android/iOS 대상으로 생성됨
- 메인 화면 정적 UI가 Figma 의도와 크게 어긋나지 않음
- Riverpod, AppConfig, router, core/platform/service seam이 기본 형태로 존재
- `flutter analyze`, `flutter test` 통과
- Android/iOS 빌드 검증 workflow 통과
- Android internal / iOS TestFlight 배포 workflow 초안이 동작 가능한 형태로 존재
- PR 시 Copilot 자동 리뷰를 켤 수 있는 repository 운영 문서가 정리됨
- README가 새 개발자 온보딩 문서 역할을 수행함

## 21. 이후 단계 예고

다음 구현 단계는 아래 순서가 적절하다.

1. 퀴즈 화면 진입 라우팅
2. 더미 문제 모델/저장소
3. 선택지/정답 표시 흐름
4. 오답노트/즐겨찾기 동작
5. 실제 데이터 저장/동기화 설계
6. 필요한 기기 기능, 권한, 네이티브 연동 추가

## 22. 참고 기준

- Apple Upcoming Requirements: https://developer.apple.com/news/upcoming-requirements/
- Google Play target API requirements: https://developer.android.com/google/play/requirements/target-sdk
- Flutter app architecture guide: https://docs.flutter.dev/app-architecture/guide
- Flutter platform-specific code / Pigeon: https://docs.flutter.dev/platform-integration/platform-channels
- Flutter developing packages & plugins: https://docs.flutter.dev/packages-and-plugins/developing-packages
- Flutter Continuous delivery: https://docs.flutter.dev/deployment/cd
- Flutter iOS release: https://docs.flutter.dev/deployment/ios
- Figma Dev Mode: https://help.figma.com/hc/en-us/articles/15023124644247-Guide-to-Dev-Mode
- Figma Variables in Dev Mode: https://help.figma.com/hc/en-us/articles/27882809912471-Variables-in-Dev-Mode
- GitHub Copilot automatic review: https://docs.github.com/en/copilot/how-tos/copilot-on-github/set-up-copilot/configure-automatic-review

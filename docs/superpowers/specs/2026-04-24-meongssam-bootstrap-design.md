# 멍쌤 Bootstrap Design Spec

## 1. 목적

`멍쌤(가제)`은 반려견 문제풀이 경험을 중심으로 한 모바일 앱이다. 이번 1차 범위의 목적은 서비스 기능을 많이 만드는 것이 아니라, 이후 개발을 안전하게 시작할 수 있는 초기 제품 골격을 고정하는 것이다.

이번 단계에서 완료해야 하는 것은 다음 다섯 가지다.

1. Flutter 기반 Android/iOS 앱 기본 프로젝트 생성
2. Figma 기준 메인 화면(`MAIN`) 정적 구현
3. 확장 가능한 최소 아키텍처 골격 확정
4. GitHub Actions 기반 CI 구성
5. 내부 배포용 CD와 PR 리뷰 자동화 기준 확정

이번 단계에서 의도적으로 제외하는 것은 다음과 같다.

- 로그인/회원가입
- 문제 데이터 모델링
- 퀴즈 풀이 로직
- 정답 채점, 오답노트, 즐겨찾기 실제 동작
- 백엔드/Firebase 연결
- 알림, 분석, 광고, 결제

## 2. 범위 고정

### 포함

- 단일 Flutter 앱 저장소
- Android/iOS 동시 지원
- 앱 이름 `멍쌤`
- 메인 화면 1개
- 디자인 토큰 최소 세트
- 테스트/정적분석/빌드 검증 자동화
- Android `Google Play Internal testing` 배포 경로
- iOS `TestFlight` 배포 경로
- GitHub Copilot PR 자동 리뷰 설정 가이드

### 제외

- 여러 flavor 운영
- 다국어
- 백엔드/인증
- 상태관리 복잡화
- feature module 분리
- release to production 자동 제출

## 3. 제품/디자인 기준

메인 화면은 Figma `MAIN (node 16:133)`를 단일 기준안으로 사용한다. 현재 디자인 handoff는 2026 기준 Figma `Dev Mode + Ready for dev + Variables` 흐름에 맞추는 것이 가장 표준적이므로, 이후 디자이너 협업 기준도 이 조합으로 통일한다.

이번 구현에서 반영할 디자인 요소:

- 로고/캐릭터 이미지 상단 배치
- `1급 문제 풀이`, `2급 문제 풀이`, `3급 문제 풀이` 카드형 버튼 3개
- `오답노트`, `즐겨찾기` 보조 액션 카드 2개
- Pretendard 계열 타이포그래피
- Figma 스타일 가이드의 메인/서브 컬러

이번 단계에서는 인터랙션을 넣지 않는다. 탭 영역은 시각적으로만 준비하고, 라우팅은 다음 단계에서 연결한다.

## 4. 아키텍처

초기 버전은 과도한 계층 분리를 피한다. 하지만 다음 단계에서 화면과 기능이 늘어날 가능성이 높으므로, “작지만 버리기 어렵지 않은 구조”를 선택한다.

권장 구조:

```text
lib/
  app/
    app.dart
    bootstrap.dart
    router/
      app_router.dart
  core/
    design/
      app_colors.dart
      app_spacing.dart
      app_text_styles.dart
      app_theme.dart
    widgets/
  features/
    home/
      presentation/
        home_screen.dart
        widgets/
          level_card.dart
          quick_action_card.dart
  main.dart
```

구조 원칙:

- `app/`: 앱 시작, 전역 설정, 라우팅
- `core/design/`: 디자인 토큰과 공용 테마
- `core/widgets/`: 진짜 공용일 때만 이동
- `features/home/`: 메인 화면 전용 UI

이번 단계에서는 `application/domain/data` 3층 구조를 강제하지 않는다. 아직 데이터 흐름이 없기 때문이다. 다음 단계에서 실제 문제/정답/오답 기록이 생기면 그 시점에 feature 단위로 도입한다.

## 5. 기술 선택

- Framework: Flutter stable (`3.41.x`)
- Language: Dart `3.11.x`
- Targets: Android, iOS
- State: 기본 `StatelessWidget`/`StatefulWidget`만 사용
- Routing: 최소 `app_router.dart` 파일만 두고, 1차는 단일 화면 루트
- Styling: Flutter `ThemeData` + custom design tokens
- Fonts: Pretendard
- Icons/Images: 초기에는 로컬 asset 기반
- CI/CD: GitHub Actions
- Deployment automation: Fastlane

선택 이유:

- Flutter stable은 현재 Android 36 compile/target 기본값을 제공한다.
- iOS는 2026-04-28부터 Xcode 26/iOS 26 SDK가 필수이므로, CI/CD도 이 기준을 전제로 잡아야 한다.
- 초기 상태관리 라이브러리를 억지로 넣으면 구조가 커지지만 실제 이득은 적다. 지금은 UI 골격이 우선이다.

## 6. 플랫폼/정책 기준

### Android

- Google Play 제출 최소 기준: `targetSdk >= 35`
- 초기 프로젝트는 Flutter 기본값에 맞춰 `compileSdk 36`, `targetSdk 36` 기준 유지
- 내부 배포 채널은 `Internal testing`
- Play Console `Data safety`는 실제 SDK/데이터 수집을 넣기 전까지 가장 보수적으로 유지

### iOS

- App Store Connect 업로드 최소 기준: `2026-04-28`부터 `Xcode 26 + iOS 26 SDK`
- 내부 배포 채널은 `TestFlight`
- iOS 최소 지원 버전은 Flutter 기본 지원선 안에서 시작하되, 플러그인 제약 생기면 그때 상향
- App Privacy / Accessibility Nutrition Labels는 초기부터 체크리스트에 포함

### 공통 정책 원칙

- 초기에 Analytics, Ads, Social SDK, Push SDK를 넣지 않는다.
- 이유: 스토어 메타데이터, privacy disclosure, data safety 답변 복잡도만 올리고 현재 가치가 낮다.
- 나중에 SDK를 추가하는 순간 Apple App Privacy와 Google Play Data Safety 문서도 동시에 갱신한다.

## 7. GitHub 운영 기준

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

- `README.md`: 프로젝트 개요, 실행법, 배포 구조
- `CONTRIBUTING.md`: 브랜치/PR/리뷰 규칙
- `.github/pull_request_template.md`: 체크리스트
- `.github/copilot-instructions.md`: Flutter/구조/리뷰 기준

## 8. CI 설계

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
   - `flutter build appbundle --debug` 또는 release validate build
   - signing 없는 빌드 검증

3. `ios-build-check` on `macos-26`
   - Flutter 설치
   - CocoaPods install
   - `flutter build ipa --no-codesign`
   - Xcode 26/iOS 26 SDK 경로 검증

산출물:

- 테스트 결과
- coverage artifact
- 빌드 artifact(선택)

## 9. CD 설계

초기 버전 CD는 “내부 테스트용 배포 자동화”까지만 담당한다.

### Workflow 2: `deploy-android-internal.yml`

트리거:

- `workflow_dispatch`
- 또는 `push tags` / `manual promote` 중 하나

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
- 필요 시 `release/*` branch push

동작:

- macOS 26 runner 사용
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

## 10. Fastlane 전략

Fastlane은 “배포 전용”으로 사용한다.

- `android/fastlane/Fastfile`
  - `internal`
- `ios/fastlane/Fastfile`
  - `beta`

목표:

- GitHub Actions에서 store API를 직접 두드리는 로직을 최소화
- 로컬에서도 동일한 배포 절차 재현 가능
- 추후 beta/release lane 확장 쉬움

## 11. 보안/비밀정보 원칙

- `.env` 커밋 금지
- signing key는 GitHub Secrets/Environments로만 관리
- Android는 Play App Signing 사용
- iOS는 `match` 기반 인증서 관리
- 가능한 경우 GitHub secret scanning, push protection 활성화
- CI에서 민감 정보 출력 금지

## 12. 초기 UI 구현 원칙

- Figma를 그대로 “Tailwind식 번역”하지 않고 Flutter 위젯 구조로 재해석
- 카드 버튼, 보조 액션 카드 모두 재사용 위젯으로 분리
- spacing, radius, shadow는 theme/token에 위임
- 접근성 고려:
  - 충분한 터치 영역
  - 텍스트 확대 시 레이아웃 붕괴 최소화
  - semantic label 추가 가능한 구조

## 13. 테스트 원칙

이번 단계에서 필요한 테스트는 많지 않다. 하지만 최소한의 안전망은 둔다.

- widget test:
  - 앱 기동
  - 메인 화면 주요 텍스트 표시
  - level 카드 개수
  - quick action 카드 개수
- golden test는 이번 단계에서 선택 사항
- integration test는 다음 단계로 이월

## 14. 구현 완료 정의

다음 조건을 만족하면 이번 bootstrap 단계는 완료로 본다.

- Flutter 앱이 Android/iOS 대상으로 생성됨
- 메인 화면 정적 UI가 Figma 의도와 크게 어긋나지 않음
- `flutter analyze`, `flutter test` 통과
- Android/iOS 빌드 검증 workflow 통과
- Android internal / iOS TestFlight 배포 workflow 초안이 동작 가능한 형태로 존재
- PR 시 Copilot 자동 리뷰를 켤 수 있는 repository 운영 문서가 정리됨

## 15. 이후 단계 예고

다음 구현 단계는 아래 순서가 적절하다.

1. 퀴즈 화면 진입 라우팅
2. 더미 문제 모델/저장소
3. 선택지/정답 표시 흐름
4. 오답노트/즐겨찾기 동작
5. 실제 데이터 저장/동기화 설계

## 16. 참고 기준

- Apple Upcoming Requirements: https://developer.apple.com/news/upcoming-requirements/
- Google Play target API requirements: https://developer.android.com/google/play/requirements/target-sdk
- Flutter Continuous delivery: https://docs.flutter.dev/deployment/cd
- Flutter iOS release: https://docs.flutter.dev/deployment/ios
- Figma Dev Mode: https://help.figma.com/hc/en-us/articles/15023124644247-Guide-to-Dev-Mode
- Figma Variables in Dev Mode: https://help.figma.com/hc/en-us/articles/27882809912471-Variables-in-Dev-Mode
- GitHub Copilot automatic review: https://docs.github.com/en/copilot/how-tos/copilot-on-github/set-up-copilot/configure-automatic-review

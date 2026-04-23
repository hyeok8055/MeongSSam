# Contributing

## 목적

이 저장소는 단일 Flutter 앱을 `main` 브랜치 중심으로 운영합니다. Android/iOS를 플랫폼별 브랜치로 분리하지 않고, 기능 브랜치와 GitHub Actions, Fastlane, 스토어 배포 설정으로 릴리스 흐름을 나눕니다.

## 브랜치 규칙

- 기본 브랜치: `main`
- 작업 브랜치 접두사:
  - `feat/<short-topic>`
  - `fix/<short-topic>`
  - `chore/<short-topic>`
  - `docs/<short-topic>`
  - `release/<version-or-topic>`: 릴리스 점검이 필요한 경우에만 사용
- 한 브랜치에는 하나의 논리적 변경만 담습니다.
- 직접 `main`에 push 하지 않습니다.

예시:

```text
feat/bootstrap-home-screen
fix/ios-build-settings
chore/update-ci-cache
docs/onboarding-readme
```

## 작업 원칙

- 구조는 `feature-first`를 유지합니다.
- 각 feature 내부는 `presentation -> application -> domain -> data` 레이어를 따릅니다.
- UI 프레임워크나 UI kit 의존성은 `presentation` 또는 `shared/ui`에만 둡니다.
- `application`, `domain`, `data` 레이어에는 Flutter 위젯 타입이나 특정 UI 패키지 타입이 새지 않도록 합니다.
- 공통 디자인 값은 `lib/core/design/`의 토큰으로 모읍니다.
- 플랫폼 의존 기능은 `lib/core/platform/`의 service seam 뒤로 숨깁니다.

## Pull Request 규칙

- 모든 변경은 Pull Request로만 반영합니다.
- PR 제목은 변경 의도가 드러나야 하며, 가능하면 브랜치 목적과 일치시킵니다.
- PR 본문에는 최소한 다음 내용을 포함합니다.
  - 무엇을 바꿨는지
  - 왜 바꿨는지
  - 검증 방법
  - UI 변경 시 스크린샷 또는 짧은 설명
- 서로 다른 목적의 변경을 하나의 PR에 섞지 않습니다.
- 리뷰 피드백 반영 후에도 작성자가 최종적으로 다시 확인합니다.

## 머지 정책

- 머지는 `Squash merge`만 사용합니다.
- merge commit, rebase merge는 사용하지 않습니다.
- squash commit 메시지는 PR 변경 의도를 한 줄로 설명해야 합니다.

## CI 기대 사항

PR을 열기 전에 로컬에서 아래 명령을 우선 확인합니다.

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build appbundle --debug
```

macOS 환경이 있다면 iOS 검증도 권장합니다.

```bash
cd ios && pod install && cd ..
flutter build ipa --no-codesign
```

GitHub Actions CI는 다음 검사를 기준으로 합니다.

- 포맷 검사
- 정적 분석
- 테스트
- Android 빌드 체크
- iOS no-codesign 빌드 체크

CI가 실패한 상태에서는 머지하지 않습니다.

## 리뷰 및 승인

- 최소 1명 이상의 리뷰를 받습니다.
- base branch 최신 상태를 반영한 뒤 CI를 다시 통과시킵니다.
- Copilot 자동 리뷰가 활성화된 경우, 제안은 참고하되 사람이 최종 판단합니다.

## 보안 및 비밀정보

- `.env`, 인증서, 키 파일, 서비스 계정 JSON은 커밋하지 않습니다.
- 배포용 secret은 GitHub Secrets 또는 Environment Secrets로만 관리합니다.
- 로그나 스크린샷에 민감한 값이 노출되지 않도록 확인합니다.

## 문서 업데이트 기준

다음 항목이 바뀌면 문서도 함께 업데이트합니다.

- 실행/빌드 명령
- 디렉터리 구조
- 환경 변수 키
- CI/CD 흐름
- 브랜치/PR 정책

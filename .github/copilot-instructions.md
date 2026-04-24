# Copilot Instructions For MeongSSam

## Architecture

- Treat this repository as a single Flutter app for Android and iOS.
- Preserve the feature-first structure under `lib/features/`.
- Inside each feature, keep responsibilities separated as `presentation`, `application`, `domain`, and `data`.
- Keep app bootstrap and cross-cutting wiring in `lib/app/`.
- Keep reusable design tokens in `lib/core/design/`.
- Keep platform seams in `lib/core/platform/`.

## UI Adapter Rules

- UI kit and widget-library dependencies must stay in `presentation` or `lib/shared/ui/`.
- Do not introduce package-specific widget types into `application`, `domain`, or `data`.
- Prefer wrapping reusable UI patterns with local adapters in `lib/shared/ui/` so future UI-kit swaps stay localized.
- Prefer design tokens over hard-coded colors, spacing, radius, and text styles.
- If a widget is used by one screen only, keep it inside that feature first. Promote to `lib/shared/ui/` only when reuse is proven.

## State And Data Boundaries

- View models and providers belong in `application`.
- Domain models and use cases belong in `domain`.
- Repository implementations, DTOs, and data-source code belong in `data`.
- Platform integrations should be modeled behind interfaces such as config, storage, permissions, device info, or network services.

## Delivery Expectations

- Prefer code that is easy to analyze, test, and build in CI.
- When suggesting changes, include or update tests if behavior changes.
- Do not add secrets, signing material, or local machine paths to tracked files.
- Keep README, CONTRIBUTING, and workflow docs aligned with actual commands and paths.

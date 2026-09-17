## Context

See `proposal.md` for motivation.

Currently, `main.dart` initializes dependencies via `setupDi()` and immediately renders `CentrowSalesApp`. `GoRouter` evaluates `AuthTokenHolder.instance.hasToken` synchronously to choose between `/customers` and `/login`. The native launch screens for Android (`res/drawable/launch_background.xml`) and iOS (`LaunchScreen.storyboard`) are defaults with no custom assets or colors.

## Goals / Non-Goals

**Goals:**
- Provide a branded native launch screen on Android and iOS that visually matches the initial Flutter view.
- Introduce an in-app `/splash` route in `lib/modules/core/views/pages/splash_page.dart` as the initial GoRouter location.
- Implement `SplashController` in `lib/modules/core/controllers/splash_controller.dart` following the repository's Signals and Layered Architecture conventions.
- Validate the stored token against `/v1/auth/me` on startup, handling valid, expired (401), and offline network states gracefully.
- Enforce a minimum display duration (~1.2 seconds) to avoid jarring screen flickers.

**Non-Goals:**
- Multi-step onboarding tutorials or introductory feature carousels.
- Complex biometric authentication prompts during splash (biometrics can be a subsequent feature).

## Decisions

### 1. Generate Native Splash via `flutter_native_splash`
- **Choice:** Add `flutter_native_splash` to `dev_dependencies` with a configuration block in `pubspec.yaml`, generating native assets for Android (including Android 12+ Splash API) and iOS.
- **Rationale:** Automates generating drawables, vector drawables, night mode configurations, and iOS storyboard assets consistently without manual XML/Storyboard editing.
- **Alternatives Considered:** Manual editing of `launch_background.xml` and `LaunchScreen.storyboard`. Rejected due to fragility across Android 12+ API differences and maintenance overhead.

### 2. Architecture & Layering for In-App Splash
- **Choice:** Place `SplashController` in `lib/modules/core/controllers/splash_controller.dart` and `SplashPage` in `lib/modules/core/views/pages/splash_page.dart`.
- **Rationale:** Core module owns authentication and session lifecycle per `CLAUDE.md`. The controller imports `package:signals/signals.dart` (pure Dart, no Flutter widgets), and the view uses `signals_flutter`.
- **Alternatives Considered:** Placing splash logic inside `main.dart` or `app.dart`. Rejected because it violates module separation and couples app bootstrap with UI routing.

### 3. Startup Verification with Graceful Offline Fallback
- **Choice:** Run session validation concurrently with the minimum display timer using `Future.wait`:
  1. If `AuthTokenHolder.instance.hasToken` is `false` → Navigate to `/login`.
  2. If `hasToken` is `true` → Call `AuthRepository.getMe()`:
     - **Ok(user):** Save fresh user data, navigate to `/customers`.
     - **Err(ServerFailure with 401):** Call `AuthTokenHolder.instance.clear()`, navigate to `/login`.
     - **Err(NetworkFailure / Timeout):** Allow user into `/customers` using cached credentials, as sales reps frequently operate in low/offline connectivity.
- **Rationale:** Prevents entering the app with known expired sessions while still accommodating offline usage.

### 4. Color Palette & Visual Transition
- **Choice:** Use `AppColors.brand` (`#1E40AF`) as the splash background with the white Centrow logo (`assets/img/logo.svg` in Flutter, and matching high-res PNG for native splash).
- **Rationale:** Matches the primary enterprise brand identity, creates a bold visual identity on launch, and transitions smoothly into the app shell.

## Risks / Trade-offs

- **[Risk]** Slow API response from `/v1/auth/me` delays app launch.
  - **Mitigation:** Impose a strict timeout (e.g., 3.5 seconds) on the verification call. If the request times out or experiences network issues, fall back to offline navigation using the stored session.
- **[Risk]** Visual jump between native splash and Flutter canvas.
  - **Mitigation:** Ensure background hex color and logo dimensions/aspect ratios in native splash configurations precisely match the `SplashPage` container dimensions.

## Why

The application currently launches directly into either `/login` or `/customers` from a blank native window with no splash screen or branding transition. This creates an unpolished startup experience and lacks an initial session-check gate that verifies stored credentials or handles expired tokens before navigating into the main sales app. Adding both native and in-app splash screens provides a cohesive, branded launch experience and a structured startup gate for authentication state validation.

## What Changes

- Add native launch screens for Android (including Android 12+ Splash Screen API) and iOS using `flutter_native_splash`.
- Add an in-app Flutter splash screen route (`/splash`) styled with the Centrow logo, brand colors, and subtle loading indicator.
- Configure GoRouter to use `/splash` as the `initialLocation`.
- Introduce `SplashController` in `modules/core` to coordinate startup logic:
  - Display the splash screen for a minimum duration (~1.2s) to prevent visual flickering.
  - Check local authentication storage (`AuthTokenHolder`).
  - If a token is present, validate against `/v1/auth/me` via `AuthRepository.getMe()`.
  - If token is valid, route to `/customers`.
  - If 401/invalid, clear stored session and route to `/login`.
  - If network is unavailable, gracefully proceed to `/customers` using cached credentials.
  - If no token is stored, route directly to `/login`.

## Capabilities

### New Capabilities
- `splash-screen`: Covers the app launch experience, native and in-app splash display, startup authentication validation, and initial routing.

### Modified Capabilities
*(None)*

## Impact

- **Dependencies**: Add `flutter_native_splash` to `dev_dependencies` in `pubspec.yaml`.
- **Core Module**: New `SplashPage` widget in `lib/modules/core/views/pages/splash_page.dart` and `SplashController` in `lib/modules/core/controllers/splash_controller.dart`.
- **Routing & DI**:
  - Update `lib/app/router.dart` to register `/splash` and set it as `initialLocation`.
  - Update `lib/app/di.dart` to register `SplashController`.
- **Native Platform Files**: Native assets and launch configurations generated/updated in `android/` and `ios/`.

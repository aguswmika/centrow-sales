## 1. Native Splash Screen Setup

- [x] 1.1 Add `flutter_native_splash: ^2.4.4` to `dev_dependencies` in `pubspec.yaml` with configuration (color: `#1E40AF`, image: `assets/img/app_icon_full.png`, Android 12 configuration) and verify `flutter pub get` succeeds
- [x] 1.2 Run `dart run flutter_native_splash:create` and verify native splash assets are generated in `android/app/src/main/res/` and `ios/Runner/`

## 2. Core Controller & Logic

- [x] 2.1 Implement `SplashController` in `lib/modules/core/controllers/splash_controller.dart` using pure Dart signals, orchestrating minimum display duration (~1.2s), token verification with `AuthRepository.getMe()`, and graceful offline handling; verify `dart analyze` passes clean without Flutter widget dependencies

## 3. View, DI & Router Integration

- [x] 3.1 Implement `SplashPage` in `lib/modules/core/views/pages/splash_page.dart` using `signals_flutter`, styled with `AppColors.brand` background, Centrow logo, and subtle progress indicator; verify it disposes the controller on exit
- [x] 3.2 Register `SplashController` in `lib/app/di.dart` as a factory registration
- [x] 3.3 Register `/splash` route in `lib/app/router.dart`, set `initialLocation: '/splash'`, and update redirect guards to support initial splash evaluation; verify router passes static analysis

## 4. Verification & Quality

- [x] 4.1 Run `flutter analyze` and verify static analysis passes clean with zero errors or warnings
- [x] 4.2 Run `dart format .` and verify codebase conforms to formatting standards
- [x] 4.3 Verify application boot flow manually or via widget test to confirm proper navigation to `/login` when unauthenticated and `/customers` when authenticated

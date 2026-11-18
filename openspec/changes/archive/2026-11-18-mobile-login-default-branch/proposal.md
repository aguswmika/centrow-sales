## Why

The backend change `mobile-login-default-branch` in the `centrow` repository makes `branch_id` optional on `POST /api/v1/auth/login`: without it, the session starts in the user's default branch. The same change removes the public `GET /api/v1/branches`. Today the login screen loads that endpoint, preselects the **first branch of the whole list** and requires a branch before it can submit. With several companies, that first branch can belong to a company the sales user has no access to, so the login fails with 403. The app then shows "Akun ini tidak memiliki akses ke aplikasi ini.", which misleads the user, because the 403 message is hard-coded. Once the backend ships, the screen cannot load branches at all. Every user has exactly one branch in one company, so the picker can go. The app should show which company the session is in instead.

## What Changes

- The login screen no longer shows a branch dropdown and no longer calls `GET /api/v1/branches`. Login sends only email and password, and the form is valid with a well-formed email and a password.
- The login and `/me` responses' `branch {id, name}` and `company {id, name}` are parsed into `User`. They are persisted with the stored user and restored on launch.
- The navigation rail's user menu shows the active company and branch under the name and email.
- On login failure, the server's `message` is shown for 403 too, not only for 400 and 401, and the current text is kept as the fallback.
- **BREAKING**: this build requires the backend change. It must be released together with the backend deploy, with a forced update.

## Capabilities

### New Capabilities

- `mobile-auth`: login to the sales app with email and password, the active company and branch carried in the session, and how they are shown. This app has no auth spec yet. This capability covers only what this change defines.

### Modified Capabilities

(none)

## Impact

- Removed:
  - `lib/modules/core/entities/branch.dart`
  - `lib/modules/core/repositories/dtos/branch_dto.dart`
  - `AuthRepository.getPublicBranches`
  - `LoginController.branchesState`, `selectedBranchId`, `loadBranches()` and `selectBranch()`
  - the `branchId` field of `LoginRequestDto`
- Changed:
  - `lib/modules/core/repositories/auth_repository.dart`
  - `lib/modules/core/repositories/dtos/login_request_dto.dart`, `auth_dto.dart` and `user_me_dto.dart`
  - `lib/modules/core/entities/user.dart`
  - `lib/shared/network/auth_token_holder.dart` (persist the new fields)
  - `lib/modules/core/controllers/login_controller.dart`
  - `lib/modules/core/views/pages/login_page.dart`
  - `lib/shared/widgets/nav_rail_shell.dart`
- Tests:
  - `test/modules/core/**` (repository, DTOs, login and splash controllers, login and splash pages)
  - `test/shared/widgets/nav_rail_shell_test.dart`
  - `test/shared/network/auth_token_holder_test.dart`
  - `test/widget_test.dart`

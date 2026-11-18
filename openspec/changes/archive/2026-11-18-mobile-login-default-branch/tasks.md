## 1. Data layer

- [x] 1.1 `lib/modules/core/entities/user.dart`: add `branchName`, `companyId` and `companyName` (default `''`), and include them in `copyWith`, `==`, `hashCode` and `toString`. Keep `branchId` and `branch`. Verify with `rtk flutter analyze lib/modules/core/entities/`.
- [x] 1.2 `lib/modules/core/repositories/dtos/auth_dto.dart`:
  - Read the top-level `branch` and `company` of the payload only when they are maps, filling `branchId`/`branchName` and `companyId`/`companyName`.
  - Also read the flat keys `branch_id`, `branch_name`, `company_id` and `company_name`, which is the stored-user form.
  - Keep `user.branch` (string) → `branch`.

  `lib/modules/core/repositories/dtos/user_me_dto.dart`: parse `branch {id, name}` and `company {id, name}` into the same `User` fields. Add cases to `test/modules/core/repositories/dtos/dto_test.dart` for the API form, the stored form and absent fields. Verify with `rtk flutter test test/modules/core/repositories/dtos/`.
- [x] 1.3 `lib/shared/network/auth_token_holder.dart`: `saveUser` also writes `branch_id`, `branch_name`, `company_id` and `company_name`. Restoring through `AuthDto.fromJson` reads them back (task 1.2). Extend `test/shared/network/auth_token_holder_test.dart` with a save-and-restore round trip. Verify with `rtk flutter test test/shared/network/`.
- [x] 1.4 `lib/modules/core/repositories/auth_repository.dart`, `lib/modules/core/repositories/dtos/login_request_dto.dart`:
  - Remove `getPublicBranches()` and the `branchId` login parameter, so the request body is `{email, password}`.
  - Map a 403 to the server's `message` when present, else "Akun ini tidak memiliki akses ke aplikasi ini.".
  - Delete `lib/modules/core/repositories/dtos/branch_dto.dart` and `lib/modules/core/entities/branch.dart`.
  - Update `test/modules/core/repositories/auth_repository_test.dart`.

  Verify with `rtk flutter test test/modules/core/repositories/`.

## 2. Controller and views

- [x] 2.1 `lib/modules/core/controllers/login_controller.dart`: remove `branchesState`, `selectedBranchId`, `loadBranches()` and `selectBranch()`. `isValid` depends only on the email format and a non-empty password. `login()` calls `login(email, password)`. Update `test/modules/core/controllers/login_controller_test.dart` and `test/modules/core/controllers/splash_controller_test.dart` (any fake that still implements `getPublicBranches`). Verify with `rtk flutter test test/modules/core/controllers/`.
- [x] 2.2 `lib/modules/core/views/pages/login_page.dart`: remove the `loadBranches()` call, the branch-state handling and the branch dropdown. Update `test/modules/core/views/pages/login_page_test.dart`, `test/modules/core/views/pages/splash_page_test.dart` and `test/widget_test.dart`. Verify with `rtk flutter test test/modules/core/views/ test/widget_test.dart`.
- [x] 2.3 `lib/shared/widgets/nav_rail_shell.dart`: in the user menu's header item, show `companyName` and `branchName` below the email, with "-" for an empty value. Extend `test/shared/widgets/nav_rail_shell_test.dart`. Verify with `rtk flutter test test/shared/widgets/`.

## 3. Full check

- [x] 3.1 Run `rtk flutter analyze && rtk flutter test` and confirm both pass, and confirm that `rtk grep -rn "getPublicBranches\|/v1/branches\|branch_dto" lib test` returns nothing.

## 4. Release

- [ ] 4.1 (manual) Against a backend that has the `centrow` change `mobile-login-default-branch` deployed:
  - Log in with only email and password, open the user menu and confirm that it shows the company and branch.
  - Restart the app and confirm that they are still shown.
  - With a non-sales account, confirm that the 403 shows the server's message.
- [ ] 4.2 (manual) Release this build together with the backend deploy, and force the update, because older builds cannot log in once `GET /api/v1/branches` is gone.

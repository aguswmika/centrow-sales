## 1. DTOs and Repository Layer

- [x] 1.1 Add `CreateContractAddendumRequestDto` to `lib/modules/sales/repositories/dtos/contract_addendum_dto.dart` with full pricing upsert fields (`contract_months`, `visit_frequency`, `total_visits`, `markup_type`, `markup_value`, `discount_amount`, `tax_percentage`, `supplies`, `workers`, `items`, and `reason`). Verify with `rtk flutter analyze lib/modules/sales/repositories/dtos/contract_addendum_dto.dart`.
- [x] 1.2 Update `ContractAddendumRepository` interface and `ContractAddendumRepositoryImpl` in `lib/modules/sales/repositories/contract_addendum_repository.dart` to accept `CreateContractAddendumRequestDto`, sending the payload to `POST /v1/sales/contracts/:id/addendums` and mapping HTTP 409 conflict errors. Verify with `rtk flutter analyze lib/modules/sales/repositories/contract_addendum_repository.dart`.

## 2. Controller Layer

- [x] 2.1 Update `ContractAddendumController` in `lib/modules/sales/controllers/contract_addendum_controller.dart` to invoke repository with `CreateContractAddendumRequestDto`. Verify with `rtk flutter analyze lib/modules/sales/controllers/contract_addendum_controller.dart`.
- [x] 2.2 Update or add unit tests for `ContractAddendumRepository` and `ContractAddendumController` verifying full pricing payload dispatch. Verify with `rtk flutter test test/modules/sales/controllers/contract_addendum_controller_test.dart`.

## 3. UI Workflow and Addendum Pricing Page

- [x] 3.1 Implement `ContractAddendumPricingPage` and `AddendumReviewBottomSheet` in `lib/modules/sales/views/pages/contract_addendum_pricing_page.dart` using `PricingCalculatorController` and `PricingCalculatorView` tabs, preloading baseline pricing from `contract.sourceProposalId` and supporting comparison metrics with reason input. Verify with `rtk flutter analyze lib/modules/sales/views/pages/contract_addendum_pricing_page.dart`.
- [x] 3.2 Add route `/sales/contracts/:id/addendum` in `lib/app/router.dart` accepting `Contract` extra and rendering `ContractAddendumPricingPage`. Verify with `rtk flutter analyze lib/app/router.dart`.
- [x] 3.3 Update `contract_page.dart` and `contract_detail_view.dart` to navigate to `/sales/contracts/:id/addendum` on addendum creation, remove the legacy `ContractAddendumFormSheet`, and refresh contract details upon completion. Verify with `rtk flutter analyze lib/modules/sales/views/pages/contract_page.dart`.

## 4. Verification and Clean Static Analysis

- [x] 4.1 Run full static analysis `rtk flutter analyze` and verify zero errors/warnings across the codebase.
- [x] 4.2 Run unit test suite `rtk flutter test` and verify all tests pass.

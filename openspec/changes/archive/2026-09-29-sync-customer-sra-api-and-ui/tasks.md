## 1. Entities and DTOs

- [x] 1.1 Add `siteRiskIds` and `customRisks` fields to `CreateLocationInput` in `lib/modules/sales/entities/create_customer_input.dart`, updating constructor defaults, `copyWith`, `toJson`, `==`, and `hashCode`, and verify with unit tests.
- [x] 1.2 Update `CreateCustomerLocationRequestDto` in `lib/modules/sales/repositories/dtos/customer_dto.dart` to support `siteRiskIds` and `customRisks`, sanitize manual hazards (trim whitespace, filter empty, validate length <= 255 chars), and serialize `site_risk_ids` and `custom_risks` in `toJson()`.
- [x] 1.3 Add unit tests in `test/modules/sales/repositories/dtos/customer_dto_test.dart` verifying `site_risk_ids`, `custom_risks`, and `tax_percentage` serialization for `POST /customers` and `PUT /customers/:id`, and verify via `rtk flutter test test/modules/sales/repositories/dtos/customer_dto_test.dart`.

## 2. Controller and State Management

- [x] 2.1 Update `CustomerFormController` in `lib/modules/sales/controllers/customer_form_controller.dart` to receive `SiteRiskRepository`, add `updatePrimaryLocationSra(List<String> siteRiskIds, List<String> customRisks)`, and in `loadInitialData()` fetch recorded risks for primary address via `_siteRiskRepository.getAddressRisks` to pre-populate SRA.
- [x] 2.2 Register updated dependencies in `lib/app/di.dart` for `CustomerFormController` and verify DI instantiation.
- [x] 2.3 Add unit tests in `test/modules/sales/controllers/customer_form_controller_test.dart` verifying SRA updates on primary location, edit-mode SRA pre-population, and tax percentage binding, and verify via `rtk flutter test test/modules/sales/controllers/customer_form_controller_test.dart`.

## 3. UI Components & Customer Form Integration

- [x] 3.1 Update `Step1IdentityForm` in `lib/modules/sales/views/widgets/customer_form/step1_identity_form.dart`: relabel `risk_notes` to "Catatan Risiko Internal" and add the `tax_percentage` input field bound to `controller.taxPercentage`.
- [x] 3.2 Create `CustomerFormSiteRiskSheet` in `lib/modules/sales/views/widgets/customer_form/customer_form_site_risk_sheet.dart` to allow ticking active master hazards and adding manual hazards on local form state without immediately executing HTTP writes.
- [x] 3.3 Update `Step2LocationsForm` in `lib/modules/sales/views/widgets/customer_form/step2_locations_form.dart` to display an SRA status chip and assessment launcher on the primary location card (`locations[0]`).
- [x] 3.4 Add widget tests in `test/modules/sales/views/widgets/step2_locations_form_test.dart` and `test/modules/sales/views/widgets/step1_identity_form_test.dart` verifying SRA launcher display, SRA sheet interaction, and tax percentage input, running `rtk flutter test test/modules/sales/views/widgets/`.

## 4. Verification & Static Analysis

- [x] 4.1 Run `rtk flutter analyze` to verify zero static analysis warnings or errors.
- [x] 4.2 Run `rtk flutter test` to verify all test suites across the project pass cleanly.

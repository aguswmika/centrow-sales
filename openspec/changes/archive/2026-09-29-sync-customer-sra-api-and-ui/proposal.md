## Why

The backend API contracts for `customers.md`, `site-risks.md`, and `customer-address-risks.md` have been updated to support atomic Site Risk Assessment (SRA) on the primary location (`locations[0].site_risk_ids` and `locations[0].custom_risks`) during customer creation (`POST /api/v1/sales/customers`) and customer updates (`PUT /api/v1/sales/customers/:id`). Currently, the mobile app only allows SRA assessment on existing addresses via the customer detail view, while the customer creation/edit form Step 1 confusingly labels internal notes as "Site Risk Assessment" and lacks both actual SRA selection on locations and support for customer `tax_percentage`.

Aligning the mobile app with these API contracts ensures sales reps can complete the Site Risk Assessment during initial customer onboarding, view and edit primary location SRA seamlessly, and correctly configure customer tax and internal notes.

## What Changes

- **Primary Location SRA in Customer Form**: Add Site Risk Assessment configuration directly to Step 2 (Lokasi & Alamat) for the primary location (`locations[0]`), allowing reps to tick active master items from `GET /api/v1/sales/site-risks` and add custom hazard names.
- **Atomic SRA Serialization in DTOs**: Update `CreateCustomerLocationRequestDto` to serialize `site_risk_ids` and `custom_risks` on `locations[0]` when creating or updating a customer.
- **Controller SRA Orchestration**: Extend `CreateLocationInput` with `siteRiskIds` and `customRisks`. In `CustomerFormController.loadInitialData()`, fetch recorded risks for the primary address via `GET /api/v1/sales/customers/:id/addresses/:address_id/risks` so existing assessments are pre-populated when editing.
- **Customer Form Step 1 Alignment**: Correct the mislabeled "Site Risk Assessment" field in Step 1 to "Catatan Risiko Internal" (binding to `risk_notes`), and add the `tax_percentage` input field (binding to `taxPercentage`, informational base tax percentage).
- **Customer Detail & Profile Presentation**: Display customer base tax percentage and ensure primary location SRA status is accurately refreshed after updates.

## Capabilities

### New Capabilities
- `customer-profile`: Manages customer base tax percentage (`tax_percentage`) and internal operational/credit risk notes (`risk_notes`) distinct from site hazard assessments.

### Modified Capabilities
- `site-risk-assessment`: Extends site risk assessment to customer registration and edit workflows (`locations[0]`), enabling reps to inspect, tick master hazards, and specify custom hazards atomically with customer save operations.

## Impact

- **Entities & DTOs**:
  - `lib/modules/sales/entities/create_customer_input.dart`: Add `siteRiskIds` and `customRisks` to `CreateLocationInput`.
  - `lib/modules/sales/repositories/dtos/customer_dto.dart`: Add `siteRiskIds` and `customRisks` to `CreateCustomerLocationRequestDto` (`site_risk_ids`, `custom_risks`).
- **Controllers**:
  - `lib/modules/sales/controllers/customer_form_controller.dart`: Manage SRA state for primary location, fetch recorded primary location risks in edit mode, and expose methods to update selected SRA.
- **Views & UI**:
  - `lib/modules/sales/views/widgets/customer_form/step1_identity_form.dart`: Relabel internal risk notes and add `tax_percentage` input.
  - `lib/modules/sales/views/widgets/customer_form/step2_locations_form.dart`: Add SRA summary chip / picker trigger to primary location card.
  - SRA picker sheet/dialog reusable in customer form without requiring pre-existing address ID.
- **Tests**:
  - `test/modules/sales/repositories/dtos/customer_dto_test.dart`
  - `test/modules/sales/controllers/customer_form_controller_test.dart`
  - `test/modules/sales/views/widgets/step2_locations_form_test.dart`
  - `test/modules/sales/views/widgets/step1_identity_form_test.dart`

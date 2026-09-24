## Why

The backend sales and pest control APIs have introduced several interconnected updates across the sales pipeline:
1. Mid-term contract addendums (`POST/GET /api/v1/sales/contracts/:id/addendums`) allowing active contracts to adjust total visits and recompute value from new pricing snapshots.
2. Treatment method master data (`GET /api/v1/pc/treatment-methods`) now provides an `is_required` boolean indicating whether a method is mandatory.
3. Proposal pricing (`POST/GET /api/v1/sales/proposals/:id/pricing`) now incorporates a 4th line array, `treatment_quotas`, which records explicit per-treatment-method visit quotas independent of supply frequencies.
4. Sending a proposal (`POST /api/v1/sales/proposals/:id/send`) now strictly requires the proposal's pricing to have a `treatment_quotas` entry for every active, `is_required` treatment method of the tenant (rejected with HTTP 400 otherwise).

Currently, the mobile app lacks client and UI support for contract addendums, does not capture or submit treatment quotas in the pricing calculator, does not indicate mandatory treatment methods, and can trigger 400 errors when sending proposals lacking quotas. Incorporating these updates ensures sales representatives can manage the complete lifecycle from proposal pricing to contract amendments directly from the mobile app.

## What Changes

- **Pricing Calculator Treatment Quotas**:
  - Add `treatment_quotas` (`[{"treatment_method_id": string, "quota": int}]`) to `CreatePricingRequestDto` and parse it in `PricingDetailDto`.
  - Add a 4th tab ("Kuota Treatment") to the Pricing Calculator (`PricingTabs` and `PricingTreatmentQuotaTab`) allowing sales reps to configure visit quotas per treatment method.
  - Automatically surface or provide a shortcut ("Isi Metode Wajib") to populate tenant active `is_required` treatment methods.
  - Load existing treatment quotas when editing pricing and submit updated quotas on save.

- **Proposal Sending Validation**:
  - Ensure `sendProposal` handles and surfaces validation failures when required treatment method quotas are missing.
  - Provide inline guidance/checks in the proposal view before send if pricing has unfulfilled required quotas.

- **Treatment Method Master Quota Indicator**:
  - Update `TreatmentMethod` entity and `TreatmentMethodDto` with `isRequired` mapped from `is_required`.
  - In `TreatmentMethodPickerSheet`, render a "Wajib" indicator badge for required methods.

- **Contract Addendum Management**:
  - Implement data layer (entity, DTO, repository) for `POST /api/v1/sales/contracts/:id/addendums` and `GET /api/v1/sales/contracts/:id/addendums`.
  - Add `ContractAddendumController` and state management for history retrieval and form submission.
  - In `ContractDetailPane`, display an Addendum History section showing old/new visits, old/new values, delta, reason, and date.
  - In `ContractDetailPane`, provide a "Buat Addendum" bottom sheet for active contracts with live total visits calculation, validation against scheduled visits, and 409 conflict recovery.
  - Automatically refresh contract detail and master list upon addendum creation.

## Capabilities

### New Capabilities
- `contract-addendums`: API client, data models, state handling, and creation flow for mid-term contract addendums (visit adjustments and value recalculations).
- `treatment-methods`: Master treatment method handling including the `is_required` mandatory quota flag and badge display in picker interfaces.
- `pricing-treatment-quotas`: Pricing calculator support for configuring, loading, and submitting explicit per-treatment-method visit quotas (`treatment_quotas`).

### Modified Capabilities
- `contract-detail`: Extend contract detail pane with addendum history timeline/list and addendum creation triggers for active contracts.

## Impact

- **Affected Modules/Files**:
  - `lib/modules/pc/entities/treatment_method.dart` (add `isRequired`)
  - `lib/modules/pc/repositories/dtos/treatment_method_dto.dart` (map `is_required`)
  - `lib/modules/sales/views/widgets/treatment_method_picker_sheet.dart` ("Wajib" badge)
  - `lib/modules/sales/entities/pricing_detail.dart` (add `PricingDetailTreatmentQuota` entity)
  - `lib/modules/sales/repositories/dtos/pricing_dto.dart` (add `treatment_quotas` to request DTO)
  - `lib/modules/sales/repositories/dtos/pricing_detail_dto.dart` (deserialize `treatment_quotas`)
  - `lib/modules/sales/controllers/pricing_calculator_controller.dart` (manage quota state, load, validate, submit)
  - `lib/modules/sales/views/widgets/pricing_calculator/pricing_tabs.dart` (add 4th tab: Kuota Treatment)
  - `lib/modules/sales/views/widgets/pricing_calculator/pricing_treatment_quota_tab.dart` (new tab widget)
  - `lib/modules/sales/controllers/proposal_controller.dart` & `proposal_page.dart` (send proposal validation & error handling)
  - `lib/modules/sales/entities/contract_addendum.dart` (new)
  - `lib/modules/sales/repositories/dtos/contract_addendum_dto.dart` (new)
  - `lib/modules/sales/repositories/contract_addendum_repository.dart` (new)
  - `lib/modules/sales/controllers/contract_addendum_controller.dart` (new)
  - `lib/modules/sales/views/widgets/contract_addendum_form_sheet.dart` (new)
  - `lib/modules/sales/views/widgets/contract_addendum_history_list.dart` (new)
  - `lib/modules/sales/views/widgets/contract_detail_pane.dart` (addendum history & action)
  - `lib/app/di.dart` (register new repository and controller)
- **Dependencies**: No external package additions; uses existing Flutter, Signals, Dio, and GetIt.
- **Breaking Changes**: None. Additive fields and new endpoints remain backwards compatible with existing server contracts.

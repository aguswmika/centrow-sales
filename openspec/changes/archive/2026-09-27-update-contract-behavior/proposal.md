## Why

The backend Sales Contracts API contract (`/api/v1/sales/contracts`) has updated contract creation and editing behavior:
1. `POST /api/v1/sales/proposals/:id/contract` no longer accepts `end_date` in the request body because the server now always computes `end_date` automatically from `start_date` + the proposal pricing's `contract_months`.
2. `PUT /api/v1/sales/contracts/:id` is strictly draft-only, accepts `end_date` for manual adjustment on existing drafts, but permanently locks `contract_template_id` (not accepted in update requests).
3. Contract creation helper copy and validations in the mobile app currently still prompt for `end_date` on creation and reference outdated derivation rules.

Updating the mobile client aligns contract generation and editing with the latest backend API contract, avoiding unnecessary inputs and contract creation mismatches.

## What Changes

- **Proposal-to-Contract Conversion**:
  - Remove the manual `end_date` ("Tanggal Selesai") input when converting a proposal into a contract in `ContractFormBottomSheet`, and omit `end_date` from the `POST /api/v1/sales/proposals/:id/contract` request payload.
  - Inform the user in the form helper that `end_date` is automatically calculated by the server from the proposal pricing duration (`contract_months`).
  - Enforce `contract_template_id` as mandatory in create mode.
- **Draft Contract In-Place Editing**:
  - Keep `end_date` editable and optional during `PUT /api/v1/sales/contracts/:id` (draft editing).
  - Hide and omit `contract_template_id` from the update payload since template selection is locked permanently upon contract creation.
- **Request DTO Adjustments**:
  - Explicitly separate or configure conversion request DTO (no `end_date`, requires `contract_template_id`) vs draft update request DTO (includes optional `end_date`, no `contract_template_id`).
- **Form Copy & Helper Details**:
  - Update informational hints to clearly state that contract value, total visits, and contract duration/end date derive directly from the proposal pricing.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `contract-detail`: Update contract form specifications regarding automated end date calculation on proposal conversion, draft editing rules, and template locking.

## Impact

- **Affected Code**:
  - `lib/modules/sales/controllers/contract_form_controller.dart`
  - `lib/modules/sales/views/widgets/contract_form_bottom_sheet.dart`
  - `lib/modules/sales/repositories/dtos/contract_dto.dart`
  - `lib/modules/sales/repositories/contract_repository.dart`
- **APIs**:
  - `POST /api/v1/sales/proposals/:id/contract` (payload omits `end_date`)
  - `PUT /api/v1/sales/contracts/:id` (payload omits `contract_template_id`)
- **Breaking Changes**: None for external consumers. Internal DTO / form controller behavior is adjusted.

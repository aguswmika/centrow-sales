## Why

The backend API for contract addendums (`POST /api/v1/sales/contracts/:id/addendums`) has transitioned from accepting a simple `{visit_delta, reason}` payload to requiring a full pricing upsert payload (`contract_months`, `visit_frequency`, `total_visits`, `markup_type`, `markup_value`, `discount_amount`, `tax_percentage`, `supplies`, `workers`, `items`, and optional `reason`). In addition, the scheduled visit floor restriction and visit delta validation rules were removed on the server. The mobile client UI currently still uses a delta stepper bottom sheet (`ContractAddendumFormSheet`), causing addendum creation attempts to fail against the updated backend.

## What Changes

- **BREAKING**: Replaced contract addendum creation request payload from `{visit_delta, reason}` with the full pricing upsert shape plus `reason`.
- **BREAKING**: Replaced the visit delta stepper bottom sheet (`ContractAddendumFormSheet`) with a comprehensive Addendum Pricing workflow leveraging the pricing calculator components (`PricingCalculatorView`, duration, visits, supplies, workers, items, markups, and reason input).
- **Update**: Prepopulate addendum pricing from the contract's baseline pricing (originating proposal pricing) so sales representatives can adjust existing lines and visit parameters instead of starting from scratch.
- **Update**: Remove obsolete client-side visit-delta validations (such as visit delta cannot be zero or resulting visits below scheduled count). The only validation is `total_visits > 0` alongside standard pricing line validations.
- **Update**: Derived visit delta (`new_total_visits - old_total_visits`) and contract value delta are calculated for user preview and displayed from server responses.
- **Update**: Refactor `ContractAddendumRepository` and add `CreateContractAddendumRequestDto` to send the full pricing payload to `POST /api/v1/sales/contracts/:id/addendums`.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `contract-addendums`: Update addendum creation requirements to submit a full pricing specification with optional reason, remove scheduled visit floor restriction, and receive derived visit delta and snapshot updates.
- `contract-detail`: Update addendum creation action to launch the addendum pricing flow instead of the legacy visit-delta stepper sheet.

## Impact

- **Mobile API Layer**: `ContractAddendumRepository`, `CreateContractAddendumRequestDto`, and `ContractAddendumController` in `lib/modules/sales/`.
- **Mobile UI Layer**: `lib/modules/sales/views/widgets/contract_addendum_form_sheet.dart` is replaced or repurposed; addendum creation entry in `contract_page.dart` / `contract_detail_view.dart` routes to the addendum pricing workflow.
- **Router / Navigation**: Add route or navigation support for contract addendum pricing configuration (e.g. `/sales/contracts/:id/addendum`).
- **Dependencies**: Reuses existing `PricingCalculatorController`, `PricingSupplyRow`, `PricingWorkerRow`, `PricingItemRow`, and pricing calculator tab widgets.

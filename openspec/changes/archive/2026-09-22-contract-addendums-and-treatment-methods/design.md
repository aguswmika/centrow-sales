## Context

See `proposal.md` for motivation.

The mobile app is built with Flutter using a layered architecture (`View → Controller → Repository → Entity`) with `signals` for reactive state, `dio` for networking, and `get_it` for dependency injection.

Recent backend API changes establish a closed loop across the sales and pest control lifecycle:
1. Master Data: `GET /api/v1/pc/treatment-methods` includes `is_required: bool`.
2. Pricing: `POST/GET /api/v1/sales/proposals/:id/pricing` includes a 4th line array `treatment_quotas` (`[{"treatment_method_id": string, "quota": int}]`). Quotas are structural data (not used in cost calculations) copied forward during proposal revisions and addendum pricing snapshots.
3. Proposal Lifecycle: `POST /api/v1/sales/proposals/:id/send` gates on having a `treatment_quotas` entry for every active, required method.
4. Contract Addendum: `POST/GET /api/v1/sales/contracts/:id/addendums` allows mid-term visit count adjustments on active contracts, creating an independently priced snapshot while leaving treatment quotas unscaled.

## Goals / Non-Goals

**Goals:**
- Provide full client data and state management for contract addendums (`ContractAddendum` entity, DTO, repository, controller).
- Add an Addendum History view section and "Buat Addendum" bottom sheet dialog in `ContractDetailPane` for active contracts.
- Support `is_required` in `TreatmentMethod` entity and DTO, showing a "Wajib" badge in `TreatmentMethodPickerSheet`.
- Support `treatment_quotas` in pricing entities, DTOs, and calculator controller.
- Add a 4th tab ("Kuota Treatment") to the Pricing Calculator (`PricingTabs` and `PricingTreatmentQuotaTab`) with ability to add/remove methods and adjust quotas, plus an "Isi Metode Wajib" shortcut.
- Enhance proposal send error mapping and UI alerts when required treatment method quotas are missing.

**Non-Goals:**
- Modifying proposal pricing mathematical calculations (subtotal, markup, tax) — quotas are structural visit counts and do not impact pricing cost totals.
- Editing or deleting contract addendums (addenda records are immutable and append-only).
- Modifying proposal revision deep-copy logic (already handled server-side).

## Decisions

### 1. Dedicated `PricingTreatmentQuotaTab` vs embedding in existing tabs
- **Choice**: Add a 4th tab (`Kuota Treatment`) in `PricingTabs` alongside Supplies, Workers, and Items.
- **Rationale**: Quotas are conceptually independent of chemical/supply costs (as confirmed in `pricings.md` and `pc-treatment-methods.md`). Giving quotas a dedicated tab mirrors the backend 4th line array and keeps supply costing clean.
- **Alternative Considered**: Embedding quotas inside `PricingMaterialTab`. Rejected because supply frequency is a costing figure whereas treatment quota is a contract visit quota.

### 2. Pricing Calculator State for Quotas
- **Choice**: In `PricingCalculatorController`, introduce a reactive list `final treatmentQuotas = <PricingTreatmentQuotaRow>[].toSignal();` where each row holds `treatmentMethodId`, `treatmentMethodName`, `isRequired`, and a `Signal<int> quota`.
- **Rationale**: Follows the existing pattern of `PricingSupplyRow`, `PricingWorkerRow`, and `PricingItemRow`, enabling reactive tab counters and clean disposal.
- **Alternative Considered**: Plain primitive maps. Rejected because `PricingSupplyRow` uses signals for input reactivity and validation.

### 3. Dedicated `ContractAddendumRepository` and `ContractAddendumController`
- **Choice**: Create dedicated repository and controller for contract addendums.
- **Rationale**: Keeps repository files cohesive and matches the modular patterns in `lib/modules/sales/repositories/` (`contract_document_repository.dart`, `contract_category_repository.dart`).
- **Alternative Considered**: Bloating `ContractRepository` and `ContractController`. Rejected to maintain single-responsibility.

### 4. Treatment Method `isRequired` badge
- **Choice**: Display an `AppBadge.warn(text: 'Wajib')` in `TreatmentMethodPickerSheet` for methods where `isRequired == true`.
- **Rationale**: Reuses existing badge and wrap layout, giving immediate clarity to sales reps.

### 5. Proposal Send Validation Guidance
- **Choice**: Handle 400 responses from `sendProposal` with explicit parsing of required quota errors and provide helpful dialog guidance directing the user to edit pricing if required quotas are missing.
- **Rationale**: Catches backend constraints gracefully and guides the rep immediately to the resolution step.

## Risks / Trade-offs

- **[Risk] Missing Required Quota when Sending Proposal**: Rep fills pricing supplies and workers but forgets to set quotas, failing at send time.
  - *Mitigation*: In the "Kuota Treatment" tab, provide an "Isi Metode Wajib" button, or auto-seed rows for all active `is_required` methods on initial pricing creation.
- **[Risk] Concurrent Addendum Conflict (HTTP 409)**: If another user applies an addendum concurrently, the submission fails with 409.
  - *Mitigation*: Map HTTP 409 to a user-friendly message prompting the user to reload the contract before retrying.
- **[Risk] Negative Visit Delta below Scheduled Visits**: Server rejects negative deltas if total visits drops below scheduled PC visits.
  - *Mitigation*: Surface the backend error message directly in the bottom sheet and perform basic client validation (`new_total_visits > 0`).
- **[Risk] State Desynchronization on Addendum Creation**: Contract value and visits change after an addendum.
  - *Mitigation*: On addendum success, reload both the selected contract detail and the contract master list.

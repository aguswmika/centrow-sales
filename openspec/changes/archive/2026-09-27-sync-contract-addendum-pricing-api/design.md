## Context

The backend API for contract addendums (`POST /api/v1/sales/contracts/:id/addendums`) has evolved from accepting a visit delta stepper to accepting a full pricing upsert payload (`contract_months`, `visit_frequency`, `total_visits`, `markup_type`, `markup_value`, `discount_amount`, `tax_percentage`, `supplies`, `workers`, `items`, and optional `reason`). The mobile client currently houses a simple bottom sheet (`ContractAddendumFormSheet`) that only accepts an integer delta and reason, which is no longer compatible.

## Goals / Non-Goals

**Goals:**
- Provide a dedicated, responsive addendum pricing workflow for active contracts that reuses existing pricing calculator tabs and state management (`PricingCalculatorView`, `PricingCalculatorController`).
- Prepopulate addendum pricing from the contract's baseline proposal pricing (`sourceProposalId`).
- Display an addendum summary review showing before/after visit counts and contract value comparisons, with an addendum reason input field.
- Refactor `ContractAddendumRepository`, `ContractAddendumController`, and DTOs to serialize and send the full pricing payload.
- Gracefully handle API response codes including HTTP 409 (concurrent modification conflict).

**Non-Goals:**
- Modifying proposal pricing calculation logic or proposal workflow.
- Editing or deleting past addendum records (addendums are immutable snapshots).
- Web app Inertia document editing (addendum creation is mobile-only).

## Decisions

### 1. Dedicated `ContractAddendumPricingPage` Route
- **Decision**: Add a new route `/sales/contracts/:id/addendum` (`contract-addendum-pricing`) instead of overloading modal bottom sheets.
- **Rationale**: Pricing configuration involves multiple tabs (Chemicals & Tools, Workers, Items), duration/frequency/visit controls, markup and tax settings. A full-screen page offers the necessary workspace and keyboard handling for tablets and phones.
- **Alternatives considered**: Expanding `ContractAddendumFormSheet` into a multi-step bottom sheet. Rejected because pricing calculator tabs require full screen real estate and scrolling context.

### 2. Reuse `PricingCalculatorController` and Widgets
- **Decision**: Reuse `PricingCalculatorController`, `PricingSupplyRow`, `PricingWorkerRow`, `PricingItemRow`, and `PricingCalculatorView` child tabs (`PricingSupplyTab`, `PricingWorkerTab`, `PricingItemTab`, `PricingSettingsCard`).
- **Rationale**: Addendum pricing calculation semantics, validations, and line structures are identical to proposal pricing. Reusing existing controllers and widgets avoids code duplication and ensures formula consistency.
- **Details**: Pre-fill the controller via `loadExistingPricing(contract.sourceProposalId!)` during initialization.

### 3. Addendum Review & Reason Confirmation Sheet
- **Decision**: From the pricing calculator action bar, tapping "Review Addendum" opens an `AddendumReviewBottomSheet` displaying:
  - Total visits comparison: current contract visits vs new total visits, plus derived visit delta (`new - old`).
  - Contract value comparison: current contract value vs estimated new contract value (calculated or previewed).
  - Reason text input (`reason`, optional, up to 1000 characters).
  - "Terapkan Addendum" button executing `ContractAddendumController.createAddendum(...)`.
- **Rationale**: Separates pricing item editing from the final verification and justification step, ensuring the sales agent can double-check the financial and operational impact before committing.

### 4. Data Transfer Object (`CreateContractAddendumRequestDto`)
- **Decision**: Define `CreateContractAddendumRequestDto` inheriting or embedding pricing fields (`contract_months`, `visit_frequency`, `total_visits`, `markup_type`, `markup_value`, `discount_amount`, `tax_percentage`, `supplies`, `workers`, `items`) plus `reason`.
- **Rationale**: Matches the backend contract addendum upsert shape defined in `contract-addendums.md`.

## Risks / Trade-offs

- **[Risk] Contract lacks `sourceProposalId` or proposal pricing not found**
  → *Mitigation*: Gracefully handle missing baseline pricing by initializing with sensible defaults (e.g. contract's current total visits and duration) and displaying an empty calculator ready for inputs.
- **[Risk] Concurrent Addendum Conflict (HTTP 409)**
  → *Mitigation*: Map HTTP 409 in `ContractAddendumRepositoryImpl` and display an explicit error dialog prompting the user to refresh the contract before resubmitting.
- **[Risk] Large line item payloads on low-bandwidth mobile connections**
  → *Mitigation*: Show clear loading state on the submit button with network timeout handling.

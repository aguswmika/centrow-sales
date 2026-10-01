## Why

The backend Sales & Pest Control APIs have undergone breaking domain updates removing the per-treatment-method visit quota engine and contract schedule cycles, while introducing direct contract total visits, supply-line treatment method assignments with tool installation counts, and template requirements for proposals and contracts. The mobile sales application must be updated to align with these API contracts, eliminate obsolete quota/cycle UI elements, and support the new pricing and supply line fields.

## What Changes

- **BREAKING (Removal)**: Remove the "Kuota Treatment" tab, quota row inputs, and treatment quota payload serialization (`treatment_quotas`) from the pricing calculator, controller, entities, and DTOs.
- **BREAKING (Removal)**: Remove `is_required` parsing, domain flags, and "Wajib" badges from treatment methods.
- **BREAKING (Removal)**: Remove `schedule_cycle` (Tahunan/Bulanan) from `ContractCategory`, `Contract`, and related UI/labels in contract forms and detail panes.
- **NEW**: Add required `total_visits` field (> 0) to proposal pricing calculation header in state, preview, submission, and UI parameter bar.
- **NEW**: Add supply line enhancements for both chemicals and tools:
  - Optional `treatment_method_id`, `area_kerja`, and `note` fields on each supply line.
  - Required `installed_units` integer field on tool supply lines (`supply_type: 2`), with input validation.
- **MODIFICATION**: Update contract detail visit display to show `total_visits` ("Total Kunjungan") without schedule cycle suffix.
- **MODIFICATION**: Ensure proposal creation and contract conversion enforce whitelisted template selection (`proposal_template_id` and `contract_template_id`).

## Capabilities

### New Capabilities
- `pricing-supply-methods-and-visits`: Covers configuring `total_visits` on pricing calculations and capturing `treatment_method_id`, `area_kerja`, `note`, and tool `installed_units` on supply lines.

### Modified Capabilities
- `pricing-treatment-quotas`: Removes the per-treatment-method quota configuration tab, persistence, and proposal send quota gating.
- `treatment-methods`: Removes mandatory status flags (`is_required`) and "Wajib" badges from treatment method master data and selection sheets.
- `contract-detail`: Removes schedule cycle (Tahunan / Bulanan) designations from contract detail visit displays and category selection.

## Impact

- **Affected Code & UI**:
  - `lib/modules/sales/controllers/pricing_calculator_controller.dart`: Remove quota signals/methods; add `totalVisits`; update `PricingSupplyRow` with new fields; update request payload builders and validations.
  - `lib/modules/sales/views/widgets/pricing_calculator/`: Remove `pricing_treatment_quota_tab.dart`; update `pricing_tabs.dart` (3 tabs); update `pricing_material_tab.dart` (support treatment method, work area, note, and tool installed units).
  - `lib/modules/sales/views/pages/pricing_page.dart`: Add `total_visits` input in parameter bar.
  - `lib/modules/pc/entities/treatment_method.dart`, DTO, and `treatment_method_picker_sheet.dart`: Remove `isRequired`.
  - `lib/modules/sales/entities/contract_category.dart`, `contract.dart`, DTOs, and `contract_form_bottom_sheet.dart`: Remove `ContractScheduleCycle` and its display logic.
  - Tests referencing `treatmentQuotas`, `scheduleCycle`, or `isRequired`.
- **API Endpoints**:
  - `POST /api/v1/sales/proposals/:id/pricing`
  - `GET /api/v1/sales/proposals/:id/pricing`
  - `POST /api/v1/sales/proposals/:id/pricing/preview`
  - `GET /api/v1/pc/treatment-methods`
  - `GET /api/v1/sales/contract-categories`
  - `GET /api/v1/sales/contracts/:id`

## Context

The backend Sales & Pest Control APIs have undergone breaking changes (documented across `pc-treatment-methods.md`, `pricings.md`, `contracts.md`, `contract-categories.md`, `proposals.md`, `schedule-spk.md`, and `contract-addendums.md`).
The mobile app (`centrow-sales`) uses a layered architecture (`View → Controller → Repository → Entity/DTO`) with `signals` for reactive state management. This design outlines how to align the mobile app's domain models, DTOs, controllers, views, and unit tests with the updated API specifications.

See `proposal.md` for motivation and background.

## Goals / Non-Goals

**Goals:**
- Completely remove the treatment quota engine and UI ("Kuota Treatment" tab, quota rows, quota signals, quota serialization) from the pricing calculator.
- Remove `is_required` from `TreatmentMethod` entity, DTO, and picker sheet.
- Remove `schedule_cycle` from `ContractCategory` and `Contract` entities, DTOs, and contract UI.
- Add required `total_visits` (> 0) to proposal pricing header (controller signals, parameter bar UI, request/response DTOs, and validation).
- Add support for supply line metadata:
  - `treatment_method_id`, `area_kerja`, and `note` across all supply lines (chemical and tool).
  - Required `installed_units` (> 0) on tool supply lines (`supply_type: 2`), with input widget and validation.
- Update contract detail and category picker to display straightforward total visits without renewal cycle labels.

**Non-Goals:**
- SPK document viewing or downloading in mobile (endpoints `GET /api/pc/contracts/:id/spk` and `/pdf` are web-only).
- Altering the contract addendum creation flow (addendum endpoint contract `visit_delta` + `reason` is unchanged; cloning is handled server-side).

## Decisions

### 1. Pricing Calculator Header: `total_visits`
- **Choice**: Introduce a new `totalVisits = signal<int?>(null)` in `PricingCalculatorController`.
- **UI**: Add a third parameter item in `_buildParamBar` within `pricing_page.dart` labeled "Total Kunjungan", with an icon, numeric input, and suffix "Kali".
- **Validation**: Enforce `totalVisits.value != null && totalVisits.value! > 0` before preview and save.
- **DTOs**: Add `total_visits` to `CreatePricingRequestDto`, `PricingDetailDto`, and `PricingDetail` entity.

### 2. Supply Row Enhancement & Tool Installed Units
- **Choice**: Expand `PricingSupplyRow` to manage new supply line attributes:
  - `treatmentMethodId` (string uuid, optional)
  - `treatmentMethodName` (string, optional)
  - `treatmentMethodCode` (string, optional)
  - `areaKerja` (`Signal<String>`)
  - `note` (`Signal<String>`)
  - `installedUnits` (`Signal<int?>`) — required for `kind == 2` (tool)
- **UI for Tools**:
  - In `PricingToolRowWidget`, add inputs for Treatment Method (tappable picker), Installed Units (`CounterInput` starting at 1), Area Kerja (text input), and Catatan (text input).
- **UI for Chemicals**:
  - In `PricingSupplyRowWidget`, allow viewing/modifying treatment method, Area Kerja, and Catatan.
- **Validation**:
  - In `_validateInputs()`, verify that every tool supply line has `installedUnits.value != null && installedUnits.value! > 0`. If invalid, set error state: `"Jumlah unit terpasang untuk <tool> wajib diisi (> 0)"`.

### 3. Removal of Quota Tab and Quota Logic
- **Choice**:
  - Delete `pricing_treatment_quota_tab.dart` and its test `pricing_treatment_quota_tab_test.dart`.
  - In `PricingTabs`, reduce `tabTitles` to 3 items:
    1. Persiapan Bahan & Alat
    2. Tenaga Kerja
    3. Transport & Add-on
  - In `PricingCalculatorView`, update `_buildTabContent()` to remove `case 3`.
  - In `PricingCalculatorController`, remove `_treatmentQuotas`, `treatmentQuotas`, `readonlyTreatmentQuotas`, `addTreatmentQuota`, `removeTreatmentQuota`, `updateTreatmentQuota`, `populateRequiredMethods`, etc.
  - In `PricingDto` / `PricingDetailDto`, remove `treatment_quotas` serialization and deserialization.

### 4. Removal of `is_required` from Treatment Methods
- **Choice**:
  - In `TreatmentMethodDto` and `TreatmentMethod` entity: remove `isRequired`.
  - In `TreatmentMethodPickerSheet`: remove the `AppBadge.warn(text: 'Wajib')` badge.
  - In `ProposalRepository`: remove quota gating on `sendProposal`.

### 5. Removal of `schedule_cycle` from Contract and Category
- **Choice**:
  - In `ContractCategory` and `Contract`: delete `ContractScheduleCycle` enum and `scheduleCycle` property.
  - In `ContractCategoryDto` and `ContractDto`: remove `schedule_cycle` parsing.
  - In `contract_form_bottom_sheet.dart`: remove schedule cycle display from category items and remove the cycle helper note.
  - In `contract_detail_pane.dart`: format visit count as `"TOTAL KUNJUNGAN"` (`"${contract.totalVisits ?? 0}x"`), without cycle conditions.

## Risks / Trade-offs

- **[Risk]** Existing draft proposals with saved pricing may fail validation if re-opened without `total_visits`.
  - **Mitigation**: Prepopulate `totalVisits` from existing saved `total_visits` on `PricingDetailDto`; if null, fallback to `visitFrequency` or 1 during initial load.
- **[Risk]** Tool supply lines require `installed_units` in the backend, or backend returns 400.
  - **Mitigation**: Client-side validation prevents preview/submission if any tool row has `installed_units <= 0`, with immediate inline or snackbar feedback.
- **[Risk]** Breaking changes in existing widget and controller tests.
  - **Mitigation**: Update all affected test files (`pricing_calculator_controller_test.dart`, `pricing_calculator_view_test.dart`, `contract_form_bottom_sheet_test.dart`, `contract_controller_test.dart`, etc.) to match the new 3-tab layout and updated models.

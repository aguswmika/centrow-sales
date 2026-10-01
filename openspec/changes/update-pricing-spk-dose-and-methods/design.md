## Context

The backend pricing upsert (`pricings.md`), contract addendums (`contract-addendums.md`), and schedule SPK documents (`schedule-spk.md`) have updated their validation and schemas:
1. `treatment_method_id` is mandatory on all supply lines (chemical and tool).
2. `spk_dose_usage` is mandatory and must be > 0 on chemical supply lines.
3. Pricing calculators in proposal pricing and contract addendums share the same underlying `PricingCalculatorController`, `PricingSupplyDto`, and supply row widgets.

See `proposal.md` for motivation and `specs/` for normative requirements.

## Goals / Non-Goals

**Goals:**
- Update `PricingSupplyDto`, `PricingDetailSupplyDto`, `PricingDetailSupply` entity, and `PricingSupplyRow` to support `spk_dose_usage` and enforce mandatory `treatment_method_id`.
- Update `PricingCalculatorController` input validation to require `treatmentMethodId` on all supplies and `spkDoseUsage > 0` on chemical supplies.
- Update `PricingMaterialTab` UI:
  - Add input for `spk_dose_usage` (Dosis SPK) for chemical lines, defaulting to `dose_usage`.
  - Ensure treatment method is selected when adding a tool line (`_handleAddTool`).
  - Provide easy selection/re-selection of treatment method on both chemical and tool rows.
  - Prevent clearing treatment method to null.
- Ensure `CreateContractAddendumRequestDto` carries the new supply line schema.
- Update unit and widget tests to cover new fields and validations.

**Non-Goals:**
- Implementing SPK document generation/rendering in Flutter (web-only per `schedule-spk.md`).
- Altering COGS or pricing total formulas (the SPK dose is informational for work order printing and does not impact line totals or COGS).

## Decisions

### 1. Default `spk_dose_usage` from `dose_usage`
- **Choice**: When a chemical supply line is created from a product mapping or loaded from legacy pricing without `spk_dose_usage`, initialize `spk_dose_usage` to `dose_usage`.
- **Rationale**: The backend changelog notes that existing lines were backfilled from `dose_usage`, and in practice the SPK dose defaults to the application dose unless specifically overridden.
- **Alternative considered**: Leaving it null or 0. Rejected because it forces manual re-entry on every added chemical item even when application dose equals SPK dose.

### 2. Treatment Method flow when adding tools (`_handleAddTool`)
- **Choice**: When tapping "Tambah Alat", first present `TreatmentMethodPickerSheet`, then upon selecting a method, open `ProductPickerSheet(kind: 2)` and attach the selected method to the new tool row.
- **Rationale**: Parallels `_handleAddSupply` and ensures no tool line is ever created without an assigned treatment method, avoiding unnecessary validation friction.
- **Alternative considered**: Allowing tools to be added without a method and relying on inline selection. Rejected because users might forget to assign it, resulting in blocking validation errors upon saving.

### 3. Placement of Dosis SPK in Chemical Supply Row
- **Choice**: Place the Dosis SPK input in the secondary section of `PricingSupplyRowWidget` alongside `areaKerja` and `note` (or as a clear input group), sharing `uomCode`.
- **Rationale**: The primary row already contains 4 numeric/dropdown columns (Dosis Penggunaan, Volume Pengaplikasian, Frekuensi, Actions). Adding another numeric column to the primary horizontal header row would cause overflow or severe crowding on narrower screens/tablets. Placing it in the secondary row with a clear label "Dosis SPK (<uom>)" keeps the row clean, legible, and intuitive.
- **Alternative considered**: Squeezing an extra column into the header row. Rejected due to layout overflow on smaller viewports.

### 4. Inline treatment method switching and validation
- **Choice**: On `PricingToolRowWidget` and `PricingSupplyRowWidget`, allow tapping the treatment method badge to open `TreatmentMethodPickerSheet` to switch the method, and remove the `Icons.close` button that clears the method to null.
- **Rationale**: The API requires every line to have a method. Allowing clearing to null creates invalid state. Switching is supported by opening the picker.

## Risks / Trade-offs

- **[Risk] Existing drafts or active contract pricings missing `treatment_method_id`**:
  -> **Mitigation**: When loading existing pricing, if `treatment_method_id` is null or empty, display a prominent warning badge/button `+ Pilih Metode (Wajib)` so the user can easily assign one before saving.
- **[Risk] User enters 0 or negative for Dosis SPK**:
  -> **Mitigation**: `validateInputs()` explicitly checks `m.spkDoseUsage.value <= 0` and presents a toast notification indicating which chemical item needs a valid Dosis SPK before any network request is made.

## 1. Data Layer — Add `spk_dose_usage` to supply DTOs and entity

- [x] 1.1 In [`lib/modules/sales/entities/pricing_detail.dart`](lib/modules/sales/entities/pricing_detail.dart), add `final double? spkDoseUsage;` field to `PricingDetailSupply`, add it to the constructor, and add it to `copyWith`. Verify by running `rtk flutter analyze` with no new errors.
- [x] 1.2 In [`lib/modules/sales/repositories/dtos/pricing_detail_dto.dart`](lib/modules/sales/repositories/dtos/pricing_detail_dto.dart), add `final double? spkDoseUsage;` to `PricingDetailSupplyDto`, parse it in `fromJson` (`j['spk_dose_usage'] == null ? null : (j['spk_dose_usage'] as num).toDouble()`), and propagate it to `toEntity()`. Verify the dto test at `test/modules/sales/repositories/dtos/pricing_dto_test.dart` passes.
- [x] 1.3 In [`lib/modules/sales/repositories/dtos/pricing_dto.dart`](lib/modules/sales/repositories/dtos/pricing_dto.dart), add `final double? spkDoseUsage;` to `PricingSupplyDto`, add it to the constructor, and emit it in `toJson()` for chemical lines only (`if (supplyType == 1 && spkDoseUsage != null) 'spk_dose_usage': spkDoseUsage`). Verify `test/modules/sales/repositories/dtos/pricing_dto_test.dart` passes.

## 2. Controller — Add `spkDoseUsage` to `PricingSupplyRow` and update validation + payload

- [x] 2.1 In [`lib/modules/sales/controllers/pricing_calculator_controller.dart`](lib/modules/sales/controllers/pricing_calculator_controller.dart), add `final Signal<double> spkDoseUsage;` to `PricingSupplyRow`, initialised via a new `initialSpkDoseUsage` parameter (defaults to `initialDoseUsage`). Dispose it in `PricingSupplyRow.dispose()`. Verify `rtk flutter analyze` passes.
- [x] 2.2 In `PricingCalculatorController.addSupplyRow(ProductMapping)`, set `initialSpkDoseUsage` to `mapping.defaultDose ?? mapping.doseMinLimit` (same as `initialDoseUsage`). Verify via `test/modules/sales/controllers/pricing_calculator_controller_test.dart`.
- [x] 2.3 In `PricingCalculatorController.loadExistingPricing`, pass `initialSpkDoseUsage: s.spkDoseUsage ?? (s.doseUsage ?? 1.0)` when constructing `PricingSupplyRow` from a loaded `PricingDetailSupply`. Verify that loading a pricing where `spkDoseUsage` is null defaults to `doseUsage`.
- [x] 2.4 In `PricingCalculatorController.validateInputs()`, after the existing chemical dose-range checks, add:
  - For every chemical supply line (`m.kind == 1`): if `m.spkDoseUsage.value <= 0`, return `'Dosis SPK untuk ${m.title} harus lebih dari 0.'`.
  - For every supply line (`m.kind == 1 || m.kind == 2`): if `m.treatmentMethodId.value == null || m.treatmentMethodId.value!.isEmpty`, return `'Metode penanganan untuk ${m.title} wajib dipilih.'`.
  Verify via `test/modules/sales/controllers/pricing_calculator_controller_test.dart` that validation blocks on both conditions.
- [x] 2.5 In `PricingCalculatorController.buildRequest()`, pass `spkDoseUsage: m.kind == 1 ? m.spkDoseUsage.value : null` to `PricingSupplyDto`. Verify `buildRequest()` test covers chemical lines emitting `spk_dose_usage` and tool lines not emitting it.

## 3. UI — Chemical Supply Row: add Dosis SPK input and enforce treatment method

- [x] 3.1 In [`lib/modules/sales/views/widgets/pricing_calculator/pricing_material_tab.dart`](lib/modules/sales/views/widgets/pricing_calculator/pricing_material_tab.dart) in `PricingSupplyRowWidget`, add a `CounterInput` (or numeric `TextFormField`) for Dosis SPK in the secondary row, next to `areaKerja` / `note`. Label it `'Dosis SPK (${row.uomCode})'`. Bind it to `row.spkDoseUsage`. Disable when `isReadOnly`. Verify the widget renders in the test at `test/modules/sales/views/widgets/pricing_calculator_view_test.dart`.
- [x] 3.2 In `PricingSupplyRowWidget`, replace the plain treatment method badge display with the same tappable picker UX already used in `PricingToolRowWidget` (i.e. tapping the badge opens `TreatmentMethodPickerSheet`, updating `row.treatmentMethodId/Name/Code`). Remove the `Icons.close` button that clears the treatment method to null. If method is unset and `!isReadOnly`, show `'+ Pilih Metode (Wajib)'` badge in warning color (e.g. `AppColors.error` or orange) to signal mandatory selection. Verify visual state renders correctly in widget test.

## 4. UI — Tool Supply Row: require treatment method on add and disallow clearing

- [x] 4.1 In `PricingSupplyTab._handleAddTool`, adopt the two-step flow: first show `TreatmentMethodPickerSheet`, and only if a method is selected, then show `ProductPickerSheet(kind: 2)`. Attach the selected `TreatmentMethod` as `initialTreatmentMethodId/Name/Code` on the new `PricingSupplyRow`. Verify `_handleAddTool` no longer creates rows with null `treatmentMethodId`.
- [x] 4.2 In `PricingToolRowWidget`, remove the `Icons.close` button that clears the treatment method to null. Replace with: if method is set, show tappable badge to switch; if unset and `!isReadOnly`, show `'+ Pilih Metode (Wajib)'` in warning color. Verify via widget tests.

## 5. Tests — Update and extend test coverage

- [x] 5.1 Update `test/modules/sales/repositories/dtos/pricing_dto_test.dart` to assert `PricingSupplyDto.toJson()` emits `spk_dose_usage` for chemical lines and omits it for tool lines, and that `PricingDetailSupplyDto.fromJson` maps `spk_dose_usage` correctly (including null → null).
- [x] 5.2 Update `test/modules/sales/controllers/pricing_calculator_controller_test.dart` to cover:
  - `validateInputs()` returns the treatment-method error when any supply line lacks a method.
  - `validateInputs()` returns the SPK dose error when a chemical line has `spkDoseUsage <= 0`.
  - `buildRequest()` includes `spk_dose_usage` on chemical lines and excludes it on tool lines.
  - `loadExistingPricing` initialises `spkDoseUsage` from `PricingDetailSupply.spkDoseUsage`, falling back to `doseUsage`.
- [x] 5.3 Run `rtk flutter test` and verify all 502 existing tests still pass plus the new ones, with no regressions.

## 6. Final Validation

- [x] 6.1 Run `rtk flutter analyze` and confirm zero issues.
- [x] 6.2 Run `rtk flutter test` and confirm all tests pass.

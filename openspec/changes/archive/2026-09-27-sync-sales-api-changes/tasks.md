## 1. Domain Entities & DTOs

- [x] 1.1 Remove `isRequired` from `TreatmentMethod` entity and `TreatmentMethodDto`, and verify with `rtk flutter analyze`
- [x] 1.2 Remove `ContractScheduleCycle` and `scheduleCycle` from `ContractCategory`, `Contract`, and their DTOs (`contract_category_dto.dart`, `contract_dto.dart`), and verify with `rtk flutter analyze`
- [x] 1.3 Add `total_visits` and supply line fields (`treatment_method_id`, `area_kerja`, `note`, `installed_units`) to `PricingSupplyDto`, `PricingDetailDto`, `CreatePricingRequestDto`, and `PricingDetail` entity, while removing `treatment_quotas` DTOs/lists, and verify with `rtk flutter analyze`

## 2. Pricing Calculator Controller

- [x] 2.1 Update `PricingSupplyRow` to include `treatmentMethodId`, `treatmentMethodName`, `treatmentMethodCode`, `areaKerja`, `note`, and `installedUnits` signals and their disposal
- [x] 2.2 Add `totalVisits` signal to `PricingCalculatorController` and update `_validateInputs()` to validate `totalVisits > 0` and tool lines `installedUnits > 0`
- [x] 2.3 Remove `_treatmentQuotas`, quota signals, and quota manipulation methods from `PricingCalculatorController`, updating `_buildRequest()` to serialize `total_visits` and supply fields without `treatment_quotas`
- [x] 2.4 Update existing pricing loading logic in `PricingCalculatorController` to populate `totalVisits` and supply row metadata without quota rows, and verify with `rtk flutter test test/modules/sales/controllers/pricing_calculator_controller_test.dart`

## 3. Pricing Calculator UI

- [x] 3.1 Update `_buildParamBar` in `pricing_page.dart` to add a parameter item for "Total Kunjungan" (`totalVisits`), and verify visual layout
- [x] 3.2 Update `PricingTabs` in `pricing_tabs.dart` to show 3 tabs (Persiapan Bahan & Alat, Tenaga Kerja, Transport & Add-on), and delete `pricing_treatment_quota_tab.dart`
- [x] 3.3 Update `PricingCalculatorView` to remove tab index 3 (Kuota Treatment) from `_buildTabContent()`
- [x] 3.4 Update `PricingToolRowWidget` and `PricingSupplyRowWidget` in `pricing_material_tab.dart` to display/edit treatment method, work area (`area_kerja`), notes (`note`), and tool installed units (`installed_units`), and verify widget rendering

## 4. Contract UI & Treatment Method Picker

- [x] 4.1 Update `TreatmentMethodPickerSheet` in `treatment_method_picker_sheet.dart` to remove "Wajib" badge rendering
- [x] 4.2 Update `contract_form_bottom_sheet.dart` to remove schedule cycle mentions in category selector and helper texts
- [x] 4.3 Update `contract_detail_pane.dart` to display visit frequency as "TOTAL KUNJUNGAN" without schedule cycle suffixes, and verify with `rtk flutter analyze`

## 5. Verification & Tests

- [x] 5.1 Update unit and widget tests affected by the removals and additions (`contract_form_bottom_sheet_test.dart`, `pricing_calculator_view_test.dart`, etc.), and delete obsolete `pricing_treatment_quota_tab_test.dart`
- [x] 5.2 Run `rtk flutter analyze` and `rtk flutter test` to ensure static analysis and full test suite pass clean

## 1. DTO Parsing & Normalization

- [x] 1.1 Update `CustomerLocationDto._parseRegionRef` and `CustomerLocationDto.fromJson` to handle generic `Map` structures, numeric string IDs, and alias keys (`city`, `subdistrict`, `kabupaten`, `kecamatan`, `kelurahan`), and verify with unit tests in `test/modules/sales/repositories/dtos/customer_dto_test.dart`
- [x] 1.2 Enhance `normalizeRegionName` and `isRegionMatch` in `customer_form_controller.dart` to support administrative prefix variations and punctuation, and verify with unit tests in `test/modules/sales/controllers/customer_form_controller_test.dart`

## 2. Controller Pre-population & Resolution

- [x] 2.1 Update `CustomerFormController.loadInitialData` to ensure both region IDs and region names are fully resolved and set into `CreateLocationInput` for all 4 administrative tiers, and verify with unit tests in `test/modules/sales/controllers/customer_form_controller_test.dart`

## 3. UI Cascading Synchronization in RegionPicker

- [x] 3.1 Update `RegionPicker` initialization and `didUpdateWidget` to trigger cascading loads when existing region data is provided and bind dropdown values correctly, and verify with widget tests in `test/modules/sales/views/widgets/region_picker_test.dart`
- [x] 3.2 Ensure dependent dropdowns in `RegionPicker` enable appropriately and show correct placeholders without false disabled states, and verify with widget tests in `test/modules/sales/views/widgets/region_picker_test.dart`

## 4. Verification

- [x] 4.1 Run `rtk flutter test test/modules/sales/` and `rtk flutter analyze` to verify all tests pass and static analysis is clean

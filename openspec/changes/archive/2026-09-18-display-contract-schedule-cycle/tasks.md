## 1. Domain Entities & DTOs

- [x] 1.1 Add `ContractScheduleCycle` enum with `yearly` and `monthly` values, serialization helper `fromDynamic`, and verify with unit tests in `test/modules/sales/entities/contract_category_test.dart`
- [x] 1.2 Update `ContractCategory` entity and `ContractCategoryDto` to parse `schedule_cycle` and expose `scheduleCycle`, verifying parsing in `test/modules/sales/repositories/dtos/contract_category_dto_test.dart`
- [x] 1.3 Update `Contract` entity and `ContractDetailDto` to parse `schedule_cycle` / `category_schedule_cycle`, adding `visitFrequencyLabel` and `formattedVisitFrequency` helpers, and verify in `test/modules/sales/entities/contract_test.dart`

## 2. UI Presentation & Components

- [x] 2.1 Update `ContractDetailPane` to render dynamic visit frequency labels ("FREK. KUNJUNGAN (BULANAN)" vs "FREK. KUNJUNGAN (TAHUNAN)" vs fallback "TOTAL KUNJUNGAN"), and verify with widget tests in `test/modules/sales/views/widgets/contract_detail_pane_test.dart`
- [x] 2.2 Update `ContractFormBottomSheet` category selector options and context guidance to indicate schedule cycle ("Bulanan" vs "Tahunan"), and verify with widget tests

## 3. Verification & Analysis

- [x] 3.1 Run full sales contract test suite with `rtk flutter test test/modules/sales/` and verify all tests pass
- [x] 3.2 Run `rtk flutter analyze` and `rtk dart format` to ensure zero static analysis warnings and proper code formatting

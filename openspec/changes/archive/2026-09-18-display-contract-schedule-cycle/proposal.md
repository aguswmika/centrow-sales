## Why

Contract categories in the backend declare a `schedule_cycle` (1 = Tahunan / Yearly, 2 = Bulanan / Monthly) that dictates whether contract visit quotas accrue as a one-time lifetime quota or renew every calendar month. Currently, the mobile app does not parse or display the schedule cycle, rendering a generic "TOTAL KUNJUNGAN" label in the contract detail pane and providing no cycle indicator when selecting categories in the contract creation/edit form. Users cannot readily distinguish whether a contract's visit frequency applies per month or across the full contract period.

## What Changes

- Parse `schedule_cycle` (1 = Tahunan, 2 = Bulanan) in `ContractCategoryDto` and `ContractDetailDto`.
- Introduce `ContractScheduleCycle` enum in the sales module entities with labels `Tahunan` and `Bulanan`.
- Update `ContractDetailPane` to dynamically display the visit frequency label based on the contract's schedule cycle:
  - Monthly: "FREK. KUNJUNGAN (BULANAN)" with formatted value e.g. "4x / bulan" (or "4x")
  - Yearly: "FREK. KUNJUNGAN (TAHUNAN)" with formatted value e.g. "12x / tahun" (or "12x")
  - Default / Unspecified fallback to "TOTAL KUNJUNGAN".
- Update `ContractFormBottomSheet` category selector and helper texts to show the schedule cycle indicator ("Bulanan" vs "Tahunan") next to or under category names so sales reps know the visit frequency period when creating contracts.

## Capabilities

### Modified Capabilities
- `contract-detail`: Add requirements for schedule cycle-aware visit frequency labeling in the contract detail pane and category schedule cycle visibility in the contract creation and edit form.

## Impact

- Entities: `lib/modules/sales/entities/contract.dart`, `lib/modules/sales/entities/contract_category.dart`
- DTOs: `lib/modules/sales/repositories/dtos/contract_dto.dart`, `lib/modules/sales/repositories/dtos/contract_category_dto.dart`
- Widgets: `lib/modules/sales/views/widgets/contract_detail_pane.dart`, `lib/modules/sales/views/widgets/contract_form_bottom_sheet.dart`
- Tests: `test/modules/sales/views/widgets/contract_detail_pane_test.dart`, `test/modules/sales/controllers/contract_controller_test.dart`

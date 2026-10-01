## 1. Entities

- [x] 1.1 Add `scheduleWorkOrderType` (`int`) field to `PricingDetail` entity (`lib/modules/sales/entities/pricing_detail.dart`) — verify the class compiles and existing entity tests still pass (`rtk flutter test test/modules/sales/repositories/dtos/pricing_dto_test.dart`)
- [x] 1.2 Add `scheduleWorkOrderType` (`int?`) field to `Contract` entity (`lib/modules/sales/entities/contract.dart`), include it in `copyWith`, and verify contract entity tests still pass (`rtk flutter test test/modules/sales/repositories/dtos/contract_dto_test.dart`)

## 2. DTOs

- [x] 2.1 Add `scheduleWorkOrderType` field to `CreatePricingRequestDto` (`lib/modules/sales/repositories/dtos/pricing_dto.dart`): constructor, `toJson()` key `schedule_work_order_type`; default to `1` when not provided — verify `toJson()` output contains the key
- [x] 2.2 Add `scheduleWorkOrderType` field to `PricingDetailDto` (`lib/modules/sales/repositories/dtos/pricing_detail_dto.dart`): parse `json['schedule_work_order_type']` with `int` fallback `1`; include in `toEntity()` — verify updated tests in `pricing_dto_test.dart`
- [x] 2.3 Add `scheduleWorkOrderType` field to `CreateContractAddendumRequestDto` (`lib/modules/sales/repositories/dtos/contract_addendum_dto.dart`): constructor, `toJson()` key `schedule_work_order_type`; propagate from `fromPricingRequest` — verify addendum DTO `toJson()` includes key
- [x] 2.4 Add `scheduleWorkOrderType` field to `ContractDetailDto` (`lib/modules/sales/repositories/dtos/contract_dto.dart`): parse `json['schedule_work_order_type']` with `int?` nullable fallback; include in `toEntity()` — verify updated contract DTO tests

## 3. Controller

- [x] 3.1 Add `final scheduleWorkOrderType = signal<int>(1)` and `ReadonlySignal<int> get scheduleWorkOrderType` getter to `PricingCalculatorController` (`lib/modules/sales/controllers/pricing_calculator_controller.dart`)
- [x] 3.2 Add `void setScheduleWorkOrderType(int type)` intent method to `PricingCalculatorController`
- [x] 3.3 Update `buildRequest()` in `PricingCalculatorController` to pass `scheduleWorkOrderType: scheduleWorkOrderType.value` to `CreatePricingRequestDto` — verify `rtk flutter test test/modules/sales/controllers/pricing_calculator_controller_test.dart`
- [x] 3.4 Update `loadExistingPricing` in `PricingCalculatorController` to restore `scheduleWorkOrderType` from `PricingDetail.scheduleWorkOrderType` after loading — verify that a loaded pricing restores the signal value
- [x] 3.5 Dispose `scheduleWorkOrderType` signal in `PricingCalculatorController.dispose()` — verify no signal leak warnings in tests

## 4. Pricing Page UI

- [x] 4.1 Add a two-option segmented toggle ("Routine" / "Station") to `_buildParamBar` in `PricingPage` (`lib/modules/sales/views/pages/pricing_page.dart`), wrapped in `SignalBuilder` reading `_calcController.scheduleWorkOrderType`, calling `_calcController.setScheduleWorkOrderType(value)` on tap — verify the toggle appears and is reactive in `rtk flutter analyze`
- [x] 4.2 Add the same segmented toggle to `_buildParamBar` in `ContractAddendumPricingPage` (`lib/modules/sales/views/pages/contract_addendum_pricing_page.dart`)
- [x] 4.3 In `ContractAddendumPricingPage.initState`, after resolving the source pricing, call `_calcController.setScheduleWorkOrderType(widget.contract.scheduleWorkOrderType ?? 1)` to pre-fill from the contract — verify the toggle shows the contract's current type on page load

## 5. Contract Detail UI

- [x] 5.1 In the contract detail section of `ContractPage` (`lib/modules/sales/views/pages/contract_page.dart`), add a row or badge displaying "Jenis Penjadwalan: Routine" when `scheduleWorkOrderType == 1` and "Jenis Penjadwalan: Station" when `scheduleWorkOrderType == 2`; hide the row when the value is `null` or `0` — verify display in `rtk flutter analyze`

## 6. Tests & Verification

- [x] 6.1 Update `pricing_dto_test.dart` fixture JSON to include `schedule_work_order_type` and assert the field is parsed and mapped correctly
- [x] 6.2 Update `contract_dto_test.dart` fixture JSON to include `schedule_work_order_type` and assert the field is parsed and mapped correctly
- [x] 6.3 Update `contract_addendum_repository_test.dart` fixture to include `schedule_work_order_type` in `CreateContractAddendumRequestDto` and assert it appears in `toJson()`
- [x] 6.4 Update `pricing_calculator_controller_test.dart` to assert `scheduleWorkOrderType` defaults to `1`, changes via `setScheduleWorkOrderType`, and is included in `buildRequest()` output
- [x] 6.5 Run full test suite and static analysis — verify `rtk flutter test` and `rtk flutter analyze` pass with no errors

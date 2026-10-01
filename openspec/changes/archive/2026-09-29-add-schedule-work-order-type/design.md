## Context

The sales mobile app uses a layered Flutter architecture: View → Controller → Repository → Entity. State is managed via `signals`. The pricing calculation is coordinated through `PricingCalculatorController`, which holds all header signals (`contractMonths`, `visitFrequency`, `totalVisits`, etc.) and builds `CreatePricingRequestDto` for API calls. See `proposal.md` for the motivation.

**Current state**:
- `CreatePricingRequestDto.toJson()` does not include `schedule_work_order_type` → server returns HTTP 400 on every pricing save and preview since 2026-09-27.
- `CreateContractAddendumRequestDto.toJson()` does not include `schedule_work_order_type` → server returns HTTP 400 on every addendum creation.
- `ContractDetailDto` / `Contract` entity do not carry `scheduleWorkOrderType` → the field returned by `GET /v1/sales/contracts/:id` is silently dropped.

**Key files**:
- `lib/modules/sales/repositories/dtos/pricing_dto.dart` — `CreatePricingRequestDto`
- `lib/modules/sales/repositories/dtos/pricing_detail_dto.dart` — `PricingDetailDto`
- `lib/modules/sales/entities/pricing_detail.dart` — `PricingDetail`
- `lib/modules/sales/repositories/dtos/contract_addendum_dto.dart` — `CreateContractAddendumRequestDto`
- `lib/modules/sales/repositories/dtos/contract_dto.dart` — `ContractDetailDto`
- `lib/modules/sales/entities/contract.dart` — `Contract`
- `lib/modules/sales/controllers/pricing_calculator_controller.dart` — `PricingCalculatorController`
- `lib/modules/sales/views/pages/pricing_page.dart` — `_buildParamBar`
- `lib/modules/sales/views/pages/contract_addendum_pricing_page.dart` — `_buildParamBar`
- `lib/modules/sales/views/pages/contract_page.dart` — contract detail pane

## Goals / Non-Goals

**Goals:**
- Fix the HTTP 400 regressions on pricing save/preview and addendum create by including `schedule_work_order_type` in the request payloads.
- Expose a UI selector (two-option toggle: Routine / Station) in the pricing parameter header for both `PricingPage` and `ContractAddendumPricingPage`.
- Default `schedule_work_order_type` to `1` (Routine) on fresh calculators and populate it from the server when loading existing pricing.
- Parse and display `schedule_work_order_type` in the contract detail pane.

**Non-Goals:**
- Changing how PC scheduling itself uses the field on the backend.
- Customer photos (`customer-photos.md`), treatment-method master list (`pc-treatment-methods.md`), and contract conversion (`contracts.md`) — verified aligned already; no mobile-side changes required.
- Adding `schedule_work_order_type` to the pricing preview response DTO (the API docs state the preview response does not echo this field).

## Decisions

### 1. Signal `scheduleWorkOrderType` in `PricingCalculatorController`

Add a `final scheduleWorkOrderType = signal<int>(1)` to `PricingCalculatorController`. Expose a `ReadonlySignal` getter and a `setScheduleWorkOrderType(int)` intent. Include the value in `buildRequest()` so both `submitPricing` and `previewPricing` (and the addendum path that reuses `buildRequest()`) automatically carry it.

*Alternative*: pass `schedule_work_order_type` separately to repository methods — rejected because it breaks the existing clean `buildRequest()` abstraction and duplicates state.

### 2. UI Control: Segmented Toggle in `_buildParamBar`

Add a compact two-button segmented control (Row of two `OutlinedButton`s or a `SegmentedButton`) labelled "Routine" and "Station" beneath or alongside the existing three numeric fields in both `_buildParamBar` implementations. Wrap in a `SignalBuilder` for reactive updates.

*Alternative*: Use a `DropdownButton` — rejected; two options are better served by a toggle that is glanceable without tapping.

### 3. DTO changes follow the DTO-only pattern

Add `scheduleWorkOrderType` field to `CreatePricingRequestDto`, `PricingDetailDto`→`PricingDetail`, `CreateContractAddendumRequestDto`, and `ContractDetailDto`→`Contract`. All serialization/deserialization stays inside DTOs. Entities remain pure Dart.

### 4. Addendum page initialises from `contract.scheduleWorkOrderType`

`ContractAddendumPricingPage` already receives a `Contract` object. After parsing `scheduleWorkOrderType` from the contract detail response, the page calls `_calcController.setScheduleWorkOrderType(widget.contract.scheduleWorkOrderType ?? 1)` in `initState`, providing a pre-filled starting point the user may change.

### 5. Display in contract detail pane

Add a small info row / badge to the contract detail section in `ContractPage` showing "Jenis Penjadwalan: Routine" or "Jenis Penjadwalan: Station". Falls back silently (hidden row) if the value is `0` / null (legacy contracts).

## Risks / Trade-offs

- **Schedule work order type = 0 on legacy contracts**: Server docs note `0` if no resolvable pricing. The `Contract` entity should hold `int? scheduleWorkOrderType` (nullable) and the UI should hide the row rather than show a confusing "Unknown" label.
- **`PricingDetailDto` has no `scheduleWorkOrderType` today**: When `loadExistingPricing` runs, the field will now be parsed and restored into the calculator. If the server returns `null` or omits it (e.g., old records), the fallback of `1` ensures the UI stays valid and the next save will write a valid value.
- **Test coverage**: Existing pricing DTO and calculator tests will need `scheduleWorkOrderType` added to fixture JSON and assertions; missing this will cause test failures caught at `flutter test`, not at runtime.

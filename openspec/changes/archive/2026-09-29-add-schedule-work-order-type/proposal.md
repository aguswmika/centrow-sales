## Why

Backend API changes dated 2026-09-27 introduced a mandatory `schedule_work_order_type` (`1` = Routine, `2` = Station) field to proposal pricing and contract addendums, as well as exposing this field on the contract detail response.

Without this field sent from the sales mobile app:
- Saving pricing (`POST /api/v1/sales/proposals/:id/pricing`) fails with HTTP 400 `"Jenis penjadwalan tidak valid"`.
- Applying a contract addendum (`POST /api/v1/sales/contracts/:id/addendums`) fails with HTTP 400 `"Jenis penjadwalan tidak valid"`.
- Sales reps and planners cannot see or configure whether standard-flow visit schedules for the proposal and resulting contract default to Routine or Station.

## What Changes

- **Proposal Pricing Calculation Header**:
  - Add `schedule_work_order_type` (integer: `1` for Routine, `2` for Station) to the pricing calculation header state, DTOs (`CreatePricingRequestDto`, `PricingDetailDto`), and entity (`PricingDetail`).
  - Default `schedule_work_order_type` to `1` (Routine).
  - Add UI controls (segmented selector / dropdown) in the pricing parameter header bar on `PricingPage` / `PricingCalculatorView` so reps can toggle between Routine and Station.
  - Send `schedule_work_order_type` in `POST /api/v1/sales/proposals/:id/pricing` and `POST /api/v1/sales/proposals/:id/pricing/preview`.
- **Contract Addendum**:
  - Add `schedule_work_order_type` to `CreateContractAddendumRequestDto` and ensure it is included in the request payload for `POST /api/v1/sales/contracts/:id/addendums`.
  - Provide a UI control for `schedule_work_order_type` in `ContractAddendumPricingPage` (or carry it forward from existing pricing and allow editing).
- **Contract Detail**:
  - Add `schedule_work_order_type` to `ContractDetailDto` and `Contract` entity.
  - Display the contract's schedule work order type (e.g. badge "Jenis Penjadwalan: Routine" or "Station") in the contract detail pane in `ContractPage`.
- **API Audit Verification**:
  - Verified `/Users/agus/Project/centrow/docs/api/customer-photos.md`: customer survey photo endpoints (upload, list, delete) are already implemented and aligned.
  - Verified `/Users/agus/Project/centrow/docs/api/pc-treatment-methods.md`: treatment method master listing and quota removals are already implemented and aligned.
  - Verified `/Users/agus/Project/centrow/docs/api/contracts.md`: conversion endpoint omitting `end_date` is already implemented and aligned.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `pricing-supply-methods-and-visits`: Require and capture `schedule_work_order_type` (`1` = Routine, `2` = Station) in proposal pricing header.
- `contract-addendums`: Require and send `schedule_work_order_type` in contract addendum pricing payloads.
- `contract-detail`: Parse and display `schedule_work_order_type` in contract detail.

## Impact

- **Entities**:
  - `PricingDetail`: add `scheduleWorkOrderType` (int).
  - `Contract`: add `scheduleWorkOrderType` (int?).
- **DTOs**:
  - `CreatePricingRequestDto`: add `schedule_work_order_type` to request and `toJson()`.
  - `PricingDetailDto`: parse `schedule_work_order_type` from response and map to entity.
  - `CreateContractAddendumRequestDto`: add `schedule_work_order_type` to request and `toJson()`.
  - `ContractDetailDto`: parse `schedule_work_order_type` from response and map to entity.
- **Controllers**:
  - `PricingCalculatorController`: add signal/state `scheduleWorkOrderType`, validate input, populate from existing pricing, and include in `buildRequest()`.
- **Views**:
  - `PricingPage` / `PricingCalculatorView`: render schedule work order type selector in parameter bar.
  - `ContractAddendumPricingPage`: render schedule work order type selector in parameter bar.
  - `ContractPage`: render schedule work order type badge / label in detail pane.

## Why

Backend API updates on proposal pricing (`pricings.md`), contract addendums (`contract-addendums.md`), and schedule SPK documents (`schedule-spk.md`) introduce breaking validations:
1. `treatment_method_id` is now strictly required on every supply line (both chemical and tool). Omitting or leaving it empty causes a `400` rejection (`"Metode penanganan wajib diisi"`).
2. Chemical supply lines require `spk_dose_usage` (number, > 0) representing the actual dose printed on the SPK document. Omitting or passing a non-positive value causes a `400` rejection (`"Dosis SPK wajib diisi"`).
3. Contract addendums submit the full pricing upsert payload and enforce these same supply validations.

The sales mobile/tablet app must adopt these API changes in its data models, DTOs, calculation validation, and pricing calculator UI so that proposals and contract addendums can be configured, previewed, and submitted without validation failures.

## What Changes

- **BREAKING**: Require `treatment_method_id` on every supply line (chemical and tool) in `PricingSupplyDto`, `PricingSupplyRow`, and input validation across proposal pricing and contract addendums.
- **BREAKING**: Require `spk_dose_usage` (> 0) on chemical supply lines (`supply_type: 1`) in `PricingSupplyDto`, `PricingDetailSupplyDto`, `PricingDetailSupply` entity, `PricingSupplyRow`, and input validation.
- **UI Adjustment — Chemical Supplies**:
  - Add input field for `spk_dose_usage` (Dosis SPK) in `PricingSupplyRowWidget`, defaulting to `dose_usage` when mapping is selected or empty.
  - Allow viewing and selecting/updating `treatment_method_id` on chemical lines.
- **UI Adjustment — Tool Supplies**:
  - Require selecting a treatment method when adding or editing a tool line; remove the ability to clear treatment method to null.
- **Validation**:
  - Update `PricingCalculatorController.validateInputs()` to enforce `treatmentMethodId` on every supply line and `spkDoseUsage > 0` on chemical lines.
- **Contract Addendums**:
  - Ensure `CreateContractAddendumRequestDto` accurately maps and transmits `spk_dose_usage` and `treatment_method_id` on all supply lines.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `pricing-supply-methods-and-visits`: Require `treatment_method_id` on all supply lines (both chemical and tool) and require `spk_dose_usage` (> 0) on chemical lines, adding corresponding inputs and validation in the pricing calculator.
- `contract-addendums`: Require `treatment_method_id` on all supply lines and `spk_dose_usage` on chemical lines in the contract addendum pricing submission payload and validation.

## Impact

- **Models & DTOs**:
  - `lib/modules/sales/repositories/dtos/pricing_dto.dart` (`PricingSupplyDto`)
  - `lib/modules/sales/repositories/dtos/pricing_detail_dto.dart` (`PricingDetailSupplyDto`)
  - `lib/modules/sales/entities/pricing_detail.dart` (`PricingDetailSupply`)
- **Controllers & State**:
  - `lib/modules/sales/controllers/pricing_calculator_controller.dart` (`PricingSupplyRow`, validation, and payload mapping)
- **Views & Widgets**:
  - `lib/modules/sales/views/widgets/pricing_calculator/pricing_material_tab.dart` (`PricingSupplyRowWidget`, `PricingToolRowWidget`, `_handleAddTool`, and `_handleAddSupply`)
  - `lib/modules/sales/views/pages/contract_addendum_pricing_page.dart` (uses pricing calculator controller & supply tab)
- **Tests**:
  - Unit and widget tests for pricing DTOs, `PricingCalculatorController`, `PricingSupplyTab`, and `ContractAddendumPricingPage`.

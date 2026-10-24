## 1. DTO and Entity Updates

- [x] 1.1 Update `PricingItemDto` to include optional `unitCost` (serialized to `unit_cost`) and verify serialization in tests.
- [x] 1.2 Update `PricingPreviewDto` and `PricingPreview` entity to parse `addon_cost` and verify preview serialization tests.
- [x] 1.3 Update `PricingDetailDto`, `PricingDetailItemDto`, and `PricingDetail` entity to parse and map `unitCost` and `addonCost`.
- [x] 1.4 Support `kind: 6` (Tambahan Paket) in product models and ensure product pickers can query or filter kind 6.

## 2. Controller Logic and State Management

- [x] 2.1 Update `PricingItemRow` in `PricingCalculatorController` to support an editable `unitCost` signal for custom items (`kind == 0`).
- [x] 2.2 Update `PricingCalculatorController` to accept `markup_type: 1` and `3` only, removing legacy `2`, and auto-migrating legacy `markupType == 2` to `3` in `loadExistingPricing`.
- [x] 2.3 Store and expose the calculated nominal offer figures (subtotal before tax and total after tax) from preview responses in `PricingCalculatorController`.
- [x] 2.4 Update item line total calculation logic to divide by visit frequency when an add-on item belongs to `kind == 6` (Tambahan Paket).
- [x] 2.5 Update `buildRequest()` to serialize `unit_cost` for manual items and `markup_type: 1 | 3`, setting `discount_amount` to 0.

## 3. UI Component Updates

- [x] 3.1 Update `PricingSettingsCard` terminology from "Markup" to "Penawaran", displaying dropdown choices "Persentase (%)" (`1`) and "Nilai Tetap (Rp)" (`3`).
- [x] 3.2 Add dynamic nominal offer display in Rupiah (before and after tax) under the percentage input in `PricingSettingsCard`.
- [x] 3.3 Remove or de-emphasize the "Diskon Khusus" input from `PricingSettingsCard`.
- [x] 3.4 Update `PricingItemTab` to provide selection for Add-on Paket (`kind: 6`) and allow entering unit cost on custom items.
- [x] 3.5 Update `PricingPreviewPage` to display "Biaya Add-on" in the COGS breakdown and reflect the offer-based structure.
- [x] 3.6 Ensure `ContractAddendumPricingPage` and `AddendumReviewBottomSheet` reflect the new offer settings and review summary.

## 4. Verification and Testing

- [x] 4.1 Update and run unit and widget tests for pricing calculator, DTOs, and settings card to verify expected behaviors.
- [x] 4.2 Run `rtk flutter analyze` and verify zero errors and warnings.

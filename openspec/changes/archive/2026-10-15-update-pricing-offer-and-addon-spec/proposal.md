## Why

The backend sales API contract has been updated on 2026-10-14 with breaking changes to pricing calculations (`pricings.md`, `contract-addendums.md`, `products.md`, and `proposals.md`). Pricing calculations now follow an offer-based model (*penawaran*) where add-on items are included inside the offer rather than added on top of it, `markup_type` accepts only `1` (Persentase) and `3` (Jumlah) while rejecting `2` (Nominal), discounts are ignored, add-on packages (`kind: 6`) are supported, and manual add-ons accept an optional unit cost. The mobile client must be aligned with these backend changes to avoid validation errors (HTTP 400), clarify the pricing mental model for sales users by using the term **"Penawaran"** instead of "Markup", and display the calculated nominal amount when entering percentages.

## What Changes

- **BREAKING**: Remove `markup_type: 2` (Nominal) from pricing requests and UI; add `markup_type: 3` (Jumlah / Nilai Tetap Penawaran).
- Replace the term **"Markup"** across user-facing mobile UI with **"Penawaran"** (e.g. "Jenis Penawaran", "Nilai Penawaran").
- In **Persentase (%)** mode, display the calculated nominal offer in Rupiah (before and after tax) directly in the settings card so the user sees the concrete monetary value.
- Ignore and de-emphasize `discount_amount` in calculations and UI since the backend stores and returns `0` without reducing the offer.
- Support Add-on Package products (`kind: 6`) alongside standard Add-ons (`kind: 5`), calculating package line totals via `(qty × unit_price) / frequency`.
- Support optional manual unit cost (`unit_cost`) on custom items (`kind == 0`) so cost figures feed accurately into the backend COGS.
- Update `PricingPreviewDto` and `PricingPreview` to parse and display `addon_cost` as part of `total_cogs`.
- Update contract addendum pricing flows to adopt the same offer-based rules and UI terminology.

## Capabilities

### New Capabilities
- `pricing-offer-and-addons`: Defines requirements for offer-based pricing selection (Persentase vs Nilai Tetap), nominal preview under percentage mode, add-on package lines (`kind: 6`), and `addon_cost` breakdown.

### Modified Capabilities
- `pricing-custom-items`: Updates requirements for custom/manual pricing items to support optional editable `unit_cost` serialized in the pricing request payload.

## Impact

- **Models & DTOs**: `PricingItemDto`, `CreatePricingRequestDto`, `PricingPreviewDto`, `PricingPreview`, `PricingDetailDto`, `PricingDetailItemDto`.
- **Controllers**: `PricingCalculatorController` (update markup signals, item serialization, kind 6 handling, nominal preview).
- **Views**:
  - `lib/modules/sales/views/widgets/pricing_calculator/pricing_settings_card.dart`
  - `lib/modules/sales/views/widgets/pricing_calculator/pricing_item_tab.dart`
  - `lib/modules/sales/views/pages/pricing_preview_page.dart`
  - `lib/modules/sales/views/pages/contract_addendum_pricing_page.dart`
  - `lib/modules/sales/views/widgets/product_picker_sheet.dart`

## Why

Sales representatives frequently encounter operational costs and client-requested add-on services or miscellaneous items that are not pre-configured in the central product catalog (`/v1/products`). Currently, the Transport & Add-on tab only allows picking predefined products from the catalog via `ProductPickerSheet`. When reps need to include a non-catalog expense or custom add-on, they cannot input it directly, blocking accurate quotation and calculation.

## What Changes

- Add a new button `+ Item Kustom` (or `+ Manual`) in `PricingItemTab` next to `+ BBM` and `+ Add-on`.
- Allow adding custom pricing item rows with `kind == 0` that do not have a master product ID (`productId: null`).
- Make the title/name of `kind == 0` rows directly editable via an inline text input field, allowing reps to type custom descriptions (e.g. "Sewa Mobil Pickup", "Perizinan Khusus", "Custom Fogging").
- Render editable price input for `kind == 0` items (similar to Add-on items).
- When serializing the pricing request in `PricingCalculatorController.buildRequest()`, map `kind == 0` items to `item_type: 2` (Add-on / Ekstra revenue) with `product_id: null` (omitted from payload), sending user-entered `name`, `qty`, `frequency`, and `unit_price`.
- When loading existing pricing details via `loadExistingPricing`, identify items with null `productId` or custom items and restore them as `kind == 0` editable rows.

## Capabilities

### New Capabilities
- `pricing-custom-items`: Requirements for adding, editing, rendering, and submitting custom/manual non-catalog items (`kind == 0`) with no product ID in pricing calculations.

### Modified Capabilities
<!-- None -->

## Impact

- **UI**: `PricingItemTab` and `PricingItemRowWidget` in `lib/modules/sales/views/widgets/pricing_calculator/pricing_item_tab.dart`.
- **Controller**: `PricingCalculatorController` in `lib/modules/sales/controllers/pricing_calculator_controller.dart` (`items`, `PricingItemRow`, `buildRequest`, `loadExistingPricing`).
- **Tests**: `pricing_calculator_controller_test.dart` and `pricing_calculator_view_test.dart`.
- **API compatibility**: `PricingItemDto` already supports `productId: null` and omits `product_id` when null, which matches backend requirements.

## Why

The Centrow backend API updated several pricing and product endpoints to standardize terminology and cost derivation:
1. `GET /api/v1/products` renamed the catalog item cost field from `cogs` to `selling_price`, and expanded valid `kind` filter values to include `6` (Tambahan (paket)).
2. `POST /api/v1/sales/proposals/:id/pricing/preview` and pricing calculations renamed `total_cogs` to `total_cost`.
3. Pricing calculations, product mappings, and contract addendums now derive worker hourly rates, transport unit costs, and add-on product costs directly from the product's `selling_price` rather than `cogs`.

The sales mobile app (`centrow-sales`) needs to update its DTOs, entities, and controllers to consume `selling_price` and `total_cost` seamlessly while maintaining backward compatibility with existing responses.

## What Changes

- **Product DTO & Entity**:
  - Update `ProductDto.fromJson` to parse `selling_price` as the primary field with fallback to `cogs` for backward compatibility.
  - Expose `sellingPrice` on `Product` (with `cogs` preserved as a getter for backward compatibility).
- **Pricing Preview DTO & Entity**:
  - Update `PricingPreviewDto.fromJson` to parse `total_cost` as the primary field with fallback to `total_cogs`.
  - Expose `totalCost` on `PricingPreview` (with `totalCogs` preserved as a getter for backward compatibility).
- **Pricing Calculator Controller**:
  - Update worker row creation (`PricingWorkerRow`) to initialize `hourlyRate` from `product.sellingPrice`.
  - Update item row creation (`PricingItemRow`) to initialize `unitPrice` and `unitCost` from `product.sellingPrice`.
- **Contract Addendum & Pricing Mappings**:
  - Ensure contract addendum pricing flows and item additions use product `sellingPrice`.
- **Tests**:
  - Add and update unit tests for `ProductDto`, `PricingPreviewDto`, and `PricingCalculatorController` verifying serialization and deserialization of `selling_price` and `total_cost`.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `pricing-offer-and-addons`: Update requirements to reflect `total_cost` in pricing preview responses, parse `selling_price` in the product catalogue, and resolve worker/item costs from product `selling_price`.

## Impact

- **Affected code**:
  - `lib/modules/sales/repositories/dtos/product_dto.dart`
  - `lib/modules/sales/entities/product.dart`
  - `lib/modules/sales/repositories/dtos/pricing_preview_dto.dart`
  - `lib/modules/sales/entities/pricing_preview.dart`
  - `lib/modules/sales/controllers/pricing_calculator_controller.dart`
  - Unit tests in `test/modules/sales/`
- **APIs**:
  - `GET /api/v1/products` (`selling_price`)
  - `POST /api/v1/sales/proposals/:id/pricing/preview` (`total_cost`)
  - `POST /api/v1/sales/proposals/:id/pricing` (`total_cost`)
  - `POST /api/v1/sales/contracts/:id/addendums`
- **Dependencies**: No new external dependencies required.

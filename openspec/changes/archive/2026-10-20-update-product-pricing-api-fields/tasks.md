## 1. Entities & DTOs

- [x] 1.1 Update `Product` entity in `lib/modules/sales/entities/product.dart` to add `sellingPrice` while retaining `cogs` getter for backward compatibility, and verify with `flutter analyze`.
- [x] 1.2 Update `ProductDto` in `lib/modules/sales/repositories/dtos/product_dto.dart` to parse `selling_price` with fallback to `cogs` and pass to `Product`, and verify DTO parsing.
- [x] 1.3 Update `PricingPreview` entity in `lib/modules/sales/entities/pricing_preview.dart` to add `totalCost` while retaining `totalCogs` getter for backward compatibility, and verify with `flutter analyze`.
- [x] 1.4 Update `PricingPreviewDto` in `lib/modules/sales/repositories/dtos/pricing_preview_dto.dart` to parse `total_cost` with fallback to `total_cogs` and pass to `PricingPreview`, and verify DTO parsing.

## 2. Controller & Calculation Integration

- [x] 2.1 Update `PricingCalculatorController.addRow` in `lib/modules/sales/controllers/pricing_calculator_controller.dart` to initialize worker `initialHourlyRate` and item `initialUnitPrice`/`initialUnitCost` from `product.sellingPrice`, and verify with controller tests.
- [x] 2.2 Verify and align `PricingPreviewPage` in `lib/modules/sales/views/pages/pricing_preview_page.dart` with `totalCost`, and verify widget tests pass.

## 3. Verification & Testing

- [x] 3.1 Add unit tests covering both `selling_price` and legacy `cogs` JSON payloads in `test/modules/sales/repositories/dtos/product_dto_test.dart` and verify tests pass.
- [x] 3.2 Add unit tests covering both `total_cost` and legacy `total_cogs` JSON payloads in `test/modules/sales/repositories/dtos/pricing_preview_dto_test.dart` and verify tests pass.
- [x] 3.3 Run full static analysis (`rtk flutter analyze`) and the test suite (`rtk flutter test`) to ensure zero warnings/errors and all tests pass.

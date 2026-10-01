## 1. Controller and State Updates

- [x] 1.1 Update `PricingItemRow` in `lib/modules/sales/controllers/pricing_calculator_controller.dart` to use `final Signal<String> title` instead of immutable `String`, supporting `kind == 0` with proper signal disposal, and verify row unit tests pass.
- [x] 1.2 Implement `addCustomItem({String defaultTitle, double initialPrice})` in `PricingCalculatorController` generating a unique client-side key, `kind == 0`, and verify via unit test.
- [x] 1.3 Update `buildRequest()` in `PricingCalculatorController` to serialize `kind == 0` rows as `item_type: 2` with `product_id: null` and `name: i.title.value`, and verify request serialization tests pass.
- [x] 1.4 Update `loadExistingPricing()` in `PricingCalculatorController` to restore items with null/empty `productId` as `kind == 0` editable rows, and verify unit test passes.
- [x] 1.5 Add validation in `validateInputs()` to ensure custom items do not have empty titles, and verify validation unit tests pass.

## 2. UI Implementation

- [x] 2.1 Add `buildAddBtn('Item Kustom', () => controller.addCustomItem())` button to the button row in `lib/modules/sales/views/widgets/pricing_calculator/pricing_item_tab.dart`.
- [x] 2.2 Update `PricingItemRowWidget` in `pricing_item_tab.dart` to render an inline `TextFormField` in the description column when `row.kind == 0`, updating `row.title.value`, while preserving the static title and badge for catalog items.
- [x] 2.3 Ensure price editing in `PricingItemRowWidget` is enabled for both `row.kind == 5` and `row.kind == 0` via `buildInput`.

## 3. Testing and Verification

- [x] 3.1 Add widget tests in `test/modules/sales/views/widgets/pricing_calculator_view_test.dart` verifying clicking "+ Item Kustom" adds an editable row, allows typing description and price, and can be removed.
- [x] 3.2 Run `flutter analyze` and `flutter test` to ensure static analysis is clean and all tests pass.

## Context

See `proposal.md` for motivation. Currently, `PricingItemRow` represents items in `items = ListSignal<PricingItemRow>([])` inside `PricingCalculatorController`. Rows are created through `controller.addRow(Product, expectedKind)` where `Product` comes from the remote catalog (`/v1/products`).

`PricingItemDto` in `pricing_dto.dart` already specifies `final String? productId;` and only includes `'product_id'` in JSON when non-null (`if (productId != null) 'product_id': productId`).

## Goals / Non-Goals

**Goals:**
- Provide a clear, intuitive way in `PricingItemTab` to add manual non-catalog item rows (`kind == 0`).
- Allow full inline editing of custom item title/name and unit price.
- Omit `product_id` (send `null`) and map to `item_type: 2` (Add-on revenue) upon calculation/submission.
- Restore saved custom items seamlessly when loading existing pricing.

**Non-Goals:**
- Custom items for chemical supplies or tools (`kind == 1` or `kind == 2`), which still strictly require product catalog / mapping definitions.
- Persisting newly created custom items into the central master product catalog table `/v1/products`.

## Decisions

### Decision 1: Make `title` reactive in `PricingItemRow`
- **Choice**: Change `final String title` or provide `final Signal<String> title` in `PricingItemRow` so that changes to custom item names are reactive and captured on submit.
- **Alternatives considered**:
  - Keep `title` immutable and use dialog prompts before insertion: Clunky UX; inline editing directly in the table matches other row inputs (CounterInput, price input).

### Decision 2: Unique client-side ID generation for `kind == 0`
- **Choice**: Generate a temporary unique ID (e.g. `'custom_${DateTime.now().microsecondsSinceEpoch}'`) when adding a custom item.
- **Rationale**: `PricingItemRowWidget` uses `key: ObjectKey(row)`, but having a unique `id` prevents collisions in Flutter widget trees and `items.remove(row)`.
- **Serialization Handling**: When `kind == 0`, `buildRequest()` explicitly ignores this client-side `id` and passes `productId: null`.

### Decision 3: Explicit Controller method `addCustomItem()`
- **Choice**: Add `void addCustomItem({String defaultTitle = 'Item Kustom', double initialPrice = 0.0})` to `PricingCalculatorController`.
- **Alternatives considered**:
  - Overload `addRow(Product, 0)`: Creating a dummy `Product` object with fake UOM and empty codes causes messy boilerplate and type violations. A dedicated `addCustomItem()` method is cleaner and inward-pointing.

### Decision 4: UI Button and Inline Row Layout
- **Choice**:
  - In `PricingItemTab`, add a third button `buildAddBtn('Item Kustom', () => controller.addCustomItem())` next to `BBM` and `Add-on`.
  - In `PricingItemRowWidget`, if `row.kind == 0`, render a `TextFormField` in the description column (with border and padding matching the app theme) instead of a static `Text(row.title)`.
  - The price column for `kind == 0` uses the same editable `buildInput(...)` as Add-on rows (`kind == 5`).

## Risks / Trade-offs

- **[Empty custom item title]** → Validation in `validateInputs()` should ensure that if custom items exist, their `title` is not empty, preventing submission of blank lines.
- **[Zero price on custom items]** → Sales reps might leave price at 0; however, zero-priced complimentary custom add-ons may be valid in some sales contracts. Keep price validation aligned with standard add-on behavior.

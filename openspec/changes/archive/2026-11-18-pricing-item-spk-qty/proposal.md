## Why

Three problems on the Transport & Add-on tab and the edit flow of the pricing calculator:

1. **Wording differs from the web.** The web product category form names the kinds "Bahan Bakar", "Add On" and "Add On (Paket)". This app labels the same buttons "BBM", "Add-on" and "Paket Add-on", so sales staff and back-office staff use different words for the same thing.
2. **No SPK quantity.** Chemical lines already have "Dosis SPK". Transport & Add-on lines have only the priced quantity, but the SPK needs the quantity that is actually delivered. The backend change `pricing-item-spk-qty` in `centrow` adds `actual_qty` to every item line.
3. **Edit screen bugs.** When an existing pricing is opened for editing:
   - Supply lines whose treatment method is already chosen show "+ Pilih Metode (Wajib)", because the badge appears only when the method *name* is known and the old response gave only the id. The backend change now returns `treatment_method {id, code, name}`, and the app must also stay correct when only the id is present.
   - Every saved add-on is restored as "Add-on", so an "Add On (Paket)" line becomes a plain add-on and its price field changes behavior. The backend change now returns `addon_kind`.

## What Changes

- Buttons on the Transport & Add-on tab become "Bahan Bakar", "Add On" and "Add On (Paket)". "Item Kustom" stays. The product picker titles for these kinds use the same names ("Pilih Bahan Bakar", "Pilih Add On", "Pilih Add On (Paket)"). The tab title "Transport & Add-on" stays.
- Each row on that tab gets a "Jumlah SPK" counter between "Jumlah" and "Frekuensi". It starts at the row's quantity, must be at least 1, is sent as `actual_qty`, is restored on edit, and never changes any price shown in the app.
- On edit, the treatment method badge is shown whenever the line has a method id: the label is the method name, else its code, else "Metode terpilih". "+ Pilih Metode (Wajib)" shows only when no method id is set.
- On edit, an add-on line is restored with the kind the server stored (`addon_kind`: 5 or 6), falling back to plain add-on for a product line when the server does not send it. Lines without a product stay custom items.
- No new API usage. The app only reads and writes new fields on the existing pricing endpoints.
- **Depends on** the `centrow` change `pricing-item-spk-qty`. Without it the app keeps working (the extra request field is ignored, the new response fields are absent), but "Jumlah SPK" is not saved and a package line is still restored as a plain add-on.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `pricing-offer-and-addons`: kind names on the buttons and pickers, the SPK quantity on item rows, and the restoration of the add-on kind on edit.
- `pricing-supply-methods-and-visits`: the treatment method of a supply line is shown correctly on edit.

## Impact

- Changed:
  - `lib/modules/sales/views/widgets/pricing_calculator/pricing_item_tab.dart` (labels, "Jumlah SPK" column)
  - `lib/modules/sales/views/widgets/pricing_calculator/pricing_material_tab.dart` (method badge on id)
  - `lib/modules/sales/views/widgets/product_picker_sheet.dart` (titles)
  - `lib/modules/sales/controllers/pricing_calculator_controller.dart` (`PricingItemRow`, request building, `loadExistingPricing`, validation)
  - `lib/modules/sales/repositories/dtos/pricing_dto.dart`, `pricing_detail_dto.dart`
  - `lib/modules/sales/entities/pricing_detail.dart`
- Tests: `test/modules/sales/controllers/pricing_calculator_controller_test.dart`, `test/modules/sales/views/widgets/pricing_calculator_view_test.dart`, and the DTO tests for pricing.
- Not changed: the preview page labels ("BBM / Transport", "Biaya Add-on"), which are summary rows rather than category names.
- Release: ship after the backend change is deployed. No forced update is needed.

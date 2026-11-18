## 1. Data layer

- [x] 1.1 `lib/modules/sales/repositories/dtos/pricing_detail_dto.dart`, `lib/modules/sales/entities/pricing_detail.dart`: add `actualQty` (nullable) and `addonKind` (int, default 0) to `PricingDetailItemDto` and `PricingDetailItem`, parsed from `actual_qty` and `addon_kind`. In the same dto, keep reading `treatment_method {id, code, name}` for supplies and make sure an id-only response still yields the id. Add cases to the pricing detail DTO test for both fields present and absent. Verify with `rtk flutter test test/modules/sales/repositories/`.
- [x] 1.2 `lib/modules/sales/repositories/dtos/pricing_dto.dart`: add `actualQty` to `PricingItemDto` and send it as `actual_qty`. Add a case to the DTO test. Verify with `rtk flutter test test/modules/sales/repositories/`.

## 2. Controller

- [x] 2.1 `lib/modules/sales/controllers/pricing_calculator_controller.dart`:
  - Add a `spkQty` signal to `PricingItemRow` (initial value = `initialQty` unless `initialSpkQty` is given; dispose it).
  - Pass it as `actualQty` in `buildRequest()` for every item.
  - Add an item check that rejects an SPK quantity below 1.
  - In `loadExistingPricing`, restore `spkQty` from `actualQty` (fallback `qty`), and restore the add-on kind from `addonKind` (design rule in the spec: 5 or 6, product line without it becomes 5, no product stays custom, `item_type` 1 stays 3).
  - Make the method check treat any non-empty method id as chosen, which it already does; keep it unchanged.

  Update `test/modules/sales/controllers/pricing_calculator_controller_test.dart` with cases for the request payload, restore of kind 6, restore without `addon_kind`, and `spkQty` fallback. Verify with `rtk flutter test test/modules/sales/controllers/`.

## 3. Views

Tasks 3.1, 3.2 and 3.3 touch disjoint files and are parallelizable. 3.1 depends on 2.1.

- [x] 3.1 `lib/modules/sales/views/widgets/pricing_calculator/pricing_item_tab.dart`: rename the buttons to "Bahan Bakar", "Add On", "Add On (Paket)"; add the "Jumlah SPK" header and a `CounterInput` (min 1, disabled when read-only) between "Jumlah" and "Frekuensi", and adjust `flexes` so the row still fits on a tablet. Update `test/modules/sales/views/widgets/pricing_calculator_view_test.dart` (it currently asserts that `BBM` and `Add-on` are absent in read-only mode; assert the new names are absent, and that "Jumlah SPK" is shown). Verify with `rtk flutter test test/modules/sales/views/widgets/`.
- [x] 3.2 `lib/modules/sales/views/widgets/product_picker_sheet.dart`: titles for kinds 3, 5 and 6 become "Pilih Bahan Bakar", "Pilih Add On" and "Pilih Add On (Paket)". Add or extend a widget test for the titles. Verify with `rtk flutter test test/modules/sales/views/widgets/`.
- [x] 3.3 `lib/modules/sales/views/widgets/pricing_calculator/pricing_material_tab.dart`: show the method badge when the row has a method id (label: name, else code, else "Metode terpilih") in both places the badge appears (around lines 242 and 617), and "+ Pilih Metode (Wajib)" only when the id is empty. Add a widget test for a row restored with id only and with name. Verify with `rtk flutter test test/modules/sales/views/widgets/`.

## 4. Full check

- [x] 4.1 Run `rtk flutter analyze && rtk flutter test` and confirm both pass. Confirm that `rtk grep -rn "'BBM'\|'Add-on'\|'Paket Add-on'" lib/modules/sales/views/widgets` returns nothing.

## 5. Release

- [ ] 5.1 (manual) Against a backend with the `centrow` change `pricing-item-spk-qty` deployed: add a Bahan Bakar, an Add On and an Add On (Paket) line, set a "Jumlah SPK" different from "Jumlah", save, reopen for edit and confirm the SPK values, the package kind and the treatment method badges are all restored.
- [ ] 5.2 (manual) Release after the backend deploy. No forced update is needed.

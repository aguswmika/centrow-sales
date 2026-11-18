## ADDED Requirements

### Requirement: Item kinds are named like the web product categories
The system SHALL name the add buttons of the Transport & Add-on tab "Bahan Bakar" (fuel), "Add On" and "Add On (Paket)", and the titles of their product pickers "Pilih Bahan Bakar", "Pilih Add On" and "Pilih Add On (Paket)", matching the names of the product category kinds on the web. The custom item button SHALL stay "Item Kustom" and the tab title SHALL stay "Transport & Add-on".

#### Scenario: Buttons on an editable pricing
- **WHEN** a sales user opens the Transport & Add-on tab of an editable pricing
- **THEN** the buttons are "Bahan Bakar", "Add On", "Add On (Paket)" and "Item Kustom"

#### Scenario: Picker title
- **WHEN** the user taps "Add On (Paket)"
- **THEN** the product picker opens with the title "Pilih Add On (Paket)"

### Requirement: Item rows carry a Jumlah SPK
The system SHALL show a "Jumlah SPK" counter on every row of the Transport & Add-on tab, between "Jumlah" and "Frekuensi", for catalog rows and custom items alike. A new row SHALL start with the same value as its "Jumlah". The counter SHALL NOT go below 1, and SHALL be read-only when the pricing is read-only. The system SHALL send the value as `actual_qty` of the item in the pricing request. Changing "Jumlah SPK" SHALL NOT change any price, total or preview value shown in the app.

#### Scenario: New row
- **WHEN** the user adds an Add On product to the tab
- **THEN** the row shows "Jumlah" 1 and "Jumlah SPK" 1

#### Scenario: SPK quantity differs from the priced quantity
- **WHEN** the user sets "Jumlah" 1 and "Jumlah SPK" 3 and saves the pricing
- **THEN** the request carries `qty` 1 and `actual_qty` 3 for that item

#### Scenario: Restored on edit
- **WHEN** the user opens an existing pricing whose item has `qty` 1 and `actual_qty` 3
- **THEN** the row shows "Jumlah" 1 and "Jumlah SPK" 3

#### Scenario: Old pricing without the field
- **WHEN** the user opens an existing pricing whose item has no `actual_qty`
- **THEN** the row shows "Jumlah SPK" equal to its "Jumlah"

#### Scenario: Read-only pricing
- **WHEN** the user views a pricing that is read-only
- **THEN** the "Jumlah SPK" counters are shown but cannot be changed

### Requirement: Add-on kind is restored on edit
The system SHALL restore each add-on item of an existing pricing with the kind the server returns in `addon_kind` (5 for "Add On", 6 for "Add On (Paket)"). When the item has a product but the server returns no `addon_kind` or 0, the system SHALL restore it as "Add On" (5). An add-on item without a product SHALL be restored as a custom item. A restored package row SHALL behave like a newly added package row, including how its price field is shown.

#### Scenario: Package line restored
- **WHEN** the user opens an existing pricing with an add-on item that has a product and `addon_kind` 6
- **THEN** the row behaves as an "Add On (Paket)" row and is sent back as a package line when saved

#### Scenario: Server without addon_kind
- **WHEN** the user opens an existing pricing with an add-on item that has a product and no `addon_kind`
- **THEN** the row is restored as an "Add On" row

#### Scenario: Transport line
- **WHEN** the user opens an existing pricing with an item whose `item_type` is 1
- **THEN** the row is restored as a "Bahan Bakar" row

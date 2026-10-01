## Purpose

Enables sales representatives to add, configure, and submit custom or non-catalog items with editable descriptions and prices in the Transport & Add-on pricing tab.

## ADDED Requirements

### Requirement: Add Custom Item Action
The system SHALL provide an action to add custom/manual pricing items without selecting from the product catalog in the Transport & Add-on tab.

#### Scenario: User clicks add custom item button
- **WHEN** user is on the "Transport & Add-on" tab of the pricing calculator and clicks "+ Item Kustom" (or "+ Manual")
- **THEN** system appends a new pricing item row marked as custom (`kind == 0`) with no master product ID

### Requirement: Inline Editable Fields for Custom Items
The system SHALL display an editable text input for the item description/name and an editable number input for unit price on all custom items (`kind == 0`).

#### Scenario: User edits custom item name and price
- **WHEN** user enters a custom description into the item name text field and a price into the unit price field
- **THEN** system updates the custom item row's title and unit price accordingly in real time

#### Scenario: User edits custom item quantity and frequency
- **WHEN** user increments or decrements quantity or frequency using the counter inputs on a custom item row
- **THEN** system updates the item row's quantity and frequency values

### Requirement: Custom Item Serialization and Submission
The system SHALL serialize custom items (`kind == 0`) as `item_type: 2` (Add-on) with `product_id: null` in the pricing calculation request payload.

#### Scenario: Pricing calculation payload generation
- **WHEN** pricing calculation preview or submission request is built
- **THEN** system includes custom items with `item_type: 2`, user-entered `name`, `qty`, `frequency`, `unit_price`, and excludes `product_id`

### Requirement: Existing Pricing Restoration
The system SHALL correctly restore saved custom items when loading existing pricing details.

#### Scenario: Existing pricing contains item without product_id
- **WHEN** `loadExistingPricing` receives an item with null or empty `product_id` and `item_type == 2`
- **THEN** system restores the row as a custom item (`kind == 0`) preserving its name, quantity, frequency, and price with editable fields

## MODIFIED Requirements

### Requirement: Inline Editable Fields for Custom Items
The system SHALL display editable text inputs for the item description/name, unit price, and an optional unit cost on all custom items (`kind == 0`).

#### Scenario: User edits custom item name and price
- **WHEN** user enters a custom description into the item name text field and a price into the unit price field
- **THEN** system updates the custom item row's title and unit price accordingly in real time

#### Scenario: User edits custom item unit cost
- **WHEN** user enters a manual unit cost into the optional cost field on a custom item row
- **THEN** system updates the custom item row's unit cost value ensuring non-negative values

#### Scenario: User edits custom item quantity and frequency
- **WHEN** user increments or decrements quantity or frequency using the counter inputs on a custom item row
- **THEN** system updates the item row's quantity and frequency values

### Requirement: Custom Item Serialization and Submission
The system SHALL serialize custom items (`kind == 0`) as `item_type: 2` (Add-on) with `product_id: null` and optional `unit_cost` in the pricing calculation request payload.

#### Scenario: Pricing calculation payload generation
- **WHEN** pricing calculation preview or submission request is built
- **THEN** system includes custom items with `item_type: 2`, user-entered `name`, `qty`, `frequency`, `unit_price`, user-specified `unit_cost` (or omits if zero/unset), and excludes `product_id`

### Requirement: Existing Pricing Restoration
The system SHALL correctly restore saved custom items when loading existing pricing details, preserving name, quantity, frequency, unit price, and unit cost.

#### Scenario: Existing pricing contains item without product_id
- **WHEN** `loadExistingPricing` receives an item with null or empty `product_id` and `item_type == 2`
- **THEN** system restores the row as a custom item (`kind == 0`) preserving its name, quantity, frequency, unit price, and unit cost with editable fields

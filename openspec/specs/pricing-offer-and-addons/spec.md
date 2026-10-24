## Purpose

Provides an offer-based pricing interface ('Penawaran') supporting percentage and fixed offer models, nominal display under percentage mode, add-on package line items, and add-on cost breakdown in COGS.

## Requirements

### Requirement: Offer-Based Pricing Model Selection
The system SHALL present pricing settings using the terminology 'Penawaran' rather than 'Markup', allowing users to select only between 'Persentase (%)' (`markup_type: 1`) and 'Nilai Tetap (Rp)' (`markup_type: 3`), defaulting to 'Nilai Tetap (Rp)' (`markup_type: 3`), and SHALL reject or exclude legacy nominal markup (`markup_type: 2`).

#### Scenario: Default offer model
- **WHEN** user initializes or creates a new pricing calculation
- **THEN** system defaults to 'Nilai Tetap (Rp)' (`markup_type: 3`)

#### Scenario: User chooses Persentase mode
- **WHEN** user selects 'Persentase (%)' in the offer model dropdown
- **THEN** system serializes `markup_type: 1` with the entered percentage value in `markup_value`

#### Scenario: User chooses Nilai Tetap mode
- **WHEN** user selects 'Nilai Tetap (Rp)' in the offer model dropdown
- **THEN** system serializes `markup_type: 3` with the entered currency amount in `markup_value`

### Requirement: Nominal Display in Percentage Mode
The system SHALL display the calculated nominal monetary offer in Rupiah alongside or below the percentage input when Persentase mode is active.

#### Scenario: User enters percentage and views nominal offer
- **WHEN** user configures an offer percentage and pricing preview is loaded or refreshed
- **THEN** system displays the resulting nominal offer before tax (`subtotal`) and total after tax (`total_amount`) in the settings card

### Requirement: Add-on Package Lines Support
The system SHALL support selecting and configuring Add-on Package products (`kind: 6`), calculating package selling line totals and cost totals as `(qty × unit_price) / frequency` and `(qty × unit_cost) / frequency`.

#### Scenario: User adds and edits an add-on package item
- **WHEN** user selects a product categorized as Tambahan (paket) (`kind: 6`)
- **THEN** system adds the item with item_type 2 and evaluates its line total divided by the frequency

### Requirement: Add-on Cost in COGS and Preview Breakdown
The system SHALL parse `addon_cost` and `total_cost` from pricing preview and detail responses, including `addon_cost` in the breakdown and reflecting `total_cost` (with fallback to `total_cogs` for backward compatibility) in the cost breakdown rollup display.

#### Scenario: Preview response contains addon_cost
- **WHEN** pricing preview API response is received with `addon_cost`
- **THEN** system displays 'Biaya Add-on' in the cost breakdown section and includes it in the total cost rollup (`total_cost` or `total_cogs`)

#### Scenario: Preview response contains total_cost
- **WHEN** pricing preview API response is received with `total_cost`
- **THEN** system populates the total cost rollup from `total_cost`

#### Scenario: Preview response uses legacy total_cogs field
- **WHEN** pricing preview API response is received with `total_cogs` instead of `total_cost`
- **THEN** system falls back to `total_cogs` and populates the total cost rollup without failing

### Requirement: Product Catalogue Selling Price Parsing and Cost Derivation
The system SHALL parse `selling_price` from the products catalogue endpoint (`GET /api/v1/products`) with fallback to `cogs`, support `kind: 6` (Tambahan (paket)) classification, and use the product's selling price to initialize worker hourly rates, transport unit costs, and add-on unit costs.

#### Scenario: Product parsed with selling_price
- **WHEN** product catalogue endpoint returns products with `selling_price`
- **THEN** system parses `selling_price` into the product entity's selling price

#### Scenario: Product parsed with legacy cogs field
- **WHEN** product catalogue endpoint returns a product with legacy `cogs` instead of `selling_price`
- **THEN** system falls back to `cogs` to populate the product's selling price

#### Scenario: Adding worker or add-on item from product catalogue
- **WHEN** user selects a product for a worker or add-on/transport item
- **THEN** system initializes the row's hourly rate or unit cost from the product's selling price

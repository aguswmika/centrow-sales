## MODIFIED Requirements

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

## ADDED Requirements

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

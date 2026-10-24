## Context

See [proposal.md](proposal.md) for motivation. The Centrow backend transitioned product cost and pricing rollup nomenclature:
- Products catalog JSON uses `selling_price` instead of `cogs`.
- Pricing preview and calculation endpoints return `total_cost` instead of `total_cogs`.
- Worker hourly rates and add-on unit costs are derived from the product's selling price.

## Goals / Non-Goals

**Goals:**
- Parse `selling_price` from `GET /api/v1/products` and expose it on `Product` entity.
- Parse `total_cost` from `POST /api/v1/sales/proposals/:id/pricing/preview` and expose it on `PricingPreview` entity.
- Maintain backward compatibility via getters (`cogs` on `Product`, `totalCogs` on `PricingPreview`) so existing UI and tests continue functioning without breaking changes.
- Ensure `PricingCalculatorController` initializes worker hourly rates and item unit costs/prices using `sellingPrice`.
- Support category kind `6` (Tambahan paket) seamlessly in product filtering.

**Non-Goals:**
- Redesigning the pricing preview UI layout or calculations.
- Modifying backend server logic or database schemas.
- Deprecating or removing existing UI display terminology unless necessary.

## Decisions

### Decision 1: Dual-property support on `Product` and `ProductDto`
- **Approach**: In `ProductDto.fromJson`, read `json['selling_price'] ?? json['sellingPrice'] ?? json['cogs']`. On `Product`, store `final double sellingPrice;` and provide `double get cogs => sellingPrice;`.
- **Rationale**: Keeps full backward compatibility with any callers still referring to `.cogs` while clearly communicating domain alignment with the backend `selling_price`.
- **Alternatives Considered**:
  - *Hard rename removing `cogs` entirely*: Would break multiple existing test cases and call sites across the sales module.
  - *Keep `cogs` as primary field name*: Does not reflect the actual backend API schema, creating confusion for future maintenance.

### Decision 2: Dual-property support on `PricingPreview` and `PricingPreviewDto`
- **Approach**: In `PricingPreviewDto.fromJson`, read `json['total_cost'] ?? json['totalCost'] ?? json['total_cogs'] ?? json['totalCogs']`. On `PricingPreview`, store `final double totalCost;` and provide `double get totalCogs => totalCost;`.
- **Rationale**: Server responses will send `total_cost`, but cached or mock responses might still have `total_cogs`. Backward-compatible fallback prevents parsing crashes.
- **Alternatives Considered**:
  - *Hard break on `total_cost` only*: Would fail if testing against older mock datasets or staging servers.

### Decision 3: Pricing controller row initialization
- **Approach**: Update `PricingCalculatorController.addRow` to use `product.sellingPrice` when setting `initialHourlyRate` for workers (kind 4) and `initialUnitPrice`/`initialUnitCost` for items (kind 3, 5, 6).
- **Rationale**: Aligns mobile calculation behavior with backend rules specified in `docs/api/pricings.md` and `contract-addendums.md`.

## Risks / Trade-offs

- **[Risk]** Staging backend might send `cogs` while production sends `selling_price` during rolling deployment.
  - → *Mitigation*: Fallback chain `json['selling_price'] ?? json['sellingPrice'] ?? json['cogs']` guarantees compatibility regardless of deployment order.
- **[Risk]** Test fixtures may contain older JSON payloads.
  - → *Mitigation*: Both keys are supported, and dedicated unit tests will be added to test both old and new payload formats.

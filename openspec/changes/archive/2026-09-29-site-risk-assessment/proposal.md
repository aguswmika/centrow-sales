# Proposal: Site Risk Assessment (SRA)

## Why

Sales representatives conducting site surveys need to assess and record potential environmental and safety hazards at customer service locations. Integrating the backend Site Risk Assessment (SRA) master and per-address risk APIs empowers sales reps to identify standard hazards from the tenant's master checklist, input custom hazards, and maintain accurate risk assessments directly within the mobile app.

## What Changes

- **Site Risk Master API Client**: Integrate `GET /api/v1/sales/site-risks` to fetch the tenant's active master checklist of hazards (`sales.site_risk.view`).
- **Customer Address Risk API Client**: Integrate `GET /api/v1/sales/customers/:id/addresses/:address_id/risks` to fetch recorded hazards for a given address (`sales.customer.risk.view`).
- **Customer Address Risk Management (Full Replace)**: Integrate `PUT /api/v1/sales/customers/:id/addresses/:address_id/risks` to replace the address's risk assessment with selected master risk IDs and custom risk descriptions (`sales.customer.risk.edit`).
- **Domain Entities & DTOs**: Create `SiteRiskMaster` and `CustomerAddressRisk` domain entities along with their serialization DTOs following clean layered architecture.
- **Repository & Controller**: Implement `SiteRiskRepository` (handling Dio, DTO mapping, and Failure handling) and `SiteRiskController` (managing signals for master hazards, address-specific risks, loading, and saving).
- **Location SRA UI Integration**: Expose an entry point in the customer location view (`CustomerLocationsTab` or customer location detail) to view recorded risks and launch an assessment modal/page where reps can toggle master hazards, add/remove custom hazards, and save changes.

## Capabilities

### New Capabilities
- `site-risk-assessment`: Covers loading the master hazard checklist, retrieving recorded risks for a customer address, editing risks (master selections and custom hazards) via full replacement, and presenting the risk assessment workflow in the mobile UI.

### Modified Capabilities
*(None)*

## Impact

- **Affected Code**:
  - `lib/modules/sales/entities/site_risk.dart`: Domain entities for master risk and address risk.
  - `lib/modules/sales/repositories/dtos/site_risk_dto.dart`: DTOs for API payloads and responses.
  - `lib/modules/sales/repositories/site_risk_repository.dart`: Interface and Dio implementation.
  - `lib/modules/sales/controllers/site_risk_controller.dart`: Signals state management for loading and saving risks.
  - `lib/modules/sales/views/widgets/customer_locations_tab.dart` & new SRA dialog/bottom sheet widget: UI for viewing and editing site risks per address.
  - `lib/app/di.dart`: Service registration for repository and controller.
- **APIs**:
  - `GET /api/v1/sales/site-risks`
  - `GET /api/v1/sales/customers/:id/addresses/:address_id/risks`
  - `PUT /api/v1/sales/customers/:id/addresses/:address_id/risks`
- **Dependencies**: No external dependencies added; uses existing Dio, Signals, and GetIt.

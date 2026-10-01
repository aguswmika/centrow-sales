# Technical Design: Site Risk Assessment (SRA)

## Context

See `proposal.md` for business motivation and problem description.

The mobile app currently displays customer service locations via `CustomerLocation` entities inside `CustomerLocationsTab`. Backend endpoints are implemented in the Centrow ERP core:
1. `GET /api/v1/sales/site-risks` returns tenant master checklist items.
2. `GET /api/v1/sales/customers/:id/addresses/:address_id/risks` returns recorded hazards for an address.
3. `PUT /api/v1/sales/customers/:id/addresses/:address_id/risks` performs a full replace of recorded hazards with `site_risk_ids` and `custom_risks`.

The client follows a strict layered architecture:
`View -> Controller (Signals) -> Repository (Dio) -> Entity`.

## Goals / Non-Goals

**Goals:**
- Provide domain entities, DTOs, and repository methods matching the API contracts defined in `site-risks.md` and `customer-address-risks.md`.
- Implement reactive state management using pure Dart Signals (`package:signals/signals.dart`) in a dedicated controller to load master risks, fetch address risks, manage user modifications (selection and custom hazard entries), and save changes via full replace.
- Integrate risk indicators and an intuitive assessment sheet/modal into the customer location UI, allowing sales reps to review and update risk assessments seamlessly.
- Preserve deleted master items that were previously recorded when the user retains them.
- Ensure exhaustive error handling via `Result<T>` and `UiState<T>`.

**Non-Goals:**
- Master item management (create/edit/delete master checklist items): Master items are configured in ERP web only.
- Standalone location creation inside this assessment workflow (locations must already exist).
- Offline queuing/sync of site risk assessments (future phase if needed).

## Decisions

### 1. Separate Domain Entities: `SiteRiskMaster` vs `CustomerAddressRisk`
- **Decision**: Define two distinct entities:
  - `SiteRiskMaster`: Contains `id` and `name` representing an item from the tenant's master checklist.
  - `CustomerAddressRisk`: Contains `id` (assessment entry UUID), `siteRiskId` (nullable UUID), `name` (string), and `isCustom` (bool).
- **Rationale**: The response shapes and semantics differ. Master items are templates; address risks represent concrete recorded assessments where `is_custom` identifies user-entered hazards and `site_risk_id` can be null.
- **Alternatives Considered**: Combining into a single polymorphic entity with nullable fields. Rejected to maintain strict immutability and domain clarity.

### 2. Repository Design: `SiteRiskRepository`
- **Decision**: Create a single repository interface `SiteRiskRepository` and implementation `SiteRiskRepositoryImpl` covering both master checklist and address-specific endpoints:
  - `getSiteRiskMasters()` -> `Future<Result<List<SiteRiskMaster>>>`
  - `getAddressRisks({required String customerId, required String addressId})` -> `Future<Result<List<CustomerAddressRisk>>>`
  - `updateAddressRisks({required String customerId, required String addressId, required List<String> siteRiskIds, required List<String> customRisks})` -> `Future<Result<List<CustomerAddressRisk>>>`
- **Rationale**: Both endpoints belong to the sales site risk domain and are consumed together during an assessment session.
- **Alternatives Considered**: Splitting into `SiteRiskMasterRepository` and `CustomerAddressRiskRepository`. Rejected as unnecessary overhead given the tight coupling of the workflows.

### 3. Controller Architecture: `SiteRiskController`
- **Decision**: Implement a factory-scoped `SiteRiskController` that:
  - Loads and caches `masterRisks` signal (`UiState<List<SiteRiskMaster>>`).
  - Loads `addressRisks` signal (`UiState<List<CustomerAddressRisk>>`) for a target `(customerId, addressId)`.
  - Exposes state signals for currently selected master risk IDs (`Set<String>`) and custom risk items (`List<String>`).
  - Supports mutations: `toggleMasterRisk(String id)`, `addCustomRisk(String name)`, `removeCustomRisk(int index)`.
  - Handles `saveRisks()` triggering the repository's `updateAddressRisks` with a loading state, updating the UI state with the result, and notifying the caller.
- **Rationale**: Isolates form state from UI widgets and provides reactive updates cleanly with Signals.

### 4. UI Presentation: Modal Bottom Sheet on `CustomerLocationsTab`
- **Decision**: In `CustomerLocationsTab`, render a risk summary/assessment chip on each location card (e.g., "Risiko Lokasi" with count or "Belum Dinilai"). Tapping opens a `SiteRiskAssessmentSheet` (modal bottom sheet or dialog) where reps review the master checklist, toggle checkboxes, enter custom items, and tap "Simpan".
- **Rationale**: Non-intrusive to existing location list layout while providing immediate accessibility to survey checklists.

## Risks / Trade-offs

- **[Risk] Master risk deleted after being recorded on address**: If an admin deletes a master item from ERP web, it won't appear in `GET /api/v1/sales/site-risks`, but `GET .../addresses/:id/risks` will still return it with `is_custom: false` and its old `site_risk_id`.
  - *Mitigation*: The controller merges previously recorded items: if an existing recorded address risk has a `site_risk_id` not in the active master list, display it in a "Previously Recorded / Retained" section with its checkbox checked. If retained, its ID is sent back in `site_risk_ids`.
- **[Risk] Full replace payload drops unselected items**: Omitting an item in `PUT` deletes it from the address.
  - *Mitigation*: The form controller initializes its checked set and custom list from the fetched address risks directly so no previously recorded item is lost unless explicitly unticked or removed by the user.
- **[Risk] Network timeout during assessment save**:
  - *Mitigation*: Preserve the dirty form state in the controller on error so the user does not lose typed custom hazards or selections, and show an error banner with a retry button.

## Migration Plan

- Backward-compatible addition to the sales module. No changes required to existing customer API endpoints or database migrations.
- Registered in `lib/app/di.dart` via `getIt.registerLazySingleton<SiteRiskRepository>` and `getIt.registerFactory<SiteRiskController>`.

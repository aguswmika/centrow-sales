## Context

The backend API contracts for customer management (`customers.md`), master site risks (`site-risks.md`), and customer address risks (`customer-address-risks.md`) now support recording Site Risk Assessment (SRA) atomically on the primary address (`locations[0].site_risk_ids` and `locations[0].custom_risks`) in both `POST /api/v1/sales/customers` and `PUT /api/v1/sales/customers/:id`.

In the current mobile implementation:
- `SiteRiskAssessmentSheet` is coupled directly to `SiteRiskController`, requiring existing `customerId` and `location.id` strings and immediately invoking `PUT .../addresses/:address_id/risks` on save. This prevents it from being used during new customer creation where IDs do not exist yet.
- `CreateLocationInput` and `CreateCustomerLocationRequestDto` do not include `siteRiskIds` or `customRisks`.
- `Step1IdentityForm` contains a label error ("Site Risk Assessment" applied to `risk_notes`) and lacks the informational `tax_percentage` field.
- `Step2LocationsForm` has no SRA trigger or checklist for the primary location.

## Goals / Non-Goals

**Goals:**
- Enable sales reps to assess physical site risks (master checklist items + manual hazards) directly on the primary location during customer creation and editing in Step 2.
- Atomically submit `locations[0].site_risk_ids` and `locations[0].custom_risks` in customer create and update requests.
- In customer edit mode, pre-populate recorded SRA for the primary address by querying `GET /api/v1/sales/customers/:id/addresses/:address_id/risks`.
- Clarify Step 1 form fields: rename `risk_notes` to "Catatan Risiko Internal" and add the informational `tax_percentage` input.
- Display customer base tax percentage on customer profile details.

**Non-Goals:**
- SRA on secondary locations (`locations[1..n]`) during customer creation/edit: the API contract strictly persists `locations[0]`. Secondary location SRA continues to be configured via customer detail after addresses are added.
- Managing master SRA items (tenant master items are managed exclusively via the web ERP).

## Decisions

### Decision 1: Model SRA in `CreateLocationInput`
Add `siteRiskIds` (`List<String>`) and `customRisks` (`List<String>`) to `CreateLocationInput`:
```dart
class CreateLocationInput {
  ...
  final List<String> siteRiskIds;
  final List<String> customRisks;

  const CreateLocationInput({
    ...
    this.siteRiskIds = const [],
    this.customRisks = const [],
  });
}
```
*Rationale*: Keeps location state immutable and cohesive. `CustomerFormController` methods like `updateLocation` continue to work without introducing side-channel signals.
*Alternatives considered*: Separate signals for SRA in `CustomerFormController`. Rejected to avoid disconnected state between locations and SRA.

### Decision 2: Decouple SRA Selection UI for Form Usage
Provide an SRA picker dialog or modal (`CustomerFormSiteRiskSheet` or configurable mode in `SiteRiskAssessmentSheet`) that:
- Receives initial `selectedRiskIds` and `customRisks`.
- Loads active master items from `SiteRiskRepository.getMasterRisks()`.
- Allows toggling master risks and adding/removing manual hazards.
- Returns `(List<String> siteRiskIds, List<String> customRisks)` to the caller via callback or `Navigator.pop(context, result)` without executing API write requests.
*Rationale*: During customer creation, no customer or address ID exists yet. Ticking risks must update local form state and persist atomically with customer registration.
*Alternatives considered*: Creating customer first and opening `SiteRiskAssessmentSheet` in an extra step. Rejected because the backend specifically added atomic SRA support to eliminate multi-step friction.

### Decision 3: Pre-population in Edit Mode
In `CustomerFormController.loadInitialData(String id)`:
When the customer detail is retrieved:
1. Identify the primary location (`locations.firstWhereOrNull((l) => l.isPrimary) ?? locations.firstOrNull`).
2. If `primaryLocation?.id` is not null, invoke `_siteRiskRepository.getAddressRisks(id, primaryLocation.id!)`.
3. If successful, map ticked items to `siteRiskIds` and custom items to `customRisks`, updating `locations.value[0]`.
*Rationale*: `GET /api/v1/sales/customers/:id` does not embed risks in the location objects. Fetching the primary address SRA via the existing repository ensures edit mode starts with accurate recorded state.
*Alternatives considered*: Only showing SRA in customer detail. Rejected because editing customer addresses should not overwrite or wipe existing SRA data when resubmitting `PUT /api/v1/sales/customers/:id`.

### Decision 4: Serialization and Client-Side Sanitization
In `CreateCustomerLocationRequestDto.fromInput`:
- Map `input.siteRiskIds` and `input.customRisks`.
- Trim each manual hazard string, discard empty/whitespace strings, and ensure hazards do not exceed 255 characters.
- In `toJson()`:
  ```dart
  if (siteRiskIds != null) map['site_risk_ids'] = siteRiskIds;
  if (customRisks != null) map['custom_risks'] = customRisks;
  ```
  Note: for the primary location, serialize both keys if modified/specified, so full replace semantics are respected.
*Rationale*: Conforms to `customer-address-risks.md` and `customers.md`, preventing 400 validation errors caused by whitespace or length violations.

### Decision 5: Step 1 Identity Form Field Corrections
- Relabel `risk_notes` input to "Catatan Risiko Internal" with hint "Catatan kredit, komplain sebelumnya, atau syarat termin khusus…".
- Add "Pajak Pertambahan Nilai (PPN)" input with hint "Contoh: 11" and percentage suffix, bound to `controller.taxPercentage`.

## Risks / Trade-offs

- **[Risk]** Master SRA items fail to load when opening SRA picker in customer form.
  → *Mitigation*: Show retry button in the picker while keeping already selected IDs and custom hazards intact.
- **[Risk]** Unintentional wiping of SRA on customer edit.
  → *Mitigation*: Only serialize `site_risk_ids` and `custom_risks` if the primary location's SRA was loaded or edited. If SRA was not loaded/altered, omit the keys so backend leaves the SRA untouched per contract.
- **[Risk]** Confusion on secondary location cards.
  → *Mitigation*: Display SRA card/trigger only on `locations[0]` (primary address) with explanatory subtitle that secondary locations can be assessed from customer detail.

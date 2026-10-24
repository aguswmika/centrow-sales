## REMOVED Requirements

### Requirement: Present site risk assessment on customer locations
**Reason**: Site Risk Assessment (SRA) management is handled during customer onboarding and edit workflows rather than being viewed or triggered ad-hoc from the customer detail locations tab.
**Migration**: View or edit primary location site risk assessment via customer edit (Step 2: Lokasi & Alamat).

### Requirement: Save customer address site risks with full replace
**Reason**: Direct standalone update of address site risks via `PUT /api/v1/sales/customers/:id/addresses/:address_id/risks` is removed with the removal of the customer detail SRA sheet.
**Migration**: Update site risks via the customer edit form (`PUT /api/v1/sales/customers/:id`).

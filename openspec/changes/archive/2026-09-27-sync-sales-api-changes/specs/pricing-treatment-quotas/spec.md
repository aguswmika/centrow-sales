## REMOVED Requirements

### Requirement: Configure treatment method quotas in pricing calculator
**Reason**: Backend dropped `sales_pricing_treatment_quotas` and the whole per-treatment-method quota engine from the API (Changelog 2026-09-24).
**Migration**: Remove the "Kuota Treatment" tab and quota rows from the pricing calculator view. Visit limits are managed via contract `total_visits` on pricing header.

### Requirement: Persist and reload treatment quotas on proposal pricing
**Reason**: `treatment_quotas` line array was removed from `POST`, `GET`, and preview pricing endpoints in the API.
**Migration**: Remove `treatment_quotas` from pricing request and response DTOs and pricing state deserialization.

### Requirement: Gating proposal send on required treatment method quotas
**Reason**: Backend removed the quota coverage precondition when transitioning proposals to `sent` status (Changelog 2026-09-24).
**Migration**: Allow sending draft proposals without verifying treatment method quotas.

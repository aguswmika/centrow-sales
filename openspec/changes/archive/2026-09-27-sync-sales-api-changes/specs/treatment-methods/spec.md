## ADDED Requirements

### Requirement: Parse and display active treatment methods
The system SHALL parse and display active treatment methods with their code and name in master data selection interfaces without mandatory requirement badges.

#### Scenario: Viewing active treatment methods in picker sheet
- **WHEN** user opens the treatment method picker sheet
- **THEN** the system displays each active treatment method with its code and name without any "Wajib" badge

## REMOVED Requirements

### Requirement: Identify mandatory treatment methods in master data
**Reason**: Backend removed `is_required` from `GET /api/v1/pc/treatment-methods` and dropped mandatory treatment method designations (Changelog 2026-09-24).
**Migration**: Remove `isRequired` property from `TreatmentMethod` entity and DTO.

### Requirement: Display mandatory status badge in treatment method picker
**Reason**: Mandatory status is no longer part of treatment method master data.
**Migration**: Remove the "Wajib" badge rendering from the treatment method picker bottom sheet.

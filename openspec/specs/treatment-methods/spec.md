## Purpose

Defines requirements for fetching master treatment methods with mandatory quota designations and surfacing requirement status in selection interfaces.

## Requirements

### Requirement: Identify mandatory treatment methods in master data
The system SHALL parse and retain the mandatory requirement status (`is_required`) for each treatment method received from the backend pest control master data API.

#### Scenario: Method is flagged as required
- **WHEN** the backend returns a treatment method item with `is_required: true`
- **THEN** the system sets `isRequired` to true on the domain model

#### Scenario: Method is not flagged as required or field is omitted
- **WHEN** the backend returns a treatment method item with `is_required: false` or omitted
- **THEN** the system defaults `isRequired` to false on the domain model

### Requirement: Display mandatory status badge in treatment method picker
The system SHALL visually identify mandatory treatment methods in the treatment method picker bottom sheet.

#### Scenario: Viewing treatment methods in picker sheet
- **WHEN** user opens the treatment method picker sheet during pricing material selection
- **THEN** methods with `isRequired: true` display a visible "Wajib" indicator badge alongside their code and description

#### Scenario: Optional treatment method in picker sheet
- **WHEN** a treatment method has `isRequired: false`
- **THEN** the method item is displayed without the "Wajib" badge

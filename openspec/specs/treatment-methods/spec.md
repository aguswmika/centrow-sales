## Purpose

Defines requirements for fetching master treatment methods with mandatory quota designations and surfacing requirement status in selection interfaces.

## Requirements

### Requirement: Parse and display active treatment methods
The system SHALL parse and display active treatment methods with their code and name in master data selection interfaces without mandatory requirement badges.

#### Scenario: Viewing active treatment methods in picker sheet
- **WHEN** user opens the treatment method picker sheet
- **THEN** the system displays each active treatment method with its code and name without any "Wajib" badge

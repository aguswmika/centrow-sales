## ADDED Requirements

### Requirement: Display contract total visits in contract detail
The system SHALL display the contract's total visit count in the contract detail pane under "TOTAL KUNJUNGAN" as a total count without cycle suffixes.

#### Scenario: Viewing contract total visits
- **WHEN** user views a contract detail pane for a contract with a populated `totalVisits`
- **THEN** the system displays the label "TOTAL KUNJUNGAN" with the formatted visit count (e.g. "12x")

## REMOVED Requirements

### Requirement: Display schedule cycle in contract detail visit frequency
**Reason**: Backend removed `schedule_cycle` from contracts and categories, replacing renewal cycles with direct contract total visits (Changelog 2026-09-24).
**Migration**: Display contract visits as "TOTAL KUNJUNGAN" without "(BULANAN)" or "(TAHUNAN)" indicators.

### Requirement: Display schedule cycle in contract category selection
**Reason**: Backend removed `schedule_cycle` from `ContractCategory` and its API responses.
**Migration**: Display category options with their name only, removing cycle suffixes and cycle helper explanations from contract form sheets.

## ADDED Requirements

### Requirement: Display schedule cycle in contract detail visit frequency
The system SHALL display the contract's schedule cycle in the visit frequency section of the contract detail pane to distinguish between monthly and yearly visit allowances.

#### Scenario: Contract has monthly schedule cycle
- **WHEN** user views the contract detail pane for a contract whose schedule cycle is Monthly (Bulanan) and has a populated `totalVisits`
- **THEN** the system displays the label "FREK. KUNJUNGAN (BULANAN)" with the formatted visit count (e.g. "4x / bulan" or "4x")

#### Scenario: Contract has yearly schedule cycle
- **WHEN** user views the contract detail pane for a contract whose schedule cycle is Yearly (Tahunan) and has a populated `totalVisits`
- **THEN** the system displays the label "FREK. KUNJUNGAN (TAHUNAN)" with the formatted visit count (e.g. "12x / tahun" or "12x")

#### Scenario: Contract has unknown or unspecified schedule cycle
- **WHEN** user views the contract detail pane for a contract where `scheduleCycle` is null or unspecified and has a populated `totalVisits`
- **THEN** the system falls back to displaying "TOTAL KUNJUNGAN" with the visit count (e.g. "12x")

### Requirement: Display schedule cycle in contract category selection
The system SHALL display the schedule cycle designation when presenting contract categories in the contract creation and editing form.

#### Scenario: Category list item shows schedule cycle
- **WHEN** user opens the contract category selector in the contract form bottom sheet
- **THEN** each category option clearly indicates its schedule cycle ("Bulanan" vs "Tahunan")

#### Scenario: Category selected in creation form updates contextual guidance
- **WHEN** user selects a category in the contract form bottom sheet
- **THEN** the helper text reflects whether the visit frequency inherited from proposal pricing represents a monthly recurring visit count or a full-term yearly visit count

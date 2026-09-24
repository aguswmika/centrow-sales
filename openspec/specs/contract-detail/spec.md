## Purpose

Defines requirements for viewing contract timeline, billing dates, and schedule cycle visit frequencies in the contract detail and form views, including optional first invoice scheduling and visit quota cycle designations.

## Requirements

### Requirement: Display first invoice date in contract detail
The system SHALL display the first invoice date in the contract detail pane when viewing a contract that has a first invoice date set.

#### Scenario: Contract has first invoice date
- **WHEN** user views a contract detail pane for a contract with a populated `firstInvoiceDate`
- **THEN** the system displays the "TANGGAL INVOICE PERTAMA" section with the formatted date value

#### Scenario: Contract does not have first invoice date
- **WHEN** user views a contract detail pane for a contract where `firstInvoiceDate` is null or empty
- **THEN** the system displays "-" or omits the value gracefully without visual layout defects

### Requirement: Clear optional first invoice date in contract form
The system SHALL allow users to clear or reset the optional first invoice date field when creating or editing a contract.

#### Scenario: User clears an existing or selected first invoice date
- **WHEN** user taps the clear button on the "Tanggal Invoice Pertama" field
- **THEN** the field is cleared and the underlying controller updates `firstInvoiceDate` to null or empty

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

### Requirement: Display contract addendum history in contract detail
The system SHALL display an addendum history section or tab within the contract detail pane when viewing an existing contract.

#### Scenario: Contract has addendum history
- **WHEN** user views the detail pane for a contract with recorded addendums
- **THEN** the system displays the addendum history list including the visit count deltas, date, reason, and resulting contract values

#### Scenario: Contract has no addendum history
- **WHEN** user views the detail pane for a contract with zero addendums
- **THEN** the addendum section displays an empty state or indicates that no addendums have been created

### Requirement: Provide addendum creation action for active contracts
The system SHALL provide an action in the contract detail pane to create an addendum whenever the selected contract is in active status.

#### Scenario: Active contract displays addendum action
- **WHEN** user views an active contract (`status == active`) in the detail pane
- **THEN** the system displays an action button or menu item to create an addendum

#### Scenario: Non-active contract hides or disables addendum action
- **WHEN** user views a contract in any status other than active (draft, suspended, terminated, cancelled, expired)
- **THEN** the system does not present the addendum creation action

#### Scenario: Addendum creation opens form sheet
- **WHEN** user clicks the create addendum action
- **THEN** the system opens the addendum bottom sheet preloaded with the contract's current visit count and value


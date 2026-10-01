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

### Requirement: Display contract total visits in contract detail
The system SHALL display the contract's total visit count in the contract detail pane under "TOTAL KUNJUNGAN" as a total count without cycle suffixes.

#### Scenario: Viewing contract total visits
- **WHEN** user views a contract detail pane for a contract with a populated `totalVisits`
- **THEN** the system displays the label "TOTAL KUNJUNGAN" with the formatted visit count (e.g. "12x")

### Requirement: Display contract addendum history in contract detail
The system SHALL display an addendum history section or tab within the contract detail pane when viewing an existing contract.

#### Scenario: Contract has addendum history
- **WHEN** user views the detail pane for a contract with recorded addendums
- **THEN** the system displays the addendum history list including the visit count deltas, date, reason, and resulting contract values

#### Scenario: Contract has no addendum history
- **WHEN** user views the detail pane for a contract with zero addendums
- **THEN** the addendum section displays an empty state or indicates that no addendums have been recorded

### Requirement: Provide addendum creation action for active contracts
The system SHALL provide an action in the contract detail pane to create an addendum whenever the selected contract is in active status, opening the addendum pricing workflow.

#### Scenario: Active contract displays addendum action
- **WHEN** user views an active contract (`status == active`) in the detail pane
- **THEN** the system displays an action button or menu item to create an addendum

#### Scenario: Non-active contract hides or disables addendum action
- **WHEN** user views a contract in any status other than active (draft, suspended, terminated, cancelled, expired)
- **THEN** the system does not present the addendum creation action

#### Scenario: Addendum creation opens form sheet
- **WHEN** user clicks the create addendum action
- **THEN** the system initiates the addendum pricing workflow preloaded with the contract's baseline pricing configuration

### Requirement: Automated contract end date upon proposal conversion
The system SHALL omit manual end date input when creating a contract from an accepted proposal, relying on server-side derivation from the proposal pricing duration (`contract_months`).

#### Scenario: Creating a contract from an accepted proposal
- **WHEN** user opens the contract creation form from an accepted proposal
- **THEN** the system does not present a manual editable end date field and displays helper information that end date is calculated automatically from the proposal pricing duration

#### Scenario: Submitting proposal conversion
- **WHEN** user submits the proposal conversion form with required fields (category, start date, signed date, payment type, notes, contract template)
- **THEN** the system dispatches the conversion request omitting `end_date` from the request payload

### Requirement: In-place draft contract editing
The system SHALL allow editing editable contract fields including optional end date for contracts in draft status, while permanently locking the contract template selection.

#### Scenario: Editing a draft contract
- **WHEN** user opens the edit form for a contract with `draft` status
- **THEN** the system presents an editable optional end date field and does not show the contract template selector

#### Scenario: Submitting draft contract updates
- **WHEN** user submits updates to a draft contract
- **THEN** the system dispatches the update request with `category_id`, `start_date`, `signed_date`, `payment_type_id`, `notes`, optional `end_date`, and optional `first_invoice_date`, and omits `contract_template_id` from the payload

### Requirement: Display schedule work order type in contract detail
The system SHALL parse and display the schedule work order type (`1` for Routine, `2` for Station) when viewing a contract's details in the sales app.

#### Scenario: Contract has Routine work order type
- **WHEN** user views a contract whose current pricing specifies Routine schedule work order type (`1`)
- **THEN** the contract detail pane displays the work order type badge or label as "Routine"

#### Scenario: Contract has Station work order type
- **WHEN** user views a contract whose current pricing specifies Station schedule work order type (`2`)
- **THEN** the contract detail pane displays the work order type badge or label as "Station"



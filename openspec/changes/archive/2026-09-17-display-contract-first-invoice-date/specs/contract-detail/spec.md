## Purpose

Defines requirements for viewing contract timeline and billing dates in the contract detail view, including optional first invoice scheduling and date-clearing controls.

## ADDED Requirements

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

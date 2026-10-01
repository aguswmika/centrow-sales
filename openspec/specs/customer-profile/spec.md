## Purpose

Manages customer profile settings including informational base tax rate and internal operational or credit risk notes across creation and update workflows.

## Requirements

### Requirement: Configure customer base tax percentage
The system SHALL support capturing and persisting a customer's base tax percentage (`tax_percentage`) as an informational numerical value during customer creation and profile updates.

#### Scenario: Specify custom base tax percentage during creation
- **WHEN** the sales rep inputs a tax percentage (e.g., 11) in the customer creation form and submits
- **THEN** the system serializes `tax_percentage` in the `POST /api/v1/sales/customers` payload and confirms successful creation

#### Scenario: Customer without tax percentage
- **WHEN** the sales rep leaves the tax percentage field empty or 0
- **THEN** the system treats the tax percentage as 0 or omits the key from the request payload without validation error

#### Scenario: Pre-populate tax percentage when editing customer
- **WHEN** the sales rep opens the edit form for a customer that has a recorded tax percentage
- **THEN** the system populates the tax percentage input field with the customer's recorded value

### Requirement: Record internal risk notes distinctly from location hazards
The system SHALL provide an internal risk notes field (`risk_notes`) within customer basic identity (Step 1) labeled "Catatan Risiko Internal" to capture internal credit, operational, or payment considerations distinct from physical site risk assessments.

#### Scenario: Enter internal risk notes in basic identity form
- **WHEN** the sales rep enters internal notes regarding customer credit or payment terms in Step 1
- **THEN** the system preserves this text under `risk_notes` and saves it with customer identity without conflating it with location site risks

#### Scenario: Display recorded risk notes on customer profile
- **WHEN** the sales rep views customer details or opens the customer edit form
- **THEN** the recorded `risk_notes` are displayed in the customer notes section and pre-filled in the Step 1 form

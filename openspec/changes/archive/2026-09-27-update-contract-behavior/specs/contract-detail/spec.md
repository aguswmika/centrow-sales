## ADDED Requirements

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

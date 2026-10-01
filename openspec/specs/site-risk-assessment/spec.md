## Purpose

Enables sales representatives to view and manage Site Risk Assessments (SRA) for customer service locations, integrating master hazard checklists and custom site hazards.

## Requirements

### Requirement: Fetch tenant master site risk items
The system SHALL retrieve all active master site risk assessment checklist items from `GET /api/v1/sales/site-risks` ordered by creation time ascending.

#### Scenario: Successfully load master site risk items
- **WHEN** the sales rep opens the site risk assessment checklist or loads risk configurations
- **THEN** the system requests master risks from the server and provides the list of items containing their IDs and descriptions

#### Scenario: Empty master checklist
- **WHEN** the server returns an empty list of master risk items
- **THEN** the system handles the empty state gracefully without errors, allowing custom hazard entry

#### Scenario: Master checklist request fails
- **WHEN** the master risk request fails due to network outage or server error
- **THEN** the system exposes an error state and allows the rep to retry loading the master checklist

#### Scenario: Rep lacks permission to view master checklist
- **WHEN** the server responds with HTTP 403 Forbidden due to missing `sales.site_risk.view` permission
- **THEN** the system indicates permission failure and prevents checklist selection from stale or incomplete data

### Requirement: Fetch recorded site risks for a customer address
The system SHALL retrieve recorded site risk items for a customer's specific address from `GET /api/v1/sales/customers/:id/addresses/:address_id/risks`.

#### Scenario: Successfully retrieve recorded risks
- **WHEN** the sales rep views a customer address or opens its risk assessment panel
- **THEN** the system fetches and displays both ticked master risks and custom risk entries recorded for that address

#### Scenario: Address has no recorded risks
- **WHEN** an address has no prior site risk assessment recorded
- **THEN** the server returns an empty list (`[]`) and the system displays an unassessed/empty risk state without treating it as an error

#### Scenario: Address not found or deleted
- **WHEN** the server responds with HTTP 404 (address does not exist, belongs to another customer, or is deleted)
- **THEN** the system notifies the rep that the address was not found and cancels the assessment view

#### Scenario: Rep lacks permission to view address risks
- **WHEN** the server responds with HTTP 403 due to missing `sales.customer.risk.view` permission
- **THEN** the system displays a permission-denied error message

### Requirement: Save customer address site risks with full replace
The system SHALL save the complete site risk assessment for an address via `PUT /api/v1/sales/customers/:id/addresses/:address_id/risks`, replacing previous items with selected master risk IDs (`site_risk_ids`) and custom hazard strings (`custom_risks`).

#### Scenario: Successfully update address site risks
- **WHEN** the sales rep selects master hazards, enters custom hazards, and submits the assessment
- **THEN** the system sends the full replace payload to the server, updates local state with the returned list, and confirms successful save

#### Scenario: Clear all recorded site risks
- **WHEN** the sales rep unticks all master hazards, removes all custom hazards, and saves
- **THEN** the system sends empty arrays (`site_risk_ids: []`, `custom_risks: []`) and clears the address's recorded risks

#### Scenario: Retain previously recorded deleted master items
- **WHEN** an address previously had a master risk item that was subsequently deleted from the master list, and the rep leaves it selected
- **THEN** the system retains its `site_risk_id` in the submission, allowing the server to preserve the recorded item and name

#### Scenario: Client-side validation of custom risks
- **WHEN** the sales rep enters a custom hazard that is empty or whitespace-only
- **THEN** the system trims whitespace, rejects or ignores empty items, and validates that hazard names do not exceed 255 characters before submission

#### Scenario: Server rejects invalid input
- **WHEN** the server returns HTTP 400 due to validation failure
- **THEN** the system displays the server validation error message and keeps the editor open so the rep can make corrections

#### Scenario: Rep lacks permission to edit address risks
- **WHEN** the server returns HTTP 403 due to missing `sales.customer.risk.edit` permission
- **THEN** the system displays an unauthorized error message and prevents changes from being applied locally

### Requirement: Present site risk assessment on customer locations
The system SHALL display site risk status and indicators on customer service locations within the customer detail view, allowing reps to initiate assessment.

#### Scenario: View location risk indicator
- **WHEN** the rep views the customer locations list
- **THEN** each location displays an indicator or button reflecting its Site Risk Assessment status (e.g. number of identified risks or unassessed status)

#### Scenario: Launch site risk assessment editor
- **WHEN** the rep taps on the risk assessment action for an address
- **THEN** the system displays the assessment interface showing master checklist items pre-ticked according to recorded risks, alongside existing custom hazards and an input field to add new custom hazards

### Requirement: Capture site risk assessment during customer creation and update
The system SHALL serialize selected master site risk IDs (`site_risk_ids`) and manual hazard names (`custom_risks`) within the primary location (`locations[0]`) when creating a customer via `POST /api/v1/sales/customers` or updating a customer via `PUT /api/v1/sales/customers/:id`.

#### Scenario: Customer creation with selected site risks
- **WHEN** the sales rep selects master hazards and enters manual hazards for the primary address in Step 2 of the customer form and submits the creation request
- **THEN** the system serializes `locations[0].site_risk_ids` and `locations[0].custom_risks` in the request body, saving the SRA atomically with the customer and address

#### Scenario: Customer update modifying primary address site risks
- **WHEN** the sales rep alters the primary address site risks during customer edit and saves changes
- **THEN** the system sends the full replace arrays of `site_risk_ids` and `custom_risks` on `locations[0]` to `PUT /api/v1/sales/customers/:id`

#### Scenario: Client-side validation of customer form custom hazards
- **WHEN** the sales rep inputs a manual hazard on the customer form that is empty, contains only whitespace, or exceeds 255 characters
- **THEN** the system trims whitespace, filters out empty hazards, and displays a validation warning if a hazard exceeds 255 characters before submission

### Requirement: Pre-populate primary address site risk assessment on customer edit
When loading an existing customer for editing, the system SHALL fetch the recorded site risks for the primary address from `GET /api/v1/sales/customers/:id/addresses/:address_id/risks` and pre-populate the assessment state in Step 2.

#### Scenario: Existing customer with recorded primary address SRA
- **WHEN** the sales rep opens the edit form for a customer whose primary address has recorded hazards
- **THEN** the system loads the address risks and marks the corresponding master hazards as ticked and pre-fills recorded custom hazards

#### Scenario: Existing customer with unassessed primary address
- **WHEN** the primary address has no recorded SRA (`items: []`)
- **THEN** the system initializes an empty assessment state without treating it as an error

### Requirement: Present site risk assessment trigger in customer form step 2
The customer form Step 2 (Lokasi & Alamat) SHALL display a Site Risk Assessment control or summary chip on the primary location card (`locations[0]`), allowing the sales rep to view assessment summary and launch the assessment checklist.

#### Scenario: View SRA status on primary location card
- **WHEN** the sales rep reviews the primary location card in Step 2
- **THEN** the card displays an SRA badge or counter indicating the number of selected risks (or "Belum dinilai") and a button to edit the assessment

#### Scenario: Launch SRA checklist from primary location card
- **WHEN** the sales rep taps the SRA action button on the primary location card
- **THEN** the system opens the assessment picker displaying active master checklist items alongside custom hazard inputs

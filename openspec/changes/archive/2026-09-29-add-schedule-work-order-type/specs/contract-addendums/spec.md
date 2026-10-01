## ADDED Requirements

### Requirement: Configure schedule work order type on contract addendum
The system SHALL require and capture `schedule_work_order_type` (`1` for Routine, `2` for Station) when creating a contract addendum, sending it in the addendum pricing submission payload.

#### Scenario: User configures addendum with work order type
- **WHEN** user creates an addendum for an active contract and confirms or modifies the schedule work order type
- **THEN** the system includes `schedule_work_order_type` in the `POST /api/v1/sales/contracts/:id/addendums` request payload

#### Scenario: Addendum initializes work order type from contract or pricing
- **WHEN** user opens the contract addendum pricing workflow for an active contract
- **THEN** the system initializes `schedule_work_order_type` from the contract's current pricing configuration or contract detail, falling back to Routine (`1`) if unset

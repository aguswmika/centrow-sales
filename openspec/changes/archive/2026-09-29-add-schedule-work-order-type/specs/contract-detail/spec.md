## ADDED Requirements

### Requirement: Display schedule work order type in contract detail
The system SHALL parse and display the schedule work order type (`1` for Routine, `2` for Station) when viewing a contract's details in the sales app.

#### Scenario: Contract has Routine work order type
- **WHEN** user views a contract whose current pricing specifies Routine schedule work order type (`1`)
- **THEN** the contract detail pane displays the work order type badge or label as "Routine"

#### Scenario: Contract has Station work order type
- **WHEN** user views a contract whose current pricing specifies Station schedule work order type (`2`)
- **THEN** the contract detail pane displays the work order type badge or label as "Station"

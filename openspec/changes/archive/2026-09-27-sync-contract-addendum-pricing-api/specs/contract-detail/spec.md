## MODIFIED Requirements

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

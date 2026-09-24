## ADDED Requirements

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

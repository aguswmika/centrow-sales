## MODIFIED Requirements

### Requirement: List contract addendum history
The system SHALL retrieve and display the chronological history of addendums applied to a contract, including links to associated pricing snapshots and actions to access addendum documents.

#### Scenario: Contract has addenda history
- **WHEN** user views the addendum history of a contract that has past addendums
- **THEN** the system displays the list of addendum records showing visit delta, old and new total visits, old and new contract value, associated pricing ID, reason, creator, and submission timestamp, along with actions to view or create the addendum document and download the addendum PDF

#### Scenario: Contract has no addenda
- **WHEN** user views a contract with no addendums applied
- **THEN** the system displays an empty state indicating that no addendums have been recorded

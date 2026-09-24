## Purpose

Defines requirements for recording mid-term contract visit adjustments and retrieving contract addendum history records on active sales contracts.

## Requirements

### Requirement: Create contract addendum for active contract
The system SHALL allow authorized sales representatives to create a contract addendum for an active contract to adjust total visits and recompute contract value.

#### Scenario: Successfully submit contract addendum
- **WHEN** user submits a valid signed visit delta and optional reason for an active contract
- **THEN** the system applies the addendum, updates the contract's total visits and priced contract value, and refreshes the displayed contract details

#### Scenario: Attempt addendum on non-active contract
- **WHEN** user attempts to create an addendum for a contract whose status is not active (e.g. draft, suspended, cancelled, or terminated)
- **THEN** the system rejects the operation and displays an error indicating that addendums can only be applied to active contracts

### Requirement: Validate contract addendum input
The system SHALL validate addendum input to ensure the visit delta is non-zero, the resulting visit count is greater than zero, and the resulting count does not fall below already scheduled visits.

#### Scenario: Visit delta is zero
- **WHEN** user submits an addendum with a visit delta of zero
- **THEN** the system rejects the submission with a validation error indicating that visit change cannot be zero

#### Scenario: Resulting total visits zero or negative
- **WHEN** user submits an addendum where total visits plus visit delta is less than or equal to zero
- **THEN** the system rejects the submission with an error indicating that the new total visits must be greater than zero

#### Scenario: Resulting total visits below scheduled count
- **WHEN** user submits a negative visit delta that reduces total visits below the count of already scheduled visits
- **THEN** the system displays the server error explaining that the new total visit count cannot be less than the already scheduled visit count

#### Scenario: Concurrent addendum conflict (HTTP 409)
- **WHEN** an addendum request encounters a concurrent modification conflict (HTTP 409)
- **THEN** the system alerts the user that the contract was modified concurrently and prompts them to reload the contract before trying again

### Requirement: List contract addendum history
The system SHALL retrieve and display the chronological history of addendums applied to a contract.

#### Scenario: Contract has addenda history
- **WHEN** user views the addendum history of a contract that has past addendums
- **THEN** the system displays the list of addendum records showing visit delta, old and new total visits, old and new contract value, reason, creator, and submission timestamp

#### Scenario: Contract has no addenda
- **WHEN** user views a contract with no addendums applied
- **THEN** the system displays an empty state indicating that no addendums have been recorded

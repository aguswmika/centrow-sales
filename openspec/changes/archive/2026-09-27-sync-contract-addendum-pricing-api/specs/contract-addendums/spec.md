## MODIFIED Requirements

### Requirement: Create contract addendum for active contract
The system SHALL allow authorized sales representatives to create a contract addendum for an active contract by submitting a full pricing configuration and optional reason to recompute contract value and visit count.

#### Scenario: Successfully submit contract addendum
- **WHEN** user submits a valid pricing configuration (supplies, workers, items, duration, visits, markup, and taxes) with an optional reason for an active contract
- **THEN** the system applies the addendum, updates the contract's total visits and contract value, records the derived visit delta, and refreshes the displayed contract details and addendum history

#### Scenario: Attempt addendum on non-active contract
- **WHEN** user attempts to create an addendum for a contract whose status is not active (e.g. draft, suspended, cancelled, or terminated)
- **THEN** the system rejects the operation and displays an error indicating that addendums can only be applied to active contracts

### Requirement: Validate contract addendum input
The system SHALL validate addendum pricing input according to shared pricing upsert rules, ensuring total visits is strictly greater than zero and required line fields are valid, without enforcing visit delta non-zero or scheduled visit floor restrictions.

#### Scenario: Visit delta is zero
- **WHEN** an addendum submission produces no net change in total visits (`visit_delta == 0`)
- **THEN** the system accepts the submission as long as `total_visits > 0`, recalculating contract value and line items without rejecting zero delta

#### Scenario: Resulting total visits zero or negative
- **WHEN** user submits an addendum where total visits is less than or equal to zero
- **THEN** the system rejects the submission with a validation error indicating that the new total visits must be greater than zero

#### Scenario: Resulting total visits below scheduled count
- **WHEN** user submits an addendum where total visits reduces total visits below the count of already scheduled visits
- **THEN** the system accepts the submission and allows the reduction without raising a scheduled visit floor error

#### Scenario: Concurrent addendum conflict (HTTP 409)
- **WHEN** an addendum request encounters a concurrent modification conflict (HTTP 409)
- **THEN** the system alerts the user that the contract was modified concurrently and prompts them to reload the contract before trying again

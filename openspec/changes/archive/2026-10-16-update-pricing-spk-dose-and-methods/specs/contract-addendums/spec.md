## MODIFIED Requirements

### Requirement: Validate contract addendum input
The system SHALL validate addendum pricing input according to shared pricing upsert rules, ensuring total visits is strictly greater than zero, all supply lines have required treatment methods assigned, chemical supply lines have a positive SPK dose (`spk_dose_usage > 0`), and required line fields are valid, without enforcing visit delta non-zero or scheduled visit floor restrictions.

#### Scenario: Addendum requires treatment method on all supplies and SPK dose on chemicals
- **WHEN** user attempts to submit a contract addendum where any supply line lacks a treatment method or any chemical line has non-positive `spk_dose_usage`
- **THEN** the system blocks the submission and indicates which required supply field must be corrected

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

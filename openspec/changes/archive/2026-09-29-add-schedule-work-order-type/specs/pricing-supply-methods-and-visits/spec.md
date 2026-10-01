## ADDED Requirements

### Requirement: Configure schedule work order type on pricing calculation
The system SHALL require and capture `schedule_work_order_type` (`1` for Routine, `2` for Station) on proposal pricing calculations alongside duration in months, visit frequency, and total visits.

#### Scenario: User selects Routine or Station work order type
- **WHEN** user configures pricing and selects Routine (`1`) or Station (`2`) in the pricing parameter header
- **THEN** the system updates the pricing calculation state and includes `schedule_work_order_type` in the request payload for pricing preview and save

#### Scenario: Submitting pricing defaults to Routine when unset
- **WHEN** a new pricing calculation is initialized without an explicit work order type selection
- **THEN** the system defaults `schedule_work_order_type` to `1` (Routine)

#### Scenario: Loading existing pricing restores saved work order type
- **WHEN** user loads an existing proposal pricing calculation from the server
- **THEN** the system restores the saved `schedule_work_order_type` into the calculator state and UI selector

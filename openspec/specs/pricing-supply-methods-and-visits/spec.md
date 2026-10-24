## Purpose

Defines requirements for capturing total contract visit counts in pricing calculation headers and specifying treatment methods, work areas, notes, and tool installation units on supply lines.

## Requirements

### Requirement: Configure contract total visits on pricing calculation
The system SHALL require and capture a positive integer `total_visits` on proposal pricing calculations alongside duration in months and visit frequency.

#### Scenario: User configures positive total visits
- **WHEN** user inputs a positive integer value (e.g. 12) for Total Kunjungan in the pricing parameter bar
- **THEN** the system updates the pricing calculation state and sends `total_visits` in preview and save requests

#### Scenario: Submitting pricing with non-positive total visits
- **WHEN** user attempts to preview or save pricing while Total Kunjungan is empty, zero, or negative
- **THEN** the system blocks submission and indicates that Total Kunjungan must be greater than 0

### Requirement: Specify treatment method, work area, and notes on supply lines
The system SHALL require an active treatment method to be assigned on every supply line (both chemical and tool lines), and allow users to specify an optional work area (`area_kerja`) and notes.

#### Scenario: Chemical supply line with required method, area, and notes
- **WHEN** user configures a chemical supply line
- **THEN** the system requires an active treatment method to be associated with the line, and allows entering a free-text work area (e.g. "Dapur") and notes (e.g. "Fokus area lembab")

#### Scenario: Tool supply line with required method, area, and notes
- **WHEN** user configures a tool supply line
- **THEN** the system requires selecting an active treatment method from the picker before or upon adding the tool, and allows entering a work area and notes

#### Scenario: Missing treatment method blocks pricing submission
- **WHEN** user attempts to preview or save pricing or contract addendums while any chemical or tool supply line lacks an assigned treatment method
- **THEN** the system blocks submission and displays a validation error indicating that the treatment method is required for that supply line

### Requirement: Require and validate installed units on tool supply lines
The system SHALL require and validate a positive integer for `installed_units` on all tool supply lines (`supply_type: 2`), while excluding `installed_units` from chemical supply lines.

#### Scenario: Tool line has valid installed units
- **WHEN** user inputs a positive integer for installed units on a tool line
- **THEN** the system accepts the value and includes `installed_units` in the supply line payload for preview and save operations

#### Scenario: Tool line lacks valid installed units
- **WHEN** user leaves installed units empty or enters a value less than 1 on a tool supply line
- **THEN** the system blocks pricing preview and save, displaying an error that installed units must be filled with a value greater than 0

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

### Requirement: Configure and validate SPK dose usage on chemical supply lines
The system SHALL require and validate a positive number for `spk_dose_usage` (> 0) on all chemical supply lines (`supply_type: 1`), representing the actual dosage printed on the SPK document, while excluding `spk_dose_usage` from tool supply lines (`supply_type: 2`).

#### Scenario: Chemical line specifies valid SPK dose
- **WHEN** user inputs a positive number for SPK dose on a chemical supply line
- **THEN** the system accepts the value, shares the dose unit of measure (`dose_unit_id` / `uom_code`) with `dose_usage`, and transmits `spk_dose_usage` in pricing preview, save, and addendum payloads without altering calculated line costs or totals

#### Scenario: Initializing SPK dose defaults from dose usage
- **WHEN** user adds a new chemical supply line from a product mapping or loads an existing pricing line where `spk_dose_usage` is not explicitly set
- **THEN** the system initializes `spk_dose_usage` to the value of `dose_usage`

#### Scenario: Chemical line lacks valid SPK dose
- **WHEN** user enters zero, a negative number, or clears the SPK dose input on a chemical supply line
- **THEN** the system blocks pricing preview and save, displaying a validation error indicating that Dosis SPK must be greater than 0

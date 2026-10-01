## MODIFIED Requirements

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

## ADDED Requirements

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

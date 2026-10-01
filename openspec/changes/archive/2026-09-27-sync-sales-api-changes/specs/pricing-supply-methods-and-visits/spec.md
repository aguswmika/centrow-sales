## Purpose

Defines requirements for capturing total contract visit counts in pricing calculation headers and specifying treatment methods, work areas, notes, and tool installation units on supply lines.

## ADDED Requirements

### Requirement: Configure contract total visits on pricing calculation
The system SHALL require and capture a positive integer `total_visits` on proposal pricing calculations alongside duration in months and visit frequency.

#### Scenario: User configures positive total visits
- **WHEN** user inputs a positive integer value (e.g. 12) for Total Kunjungan in the pricing parameter bar
- **THEN** the system updates the pricing calculation state and sends `total_visits` in preview and save requests

#### Scenario: Submitting pricing with non-positive total visits
- **WHEN** user attempts to preview or save pricing while Total Kunjungan is empty, zero, or negative
- **THEN** the system blocks submission and indicates that Total Kunjungan must be greater than 0

### Requirement: Specify treatment method, work area, and notes on supply lines
The system SHALL allow users to optionally assign an active treatment method, specify a work area (`area_kerja`), and add notes on both chemical and tool supply lines.

#### Scenario: Chemical supply line with method, area, and notes
- **WHEN** user configures a chemical supply line
- **THEN** the user can associate an active treatment method, enter free-text work area (e.g. "Dapur"), and enter a note (e.g. "Fokus area lembab")

#### Scenario: Tool supply line with method, area, and notes
- **WHEN** user configures a tool supply line
- **THEN** the user can select an active treatment method from the picker, enter work area, and enter a note

### Requirement: Require and validate installed units on tool supply lines
The system SHALL require and validate a positive integer for `installed_units` on all tool supply lines (`supply_type: 2`), while excluding `installed_units` from chemical supply lines.

#### Scenario: Tool line has valid installed units
- **WHEN** user inputs a positive integer for installed units on a tool line
- **THEN** the system accepts the value and includes `installed_units` in the supply line payload for preview and save operations

#### Scenario: Tool line lacks valid installed units
- **WHEN** user leaves installed units empty or enters a value less than 1 on a tool supply line
- **THEN** the system blocks pricing preview and save, displaying an error that installed units must be filled with a value greater than 0

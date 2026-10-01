## Purpose

Provides seamless, resilient cascading selection and pre-population of Indonesian administrative regions (Provinsi, Kabupaten/Kota, Kecamatan, Kelurahan/Desa) across customer creation and edit workflows.

## Requirements

### Requirement: Pre-populate existing administrative regions on customer edit
When loading an existing customer record for editing, the system SHALL populate and select all previously saved administrative region tiers (Provinsi, Kabupaten/Kota, Kecamatan, and Kelurahan/Desa) in the location form.

#### Scenario: Customer with existing region IDs and names
- **WHEN** user opens the customer edit form for a customer with recorded province, regency, district, and village
- **THEN** all four dropdown selectors (Provinsi, Kabupaten/Kota, Kecamatan, Kelurahan/Desa) display their respective saved selections with corresponding available child options loaded

#### Scenario: Customer with legacy or missing region IDs
- **WHEN** user opens the customer edit form for a customer where only region names or partial IDs are available
- **THEN** the system resolves the missing IDs via region master data matching and automatically selects the corresponding options without clearing or blocking dependent tiers

### Requirement: Resilient region data parsing from customer API
The system SHALL reliably parse region references from customer location responses regardless of whether regions are returned as structured objects `{id, name}`, scalar strings, separate ID and name fields, or alias property names.

#### Scenario: Region returned as generic map object
- **WHEN** the customer location response contains `{id: 5171, name: "KOTA DENPASAR"}` or `{id: "5171", name: "KOTA DENPASAR"}`
- **THEN** the system extracts both the integer ID `5171` and the display name `"KOTA DENPASAR"`

#### Scenario: Region returned with alias keys
- **WHEN** the customer location response contains `city` or `city_id` instead of `regency` or `regency_id`
- **THEN** the system maps the value to the regency model fields

### Requirement: Normalized and tolerant region name matching
The system SHALL match region names case-insensitively while ignoring standard Indonesian administrative prefixes, punctuation, and colloquial suffixes.

#### Scenario: Name with administrative prefix variations
- **WHEN** matching a stored name "Denpasar" against API item "Kota Denpasar", or "Badung" against "Kab. Badung"
- **THEN** the system identifies them as matching regions and resolves the correct region ID

### Requirement: Smooth cascading dropdown interaction
Selecting or altering a parent administrative region SHALL reset and fetch the appropriate subordinate tiers while preventing inconsistent selection states.

#### Scenario: Changing province resets lower levels
- **WHEN** user selects a different province in the location form
- **THEN** regency options are fetched for that province, and previously selected regency, district, and village are reset

#### Scenario: Dependent dropdowns disabled only while parent is unselected or loading
- **WHEN** a valid province is selected and regencies are loaded
- **THEN** the Kabupaten/Kota dropdown is enabled for selection and displays "Pilih Kabupaten / Kota" rather than a disabled placeholder

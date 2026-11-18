## ADDED Requirements

### Requirement: Treatment method is shown on supply lines when editing
The system SHALL show the treatment method badge on a supply line whenever the line has a treatment method id, including when an existing pricing is opened for editing. The badge label SHALL be the method name; when the name is empty, the method code; when both are empty, "Metode terpilih". The system SHALL read the name and code from `treatment_method {id, code, name}` of the pricing detail response, and SHALL show "+ Pilih Metode (Wajib)" only when the line has no method id. A line with a method id SHALL pass the required-method validation without the user choosing again.

#### Scenario: Method restored on edit
- **WHEN** the user opens an existing pricing whose chemical line has `treatment_method` with code "CF" and name "Cold Fog"
- **THEN** the line shows the "Cold Fog" badge and not "+ Pilih Metode (Wajib)"

#### Scenario: Only the id is known
- **WHEN** the response has `treatment_method_id` for a line but no `treatment_method` object
- **THEN** the line shows the badge "Metode terpilih" and saving does not fail the required-method check

#### Scenario: No method
- **WHEN** a supply line has no treatment method id
- **THEN** the line shows "+ Pilih Metode (Wajib)" and the required-method validation fails on save

#### Scenario: Changing the method
- **WHEN** the user taps the badge of a restored line and picks another method
- **THEN** the badge shows the new method and the request carries the new method id

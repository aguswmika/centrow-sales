## Purpose

Defines requirements for configuring, saving, and verifying per-treatment-method visit quotas in proposal pricing and gating proposal send operations.

## ADDED Requirements

### Requirement: Configure treatment method quotas in pricing calculator
The system SHALL provide a dedicated treatment quotas interface within the pricing calculator allowing users to define visit quotas per treatment method.

#### Scenario: User adds a treatment method quota row
- **WHEN** user selects a treatment method in the "Kuota Treatment" tab and specifies a visit quota
- **THEN** the system adds the quota row to the pricing state and updates the tab item counter

#### Scenario: User pre-populates required treatment methods
- **WHEN** user initiates "Isi Metode Wajib" in the treatment quota tab
- **THEN** the system populates quota rows for all active treatment methods marked with `is_required: true` that do not yet have an entry

### Requirement: Persist and reload treatment quotas on proposal pricing
The system SHALL serialize treatment quotas in `POST /api/v1/sales/proposals/:id/pricing` and deserialize them when loading existing pricing.

#### Scenario: Submitting pricing with treatment quotas
- **WHEN** user saves or submits pricing with configured treatment quotas
- **THEN** the request payload includes `treatment_quotas` with the corresponding `treatment_method_id` and `quota` values

#### Scenario: Loading existing pricing with treatment quotas
- **WHEN** user opens pricing for a proposal that has previously saved treatment quotas
- **THEN** the system populates the "Kuota Treatment" tab with the saved quota rows and values

### Requirement: Gating proposal send on required treatment method quotas
The system SHALL verify that all active required treatment methods have quotas defined before allowing a proposal to transition to sent status.

#### Scenario: Attempting to send proposal missing required quota
- **WHEN** user attempts to send a proposal whose pricing lacks a quota entry for an active `is_required` treatment method
- **THEN** the system warns the user and displays an error message indicating that required treatment method quotas must be completed before sending

#### Scenario: Sending proposal with all required quotas satisfied
- **WHEN** user sends a proposal where every active `is_required` treatment method has a defined quota in its pricing
- **THEN** the system successfully dispatches the send request and transitions the proposal status to sent

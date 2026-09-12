# Feature Specification: Pricing Worker Duration in Minutes

**Feature Branch**: `001-pricing-worker-minutes`

**Created**: 2026-09-11

**Status**: Draft

**Input**: User description: "the api docs change, so we need to change the ui also /Users/agus/Project/centrow/docs/api/pricings.md"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Configure Technician Duration in Minutes (Priority: P1)

As a sales representative preparing a service proposal on the pricing calculator, I want to input technician initial and routine visit durations in minutes rather than hours, so that my inputs match the operational estimation standards and the underlying pricing calculation.

**Why this priority**: Directly impacts the core pricing workflow. Without aligning duration units to minutes, sales representatives could mistakenly input hours (e.g., entering "4" instead of "240"), resulting in severely underestimated labor costs and unprofitable service quotes.

**Independent Test**: Can be fully tested by opening the pricing calculator's technician section, observing that duration columns clearly indicate minutes ("Menit Awal" and "Menit Rutin"), entering duration values in minutes, and confirming the values are preserved accurately.

**Acceptance Scenarios**:

1. **Given** a sales representative is on the pricing calculator for a draft proposal, **When** they view the technician (Tenaga Kerja) tab, **Then** the table headers for duration display "Menit Awal" and "Menit Rutin".
2. **Given** a technician row is added to the calculator, **When** the representative enters the first visit duration as 180 and routine visit duration as 60, **Then** the inputs accept and display these minute values accurately.
3. **Given** a sales representative enters a negative value for either visit duration, **When** attempting to validate or preview, **Then** the system rejects the value with an error message indicating that work minutes cannot be negative ("Menit kerja tidak boleh negatif").

---

### User Story 2 - Calculate and Preview Quote with Minute Durations (Priority: P2)

As a sales representative, I want the quote preview and total pricing breakdown to accurately compute technician labor costs based on the specified minutes, so that the proposal total reflects correct labor expenditure.

**Why this priority**: Accurate pricing computation is essential for generating reliable customer proposals and maintaining business margins.

**Independent Test**: Can be tested by entering known minute durations for technicians with specified hourly rates, triggering a preview, and verifying that the calculated labor line totals and rollups match the expected hourly conversion (total minutes / 60 × hourly rate).

**Acceptance Scenarios**:

1. **Given** technician rows with valid minute durations, **When** the representative taps "Lihat Ringkasan" (Preview), **Then** the labor cost breakdown and proposal totals are computed accurately without error.
2. **Given** a proposal preview is displayed, **When** the user confirms and saves, **Then** the pricing with minute-based durations is saved successfully to the proposal.

---

### User Story 3 - Review and Revise Existing Pricing (Priority: P3)

As a sales representative reviewing or revising a draft proposal, I want existing technician pricing lines to display their duration in minutes, so that I can inspect or adjust technician time allocations consistently.

**Why this priority**: Ensures data consistency when reloading previously saved proposals or creating proposal revisions.

**Independent Test**: Can be tested by opening an existing proposal that already has saved pricing, navigating to the technician tab, and verifying that the loaded duration fields reflect the stored minutes.

**Acceptance Scenarios**:

1. **Given** a proposal with previously saved pricing, **When** the sales representative opens the pricing calculator, **Then** each technician line displays the saved initial visit minutes and routine visit minutes in their respective minute fields.
2. **Given** an existing pricing record, **When** the representative modifies the routine duration in minutes and re-saves, **Then** the updated duration is saved and reflected in the revised proposal total.

---

### Edge Cases

- **Zero duration**: First visit minutes or routine visit minutes set to 0 (e.g., when a technician only attends initial setup or only routine visits). The system must allow 0 minutes and calculate the cost accordingly.
- **Decimal / fractional minutes**: When a user inputs fractional minutes (e.g., 30.5), the system should handle or round according to standard numeric input rules without crashing.
- **Negative minutes**: Prevent negative durations both at the field entry/validation level and handle any server rejection ("Menit kerja tidak boleh negatif") with a user-friendly notification.
- **Read-only / locked state**: When viewing a sent or finalized proposal where pricing is locked, the minute fields must be presented as read-only while clearly conveying that values represent minutes.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The pricing calculator MUST present duration input fields and column headers for technicians labeled in minutes ("Menit Awal" and "Menit Rutin" instead of "Jam Awal" and "Jam Rutin").
- **FR-002**: The system MUST allow sales representatives to specify technician initial visit duration in minutes (`first_visit_minutes`) as a non-negative number.
- **FR-003**: The system MUST allow sales representatives to specify technician routine visit duration in minutes (`routine_minutes`) as a non-negative number.
- **FR-004**: The system MUST reject any negative values for technician work durations with a descriptive validation error ("Menit kerja tidak boleh negatif").
- **FR-005**: The system MUST transmit and retrieve technician work durations using the minute-based contract fields when previewing, saving, and loading pricing calculations.
- **FR-006**: When loading existing proposal pricing records, the system MUST correctly map stored technician duration values into the minute input fields.

### Key Entities

- **Proposal Pricing Worker Line**: Represents a technician role assigned to a service quote, containing position reference, visit frequency, initial visit duration in minutes (`first_visit_minutes`), routine visit duration in minutes (`routine_minutes`), hourly rate, and computed line total.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of duration fields and column headers in the technician pricing interface clearly indicate minutes ("Menit Awal" / "Menit Rutin").
- **SC-002**: Zero calculation discrepancies caused by unit confusion — labor costs reflect accurate minute-to-hour conversions for all generated proposals.
- **SC-003**: Sales representatives can input and review technician durations in minutes and obtain a price preview in under 3 seconds.
- **SC-004**: Form validation catches 100% of negative duration entries before or during preview submission.

## Assumptions

- Hourly billing rates for technician roles remain defined on an hourly basis; the system converts minute durations to hours internally (`minutes / 60`) for cost computation.
- Existing saved pricing records in the backend database have already been migrated to store minutes under the updated field names as noted in the API contract changelog.
- No other line item types (supplies/tools, transport, add-ons) are affected by this duration unit change.

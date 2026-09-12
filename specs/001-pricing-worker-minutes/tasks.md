# Tasks: Pricing Worker Duration in Minutes

**Feature**: Pricing Worker Duration in Minutes  
**Branch**: `001-pricing-worker-minutes`  
**Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Baseline verification of project setup and environment

- [X] T001 Verify Flutter dependencies and baseline test suite pass cleanly via `rtk flutter test`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core entity, DTO, and serialization updates required across all user stories

**⚠️ CRITICAL**: Must complete before user story implementation begins

- [X] T002 [P] Update `PricingDetailWorker` entity in `lib/modules/sales/entities/pricing_detail.dart` replacing `firstVisitHours` and `routineHours` with `firstVisitMinutes: double (>= 0)` and `routineMinutes: double (>= 0)`
- [X] T003 [P] Update `PricingWorkerDto` in `lib/modules/sales/repositories/dtos/pricing_dto.dart` replacing hour fields with `firstVisitMinutes` and `routineMinutes`, serializing to JSON keys `'first_visit_minutes': number (>= 0)` and `'routine_minutes': number (>= 0)`
- [X] T004 [P] Update `PricingDetailWorkerDto` in `lib/modules/sales/repositories/dtos/pricing_detail_dto.dart` to deserialize `'first_visit_minutes'` and `'routine_minutes'` (with fallback to legacy keys) into `PricingDetailWorker`
- [X] T005 [P] Update DTO unit tests in `test/modules/sales/repositories/dtos/pricing_dto_test.dart` to assert `'first_visit_minutes'` and `'routine_minutes'` serialization and JSON mapping

**Checkpoint**: Core data contracts and DTOs updated; user story implementation can begin.

---

## Phase 3: User Story 1 - Configure Technician Duration in Minutes (Priority: P1) 🎯 MVP

**Goal**: Sales representatives see "Menit Awal" and "Menit Rutin" column headers, input durations in minutes, and receive validation if duration is negative.

**Independent Test**: Open pricing calculator technician tab, verify column headers display "Menit Awal" and "Menit Rutin", enter duration values (e.g. 180 and 60 minutes), and confirm negative values trigger validation error `"Menit kerja tidak boleh negatif."`.

- [X] T006 [P] [US1] Update `PricingWorkerRow` state model in `lib/modules/sales/controllers/pricing_calculator_controller.dart` replacing `firstVisitHours` and `routineHours` with `firstVisitMinutes: Signal<double>` and `routineMinutes: Signal<double>`
- [X] T007 [US1] Add client-side validation in `PricingCalculatorController._validateInputs` in `lib/modules/sales/controllers/pricing_calculator_controller.dart` to reject negative minutes with error `"Menit kerja tidak boleh negatif."`
- [X] T008 [US1] Update table headers to `'Menit Awal'` and `'Menit Rutin'` and bind input fields to `row.firstVisitMinutes` and `row.routineMinutes` in `lib/modules/sales/views/widgets/pricing_calculator/pricing_worker_tab.dart`
- [X] T009 [US1] Update widget tests in `test/modules/sales/views/widgets/pricing_calculator_view_test.dart` to initialize and verify sample technician rows with minute values

**Checkpoint**: User Story 1 functional and verifiable independently.

---

## Phase 4: User Story 2 - Calculate and Preview Quote with Minute Durations (Priority: P2)

**Goal**: Quotation preview and pricing calculation correctly incorporate technician minutes and produce accurate labor costs.

**Independent Test**: Enter technician lines with minute durations and hourly rates, trigger preview, and verify that request payload contains `first_visit_minutes` and `routine_minutes` and labor cost rolls up correctly.

- [X] T010 [US2] Update `_buildRequest()` in `lib/modules/sales/controllers/pricing_calculator_controller.dart` to map `firstVisitMinutes.value` and `routineMinutes.value` to `PricingWorkerDto`
- [X] T011 [P] [US2] Update repository mock and test fixtures in `test/modules/sales/repositories/pricing_repository_test.dart` to use `firstVisitMinutes` and `routineMinutes`
- [X] T012 [US2] Update controller unit tests in `test/modules/sales/controllers/pricing_calculator_controller_test.dart` to verify `previewPricing` and `submitPricing` build requests with minute durations and enforce non-negative validation

**Checkpoint**: User Stories 1 and 2 functional and verifiable.

---

## Phase 5: User Story 3 - Review and Revise Existing Pricing (Priority: P3)

**Goal**: When loading an existing proposal pricing calculation, technician initial and routine visit minutes are loaded and mapped into input fields.

**Independent Test**: Open an existing proposal with saved pricing lines, navigate to the technician tab, and verify that the loaded duration fields reflect the stored minutes.

- [X] T013 [US3] Update `loadExistingPricing` in `lib/modules/sales/controllers/pricing_calculator_controller.dart` to map `w.firstVisitMinutes` and `w.routineMinutes` from `PricingDetailWorker` to `PricingWorkerRow`
- [X] T014 [US3] Add/update test case in `test/modules/sales/controllers/pricing_calculator_controller_test.dart` verifying `loadExistingPricing` maps technician duration minutes correctly

**Checkpoint**: All three user stories functional and covered with tests.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Quality gates, static analysis, and regression testing

- [X] T015 [P] Run static analysis with `rtk flutter analyze` and resolve any warnings or deprecations
- [X] T016 Run full test suite with `rtk flutter test` to confirm all 258+ tests pass with zero regressions
- [X] T017 Execute verification scenarios per `specs/001-pricing-worker-minutes/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Can start immediately.
- **Foundational (Phase 2)**: Depends on Phase 1; blocks all User Story work.
- **User Story 1 (Phase 3)**: Depends on Phase 2; provides MVP.
- **User Story 2 (Phase 4)**: Depends on Phase 2 and Phase 3 (extends controller request building and preview).
- **User Story 3 (Phase 5)**: Depends on Phase 2 and Phase 3 (extends controller existing pricing loader).
- **Polish (Phase 6)**: Depends on completion of all User Stories.

### Parallel Opportunities

- **Phase 2**: T002, T003, T004, and T005 touch distinct files and can be authored in parallel.
- **Phase 3**: T006 can run in parallel with UI inspection before T007/T008 integration.
- **Phase 4**: T011 (repository tests) can be updated in parallel with T010.
- **Phase 6**: T015 (analyzer) can run in parallel with test verification.

---

## Parallel Example: Foundational Phase

```bash
# Update entity and DTOs in parallel:
Task: "Update PricingDetailWorker entity in lib/modules/sales/entities/pricing_detail.dart"
Task: "Update PricingWorkerDto in lib/modules/sales/repositories/dtos/pricing_dto.dart"
Task: "Update PricingDetailWorkerDto in lib/modules/sales/repositories/dtos/pricing_detail_dto.dart"
Task: "Update DTO unit tests in test/modules/sales/repositories/dtos/pricing_dto_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)
1. Complete Phase 1 (Baseline test verification).
2. Complete Phase 2 (Foundational entities and DTOs).
3. Complete Phase 3 (User Story 1: row signals, UI headers "Menit Awal" / "Menit Rutin", negative validation).
4. **Validate MVP**: Sales reps can configure technician lines in minutes with clear labels.

### Incremental Delivery
1. Foundation + US1 → Visual and input clarity (MVP).
2. Add US2 → End-to-end preview and pricing submission with minutes.
3. Add US3 → Full cycle support for reviewing and revising saved pricing.
4. Polish → Complete test pass and static analysis.

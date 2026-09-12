# Implementation Plan: Pricing Worker Duration in Minutes

**Branch**: `001-pricing-worker-minutes` | **Date**: 2026-09-11 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-pricing-worker-minutes/spec.md`

## Summary

Align the sales proposal pricing calculator with the backend breaking change (2026-09-08) where technician work durations are now defined in minutes (`first_visit_minutes` and `routine_minutes`) rather than hours. The updates span the entire client vertical slice:
1. **Entity & DTOs**: Update `PricingDetailWorker`, `PricingWorkerDto`, and `PricingDetailWorkerDto` to use minute-based fields.
2. **Controller**: Update `PricingWorkerRow` state signals and add client validation against negative minutes.
3. **UI**: Update `PricingWorkerTab` table headers to "Menit Awal" and "Menit Rutin", binding inputs directly to minute values.
4. **Unit & Widget Tests**: Update serialization, controller, and widget tests to assert minute semantics.

---

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `signals` (core Dart state management), `signals_flutter` (reactive UI bindings), `dio` (HTTP networking), `get_it` (service locator)  
**Storage**: In-memory signals; backend persistence via REST API (`POST .../pricing`)  
**Testing**: `flutter_test` (unit & widget tests)  
**Target Platform**: Android / iOS (mobile & tablet)  
**Project Type**: Mobile ERP Application (Sales Module)  
**Performance Goals**: Instant UI reactivity via surgical `SignalBuilder` rebuilds (< 16ms frame budget), price preview network round-trip < 2s  
**Constraints**: Zero regression on existing proposal pricing calculation; strict adherence to layered architecture (inward dependencies only)  
**Scale/Scope**: 5 production source files, 3 test files across the `modules/sales/` slice  

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Layered Architecture & Inward Dependencies**: PASSED. Entity (`pricing_detail.dart`) remains pure Dart with no external dependencies. DTOs encapsulate JSON parsing. Controller relies on core Dart signals. View uses `signals_flutter`.
- **Error Handling**: PASSED. Client validation returns structured `UiFailure(UnknownFailure(...))`. Repository translates Dio exceptions to `Failure`.
- **Reactive State Management**: PASSED. Controller manages signals; View wraps only the table and action bar in `SignalBuilder`.
- **Test Coverage**: PASSED. All existing unit and widget tests will be updated to verify the new contract fields, ensuring zero broken tests.

---

## Project Structure

### Documentation (this feature)

```text
specs/001-pricing-worker-minutes/
├── spec.md              # Feature specification
├── plan.md              # Implementation plan (/speckit-plan output)
├── research.md          # Phase 0 decisions & alternatives
├── data-model.md        # Phase 1 domain entity & DTO mappings
├── contracts/
│   └── pricing-worker-api.md # Phase 1 API request/response contract
├── quickstart.md        # Phase 1 verification and test guide
└── checklists/
    └── requirements.md  # Specification quality checklist
```

### Source Code (repository root)

```text
lib/modules/sales/
├── entities/
│   └── pricing_detail.dart                   # PricingDetailWorker (firstVisitMinutes, routineMinutes)
├── repositories/
│   └── dtos/
│       ├── pricing_dto.dart                  # PricingWorkerDto (first_visit_minutes, routine_minutes)
│       └── pricing_detail_dto.dart           # PricingDetailWorkerDto (deserialization)
├── controllers/
│   └── pricing_calculator_controller.dart    # PricingWorkerRow signals & validation
└── views/
    └── widgets/
        └── pricing_calculator/
            └── pricing_worker_tab.dart       # UI headers ("Menit Awal", "Menit Rutin") & inputs

test/modules/sales/
├── repositories/
│   ├── dtos/
│   │   └── pricing_dto_test.dart             # DTO serialization tests
│   └── pricing_repository_test.dart          # Repository tests
├── controllers/
│   └── pricing_calculator_controller_test.dart # Controller logic & row tests
└── views/
    └── widgets/
        └── pricing_calculator_view_test.dart  # Calculator view widget tests
```

**Structure Decision**: Standard module-first layered architecture under `lib/modules/sales/`. Changes are localized within the existing files of the `sales` module without introducing unnecessary new abstractions or packages.

---

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| *None* | Standard architectural refactor aligning with contract | N/A |

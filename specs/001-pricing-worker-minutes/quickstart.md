# Quickstart & Verification Guide: Pricing Worker Duration in Minutes

## Prerequisites

- Flutter SDK 3.x+ installed and configured
- Dependencies retrieved (`rtk flutter pub get`)
- Static analysis clean (`rtk flutter analyze`)

---

## Verification Scenarios

### Scenario 1: DTO Serialization & Deserialization
Verify that `PricingWorkerDto` outputs `first_visit_minutes` and `routine_minutes`, and `PricingDetailWorkerDto` parses both correctly.

**Test Command**:
```bash
rtk flutter test test/modules/sales/repositories/dtos/pricing_dto_test.dart
```

**Expected Outcome**:
- `PricingWorkerDto.toJson()` includes `'first_visit_minutes'` and `'routine_minutes'`.
- Does not output obsolete `'first_visit_hours'` or `'routine_hours'`.

---

### Scenario 2: Controller State & Validation
Verify that `PricingWorkerRow` holds minute signals, validates non-negative durations, and constructs the API request with minutes.

**Test Command**:
```bash
rtk flutter test test/modules/sales/controllers/pricing_calculator_controller_test.dart
```

**Expected Outcome**:
- `PricingWorkerRow` initializes with `firstVisitMinutes` and `routineMinutes`.
- Submitting negative minutes is caught by validation and yields `"Menit kerja tidak boleh negatif."`.
- Correct minute values are included when preparing preview/save requests.

---

### Scenario 3: UI Widget Rendering & Header Labels
Verify that the `PricingWorkerTab` renders column headers with `"Menit Awal"` and `"Menit Rutin"`.

**Test Command**:
```bash
rtk flutter test test/modules/sales/views/widgets/pricing_calculator_view_test.dart
```

**Expected Outcome**:
- Table headers contain `"Menit Awal"` and `"Menit Rutin"`.
- Technician rows populate minute inputs and react to changes.

---

### Scenario 4: Full Suite Regression
Ensure zero regressions across the sales module.

**Command**:
```bash
rtk flutter test
```

**Expected Outcome**:
- 258+ tests pass cleanly.

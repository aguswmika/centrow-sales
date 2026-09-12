# Research & Architectural Decisions: Pricing Worker Duration in Minutes

## Context & Overview

The proposal pricing calculation API contract (`POST /api/v1/sales/proposals/:id/pricing` and `POST /api/v1/sales/proposals/:id/pricing/preview`) has implemented a breaking change on 2026-09-08:
Worker line duration fields were renamed from hours to minutes:
- `first_visit_hours` → `first_visit_minutes`
- `routine_hours` → `routine_minutes`

The server-side computation formula divides total minutes by 60:
`line_total = (first_visit_minutes + visit_frequency × routine_minutes) / 60 × hourly_rate`

The mobile UI and client models must be updated so that:
1. Sales reps explicitly enter and view duration in minutes.
2. The UI headers indicate "Menit Awal" and "Menit Rutin" instead of "Jam Awal" and "Jam Rutin".
3. DTOs and entities serialize and deserialize the new field names (`first_visit_minutes`, `routine_minutes`).
4. Client validation disallows negative values and aligns with the server error message `"Menit kerja tidak boleh negatif"`.

---

## Technical Decisions

### Decision 1: Domain Entity & DTO Field Naming

- **Decision**: Rename fields in both DTOs (`first_visit_minutes`, `routine_minutes`) and Dart entities/state models (`firstVisitMinutes`, `routineMinutes`).
- **Rationale**: Keeps naming clear, consistent, and semantically accurate across all layers (Entity, DTO, Controller, View). Retaining `Hours` in Dart code while the JSON payload uses `minutes` would introduce severe confusion, cognitive overhead, and potential unit conversion bugs.
- **Alternatives Considered**:
  - *Keep `firstVisitHours` in entities and convert to/from minutes in DTOs*: Rejected because the product decision is that users and operators now work directly in minutes. Converting back and forth would reintroduce floating-point conversion inaccuracies (e.g. 45 minutes = 0.75 hours).

### Decision 2: UI Input Representation & Formatting

- **Decision**: In `PricingWorkerTab`, update table column headers to `"Menit Awal"` and `"Menit Rutin"`. Number inputs accept whole or decimal numbers representing minutes (e.g. `120`, `45`, `180`).
- **Rationale**: Direct 1:1 input of minutes eliminates confusion. A sales representative wanting 2 hours types `120`; 30 minutes types `30`.
- **Alternatives Considered**:
  - *Time picker (HH:MM)*: Rejected because the current UI uses a compact table layout with `buildInput` text fields, optimized for quick tabular data entry on mobile/tablet. Changing to a complex time picker would break layout consistency and slow down data entry.

### Decision 3: Client-Side Input Validation

- **Decision**: Add client-side validation in `PricingCalculatorController._validateInputs` to ensure `firstVisitMinutes >= 0` and `routineMinutes >= 0`. If negative, yield `UiFailure(UnknownFailure('Menit kerja tidak boleh negatif.'))`.
- **Rationale**: Immediate validation feedback prevents unnecessary network round-trips when invalid values are entered. Matches exact server validation semantics.
- **Alternatives Considered**:
  - *Rely strictly on backend validation*: Rejected because the mobile app already validates chemical dose limits and tool quantities client-side before network calls.

### Decision 4: Backward Compatibility & Response Handling

- **Decision**: In `PricingDetailWorkerDto.fromJson`, read `first_visit_minutes` with fallback to `first_visit_hours` if ever encountered during transition; output standard `firstVisitMinutes` and `routineMinutes`.
- **Rationale**: Defensive parsing ensures that if cached mock data or older responses are encountered in development, parsing does not throw null errors.
- **Alternatives Considered**:
  - *Strict parsing only of new keys*: Kept as primary path, with fallback to old key as safety net: `(j['first_visit_minutes'] ?? j['first_visit_hours'] ?? 0 as num).toDouble()`.

---

## Blast Radius & Dependency Impact

| Component / Layer | Affected Files | Impact & Changes |
|---|---|---|
| **Entity** | `lib/modules/sales/entities/pricing_detail.dart` | Update `PricingDetailWorker` to have `firstVisitMinutes` and `routineMinutes`. |
| **DTO (Request)** | `lib/modules/sales/repositories/dtos/pricing_dto.dart` | Update `PricingWorkerDto` fields and `toJson()` keys to `first_visit_minutes` and `routine_minutes`. |
| **DTO (Response)** | `lib/modules/sales/repositories/dtos/pricing_detail_dto.dart` | Update `PricingDetailWorkerDto.fromJson()` to parse `first_visit_minutes` and `routine_minutes`. |
| **Controller** | `lib/modules/sales/controllers/pricing_calculator_controller.dart` | Update `PricingWorkerRow` properties, `loadExistingPricing` mapping, and `_buildRequest` mapping. Add non-negative validation. |
| **View** | `lib/modules/sales/views/widgets/pricing_calculator/pricing_worker_tab.dart` | Update table header labels to `"Menit Awal"` and `"Menit Rutin"`, update row binding. |
| **Tests** | `test/modules/sales/repositories/dtos/pricing_dto_test.dart`<br>`test/modules/sales/controllers/pricing_calculator_controller_test.dart`<br>`test/modules/sales/views/widgets/pricing_calculator_view_test.dart` | Update test fixtures, assertions, and mock payloads. |

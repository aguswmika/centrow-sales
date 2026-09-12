# Data Model: Pricing Worker Duration in Minutes

## Core Entities

### 1. `PricingDetailWorker` (Domain Entity)
- **Path**: `lib/modules/sales/entities/pricing_detail.dart`
- **Description**: Immutable Dart entity representing a technician worker line item in an existing pricing calculation.
- **Fields**:
  - `id`: `String` — Unique identifier of the worker pricing line.
  - `productId`: `String` — Product ID referencing a technician product.
  - `positionName`: `String` — Position title/label snapshot.
  - `visitFrequency`: `int?` — Number of visits for this worker line.
  - `firstVisitMinutes`: `double` — Duration in minutes spent on the first visit (>= 0).
  - `routineMinutes`: `double` — Duration in minutes spent on each routine visit (>= 0).
  - `hourlyRate`: `double` — Technician hourly billing rate.
  - `lineTotal`: `double` — Calculated labor cost for this line: `(firstVisitMinutes + visitFrequency × routineMinutes) / 60 × hourlyRate`.

---

## Data Transfer Objects (DTOs)

### 2. `PricingWorkerDto` (Request DTO)
- **Path**: `lib/modules/sales/repositories/dtos/pricing_dto.dart`
- **Description**: Encodes worker line parameters for `previewPricing` and `savePricing` payloads.
- **JSON Schema**:
  ```json
  {
    "product_id": "string (uuid)",
    "visit_frequency": "integer (> 0)",
    "first_visit_minutes": "number (>= 0)",
    "routine_minutes": "number (>= 0)"
  }
  ```
- **Serialization Mapping**:
  ```dart
  Map<String, dynamic> toJson() => {
    'product_id': productId,
    if (visitFrequency != null) 'visit_frequency': visitFrequency,
    'first_visit_minutes': firstVisitMinutes,
    'routine_minutes': routineMinutes,
  };
  ```

### 3. `PricingDetailWorkerDto` (Response DTO)
- **Path**: `lib/modules/sales/repositories/dtos/pricing_detail_dto.dart`
- **Description**: Decodes worker line items returned by `GET /api/v1/sales/proposals/:id/pricing`.
- **Deserialization**:
  - `first_visit_minutes`: reads `j['first_visit_minutes'] ?? j['first_visit_hours'] ?? 0` as `double`
  - `routine_minutes`: reads `j['routine_minutes'] ?? j['routine_hours'] ?? 0` as `double`
- **Entity Conversion**:
  - Maps to `PricingDetailWorker` with `firstVisitMinutes` and `routineMinutes`.

---

## Controller State Model

### 4. `PricingWorkerRow`
- **Path**: `lib/modules/sales/controllers/pricing_calculator_controller.dart`
- **Description**: Mutable, reactive row item holding Signals for user input in the pricing calculator.
- **Signals**:
  - `visitFreq`: `Signal<double>` — Number of visits for this technician.
  - `firstVisitMinutes`: `Signal<double>` — Duration of first visit in minutes (default `0.0`).
  - `routineMinutes`: `Signal<double>` — Duration of routine visits in minutes (default `0.0`).
  - `hourlyRate`: `Signal<double>` — Hourly rate of the technician role.
- **Validation Rules**:
  - `firstVisitMinutes.value >= 0`: Error `"Menit kerja tidak boleh negatif"` if `< 0`.
  - `routineMinutes.value >= 0`: Error `"Menit kerja tidak boleh negatif"` if `< 0`.

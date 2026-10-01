## 1. Domain Entities & DTOs

- [x] 1.1 Create `SiteRiskMaster` and `CustomerAddressRisk` domain entities in `lib/modules/sales/entities/site_risk.dart` with pure Dart types and immutability.
- [x] 1.2 Implement `SiteRiskMasterDto`, `CustomerAddressRiskDto`, and payload serialization in `lib/modules/sales/repositories/dtos/site_risk_dto.dart` with JSON mapping, and verify with unit tests.

## 2. Repository Layer

- [x] 2.1 Define `SiteRiskRepository` interface in `lib/modules/sales/repositories/site_risk_repository.dart` for fetching master risks, fetching address risks, and full replace updates.
- [x] 2.2 Implement `SiteRiskRepositoryImpl` with Dio integration, parsing responses, and translating technical errors to sealed `Result`/`Failure` types.
- [x] 2.3 Write repository unit tests covering 200 success, 400 validation, 403 forbidden, 404 not found, and 500 server error responses and verify via `flutter test`.

## 3. Controller Layer (Signals)

- [x] 3.1 Implement `SiteRiskController` in `lib/modules/sales/controllers/site_risk_controller.dart` managing Signals for master hazards, address hazards, selection sets, custom risk additions, and save operations.
- [x] 3.2 Add controller unit tests verifying initial load, selection toggling, retaining deleted master items, adding/removing custom risks, and saving results via `flutter test`.
- [x] 3.3 Register `SiteRiskRepository` (lazy singleton) and `SiteRiskController` (factory) in `lib/app/di.dart` and verify DI resolution.

## 4. UI Presentation & Integration

- [x] 4.1 Create `SiteRiskAssessmentSheet` in `lib/modules/sales/views/widgets/site_risk_assessment_sheet.dart` rendering the master checklist, retained items, custom hazard inputs, and save action.
- [x] 4.2 Integrate the risk assessment trigger and status indicator on location cards in `lib/modules/sales/views/widgets/customer_locations_tab.dart`.
- [x] 4.3 Add widget tests verifying assessment sheet opening, checklist interactions, and error feedback via `flutter test`.

## 5. Verification & Code Quality

- [x] 5.1 Run static analysis via `flutter analyze` and verify zero errors or warnings.
- [x] 5.2 Run code formatting via `dart format .` and execute full unit/widget test suite via `flutter test`.

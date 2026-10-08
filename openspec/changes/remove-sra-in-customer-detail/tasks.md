## 1. UI Modification in Customer Detail

- [x] 1.1 Remove the "Penilaian Risiko (SRA)" action button, tap handler, and `SiteRiskAssessmentSheet` import from `lib/modules/sales/views/widgets/customer_locations_tab.dart`, and verify location item cards render cleanly without the SRA button.
- [x] 1.2 Remove `lib/modules/sales/views/widgets/site_risk_assessment_sheet.dart` and verify no references to it remain in the codebase.

## 2. Dependency Injection and Controller Cleanup

- [x] 2.1 Remove the `SiteRiskController` factory registration from `lib/app/di.dart` and delete `lib/modules/sales/controllers/site_risk_controller.dart`.
- [x] 2.2 Remove `test/modules/sales/controllers/site_risk_controller_test.dart` and verify DI registrations in `lib/app/di.dart` build cleanly.

## 3. Test Updates and Verification

- [x] 3.1 Remove `test/modules/sales/views/widgets/site_risk_assessment_sheet_test.dart` and update `CustomerLocationsTab` widget tests in `test/modules/sales/views/widgets/customer_detail_pane_test.dart` (or add a dedicated test) to verify that "Penilaian Risiko (SRA)" is not present on location cards.
- [x] 3.2 Run `flutter analyze` and `flutter test` to verify that static analysis and the test suite pass with zero errors.

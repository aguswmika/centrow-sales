## Why

Site Risk Assessment (SRA) management is intended to be captured during customer onboarding and profile editing rather than managed ad-hoc directly from the customer detail locations tab. Removing the SRA trigger from the customer detail locations list streamlines the view to focus on location address details and prevents redundant/unintended edits outside the standard customer management flow.

## What Changes

- **Customer Detail Locations Tab**: Remove the "Penilaian Risiko (SRA)" action button and bottom sheet launcher from each location item card in `CustomerLocationsTab`.
- **SRA Detail Widget & Controller Cleanup**: Remove `SiteRiskAssessmentSheet` and clean up `SiteRiskController` registration/usages that were only used by the customer detail view.
- **Tests**: Update `CustomerLocationsTab` tests and remove or adjust obsolete integration tests for the customer detail SRA sheet.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `site-risk-assessment`: Remove the requirement and scenarios for displaying and launching Site Risk Assessment directly from customer service locations in the customer detail view.

## Impact

- **UI / Views**: `lib/modules/sales/views/widgets/customer_locations_tab.dart` (removes SRA button and bottom sheet invocation), `lib/modules/sales/views/widgets/site_risk_assessment_sheet.dart` (removed or cleaned up).
- **Controllers & DI**: `lib/modules/sales/controllers/site_risk_controller.dart` and `lib/app/di.dart` (clean up unused registration if removed).
- **Tests**: `test/modules/sales/views/widgets/site_risk_assessment_sheet_test.dart`, `test/modules/sales/views/widgets/customer_locations_tab_test.dart` (or location card integration test).
- **APIs**: No backend API changes; customer creation and edit workflows remain untouched and continue to handle SRA on primary locations.

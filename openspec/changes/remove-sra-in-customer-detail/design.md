## Context

Currently, the customer detail locations tab (`CustomerLocationsTab` in `lib/modules/sales/views/widgets/customer_locations_tab.dart`) displays an action button labelled "Penilaian Risiko (SRA)" for each customer service location card. Tapping this button displays `SiteRiskAssessmentSheet`, an interactive modal bottom sheet that allows loading and saving address-level site risks via `SiteRiskController` and `SiteRiskRepository`.

Site Risk Assessment is also captured and edited in the customer creation and edit flows (`Step2LocationsForm`, `CustomerFormSiteRiskSheet`, and `CustomerFormController`). The product requirement is to remove SRA from customer detail to avoid ad-hoc out-of-flow modifications.

## Goals / Non-Goals

**Goals:**
- Remove the "Penilaian Risiko (SRA)" button and its bottom sheet opener from each location card in `CustomerLocationsTab`.
- Remove `SiteRiskAssessmentSheet` and its corresponding widget tests.
- Clean up unused `SiteRiskController` and its DI registration in `app/di.dart` and unit tests.
- Update tests for `CustomerLocationsTab` to ensure location cards render without the SRA button.
- Ensure `flutter analyze` and tests pass cleanly.

**Non-Goals:**
- Altering the customer creation or customer edit SRA workflows (`CustomerFormPage`, `Step2LocationsForm`, `CustomerFormSiteRiskSheet`, `CustomerFormController`).
- Removing `SiteRiskRepository` methods used during customer editing (`getAddressRisks` is used by `CustomerFormController`).
- Any backend API changes or database schema alterations.

## Decisions

### Decision 1: Remove `SiteRiskAssessmentSheet` completely rather than keeping it orphaned
- **Rationale**: `SiteRiskAssessmentSheet` was only used by `CustomerLocationsTab`. Keeping it creates dead UI code and requires maintaining orphaned tests.
- **Alternative considered**: Keeping `SiteRiskAssessmentSheet` unused. Rejected to prevent technical debt and dead code.

### Decision 2: Remove `SiteRiskController` and its registration in `app/di.dart`
- **Rationale**: `SiteRiskController` was only consumed by `SiteRiskAssessmentSheet`. Customer form uses `CustomerFormController` and directly interacts with `SiteRiskRepository`. Removing `SiteRiskController` keeps the controller layer clean.
- **Alternative considered**: Retaining `SiteRiskController` without usages. Rejected because controllers should not be kept if no view consumes them.

### Decision 3: Streamline location card layout in `CustomerLocationsTab`
- **Rationale**: Removing the SRA button and its enclosing `InkWell` and spacing leaves a cleaner card containing the location icon, label, "Utama" badge (if primary), address, and region metadata.

## Risks / Trade-offs

- **[Risk] Sales reps can no longer edit SRA directly from customer detail**:
  → *Mitigation*: Intended behavior. SRA updates must be performed via the "Edit Pelanggan" action to ensure consistency.
- **[Risk] Existing widget tests expecting the SRA button fail**:
  → *Mitigation*: Update `site_risk_assessment_sheet_test.dart` / `customer_locations_tab_test.dart` to verify that the SRA button is no longer present.

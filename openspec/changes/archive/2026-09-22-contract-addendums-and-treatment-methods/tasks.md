## 1. Treatment Method Master Data & UI Update

- [x] 1.1 Update `TreatmentMethod` entity and `TreatmentMethodDto` to include the `isRequired` (`bool`, defaulting to false) field mapped from `is_required`, and verify with `rtk flutter analyze`
- [x] 1.2 Update `TreatmentMethodPickerSheet` to display a "Wajib" badge tag when `method.isRequired` is true, and verify with `rtk flutter analyze`

## 2. Pricing Calculator Treatment Quotas Data & State Layer

- [x] 2.1 Update `PricingDetail` entity and `PricingDetailDto` to model and parse `treatment_quotas` (`PricingDetailTreatmentQuota`), and verify with `rtk flutter analyze`
- [x] 2.2 Update `CreatePricingRequestDto` and `PricingTreatmentQuotaDto` in `pricing_dto.dart` to serialize `treatment_quotas`, and verify with `rtk flutter analyze`
- [x] 2.3 Update `PricingCalculatorController` to introduce `PricingTreatmentQuotaRow`, manage `treatmentQuotas` reactive list, load existing quotas in `loadExistingPricing`, and include quotas in `_buildRequest()`, and verify with `rtk flutter analyze`

## 3. Pricing Calculator UI & Proposal Send Validation

- [x] 3.1 Update `PricingTabs` to include the 4th tab "Kuota Treatment" with dynamic count badge, and verify with `rtk flutter analyze`
- [x] 3.2 Create `PricingTreatmentQuotaTab` widget allowing reps to add treatment methods, adjust quota counts, remove methods, and use an "Isi Metode Wajib" button, and verify with `rtk flutter analyze`
- [x] 3.3 Update `ProposalController` and `ProposalPage` to gracefully handle and display HTTP 400 errors when sending a proposal that lacks required treatment method quotas, and verify with `rtk flutter analyze`

## 4. Contract Addendum Data & Controller Layer

- [x] 4.1 Create `ContractAddendum` entity (`lib/modules/sales/entities/contract_addendum.dart`) and `ContractAddendumDto` (`lib/modules/sales/repositories/dtos/contract_addendum_dto.dart`), and verify with `rtk flutter analyze`
- [x] 4.2 Create `ContractAddendumRepository` interface and implementation (`lib/modules/sales/repositories/contract_addendum_repository.dart`) with `getAddendums` (`GET /api/v1/sales/contracts/:id/addendums`) and `createAddendum` (`POST /api/v1/sales/contracts/:id/addendums`) error mapping, and verify with `rtk flutter analyze`
- [x] 4.3 Implement `ContractAddendumController` (`lib/modules/sales/controllers/contract_addendum_controller.dart`) handling history loading, addendum form submission, and error handling, and verify with `rtk flutter analyze`
- [x] 4.4 Register `ContractAddendumRepository` and `ContractAddendumController` in `lib/app/di.dart`, and verify with `rtk flutter analyze`

## 5. Contract Detail UI Adjustments & Addendum Components

- [x] 5.1 Create `ContractAddendumFormSheet` (`lib/modules/sales/views/widgets/contract_addendum_form_sheet.dart`) for submitting signed visit delta and optional reason with live total visits calculation and input validation, and verify with `rtk flutter analyze`
- [x] 5.2 Create `ContractAddendumHistoryList` (`lib/modules/sales/views/widgets/contract_addendum_history_list.dart`) displaying past addendums with old/new total visits, old/new contract value, reason, date, and user, and verify with `rtk flutter analyze`
- [x] 5.3 Update `ContractDetailPane` (`lib/modules/sales/views/widgets/contract_detail_pane.dart`) to display the addendum history section and "Buat Addendum" action when the contract is active, and verify with `rtk flutter analyze`
- [x] 5.4 Hook addendum creation completion to reload the selected contract detail and contract master list, and verify with `rtk flutter analyze`

## 6. Verification & Code Quality

- [x] 6.1 Run static analysis (`rtk flutter analyze`) and code formatting (`rtk dart format .`) to verify clean compilation with zero warnings or errors


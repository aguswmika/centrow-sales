## 1. DTO and Repository Layer

- [x] 1.1 Update `ContractFormRequestDto` in `lib/modules/sales/repositories/dtos/contract_dto.dart` to provide explicit serialization for create (`toCreateJson()`, omitting `end_date` and including `contract_template_id`) and update (`toUpdateJson()`, omitting `contract_template_id` and including optional `end_date`). Verify with `flutter analyze`.
- [x] 1.2 Update `ContractRepositoryImpl` in `lib/modules/sales/repositories/contract_repository.dart` to call `toCreateJson()` in `createContractFromProposal` and `toUpdateJson()` in `updateContract`. Verify with `flutter analyze`.

## 2. Controller Layer

- [x] 2.1 Update `ContractFormController` in `lib/modules/sales/controllers/contract_form_controller.dart` to bypass `endDate` validation during create mode (`!isEditMode`), validate `endDate` against `startDate` only in edit mode when provided, and require `contractTemplateId` only during create mode. Verify with `flutter analyze`.

## 3. UI Layer

- [x] 3.1 Update `ContractFormBottomSheet` in `lib/modules/sales/views/widgets/contract_form_bottom_sheet.dart` to display the "Tanggal Selesai" date picker only in edit mode (`isEditMode`), omitting it from the proposal conversion form.
- [x] 3.2 Update informational helper text in `ContractFormBottomSheet` to clearly communicate that contract end date is calculated automatically from the proposal pricing duration, and that contract value, total visits, and signatory are derived from the proposal and customer contacts.

## 4. Verification and Tests

- [x] 4.1 Update existing unit and widget tests in `test/modules/sales/views/widgets/contract_form_bottom_sheet_test.dart` and relevant controller tests to align with create vs edit mode fields. Verify with `flutter test`.
- [x] 4.2 Run `rtk flutter analyze` and confirm zero static analysis errors across all modified modules.

## 1. Domain Entities & DTOs

- [x] 1.1 Update `ContractAddendum` entity and `ContractAddendumDto` to include `pricingId` / `pricing_id`, and verify with `rtk flutter test test/modules/sales/entities/contract_addendum_test.dart` and `test/modules/sales/repositories/dtos/contract_addendum_dto_test.dart`
- [x] 1.2 Create `AddendumTemplate` entity and `AddendumTemplateDto` in `lib/modules/sales/entities/addendum_template.dart` and `lib/modules/sales/repositories/dtos/addendum_template_dto.dart`, and verify with unit tests in `test/modules/sales/repositories/dtos/addendum_template_dto_test.dart`
- [x] 1.3 Create `ContractAddendumDocument` entity and `ContractAddendumDocumentDto` in `lib/modules/sales/entities/contract_addendum_document.dart` and `lib/modules/sales/repositories/dtos/contract_addendum_document_dto.dart`, and verify with unit tests in `test/modules/sales/repositories/dtos/contract_addendum_document_dto_test.dart`

## 2. Repository Layer

- [x] 2.1 Implement `ContractAddendumDocumentRepository` interface and implementation in `lib/modules/sales/repositories/contract_addendum_document_repository.dart` (`getActiveTemplates`, `getDocument`, `saveDocument`, `downloadPdf`), and verify with repository tests in `test/modules/sales/repositories/contract_addendum_document_repository_test.dart`

## 3. Controller Layer

- [x] 3.1 Implement `ContractAddendumDocumentController` in `lib/modules/sales/controllers/contract_addendum_document_controller.dart` managing signals for active templates, document state, save state, and PDF download, and verify with controller tests in `test/modules/sales/controllers/contract_addendum_document_controller_test.dart`

## 4. UI Components & Pages

- [x] 4.1 Create `AddendumTemplatePickerSheet` in `lib/modules/sales/views/widgets/addendum_template_picker_sheet.dart` for choosing active templates before document previewing, and verify with widget tests in `test/modules/sales/views/widgets/addendum_template_picker_sheet_test.dart`
- [x] 4.2 Create `ContractAddendumDocumentPage` in `lib/modules/sales/views/pages/contract_addendum_document_page.dart` integrating `WebViewTiptapEditor`, `CustomTiptapToolbar`, save action, and PDF download, and verify with widget tests in `test/modules/sales/views/pages/contract_addendum_document_page_test.dart`
- [x] 4.3 Update `_ContractAddendumCard` in `lib/modules/sales/views/widgets/contract_addendum_history_list.dart` to display pricing snapshot badge and document action buttons ("Dokumen Addendum" and "Unduh PDF"), and verify with widget tests in `test/modules/sales/views/widgets/contract_addendum_history_list_test.dart`

## 5. Dependency Injection, Routing, and Integration Verification

- [x] 5.1 Register `ContractAddendumDocumentRepository` and `ContractAddendumDocumentController` in `lib/app/di.dart`
- [x] 5.2 Register route `/contracts/:contractId/addendums/:addendumId/document` in `lib/app/router.dart`
- [x] 5.3 Run `rtk flutter analyze` and `rtk flutter test` to ensure clean static analysis and test passing across the project

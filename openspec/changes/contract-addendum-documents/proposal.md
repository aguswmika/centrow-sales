## Why

The backend API for contract addendums and contract addendum documents has been updated (`docs/api/contract-addendums.md` and `docs/api/addendum-documents.md`):
1. `ContractAddendum` records now expose `pricing_id`, linking the addendum to its newly cloned and scaled pricing snapshot.
2. An addendum document system (`ContractAddendumDocument`) has been implemented on the server, offering active template listing (`GET /api/v1/sales/addendum-templates/active`), document fetching and template seeding (`GET /api/v1/sales/contract-addendums/:id/document`), document upserting (`PUT /api/v1/sales/contract-addendums/:id/document`), and PDF generation (`GET /api/v1/sales/contract-addendums/:id/document/pdf`).

Currently in the mobile app (`centrow-sales`), addenda in the history list cannot display, edit, or download formal addendum agreement documents, nor do they record or navigate to the associated `pricing_id`. Providing full addendum document support and integrating `pricing_id` enables sales staff to generate, customize via rich text (Tiptap), preview from active templates, and export addendum PDFs directly on mobile devices.

## What Changes

- **Contract Addendum Data & Pricing Reference**:
  - Update `ContractAddendum` entity and `ContractAddendumDto` to parse and store `pricing_id`.
  - Display a link or badge on the addendum history card acknowledging the associated pricing snapshot.
- **Contract Addendum Document Client & Domain Layer**:
  - Create `ContractAddendumDocument` and `AddendumTemplate` entities and DTOs.
  - Implement `ContractAddendumDocumentRepository` for fetching active templates, loading documents (or seeding previews with `template_id`), saving edited Tiptap JSON content, and downloading PDFs using `/v1/sales/...` endpoints.
  - Implement `ContractAddendumDocumentController` with Signals for managing document loading, template selection, content modification, save state, and PDF export.
- **Template Selection & Document Management UI**:
  - Add template selection bottom sheet (`AddendumTemplatePickerSheet`) to choose an active template when opening a document for an addendum that has no saved document yet.
  - Implement `ContractAddendumDocumentPage` utilizing the existing `WebViewTiptapEditor` and `CustomTiptapToolbar` for viewing and editing addendum document content, saving updates, and downloading/previewing PDFs.
  - Add route in `lib/app/router.dart` for navigating to `/contracts/:contractId/addendums/:addendumId/document`.
- **Addendum History Integration**:
  - In `_ContractAddendumCard` within `ContractAddendumHistoryList`, add action buttons: "Dokumen Addendum" (opens editor/viewer or template picker) and "Unduh PDF" (direct PDF download/share).

## Capabilities

### New Capabilities
- `contract-addendum-documents`: Contract addendum document lifecycle on mobile: listing active templates, previewing template-seeded documents, editing and saving rich-text Tiptap JSON documents, and downloading PDF files.

### Modified Capabilities
- `contract-addendums`: Enhance contract addendum records with `pricing_id` linking to the associated pricing snapshot, and integrate document management triggers in addendum history cards.

## Impact

- **Affected Code**:
  - `lib/modules/sales/entities/contract_addendum.dart` (add `pricingId`)
  - `lib/modules/sales/repositories/dtos/contract_addendum_dto.dart` (map `pricing_id`)
  - `lib/modules/sales/entities/contract_addendum_document.dart` (new entity)
  - `lib/modules/sales/entities/addendum_template.dart` (new entity)
  - `lib/modules/sales/repositories/dtos/contract_addendum_document_dto.dart` (new DTO)
  - `lib/modules/sales/repositories/dtos/addendum_template_dto.dart` (new DTO)
  - `lib/modules/sales/repositories/contract_addendum_document_repository.dart` (new repository)
  - `lib/modules/sales/controllers/contract_addendum_document_controller.dart` (new controller)
  - `lib/modules/sales/views/pages/contract_addendum_document_page.dart` (new page)
  - `lib/modules/sales/views/widgets/addendum_template_picker_sheet.dart` (new picker)
  - `lib/modules/sales/views/widgets/contract_addendum_history_list.dart` (document actions)
  - `lib/app/di.dart` (register new repository and controller)
  - `lib/app/router.dart` (register addendum document route)
- **Dependencies**: Reuses existing `webview_flutter`, `signals`, `dio`, and `get_it`. No new packages required.
- **Backend API Alignment**: Mobile app requests will target `/api/v1/sales/contract-addendums/:id/document`, `/api/v1/sales/contract-addendums/:id/document/pdf`, and `/api/v1/sales/addendum-templates/active` with `mobile` JWT audience.

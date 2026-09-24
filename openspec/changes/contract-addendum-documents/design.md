## Context

The backend has implemented rich-text document support for contract addendums (`ContractAddendumDocument`) and active addendum templates (`AddendumTemplate`), as documented in `docs/api/addendum-documents.md` and `docs/api/contract-addendums.md`. The existing mobile app (`centrow-sales`) already supports rich-text document editing for contracts and proposals using a Flutter-to-WebView bridge (`WebViewTiptapEditor` and `CustomTiptapToolbar`), but addenda currently only exist as plain metric history entries without document generation or PDF export.

## Goals / Non-Goals

**Goals:**
- Update `ContractAddendum` entity and DTO to include `pricing_id`.
- Implement `ContractAddendumDocument` and `AddendumTemplate` domain entities, DTOs, repository, and controller.
- Provide a template picker sheet (`AddendumTemplatePickerSheet`) to choose an active template when viewing/creating a fresh addendum's document.
- Provide a full document editor/viewer page (`ContractAddendumDocumentPage`) supporting Tiptap rich-text editing, document saving, and PDF downloading.
- Integrate action buttons on each addendum card in `ContractAddendumHistoryList` to open the document or download the PDF.

**Non-Goals:**
- Creating or editing addendum templates from the mobile app (template CRUD is ops/web-only).
- Modifying contract addendum visit calculations or creation logic (already implemented).
- Placeholder substitution logic (addendum documents render verbatim rich text without placeholder substitution).

## Decisions

### 1. Reuse existing `WebViewTiptapEditor` and `CustomTiptapToolbar`
- **Choice**: Use the existing `WebViewTiptapEditor` widget for rendering and editing Tiptap/ProseMirror JSON trees.
- **Rationale**: The mobile app already maintains an asset-based Tiptap v3 webview environment supporting paragraph, headings, lists, tables, marks, and alignment. Reusing this component ensures consistent UX and avoids introducing new third-party dependencies.
- **Alternative considered**: Using flutter_quill or markdown. Rejected because the backend stores and validates ProseMirror/Tiptap JSON schema.

### 2. Upfront Template Selection for Fresh Addendums
- **Choice**: If an addendum has no saved document yet, prompt the user with `AddendumTemplatePickerSheet` before opening `ContractAddendumDocumentPage` (or fetch templates automatically if only 1 is active). Pass the selected `templateId` to the document page.
- **Rationale**: The backend `GET /api/v1/sales/contract-addendums/:id/document` requires `template_id` query parameter when no document row exists in the database. Selecting the template first ensures the document page loads cleanly with the template-seeded preview.
- **Alternative considered**: Navigating to an empty editor and having an inline template dropdown. Rejected because the initial document fetch would fail with HTTP 400 before a template is selected.

### 3. API Route Targeting `/v1/sales/...`
- **Choice**: Target `/v1/sales/contract-addendums/:id/document`, `/v1/sales/contract-addendums/:id/document/pdf`, and `/v1/sales/addendum-templates/active`.
- **Rationale**: The mobile app authenticates using JWT access tokens with audience `mobile`. The server auth middleware verifies that `/api/v1/` routes match the `mobile` audience.
- **Alternative considered**: Calling `/api/sales/...` directly. Rejected because `/api/sales/...` is restricted to `web` audience in the backend middleware and would trigger HTTP 401.

### 4. Direct PDF Download and Share
- **Choice**: Download PDF bytes via Dio into a temporary file and invoke system share/open using existing platform helpers.
- **Rationale**: Matches the pattern used in `ContractDocumentPage` and `ProposalDocumentPage`.

## Risks / Trade-offs

- **[Risk]** Addendum document has no active templates on the server when a user tries to create one.
  → **Mitigation**: `AddendumTemplatePickerSheet` handles empty template lists gracefully with an informative empty state informing the user to ask administrators to activate an addendum template.
- **[Risk]** First save requires `template_id` in request body, while subsequent saves ignore it.
  → **Mitigation**: `ContractAddendumDocumentController` retains the `templateId` used to seed the document and includes it on the initial save request (`PUT`), subsequent saves omit it once `documentId` is non-null.
- **[Risk]** Document editing conflicts if edited concurrently.
  → **Mitigation**: Standard server error handling via `Failure` with user-friendly retry and error notifications.

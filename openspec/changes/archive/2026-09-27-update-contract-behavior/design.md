## Context

The backend Sales Contract API contract (`/api/v1/sales/contracts`) enforces:
1. `POST /api/v1/sales/proposals/:id/contract`: The server computes `end_date` as `start_date` + proposal pricing `contract_months`. Client-sent `end_date` is ignored. `contract_template_id` is required.
2. `PUT /api/v1/sales/contracts/:id`: Draft-only in-place update. Accepts `end_date` (optional, for adjusting the draft duration). Does NOT accept `contract_template_id` (locked permanently).
3. Field derivations: `contract_value` is `pricing.total_amount`, `total_visits` is `pricing.total_visits`, and signatory is resolved from customer contacts with `role == 4` (Signatory).

Currently, the mobile client's `ContractFormBottomSheet` and `ContractFormController` prompt for `end_date` during creation, validate `endDate` against `startDate`, send `end_date` in create payloads, and display outdated copy regarding visit frequency and duration.

## Goals / Non-Goals

**Goals:**
- Differentiate payload serialization for creation (`createContractFromProposal`) and editing (`updateContract`):
  - Creation payload: includes `category_id`, `start_date`, `signed_date`, `payment_type_id`, `notes`, `contract_template_id`, optional `first_invoice_date`. Omits `end_date`.
  - Edit payload: includes `category_id`, `start_date`, `signed_date`, `payment_type_id`, `notes`, optional `end_date`, optional `first_invoice_date`. Omits `contract_template_id`.
- Update `ContractFormController`:
  - Enforce `contractTemplateId` only during create mode (`!isEditMode`).
  - Only validate `endDate` when `isEditMode` and `endDate` is provided.
- Update `ContractFormBottomSheet`:
  - Hide "Tanggal Selesai" input field in create mode (`!isEditMode`), displaying helper text that end date is computed automatically from proposal duration.
  - Show "Tanggal Selesai" in edit mode (`isEditMode`) for adjusting draft contracts.
  - Update informational text in form header to match current backend derivation rules.

**Non-Goals:**
- Modifying contract lifecycle actions (`activate`, `suspend`, `terminate`, `cancel`), which already follow the state machine.
- Editing non-draft contracts (already restricted by `status.canEdit`).
- Changing addendum or document workflows.

## Decisions

### 1. Dedicated Serialization Methods in `ContractFormRequestDto`
- **Choice**: Add `toCreateJson()` and `toUpdateJson()` to `ContractFormRequestDto` (or separate methods in repository).
- **Details**:
  - `toCreateJson()`:
    ```dart
    {
      'category_id': categoryId,
      'start_date': startDate,
      'signed_date': signedDate,
      'payment_type_id': paymentTypeId,
      'notes': notes,
      'contract_template_id': contractTemplateId,
      if (firstInvoiceDate != null && firstInvoiceDate!.isNotEmpty)
        'first_invoice_date': firstInvoiceDate,
    }
    ```
  - `toUpdateJson()`:
    ```dart
    {
      'category_id': categoryId,
      'start_date': startDate,
      'signed_date': signedDate,
      'payment_type_id': paymentTypeId,
      'notes': notes,
      if (endDate != null && endDate!.isNotEmpty) 'end_date': endDate,
      if (firstInvoiceDate != null && firstInvoiceDate!.isNotEmpty)
        'first_invoice_date': firstInvoiceDate,
    }
    ```
- **Rationale**: Keeps DTO clean and guarantees that creation never sends `end_date` and update never sends `contract_template_id`.

### 2. Conditional Display of "Tanggal Selesai"
- **Choice**: Display the `TextFormField` for "Tanggal Selesai" only when `!isCreateMode` (i.e. `isEditMode`).
- **Rationale**: Prevents users from inputting a date during proposal conversion that would be silently ignored by the server, eliminating user confusion.

### 3. Clear Helper Explanations
- **Choice**: Update the info container at the top of `ContractFormBottomSheet`:
  - "• Nilai kontrak & total kunjungan disalin otomatis dari kalkulasi harga proposal."
  - "• Tanggal selesai dihitung otomatis dari durasi kontrak pada harga proposal (tanggal mulai + durasi bulan)."
  - "• Penandatangan disalin otomatis dari kontak Pelanggan dengan peran Penandatangan."

## Risks / Trade-offs

- **[Risk] User wants to customize end date immediately on creation** → Explain in helper text that the initial end date derives from the accepted proposal duration, and can be edited afterward while the contract is in draft status.
- **[Risk] Existing unit / widget tests for contract form** → Update tests in `test/modules/sales/views/widgets/contract_form_bottom_sheet_test.dart` and controller tests to reflect the create vs edit field visibility.

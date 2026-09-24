## Context

See `proposal.md` for motivation. The data models (`Contract`, `ContractDetailDto`, `ContractFormInput`, and `ContractFormRequestDto`) already preserve and transfer `firstInvoiceDate` to and from the backend API. The current limitation is exclusively within the presentation layer:
1. `ContractDetailPane` renders a `Wrap` containing `TANGGAL MULAI`, `TANGGAL SELESAI`, and `TANGGAL TTD`, but lacks a section for `firstInvoiceDate`.
2. `ContractFormBottomSheet` contains a `TextFormField` bound to `_firstInvoiceDateCtrl` without a clear control, making it impossible to deselect the date once chosen.

## Goals / Non-Goals

**Goals:**
- Render `firstInvoiceDate` in `ContractDetailPane` whenever it is present on the contract.
- Provide a clear button on the `first_invoice_date` input in `ContractFormBottomSheet` allowing users to clear or unset the date.

**Non-Goals:**
- Adding invoice date properties to Proposal entities or views (backend proposals do not have this property).
- Modifying repositories, DTOs, or database schemas.

## Decisions

### 1. Placement in ContractDetailPane
- **Choice**: Display `TANGGAL INVOICE PERTAMA` alongside the existing date fields in the dates `Wrap` section:
  ```dart
  if (c.firstInvoiceDate != null && c.firstInvoiceDate!.isNotEmpty)
    _buildInfoSection('TANGGAL INVOICE PERTAMA', c.firstInvoiceDate!),
  ```
- **Rationale**: Keeps all temporal and milestone dates grouped cleanly. Omitting it when null avoids cluttering contracts that do not have an invoice schedule.
- **Alternatives considered**:
  - Always show with `-`: Takes up card space for simple or non-scheduled contracts. Conditional display matches how `signedDate` is handled.

### 2. Clear Action in ContractFormBottomSheet
- **Choice**: Provide an `IconButton(icon: Icon(Icons.clear))` as suffix when `_firstInvoiceDateCtrl.text` is not empty, alongside or in place of the calendar icon. Tapping clear sets `_firstInvoiceDateCtrl.clear()` and calls `_controller.updateFields(firstInvoiceDate: null)`.
- **Rationale**: The field is optional, so users who accidentally pick a date or want to revert an existing date need a clear control.

## Risks / Trade-offs

- **[Risk] Null vs Empty string serialization** → The DTO already checks `if (firstInvoiceDate != null && firstInvoiceDate!.isNotEmpty)` before adding to payload. When clearing, setting it to `null` or `""` will correctly omit it from the payload or send empty to clear on `PUT`.

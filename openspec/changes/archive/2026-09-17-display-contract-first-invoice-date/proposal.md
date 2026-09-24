## Why

The backend Sales Contract API already provides and persists `first_invoice_date` on contracts (both during creation from proposal and draft updates). While `centrow-sales` has already wired this field in its DTOs, entities, and bottom sheet form, the contract detail pane (`ContractDetailPane`) does not render `firstInvoiceDate`, preventing sales users from viewing when the first invoice is scheduled. In addition, the contract creation/update form does not provide a way to clear an optionally selected first invoice date.

## What Changes

- Display **Tanggal Invoice Pertama** (`firstInvoiceDate`) in `ContractDetailPane` within the contract dates section if set, or appropriately indicated.
- Provide a clear button / action on the optional `first_invoice_date` input in `ContractFormBottomSheet` so users can unset/clear the date before submitting.

## Capabilities

### New Capabilities
- `contract-detail`: Covers the presentation of contract timeline and billing dates (start date, end date, signed date, and first invoice date) in the contract detail pane, as well as date clearing interaction in the contract form.

### Modified Capabilities
<!-- None -->

## Impact

- **Affected files**:
  - `lib/modules/sales/views/widgets/contract_detail_pane.dart`: Add `TANGGAL INVOICE PERTAMA` to the information section.
  - `lib/modules/sales/views/widgets/contract_form_bottom_sheet.dart`: Add clear icon/action to `_firstInvoiceDateCtrl` when not empty.
- **Dependencies & APIs**: No backend API or DTO changes required; backend already supports `first_invoice_date`.

## 1. Detail View Presentation

- [x] 1.1 Add `TANGGAL INVOICE PERTAMA` info section to `ContractDetailPane` in `lib/modules/sales/views/widgets/contract_detail_pane.dart` and verify it renders when `firstInvoiceDate` is present
- [x] 1.2 Verify that contracts without `firstInvoiceDate` render cleanly without errors or awkward spacing in `ContractDetailPane`

## 2. Form Input Enhancements

- [x] 2.1 Add clear button/suffix action to `_firstInvoiceDateCtrl` in `ContractFormBottomSheet` (`lib/modules/sales/views/widgets/contract_form_bottom_sheet.dart`) and verify tapping it clears the date and updates `ContractFormController`
- [x] 2.2 Verify contract creation and update payloads when `firstInvoiceDate` is selected vs cleared

## 3. Verification & Quality

- [x] 3.1 Run `rtk flutter analyze` and verify that the codebase passes with zero analysis issues

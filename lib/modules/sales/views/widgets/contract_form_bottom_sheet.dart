import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_form_controller.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/entities/contract_category.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_typography.dart';
import 'package:centrow_sales/shared/widgets/app_dropdown.dart';
import 'package:centrow_sales/shared/widgets/app_searchable_selector.dart';
import 'package:centrow_sales/shared/widgets/toast.dart';

class ContractFormBottomSheet extends StatefulWidget {
  final String? proposalId;
  final String? proposalCode;
  final String? customerName;
  final String? serviceName;
  final double? prefilledContractValue;
  final int? prefilledTotalVisits;
  final Contract? initialContract;

  const ContractFormBottomSheet({
    super.key,
    this.proposalId,
    this.proposalCode,
    this.customerName,
    this.serviceName,
    this.prefilledContractValue,
    this.prefilledTotalVisits,
    this.initialContract,
  });

  @override
  State<ContractFormBottomSheet> createState() =>
      _ContractFormBottomSheetState();
}

class _ContractFormBottomSheetState extends State<ContractFormBottomSheet> {
  late final ContractFormController _controller;
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();
  final _signedDateCtrl = TextEditingController();
  final _firstInvoiceDateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = getIt<ContractFormController>();
    if (widget.initialContract != null) {
      _controller.initFromContract(widget.initialContract!);
      _startDateCtrl.text = widget.initialContract!.startDate;
      if (widget.initialContract!.endDate != null) {
        _endDateCtrl.text = widget.initialContract!.endDate!;
      }
      if (widget.initialContract!.signedDate != null) {
        _signedDateCtrl.text = widget.initialContract!.signedDate!;
      }
      if (widget.initialContract!.firstInvoiceDate != null) {
        _firstInvoiceDateCtrl.text = widget.initialContract!.firstInvoiceDate!;
      }
      if (widget.initialContract!.notes != null) {
        _notesCtrl.text = widget.initialContract!.notes!;
      }
    } else {
      _controller.initFromProposal(
        proposalId: widget.proposalId ?? '',
        proposalCode: widget.proposalCode ?? '',
        customerName: widget.customerName ?? '',
        serviceName: widget.serviceName ?? '',
        prefilledValue: widget.prefilledContractValue,
        prefilledVisits: widget.prefilledTotalVisits,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _signedDateCtrl.dispose();
    _firstInvoiceDateCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    TextEditingController ctrl,
    void Function(String) onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final s =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      ctrl.text = s;
      onPicked(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final bool isCreateMode = !_controller.isEditMode;
            final bool templatesUnavailable =
                isCreateMode &&
                _controller.selectedCategory != null &&
                _controller.selectedCategory!.templates.isEmpty;
            final bool canSubmit = !isCreateMode || !templatesUnavailable;

            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
                left: 24.0,
                right: 24.0,
                top: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderStrong,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _controller.isEditMode
                            ? 'Ubah Kontrak'
                            : 'Buat Kontrak',
                        style: AppTypography.heading2(),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.sec,
                        ),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_controller.proposalCode != null &&
                      _controller.proposalCode!.isNotEmpty)
                    Text(
                      'Dari Penawaran ${_controller.proposalCode}',
                      style: AppTypography.bodySm(color: AppColors.muted),
                    ),
                  Text(
                    '${_controller.prefilledCustomerName ?? ''} · ${_controller.prefilledServiceName ?? ''}',
                    style: AppTypography.bodySm(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Information Banner about Pricing & Signatory
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppColors.subtle,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Otomatis:',
                          style: AppTypography.bodySm(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Nilai kontrak & frekuensi kunjungan disalin otomatis dari kalkulasi harga proposal.\n• Penandatangan disalin otomatis dari kontak Pelanggan dengan peran Penandatangan.',
                          style: AppTypography.caption(color: AppColors.sec),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 1. Kategori Kontrak *
                  AppSearchableSelector<ContractCategory>(
                    label: 'Kategori Kontrak *',
                    hint: 'Pilih kategori…',
                    value: _controller.selectedCategory,
                    onSearch: _controller.searchCategories,
                    itemAsString: (cat) => cat.name,
                    onChanged: (cat) => _controller.updateFields(category: cat),
                    isRequired: true,
                  ),
                  if (isCreateMode && _controller.selectedCategory != null) ...[
                    const SizedBox(height: 16),
                    if (_controller.selectedCategory!.templates.isNotEmpty)
                      AppDropdown<String>(
                        label: 'Template Kontrak',
                        isRequired: true,
                        value: _controller.contractTemplateId,
                        items: _controller.selectedCategory!.templates
                            .map(
                              (t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(
                                  t.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            _controller.selectContractTemplate(val),
                      )
                    else
                      Text(
                        'Template kontrak tidak tersedia untuk kategori ini',
                        style: AppTypography.bodySm(color: AppColors.err),
                      ),
                  ],
                  const SizedBox(height: 16),

                  // 2. Tanggal Mulai *
                  TextFormField(
                    controller: _startDateCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Mulai *',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => _pickDate(
                      _startDateCtrl,
                      (v) => _controller.updateFields(startDate: v),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Tanggal Selesai (optional)
                  TextFormField(
                    controller: _endDateCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Selesai',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => _pickDate(
                      _endDateCtrl,
                      (v) => _controller.updateFields(endDate: v),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Tanggal Penandatanganan *
                  TextFormField(
                    controller: _signedDateCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Penandatanganan *',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => _pickDate(
                      _signedDateCtrl,
                      (v) => _controller.updateFields(signedDate: v),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Tanggal Invoice Pertama (optional)
                  TextFormField(
                    controller: _firstInvoiceDateCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Invoice Pertama',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => _pickDate(
                      _firstInvoiceDateCtrl,
                      (v) => _controller.updateFields(firstInvoiceDate: v),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. Tipe Pembayaran *
                  AppDropdown<ContractPaymentType>(
                    label: 'Tipe Pembayaran *',
                    value: _controller.paymentType,
                    items: ContractPaymentType.values
                        .map(
                          (pt) => DropdownMenuItem(
                            value: pt,
                            child: Text(pt.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (pt) {
                      if (pt != null) {
                        _controller.updateFields(paymentType: pt);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // 7. Catatan *
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Catatan *',
                      alignLabelWithHint: true,
                    ),
                    onChanged: (v) => _controller.updateFields(notes: v),
                  ),
                  const SizedBox(height: 32),

                  // Submit
                  ElevatedButton(
                    onPressed: (_controller.isSubmitting || !canSubmit)
                        ? null
                        : () async {
                            final result = await _controller.submit();
                            if (!context.mounted) return;
                            if (result.isOk) {
                              context.pop(result.valueOrNull);
                            } else {
                              showAppToast(
                                context,
                                result.failureOrNull!.message,
                                isError: true,
                              );
                            }
                          },
                    child: _controller.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _controller.isEditMode
                                ? 'Simpan Perubahan'
                                : 'Buat Kontrak',
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

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
  final String proposalId;
  final String proposalCode;
  final String customerName;
  final String serviceName;
  final double? prefilledContractValue;
  final int? prefilledTotalVisits;

  const ContractFormBottomSheet({
    super.key,
    required this.proposalId,
    required this.proposalCode,
    required this.customerName,
    required this.serviceName,
    this.prefilledContractValue,
    this.prefilledTotalVisits,
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
  final _contractValueCtrl = TextEditingController();
  final _signatoryNameCtrl = TextEditingController();
  final _signatoryPosCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = getIt<ContractFormController>();
    _controller.initFromProposal(
      proposalId: widget.proposalId,
      proposalCode: widget.proposalCode,
      customerName: widget.customerName,
      serviceName: widget.serviceName,
      prefilledValue: widget.prefilledContractValue,
      prefilledVisits: widget.prefilledTotalVisits,
    );
    if (widget.prefilledContractValue != null) {
      _contractValueCtrl.text = widget.prefilledContractValue!.toStringAsFixed(
        0,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _signedDateCtrl.dispose();
    _contractValueCtrl.dispose();
    _signatoryNameCtrl.dispose();
    _signatoryPosCtrl.dispose();
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
                      Text('Buat Kontrak', style: AppTypography.heading2()),
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
                  Text(
                    'Dari Penawaran ${widget.proposalCode}',
                    style: AppTypography.bodySm(color: AppColors.muted),
                  ),
                  Text(
                    '${widget.customerName} · ${widget.serviceName}',
                    style: AppTypography.bodySm(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category picker (required)
                  AppSearchableSelector<ContractCategory>(
                    label: 'Kategori Kontrak *',
                    hint: 'Pilih kategori…',
                    value: _controller.selectedCategory,
                    onSearch: _controller.searchCategories,
                    itemAsString: (cat) => cat.name,
                    onChanged: (cat) => _controller.updateFields(category: cat),
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  // Start date (required)
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

                  // End date (optional)
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

                  // Signed date (optional)
                  TextFormField(
                    controller: _signedDateCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal TTD',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => _pickDate(
                      _signedDateCtrl,
                      (v) => _controller.updateFields(signedDate: v),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contract value
                  TextFormField(
                    controller: _contractValueCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nilai Kontrak (Rp)',
                      prefixText: 'Rp ',
                    ),
                    onChanged: (v) {
                      final parsed = double.tryParse(v.replaceAll('.', ''));
                      _controller.updateFields(contractValue: parsed);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Payment type dropdown
                  AppDropdown<ContractPaymentType>(
                    label: 'Tipe Pembayaran',
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

                  // Signatory name
                  TextFormField(
                    controller: _signatoryNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Penandatangan',
                    ),
                    onChanged: (v) =>
                        _controller.updateFields(signatoryName: v),
                  ),
                  const SizedBox(height: 16),

                  // Signatory position
                  TextFormField(
                    controller: _signatoryPosCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Jabatan Penandatangan',
                    ),
                    onChanged: (v) =>
                        _controller.updateFields(signatoryPosition: v),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Catatan',
                      alignLabelWithHint: true,
                    ),
                    onChanged: (v) => _controller.updateFields(notes: v),
                  ),
                  const SizedBox(height: 32),

                  // Submit
                  ElevatedButton(
                    onPressed: _controller.isSubmitting
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
                        : const Text('Buat Kontrak'),
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

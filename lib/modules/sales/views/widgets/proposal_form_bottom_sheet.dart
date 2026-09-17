import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/proposal_form_controller.dart';
import 'package:centrow_sales/shared/widgets/app_searchable_selector.dart';
import 'package:centrow_sales/shared/widgets/app_dropdown.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/entities/service.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';

import 'package:centrow_sales/shared/theme/app_typography.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';

class ProposalFormBottomSheet extends StatefulWidget {
  final String? customerId;
  final Proposal? initialProposal;
  final bool isReviseMode;

  const ProposalFormBottomSheet({
    super.key,
    this.customerId,
    this.initialProposal,
    this.isReviseMode = false,
  });

  @override
  State<ProposalFormBottomSheet> createState() =>
      _ProposalFormBottomSheetState();
}

class _ProposalFormBottomSheetState extends State<ProposalFormBottomSheet> {
  late final ProposalFormController _controller;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _validUntilController = TextEditingController();
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _controller = getIt<ProposalFormController>();
    _notesController = TextEditingController();

    if (widget.initialProposal != null) {
      if (widget.isReviseMode) {
        _controller.initForRevise(widget.initialProposal!);
      } else {
        _controller.initForEdit(widget.initialProposal!);
      }
      _dateController.text = widget.initialProposal!.date;
      if (widget.initialProposal!.validUntil.isNotEmpty) {
        _validUntilController.text = widget.initialProposal!.validUntil;
      }
      _notesController.text = widget.initialProposal!.notes ?? '';
    } else if (widget.customerId != null) {
      _controller.customerId = widget.customerId;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _controller.dispose();
    _dateController.dispose();
    _validUntilController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    ValueChanged<String> onSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final dateString =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      controller.text = dateString;
      onSelected(dateString);
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
          builder: (context, child) {
            final bool isCreateMode =
                !_controller.isEditMode && !_controller.isReviseMode;
            final bool templatesUnavailable =
                isCreateMode &&
                _controller.selectedService != null &&
                !_controller.isLoadingTemplates &&
                _controller.availableTemplates.isEmpty;
            final bool canSubmit =
                !isCreateMode ||
                (!_controller.isLoadingTemplates && !templatesUnavailable);

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
                        _controller.isReviseMode
                            ? 'Revisi Proposal'
                            : (_controller.isEditMode
                                  ? 'Ubah Proposal'
                                  : 'Buat Proposal Baru'),
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
                  const SizedBox(height: 24),
                  AppSearchableSelector<Customer>(
                    label: 'Pelanggan',
                    enabled:
                        !_controller.isEditMode && !_controller.isReviseMode,
                    value: _controller.selectedCustomer,
                    onSearch: _controller.searchCustomers,
                    itemAsString: (c) =>
                        c.code.isNotEmpty ? '[${c.code}] ${c.name}' : c.name,
                    onChanged: (c) => _controller.updateFields(customer: c),
                  ),
                  const SizedBox(height: 16),
                  AppSearchableSelector<Service>(
                    label: 'Layanan',
                    enabled:
                        !_controller.isEditMode && !_controller.isReviseMode,
                    value: _controller.selectedService,
                    onSearch: _controller.searchServices,
                    itemAsString: (s) =>
                        s.code.isNotEmpty ? '[${s.code}] ${s.name}' : s.name,
                    onChanged: (s) => _controller.updateFields(service: s),
                  ),
                  if (isCreateMode && _controller.selectedService != null) ...[
                    const SizedBox(height: 16),
                    if (_controller.isLoadingTemplates)
                      Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Memuat template proposal…',
                            style: AppTypography.bodySm(color: AppColors.sec),
                          ),
                        ],
                      )
                    else if (_controller.availableTemplates.isNotEmpty)
                      AppDropdown<String>(
                        label: 'Template Proposal',
                        isRequired: true,
                        value: _controller.templateId,
                        items: _controller.availableTemplates
                            .map(
                              (t) => DropdownMenuItem(
                                value: t.value,
                                child: Text(
                                  t.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => _controller.selectTemplate(val),
                      )
                    else
                      Text(
                        'Template proposal tidak tersedia untuk layanan ini',
                        style: AppTypography.bodySm(color: AppColors.err),
                      ),
                  ],
                  const SizedBox(height: 16),
                  AppDropdown<String>(
                    label: 'Lokasi',
                    value: _controller.addressId,
                    items: _controller.availableLocations
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.id,
                            child: Text(
                              l.label.isNotEmpty
                                  ? '${l.label} - ${l.address}'
                                  : l.address,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      _controller.updateFields(addressId: val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Proposal',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => _selectDate(
                      context,
                      _dateController,
                      (val) => _controller.updateFields(proposalDate: val),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _validUntilController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Berlaku Hingga',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => _selectDate(
                      context,
                      _validUntilController,
                      (val) => _controller.updateFields(validUntil: val),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Proposal',
                      alignLabelWithHint: true,
                    ),
                    onChanged: (val) => _controller.updateFields(notes: val),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: !canSubmit
                        ? null
                        : () async {
                            final result = await _controller.submit();
                            if (result.isOk && context.mounted) {
                              context.pop(result.valueOrNull);
                            } else if (result.isErr && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result.failureOrNull!.message),
                                ),
                              );
                            }
                          },
                    child: Text(
                      _controller.isReviseMode
                          ? 'Simpan Revisi'
                          : (_controller.isEditMode
                                ? 'Simpan Perubahan'
                                : 'Buat Proposal'),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/proposal_form_controller.dart';
import 'package:centrow_sales/shared/widgets/app_searchable_selector.dart';
import 'package:centrow_sales/shared/widgets/app_dropdown.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/entities/service.dart';

import 'package:centrow_sales/shared/theme/app_typography.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';

class ProposalFormBottomSheet extends StatefulWidget {
  final String? customerId;

  const ProposalFormBottomSheet({super.key, this.customerId});

  @override
  State<ProposalFormBottomSheet> createState() =>
      _ProposalFormBottomSheetState();
}

class _ProposalFormBottomSheetState extends State<ProposalFormBottomSheet> {
  late final ProposalFormController _controller;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _validUntilController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = getIt<ProposalFormController>();
    if (widget.customerId != null) {
      _controller.customerId = widget.customerId;
    }
  }

  @override
  void dispose() {
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
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
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
                    Text('Buat Proposal Baru', style: AppTypography.heading2()),
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
                  value: null,
                  onSearch: _controller.searchCustomers,
                  itemAsString: (c) => c.name,
                  onChanged: (c) => _controller.updateFields(customerId: c?.id),
                ),
                const SizedBox(height: 16),
                AppSearchableSelector<Service>(
                  label: 'Layanan',
                  value: null,
                  onSearch: _controller.searchServices,
                  itemAsString: (s) => s.name,
                  onChanged: (s) => _controller.updateFields(serviceId: s?.id),
                ),
                const SizedBox(height: 16),
                AppDropdown<String>(
                  label: 'Lokasi',
                  value: null,
                  items: _controller.availableLocations
                      .map(
                        (l) => DropdownMenuItem(
                          value: l.id,
                          child: Text(l.address),
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
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    final result = await _controller.submit();
                    if (result.isOk && context.mounted) {
                      context.pop(true);
                    } else if (result.isErr && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result.failureOrNull!.message)),
                      );
                    }
                  },
                  child: const Text('Buat Proposal'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

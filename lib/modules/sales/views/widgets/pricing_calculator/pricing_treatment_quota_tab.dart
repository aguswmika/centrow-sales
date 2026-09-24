import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_badge.dart';
import 'package:centrow_sales/shared/widgets/counter_input.dart';
import 'package:centrow_sales/modules/pc/entities/treatment_method.dart';
import 'package:centrow_sales/modules/pc/repositories/treatment_method_repository.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/views/widgets/treatment_method_picker_sheet.dart';
import 'pricing_utils.dart';

class PricingTreatmentQuotaTab extends StatelessWidget {
  final PricingCalculatorController controller;
  final bool isReadOnly;

  const PricingTreatmentQuotaTab({
    super.key,
    required this.controller,
    this.isReadOnly = false,
  });

  Future<void> _handleAddMethod(BuildContext context) async {
    final method = await showModalBottomSheet<TreatmentMethod>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const TreatmentMethodPickerSheet(),
    );
    if (method != null && context.mounted) {
      controller.addTreatmentQuota(method);
    }
  }

  Future<void> _handlePopulateRequired(BuildContext context) async {
    controller.populateFromSupplies();
    if (controller.treatmentQuotas.isEmpty) {
      await controller.populateRequiredMethodsFromRepo();
      if (controller.treatmentQuotas.isEmpty &&
          getIt.isRegistered<TreatmentMethodRepository>()) {
        final repo = getIt<TreatmentMethodRepository>();
        final res = await repo.getTreatmentMethods();
        if (res is Ok<List<TreatmentMethod>>) {
          controller.populateRequiredMethods(res.value);
        }
      }
    }
  }

  Widget _buildAutoFillBtn(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: AppRadius.borderSm,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: AppColors.brand, size: 16.0),
            SizedBox(width: 8.0),
            Text(
              'Isi Metode Wajib',
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: AppColors.brand,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final rows = controller.treatmentQuotas;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildTableHeader(
              ['Metode Treatment', 'Kuota Visit', ''],
              flexes: const [5, 3],
            ),
            if (rows.isEmpty)
              Container(
                padding: const EdgeInsets.all(24.0),
                color: AppColors.surface,
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_turned_in_outlined,
                        size: 40.0,
                        color: AppColors.muted.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Belum ada kuota treatment.',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sec,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      const Text(
                        'Tambahkan metode atau gunakan "Isi Metode Wajib" untuk mengisi kuota standar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            for (final row in rows)
              PricingTreatmentQuotaRowWidget(
                key: ObjectKey(row),
                row: row,
                controller: controller,
                isReadOnly: isReadOnly,
              ),
            if (!isReadOnly)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: AppColors.subtle,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children: [
                    buildAddBtn(
                      'Tambah Metode',
                      () => _handleAddMethod(context),
                    ),
                    _buildAutoFillBtn(() => _handlePopulateRequired(context)),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class PricingTreatmentQuotaRowWidget extends StatelessWidget {
  final PricingTreatmentQuotaRow row;
  final PricingCalculatorController controller;
  final bool isReadOnly;

  const PricingTreatmentQuotaRowWidget({
    super.key,
    required this.row,
    required this.controller,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (row.treatmentMethodCode.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 3.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brand05,
                          border: Border.all(color: AppColors.brand10),
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: Text(
                          row.treatmentMethodCode,
                          style: const TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brand,
                          ),
                        ),
                      ),
                    if (row.isRequired) const AppBadge.warn(text: 'Wajib'),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  row.treatmentMethodName,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            flex: 3,
            child: SignalBuilder(
              builder: (context) {
                return CounterInput(
                  initialValue: row.quota.value.toDouble(),
                  min: 1,
                  enabled: !isReadOnly,
                  onChanged: (val) {
                    row.quota.value = val.toInt();
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 8.0),
          if (!isReadOnly)
            SizedBox(
              width: 30.0,
              height: 30.0,
              child: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.muted,
                  size: 18.0,
                ),
                tooltip: 'Hapus',
                onPressed: () {
                  controller.removeTreatmentQuota(row.treatmentMethodId);
                },
              ),
            )
          else
            const SizedBox(width: 30.0),
        ],
      ),
    );
  }
}

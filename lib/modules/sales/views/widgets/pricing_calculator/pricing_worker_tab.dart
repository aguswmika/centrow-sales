import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/entities/product.dart';
import 'package:centrow_sales/modules/sales/views/widgets/product_picker_sheet.dart';
import 'package:centrow_sales/shared/widgets/counter_input.dart';
import 'pricing_utils.dart';

class PricingWorkerTab extends StatelessWidget {
  final PricingCalculatorController controller;
  final bool isReadOnly;

  const PricingWorkerTab({
    super.key,
    required this.controller,
    this.isReadOnly = false,
  });

  Future<void> _handleAddWorker(BuildContext context) async {
    final result = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ProductPickerSheet(kind: 4),
    );
    if (result != null && context.mounted) {
      controller.addRow(result, 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final rows = controller.workers;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildTableHeader(
              [
                'Posisi & Peran Teknisi',
                'Kunjungan',
                'Menit Awal',
                'Menit Routine',
                '',
              ],
              flexes: const [4, 2, 2, 2],
            ),
            for (final row in rows)
              PricingWorkerRowWidget(
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
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: buildAddBtn(
                    'Tambah Teknisi',
                    () => _handleAddWorker(context),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class PricingWorkerRowWidget extends StatelessWidget {
  final PricingWorkerRow row;
  final PricingCalculatorController controller;
  final bool isReadOnly;

  const PricingWorkerRowWidget({
    super.key,
    required this.row,
    required this.controller,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
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
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (row.code.isNotEmpty) ...[
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
                          row.code,
                          style: const TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brand,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                    ],
                    Text(
                      row.title,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                flex: 2,
                child: CounterInput(
                  initialValue: row.visitFreq.value,
                  min: 1,
                  enabled: !isReadOnly,
                  onChanged: (val) {
                    row.visitFreq.value = val;
                  },
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                flex: 2,
                child: CounterInput(
                  initialValue: row.firstVisitMinutes.value,
                  min: 0,
                  enabled: !isReadOnly,
                  onChanged: (val) {
                    row.firstVisitMinutes.value = val;
                  },
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                flex: 2,
                child: CounterInput(
                  initialValue: row.routineMinutes.value,
                  min: 0,
                  enabled: !isReadOnly,
                  onChanged: (val) {
                    row.routineMinutes.value = val;
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
                    onPressed: () {
                      controller.workers.remove(row);
                    },
                  ),
                )
              else
                const SizedBox(width: 30.0),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/entities/product.dart';
import 'package:centrow_sales/modules/sales/views/widgets/product_picker_sheet.dart';
import 'package:centrow_sales/shared/widgets/counter_input.dart';
import 'pricing_utils.dart';

class PricingItemTab extends StatelessWidget {
  final PricingCalculatorController controller;
  final bool isReadOnly;

  const PricingItemTab({
    super.key,
    required this.controller,
    this.isReadOnly = false,
  });

  Future<void> _handleAddItem(BuildContext context, int kind) async {
    final result = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProductPickerSheet(kind: kind),
    );
    if (result != null && context.mounted) {
      controller.addRow(result, kind);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final rows = controller.items;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildTableHeader(
              ['Komponen & Jenis Biaya', 'Jumlah', 'Frekuensi', 'Harga', ''],
              flexes: const [4, 2, 2, 3],
            ),
            for (final row in rows)
              PricingItemRowWidget(
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
                child: Row(
                  children: [
                    buildAddBtn('BBM', () => _handleAddItem(context, 3)),
                    const SizedBox(width: 12.0),
                    buildAddBtn('Add-on', () => _handleAddItem(context, 5)),
                    const SizedBox(width: 12.0),
                    buildAddBtn(
                      'Item Kustom',
                      () => controller.addCustomItem(),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class PricingItemRowWidget extends StatelessWidget {
  final PricingItemRow row;
  final PricingCalculatorController controller;
  final bool isReadOnly;

  const PricingItemRowWidget({
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
                child: row.kind == 0
                    ? Container(
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: !isReadOnly
                              ? AppColors.subtle
                              : AppColors.border.withValues(alpha: 0.3),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: TextFormField(
                          initialValue: row.title.value,
                          enabled: !isReadOnly,
                          onChanged: (val) => row.title.value = val,
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                            color: !isReadOnly
                                ? AppColors.text
                                : AppColors.muted,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Nama item kustom...',
                            hintStyle: TextStyle(
                              fontSize: 13.0,
                              color: AppColors.muted,
                            ),
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 10.0,
                            ),
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        ),
                      )
                    : Column(
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
                            row.title.value,
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
                  initialValue: row.qty.value,
                  min: 1,
                  enabled: !isReadOnly,
                  onChanged: (val) {
                    row.qty.value = val;
                  },
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                flex: 2,
                child: CounterInput(
                  initialValue: row.freq.value,
                  min: 1,
                  enabled: !isReadOnly,
                  onChanged: (val) {
                    row.freq.value = val;
                  },
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                flex: 3,
                child: (row.kind == 5 || row.kind == 0)
                    ? buildInput(
                        row.unitPrice.value % 1 == 0
                            ? row.unitPrice.value.toInt().toString()
                            : row.unitPrice.value.toString(),
                        (val) {
                          row.unitPrice.value = double.tryParse(val) ?? 0.0;
                        },
                        enabled: !isReadOnly,
                      )
                    : Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            formatRp(row.unitPrice.value),
                            style: const TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                        ),
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
                      controller.items.remove(row);
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

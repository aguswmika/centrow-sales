import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/counter_input.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/entities/product.dart';
import 'package:centrow_sales/modules/pc/entities/product_mapping.dart';
import 'package:centrow_sales/modules/pc/entities/treatment_method.dart';
import 'package:centrow_sales/modules/sales/views/widgets/product_picker_sheet.dart';
import 'package:centrow_sales/modules/sales/views/widgets/product_mapping_picker_sheet.dart';
import 'package:centrow_sales/modules/sales/views/widgets/treatment_method_picker_sheet.dart';
import 'pricing_utils.dart';

class PricingMaterialTab extends StatelessWidget {
  final PricingCalculatorController controller;

  const PricingMaterialTab({super.key, required this.controller});

  Future<void> _handleAddMaterial(BuildContext context) async {
    final method = await showModalBottomSheet<TreatmentMethod>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const TreatmentMethodPickerSheet(),
    );
    if (method == null) return;
    if (!context.mounted) return;

    final mapping = await showModalBottomSheet<ProductMapping>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProductMappingPickerSheet(treatmentMethodId: method.id),
    );
    if (mapping != null && context.mounted) {
      controller.addMaterialRow(mapping);
    }
  }

  Future<void> _handleAddTool(BuildContext context) async {
    final result = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ProductPickerSheet(kind: 2),
    );
    if (result != null && context.mounted) {
      controller.addRow(result, 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final rows = controller.materials;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildTableHeader(
              [
                'Nama',
                'Dosis (unit)',
                'Volume Pengaplikasian (unit)',
                'Frekuensi',
                'Biaya',
                'Total Biaya',
                '',
              ],
              flexes: const [3, 3, 3, 1, 2, 2],
            ),
            for (final row in rows)
              PricingMaterialRowWidget(
                row: row,
                controller: controller,
                hasUnitColumn: true,
              ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: AppColors.subtle,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  buildAddBtn(
                    'Tambah Bahan Kimia',
                    () => _handleAddMaterial(context),
                  ),
                  const SizedBox(width: 12.0),
                  buildAddBtn('Tambah Alat', () => _handleAddTool(context)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class PricingMaterialRowWidget extends StatelessWidget {
  final PricingMaterialRow row;
  final PricingCalculatorController controller;
  final bool hasUnitColumn;

  const PricingMaterialRowWidget({
    super.key,
    required this.row,
    required this.controller,
    this.hasUnitColumn = false,
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
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                if (row.code.isNotEmpty) ...[
                  const SizedBox(height: 4.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.0,
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
                ],
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: CounterInput(
                    initialValue: row.doseUsage.value,
                    onChanged: (val) {
                      row.doseUsage.value = val;
                    },
                  ),
                ),
                if (hasUnitColumn) ...[
                  const SizedBox(width: 4.0),
                  Text(
                    row.uomCode,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: CounterInput(
                    initialValue: row.applicationVolume.value,
                    onChanged: (val) {
                      row.applicationVolume.value = val;
                    },
                  ),
                ),
                if (hasUnitColumn) ...[
                  const SizedBox(width: 4.0),
                  SignalBuilder(
                    builder: (context) {
                      final items = controller.uoms;
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: row.applicationVolumeUnitId.value.isEmpty
                              ? null
                              : row.applicationVolumeUnitId.value,
                          isDense: true,
                          hint: const Text(
                            'Unit',
                            style: TextStyle(fontSize: 11.0),
                          ),
                          icon: const Icon(Icons.arrow_drop_down, size: 16),
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                          items: items.map((uom) {
                            return DropdownMenuItem<String>(
                              value: uom.id,
                              child: Text(uom.code),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              row.applicationVolumeUnitId.value = val;
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: buildInput(row.freq.value.toString(), (val) {
              row.freq.value = double.tryParse(val) ?? 0.0;
            }),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  formatRp(row.unitCost.value),
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            flex: 2,
            child: SignalBuilder(
              builder: (context) {
                return buildTotalAmount(formatRp(row.total.value));
              },
            ),
          ),
          const SizedBox(width: 8.0),
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
                controller.materials.remove(row);
              },
            ),
          ),
        ],
      ),
    );
  }
}

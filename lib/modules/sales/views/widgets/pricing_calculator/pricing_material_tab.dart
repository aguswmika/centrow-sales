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
  final bool isReadOnly;

  const PricingMaterialTab({
    super.key,
    required this.controller,
    this.isReadOnly = false,
  });

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
        final chemicals = controller.materials
            .where((m) => m.kind == 1)
            .toList();
        final tools = controller.materials.where((m) => m.kind == 2).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (chemicals.isNotEmpty || tools.isEmpty) ...[
              buildTableHeader(
                [
                  'Bahan Kimia',
                  'Dosis (unit)',
                  'Volume Pengaplikasian (unit)',
                  'Frekuensi',
                  '',
                ],
                flexes: const [4, 3, 3, 2],
              ),
              for (final row in chemicals)
                PricingMaterialRowWidget(
                  key: ObjectKey(row),
                  row: row,
                  controller: controller,
                  hasUnitColumn: true,
                  isReadOnly: isReadOnly,
                ),
            ],
            if (tools.isNotEmpty) ...[
              if (chemicals.isNotEmpty) const SizedBox(height: 16.0),
              buildTableHeader(
                ['Nama Alat', 'Qty', 'Frekuensi', ''],
                flexes: const [4, 3, 3],
              ),
              for (final row in tools)
                PricingToolRowWidget(
                  key: ObjectKey(row),
                  row: row,
                  controller: controller,
                  isReadOnly: isReadOnly,
                ),
            ],
            if (!isReadOnly)
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
  final bool isReadOnly;

  const PricingMaterialRowWidget({
    super.key,
    required this.row,
    required this.controller,
    this.hasUnitColumn = false,
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
            flex: 4,
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
                if (row.doseMinLimit != null && row.doseMaxLimit != null) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    'Min: ${row.doseMinLimit} - Max: ${row.doseMaxLimit}',
                    style: const TextStyle(
                      fontSize: 11.0,
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
                    initialValue: row.doseUsage.value,
                    min: row.doseMinLimit,
                    max: row.doseMaxLimit,
                    enabled: !isReadOnly,
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
                    enabled: !isReadOnly,
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
                          onChanged: isReadOnly
                              ? null
                              : (val) {
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
            flex: 2,
            child: buildInput(row.freq.value.toString(), (val) {
              row.freq.value = double.tryParse(val) ?? 0.0;
            }, enabled: !isReadOnly),
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
                  controller.materials.remove(row);
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

class PricingToolRowWidget extends StatelessWidget {
  final PricingMaterialRow row;
  final PricingCalculatorController controller;
  final bool isReadOnly;

  const PricingToolRowWidget({
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
            flex: 4,
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
            child: CounterInput(
              initialValue: row.doseUsage.value,
              enabled: !isReadOnly,
              onChanged: (val) {
                row.doseUsage.value = val;
              },
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            flex: 3,
            child: buildInput(row.freq.value.toString(), (val) {
              row.freq.value = double.tryParse(val) ?? 0.0;
            }, enabled: !isReadOnly),
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
                  controller.materials.remove(row);
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

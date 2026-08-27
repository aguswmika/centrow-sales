import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/views/widgets/product_picker_sheet.dart';
import 'package:centrow_sales/modules/sales/views/widgets/product_mapping_picker_sheet.dart';
import 'package:centrow_sales/modules/sales/views/widgets/treatment_method_picker_sheet.dart';
import 'package:centrow_sales/modules/pc/entities/product_mapping.dart';
import 'package:centrow_sales/modules/pc/entities/treatment_method.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/entities/product.dart';

class PricingCalculatorView extends StatefulWidget {
  final Proposal proposal;
  final PricingCalculatorController calculatorController;

  const PricingCalculatorView({
    super.key,
    required this.proposal,
    required this.calculatorController,
  });

  @override
  State<PricingCalculatorView> createState() => _PricingCalculatorViewState();
}

class _PricingCalculatorViewState extends State<PricingCalculatorView> {
  int _activeTab = 0;

  final List<String> _tabTitles = [
    'Persiapan Bahan & Alat',
    'Tenaga Kerja & Teknisi',
    'Transport & Add-on',
  ];

  String _formatRp(double amount) {
    if (amount == 0) return 'Rp 0';
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final intPart = absAmount.truncate();
    final formattedInt = intPart.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return isNegative ? '-Rp $formattedInt' : 'Rp $formattedInt';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTabs(),
              Expanded(
                child: Container(
                  color: AppColors.surface,
                  child: SingleChildScrollView(child: _buildTabContent()),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildSidebar(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTabs(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        color: AppColors.surface,
                        child: _buildTabContent(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 320.0,
              decoration: const BoxDecoration(
                color: AppColors.bg,
                border: Border(
                  left: BorderSide(color: AppColors.border, width: 1.0),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(child: _buildSidebar()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabs() {
    return Watch.builder(
      builder: (context) {
        final List<int> tabCounts = [
          widget.calculatorController.materials.length,
          widget.calculatorController.labors.length,
          widget.calculatorController.items.length,
        ];
        return Container(
          width: double.infinity,
          color: AppColors.subtle,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabTitles.length, (index) {
                final isSelected = index == _activeTab;
                return InkWell(
                  onTap: () => setState(() => _activeTab = index),
                  child: Container(
                    height: 44.0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 0.0,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surface
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? AppColors.brand
                              : Colors.transparent,
                          width: 3.0,
                        ),
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Color(0x08000000),
                                offset: Offset(0, -2),
                                blurRadius: 6.0,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _tabTitles[index],
                          style: GoogleFonts.inter(
                            fontSize: 13.0,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected ? AppColors.brand : AppColors.sec,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.brand10
                                : AppColors.border,
                            borderRadius: AppRadius.borderPill,
                          ),
                          child: Text(
                            tabCounts[index].toString(),
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.brand
                                  : AppColors.sec,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabContent() {
    return Watch.builder(
      builder: (context) {
        switch (_activeTab) {
          case 0:
            final rows = widget.calculatorController.materials;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTableHeader(
                  [
                    'Item & Deskripsi Bahan',
                    'Dosis',
                    'Volume',
                    'Frekuensi',
                    'Satuan',
                    'Biaya Satuan',
                    'Total Biaya',
                    '',
                  ],
                  flexes: const [3, 1, 1, 1, 1, 2, 2],
                ),
                for (final row in rows)
                  _buildTableRow(row, hasUnitColumn: true),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: AppColors.subtle,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      _buildAddBtn('Tambah Bahan Kimia', 1),
                      const SizedBox(width: 12.0),
                      _buildAddBtn('Tambah Alat', 2),
                    ],
                  ),
                ),
              ],
            );
          case 1:
            final rows = widget.calculatorController.labors;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTableHeader(
                  [
                    'Posisi & Peran Teknisi',
                    'Kunjungan',
                    'Jam Awal',
                    'Jam Rutin',
                    'Tarif per Jam',
                    'Total Biaya',
                    '',
                  ],
                  flexes: const [3, 1, 1, 1, 2, 2],
                ),
                for (final row in rows) _buildLaborRow(row),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: AppColors.subtle,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildAddBtn('Tambah Teknisi', 4),
                  ),
                ),
              ],
            );
          case 2:
            final rows = widget.calculatorController.items;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTableHeader(
                  [
                    'Komponen & Jenis Biaya',
                    'Jumlah',
                    'Frekuensi',
                    'Biaya Pokok',
                    'Harga Jual',
                    'Total Nilai',
                    '',
                  ],
                  flexes: const [3, 1, 1, 2, 2, 2],
                ),
                for (final row in rows) _buildItemRow(row),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: AppColors.subtle,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      _buildAddBtn('+ Biaya Transport', 3),
                      const SizedBox(width: 12.0),
                      _buildAddBtn('+ Add-on', 5),
                    ],
                  ),
                ),
              ],
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildTableHeader(
    List<String> columns, {
    List<int> flexes = const [3, 1, 1, 1, 2, 2],
  }) {
    return Container(
      color: AppColors.subtle,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          for (int i = 0; i < flexes.length; i++) ...[
            if (i > 0) SizedBox(width: (i >= flexes.length - 2) ? 16.0 : 8.0),
            Expanded(
              flex: flexes[i],
              child: _th(
                columns[i],
                center: i > 0 && i < flexes.length - 2 && flexes[i] == 1,
                right: i >= flexes.length - 2 || (i > 0 && flexes[i] > 1),
              ),
            ),
          ],
          const SizedBox(width: 8.0),
          const SizedBox(width: 30.0),
        ],
      ),
    );
  }

  Widget _th(String text, {bool center = false, bool right = false}) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11.0,
        fontWeight: FontWeight.w700,
        color: AppColors.sec,
        letterSpacing: 0.5,
      ),
      textAlign: right
          ? TextAlign.right
          : center
          ? TextAlign.center
          : TextAlign.left,
    );
  }

  Widget _buildTableRow(PricingMaterialRow row, {bool hasUnitColumn = false}) {
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
            child: _buildInput(row.doseUsage.value.toString(), (val) {
              row.doseUsage.value = double.tryParse(val) ?? 0.0;
            }),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: _buildInput(row.applicationVolume.value.toString(), (val) {
              row.applicationVolume.value = double.tryParse(val) ?? 0.0;
            }),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: _buildInput(row.freq.value.toString(), (val) {
              row.freq.value = double.tryParse(val) ?? 0.0;
            }),
          ),
          if (hasUnitColumn) ...[
            const SizedBox(width: 8.0),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  row.uomCode,
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(width: 16.0),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  _formatRp(row.unitCost.value),
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
            child: Watch.builder(
              builder: (context) {
                return _buildTotalAmount(_formatRp(row.total.value));
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
                widget.calculatorController.materials.remove(row);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaborRow(PricingLaborRow row) {
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
            child: _buildInput(row.visitFreq.value.toString(), (val) {
              row.visitFreq.value = double.tryParse(val) ?? 0.0;
            }),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: _buildInput(row.firstVisitHours.value.toString(), (val) {
              row.firstVisitHours.value = double.tryParse(val) ?? 0.0;
            }),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            flex: 1,
            child: _buildInput(row.routineHours.value.toString(), (val) {
              row.routineHours.value = double.tryParse(val) ?? 0.0;
            }),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            flex: 2,
            child: _buildInput(row.hourlyRate.value.toString(), (val) {
              row.hourlyRate.value = double.tryParse(val) ?? 0.0;
            }),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            flex: 2,
            child: Watch.builder(
              builder: (context) {
                return _buildTotalAmount(_formatRp(row.total.value));
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
                widget.calculatorController.labors.remove(row);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(PricingItemRow row) {
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
            child: _buildInput(row.qty.value.toString(), (val) {
              row.qty.value = double.tryParse(val) ?? 0.0;
            }),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: _buildInput(row.freq.value.toString(), (val) {
              row.freq.value = double.tryParse(val) ?? 0.0;
            }),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  _formatRp(row.unitCost.value),
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
            child: row.kind == 5
                ? _buildInput(row.unitPrice.value.toString(), (val) {
                    row.unitPrice.value = double.tryParse(val) ?? 0.0;
                  })
                : const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        '0',
                        style: TextStyle(
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
            child: Watch.builder(
              builder: (context) {
                return _buildTotalAmount(_formatRp(row.total.value));
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
                widget.calculatorController.items.remove(row);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String initialValue, void Function(String) onChanged) {
    return Container(
      height: 40.0,
      decoration: BoxDecoration(
        color: AppColors.subtle,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: AppRadius.borderSm,
      ),
      child: TextFormField(
        initialValue: initialValue,
        textAlign: TextAlign.right,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        decoration: const InputDecoration(
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
    );
  }

  Widget _buildTotalAmount(String text) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }

  Widget _buildAddBtn(String text, int kind) {
    return InkWell(
      onTap: () => _handleAddRow(kind),
      child: Container(
        height: 40.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: AppRadius.borderSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: AppColors.brand, size: 16.0),
            const SizedBox(width: 8.0),
            Text(
              text,
              style: const TextStyle(
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

  Future<void> _handleAddRow(int kind) async {
    if (kind == 1) {
      final method = await showModalBottomSheet<TreatmentMethod>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const TreatmentMethodPickerSheet(),
      );
      if (method == null) return;
      if (!mounted) return;

      final mapping = await showModalBottomSheet<ProductMapping>(
        context: context,
        isScrollControlled: true,
        builder: (_) => ProductMappingPickerSheet(treatmentMethodId: method.id),
      );
      if (mapping != null && mounted) {
        widget.calculatorController.addMaterialRow(mapping);
      }
      return;
    }

    final result = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProductPickerSheet(kind: kind),
    );
    if (result != null && mounted) {
      widget.calculatorController.addRow(result, kind);
    }
  }

  // ---- SIDEBAR ----

  Widget _buildSidebar() {
    return Watch.builder(
      builder: (context) {
        final submitState = widget.calculatorController.submitState.value;
        final isLoading = submitState is UiLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGrandTotalCard(),
            const SizedBox(height: 12.0),
            _buildCogsCard(),
            const SizedBox(height: 12.0),
            _buildMarginCard(),
            const SizedBox(height: 12.0),
            AppButton(
              text: 'Simpan Kalkulasi',
              isLoading: isLoading,
              onPressed: () => widget.calculatorController.submitPricing(
                widget.proposal.customerId,
                widget.proposal.serviceId,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGrandTotalCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.brand, AppColors.brandDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.borderLg,
        boxShadow: [
          BoxShadow(
            color: Color(0x331E40AF),
            offset: Offset(0, 4),
            blurRadius: 14.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'TOTAL NILAI PROPOSAL',
            style: GoogleFonts.inter(
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            _formatRp(widget.calculatorController.grandTotal.value),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24.0,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Sudah termasuk PPN 11%',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCogsCard() {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: AppRadius.borderLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Struktur Biaya Pokok (HPP / COGS)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10.0),
          _buildSumRow(
            'Biaya Bahan & Alat',
            _formatRp(widget.calculatorController.cogsMaterial.value),
          ),
          _buildSumRow(
            'Biaya Tenaga Kerja',
            _formatRp(widget.calculatorController.cogsLabor.value),
          ),
          _buildSumRow(
            'Biaya Transport / BBM',
            _formatRp(widget.calculatorController.cogsTransport.value),
          ),
          const Divider(height: 16.0, color: AppColors.border),
          _buildSumRow(
            'Total Biaya Modal (COGS)',
            _formatRp(widget.calculatorController.cogsTotal.value),
            bold: true,
          ),

          // Markup Row
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Markup',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sec,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Container(
                    height: 40.0,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: AppColors.subtle,
                      border: Border.all(color: AppColors.border, width: 1.5),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: '1',
                        isExpanded: true,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: '1',
                            child: Text('Persen (%)'),
                          ),
                        ],
                        onChanged: (v) {},
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                SizedBox(
                  width: 64.0,
                  height: 40.0,
                  child: TextFormField(
                    initialValue: widget
                        .calculatorController
                        .markupPercent
                        .value
                        .toString(),
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      widget.calculatorController.markupPercent.value =
                          double.tryParse(val) ?? 0.0;
                    },
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AppColors.subtle,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.borderSm,
                        borderSide: BorderSide(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.borderSm,
                        borderSide: BorderSide(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                const Text(
                  '%',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),

          _buildSumRow(
            'Harga Pokok Layanan',
            _formatRp(widget.calculatorController.servicePrice.value),
          ),
          _buildSumRow(
            'Total Add-on & Ekstra',
            _formatRp(widget.calculatorController.addonCost.value),
          ),

          // Discount Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Diskon Khusus',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.sec,
                  ),
                ),
                SizedBox(
                  width: 85.0,
                  height: 34.0,
                  child: TextFormField(
                    initialValue: widget
                        .calculatorController
                        .discountAmount
                        .value
                        .toString(),
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      widget.calculatorController.discountAmount.value =
                          double.tryParse(val) ?? 0.0;
                    },
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AppColors.subtle,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.borderSm,
                        borderSide: BorderSide(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.borderSm,
                        borderSide: BorderSide(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 16.0, color: AppColors.border),
          _buildSumRow(
            'Subtotal (DPP)',
            _formatRp(widget.calculatorController.subtotal.value),
            semiBold: true,
          ),
          _buildSumRow(
            'PPN 11%',
            _formatRp(widget.calculatorController.taxAmount.value),
          ),
        ],
      ),
    );
  }

  Widget _buildMarginCard() {
    final marginAmt = widget.calculatorController.marginAmount.value;
    final subtotal = widget.calculatorController.subtotal.value;
    final marginPct = subtotal > 0 ? (marginAmt / subtotal) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: AppRadius.borderLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Metrik Margin & Unit Rate',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x1A10B859),
                    border: Border.all(color: const Color(0x3328B272)),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${marginPct.toStringAsFixed(1)}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800,
                          color: const Color(0x106B4D2E),
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      const Text(
                        'Margin Persen',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0x4056787E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.subtle,
                    border: Border.all(color: AppColors.border),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Column(
                    children: [
                      Text(
                        _formatRp(marginAmt),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      const Text(
                        'Nominal Margin',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sec,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Harga per Kunjungan',
                style: TextStyle(fontSize: 12.0, color: AppColors.sec),
              ),
              Text(
                _formatRp(widget.calculatorController.grandTotal.value / 6),
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Harga per Bulan',
                style: TextStyle(fontSize: 12.0, color: AppColors.sec),
              ),
              Text(
                _formatRp(widget.calculatorController.grandTotal.value / 12),
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSumRow(
    String label,
    String value, {
    bool bold = false,
    bool semiBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: bold
                  ? FontWeight.w700
                  : semiBold
                  ? FontWeight.w600
                  : FontWeight.w500,
              color: bold || semiBold ? AppColors.text : AppColors.sec,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: bold
                  ? FontWeight.w800
                  : semiBold
                  ? FontWeight.w700
                  : FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

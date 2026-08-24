import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';

class PricingCalculatorView extends StatefulWidget {
  final Proposal proposal;

  const PricingCalculatorView({super.key, required this.proposal});

  @override
  State<PricingCalculatorView> createState() => _PricingCalculatorViewState();
}

class _PricingCalculatorViewState extends State<PricingCalculatorView> {
  int _activeTab = 0;
  final List<int> _tabCounts = [4, 2, 2];

  final List<String> _tabTitles = [
    'Persiapan Bahan & Alat',
    'Tenaga Kerja & Teknisi',
    'Transport & Add-on',
  ];

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
    return Container(
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
                  color: isSelected ? AppColors.surface : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.brand : Colors.transparent,
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
                        _tabCounts[_activeTab].toString(),
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppColors.brand : AppColors.sec,
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
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return _buildMockTablePersiapan();
      case 1:
        return _buildMockTableTeknisi();
      case 2:
        return _buildMockTableTransport();
      default:
        return const SizedBox.shrink();
    }
  }

  // ---- MOCK TABLES ----

  Widget _buildMockTablePersiapan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTableHeader([
          'Item & Deskripsi Bahan',
          'Jumlah (Qty)',
          'Frekuensi',
          'Satuan',
          'Biaya Satuan',
          'Total Biaya',
          '',
        ]),
        _buildTableRow(
          title: 'Ficam W (25kg)',
          badge: 'Insektisida Rayap Residual',
          col1: _buildInput('2'),
          col2: _buildInput('1'),
          col3: const Text('kg', style: TextStyle(fontSize: 13.0)),
          col4: _buildInput('380000'),
          col5: _buildTotalAmount('Rp 760.000'),
          hasUnitColumn: true,
        ),
        _buildTableRow(
          title: 'Termidor SC (1L)',
          badge: 'Termitisida Fipronil Non-Repellent',
          col1: _buildInput('3'),
          col2: _buildInput('1'),
          col3: const Text('botol', style: TextStyle(fontSize: 13.0)),
          col4: _buildInput('650000'),
          col5: _buildTotalAmount('Rp 1.950.000'),
          hasUnitColumn: true,
        ),
        _buildTableRow(
          title: 'Solfac 10WP (1kg)',
          badge: 'Cyfluthrin Wettable Powder',
          col1: _buildInput('1'),
          col2: _buildInput('2'),
          col3: const Text('kg', style: TextStyle(fontSize: 13.0)),
          col4: _buildInput('290000'),
          col5: _buildTotalAmount('Rp 580.000'),
          hasUnitColumn: true,
        ),
        _buildTableRow(
          title: 'Sprayer Solo 425 & Nozzle',
          badge: 'Peralatan Teknis Penyemprotan',
          col1: _buildInput('1'),
          col2: _buildInput('1'),
          col3: const Text('unit', style: TextStyle(fontSize: 13.0)),
          col4: _buildInput('420000'),
          col5: _buildTotalAmount('Rp 420.000'),
          hasUnitColumn: true,
        ),
        _buildAddRowBar('Tambah Baris Bahan / Alat'),
      ],
    );
  }

  Widget _buildMockTableTeknisi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTableHeader([
          'Posisi & Peran Teknisi',
          'Kunjungan',
          'Jam Awal',
          'Jam Rutin',
          'Tarif per Jam',
          'Total Biaya',
          '',
        ]),
        _buildTableRow(
          title: 'Teknisi Senior (Lead Operator)',
          badge: 'Teknisi Utama Bersertifikasi',
          col1: _buildInput('6'),
          col2: _buildInput('4.0'),
          col3: _buildInput('3.0'),
          col4: _buildInput('45000'),
          col5: _buildTotalAmount('Rp 990.000'),
        ),
        _buildTableRow(
          title: 'Teknisi Junior (Asisten Lapangan)',
          badge: 'Asisten Aplikasi & Support',
          col1: _buildInput('6'),
          col2: _buildInput('4.0'),
          col3: _buildInput('3.0'),
          col4: _buildInput('30000'),
          col5: _buildTotalAmount('Rp 660.000'),
        ),
        _buildAddRowBar('Tambah Baris Teknisi'),
      ],
    );
  }

  Widget _buildMockTableTransport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTableHeader([
          'Komponen & Jenis Biaya',
          'Jumlah',
          'Frekuensi',
          'Biaya Pokok',
          'Harga Jual',
          'Total Nilai',
          '',
        ]),
        _buildTableRow(
          title: 'Biaya Perjalanan Badung',
          badge: 'BBM & Transportasi Wilayah',
          col1: _buildInput('1'),
          col2: _buildInput('6'),
          col3: _buildInput('20000'),
          col4: const Text(
            'rpm',
            style: TextStyle(fontSize: 12.0, color: AppColors.muted),
          ),
          col5: _buildTotalAmount('Rp 120.000'),
        ),
        _buildTableRow(
          title: 'Pest Safety Training Kit',
          badge: 'Layanan Tambahan (Add-on)',
          col1: _buildInput('1'),
          col2: _buildInput('1'),
          col3: _buildInput('200000'),
          col4: _buildInput('500000'),
          col5: _buildTotalAmount('Rp 500.000'),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: AppColors.subtle,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              _buildAddBtn('+ Biaya Transport / BBM'),
              const SizedBox(width: 12.0),
              _buildAddBtn('+ Add-on Layanan Tambahan'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(List<String> columns) {
    return Container(
      color: AppColors.subtle,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: _th(columns[0])),
          Expanded(child: _th(columns[1], center: true)),
          Expanded(child: _th(columns[2], center: true)),
          Expanded(flex: 1, child: _th(columns[3], center: true)),
          Expanded(flex: 2, child: _th(columns[4], right: true)),
          Expanded(flex: 2, child: _th(columns[5], right: true)),
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

  Widget _buildTableRow({
    required String title,
    required String badge,
    required Widget col1,
    required Widget col2,
    required Widget col3,
    required Widget col4,
    required Widget col5,
    bool hasUnitColumn = false,
  }) {
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
            flex: hasUnitColumn ? 2 : 3,
            child: hasUnitColumn
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4.0),
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
                          badge,
                          style: const TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brand,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
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
                          badge,
                          style: const TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brand,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        title,
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
          Expanded(child: col1),
          const SizedBox(width: 8.0),
          Expanded(child: col2),
          if (hasUnitColumn) ...[
            const SizedBox(width: 8.0),
            Expanded(flex: 1, child: col3),
          ],
          const SizedBox(width: 16.0),
          Expanded(flex: 2, child: col4),
          const SizedBox(width: 16.0),
          Expanded(flex: 2, child: col5),
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
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String initialValue) {
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
        style: const TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        decoration: InputDecoration(
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 10.0,
          ),
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
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

  Widget _buildAddRowBar(String text) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.subtle,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Align(alignment: Alignment.centerLeft, child: _buildAddBtn(text)),
    );
  }

  Widget _buildAddBtn(String text) {
    return InkWell(
      onTap: _handleAddRow,
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

  void _handleAddRow() {
    final newCount = _tabCounts[_activeTab] + 1;
    setState(() {
      _tabCounts[_activeTab] = newCount;
    });
  }

  // ---- SIDEBAR ----

  Widget _buildSidebar() {
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
          text: 'Simpan Perhitungan Harga',
          icon: const Icon(Icons.save_outlined, size: 18.0),
          onPressed: () {},
        ),
      ],
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
            widget.proposal.formattedTotal,
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
            widget.proposal.formattedMaterialCost,
          ),
          _buildSumRow(
            'Biaya Tenaga Kerja',
            widget.proposal.formattedLaborCost,
          ),
          _buildSumRow(
            'Biaya Transport / BBM',
            widget.proposal.formattedFuelCost,
          ),
          const Divider(height: 16.0, color: AppColors.border),
          _buildSumRow(
            'Total Biaya Modal (COGS)',
            widget.proposal.formattedCogs,
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
                          DropdownMenuItem(
                            value: '2',
                            child: Text('Nominal (Rp)'),
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
                    initialValue: '25',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.subtle,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                      ),
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
            widget.proposal.formattedServicePrice,
          ),
          _buildSumRow('Total Add-on & Ekstra', widget.proposal.formattedAddon),

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
                    initialValue: '0',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.subtle,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                      ),
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
            widget.proposal.formattedSubtotal,
            semiBold: true,
          ),
          _buildSumRow('PPN 11%', widget.proposal.formattedTax),
        ],
      ),
    );
  }

  Widget _buildMarginCard() {
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
                        widget.proposal.formattedMarginPct,
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
                          color: const Color(0x4056787E),
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
                        widget.proposal.formattedMarginAmt,
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
                widget.proposal.formattedPpv,
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
                widget.proposal.formattedPpm,
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

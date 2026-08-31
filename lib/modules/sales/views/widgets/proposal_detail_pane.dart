import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_badge.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';

class ProposalDetailPane extends StatelessWidget {
  final Proposal? proposal;
  final UiState<Proposal>? detailState;
  final int activeDetailTab;
  final ValueChanged<int> onDetailTabChanged;
  final int activePricingTab;
  final ValueChanged<int> onPricingTabChanged;
  final VoidCallback? onExportPdf;
  final VoidCallback? onOpenCalculator;
  final VoidCallback? onOpenDocument;
  final VoidCallback? onRetry;
  final VoidCallback? onEditProposal;

  const ProposalDetailPane({
    super.key,
    this.proposal,
    this.detailState,
    required this.activeDetailTab,
    required this.onDetailTabChanged,
    required this.activePricingTab,
    required this.onPricingTabChanged,
    this.onExportPdf,
    this.onOpenCalculator,
    this.onOpenDocument,
    this.onRetry,
    this.onEditProposal,
  });

  static const List<String> tabTitles = [
    '1. Persiapan Bahan & Alat',
    '2. Tenaga Kerja',
    '3. Transport & Add-on',
  ];

  @override
  Widget build(BuildContext context) {
    if (detailState != null) {
      return switch (detailState!) {
        UiInitial() => _buildFallbackOrEmpty(),
        UiLoading() => const Center(
          child: CircularProgressIndicator(color: AppColors.brand),
        ),
        UiFailure(:final failure) => Center(
          child: ErrorView(message: failure.message, onRetry: onRetry),
        ),
        UiSuccess(:final data) => _buildDetailContent(context, data),
      };
    }

    return _buildFallbackOrEmpty();
  }

  Widget _buildFallbackOrEmpty() {
    final p = proposal;
    if (p == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.description_outlined,
              size: 48.0,
              color: AppColors.muted,
            ),
            const SizedBox(height: 12.0),
            Text(
              'Pilih proposal dari daftar di sebelah kiri',
              style: GoogleFonts.inter(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      );
    }
    return Builder(builder: (context) => _buildDetailContent(context, p));
  }

  Widget _buildDetailContent(BuildContext context, Proposal proposal) {
    return Container(
      color: AppColors.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, proposal),
          _buildTopLevelTabs(),
          Expanded(
            child: activeDetailTab == 0
                ? _buildGeneralInfoTab(proposal)
                : _buildPricingTabContent(proposal),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Proposal proposal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;

          final identity = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${proposal.code} · ${proposal.clientName}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5.0),
              Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppBadge.brand(text: proposal.serviceName),
                  AppBadge.neutral(text: proposal.displayVersion),
                  AppBadge.fromType(
                    proposal.status.badgeType,
                    'Status: ${proposal.status.displayName}',
                  ),
                ],
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10.0,
            runSpacing: 8.0,
            children: [
              AppButton.secondary(
                text: 'Ubah Data',
                height: 40.0,
                isFullWidth: false,
                borderRadius: AppRadius.borderMd,
                icon: const Icon(
                  Icons.edit_note,
                  size: 16.0,
                  color: AppColors.text,
                ),
                onPressed: onEditProposal,
              ),
              AppButton.secondary(
                text: 'Ekspor PDF',
                height: 40.0,
                isFullWidth: false,
                borderRadius: AppRadius.borderMd,
                icon: const Icon(
                  Icons.download_rounded,
                  size: 16.0,
                  color: AppColors.text,
                ),
                onPressed: onExportPdf,
              ),
              AppButton.secondary(
                text: 'Dokumen',
                height: 40.0,
                isFullWidth: false,
                borderRadius: AppRadius.borderMd,
                icon: const Icon(
                  Icons.edit_document,
                  size: 16.0,
                  color: AppColors.text,
                ),
                onPressed: onOpenDocument,
              ),
              AppButton(
                text: 'Pricing',
                height: 40.0,
                isFullWidth: false,
                borderRadius: AppRadius.borderMd,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 16.0,
                  color: Colors.white,
                ),
                onPressed: onOpenCalculator,
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [identity, const SizedBox(height: 12.0), actions],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: identity),
              const SizedBox(width: 16.0),
              actions,
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopLevelTabs() {
    const tabs = ['Informasi Umum', 'Rincian Kalkulasi'];
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == activeDetailTab;
          return InkWell(
            onTap: () => onDetailTabChanged(index),
            child: Container(
              height: 48.0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppColors.brand : Colors.transparent,
                    width: 3.0,
                  ),
                ),
              ),
              child: Text(
                tabs[index],
                style: GoogleFonts.inter(
                  fontSize: 14.0,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppColors.brand : AppColors.sec,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGeneralInfoTab(Proposal proposal) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Basic Info
          Wrap(
            spacing: 24.0,
            runSpacing: 16.0,
            children: [
              _buildInfoSection('TANGGAL PROPOSAL', proposal.date),
              _buildInfoSection(
                'MASA BERLAKU',
                proposal.validUntil.isNotEmpty ? proposal.validUntil : '-',
              ),
              _buildInfoSection('LOKASI PROPERTI', proposal.location),
              _buildInfoSection(
                'NILAI TOTAL',
                proposal.formattedTotal,
                valueColor: AppColors.brand,
              ),
            ],
          ),
          const SizedBox(height: 32.0),

          // Row 2: Notes
          Text(
            'Catatan Proposal',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.0,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              (proposal.notes != null && proposal.notes!.isNotEmpty)
                  ? proposal.notes!
                  : 'Tidak ada catatan.',
              style: GoogleFonts.inter(fontSize: 14.0, color: AppColors.text),
            ),
          ),
          const SizedBox(height: 32.0),

          // Row 3: Timeline & Status
          Text(
            'Timeline & Status',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.0,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 24.0,
            runSpacing: 16.0,
            children: [
              _buildInfoSection('DIBUAT PADA', proposal.createdAt ?? '-'),
              _buildInfoSection('DIKIRIM PADA', proposal.sentAt ?? '-'),
              if (proposal.status.value == 'accepted' ||
                  proposal.status.value == 'rejected')
                _buildInfoSection('DIPUTUSKAN PADA', proposal.decidedAt ?? '-'),
            ],
          ),
          if (proposal.status.value == 'rejected' &&
              proposal.rejectionReason != null) ...[
            const SizedBox(height: 16.0),
            _buildInfoSection(
              'ALASAN PENOLAKAN',
              proposal.rejectionReason!,
              valueColor: AppColors.err,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.0,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingTabContent(Proposal proposal) {
    if (proposal.cogs == 0 && proposal.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calculate_outlined,
              size: 64.0,
              color: AppColors.muted,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Belum ada kalkulasi harga',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Buat rincian bahan, alat, dan tenaga kerja untuk proposal ini.',
              style: GoogleFonts.inter(fontSize: 14.0, color: AppColors.muted),
            ),
            const SizedBox(height: 24.0),
            AppButton(
              text: 'Buat Kalkulasi Harga',
              onPressed: onOpenCalculator,
              isFullWidth: false,
            ),
          ],
        ),
      );
    }

    return _buildPricingSplit(proposal);
  }

  Widget _buildPricingSplit(Proposal proposal) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 620;

        if (isNarrow) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPricingTabs(),
                _buildPricingListContent(proposal),
                const Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: AppColors.border,
                ),
                _buildSidebarContent(proposal),
              ],
            ),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left: Tabs & Pricing item list
            Expanded(
              child: Container(
                color: AppColors.surface,
                child: Column(
                  children: [
                    _buildPricingTabs(),
                    Expanded(child: _buildPricingList(proposal)),
                  ],
                ),
              ),
            ),

            // Right: 300px Financial Summary Sidebar
            Container(
              width: 300.0,
              decoration: const BoxDecoration(
                color: AppColors.bg,
                border: Border(
                  left: BorderSide(color: AppColors.border, width: 1.0),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: _buildSidebarContent(proposal),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSidebarContent(Proposal proposal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildGrandTotalCard(proposal),
        const SizedBox(height: 12.0),
        _buildFinancialBreakdownCard(proposal),
        const SizedBox(height: 12.0),
        _buildProfitabilityCard(proposal),
      ],
    );
  }

  Widget _buildPricingTabs() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.subtle,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabTitles.length, (index) {
            final isSelected = index == activePricingTab;
            return InkWell(
              onTap: () => onPricingTabChanged(index),
              child: Container(
                height: 44.0,
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surface : Colors.transparent,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.rSm),
                  ),
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
                child: Text(
                  tabTitles[index],
                  style: GoogleFonts.inter(
                    fontSize: 13.0,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? AppColors.brand : AppColors.sec,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  List<ProposalItem> _getActiveItems(Proposal proposal) {
    return switch (activePricingTab) {
      0 => proposal.persiapanItems,
      1 => proposal.teknisiItems,
      2 => proposal.transportItems,
      _ => proposal.persiapanItems,
    };
  }

  Widget _buildPricingListContent(Proposal proposal) {
    final items = _getActiveItems(proposal);

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 36.0,
                color: AppColors.muted,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Tidak ada rincian item untuk kategori ini',
                style: GoogleFonts.inter(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: items.map((item) => _buildItemRow(item)).toList());
  }

  Widget _buildPricingList(Proposal proposal) {
    final items = _getActiveItems(proposal);

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 36.0,
                color: AppColors.muted,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Tidak ada rincian item untuk kategori ini',
                style: GoogleFonts.inter(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1.0, thickness: 1.0, color: AppColors.border),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemRow(item);
      },
    );
  }

  Widget _buildItemRow(ProposalItem item) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      constraints: const BoxConstraints(minHeight: 48.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 3.0),
                  Text(
                    item.description,
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Text(
            item.formattedPrice,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrandTotalCard(Proposal proposal) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.brand, Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.borderLg,
        boxShadow: [
          BoxShadow(
            color: Color(0x401E40AF),
            offset: Offset(0, 4),
            blurRadius: 14.0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            proposal.formattedTotal,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24.0,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4.0),
          Text(
            'Sudah termasuk PPN 11%',
            style: GoogleFonts.inter(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialBreakdownCard(Proposal proposal) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 1),
            blurRadius: 3.0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rincian Finansial Proposal',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10.0),
          _buildSummaryRow(
            'Biaya Bahan & Alat',
            proposal.formattedMaterialCost,
          ),
          _buildSummaryRow('Biaya Tenaga Kerja', proposal.formattedWorkerCost),
          _buildSummaryRow('Biaya Transport / BBM', proposal.formattedFuelCost),
          const Divider(height: 14.0, thickness: 1.0, color: AppColors.border),
          _buildSummaryRow(
            'Total Biaya Modal (COGS)',
            proposal.formattedCogs,
            isLabelBold: true,
            isValueBold: true,
            labelColor: AppColors.text,
          ),
          _buildSummaryRow(
            'Markup Keuntungan',
            proposal.formattedMarkup,
            valueColor: AppColors.ok,
            isValueBold: true,
          ),
          _buildSummaryRow(
            'Harga Pokok Layanan',
            proposal.formattedServicePrice,
          ),
          _buildSummaryRow('Total Add-on & Ekstra', proposal.formattedAddon),
          const Divider(height: 14.0, thickness: 1.0, color: AppColors.border),
          _buildSummaryRow(
            'Subtotal (DPP)',
            proposal.formattedSubtotal,
            isLabelBold: true,
            isValueBold: true,
          ),
          _buildSummaryRow('PPN 11%', proposal.formattedTax),
        ],
      ),
    );
  }

  Widget _buildProfitabilityCard(Proposal proposal) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 1),
            blurRadius: 3.0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metrik Profitabilitas',
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
                    horizontal: 8.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x1A10B981),
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(
                      color: const Color(0x3310B981),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        proposal.formattedMarginPct,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ok,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        'Margin Persen',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sec,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.subtle,
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(color: AppColors.border, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      Text(
                        proposal.formattedMarginAmt,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        'Nominal Margin',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sec,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Harga per Kunjungan',
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      color: AppColors.sec,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8.0),
                Flexible(
                  flex: 3,
                  child: Text(
                    proposal.formattedPpv,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Harga per Bulan',
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      color: AppColors.sec,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8.0),
                Flexible(
                  flex: 3,
                  child: Text(
                    proposal.formattedPpm,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isLabelBold = false,
    bool isValueBold = false,
    Color? labelColor,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.0,
                fontWeight: isLabelBold ? FontWeight.w700 : FontWeight.w500,
                color: labelColor ?? AppColors.sec,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8.0),
          Flexible(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 12.0,
                fontWeight: isValueBold ? FontWeight.w700 : FontWeight.w600,
                color: valueColor ?? AppColors.text,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

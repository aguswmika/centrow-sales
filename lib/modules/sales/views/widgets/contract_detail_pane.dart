import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_badge.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';

class ContractDetailPane extends StatelessWidget {
  final Contract? contract;
  final UiState<Contract>? detailState;
  final bool isActionLoading;
  final VoidCallback? onRetry;
  final VoidCallback? onActivate;
  final VoidCallback? onSuspend;
  final VoidCallback? onTerminate;
  final VoidCallback? onCancel;

  const ContractDetailPane({
    super.key,
    this.contract,
    this.detailState,
    this.isActionLoading = false,
    this.onRetry,
    this.onActivate,
    this.onSuspend,
    this.onTerminate,
    this.onCancel,
  });

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
        UiSuccess(:final data) => _buildContent(context, data),
      };
    }
    return _buildFallbackOrEmpty();
  }

  Widget _buildFallbackOrEmpty() {
    final c = contract;
    if (c == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 48.0,
              color: AppColors.muted,
            ),
            const SizedBox(height: 12.0),
            Text(
              'Pilih kontrak dari daftar di sebelah kiri',
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
    return Builder(builder: (context) => _buildContent(context, c));
  }

  Widget _buildContent(BuildContext context, Contract c) {
    return Container(
      color: AppColors.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(c),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection('KODE KONTRAK', c.code),
                  const SizedBox(height: 16.0),
                  Wrap(
                    spacing: 24.0,
                    runSpacing: 16.0,
                    children: [
                      _buildInfoSection('PELANGGAN', c.customerName),
                      _buildInfoSection('LAYANAN', c.serviceName),
                      _buildInfoSection('KATEGORI', c.categoryName),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Wrap(
                    spacing: 24.0,
                    runSpacing: 16.0,
                    children: [
                      _buildInfoSection('TANGGAL MULAI', c.startDate),
                      _buildInfoSection('TANGGAL SELESAI', c.endDate ?? '-'),
                      if (c.signedDate != null)
                        _buildInfoSection('TANGGAL TTD', c.signedDate!),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Wrap(
                    spacing: 24.0,
                    runSpacing: 16.0,
                    children: [
                      _buildInfoSection(
                        'NILAI KONTRAK',
                        c.formattedValue,
                        valueColor: AppColors.brand,
                      ),
                      _buildInfoSection(
                        'TIPE PEMBAYARAN',
                        c.paymentType.displayName,
                      ),
                      if (c.totalVisits != null)
                        _buildInfoSection(
                          'TOTAL KUNJUNGAN',
                          '${c.totalVisits}x',
                        ),
                    ],
                  ),
                  if (c.signatoryName != null &&
                      c.signatoryName!.isNotEmpty) ...[
                    const SizedBox(height: 16.0),
                    Wrap(
                      spacing: 24.0,
                      runSpacing: 16.0,
                      children: [
                        _buildInfoSection('PENANDATANGAN', c.signatoryName!),
                        if (c.signatoryPosition != null &&
                            c.signatoryPosition!.isNotEmpty)
                          _buildInfoSection('JABATAN', c.signatoryPosition!),
                      ],
                    ),
                  ],
                  if (c.sourceProposalCode != null) ...[
                    const SizedBox(height: 16.0),
                    _buildInfoSection(
                      'SUMBER PENAWARAN',
                      c.sourceProposalCode!,
                    ),
                  ],
                  if (c.notes != null && c.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24.0),
                    Text(
                      'Catatan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        c.notes!,
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                  if (c.status == ContractStatus.terminated) ...[
                    const SizedBox(height: 24.0),
                    Text(
                      'Informasi Terminasi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.err,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    if (c.terminatedAt != null)
                      _buildInfoSection(
                        'DITERMINASI PADA',
                        c.terminatedAt!,
                        valueColor: AppColors.err,
                      ),
                    if (c.terminationReason != null &&
                        c.terminationReason!.isNotEmpty) ...[
                      const SizedBox(height: 12.0),
                      _buildInfoSection(
                        'ALASAN TERMINASI',
                        c.terminationReason!,
                        valueColor: AppColors.err,
                      ),
                    ],
                  ],
                  const SizedBox(height: 8.0),
                  _buildInfoSection('DIBUAT PADA', c.createdAt ?? '-'),
                ],
              ),
            ),
          ),
          if (!c.status.isTerminal) _buildActionBar(c),
        ],
      ),
    );
  }

  Widget _buildHeader(Contract c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${c.code} · ${c.customerName}',
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
                  children: [
                    AppBadge.brand(text: c.serviceName),
                    AppBadge.fromType(c.status.badgeType, c.status.displayName),
                  ],
                ),
              ],
            ),
          ),
          if (isActionLoading) ...[
            const SizedBox(width: 12.0),
            const SizedBox(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: AppColors.brand,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionBar(Contract c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 8.0,
        children: [
          if (onActivate != null)
            AppButton(
              text: 'Aktifkan',
              isFullWidth: false,
              onPressed: isActionLoading ? null : onActivate,
            ),
          if (onSuspend != null)
            AppButton.secondary(
              text: 'Tangguhkan',
              isFullWidth: false,
              onPressed: isActionLoading ? null : onSuspend,
            ),
          if (onTerminate != null)
            AppButton.secondary(
              text: 'Terminasi',
              isFullWidth: false,
              onPressed: isActionLoading ? null : onTerminate,
            ),
          if (onCancel != null)
            AppButton.secondary(
              text: 'Batalkan',
              isFullWidth: false,
              onPressed: isActionLoading ? null : onCancel,
            ),
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
}

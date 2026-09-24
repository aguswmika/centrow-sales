import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_addendum_document_controller.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_badge.dart';
import 'package:centrow_sales/shared/widgets/toast.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum.dart';

class ContractAddendumHistoryList extends StatelessWidget {
  final UiState<List<ContractAddendum>>? state;
  final List<ContractAddendum>? addendums;
  final VoidCallback? onRetry;
  final VoidCallback? onAddAddendum;
  final void Function(ContractAddendum addendum)? onOpenDocument;
  final void Function(ContractAddendum addendum)? onDownloadPdf;

  const ContractAddendumHistoryList({
    super.key,
    this.state,
    this.addendums,
    this.onRetry,
    this.onAddAddendum,
    this.onOpenDocument,
    this.onDownloadPdf,
  });

  @override
  Widget build(BuildContext context) {
    if (state != null) {
      return switch (state!) {
        UiInitial() => _buildList(addendums ?? const []),
        UiLoading() => const Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.brand),
          ),
        ),
        UiFailure(:final failure) => Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.err.withValues(alpha: 0.08),
            borderRadius: AppRadius.borderMd,
            border: Border.all(color: AppColors.err.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 18.0,
                    color: AppColors.err,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      failure.message,
                      style: GoogleFonts.inter(
                        fontSize: 13.0,
                        color: AppColors.err,
                      ),
                    ),
                  ),
                ],
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 16.0),
                    label: const Text('Coba Lagi'),
                  ),
                ),
              ],
            ],
          ),
        ),
        UiSuccess(:final data) => _buildList(data),
      };
    }

    return _buildList(addendums ?? const []);
  }

  Widget _buildList(List<ContractAddendum> items) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 12.0),
          _ContractAddendumCard(
            addendum: items[i],
            index: items.length - i,
            onOpenDocument: onOpenDocument,
            onDownloadPdf: onDownloadPdf,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.history_toggle_off_outlined,
            size: 40.0,
            color: AppColors.muted,
          ),
          const SizedBox(height: 10.0),
          Text(
            'Belum Ada Addendum',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Riwayat addendum kontrak akan tampil di sini setelah dibuat.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12.0, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _ContractAddendumCard extends StatelessWidget {
  final ContractAddendum addendum;
  final int index;
  final void Function(ContractAddendum addendum)? onOpenDocument;
  final void Function(ContractAddendum addendum)? onDownloadPdf;

  const _ContractAddendumCard({
    required this.addendum,
    required this.index,
    this.onOpenDocument,
    this.onDownloadPdf,
  });

  @override
  Widget build(BuildContext context) {
    final isDeltaPositive = addendum.visitDelta > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Addendum #$index',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              if (isDeltaPositive)
                AppBadge.ok(text: '${addendum.formattedVisitDelta} Kunjungan')
              else
                AppBadge.warn(
                  text: '${addendum.formattedVisitDelta} Kunjungan',
                ),
            ],
          ),
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 24.0,
            runSpacing: 10.0,
            children: [
              _buildMetric(
                label: 'TOTAL KUNJUNGAN',
                value:
                    '${addendum.oldTotalVisits}x  ➔  ${addendum.newTotalVisits}x',
              ),
              _buildMetric(
                label: 'NILAI KONTRAK',
                value:
                    '${addendum.formattedOldContractValue}  ➔  ${addendum.formattedNewContractValue}',
                subValue: addendum.contractValueDelta != 0
                    ? '(${addendum.formattedContractValueDelta})'
                    : null,
                subValueColor: addendum.contractValueDelta > 0
                    ? AppColors.ok
                    : (addendum.contractValueDelta < 0
                          ? AppColors.warn
                          : AppColors.muted),
              ),
            ],
          ),
          if (addendum.reason != null && addendum.reason!.isNotEmpty) ...[
            const SizedBox(height: 12.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                color: AppColors.bg,
                borderRadius: AppRadius.borderSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ALASAN',
                    style: GoogleFonts.inter(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    addendum.reason!,
                    style: GoogleFonts.inter(
                      fontSize: 13.0,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 16.0,
            runSpacing: 4.0,
            children: [
              if (addendum.createdAt != null &&
                  addendum.createdAt!.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13.0,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      addendum.createdAt!,
                      style: GoogleFonts.inter(
                        fontSize: 11.0,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
              if (addendum.createdBy != null &&
                  addendum.createdBy!.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14.0,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      addendum.createdBy!,
                      style: GoogleFonts.inter(
                        fontSize: 11.0,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
              if (addendum.pricingId != null &&
                  addendum.pricingId!.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 13.0,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Pricing: ${addendum.pricingId!.length > 8 ? addendum.pricingId!.substring(0, 8) : addendum.pricingId}',
                      style: GoogleFonts.inter(
                        fontSize: 11.0,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const Divider(height: 24.0, color: AppColors.border),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.description_outlined, size: 16.0),
                  label: const Text('Dokumen Addendum'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brand,
                    side: const BorderSide(color: AppColors.brand),
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderSm,
                    ),
                  ),
                  onPressed: () => onOpenDocument != null
                      ? onOpenDocument!(addendum)
                      : _defaultOpenDocument(context, addendum),
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton.outlined(
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18.0),
                tooltip: 'Unduh PDF',
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: AppColors.border),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.borderSm,
                  ),
                ),
                onPressed: () => onDownloadPdf != null
                    ? onDownloadPdf!(addendum)
                    : _defaultDownloadPdf(context, addendum),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _defaultOpenDocument(BuildContext context, ContractAddendum addendum) {
    if (context.mounted) {
      context.push(
        '/contracts/${addendum.contractId}/addendums/${addendum.id}/document',
      );
    }
  }

  Future<void> _defaultDownloadPdf(
    BuildContext context,
    ContractAddendum addendum,
  ) async {
    try {
      final controller = getIt<ContractAddendumDocumentController>();
      final result = await controller.downloadPdf(addendum.id);
      if (context.mounted) {
        switch (result) {
          case Ok(:final value):
            final tempDir = Directory.systemTemp;
            final file = File('${tempDir.path}/addendum_${addendum.id}.pdf');
            await file.writeAsBytes(value, flush: true);
            await OpenFilex.open(file.path);
          case Err(:final failure):
            showAppToast(context, failure.message, isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        showAppToast(context, 'Gagal mengunduh PDF: $e', isError: true);
      }
    }
  }

  Widget _buildMetric({
    required String label,
    required String value,
    String? subValue,
    Color? subValueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.0,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            if (subValue != null) ...[
              const SizedBox(width: 6.0),
              Text(
                subValue,
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: subValueColor ?? AppColors.text,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

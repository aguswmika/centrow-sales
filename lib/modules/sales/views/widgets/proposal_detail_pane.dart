import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/theme/app_typography.dart';
import 'package:centrow_sales/shared/widgets/app_badge.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';

class ProposalDetailPane extends StatelessWidget {
  final Proposal? proposal;
  final UiState<Proposal>? detailState;
  final VoidCallback? onExportPdf;
  final bool isExportingPdf;
  final VoidCallback? onOpenCalculator;
  final VoidCallback? onOpenDocument;
  final VoidCallback? onRetry;
  final VoidCallback? onEditProposal;
  final VoidCallback? onReviseProposal;
  final VoidCallback? onSendProposal;
  final VoidCallback? onAcceptProposal;
  final VoidCallback? onRejectProposal;
  final VoidCallback? onExpireProposal;
  final VoidCallback? onCancelProposal;
  final VoidCallback? onCreateContract;
  final void Function(String contractId)? onViewLinkedContract;
  final bool isActionLoading;

  const ProposalDetailPane({
    super.key,
    this.proposal,
    this.detailState,
    this.onExportPdf,
    this.isExportingPdf = false,
    this.onOpenCalculator,
    this.onOpenDocument,
    this.onRetry,
    this.onEditProposal,
    this.onReviseProposal,
    this.onSendProposal,
    this.onAcceptProposal,
    this.onRejectProposal,
    this.onExpireProposal,
    this.onCancelProposal,
    this.onCreateContract,
    this.onViewLinkedContract,
    this.isActionLoading = false,
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
          Expanded(child: _buildGeneralInfoTab(proposal)),
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
          final isNarrow = constraints.maxWidth < 620;

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

          final isLoading = isActionLoading || isExportingPdf;
          final actions = Wrap(
            spacing: 10.0,
            runSpacing: 8.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppButton.secondary(
                text: 'Pricing',
                height: 40.0,
                isFullWidth: false,
                borderRadius: AppRadius.borderMd,
                icon: Icon(
                  Icons.calculate_outlined,
                  size: 16.0,
                  color: (proposal.status.canEditPricing || proposal.hasPricing)
                      ? AppColors.text
                      : AppColors.muted,
                ),
                onPressed:
                    (proposal.status.canEditPricing || proposal.hasPricing)
                    ? onOpenCalculator
                    : null,
              ),
              AppButton.secondary(
                text: 'Dokumen',
                height: 40.0,
                isFullWidth: false,
                borderRadius: AppRadius.borderMd,
                icon: Icon(
                  proposal.status.canEditDocument
                      ? Icons.edit_document
                      : Icons.description_outlined,
                  size: 16.0,
                  color: AppColors.text,
                ),
                onPressed: onOpenDocument,
              ),
              if (proposal.canCreateContract)
                AppButton(
                  text: 'Buat Kontrak',
                  height: 40.0,
                  isFullWidth: false,
                  borderRadius: AppRadius.borderMd,
                  icon: const Icon(
                    Icons.assignment_outlined,
                    size: 16.0,
                    color: Colors.white,
                  ),
                  onPressed: onCreateContract,
                ),
              PopupMenuButton<String>(
                tooltip: 'Aksi',
                enabled: !isLoading,
                onSelected: (val) {
                  switch (val) {
                    case 'contract':
                      onCreateContract?.call();
                    case 'send':
                      onSendProposal?.call();
                    case 'accept':
                      onAcceptProposal?.call();
                    case 'reject':
                      onRejectProposal?.call();
                    case 'revise':
                      onReviseProposal?.call();
                    case 'pdf':
                      onExportPdf?.call();
                    case 'edit':
                      onEditProposal?.call();
                    case 'expire':
                      onExpireProposal?.call();
                    case 'cancel':
                      onCancelProposal?.call();
                  }
                },
                itemBuilder: (context) => [
                  if (proposal.status.canSend)
                    const PopupMenuItem<String>(
                      value: 'send',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            size: 18,
                            color: AppColors.brand,
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Kirim Proposal',
                              style: TextStyle(
                                color: AppColors.brand,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (proposal.status.canAccept)
                    const PopupMenuItem<String>(
                      value: 'accept',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: AppColors.ok,
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Terima Proposal',
                              style: TextStyle(
                                color: AppColors.ok,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (proposal.status.canReject)
                    const PopupMenuItem<String>(
                      value: 'reject',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            size: 18,
                            color: AppColors.err,
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Tolak Proposal',
                              style: TextStyle(
                                color: AppColors.err,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (proposal.status.canRevise)
                    const PopupMenuItem<String>(
                      value: 'revise',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.file_copy, size: 18, color: AppColors.sec),
                          SizedBox(width: 8),
                          Flexible(child: Text('Revisi Proposal')),
                        ],
                      ),
                    ),
                  const PopupMenuItem<String>(
                    value: 'pdf',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.download_rounded,
                          size: 18,
                          color: AppColors.sec,
                        ),
                        SizedBox(width: 8),
                        Flexible(child: Text('Ekspor PDF')),
                      ],
                    ),
                  ),
                  if (proposal.status.canEdit)
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_note, size: 18, color: AppColors.sec),
                          SizedBox(width: 8),
                          Flexible(child: Text('Ubah Data')),
                        ],
                      ),
                    ),
                  if (proposal.status.canExpire)
                    const PopupMenuItem<String>(
                      value: 'expire',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.hourglass_bottom,
                            size: 18,
                            color: AppColors.sec,
                          ),
                          SizedBox(width: 8),
                          Flexible(child: Text('Tandai Kedaluwarsa')),
                        ],
                      ),
                    ),
                  if (proposal.status.canCancel)
                    const PopupMenuItem<String>(
                      value: 'cancel',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.err,
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Batalkan Proposal',
                              style: TextStyle(color: AppColors.err),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                child: Container(
                  height: 40.0,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: isLoading
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16.0,
                              height: 16.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.tune,
                              size: 16.0,
                              color: AppColors.text,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Aksi',
                              style: AppTypography.buttonMd(
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18.0,
                              color: AppColors.sec,
                            ),
                          ],
                        ),
                ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: identity),
              const SizedBox(width: 16.0),
              Flexible(child: actions),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGeneralInfoTab(Proposal proposal) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (proposal.linkedContract != null) ...[
            Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: AppColors.brand05,
                borderRadius: AppRadius.borderMd,
                border: Border.all(color: AppColors.brand10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: AppColors.brand,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kontrak Terkait: ${proposal.linkedContract!.code}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Status: ${proposal.linkedContract!.statusLabel ?? proposal.linkedContract!.status}',
                          style: GoogleFonts.inter(
                            fontSize: 12.0,
                            color: AppColors.sec,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppButton.secondary(
                    text: 'Lihat Kontrak',
                    isFullWidth: false,
                    onPressed: () =>
                        onViewLinkedContract?.call(proposal.linkedContract!.id),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
          ],
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
              if (proposal.sentAt != null && proposal.sentAt!.isNotEmpty)
                _buildInfoSection('DIKIRIM PADA', proposal.sentAt!),
              if (proposal.status.isAccepted ||
                  proposal.status.isRejected ||
                  proposal.status.isExpired)
                _buildInfoSection('DIPUTUSKAN PADA', proposal.decidedAt ?? '-'),
            ],
          ),
          if (proposal.status.isRejected &&
              proposal.rejectionReason != null &&
              proposal.rejectionReason!.isNotEmpty) ...[
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
}

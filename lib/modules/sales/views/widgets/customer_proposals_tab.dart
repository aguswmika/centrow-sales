import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../entities/customer.dart';

class CustomerProposalsTab extends StatelessWidget {
  final List<CustomerProposalSummary> proposals;

  const CustomerProposalsTab({super.key, required this.proposals});

  @override
  Widget build(BuildContext context) {
    if (proposals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Belum ada riwayat proposal untuk pelanggan ini',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < proposals.length; i++) ...[
          if (i > 0) const SizedBox(height: 12.0),
          _buildProposalCard(proposals[i]),
        ],
      ],
    );
  }

  Widget _buildProposalCard(CustomerProposalSummary proposal) {
    final title = proposal.title.isNotEmpty ? proposal.title : proposal.code;
    final subtitle = [
      if (proposal.code.isNotEmpty) proposal.code,
      if (proposal.date.isNotEmpty) proposal.date,
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  subtitle.isNotEmpty ? subtitle : '-',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                proposal.amount,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4.0),
              _buildProposalStatusBadge(proposal.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProposalStatusBadge(String status) {
    final s = status.toLowerCase().trim();
    return switch (s) {
      'accepted' || 'disetujui' => const AppBadge.ok(text: 'Disetujui'),
      'sent' || 'dikirim' || 'terkirim' => const AppBadge.info(text: 'Terkirim'),
      'negotiation' || 'negosiasi' => const AppBadge.warn(text: 'Negosiasi'),
      'rejected' || 'ditolak' => const AppBadge.err(text: 'Ditolak'),
      'expired' || 'kadaluarsa' => const AppBadge.err(text: 'Kadaluarsa'),
      'cancelled' || 'dibatalkan' => const AppBadge.err(text: 'Dibatalkan'),
      'draft' => const AppBadge.neutral(text: 'Draft'),
      _ => AppBadge.neutral(text: status),
    };
  }
}

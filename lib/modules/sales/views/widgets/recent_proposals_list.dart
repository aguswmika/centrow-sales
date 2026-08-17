import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../entities/sales_dashboard.dart';

class RecentProposalsList extends StatelessWidget {
  final List<RecentProposal> proposals;
  final VoidCallback? onSeeAll;

  const RecentProposalsList({
    super.key,
    required this.proposals,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Proposal Terbaru',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brand,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12.0),
        for (int i = 0; i < proposals.length; i++) ...[
          if (i > 0) const SizedBox(height: 10.0),
          _buildProposalCard(proposals[i]),
        ],
      ],
    );
  }

  Widget _buildProposalCard(RecentProposal proposal) {
    final initials = proposal.clientName.length >= 2
        ? proposal.clientName.substring(0, 2).toUpperCase()
        : proposal.clientName.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            offset: Offset(0, 1),
            blurRadius: 3.0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: const BoxDecoration(
              color: AppColors.brand10,
              borderRadius: AppRadius.borderMd,
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brand,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proposal.clientName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Text(
                  '${proposal.code} · ${proposal.serviceName} · ${proposal.region}',
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10.0),
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
              AppBadge.fromType(proposal.status, proposal.status),
            ],
          ),
        ],
      ),
    );
  }
}

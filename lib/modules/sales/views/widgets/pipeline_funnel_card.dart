import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../entities/sales_dashboard.dart';

class PipelineFunnelCard extends StatelessWidget {
  final List<PipelineStage> stages;
  final List<ClientSegment> segments;

  const PipelineFunnelCard({
    super.key,
    required this.stages,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pipeline Penjualan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16.0),
          ...stages.map(_buildStageRow),
          const SizedBox(height: 12.0),
          const Divider(height: 24.0, thickness: 1.5, color: AppColors.border),
          Text(
            'Distribusi Segmen Klien',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: segments.map(_buildSegmentBadge).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStageRow(PipelineStage stage) {
    final barColor = Color(stage.colorHex);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 75.0,
            child: Text(
              stage.name,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Container(
              height: 28.0,
              decoration: const BoxDecoration(
                color: AppColors.subtle,
                borderRadius: AppRadius.borderSm,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: stage.percentage.clamp(0.08, 1.0),
                child: Container(
                  height: 28.0,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: AppRadius.borderSm,
                  ),
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${stage.count}',
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: stage.percentage > 0.4
                          ? Colors.white
                          : AppColors.brand,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          SizedBox(
            width: 24.0,
            child: Text(
              '${stage.count}',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentBadge(ClientSegment segment) {
    final Color badgeBg;
    final Color badgeText;

    switch (segment.badgeType) {
      case 'brand':
        badgeBg = AppColors.brand10;
        badgeText = AppColors.brand;
        break;
      case 'info':
        badgeBg = const Color(0x1F3B82F6);
        badgeText = const Color(0xFF2563EB);
        break;
      case 'ok':
        badgeBg = const Color(0x1F10B981);
        badgeText = const Color(0xFF059669);
        break;
      default:
        badgeBg = AppColors.subtle;
        badgeText = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.5),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: AppRadius.borderPill,
      ),
      child: Text(
        '${segment.name} (${segment.count})',
        style: GoogleFonts.inter(
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          color: badgeText,
        ),
      ),
    );
  }
}

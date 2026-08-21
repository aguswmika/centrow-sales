import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_badge.dart';
import 'package:centrow_sales/modules/sales/entities/sales_dashboard.dart';

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
      padding: const EdgeInsets.all(18.0),
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
          for (int i = 0; i < stages.length; i++) ...[
            if (i > 0) const SizedBox(height: 10.0),
            _buildStageRow(stages[i]),
          ],
          const SizedBox(height: 18.0),
          const Divider(height: 1.0, thickness: 1.0, color: AppColors.border),
          const SizedBox(height: 14.0),
          Text(
            'Distribusi Segmen Klien',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: segments.map((seg) {
              return AppBadge.fromType(
                seg.badgeType,
                '${seg.name} (${seg.count})',
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStageRow(PipelineStage stage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              stage.name,
              style: GoogleFonts.inter(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                color: AppColors.sec,
              ),
            ),
            Text(
              '${stage.count} (${(stage.percentage * 100).round()}%)',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        Container(
          height: 26.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.subtle,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: stage.percentage.clamp(0.04, 1.0),
              child: Container(
                height: 26.0,
                decoration: BoxDecoration(
                  color: Color(stage.colorHex),
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../entities/sales_dashboard.dart';

class KpiCard extends StatelessWidget {
  final KpiMetric metric;

  const KpiCard({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            metric.label,
            style: GoogleFonts.inter(
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8.0),
          Text(
            metric.value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24.0,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -0.5,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6.0),
          _buildSubText(),
        ],
      ),
    );
  }

  Widget _buildSubText() {
    if (metric.isWarning) {
      return Text(
        metric.subText,
        style: GoogleFonts.inter(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.err,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (metric.isPositive == null) {
      return Text(
        metric.subText,
        style: GoogleFonts.inter(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: AppColors.sec,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final isUp = metric.isPositive == true;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          size: 13.0,
          color: isUp ? AppColors.ok : AppColors.err,
        ),
        const SizedBox(width: 3.0),
        Flexible(
          child: Text(
            metric.subText,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isUp ? AppColors.ok : AppColors.err,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

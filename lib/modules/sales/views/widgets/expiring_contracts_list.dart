import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../entities/sales_dashboard.dart';

class ExpiringContractsList extends StatelessWidget {
  final List<ExpiringContract> contracts;

  const ExpiringContractsList({super.key, required this.contracts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kontrak Jatuh Tempo',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 2.5,
              ),
              decoration: const BoxDecoration(
                color: Color(0x1AEF4444),
                borderRadius: AppRadius.borderPill,
              ),
              child: Text(
                '${contracts.length} Bulan Ini',
                style: GoogleFonts.inter(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.err,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: contracts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8.0),
          itemBuilder: (context, index) => _buildContractCard(contracts[index]),
        ),
      ],
    );
  }

  Widget _buildContractCard(ExpiringContract contract) {
    final accentColor = contract.isCritical ? AppColors.err : AppColors.warn;
    final initials = _getInitials(contract.clientName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border(
          left: BorderSide(color: accentColor, width: 3.5),
          top: const BorderSide(color: AppColors.border, width: 1.5),
          right: const BorderSide(color: AppColors.border, width: 1.5),
          bottom: const BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38.0,
            height: 38.0,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderSm,
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
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
                  contract.clientName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  '${contract.code} · ${contract.packageName} · ${contract.region}',
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
                contract.dueDate,
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                contract.amount,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'CT';
  }
}

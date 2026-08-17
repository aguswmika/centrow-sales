import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/widgets/app_badge.dart';
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
            Flexible(
              child: Text(
                'Kontrak Jatuh Tempo',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8.0),
            AppBadge.err(text: '${contracts.length} Perlu Tindakan'),
          ],
        ),
        const SizedBox(height: 12.0),
        for (int i = 0; i < contracts.length; i++) ...[
          if (i > 0) const SizedBox(height: 10.0),
          _buildContractCard(contracts[i]),
        ],
      ],
    );
  }

  Widget _buildContractCard(ExpiringContract contract) {
    final initials = contract.clientName.length >= 2
        ? contract.clientName.substring(0, 2).toUpperCase()
        : contract.clientName.toUpperCase();

    final Color accentColor = contract.isCritical
        ? AppColors.err
        : const Color(0xFFBC7B43);

    return Container(
      clipBehavior: Clip.antiAlias,
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3.5, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 13.0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38.0,
                      height: 38.0,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: AppRadius.borderMd,
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            contract.clientName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                      mainAxisSize: MainAxisSize.min,
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
                            fontSize: 14.0,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../entities/customer.dart';

class CustomerContactsTab extends StatelessWidget {
  final List<CustomerContact> contacts;

  const CustomerContactsTab({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Belum ada kontak PIC terdaftar',
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
        for (int i = 0; i < contacts.length; i++) ...[
          if (i > 0) const SizedBox(height: 12.0),
          _buildContactCard(contacts[i]),
        ],
      ],
    );
  }

  Widget _buildContactCard(CustomerContact contact) {
    final contactInfoParts = [
      if (contact.email.isNotEmpty) contact.email,
      if (contact.phone.isNotEmpty) contact.phone,
    ];
    final contactInfo = contactInfoParts.isNotEmpty
        ? contactInfoParts.join(' · ')
        : '-';

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
          Container(
            width: 40.0,
            height: 40.0,
            decoration: const BoxDecoration(
              color: AppColors.brand10,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                contact.initials,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brand,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        contact.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (contact.isPrimary) ...[
                      const SizedBox(width: 8.0),
                      const AppBadge.brand(text: 'Utama'),
                    ],
                  ],
                ),
                const SizedBox(height: 2.0),
                Text(
                  contact.position.isNotEmpty ? contact.position : '-',
                  style: GoogleFonts.inter(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.sec,
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  contactInfo,
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10.0),
          AppBadge.fromType(contact.roleBadge, contact.displayRole),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_badge.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';

class CustomerLocationsTab extends StatelessWidget {
  final List<CustomerLocation> locations;
  final String? customerId;

  const CustomerLocationsTab({
    super.key,
    required this.locations,
    this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Belum ada lokasi titik servis terdaftar',
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
        for (int i = 0; i < locations.length; i++) ...[
          if (i > 0) const SizedBox(height: 12.0),
          _buildLocationCard(context, locations[i]),
        ],
      ],
    );
  }

  Widget _buildLocationCard(BuildContext context, CustomerLocation location) {
    final regionChips = [
      if (location.district.isNotEmpty)
        _buildInfoChip(label: 'Kecamatan', value: location.district),
      if (location.regency.isNotEmpty)
        _buildInfoChip(label: 'Kab/Kota', value: location.regency),
      if (location.province.isNotEmpty)
        _buildInfoChip(label: 'Provinsi', value: location.province),
      if (location.village.isNotEmpty)
        _buildInfoChip(label: 'Kel/Desa', value: location.village),
    ];

    final metaParts = [
      if (location.area.isNotEmpty) location.area,
      if (location.coords.isNotEmpty) 'GPS: ${location.coords}',
    ];
    final metaText = metaParts.join(' · ');

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: location.isPrimary ? AppColors.brand10 : AppColors.subtle,
              borderRadius: AppRadius.borderSm,
            ),
            child: Center(
              child: Icon(
                Icons.location_on_outlined,
                size: 20.0,
                color: location.isPrimary ? AppColors.brand : AppColors.muted,
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
                        location.label.isNotEmpty
                            ? location.label
                            : 'Titik Servis',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    if (location.isPrimary) ...[
                      const SizedBox(width: 8.0),
                      const AppBadge.brand(text: 'Utama'),
                    ],
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  location.address.isNotEmpty ? location.address : '-',
                  style: GoogleFonts.inter(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.sec,
                  ),
                ),
                if (regionChips.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  Wrap(spacing: 8.0, runSpacing: 6.0, children: regionChips),
                ],
                if (metaText.isNotEmpty) ...[
                  const SizedBox(height: 6.0),
                  Text(
                    metaText,
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(fontSize: 12.0, color: AppColors.muted),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

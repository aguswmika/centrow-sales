import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../entities/customer.dart';

class CustomerInfoTab extends StatelessWidget {
  final Customer customer;

  const CustomerInfoTab({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 1),
            blurRadius: 3.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoRow(
            'Status Pelanggan',
            child: AppBadge.ok(text: customer.status),
          ),
          _buildDivider(),
          _buildInfoRow('Segmen Usaha', text: customer.segment),
          _buildDivider(),
          _buildInfoRow('Wilayah Domisili', text: customer.regency),
          _buildDivider(),
          _buildInfoRow('Nomor NPWP', text: customer.npwp),
          _buildDivider(),
          _buildInfoRow('Telepon Utama', text: customer.phone),
          _buildDivider(),
          _buildInfoRow('Telepon Alternatif', text: customer.phoneAlt),
          _buildDivider(),
          _buildInfoRow('Email Bisnis', text: customer.email),
          _buildDivider(),
          _buildInfoRow(
            'Scan Barcode / QR',
            child: Text(
              customer.scanCode,
              style: GoogleFonts.robotoMono(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          _buildDivider(),
          _buildInfoRow('Catatan Risiko', text: customer.riskNotes),
          _buildDivider(),
          _buildInfoRow('Catatan Operasional', text: customer.notes),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1.0, thickness: 1.0, color: AppColors.border);
  }

  Widget _buildInfoRow(String key, {String? text, Widget? child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 13.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160.0,
            child: Text(
              key,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child:
                  child ??
                  Text(
                    text ?? '-',
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

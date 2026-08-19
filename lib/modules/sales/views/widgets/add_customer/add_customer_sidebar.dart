import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/modules/sales/controllers/add_customer_controller.dart';

class AddCustomerSidebar extends StatelessWidget {
  final AddCustomerController controller;

  const AddCustomerSidebar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final currentStep = controller.currentStep.value;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 20.0,
        left: 16.0,
        right: 16.0,
        bottom: 60.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Live Summary Card
          _buildPreviewCard(
            title: 'Ringkasan Data',
            child: Column(
              children: [
                _buildPreviewRow(
                  'Kode',
                  controller.code.value.isNotEmpty
                      ? controller.code.value
                      : '(Otomatis)',
                ),
                _buildPreviewRow(
                  'Nama',
                  controller.name.value.isNotEmpty
                      ? controller.name.value
                      : '-',
                ),
                _buildPreviewRow(
                  'Segmen',
                  controller.segment.value.isNotEmpty
                      ? controller.segment.value
                      : '-',
                ),
                _buildPreviewRow(
                  'Wilayah',
                  controller.regency.value.isNotEmpty
                      ? controller.regency.value
                      : '-',
                ),
                _buildPreviewRow(
                  'Status',
                  controller.status.value.isNotEmpty
                      ? controller.status.value
                      : 'Aktif',
                  isStatus: true,
                ),
                _buildPreviewRow(
                  'Alamat Utama',
                  controller.primaryLocationSummary.value,
                ),
                _buildPreviewRow(
                  'PIC Utama',
                  controller.primaryContactName.value,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),

          // 2. Progress Indicator Card
          _buildPreviewCard(
            title: 'Progres Pendaftaran',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Langkah $currentStep dari 3',
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sec,
                  ),
                ),
                const SizedBox(height: 12.0),
                _buildProgressItem(1, '1. Identitas & Legal', currentStep),
                const SizedBox(height: 10.0),
                _buildProgressItem(2, '2. Lokasi & Alamat', currentStep),
                const SizedBox(height: 10.0),
                _buildProgressItem(3, '3. Kontak Person & PIC', currentStep),
              ],
            ),
          ),
          const SizedBox(height: 16.0),

          // 3. Guidance Card
          _buildPreviewCard(
            title: 'Petunjuk Pengisian',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGuidanceBullet(
                  'Kode pelanggan opsional dan otomatis digenerate backend jika kosong.',
                ),
                const SizedBox(height: 8.0),
                _buildGuidanceBullet(
                  'Nama pelanggan dan nomor telepon utama perusahaan wajib diisi.',
                ),
                const SizedBox(height: 8.0),
                _buildGuidanceBullet(
                  'Daftarkan minimal 1 lokasi operasional atau titik servis penanganan.',
                ),
                const SizedBox(height: 8.0),
                _buildGuidanceBullet(
                  'Daftarkan minimal 1 PIC bertindak sebagai Pengambil Keputusan.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            offset: Offset(0, 1),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12.0),
          child,
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String key, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: GoogleFonts.inter(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(width: 8.0),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: isStatus ? AppColors.ok : AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(int step, String label, int currentStep) {
    final isDone = currentStep > step;
    final isActive = currentStep == step;

    return Row(
      children: [
        Container(
          width: 20.0,
          height: 20.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? AppColors.ok
                : (isActive ? AppColors.brand : AppColors.subtle),
            border: Border.all(
              color: isDone
                  ? AppColors.ok
                  : (isActive ? AppColors.brand : AppColors.border),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 12.0)
              : Text(
                  '$step',
                  style: GoogleFonts.inter(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : AppColors.muted,
                  ),
                ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: isActive || isDone
                  ? FontWeight.w600
                  : FontWeight.w500,
              color: isDone
                  ? AppColors.ok
                  : (isActive ? AppColors.brand : AppColors.muted),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuidanceBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: GoogleFonts.inter(
            fontSize: 12.0,
            color: AppColors.muted,
            height: 1.5,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12.0,
              color: AppColors.sec,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

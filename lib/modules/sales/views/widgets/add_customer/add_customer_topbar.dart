import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';

class AddCustomerTopbar extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int> onStepChanged;
  final VoidCallback onCancel;
  final VoidCallback onNext;
  final VoidCallback? onPrev;

  const AddCustomerTopbar({
    super.key,
    required this.currentStep,
    required this.onStepChanged,
    required this.onCancel,
    required this.onNext,
    this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isCompact = constraints.maxWidth < 1250;

        final stepper = Container(
          height: 42.0,
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: AppColors.subtle,
            borderRadius: AppRadius.borderPill,
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStepItem(1, 'Identitas & Legal', isCompact: isCompact),
              _buildStepItem(2, 'Lokasi & Alamat', isCompact: isCompact),
              _buildStepItem(3, 'Kontak Person & PIC', isCompact: isCompact),
            ],
          ),
        );

        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMobile) ...[
              AppButton.danger(
                text: 'Batal',
                height: 38.0,
                isFullWidth: false,
                borderRadius: AppRadius.borderPill,
                onPressed: onCancel,
              ),
              if (currentStep > 1) const SizedBox(width: 8.0),
            ],
            if (currentStep > 1) ...[
              AppButton.secondary(
                text: isMobile ? 'Kembali' : 'Sebelumnya',
                height: 38.0,
                isFullWidth: false,
                borderRadius: AppRadius.borderPill,
                icon: const Icon(Icons.arrow_back_rounded, size: 14.0),
                onPressed: onPrev ?? () {},
              ),
              const SizedBox(width: 8.0),
            ],
            AppButton(
              text: currentStep == 3
                  ? 'Simpan Data Pelanggan'
                  : 'Selanjutnya',
              height: 38.0,
              isFullWidth: false,
              borderRadius: AppRadius.borderPill,
              icon: currentStep == 3
                  ? const Icon(
                      Icons.save_outlined,
                      size: 15.0,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14.0,
                      color: Colors.white,
                    ),
              onPressed: onNext,
            ),
          ],
        );

        return Container(
          height: 68.0,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12.0 : 24.0),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onCancel,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border, width: 1.5),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.text,
                    size: 24.0,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tambah Pelanggan Baru',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isMobile ? 14.5 : 16.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isMobile) ...[
                      const SizedBox(height: 2.0),
                      Text(
                        'Form pendaftaran data master pelanggan',
                        style: GoogleFonts.inter(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              if (!isMobile) ...[
                stepper,
                const SizedBox(width: 12.0),
              ],
              actions,
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepItem(int step, String label, {bool isCompact = false}) {
    final isActive = currentStep == step;
    final isDone = currentStep > step;
    final showLabel = !isCompact || isActive;

    return GestureDetector(
      onTap: () => onStepChanged(step),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 34.0,
        padding: EdgeInsets.symmetric(horizontal: showLabel ? 10.0 : 6.0),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: AppRadius.borderPill,
          boxShadow: isActive
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    offset: Offset(0, 1),
                    blurRadius: 3.0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.0,
              height: 20.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? AppColors.ok
                    : (isActive ? AppColors.brand : const Color(0xFFE2E8F0)),
              ),
              alignment: Alignment.center,
              child: isDone
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 13.0,
                    )
                  : Text(
                      '$step',
                      style: GoogleFonts.inter(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : AppColors.muted,
                      ),
                    ),
            ),
            if (showLabel) ...[
              const SizedBox(width: 6.0),
              Text(
                '$step. $label',
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? AppColors.brand
                      : (isDone ? AppColors.ok : AppColors.muted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

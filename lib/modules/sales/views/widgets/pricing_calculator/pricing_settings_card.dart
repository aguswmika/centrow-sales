import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';

class PricingSettingsCard extends StatelessWidget {
  final PricingCalculatorController controller;
  final bool isReadOnly;

  const PricingSettingsCard({
    super.key,
    required this.controller,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: AppRadius.borderLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pengaturan Harga & Diskon',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 24.0,
            runSpacing: 16.0,
            children: [
              // Markup Group
              SizedBox(
                width: 240,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Markup',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sec,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: 40.0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: isReadOnly
                                  ? AppColors.border.withValues(alpha: 0.3)
                                  : AppColors.subtle,
                              border: Border.all(
                                color: AppColors.border,
                                width: 1.5,
                              ),
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: SignalBuilder(
                              builder: (context) {
                                return DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: controller.markupType.value
                                        .toString(),
                                    isExpanded: true,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: '1',
                                        child: Text('Persen (%)'),
                                      ),
                                      DropdownMenuItem(
                                        value: '2',
                                        child: Text('Nominal (Rp)'),
                                      ),
                                    ],
                                    onChanged: isReadOnly
                                        ? null
                                        : (v) {
                                            if (v != null) {
                                              controller.markupType.value =
                                                  int.tryParse(v) ?? 1;
                                            }
                                          },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 40.0,
                            child: TextFormField(
                              initialValue: controller.markupPercent.value
                                  .toString(),
                              enabled: !isReadOnly,
                              textAlign: TextAlign.right,
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                controller.markupPercent.value =
                                    double.tryParse(val) ?? 0.0;
                              },
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w700,
                                color: isReadOnly
                                    ? AppColors.muted
                                    : AppColors.text,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isReadOnly
                                    ? AppColors.border.withValues(alpha: 0.3)
                                    : AppColors.subtle,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius: AppRadius.borderSm,
                                  borderSide: BorderSide(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius: AppRadius.borderSm,
                                  borderSide: BorderSide(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                disabledBorder: const OutlineInputBorder(
                                  borderRadius: AppRadius.borderSm,
                                  borderSide: BorderSide(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Diskon Group
              SizedBox(
                width: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Diskon Khusus (Rp)',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sec,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      height: 40.0,
                      child: TextFormField(
                        initialValue: controller.discountAmount.value
                            .toString(),
                        enabled: !isReadOnly,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          controller.discountAmount.value =
                              double.tryParse(val) ?? 0.0;
                        },
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: isReadOnly ? AppColors.muted : AppColors.text,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isReadOnly
                              ? AppColors.border.withValues(alpha: 0.3)
                              : AppColors.subtle,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: AppRadius.borderSm,
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: AppRadius.borderSm,
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          disabledBorder: const OutlineInputBorder(
                            borderRadius: AppRadius.borderSm,
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tax Group
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PPN / Pajak (%)',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sec,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      height: 40.0,
                      child: TextFormField(
                        initialValue: controller.taxPercentage.value.toString(),
                        enabled: !isReadOnly,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          controller.taxPercentage.value =
                              double.tryParse(val) ?? 0.0;
                        },
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: isReadOnly ? AppColors.muted : AppColors.text,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isReadOnly
                              ? AppColors.border.withValues(alpha: 0.3)
                              : AppColors.subtle,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: AppRadius.borderSm,
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: AppRadius.borderSm,
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          disabledBorder: const OutlineInputBorder(
                            borderRadius: AppRadius.borderSm,
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

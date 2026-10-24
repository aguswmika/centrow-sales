import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'pricing_utils.dart';

class PricingSettingsCard extends StatelessWidget {
  final PricingCalculatorController controller;
  final bool isReadOnly;
  final VoidCallback? onChanged;

  const PricingSettingsCard({
    super.key,
    required this.controller,
    this.isReadOnly = false,
    this.onChanged,
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
            'Pengaturan Penawaran & Pajak',
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
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              // Offer Group
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 320, maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Model & Nilai Penawaran',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.sec,
                          ),
                        ),
                        SizedBox(width: 2),
                        Text(
                          '*',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.err,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        SizedBox(
                          width: 140.0,
                          height: 46.0,
                          child: Container(
                            height: 46.0,
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
                                        value: '3',
                                        child: Text('Nilai Tetap (Rp)'),
                                      ),
                                      DropdownMenuItem(
                                        value: '1',
                                        child: Text('Persentase (%)'),
                                      ),
                                    ],
                                    onChanged: isReadOnly
                                        ? null
                                        : (v) {
                                            if (v != null) {
                                              controller.markupType.value =
                                                  int.tryParse(v) ?? 3;
                                              onChanged?.call();
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
                          child: SizedBox(
                            height: 46.0,
                            child: SignalBuilder(
                              builder: (context) {
                                final isPercentage =
                                    controller.markupType.value == 1;
                                return TextFormField(
                                  key: ValueKey(
                                    'offer_value_${controller.markupType.value}',
                                  ),
                                  initialValue:
                                      controller.markupPercent.value > 0
                                      ? (isPercentage
                                            ? (controller.markupPercent.value %
                                                          1 ==
                                                      0
                                                  ? controller
                                                        .markupPercent
                                                        .value
                                                        .toInt()
                                                        .toString()
                                                  : controller
                                                        .markupPercent
                                                        .value
                                                        .toString())
                                            : formatCurrencyNumber(
                                                controller.markupPercent.value,
                                              ))
                                      : '',
                                  enabled: !isReadOnly,
                                  textAlign: TextAlign.right,
                                  keyboardType: isPercentage
                                      ? const TextInputType.numberWithOptions(
                                          decimal: true,
                                        )
                                      : TextInputType.number,
                                  inputFormatters: isPercentage
                                      ? [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*[,.]?\d*'),
                                          ),
                                        ]
                                      : [CurrencyInputFormatter()],
                                  onChanged: (val) {
                                    final cleanVal = isPercentage
                                        ? val.replaceAll(',', '.')
                                        : val.replaceAll(RegExp(r'[^\d]'), '');
                                    controller.markupPercent.value =
                                        double.tryParse(cleanVal) ?? 0.0;
                                    onChanged?.call();
                                  },
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w700,
                                    color: isReadOnly
                                        ? AppColors.muted
                                        : AppColors.text,
                                  ),
                                  decoration: InputDecoration(
                                    prefixText: isPercentage ? null : 'Rp ',
                                    prefixStyle: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color: isReadOnly
                                          ? AppColors.muted
                                          : AppColors.sec,
                                    ),
                                    suffixText: isPercentage ? '%' : null,
                                    suffixStyle: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color: isReadOnly
                                          ? AppColors.muted
                                          : AppColors.sec,
                                    ),
                                    hintText: '0',
                                    hintStyle: const TextStyle(
                                      fontSize: 14.0,
                                      color: AppColors.muted,
                                    ),
                                    filled: true,
                                    fillColor: isReadOnly
                                        ? AppColors.border.withValues(
                                            alpha: 0.3,
                                          )
                                        : AppColors.subtle,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
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
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SignalBuilder(
                      builder: (context) {
                        final isPercentage = controller.markupType.value == 1;
                        final subtotal = controller.previewSubtotal.value;
                        final total = controller.previewTotalAmount.value;
                        if (isPercentage && subtotal != null && subtotal > 0) {
                          return Container(
                            margin: const EdgeInsets.only(top: 8.0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.brand05,
                              borderRadius: AppRadius.borderSm,
                              border: Border.all(color: AppColors.brand10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 14.0,
                                  color: AppColors.brand,
                                ),
                                const SizedBox(width: 6.0),
                                Expanded(
                                  child: Text(
                                    'Estimasi Penawaran: ${formatRp(subtotal)}${total != null ? ' (Total: ${formatRp(total)})' : ''}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.brand,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
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
                          onChanged?.call();
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

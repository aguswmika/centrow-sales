import 'package:centrow_sales/modules/sales/views/widgets/pricing_calculator/pricing_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:signals_flutter/signals_flutter.dart';

class PricingCogsCard extends StatelessWidget {
  final PricingCalculatorController controller;

  const PricingCogsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: AppRadius.borderLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Struktur Biaya Pokok (HPP / COGS)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 10.0),
            buildSumRow(
              'Biaya Bahan & Alat',
              formatRp(controller.cogsMaterial.value),
            ),
            buildSumRow(
              'Biaya Tenaga Kerja',
              formatRp(controller.cogsWorker.value),
            ),
            buildSumRow('Biaya BBM', formatRp(controller.cogsTransport.value)),
            const Divider(height: 16.0, color: AppColors.border),
            buildSumRow(
              'Total Biaya Modal (COGS)',
              formatRp(controller.cogsTotal.value),
              bold: true,
            ),

            // Markup Row
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: const BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Markup',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.sec,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Container(
                    width: 130.0,
                    height: 40.0,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      color: AppColors.subtle,
                      border: Border.all(color: AppColors.border, width: 1.5),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: SignalBuilder(
                        builder: (context) {
                          return DropdownButton<int>(
                            value: controller.markupType.value,
                            isExpanded: true,
                            isDense: true,
                            icon: const Icon(Icons.arrow_drop_down, size: 18.0),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('Persen')),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('Nominal'),
                              ),
                              DropdownMenuItem(
                                value: 3,
                                child: Text('Target Harga'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) controller.markupType.value = v;
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Container(
                      height: 40.0,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                        color: AppColors.subtle,
                        border: Border.all(color: AppColors.border, width: 1.5),
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: controller.markupPercent.value
                                  .toString(),
                              textAlign: TextAlign.right,
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                controller.markupPercent.value =
                                    double.tryParse(val) ?? 0.0;
                              },
                              style: const TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          SignalBuilder(
                            builder: (context) {
                              return Text(
                                controller.markupType.value == 1 ? '%' : 'Rp',
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.muted,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            buildSumRow(
              'Harga Pokok Layanan',
              formatRp(controller.servicePrice.value),
            ),
            buildSumRow(
              'Total Add-on & Ekstra',
              formatRp(controller.addonCost.value),
            ),

            // Discount Row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Diskon Khusus',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.sec,
                    ),
                  ),
                  SizedBox(
                    width: 85.0,
                    height: 34.0,
                    child: TextFormField(
                      initialValue: controller.discountAmount.value.toString(),
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        controller.discountAmount.value =
                            double.tryParse(val) ?? 0.0;
                      },
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: AppColors.subtle,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.borderSm,
                          borderSide: BorderSide(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
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

            const Divider(height: 16.0, color: AppColors.border),
            buildSumRow(
              'Subtotal (DPP)',
              formatRp(controller.subtotal.value),
              semiBold: true,
            ),
            // PPN row - rate is user-editable, amount reacts to it.
            SignalBuilder(
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'PPN',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: AppColors.sec,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          SizedBox(
                            width: 78.0,
                            height: 34.0,
                            child: TextFormField(
                              initialValue: controller.taxPercentage.value
                                  .toString(),
                              textAlign: TextAlign.right,
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                controller.taxPercentage.value =
                                    double.tryParse(val) ?? 0.0;
                              },
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: AppColors.subtle,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                suffixText: '%',
                                suffixStyle: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.muted,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.borderSm,
                                  borderSide: BorderSide(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
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
                      Text(
                        formatRp(controller.taxAmount.value),
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:centrow_sales/modules/sales/views/widgets/pricing_calculator/pricing_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';

class PricingCogsCard extends StatelessWidget {
  final PricingCalculatorController controller;

  const PricingCogsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            formatRp(controller.cogsWoker.value),
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
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: '1',
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
                        ],
                        onChanged: (v) {},
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                SizedBox(
                  width: 64.0,
                  height: 40.0,
                  child: TextFormField(
                    initialValue: controller.markupPercent.value.toString(),
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
                const SizedBox(width: 8.0),
                const Text(
                  '%',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
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
          buildSumRow('PPN', formatRp(controller.taxAmount.value)),
        ],
      ),
    );
  }
}

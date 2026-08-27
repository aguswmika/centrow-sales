import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'pricing_utils.dart';

class PricingMarginCard extends StatelessWidget {
  final PricingCalculatorController controller;

  const PricingMarginCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final marginAmt = controller.marginAmount.value;
    final subtotal = controller.subtotal.value;
    final marginPct = subtotal > 0 ? (marginAmt / subtotal) * 100 : 0.0;

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
            'Metrik Margin & Unit Rate',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x1A10B859),
                    border: Border.all(color: const Color(0x3328B272)),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${marginPct.toStringAsFixed(1)}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800,
                          color: const Color(0x106B4D2E),
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      const Text(
                        'Margin Persen',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0x4056787E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.subtle,
                    border: Border.all(color: AppColors.border),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Column(
                    children: [
                      Text(
                        formatRp(marginAmt),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      const Text(
                        'Nominal Margin',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sec,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Harga per Kunjungan',
                style: TextStyle(fontSize: 12.0, color: AppColors.sec),
              ),
              Text(
                formatRp(controller.grandTotal.value / 6),
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Harga per Bulan',
                style: TextStyle(fontSize: 12.0, color: AppColors.sec),
              ),
              Text(
                formatRp(controller.grandTotal.value / 12),
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

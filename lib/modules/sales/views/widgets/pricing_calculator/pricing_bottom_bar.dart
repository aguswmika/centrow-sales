import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'pricing_utils.dart';

class PricingBottomBar extends StatelessWidget {
  final Proposal proposal;
  final PricingCalculatorController controller;

  const PricingBottomBar({
    super.key,
    required this.proposal,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, -4),
            blurRadius: 12.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TOTAL NILAI PROPOSAL',
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.sec,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4.0),
              SignalBuilder(
                builder: (context) {
                  return Text(
                    formatRp(controller.grandTotal.value),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brand,
                    ),
                  );
                },
              ),
            ],
          ),
          SignalBuilder(
            builder: (context) {
              final submitState = controller.submitState.value;
              final isLoading = submitState is UiLoading;

              return SizedBox(
                width: 200.0,
                child: AppButton(
                  text: 'Simpan Kalkulasi',
                  isLoading: isLoading,
                  onPressed: () => controller.submitPricing(
                    proposal.customerId,
                    proposal.serviceId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

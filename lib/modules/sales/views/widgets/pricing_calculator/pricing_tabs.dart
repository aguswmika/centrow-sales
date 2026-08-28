import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';

class PricingTabs extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  final PricingCalculatorController controller;

  const PricingTabs({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
    required this.controller,
  });

  static const List<String> tabTitles = [
    'Persiapan Bahan & Alat',
    'Tenaga Kerja',
    'Transport & Add-on',
  ];

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final List<int> tabCounts = [
          controller.materials.length,
          controller.wokers.length,
          controller.items.length,
        ];
        return Container(
          width: double.infinity,
          color: AppColors.subtle,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(tabTitles.length, (index) {
                final isSelected = index == activeTab;
                return InkWell(
                  onTap: () => onTabChanged(index),
                  child: Container(
                    height: 44.0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 0.0,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surface
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? AppColors.brand
                              : Colors.transparent,
                          width: 3.0,
                        ),
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Color(0x08000000),
                                offset: Offset(0, -2),
                                blurRadius: 6.0,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tabTitles[index],
                          style: GoogleFonts.inter(
                            fontSize: 13.0,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected ? AppColors.brand : AppColors.sec,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.brand10
                                : AppColors.border,
                            borderRadius: AppRadius.borderPill,
                          ),
                          child: Text(
                            tabCounts[index].toString(),
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.brand
                                  : AppColors.sec,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

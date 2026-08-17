import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class SegmentItem<T> {
  final String label;
  final T value;

  const SegmentItem({required this.label, required this.value});
}

class AppSegmentedControl<T> extends StatelessWidget {
  final List<SegmentItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onValueChanged;
  final double height;

  const AppSegmentedControl({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onValueChanged,
    this.height = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: AppColors.subtle,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: items.map((item) {
          final isSelected = item.value == selectedValue;

          return Expanded(
            child: InkWell(
              onTap: () => onValueChanged(item.value),
              borderRadius: AppRadius.borderSm,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surface : Colors.transparent,
                  borderRadius: AppRadius.borderSm,
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            offset: Offset(0, 1),
                            blurRadius: 3.0,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? AppColors.brand : AppColors.sec,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

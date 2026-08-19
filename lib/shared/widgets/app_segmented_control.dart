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
  final Duration animationDuration;
  final Curve animationCurve;

  const AppSegmentedControl({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onValueChanged,
    this.height = 36.0,
    this.animationDuration = const Duration(milliseconds: 220),
    this.animationCurve = Curves.easeInOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = items.indexWhere(
      (item) => item.value == selectedValue,
    );
    final validIndex = selectedIndex >= 0 ? selectedIndex : 0;

    return Container(
      height: height,
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: AppColors.subtle,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = items.length;
          if (count == 0) return const SizedBox.shrink();

          final itemWidth = constraints.maxWidth / count;

          return Stack(
            children: [
              // Smooth sliding indicator pill
              AnimatedPositioned(
                duration: animationDuration,
                curve: animationCurve,
                left: validIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.borderSm,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        offset: Offset(0, 1.5),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                ),
              ),
              // Segment label touch targets
              Row(
                children: items.map((item) {
                  final isSelected = item.value == selectedValue;

                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onValueChanged(item.value),
                        borderRadius: AppRadius.borderSm,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: animationDuration,
                            curve: animationCurve,
                            style: GoogleFonts.inter(
                              fontSize: 12.0,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? AppColors.brand
                                  : AppColors.sec,
                            ),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

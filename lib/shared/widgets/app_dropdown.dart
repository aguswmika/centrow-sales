import 'package:flutter/material.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/theme/app_spacing.dart';
import 'package:centrow_sales/shared/theme/app_typography.dart';

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool isRequired;
  final bool enabled;
  final Widget? prefixIcon;
  final String? Function(T?)? validator;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.enabled = true,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final dropdownWidget = DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true,
      style: AppTypography.inputText(),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.sec),
      dropdownColor: AppColors.surface,
      borderRadius: AppRadius.borderMd,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: prefixIcon,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        filled: true,
        fillColor: enabled ? AppColors.subtle : const Color(0xFFF0F0EC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.brand, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.err, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.err, width: 1.5),
        ),
      ),
    );

    if (label == null) {
      return dropdownWidget;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label!,
              style: AppTypography.bodySm(
                color: AppColors.sec,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 2),
              Text(
                '*',
                style: AppTypography.bodySm(
                  color: AppColors.err,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.labelGap),
        dropdownWidget,
      ],
    );
  }
}

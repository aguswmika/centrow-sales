import 'package:flutter/material.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/theme/app_spacing.dart';
import 'package:centrow_sales/shared/theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final AppButtonVariant variant;
  final double height;
  final double? width;
  final bool isFullWidth;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.height = AppSpacing.touchLg,
    this.width,
    this.isFullWidth = true,
    this.borderRadius,
  });

  const AppButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = AppSpacing.touchLg,
    this.width,
    this.isFullWidth = true,
    this.borderRadius,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.danger({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = AppSpacing.touchLg,
    this.width,
    this.isFullWidth = true,
    this.borderRadius,
  }) : variant = AppButtonVariant.danger;

  const AppButton.ghost({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = AppSpacing.touchLg,
    this.width,
    this.isFullWidth = true,
    this.borderRadius,
  }) : variant = AppButtonVariant.ghost;

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = onPressed != null && !isLoading;
    final radius = borderRadius ?? AppRadius.borderMd;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide;
    List<BoxShadow> shadows = const [];

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = AppColors.brand;
        foregroundColor = Colors.white;
        borderSide = BorderSide.none;
        if (isInteractive) {
          shadows = const [
            BoxShadow(
              color: Color(0x331E40AF),
              offset: Offset(0, 3),
              blurRadius: 10,
            ),
          ];
        }
        break;
      case AppButtonVariant.secondary:
        backgroundColor = AppColors.surface;
        foregroundColor = AppColors.text;
        borderSide = const BorderSide(color: AppColors.border, width: 1.5);
        if (isInteractive) {
          shadows = const [
            BoxShadow(
              color: Color(0x0F000000),
              offset: Offset(0, 1),
              blurRadius: 3,
            ),
          ];
        }
        break;
      case AppButtonVariant.danger:
        backgroundColor = AppColors.err;
        foregroundColor = Colors.white;
        borderSide = BorderSide.none;
        if (isInteractive) {
          shadows = const [
            BoxShadow(
              color: Color(0x33EF4444),
              offset: Offset(0, 3),
              blurRadius: 10,
            ),
          ];
        }
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.brand;
        borderSide = BorderSide.none;
        break;
    }

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: AppSpacing.sm)],
          Text(
            text,
            style: AppTypography.buttonMd(
              color: isInteractive
                  ? foregroundColor
                  : foregroundColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      );
    }

    final button = Container(
      width: isFullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        color: isInteractive
            ? backgroundColor
            : backgroundColor.withValues(
                alpha: variant == AppButtonVariant.ghost ? 0 : 0.6,
              ),
        borderRadius: radius,
        border: borderSide != BorderSide.none
            ? Border.fromBorderSide(borderSide)
            : null,
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isInteractive ? onPressed : null,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: content,
          ),
        ),
      ),
    );

    return button;
  }
}

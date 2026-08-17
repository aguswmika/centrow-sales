import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

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
  }) : variant = AppButtonVariant.ghost;

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = onPressed != null && !isLoading;

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

    return Container(
      width: isFullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderMd,
        boxShadow: shadows,
      ),
      child: Material(
        color: isInteractive
            ? backgroundColor
            : backgroundColor.withValues(
                alpha: variant == AppButtonVariant.ghost ? 0 : 0.6,
              ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
          side: borderSide,
        ),
        child: InkWell(
          onTap: isInteractive ? onPressed : null,
          borderRadius: AppRadius.borderMd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}

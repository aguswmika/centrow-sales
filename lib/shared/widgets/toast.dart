import 'package:flutter/material.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/theme/app_spacing.dart';
import 'package:centrow_sales/shared/theme/app_typography.dart';

void showAppToast(
  BuildContext context,
  String message, {
  bool isError = false,
  bool isSuccess = false,
  Duration duration = const Duration(seconds: 3),
}) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  scaffoldMessenger.hideCurrentSnackBar();

  final Color bgColor = isError
      ? AppColors.err
      : isSuccess
      ? AppColors.ok
      : AppColors.text;

  final IconData iconData = isError
      ? Icons.error_outline_rounded
      : isSuccess
      ? Icons.check_circle_outline_rounded
      : Icons.info_outline_rounded;

  scaffoldMessenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      duration: duration,
      content: Row(
        children: [
          Icon(iconData, color: Colors.white, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMd(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}

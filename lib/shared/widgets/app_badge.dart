import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';

enum AppBadgeVariant { ok, warn, err, info, brand, neutral }

class AppBadge extends StatelessWidget {
  final String text;
  final AppBadgeVariant variant;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const AppBadge({
    super.key,
    required this.text,
    this.variant = AppBadgeVariant.brand,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.0),
  });

  const AppBadge.ok({
    super.key,
    required this.text,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.0),
  }) : variant = AppBadgeVariant.ok;

  const AppBadge.warn({
    super.key,
    required this.text,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.0),
  }) : variant = AppBadgeVariant.warn;

  const AppBadge.err({
    super.key,
    required this.text,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.0),
  }) : variant = AppBadgeVariant.err;

  const AppBadge.info({
    super.key,
    required this.text,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.0),
  }) : variant = AppBadgeVariant.info;

  const AppBadge.brand({
    super.key,
    required this.text,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.0),
  }) : variant = AppBadgeVariant.brand;

  const AppBadge.neutral({
    super.key,
    required this.text,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.0),
  }) : variant = AppBadgeVariant.neutral;

  factory AppBadge.fromType(String type, String text) {
    final variant = switch (type.toLowerCase()) {
      'ok' || 'success' || 'disetujui' || 'aktif' => AppBadgeVariant.ok,
      'warn' || 'warning' || 'negosiasi' => AppBadgeVariant.warn,
      'err' || 'danger' || 'critical' => AppBadgeVariant.err,
      'info' || 'dikirim' => AppBadgeVariant.info,
      'brand' => AppBadgeVariant.brand,
      _ => AppBadgeVariant.neutral,
    };
    return AppBadge(text: text, variant: variant);
  }

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (variant) {
      AppBadgeVariant.ok => (const Color(0x1F10B981), const Color(0xFF059669)),
      AppBadgeVariant.warn => (
        const Color(0x24BC7B43),
        const Color(0xFF92580F),
      ),
      AppBadgeVariant.err => (const Color(0x1FEF4444), const Color(0xFFDC2626)),
      AppBadgeVariant.info => (
        const Color(0x1F3B82F6),
        const Color(0xFF2563EB),
      ),
      AppBadgeVariant.brand => (AppColors.brand10, AppColors.brand),
      AppBadgeVariant.neutral => (const Color(0x248C8E8B), AppColors.sec),
    };

    return Container(
      padding: padding,
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.borderPill),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.02,
        ),
      ),
    );
  }
}

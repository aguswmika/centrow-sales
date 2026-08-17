import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  // Headings & Display (Plus Jakarta Sans)
  static TextStyle display({
    Color color = AppColors.text,
    FontWeight fontWeight = FontWeight.w800,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: 52,
    fontWeight: fontWeight,
    color: color,
    height: 1.15,
  );

  static TextStyle numericLg({
    Color color = AppColors.text,
    FontWeight fontWeight = FontWeight.w800,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: 40,
    fontWeight: fontWeight,
    color: color,
    height: 1.2,
  );

  static TextStyle heading1({
    Color color = AppColors.text,
    FontWeight fontWeight = FontWeight.w800,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: fontWeight,
    color: color,
    height: 1.25,
  );

  static TextStyle heading2({
    Color color = AppColors.text,
    FontWeight fontWeight = FontWeight.w700,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: fontWeight,
    color: color,
    height: 1.3,
  );

  static TextStyle heading3({
    Color color = AppColors.text,
    FontWeight fontWeight = FontWeight.w700,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: fontWeight,
    color: color,
    height: 1.35,
  );

  static TextStyle sectionTitle({
    Color color = AppColors.text,
    FontWeight fontWeight = FontWeight.w700,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: fontWeight,
    color: color,
    height: 1.4,
  );

  // Body & Content (Inter)
  static TextStyle bodyLg({
    Color color = AppColors.text,
    FontWeight fontWeight = FontWeight.w500,
  }) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: fontWeight,
    color: color,
    height: 1.45,
  );

  static TextStyle bodyMd({
    Color color = AppColors.text,
    FontWeight fontWeight = FontWeight.w500,
  }) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: fontWeight,
    color: color,
    height: 1.45,
  );

  static TextStyle bodySm({
    Color color = AppColors.sec,
    FontWeight fontWeight = FontWeight.w500,
  }) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: fontWeight,
    color: color,
    height: 1.4,
  );

  static TextStyle labelCaps({
    Color color = AppColors.sec,
    FontWeight fontWeight = FontWeight.w600,
  }) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: 0.72,
  );

  static TextStyle caption({
    Color color = AppColors.muted,
    FontWeight fontWeight = FontWeight.w500,
  }) => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: fontWeight,
    color: color,
    height: 1.35,
  );

  // Buttons & Controls
  static TextStyle buttonLg({
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w700,
  }) => GoogleFonts.inter(fontSize: 16, fontWeight: fontWeight, color: color);

  static TextStyle buttonMd({
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w600,
  }) => GoogleFonts.inter(fontSize: 14, fontWeight: fontWeight, color: color);

  static TextStyle buttonSm({
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w600,
  }) => GoogleFonts.inter(fontSize: 13, fontWeight: fontWeight, color: color);

  static TextStyle inputText({
    Color color = AppColors.text,
    FontWeight fontWeight = FontWeight.w400,
  }) => GoogleFonts.inter(fontSize: 14, fontWeight: fontWeight, color: color);

  // Flutter TextTheme builder
  static TextTheme createTextTheme() {
    return TextTheme(
      displayLarge: display(),
      displayMedium: numericLg(),
      headlineLarge: heading1(),
      headlineMedium: heading2(),
      headlineSmall: heading3(),
      titleMedium: sectionTitle(),
      bodyLarge: bodyLg(),
      bodyMedium: bodyMd(),
      bodySmall: bodySm(),
      labelLarge: buttonMd(color: AppColors.text),
      labelMedium: labelCaps(),
      labelSmall: caption(),
    );
  }
}

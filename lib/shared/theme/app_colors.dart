import 'package:flutter/material.dart';

abstract final class AppColors {
  // Page & Surfaces
  static const Color bg = Color(0xFFF8F8F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color subtle = Color(0xFFF2F3EE);

  // Brand Palette
  static const Color brand = Color(0xFF1E40AF);
  static const Color brandDark = Color(0xFF1D4ED8);
  static const Color brand10 = Color(0x1A1E40AF);
  static const Color brand05 = Color(0x0D1E40AF);

  // Typography Colors
  static const Color text = Color(0xFF181A19);
  static const Color sec = Color(0xFF5A5D5A);
  static const Color muted = Color(0xFF8C8E8B);

  // Borders
  static const Color border = Color(0xFFE4E5DF);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // Status & Feedback
  static const Color ok = Color(0xFF10B981);
  static const Color warn = Color(0xFFBC7B43);
  static const Color err = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Aliases for convenience & backward compatibility
  static const Color card = surface;
  static const Color cardAlt = subtle;
  static const Color accent = brand;
  static const Color accentDark = brandDark;
  static const Color textPrimary = text;
  static const Color textSecondary = sec;
  static const Color textMuted = sec;
  static const Color textDim = muted;
  static const Color success = ok;
  static const Color warning = warn;
  static const Color danger = err;
}

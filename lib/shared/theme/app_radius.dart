import 'package:flutter/material.dart';

abstract final class AppRadius {
  // Raw values (matching tablet.css)
  static const double rSm = 8.0;
  static const double rMd = 12.0;
  static const double rLg = 16.0;
  static const double rXl = 22.0;
  static const double rPill = 9999.0;

  // Radius objects
  static const Radius radiusSm = Radius.circular(rSm);
  static const Radius radiusMd = Radius.circular(rMd);
  static const Radius radiusLg = Radius.circular(rLg);
  static const Radius radiusXl = Radius.circular(rXl);
  static const Radius radiusPill = Radius.circular(rPill);

  // BorderRadius objects
  static const BorderRadius borderSm = BorderRadius.all(radiusSm);
  static const BorderRadius borderMd = BorderRadius.all(radiusMd);
  static const BorderRadius borderLg = BorderRadius.all(radiusLg);
  static const BorderRadius borderXl = BorderRadius.all(radiusXl);
  static const BorderRadius borderPill = BorderRadius.all(radiusPill);
}

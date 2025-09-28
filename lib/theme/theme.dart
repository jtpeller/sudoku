import 'package:flutter/material.dart';

class ThemeValues {
  ////////////////////////////////////
  ///   FROSTED GLASS PARAMETERS   ///
  ////////////////////////////////////

  /// Border Radii
  static const double circularRadius = 100;
  static const double squircleRadius = 10;

  /// Blurs
  static const double blurStrong = 10;
  static const double blurMid = 5;
  static const double blurWeak = 2.5;

  /// Border Widths
  static const double bWidthThick = 6;
  static const double bWidthMid = 3;
  static const double bWidthThin = 1;

  /// Alphas
  static const int fullAlpha = 255;
  static const int alphaStronger = 200;
  static const int alphaStrong = 150;
  static const int alphaMid = 100;
  static const int alphaWeak = 50;
  static const int alphaWeaker = 25;
  static const int transparent = 0;

  ////////////////////////////////////
  ///     SPACINGS AND RATIOS      ///
  ////////////////////////////////////

  /// Cross Axis, Main Axis, Wrap Spacings
  static const double noSpacing = 0.0;
  static const double spacingSuperCozy = 1.0;
  static const double spacingCozy = 3.0;
  static const double spacingMid = 5.0;
  static const double spacingSpacy = 8.0;
  static const double spacingSuperSpacy = 12.0;

  /// Aspect Ratios
  static const double gridBoxRatio = 1.1;
  static const double squareRatio = 1.0;

  /// Number Button Ratio has to be based on screen size
  static double getNumberButtonRatio(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 500) {
      return 1.5;
    } else {
      return 2.0;
    }
  }
}

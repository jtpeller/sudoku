import 'package:flutter/material.dart';
import 'colors.dart';

abstract class ThemeStyle {
  static const String mainFontFamily = 'Inter';
  static const String gridFontFamily = 'Montserrat';
  static const String candidateFontFamily = 'monospace';
  static const double gridNormalBorder = 1.0;
  static const double gridThickBorder = 3.0;

  /// breakpoints by screen size
  static const double bpXS = 350.0;
  static const double bpSM = 500.0;
  static const double bpMD = 750.0;
  static const double bpLG = 1000.0;
  static const double bpXL = 1440.0;
  static const double bpXXL = 1920.0;

  /////////////////////////////////
  ///        TEXT STYLES        ///
  /////////////////////////////////

  static double getTextFactor(double screenSize) {
    // Define the range for fluid scaling.
    const double minWidth = bpXS; // 350
    const double maxWidth = bpLG; // 1000
    const double minScale = 1.0;
    const double maxScale = 1.8;

    // Calculate the interpolation factor (0.0 to 1.0)
    double t = ((screenSize - minWidth) / (maxWidth - minWidth)).clamp(0.0, 1.0);

    // Interpolate linearly between minScale and maxScale
    return minScale + (maxScale - minScale) * t;
  }

  static double getFontSize(BuildContext? context, double baseSize, [double multiplier = 1.0]) {
    // Use shortestSide for a more consistent feel across orientations, or stick to width.
    // shortestSide is better for elements that are constrained by both dimensions (like the Sudoku grid).
    final double screenDimension =
        context != null ? MediaQuery.of(context).size.shortestSide : 600.0;

    return baseSize * multiplier * getTextFactor(screenDimension);
  }

  static TextStyle gameTitle(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 24.0),
      height: 1.5,
      letterSpacing: 2.0,
      fontVariations: [FontVariation('wght', 700)],
    );
  }

  static TextStyle subtitle(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 18.0),
      height: 1.5,
      letterSpacing: 2.0,
      fontVariations: [FontVariation('wght', 700)],
    );
  }

  static TextStyle mediumGameText(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 14.0),
      height: 1.0,
      fontVariations: [FontVariation('wght', 400)],
    );
  }

  static TextStyle smallGameText(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 12.0),
      height: 1.0,
      fontVariations: [FontVariation('wght', 300)],
    );
  }

  static TextStyle tinyText(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 11.0),
      height: 1.0,
      fontVariations: [FontVariation('wght', 300)],
    );
  }

  static TextStyle option(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 14.0),
      height: 1.2,
      fontVariations: [FontVariation('wght', 700)],
    );
  }

  /// Italicized text style for options
  static TextStyle helperText(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 12.0),
      height: 1.2,
      fontVariations: [FontVariation('wght', 400)],
      fontStyle: FontStyle.italic,
    );
  }

  static TextStyle tooltip(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTooltipText(context),
      fontSize: getFontSize(context, 12.0),
      height: 1.5,
      fontVariations: [FontVariation('wght', 600)],
    );
  }

  static TextStyle badgeCount(BuildContext context) {
    return TextStyle(
      fontFamily: gridFontFamily,
      // color is ignored by Badge.count; it's set separately.
      fontSize: getFontSize(context, 10.0),
      fontVariations: [FontVariation('wght', 500)],
    );
  }

  static TextStyle largeButtonText(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 14.0),
      height: 1,
      fontVariations: [FontVariation('wght', 900)],
    );
  }

  static TextStyle mediumButtonText(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 12.0),
      height: 1,
      fontVariations: [FontVariation('wght', 500)],
    );
  }

  static TextStyle smallButtonText(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 11.0),
      height: 1,
      fontVariations: [FontVariation('wght', 400)],
    );
  }

  static TextStyle candidateText(BuildContext context, {int sideLength = 9}) {
    // Candidates need to scale even more aggressively to fit multiple in one cell.
    double densityFactor = 9.0 / sideLength;
    return TextStyle(
      fontFamily: candidateFontFamily,
      fontSize: getFontSize(context, 5.0, densityFactor),
      color: ThemeColor.getTextBodyColor(context),
      fontVariations: [FontVariation('wght', 500)],
    );
  }

  // style for pre-filled grid cells
  static TextStyle fixedGridText(BuildContext context, {int sideLength = 9}) {
    // Adjust font size based on grid density. We use 9 as the baseline side length.
    double densityFactor = 9.0 / sideLength;
    return TextStyle(
      fontFamily: gridFontFamily,
      color: ThemeColor.getTextFixedColor(context),
      fontSize: getFontSize(context, 14.0, densityFactor),
      fontVariations: [FontVariation('wght', 400)],
    );
  }

  // style for user-entered grid cells
  static TextStyle gridText(BuildContext context, {int sideLength = 9}) {
    // Adjust font size based on grid density.
    double densityFactor = 9.0 / sideLength;
    return TextStyle(
      fontFamily: gridFontFamily,
      color: ThemeColor.getTextGridColor(context),
      fontSize: getFontSize(context, 14.0, densityFactor),
      fontVariations: [FontVariation('wght', 700)],
    );
  }

  // style for number buttons
  static TextStyle numberButtonText(BuildContext context, {int sideLength = 9}) {
    return fixedGridText(
      context,
      sideLength: sideLength,
    ).copyWith(color: ThemeColor.getTextBodyColor(context));
  }

  /////////////////////////////////
  ///        THEME DATA         ///
  /////////////////////////////////

  /// Number Button Ratio has to be based on screen size
  static double getNumberButtonRatio(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < bpSM) {
      return 2.0;
    } else {
      return 1.8;
    }
  }

  /// Retrieves the theme data for the corresponding difficulty defined by [diff].
  static OutlinedButtonThemeData difficultyButtonThemeData(BuildContext context, String diff) {
    Color color = ThemeColor.getMenuButtonColor(context, difficulty: diff);
    int factor = Theme.of(context).brightness == Brightness.dark ? 16 : 8;
    Color buttonColor = color.withAlpha(255 ~/ factor);

    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(300.0, 30.0),
        foregroundColor: color,
        backgroundColor: buttonColor,
        shadowColor: ThemeColor.getBoxShadowColor(context),
        textStyle: largeButtonText(context),
        padding: EdgeInsets.all(20),
        side: BorderSide(color: color),
      ),
    );
  }

  /// Defines the theme data for candidate buttons.
  static TextButtonThemeData candidateButtonThemeData(BuildContext context) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ThemeColor.getTextBodyColor(context),
        textStyle: largeButtonText(context),
        padding: EdgeInsets.all(20),
      ),
    );
  }

  /// Defines the theme data for icon buttons.
  static IconButtonThemeData iconButtonThemeData(BuildContext context) {
    // scale using screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = 24.0 * getTextFactor(screenWidth);

    return IconButtonThemeData(
      style: IconButton.styleFrom(
        iconSize: iconSize,
        foregroundColor: ThemeColor.getTextBodyColor(context),
      ),
    );
  }
}

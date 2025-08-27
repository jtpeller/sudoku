import 'package:flutter/material.dart';
import 'colors.dart';

abstract class ThemeStyle {
  static const String mainFontFamily = 'Inter';
  static const String gridFontFamily = 'Montserrat';
  static const double gridNormalBorder = 0.0;
  static const double gridThickBorder = 3.0;

  /// breakpoints by screen size
  static const double bpXS = 350.0;
  static const double bpSM = 500.0;
  static const double bpMD = 750.0;
  static const double bpLG = 1000.0;
  static const double bpXL = 1440.0;
  static const double bpXXL = 1920.0;

  /// font sizes by use
  static const double fontSizeXL = 32.0;
  static const double fontSizeLG = 28.0;
  static const double fontSizeMD = 24.0;
  static const double fontSizeSM = 20.0;
  static const double fontSizeXS = 16.0;

  /////////////////////////////////
  ///        TEXT STYLES        ///
  /////////////////////////////////

  static double getTextFactor(double screenSize, double initialFactor) {
    if (screenSize < bpXS) {
      return initialFactor * 0.7;
    } else if (screenSize < bpSM) {
      return initialFactor * 0.8;
    } else if (screenSize < bpMD) {
      return initialFactor;
    } else if (screenSize < bpLG) {
      return initialFactor * 1.05;
    } else if (screenSize < bpXL) {
      return initialFactor * 1.1;
    } else {
      return initialFactor * 1.2;
    }
  }

  static double getFontSize(BuildContext? context, double initialFactor, double baseFontSize) {
    // there are use cases for not utilizing context's width.
    if (context == null) {
      return fontSizeMD * getTextFactor(600, initialFactor);
    }

    // otherwise, compute the fontsize
    double screenWidth = MediaQuery.of(context).size.width;
    return (baseFontSize * getTextFactor(screenWidth, initialFactor));
  }

  static TextStyle gameTitle(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 1.25, fontSizeXL),
      height: 1.5,
      fontVariations: [FontVariation('wght', 700)],
    );
  }

  static TextStyle subtitle(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 1.0, fontSizeLG),
      height: 1.5,
      fontVariations: [FontVariation('wght', 300)],
    );
  }

  static TextStyle mediumGameText(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 1, fontSizeMD),
      height: 1.0,
      fontVariations: [FontVariation('wght', 400)],
    );
  }

  static TextStyle smallGameText(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 0.8, fontSizeSM),
      height: 1.0,
      fontVariations: [FontVariation('wght', 300)],
    );
  }

  static TextStyle tinyText(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 0.8, fontSizeXS),
      height: 1.0,
      fontVariations: [FontVariation('wght', 300)],
    );
  }

  static TextStyle option(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: 20,
      height: 1.0,
      fontVariations: [FontVariation('wght', 400)],
    );
  }

  /// Italicized text style for options
  static TextStyle helperText(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: 18,
      height: 1.0,
      fontVariations: [FontVariation('wght', 200)],
      fontStyle: FontStyle.italic,
    );
  }

  static TextStyle tooltip(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTooltipText(context),
      fontSize: 14,
      height: 1.5,
      fontVariations: [FontVariation('wght', 600)],
    );
  }

  static TextStyle buttonText(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 1.0, fontSizeSM),
      height: 1,
      fontVariations: [FontVariation('wght', 900)],
    );
  }

  static TextStyle smallButtonText(BuildContext context) {
    return TextStyle(
      fontFamily: mainFontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: getFontSize(context, 0.8, fontSizeSM),
      height: 1,
      fontVariations: [FontVariation('wght', 400)],
    );
  }

  static TextStyle candidateText(BuildContext context) {
    return TextStyle(
      fontFamily: gridFontFamily,
      fontSize: getFontSize(context, 0.75, fontSizeXS),
      color: ThemeColor.getTextBodyColor(context),
      fontVariations: [FontVariation('wght', 400)],
    );
  }

  // style for pre-filled grid cells
  static TextStyle fixedGridText(BuildContext context) {
    return TextStyle(
      fontFamily: gridFontFamily,
      color: ThemeColor.getTextFixedColor(context),
      fontSize: getFontSize(context, 1.2, fontSizeMD),
      fontVariations: [FontVariation('wght', 300)],
    );
  }

  // style for user-entered grid cells
  static TextStyle gridText(BuildContext context) {
    return TextStyle(
      fontFamily: gridFontFamily,
      color: ThemeColor.getTextGridColor(context),
      fontSize: getFontSize(context, 1.2, fontSizeMD),
      fontVariations: [FontVariation('wght', 500)],
    );
  }

  // style for number buttons
  static TextStyle numberButtonText(BuildContext context) {
    return fixedGridText(context).copyWith(color: ThemeColor.getTextBodyColor(context));
  }

  /////////////////////////////////
  ///        THEME DATA         ///
  /////////////////////////////////

  static OutlinedButtonThemeData menuButtonThemeData(BuildContext context, String diff) {
    Color color = ThemeColor.getMenuButtonColor(context, diff);
    int factor = Theme.of(context).brightness == Brightness.dark ? 16 : 8;
    Color buttonColor = color.withAlpha(255 ~/ factor);

    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(300.0, 30.0),
        foregroundColor: color,
        backgroundColor: buttonColor,
        shadowColor: ThemeColor.getBoxShadowColor(context),
        textStyle: buttonText(context),
        padding: EdgeInsets.all(20),
        side: BorderSide(color: color),
      ),
    );
  }

  static TextButtonThemeData candidateButtonThemeData(BuildContext context, bool isCandidateMode) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor:
            isCandidateMode
                ? ThemeColor.getAccentColor(context)
                : ThemeColor.getCellAccentColor(context),
        foregroundColor: ThemeColor.getTextBodyColor(context),
        textStyle: buttonText(context),
        padding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
          side: BorderSide(color: ThemeColor.getBorderColor(context)),
        ),
      ),
    );
  }

  static IconButtonThemeData iconButtonThemeData(BuildContext context) {
    // scale using screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double factor = 1;
    double iconSize = 40.0 * getTextFactor(screenWidth, factor);

    return IconButtonThemeData(
      style: IconButton.styleFrom(
        iconSize: iconSize,
        foregroundColor: ThemeColor.getTextBodyColor(context),
      ),
    );
  }
}

import 'package:flutter/material.dart';

// Change ThemeColor to a class with static methods that take BuildContext
class ThemeColor {
  /////////////////////////////////
  ///      COLORS BY THEME      ///
  /////////////////////////////////

  /// Dark mode colors
  // ... background colors
  static const Color accentDark = Color.fromARGB(255, 0, 89, 255);
  static const Color bgDark = Color.fromARGB(255, 26, 27, 34);

  // ... cell background colors
  static const Color cellBgDark = Color.fromARGB(255, 25, 25, 27);
  static const Color cellBgAccentDark = Color.fromARGB(255, 57, 58, 70);

  // ... cell state colors
  static const Color cellHighDark = Color.fromARGB(255, 21, 29, 63);
  static const Color cellSelectedDark = Color.fromARGB(255, 0, 71, 204);
  static const Color cellCorrectDark = Color.fromARGB(255, 15, 73, 10);
  static const Color cellHintedDark = Color.fromARGB(255, 151, 168, 0);
  static const Color cellWrongDark = Color.fromARGB(255, 126, 5, 5);
  static const Color cellValueSelectedDark = Color.fromARGB(255, 165, 82, 5);

  // ... text colors
  static const Color textBodyDark = Color.fromARGB(255, 228, 228, 228);
  static const Color textFixedDark = Color.fromARGB(255, 24, 255, 205);
  static const Color textCandidateDark = Color.fromARGB(255, 185, 185, 185);

  // ... border and shadow colors
  static const Color borderDark = Color.fromARGB(255, 131, 131, 131);
  static const Color boxShadowDark = borderDark;

  /// Light mode colors
  // ... background colors
  static const Color accentLite = Color.fromARGB(255, 35, 174, 255);
  static const Color bgLite = Color.fromARGB(255, 240, 240, 240);

  // ... cell background colors
  static const Color cellBgLite = Color.fromARGB(255, 255, 255, 255);
  static const Color cellBgAccentLite = Color.fromARGB(255, 216, 216, 216);

  // ... cell state colors
  static const Color cellHighLite = Color.fromARGB(255, 171, 245, 255);
  static const Color cellCorrectLite = Color.fromARGB(255, 99, 224, 99);
  static const Color cellHintLite = Color.fromARGB(255, 226, 236, 78);
  static const Color cellWrongLite = Color.fromARGB(255, 228, 39, 39);
  static const Color cellValueSelectedLite = Color.fromARGB(255, 255, 150, 52);

  // ... text colors
  static const Color textBodyLite = Color.fromARGB(255, 30, 30, 30);
  static const Color textFixedLite = Color.fromARGB(255, 35, 39, 37);
  static const Color textCandidateLite = Color.fromARGB(255, 87, 87, 87);

  // ... border and shadow colors
  static const Color borderLite = Color.fromARGB(255, 140, 140, 140);
  static const Color boxShadowLite = borderLite;

  /// mode independent colors
  static const Color bgTooltip = Color.fromARGB(255, 197, 197, 202);
  static const Color tooltipText = Color.fromARGB(255, 19, 19, 19);
  static const Color transparent = Color.fromARGB(0, 0, 0, 0);

  /////////////////////////////////
  ///   COLOR GETTERS (THEME)   ///
  /////////////////////////////////

  /// background colors
  static Color getAccentColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? accentDark : accentLite;
  }

  static Color getBgColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? bgDark : bgLite;
  }

  /// cell colors
  static Color getCellBgColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? cellBgDark : cellBgLite;
  }

  static Color getCellAccentColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? cellBgAccentDark : cellBgAccentLite;
  }

  /// cell state colors
  static Color getCellHighlightColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? cellHighDark : cellHighLite;
  }

  static Color getCellSelectedColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cellSelectedDark
        : cellValueSelectedLite;
  }

  static Color getCellCorrectColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? cellCorrectDark : cellCorrectLite;
  }

  static Color getCellHintColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? cellHintedDark : cellHintLite;
  }

  static Color getCellWrongColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? cellWrongDark : cellWrongLite;
  }

  static Color getCellValueSelectedColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cellValueSelectedDark
        : cellValueSelectedLite;
  }

  /// text colors
  static Color getTextFixedColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? textFixedDark : textFixedLite;
  }

  static Color getTextBodyColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? textBodyDark : textBodyLite;
  }

  static Color getTooltipText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? textBodyLite : textBodyDark;
  }

  static Color getTextCandidateColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? textCandidateDark : textCandidateLite;
  }

  /// border and shadow colors
  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? borderDark : borderLite;
  }

  static Color getBoxShadowColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? boxShadowDark : boxShadowLite;
  }

  /// OTHER GETTERS
  static Color getMenuButtonColor(BuildContext context, String difficulty) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    switch (difficulty) {
      case 'Beginner':
        return isDarkMode ? Color.fromARGB(255, 234, 0, 255) : Color.fromARGB(255, 129, 78, 223);
      case 'Easy':
        return isDarkMode ? Color.fromARGB(255, 0, 183, 255) : Color.fromARGB(255, 15, 104, 187);
      case 'Medium':
        return isDarkMode ? Color.fromARGB(255, 9, 255, 0) : Color.fromARGB(255, 6, 179, 0);
      case 'Hard':
        return isDarkMode ? Color.fromARGB(255, 219, 223, 5) : Color.fromARGB(255, 167, 170, 0);
      case 'Expert':
        return isDarkMode ? Color.fromARGB(255, 255, 115, 0) : Color.fromARGB(255, 204, 92, 0);
      case 'Impossible':
        return isDarkMode ? Color.fromARGB(255, 192, 0, 0) : Color.fromARGB(255, 197, 0, 0);
      default:
        return isDarkMode ? Color.fromARGB(255, 255, 255, 255) : Color.fromARGB(255, 0, 0, 0);
    }
  }
}

abstract class ThemeStyle {
  static const String fontFamily = 'Montserrat';
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
  static const double gameTitleSize = 32.0;
  static const double subtitleSize = 24.0;
  static const double mediumGameTextSize = 24.0;
  static const double smallGameTextSize = 20.0;
  static const double tinyTextSize = 16.0;

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

  static TextStyle gameTitle(BuildContext context) {
    // compute font size based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double factor = 1.25;
    double fontSize = gameTitleSize * getTextFactor(screenWidth, factor);

    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: fontSize,
      height: 1.5,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle subtitle(BuildContext context) {
    // compute font size based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double factor = 1.15;
    double fontSize = subtitleSize * getTextFactor(screenWidth, factor);

    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: fontSize,
      height: 1.5,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle mediumGameText(BuildContext context) {
    // compute font size based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double factor = 1;
    double fontSize = mediumGameTextSize * getTextFactor(screenWidth, factor);

    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: fontSize,
      height: 1.0,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle smallGameText(BuildContext context) {
    // compute font size based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double factor = 0.9;
    double fontSize = smallGameTextSize * getTextFactor(screenWidth, factor);

    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: fontSize,
      height: 1.0,
      fontWeight: FontWeight.w300,
    );
  }

  static TextStyle tinyText(BuildContext context) {
    // compute font size based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double factor = 0.8;
    double fontSize = tinyTextSize * getTextFactor(screenWidth, factor);

    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: fontSize,
      height: 1.0,
      fontWeight: FontWeight.w200,
    );
  }

  static TextStyle option(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: 20,
      height: 1.0,
      fontWeight: FontWeight.w400,
    );
  }

  /// Italicized text style for options
  static TextStyle helperText(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: 18,
      height: 1.0,
      fontWeight: FontWeight.w200,
      fontStyle: FontStyle.italic,
    );
  }

  static TextStyle tooltip(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getTooltipText(context),
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle buttonText(BuildContext context) {
    // compute font size based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double factor = 1;
    double fontSize = smallGameTextSize * getTextFactor(screenWidth, factor);

    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: fontSize,
      height: 1,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle candidateText(BuildContext context) {
    // compute font size based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double factor = 0.75;
    double fontSize = tinyTextSize * getTextFactor(screenWidth, factor);

    return TextStyle(
      fontSize: fontSize,
      color: ThemeColor.getTextBodyColor(context),
      fontWeight: FontWeight.w400,
    );
  }

  // style for pre-filled grid cells
  static TextStyle fixedGridText(BuildContext context) {
    // compute font size based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double factor = 1;
    double fontSize = mediumGameTextSize * getTextFactor(screenWidth, factor);

    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getTextFixedColor(context),
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
    );
  }

  // style for user-entered grid cells
  static TextStyle gridText(BuildContext context) {
    // compute font size based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double factor = 1;
    double fontSize = mediumGameTextSize * getTextFactor(screenWidth, factor);

    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getTextBodyColor(context),
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
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
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(300.0, 30.0),
        foregroundColor: color,
        backgroundColor: ThemeColor.transparent,
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

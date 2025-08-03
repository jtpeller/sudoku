import 'package:flutter/material.dart';

// Change ThemeColor to a class with static methods that take BuildContext
class ThemeColor {
  // Dark mode colors
  static const Color accentDark = Color.fromARGB(255, 0, 89, 255);
  static const Color bgDark = Color.fromARGB(255, 26, 27, 34);
  static const Color bgAccentDark = Color.fromARGB(255, 55, 57, 78);
  static const Color bgHighDark = Color.fromARGB(255, 21, 29, 63);
  static const Color bodyTextDark = Color.fromARGB(255, 228, 228, 228);
  static const Color bodyTextLightDark = Color.fromARGB(255, 0, 0, 0);
  static const Color borderDark = Color.fromARGB(255, 131, 131, 131);
  static const Color boxShadowDark = borderDark;
  static const Color correctDark = Color.fromARGB(255, 15, 73, 10);
  static const Color fixedTextDark = Color.fromARGB(255, 24, 255, 205);
  static const Color hintDark = Color.fromARGB(255, 151, 168, 0);
  static const Color primaryDark = Color.fromARGB(255, 0, 162, 255);
  static const Color wrongDark = Color.fromARGB(255, 126, 5, 5);
  static const Color transparent = Color.fromARGB(0, 0, 0, 0);

  // Light mode colors
  static const Color accentLight = Color.fromARGB(255, 35, 174, 255);
  static const Color bgLight = Color.fromARGB(255, 240, 240, 240);
  static const Color bgAccentLight = Color.fromARGB(255, 202, 202, 202);
  static const Color bgHiLight = Color.fromARGB(255, 171, 245, 255);
  static const Color bodyTextLight = Color.fromARGB(255, 30, 30, 30);
  static const Color borderLight = Color.fromARGB(255, 140, 140, 140);
  static const Color boxShadowLight = borderLight;
  static const Color correctLight = Color.fromARGB(255, 99, 224, 99);
  static const Color fixedTextLight = Color.fromARGB(255, 0, 76, 216);
  static const Color hintLight = Color.fromARGB(255, 226, 236, 78);
  static const Color primaryLight = Color.fromARGB(255, 0, 140, 255);
  static const Color wrongLight = Color.fromARGB(255, 228, 39, 39);

  /// mode independent colors
  static const Color bgTooltip = Color.fromARGB(255, 197, 197, 202);
  static const Color tooltipText = Color.fromARGB(255, 19, 19, 19);

  /// GETTERS FOR COLORS BASED ON THEME

  static Color getAccentColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? accentDark : accentLight;
  }

  static Color getBgColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? bgDark : bgLight;
  }

  static Color getBgColorLite(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? bgAccentDark : bgAccentLight;
  }

  static Color getBgColorHigh(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? bgHighDark : bgHiLight;
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? borderDark : borderLight;
  }

  static Color getMainColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? primaryDark : primaryLight;
  }

  static Color getHintColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? hintDark : hintLight;
  }

  static Color getCorrectColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? correctDark : correctLight;
  }

  static Color getWrongColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? wrongDark : wrongLight;
  }

  static Color getBodyText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? bodyTextDark : bodyTextLight;
  }

  static Color getTooltipText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? bodyTextLight : bodyTextDark;
  }

  static Color getFixedCellColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? fixedTextDark : fixedTextLight;
  }

  static Color getBoxShadowColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? boxShadowDark : boxShadowLight;
  }

  /// OTHER GETTERS
  static Color getButtonColor(BuildContext context, String difficulty) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    switch (difficulty) {
      case 'Beginner':
        return isDarkMode
            ? Color.fromARGB(255, 234, 0, 255)
            : Color.fromARGB(255, 129, 78, 223);
      case 'Easy':
        return isDarkMode
            ? Color.fromARGB(255, 0, 183, 255)
            : Color.fromARGB(255, 15, 104, 187);
      case 'Medium':
        return isDarkMode
            ? Color.fromARGB(255, 9, 255, 0)
            : Color.fromARGB(255, 6, 179, 0);
      case 'Hard':
        return isDarkMode
            ? Color.fromARGB(255, 219, 223, 5)
            : Color.fromARGB(255, 167, 170, 0);
      case 'Expert':
        return isDarkMode
            ? Color.fromARGB(255, 255, 115, 0)
            : Color.fromARGB(255, 204, 92, 0);
      case 'Impossible':
        return isDarkMode
            ? Color.fromARGB(255, 192, 0, 0)
            : Color.fromARGB(255, 197, 0, 0);
      default:
        return isDarkMode
            ? Color.fromARGB(255, 255, 255, 255)
            : Color.fromARGB(255, 0, 0, 0);
    }
  }
}

abstract class ThemeStyle {
  static const String fontFamily = 'Montserrat';
  static const double gridNormalBorder = 0.0;
  static const double gridThickBorder = 3.0;

  static TextStyle gameTitle(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getBodyText(context),
      fontSize: 36,
      height: 1.5,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle subtitle(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getBodyText(context),
      fontSize: 30,
      height: 1.5,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle mediumGameText(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getBodyText(context),
      fontSize: 24,
      height: 2,
      fontWeight: FontWeight.w300,
    );
  }

  static TextStyle smallGameText(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getBodyText(context),
      fontSize: 20,
      height: 1.5,
      fontWeight: FontWeight.w300,
    );
  }

  static TextStyle tinyText(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getBodyText(context),
      fontSize: 16,
      height: 1.0,
      fontWeight: FontWeight.w200,
    );
  }

  static TextStyle option(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getBodyText(context),
      fontSize: 20,
      height: 1.0,
      fontWeight: FontWeight.w400,
    );
  }
  
  /// Italicized text style for options
  static TextStyle helperText(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getBodyText(context),
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
    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getBodyText(context),
      fontSize: 20,
      height: 1,
      fontWeight: FontWeight.w500,
    );
  }

  // style for pre-filled grid cells
  static TextStyle fixedGridText(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getFixedCellColor(context),
      fontSize: 25,
      fontWeight: FontWeight.w700,
    );
  }

  // style for user-entered grid cells
  static TextStyle gridText(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getBodyText(context),
      fontSize: 25,
      fontWeight: FontWeight.w400,
    );
  }

  // style for number buttons
  static TextStyle numberButtonText(BuildContext context) {
    return fixedGridText(context).copyWith(
      color: ThemeColor.getBodyText(context),
    );
  }

  static OutlinedButtonThemeData menuButtonThemeData(BuildContext context, String diff) {
    Color color = ThemeColor.getButtonColor(context, diff);
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

  static OutlinedButtonThemeData gameButtonThemeData(BuildContext context) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(200.0, 50.0),
        foregroundColor: ThemeColor.getBodyText(context),
        backgroundColor: ThemeColor.getBgColorLite(context),
        textStyle: buttonText(context),
        padding: EdgeInsets.all(25),
        side: BorderSide(color: ThemeColor.getBorderColor(context)),
      ),
    );
  }

  static OutlinedButtonThemeData gridButtonThemeData(BuildContext context) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: ThemeColor.getBgColorLite(context),
        fixedSize: Size(50.0, 50.0),
        foregroundColor: ThemeColor.getBodyText(context),
        padding: EdgeInsets.all(0),
        //shape: CircleBorder(),
        side: BorderSide(color: ThemeColor.getBorderColor(context)),
        textStyle: buttonText(context),
      ),
    );
  }

  static IconButtonThemeData splashIconThemeData(BuildContext context) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: Size(75.0, 75.0),
        iconSize: 40.0,
        foregroundColor: ThemeColor.getBodyText(context),
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: ThemeColor.getBorderColor(context)),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  static IconButtonThemeData iconButtonThemeData(BuildContext context) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: Size(75.0, 75.0),
        iconSize: 40.0,
        foregroundColor: ThemeColor.getBodyText(context),
      ),
    );
  }
}

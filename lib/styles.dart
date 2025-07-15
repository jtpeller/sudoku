import 'package:flutter/material.dart';

// Change ThemeColor to a class with static methods that take BuildContext
class ThemeColor {
  // Dark mode colors
  static const Color accentColorDark = Color.fromARGB(255, 0, 89, 255);
  static const Color bgColorDark = Color.fromARGB(255, 26, 27, 34);
  static const Color bgColorAccentDark = Color.fromARGB(255, 55, 57, 78);
  static const Color bgColorHighDark = Color.fromARGB(255, 21, 29, 63);
  static const Color bodyTextDark = Color.fromARGB(255, 228, 228, 228);
  static const Color borderColorDark = Color.fromARGB(255, 103, 104, 114);
  static const Color borderColorHiDark = Color.fromARGB(255, 23, 81, 116);
  static const Color correctColorDark = Color.fromARGB(255, 15, 73, 10);
  static const Color fixedCellColorDark = Color.fromARGB(255, 24, 255, 205);
  static const Color hintCellColorDark = Color.fromARGB(255, 110, 122, 0);
  static const Color mainColorDark = Color.fromARGB(255, 0, 162, 255);
  static const Color wrongColorDark = Color.fromARGB(255, 75, 14, 14);
  static const Color transparent = Color.fromARGB(0, 0, 0, 0);

  // Light mode colors
  static const Color accentColorLight = Color.fromARGB(255, 9, 195, 219);
  static const Color bgColorLight = Color.fromARGB(255, 240, 240, 240);
  static const Color bgColorAccentLight = Color.fromARGB(255, 202, 202, 202);
  static const Color bgColorHighLight = Color.fromARGB(255, 121, 230, 245);
  static const Color bodyTextLight = Color.fromARGB(255, 30, 30, 30);
  static const Color borderColorLight = Color.fromARGB(255, 100, 100, 100);
  static const Color borderColorHiLight = Color.fromARGB(255, 54, 138, 177);
  static const Color correctColorLight = Color.fromARGB(255, 82, 240, 82);
  static const Color fixedCellColorLight = Color.fromARGB(255, 0, 58, 165);
  static const Color hintCellColorLight = Color.fromARGB(255, 238, 250, 68);
  static const Color mainColorLight = Color.fromARGB(255, 0, 120, 220);
  static const Color wrongColorLight = Color.fromARGB(255, 255, 48, 48);

  // returns the background color (light vs dark)
  static Color getBgColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? bgColorDark : bgColorLight;
  }

  // returns the "lite" background color (grid's accent)
  static Color getBgColorLite(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? bgColorAccentDark : bgColorAccentLight;
  }

  // returns the highlighted background color (grid's highlighted background)
  static Color getBgColorHigh(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? bgColorHighDark : bgColorHighLight;
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? borderColorDark
        : const Color.fromRGBO(100, 100, 100, 1);
  }

  static Color getHighlightedBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? borderColorHiDark : borderColorHiLight;
  }

  static Color getAccentColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? accentColorDark : accentColorLight;
  }

  static Color getMainColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? mainColorDark : mainColorLight;
  }

  static Color getHintColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? hintCellColorDark : hintCellColorLight;
  }

  static Color getCorrectColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? correctColorDark : correctColorLight;
  }

  static Color getWrongColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? wrongColorDark : wrongColorLight;
  }

  static Color getBodyText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? bodyTextDark : bodyTextLight;
  }

  static Color getTooltipText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? bodyTextLight : bodyTextDark;
  }

  // New getter for fixed cell text color
  static Color getFixedCellColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? fixedCellColorDark
        : fixedCellColorLight;
  }
}

abstract class ThemeStyle {
  static const String fontFamily = 'Montserrat';
  static const double gridNormalBorder = 2.0;

  static TextStyle gameTitle(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getBodyText(context),
      fontSize: 50,
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

  static TextStyle option(BuildContext context) {
    return TextStyle(
      fontFamily: fontFamily,
      color: ThemeColor.getBodyText(context),
      fontSize: 24,
      height: 1.5,
      fontWeight: FontWeight.w200,
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
      fontSize: 25,
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

  static OutlinedButtonThemeData menuButtonThemeData(BuildContext context) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(200.0, 50.0),
        foregroundColor: ThemeColor.getAccentColor(context),
        backgroundColor: ThemeColor.transparent,
        textStyle: buttonText(context),
        padding: EdgeInsets.all(25),
        side: BorderSide(color: ThemeColor.getAccentColor(context)),
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
        shape: RoundedRectangleBorder(side: BorderSide.none),
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

import 'package:flutter/material.dart';

abstract class ThemeText {
  static const String fontFamily = 'Montserrat';

  static const TextStyle gameTitle = TextStyle(
    fontFamily: fontFamily,
    color: ThemeColor.bodyText,
    fontSize: 50,
    height: 1,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    color: ThemeColor.bodyText,
    fontSize: 20,
    height: 1,
    fontWeight: FontWeight.w500,
  );

  static OutlinedButtonThemeData menuButtonThemeData = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: Size(200.0, 50.0),
      foregroundColor: ThemeColor.accentColor,
      backgroundColor: ThemeColor.transparent,
      textStyle: buttonText,
      padding: EdgeInsets.all(25),
      side: const BorderSide(color: ThemeColor.accentColor),
    ),
  );
}

abstract class ThemeColor {
  static const Color bgColor = Color.fromARGB(255, 26, 27, 34);
  static const Color accentColor = Color.fromARGB(255, 0, 140, 255);
  static const Color mainColor = Color.fromARGB(255, 0, 162, 255);
  static const Color correctColor = Color.fromARGB(255, 21, 255, 0);
  static const Color wrongColor = Color.fromARGB(255, 255, 0, 0);
  static const Color bodyText = Color.fromARGB(255, 228, 228, 228);
  static const Color transparent = Color.fromARGB(0, 0, 0, 0);
}

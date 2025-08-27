import 'package:flutter/material.dart';

class ThemeColor {
  /////////////////////////////////
  ///      COLORS BY THEME      ///
  /////////////////////////////////

  /// Dark mode colors
  // ... background colors
  static const Color accentDark = Color.fromARGB(255, 0, 89, 255);
  static const Color bgDark = Color.fromARGB(255, 8, 8, 15);

  // ... cell background colors
  static const Color cellBgDark = Color.fromARGB(255, 16, 16, 24);
  static const Color cellBgAccentDark = Color.fromARGB(255, 69, 69, 90);

  // ... cell state colors
  static const Color cellHighDark = Color.fromARGB(255, 21, 29, 63);
  static const Color cellSelectedDark = Color.fromARGB(255, 0, 71, 204);
  static const Color cellCorrectDark = Color.fromARGB(255, 17, 206, 0);
  static const Color cellHintedDark = Color.fromARGB(255, 135, 150, 4);
  static const Color cellWrongDark = Color.fromARGB(255, 255, 26, 26);
  static const Color cellValueSelectedDark = Color.fromARGB(255, 83, 10, 133);

  // ... text colors
  static const Color textBodyDark = Color.fromARGB(255, 228, 228, 228);
  static const Color textGridDark = Color.fromARGB(255, 255, 48, 238);
  static const Color textFixedDark = Color.fromARGB(255, 255, 255, 255);
  static const Color textCandidateDark = Color.fromARGB(255, 185, 185, 185);

  // ... border and shadow colors
  static const Color borderDark = Color.fromARGB(255, 131, 131, 131);
  static const Color boxShadowDark = borderDark;

  /// Light mode colors
  // ... background colors
  static const Color accentLite = Color(0xFF50C7F7);
  static const Color bgLite = Color.fromARGB(255, 255, 255, 255);

  // ... cell background colors
  static const Color cellBgLite = Color.fromARGB(255, 255, 255, 255);
  static const Color cellBgAccentLite = Color.fromARGB(255, 216, 216, 216);

  // ... cell state colors
  static const Color cellHighLite = Color(0xFFABF5FF);
  static const Color cellCorrectLite = Color.fromARGB(255, 138, 255, 164);
  static const Color cellHintLite = Color(0xFFB5C900);
  static const Color cellWrongLite = Color.fromARGB(255, 161, 3, 3);
  static const Color cellValueSelectedLite = Color.fromARGB(255, 216, 173, 255);

  // ... text colors
  static const Color textBodyLite = Color(0xFF1E1E1E);
  static const Color textGridLite = Color.fromARGB(255, 5, 34, 199);
  static const Color textFixedLite = Color.fromARGB(255, 0, 0, 0);
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

  static Color getTextGridColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? textGridDark : textGridLite;
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

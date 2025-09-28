import 'package:flutter/material.dart';

class ThemeColor {
  /////////////////////////////////
  ///      COLORS BY THEME      ///
  /////////////////////////////////

  /// Dark mode colors
  // ... background colors
  static const Color accentDark = Color.fromARGB(255, 0, 89, 255);
  static const Color bgDark = Color.fromARGB(255, 8, 8, 15);
  static const Color startDark = Color.fromARGB(255, 4, 0, 15);
  static const Color appBarDark = Color.fromARGB(255, 0, 12, 8);

  // ... button colors
  static const Color iconButtonDark = cellBgDark;
  static const Color newGameAccentDark = Color.fromARGB(255, 68, 192, 57);
  static const Color restartAccentDark = Color.fromARGB(255, 255, 82, 82);
  static const Color helpAccentDark = Color.fromARGB(255, 64, 196, 255);
  static const Color hintAccentDark = Color.fromARGB(255, 255, 114, 71);
  static const Color optionsBtnAccentDark = Color.fromARGB(255, 209, 209, 209);

  // ... cell background colors
  static const Color cellBgDark = Color.fromARGB(255, 16, 16, 24);
  static const Color cellBgAccentDark = Color.fromARGB(255, 69, 69, 90);

  // ... cell state colors
  static const Color cellHighDark = Color.fromARGB(255, 21, 29, 63);
  static const Color cellSelectedDark = Color.fromARGB(255, 0, 71, 204);
  static const Color cellCorrectDark = Color.fromARGB(255, 17, 206, 0);
  static const Color cellHintedDark = Color.fromARGB(255, 255, 136, 0);
  static const Color cellWrongDark = Color.fromARGB(255, 255, 26, 26);
  static const Color cellValueSelectedDark = Color.fromARGB(255, 83, 10, 133);

  // ... option colors
  static const Color optionAccentDark = Color.fromARGB(255, 0, 162, 255);
  static const Color switchTrackOnDark = Color.fromARGB(255, 0, 34, 146);
  static const Color switchTrackOffDark = Color.fromARGB(255, 69, 69, 69);
  static const Color switchThumbOnDark = Color.fromARGB(255, 0, 194, 129);
  static const Color switchThumbOffDark = Color.fromARGB(255, 0, 194, 129);

  // ... text colors
  static const Color textBodyDark = Color.fromARGB(255, 228, 228, 228);
  static const Color textGridDark = Color.fromARGB(255, 255, 48, 238);
  static const Color textFixedDark = Color.fromARGB(255, 255, 255, 255);
  static const Color textCandidateDark = Color.fromARGB(255, 185, 185, 185);

  // ... border and shadow colors
  static const Color borderDark = Color.fromARGB(255, 109, 109, 109);
  static const Color borderExtraDark = Color.fromARGB(255, 141, 141, 141);
  static const Color boxShadowDark = borderDark;

  // ... miscellaneous
  static const Color badgeCountDark = accentDark;

  /// Light mode colors
  // ... background colors
  static const Color accentLite = Color.fromARGB(255, 13, 186, 255);
  static const Color bgLite = Color.fromARGB(255, 255, 255, 255);
  static const Color startLite = Color.fromARGB(255, 133, 255, 153);
  static const Color appBarLite = Color.fromARGB(255, 181, 255, 239);

  // ... button colors
  static const Color iconButtonLite = cellBgLite;
  static const Color newGameAccentLite = Colors.green;
  static const Color restartAccentLite = Colors.redAccent;
  static const Color helpAccentLite = Color.fromARGB(255, 0, 149, 218);
  static const Color hintAccentLite = Colors.deepOrangeAccent;
  static const Color optionsBtnAccentLite = Colors.blueGrey;

  // ... cell background colors
  static const Color cellBgLite = Color.fromARGB(255, 255, 255, 255);
  static const Color cellBgAccentLite = Color.fromARGB(255, 215, 215, 215);

  // ... cell state colors
  static const Color cellHighLite = Color(0xFFABF5FF);
  static const Color cellSelectedLite = Color.fromARGB(255, 160, 100, 255);
  static const Color cellCorrectLite = Color.fromARGB(255, 0, 202, 44);
  static const Color cellHintLite = Color.fromARGB(255, 247, 181, 0);
  static const Color cellWrongLite = Color.fromARGB(255, 161, 3, 3);
  static const Color cellValueSelectedLite = Color.fromARGB(255, 216, 173, 255);

  // ... option colors
  static const Color optionAccentLite = Color.fromARGB(255, 0, 101, 148);
  static const Color switchTrackOnLite = Color.fromARGB(255, 0, 130, 216);
  static const Color switchTrackOffLite = Color.fromARGB(255, 184, 184, 184);
  static const Color switchThumbOnLite = Color.fromARGB(255, 0, 194, 129);
  static const Color switchThumbOffLite = Color.fromARGB(255, 0, 194, 129);

  // ... text colors
  static const Color textBodyLite = Color.fromARGB(255, 30, 30, 30);
  static const Color textGridLite = Color.fromARGB(255, 5, 34, 199);
  static const Color textFixedLite = Color.fromARGB(255, 0, 0, 0);
  static const Color textCandidateLite = Color.fromARGB(255, 87, 87, 87);

  // ... border and shadow colors
  static const Color borderLite = Colors.blueGrey;
  static const Color borderExtraLite = Color.fromARGB(255, 238, 238, 238);
  static const Color boxShadowLite = borderLite;

  // ... miscellaneous
  static const Color badgeCountLite = Color.fromARGB(255, 69, 202, 255);

  /// mode independent colors
  static const Color bgTooltip = Color.fromARGB(255, 197, 197, 202);
  static const Color tooltipText = Color.fromARGB(255, 19, 19, 19);
  static const Color transparent = Color.fromARGB(0, 0, 0, 0);

  /////////////////////////////////
  ///   COLOR GETTERS (THEME)   ///
  /////////////////////////////////

  /// background colors
  static Color getAccentColor(BuildContext context) {
    return isDarkMode(context) ? accentDark : accentLite;
  }

  static Color getBgColor(BuildContext context) {
    return isDarkMode(context) ? bgDark : bgLite;
  }

  static Color getStartColor(BuildContext context) {
    return isDarkMode(context) ? startDark : startLite;
  }

  static Color getAppBarColor(BuildContext context) {
    return isDarkMode(context) ? appBarDark : appBarLite;
  }

  /// utility button colors
  static Color getIconButtonColor(BuildContext context) {
    return isDarkMode(context) ? iconButtonDark : iconButtonLite;
  }

  static Color getNewGameAccentColor(BuildContext context) {
    return isDarkMode(context) ? newGameAccentDark : newGameAccentLite;
  }

  static Color getRestartAccentColor(BuildContext context) {
    return isDarkMode(context) ? restartAccentDark : restartAccentLite;
  }

  static Color getHelpAccentColor(BuildContext context) {
    return isDarkMode(context) ? helpAccentDark : helpAccentLite;
  }

  static Color getHintAccentColor(BuildContext context) {
    return isDarkMode(context) ? hintAccentDark : hintAccentLite;
  }

  static Color getOptionBtnAccentColor(BuildContext context) {
    return isDarkMode(context) ? optionsBtnAccentDark : optionsBtnAccentLite;
  }

  /// cell colors
  static Color getCellBgColor(BuildContext context) {
    return isDarkMode(context) ? cellBgDark : cellBgLite;
  }

  static Color getCellAccentColor(BuildContext context) {
    return isDarkMode(context) ? cellBgAccentDark : cellBgAccentLite;
  }

  /// cell state colors
  static Color getCellHighlightColor(BuildContext context) {
    return isDarkMode(context) ? cellHighDark : cellHighLite;
  }

  static Color getCellSelectedColor(BuildContext context) {
    return isDarkMode(context) ? cellSelectedDark : cellSelectedLite;
  }

  static Color getCellCorrectColor(BuildContext context) {
    return isDarkMode(context) ? cellCorrectDark : cellCorrectLite;
  }

  static Color getCellHintColor(BuildContext context) {
    return isDarkMode(context) ? cellHintedDark : cellHintLite;
  }

  static Color getCellWrongColor(BuildContext context) {
    return isDarkMode(context) ? cellWrongDark : cellWrongLite;
  }

  static Color getCellValueSelectedColor(BuildContext context) {
    return isDarkMode(context) ? cellValueSelectedDark : cellValueSelectedLite;
  }

  /// option colors
  static Color getOptionAccentColor(BuildContext context) {
    return isDarkMode(context) ? optionAccentDark : optionAccentLite;
  }

  static Color getSwitchTrackOnColor(BuildContext context) {
    return isDarkMode(context) ? switchTrackOnDark : switchTrackOnLite;
  }

  static Color getSwitchTrackOffColor(BuildContext context) {
    return isDarkMode(context) ? switchTrackOffDark : switchTrackOffLite;
  }

  static Color getSwitchThumbOnColor(BuildContext context) {
    return isDarkMode(context) ? switchThumbOnDark : switchThumbOnLite;
  }

  static Color getSwitchThumbOffColor(BuildContext context) {
    return isDarkMode(context) ? switchThumbOffDark : switchThumbOffLite;
  }

  /// text colors
  static Color getTextFixedColor(BuildContext context) {
    return isDarkMode(context) ? textFixedDark : textFixedLite;
  }

  static Color getTextBodyColor(BuildContext context) {
    return isDarkMode(context) ? textBodyDark : textBodyLite;
  }

  static Color getTextGridColor(BuildContext context) {
    return isDarkMode(context) ? textGridDark : textGridLite;
  }

  static Color getTooltipText(BuildContext context) {
    return isDarkMode(context) ? textBodyLite : textBodyDark;
  }

  static Color getTextCandidateColor(BuildContext context) {
    return isDarkMode(context) ? textCandidateDark : textCandidateLite;
  }

  /// border and shadow colors
  static Color getBorderColor(BuildContext context) {
    return isDarkMode(context) ? borderDark : borderLite;
  }

  static Color getBorderExtraColor(BuildContext context) {
    return isDarkMode(context) ? borderExtraDark : borderExtraLite;
  }

  static Color getBoxShadowColor(BuildContext context) {
    return isDarkMode(context) ? boxShadowDark : boxShadowLite;
  }

  // Miscellaneous
  static Color getBadgeCountColor(BuildContext context) {
    return isDarkMode(context) ? badgeCountDark : badgeCountLite;
  }

  /// OTHER GETTERS
  static Color getMenuButtonColor(BuildContext context, String difficulty) {
    bool darkMode = isDarkMode(context);
    switch (difficulty) {
      case 'Beginner':
        return darkMode ? Color.fromARGB(255, 234, 0, 255) : Color.fromARGB(255, 129, 78, 223);
      case 'Easy':
        return darkMode ? Color.fromARGB(255, 0, 183, 255) : Color.fromARGB(255, 15, 104, 187);
      case 'Medium':
        return darkMode ? Color.fromARGB(255, 9, 255, 0) : Color.fromARGB(255, 6, 179, 0);
      case 'Hard':
        return darkMode ? Color.fromARGB(255, 219, 223, 5) : Color.fromARGB(255, 167, 170, 0);
      case 'Expert':
        return darkMode ? Color.fromARGB(255, 255, 115, 0) : Color.fromARGB(255, 204, 92, 0);
      case 'Impossible':
        return darkMode ? Color.fromARGB(255, 192, 0, 0) : Color.fromARGB(255, 197, 0, 0);
      default:
        return darkMode ? Color.fromARGB(255, 255, 255, 255) : Color.fromARGB(255, 0, 0, 0);
    }
  }

  /// Returns whether the brightness of the Theme of this [context] is [Brightness.dark].
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Returns whether the brightness of the Theme of this [context] is [Brightness.light].
  static bool isLiteMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light;
  }
}

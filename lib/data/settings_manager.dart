import 'package:flutter/material.dart';

enum GenerationMode { symmetrical, random }


class SettingsManager extends ChangeNotifier {
  ////////////////////////
  ///    ATTRIBUTES    ///
  ////////////////////////

  // theme mode (light vs dark)
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark mode
  ThemeMode get themeMode => _themeMode;

  // generation mode
  GenerationMode _generationMode = GenerationMode.symmetrical;
  GenerationMode get generationMode => _generationMode;

  // lazy mode
  bool _lazyMode = true;
  bool get lazyMode => _lazyMode;

  // auto candidate mode
  bool _autoCandidateMode = false;
  bool get autoCandidateMode => _autoCandidateMode;

  /////////////////////////////
  ///    MANAGER METHODS    ///
  /////////////////////////////

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setGenerationMode(GenerationMode mode) {
    _generationMode = mode;
    notifyListeners();
  }

  void setLazyMode(bool value) {
    _lazyMode = value;
    notifyListeners();
  }

  void setAutoCandidateMode(bool value) {
    _autoCandidateMode = value;
    notifyListeners();
  }
}

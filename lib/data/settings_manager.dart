import 'package:flutter/material.dart';
import 'sudoku_generator.dart';

class SettingsManager extends ChangeNotifier {
  ////////////////////////
  ///    ATTRIBUTES    ///
  ////////////////////////

  // theme mode (light vs dark)
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark mode
  ThemeMode get themeMode => _themeMode;

  // generation mode
  GenerationMode _generationMode = GenerationMode.symmetric;
  GenerationMode get generationMode => _generationMode;

  // lazy mode
  bool _lazyMode = true;
  bool get lazyMode => _lazyMode;

  // auto candidate mode
  bool _autoCandidateMode = false;
  bool get autoCandidateMode => _autoCandidateMode;

  // check correctness
  bool _checkCorrectness = true;
  bool get checkCorrectness => _checkCorrectness;

  // enable timer
  bool _enableTimer = true;
  bool get enableTimer => _enableTimer;

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

  void setCheckCorrectness(bool value) {
    _checkCorrectness = value;
    notifyListeners();
  }

  void setEnableTimer(bool value) {
    _enableTimer = value;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:sudoku/game/generator.dart';

class SettingsManager extends ChangeNotifier {
  ////////////////////////////////////////////////////////////////
  ///    ATTRIBUTES
  ////////////////////////////////////////////////////////////////

  // Theme mode (light vs dark)
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  // Generation mode
  GenerationMode _generationMode = GenerationMode.symmetric;
  GenerationMode get generationMode => _generationMode;

  /// Lazy mode
  bool _lazyMode = true;
  bool get lazyMode => _lazyMode;

  // TODO: Candidate update
  //bool _candidateUpdate = true;
  //bool get candidateUpdate => _candidateUpdate;

  /// Auto candidate mode
  bool _autoCandidateMode = false;
  bool get autoCandidateMode => _autoCandidateMode;
  
  /// Check correctness
  bool _checkCorrectness = true;
  bool get checkCorrectness => _checkCorrectness;

  /// Enable timer
  bool _enableTimer = true;
  bool get enableTimer => _enableTimer;

  ////////////////////////////////////////////////////////////////
  ///    SETTERS
  ////////////////////////////////////////////////////////////////

  /// Toggles the stored theme mode between light & dark.
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Sets the generation mode to [mode].
  void setGenerationMode(GenerationMode mode) {
    _generationMode = mode;
    notifyListeners();
  }

  /// Sets the lazy mode to [value]
  void setLazyMode(bool value) {
    _lazyMode = value;
    notifyListeners();
  }

  /// Sets the candidate update mode to [value]
  //void setCandidateUpdate(bool value) {
  //  _candidateUpdate = value;
  //  notifyListeners();
  //}

  /// Sets the auto-candidate mode to [value].
  void setAutoCandidateMode(bool value) {
    _autoCandidateMode = value;
    notifyListeners();
  }

  /// Sets the check-correctness mode to [value].
  void setCheckCorrectness(bool value) {
    _checkCorrectness = value;
    notifyListeners();
  }

  /// Sets whether the timer is enabled to [value].
  void setEnableTimer(bool value) {
    _enableTimer = value;
    notifyListeners();
  }

  /// Resets all settings to their default values.
  void resetToDefaults() {
    _themeMode = ThemeMode.light;
    _generationMode = GenerationMode.symmetric;
    _lazyMode = true;
    _autoCandidateMode = false;
    _checkCorrectness = true;
    _enableTimer = true;
    notifyListeners();
  }
  
  ////////////////////////////////////////////////////////////////
  ///    LOAD / SAVE
  ////////////////////////////////////////////////////////////////

  /// Initializes the settings from a map (typically from storage).
  void loadFromMap(Map<String, dynamic> map) {
    if (map.containsKey('themeMode')) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == map['themeMode'],
        orElse: () => ThemeMode.light,
      );
    }
    if (map.containsKey('generationMode')) {
      _generationMode = GenerationMode.values.firstWhere(
        (e) => e.name == map['generationMode'],
        orElse: () => GenerationMode.symmetric,
      );
    }
    _lazyMode = map['lazyMode'] ?? _lazyMode;
    _autoCandidateMode = map['autoCandidateMode'] ?? _autoCandidateMode;
    _checkCorrectness = map['checkCorrectness'] ?? _checkCorrectness;
    _enableTimer = map['enableTimer'] ?? _enableTimer;
    notifyListeners();
  }

  /// Converts this class to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    'autoCandidateMode': autoCandidateMode,
    //'candidateUpdate': candidateUpdate,
    'checkCorrectness': checkCorrectness,
    'enableTimer': enableTimer,
    'generationMode': generationMode,
    'lazyMode': lazyMode,
    'themeMode': themeMode,
  };
}

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:sudoku/features/settings/logic/settings_manager.dart';
import 'package:sudoku/features/stats/logic/stats.dart';

/// Handles saving and loading to the shared-preferences area.
class GameStorage {
  static const String _gameKeyPrefix = 'sudoku_game_data_';
  static const String _statsKey = 'sudoku_stats_data';
  static const String _settingsKey = 'sudoku_settings_data';

  static String getSlotKey(String slot) => '$_gameKeyPrefix$slot';

  // /////////////////////////////////////////////////////////////
  //   SAVE METHODS
  // /////////////////////////////////////////////////////////////

  /// Save the state
  static Future<void> save(Map<String, dynamic> state, {String slot = 'auto'}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(getSlotKey(slot), jsonEncode(state, toEncodable: _toEncodable));
  }

  /// Save user stats
  static Future<void> saveStats(SudokuStats state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode(state.toJson(), toEncodable: _toEncodable));
  }

  /// Save the Settings
  static Future<void> saveSettings(SettingsManager state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(state.toJson(), toEncodable: _toEncodable));
  }

  /// Helper to encode objects that [jsonEncode] doesn't support by default (like Enums).
  static Object? _toEncodable(Object? value) {
    if (value is Enum) return value.name;
    return value;
  }

  // /////////////////////////////////////////////////////////////
  //   LOAD METHODS
  // /////////////////////////////////////////////////////////////

  /// Load the Sudoku Save.
  /// 
  /// Returns [null] if the save data is corrupted or otherwise cannot be read.
  static Future<Map<String, dynamic>?> loadSave({String slot = 'auto'}) async {
    // Read the data.
    final prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString(getSlotKey(slot));

    // If the JSON data is null, nothing was found.
    if (rawJson == null) {
      return null;
    }

    // Safely cast. If it fails, return null.
    try {
      return jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Load the Settings
  static Future<Map<String, dynamic>?> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString(_settingsKey);

    if (rawJson == null) {
      return null;
    }

    try {
      return jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Load the stats.
  static Future<SudokuStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString(_statsKey);
    if (rawJson == null) {
      return SudokuStats();
    }
    try {
      return SudokuStats.fromJson(jsonDecode(rawJson) as Map<String, dynamic>);
    } catch (e) {
      return SudokuStats();
    }
  }

  // /////////////////////////////////////////////////////////////
  //   UTILITY METHODS
  // /////////////////////////////////////////////////////////////

  /// Clears a particular save slot.
  static Future<void> clear({String slot = 'auto'}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(getSlotKey(slot));
  }

  /// Clear all user statistics.
  static Future<void> clearStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_statsKey);
  }
}

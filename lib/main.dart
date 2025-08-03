// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/splash.dart';
import 'theme/styles.dart';
import 'data/settings_manager.dart'; // Import the new theme manager

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  // application root
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsManager(),
      child: Consumer<SettingsManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Sudoku Game',
            debugShowCheckedModeBanner: false,
            themeMode: themeManager.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.light,
                seedColor: ThemeColor.primaryLight,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: ThemeColor.bgLight,
                foregroundColor: ThemeColor.bodyTextLight,
              ),
              scaffoldBackgroundColor: ThemeColor.bgLight,
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: ThemeColor.bodyTextLight),
                bodyMedium: TextStyle(color: ThemeColor.bodyTextLight),
                // Add more text styles if needed
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.dark,
                seedColor: ThemeColor.primaryDark,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: ThemeColor.bgDark,
                foregroundColor: ThemeColor.bodyTextDark,
              ),
              scaffoldBackgroundColor: ThemeColor.bgDark,
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: ThemeColor.bodyTextDark),
                bodyMedium: TextStyle(color: ThemeColor.bodyTextDark),
                // Add more text styles if needed
              ),
            ),
            home: SudokuSplash(),
          );
        },
      ),
    );
  }
}

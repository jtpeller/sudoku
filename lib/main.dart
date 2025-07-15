// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'splash.dart';
import 'styles.dart';
import 'theme_manager.dart'; // Import the new theme manager

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  // application root
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeManager(), // Provide the ThemeManager
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Sudoku Game',
            debugShowCheckedModeBanner: false,
            themeMode: themeManager.themeMode, // Use themeMode from manager
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.light,
                seedColor: ThemeColor.mainColorLight,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: ThemeColor.bgColorLight,
                foregroundColor: ThemeColor.bodyTextLight,
              ),
              scaffoldBackgroundColor: ThemeColor.bgColorLight,
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
                seedColor: ThemeColor.mainColorDark,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: ThemeColor.bgColorDark,
                foregroundColor: ThemeColor.bodyTextDark,
              ),
              scaffoldBackgroundColor: ThemeColor.bgColorDark,
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/splash.dart';
import 'theme/colors.dart';
import 'data/settings_manager.dart';

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
        builder: (context, settingsManager, child) {
          return MaterialApp(
            title: 'Sudoku Game',
            debugShowCheckedModeBanner: false,
            themeMode: settingsManager.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.light,
                seedColor: ThemeColor.accentLite,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: ThemeColor.bgLite,
                foregroundColor: ThemeColor.textBodyLite,
              ),
              scaffoldBackgroundColor: ThemeColor.bgLite,
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: ThemeColor.textBodyLite),
                bodyMedium: TextStyle(color: ThemeColor.textBodyLite),
                // Add more text styles if needed
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.dark,
                seedColor: ThemeColor.accentDark,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: ThemeColor.bgDark,
                foregroundColor: ThemeColor.textBodyDark,
              ),
              scaffoldBackgroundColor: ThemeColor.bgDark,
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: ThemeColor.textBodyDark),
                bodyMedium: TextStyle(color: ThemeColor.textBodyDark),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/menu/ui/splash.dart';
import 'core/theme/colors.dart';
import 'features/settings/logic/settings_manager.dart';
import 'core/storage/game_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsManager = SettingsManager();
  final data = await GameStorage.loadSettings();
  if (data != null) {
    settingsManager.loadFromMap(data);
  }

  runApp(SudokuApp(settingsManager: settingsManager));
}

class SudokuApp extends StatelessWidget {
  final SettingsManager settingsManager;
  const SudokuApp({super.key, required this.settingsManager});

  // Application root
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: settingsManager,
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
              ),
            ),
            home: SudokuSplash(),
          );
        },
      ),
    );
  }
}

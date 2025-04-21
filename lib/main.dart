import 'package:flutter/material.dart';

import 'splash.dart';
import 'styles.dart';

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  // application root
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Testing Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.blue,
        ),
        outlinedButtonTheme: ThemeText.menuButtonThemeData,
      ),
      home: SudokuSplash(),
    );
  }
}

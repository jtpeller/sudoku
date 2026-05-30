import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'package:sudoku/theme/colors.dart';
import 'package:sudoku/widgets/common.dart' as common;
import 'package:sudoku/widgets/background_animations.dart';
import 'menu.dart';

class SudokuSplash extends StatelessWidget {
  const SudokuSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: common.getBackgroundBlurStack(
        blur: 2.5,
        alpha: 50,
        startColor: ThemeColor.getStartColor(context),
        context,
        Stack(
          children: [
            const FloatingNumbersBackground(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.grid_3x3_rounded,
                    color: ThemeColor.getTextBodyColor(context),
                    size: 100,
                    shadows: [
                      Shadow(
                        color: ThemeColor.getAccentColor(context),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SUDOKU',
                    style: TextStyle(
                      color: ThemeColor.getTextBodyColor(context),
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      shadows: [
                        Shadow(color: ThemeColor.getAccentColor(context), blurRadius: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      nextScreen: const MainMenu(),
      duration: 2500,
      splashIconSize: double.infinity,
      backgroundColor: ThemeColor.getBgColor(context),
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.leftToRightWithFade,
      animationDuration: const Duration(seconds: 1),
      centered: true,
    );
  }
}

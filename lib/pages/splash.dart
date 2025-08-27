import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../theme/colors.dart';
import 'menu.dart';

class SudokuSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Icon(
        Icons.grid_3x3_rounded,
        color: ThemeColor.getTextBodyColor(context),
        size: 100,
        shadows: [
          Shadow(
            color: ThemeColor.getAccentColor(context),
            blurRadius: 10
          ),
        ],
      ),
      nextScreen: MainMenu(),
      duration: 2500,
      backgroundColor: ThemeColor.getBgColor(context),
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
    );
  }
}

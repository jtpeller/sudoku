import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';

import 'menu.dart';
import 'styles.dart';

class SudokuSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Icons.grid_3x3_rounded,
      nextScreen: MainMenu(title: 'Menu'),
      duration: 2500,
      backgroundColor: ThemeColor.bgColor,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
    );
  }
}

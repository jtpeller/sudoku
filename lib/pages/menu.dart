import 'package:flutter/material.dart';

import 'game.dart';
import 'options.dart';

import '../widgets/common.dart' as common;
import '../data/sudoku_generator.dart';

import '../theme/colors.dart';
import '../theme/text.dart';

import '../widgets/spacing.dart' as spacing;

class MainMenu extends StatelessWidget {
  MainMenu({super.key});
  final difficulties = ['Beginner', 'Easy', 'Medium', 'Hard', 'Expert', 'Impossible'];

  Column buildMenu(BuildContext context) {
    // begin the menu items list with title + spacer.
    List<Widget> menuItems = [];
    menuItems.add(Text('Sudoku', style: ThemeStyle.gameTitle(context)));
    menuItems.add(spacing.verticalSpacer);

    // extract style for recoloring
    for (var diff in difficulties) {
      menuItems.add(
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        GamePage(difficulty: SudokuGenerator.getDifficulty(diff)),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
              ),
            );
          },
          style: ThemeStyle.menuButtonThemeData(context, diff).style,
          child: Text(diff),
        ),
      );

      // add the spacer in between
      menuItems.add(spacing.verticalSpacer);
    }

    // add options button (and spacer)
    menuItems.add(
      OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const OptionsPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          );
        },
        style: ThemeStyle.menuButtonThemeData(context, '').style,
        child: const Text('Options'),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: menuItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: common.getAppBar(context, 'Main Menu'),
      body: common.getBackgroundBlurStack(
        blur: 2.5,
        alpha: 50,
        startColor: ThemeColor.getStartColor(context),
        context,
        SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - kToolbarHeight - 3,
            child: buildMenu(context),
          ),
        ),
      ),
    );
  }
}

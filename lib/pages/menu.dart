import 'package:flutter/material.dart';
import 'package:sudoku/data/sudoku_generator.dart';

import 'game.dart';
import '../widgets/spacing.dart' as spacing;
import '../theme/text.dart';
import 'options.dart';

class MainMenu extends StatelessWidget {
  MainMenu({super.key});
  final difficulties = ['Beginner', 'Easy', 'Medium', 'Hard', 'Expert', 'Impossible'];

  Column buildMenu(BuildContext context) {
    // begin the menu items list with title + spacer.
    List<Widget> menuItems = [];
    menuItems.add(spacing.massiveVerticalSpacer);
    menuItems.add(Text('Sudoku', style: ThemeStyle.gameTitle(context)));
    menuItems.add(spacing.verticalSpacer);

    // extract style for recoloring
    for (var diff in difficulties) {
      menuItems.add(
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GamePage(difficulty: SudokuGenerator.getDifficulty(diff)),
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => const OptionsPage()));
        },
        style: ThemeStyle.menuButtonThemeData(context, '').style,
        child: const Text('Options'),
      ),
    );
    menuItems.add(spacing.massiveVerticalSpacer);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: menuItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Menu'), centerTitle: true),
      body: SingleChildScrollView(
        child: SizedBox(
          // get full width of the screen
          width: MediaQuery.of(context).size.width,
          child: buildMenu(context),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'game.dart';
import 'styles.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key, required this.title});
  final String title;
  static const Widget verticalSpacer = SizedBox(height: 16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Sudoku', style: ThemeText.gameTitle),
            verticalSpacer,
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GamePage()),
                );
              },
              style: Theme.of(context).outlinedButtonTheme.style,
              child: const Text('Play'),
            ),
            verticalSpacer,
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GamePage()),
                );
              },
              style: Theme.of(context).outlinedButtonTheme.style,
              child: const Text('Play with Hints'),
            ),
            verticalSpacer,
            OutlinedButton(
              onPressed: () {},
              style: Theme.of(context).outlinedButtonTheme.style,
              child: const Text('Options'),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/menu.dart
import 'package:flutter/material.dart';

import 'game.dart';
import 'styles.dart';
import 'widgets.dart' as widgets;
import 'options.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Menu')),
      body: SingleChildScrollView(
        // The SingleChildScrollView now directly takes the full width available to the Scaffold body.
        child: SizedBox(
          // We wrap the Column in a SizedBox.expand() or a SizedBox with double.infinity width
          // to force the Column to take the full horizontal space of the SingleChildScrollView.
          // This makes the SingleChildScrollView's scrollbar appear at the far right edge of the window.
          width: MediaQuery.of(context).size.width, // Explicitly take full screen width
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment
                    .center, // Center the children horizontally within this full width
            children: <Widget>[
              // Adding top and bottom padding to help with vertical centering when content is short
              // and to ensure scrolling when it's tall. Adjust these values as needed for your design.
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),

              Text('Sudoku', style: ThemeStyle.gameTitle(context)),
              widgets.verticalSpacer,
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GamePage(difficulty: 'Easy')),
                  );
                },
                style: ThemeStyle.menuButtonThemeData(context).style,
                child: const Text('Easy'),
              ),
              widgets.verticalSpacer,
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GamePage(difficulty: 'Medium')),
                  );
                },
                style: ThemeStyle.menuButtonThemeData(context).style,
                child: const Text('Medium'),
              ),
              widgets.verticalSpacer,
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GamePage(difficulty: 'Hard')),
                  );
                },
                style: ThemeStyle.menuButtonThemeData(context).style,
                child: const Text('Hard'),
              ),
              widgets.verticalSpacer,
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OptionsPage()),
                  );
                },
                style: ThemeStyle.menuButtonThemeData(context).style,
                child: const Text('Options'),
              ),
              widgets.verticalSpacer,
              widgets.verticalSpacer,
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sudoku/core/theme/theme.dart';

import 'package:sudoku/features/game/ui/game.dart';
import 'package:sudoku/core/components/common.dart' as common;
import 'package:sudoku/core/components/frosted_glass.dart';
import 'package:sudoku/core/components/page_layout.dart';
import 'package:sudoku/core/components/spacing.dart' as spacing;

import 'package:sudoku/core/extensions/string_extensions.dart';

import 'package:sudoku/core/theme/text.dart';

import 'package:sudoku/features/game/logic/sudoku_manager.dart';

class NewGamePage extends StatefulWidget {
  final String initialDifficulty;
  final int initialSideLength;

  const NewGamePage({
    super.key,
    this.initialDifficulty = 'medium',
    this.initialSideLength = 9,
  });

  @override
  State<NewGamePage> createState() => _NewGamePageState();
}

class _NewGamePageState extends State<NewGamePage> {
  late String _difficulty;
  late int _sideLength;
  bool _isLoading = false;
  String? _loadingTip;

  @override
  void initState() {
    super.initState();
    _difficulty = widget.initialDifficulty;
    _sideLength = widget.initialSideLength;
  }

  void _randomize() {
    final random = Random();
    final difficulties = SudokuManager.getDifficultyNames();
    final sizes = [4, 6, 9, 12];

    setState(() {
      _difficulty = difficulties[random.nextInt(difficulties.length)];
      _sideLength = sizes[random.nextInt(sizes.length)];
    });
  }

  (String, IconData) get _difficultySummary {
    return switch (_difficulty) {
      'easy' => ('Relax and enjoy the flow.', Icons.wb_sunny_outlined),
      'medium' => ('Sudoku as intended.', Icons.insights),
      'hard' => ('A serious test of skill.', Icons.whatshot_outlined),
      'expert' => ('Logic pushed to the limits.', Icons.psychology),
      _ => ('The classic challenge.', Icons.grid_3x3_rounded),
    };
  }

  (String, IconData) get _gridSizeSummary {
    return switch (_sideLength) {
      4 => ('A perfect bite-sized snack.', Icons.cookie_outlined),
      6 => ('A quick mental workout.', Icons.timer_outlined),
      9 => ('The standard Sudoku experience.', Icons.apps_rounded),
      12 => ("The grand master's grid.", Icons.castle_outlined),
      _ => ('Custom board size.', Icons.grid_view),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (diffPhrase, diffIcon) = _difficultySummary;
    final (sizePhrase, sizeIcon) = _gridSizeSummary;
    final isThin = MediaQuery.of(context).size.width < ThemeStyle.bpSM;

    final mainContent = FrostedScaffold(
      title: 'New Game',
      persistentFooterButtons: [
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16.0,
            runSpacing: 8.0,
            children: [
              FrostedGlassButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                label: isThin ? null : 'Cancel',
                icon: Icons.close,
                iconColor: Colors.redAccent,
                startColor: Colors.redAccent,
                alpha: ThemeValues.alphaWeaker,
                borderColor: Colors.redAccent,
                borderAlpha: 100,
                borderRadius: 100,
                padding: const EdgeInsets.all(12),
              ),
              FrostedGlassButton(
                onPressed: _isLoading ? null : _randomize,
                label: isThin ? null : 'Randomize',
                icon: Icons.shuffle,
                iconColor: Colors.purpleAccent,
                startColor: Colors.purpleAccent,
                alpha: ThemeValues.alphaWeaker,
                borderColor: Colors.purpleAccent,
                enableHaptics: true,
                borderRadius: 100,
                padding: const EdgeInsets.all(12),
              ),
              FrostedGlassButton(
                onPressed: _isLoading ? null : () async {
                  final tips = SudokuManager.loadingTips;
                  _loadingTip = tips[Random().nextInt(tips.length)];
                  setState(() => _isLoading = true);

                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          GamePage(
                            difficulty: _difficulty, 
                            sideLength: _sideLength,
                            loadingTip: _loadingTip,
                          ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                          FadeTransition(opacity: animation, child: child),
                    ),
                  );
                },
                label: isThin ? null : 'Start!',
                icon: Icons.play_arrow_rounded,
                iconColor: Colors.blueAccent,
                startColor: Colors.blueAccent,
                alpha: ThemeValues.alphaWeaker,
                borderColor: Colors.blueAccent,
                enableHaptics: true,
                borderRadius: 100,
                padding: const EdgeInsets.all(12),
              ),
            ],
          ),
        ),
      ],
      body: PageLayout(
        children: [
          spacing.bigVerticalSpacer,
          Center(
            child: Text(
              'Configure Your Game',
              style: ThemeStyle.subtitle(context),
              textAlign: TextAlign.center,
            ),
          ),
          spacing.bigVerticalSpacer,

          // Difficulty Section
          common.Option(
            label: 'Difficulty',
            helpText: 'How challenging do you want the logic to be?',
            icon: Icons.psychology_outlined,
            breakpoint: ThemeStyle.bpXS,
            child: DropdownButton<String>(
              value: _difficulty,
              items: SudokuManager.getDifficultyNames().map((String val) {
                return DropdownMenuItem(value: val, child: Text(val.capitalize()));
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) setState(() => _difficulty = newValue);
              },
            ),
          ),
          spacing.verticalSpacer,

          // Difficulty Grabber
          FrostedIconCard(icon: diffIcon, text: diffPhrase),

          // Divider
          spacing.verticalSpacer,
          spacing.buildThinDivider(context),
          spacing.verticalSpacer,

          // Grid Size Section
          common.Option(
            label: 'Grid Size',
            helpText: 'Select the dimensions of your Sudoku board.',
            icon: Icons.grid_view_outlined,
            breakpoint: ThemeStyle.bpXS,
            child: DropdownButton<int>(
              value: _sideLength,
              items: [4, 6, 9, 12].map((int val) {
                return DropdownMenuItem<int>(
                  value: val,
                  child: Text('${val}x$val'),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) setState(() => _sideLength = newValue);
              },
            ),
          ),
          spacing.bigVerticalSpacer,


          // Preview Grabbers
          FrostedIconCard(icon: sizeIcon, text: sizePhrase),
        ],
      ),
    );

    if (!_isLoading) return mainContent;

    return Stack(
      children: [
        mainContent,
        Positioned.fill(
          child: Container(
            color: Colors.black.withAlpha(ThemeValues.alphaMid),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  spacing.bigVerticalSpacer,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  spacing.smallVerticalSpacer,
                  Material(
                    color: Colors.transparent,
                    child: Text(
                      'Generating Puzzle...',
                      style: ThemeStyle.mediumGameText(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  spacing.bigVerticalSpacer,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FrostedIconCard(
                      icon: Icons.tips_and_updates_outlined,
                      text: _loadingTip ?? '',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sudoku/data/settings_manager.dart';
import 'package:sudoku/data/game_storage.dart';

import 'package:sudoku/extensions/string_extensions.dart';

import 'package:sudoku/theme/colors.dart';
import 'package:sudoku/theme/text.dart';

import 'package:sudoku/widgets/common.dart' as common;
import 'package:sudoku/widgets/spacing.dart' as spacing;
import 'package:sudoku/widgets/background_animations.dart';

import 'game.dart';
import 'options.dart';
import 'help.dart';
import 'stats.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  bool _transitionFinished = false;
  bool _hasAttachedListener = false;

  @override
  void initState() {
    super.initState();
    // Load settings from storage when the app starts.
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // We attach a listener to the route animation to detect when the
    // transition (and thus the Hero flight) has completed.
    if (!_hasAttachedListener) {
      final animation = ModalRoute.of(context)?.animation;
      if (animation != null) {
        _hasAttachedListener = true;
        if (animation.status == AnimationStatus.completed) {
          _transitionFinished = true;
        } else {
          animation.addStatusListener((status) {
            if (status == AnimationStatus.completed && mounted) {
              setState(() => _transitionFinished = true);
            }
          });
        }
      }
    }
  }

  /// Retrieves settings from storage and hydrates the [SettingsManager].
  Future<void> _loadSettings() async {
    final settings = context.read<SettingsManager>();
    final Map<String, dynamic>? data = await GameStorage.loadSettings();
    if (data != null) {
      // Hydrate the settings manager with the loaded data.
      settings.loadFromMap(data);
    }
  }

  Future<void> _showLoadGameDialog() async {
    // Load the 3 slots and auto-save for overview
    final List<Map<String, dynamic>?> slots = await Future.wait([
      GameStorage.loadSave(slot: '1'),
      GameStorage.loadSave(slot: '2'),
      GameStorage.loadSave(slot: '3'),
      GameStorage.loadSave(slot: 'auto'),
    ]);

    if (!mounted) return;

    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Center(child: Text('Load Game', style: ThemeStyle.subtitle(context))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < 4; i++) ...[
                _buildLoadSlotTile(
                  context,
                  i == 3 ? 'Auto-Save' : 'Slot ${i + 1}',
                  slots[i],
                  i == 3 ? 'auto' : '${i + 1}',
                ),
                if (i < 3) spacing.smallVerticalSpacer,
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: ThemeStyle.smallButtonText(context)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadSlotTile(
    BuildContext context,
    String title,
    Map<String, dynamic>? data,
    String slotId,
  ) {
    final bool isEmpty = data == null;
    final int gridSize = data?['gridSize'] ?? 81;
    final int side = sqrt(gridSize).toInt();
    final String subtitle =
        isEmpty
            ? 'Empty Slot'
            : '${data['difficulty'].toString().capitalize()} | ${side}x$side | ${_formatTime(data['elapsedTime'] ?? 0.0)}';

    return ListTile(
      title: Text(title, style: ThemeStyle.mediumGameText(context)),
      subtitle: Text(subtitle, style: ThemeStyle.helperText(context)),
      trailing:
          !isEmpty
              ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () async {
                  await GameStorage.clear(slot: slotId);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  if (context.mounted) _showLoadGameDialog();
                },
              )
              : null,
      onTap:
          isEmpty
              ? null
              : () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) => GamePage(initialSlot: slotId),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            FadeTransition(opacity: animation, child: child),
                  ),
                );
              },
    );
  }

  /// Formats the time in a useful manner.
  String _formatTime(double seconds) {
    int mins = (seconds / 60).floor();
    int secs = (seconds % 60).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Column buildMenu(BuildContext context) {
    // Initialize the items list with title + spacer.
    List<Widget> menuItems = [];

    // Icon and title
    menuItems.add(
      Icon(
        Icons.grid_3x3_rounded,
        color: ThemeColor.getTextBodyColor(context),
        size: 100,
        shadows: [Shadow(color: ThemeColor.getAccentColor(context), blurRadius: 10)],
      ),
    );
    menuItems.add(spacing.smallVerticalSpacer);
    menuItems.add(
      Text(
        'SUDOKU',
        style: TextStyle(
          color: ThemeColor.getTextBodyColor(context),
          fontSize: 36,
          fontWeight: FontWeight.w900,
          letterSpacing: 8,
          shadows: [Shadow(color: ThemeColor.getAccentColor(context), blurRadius: 12)],
        ),
      ),
    );
    menuItems.add(spacing.bigVerticalSpacer);

    // New Game
    menuItems.add(
      OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) => const GamePage(forceNewGame: true),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          );
        },
        style: ThemeStyle.difficultyButtonThemeData(context, '').style,
        child: const Text('New Game'),
      ),
    );
    menuItems.add(spacing.verticalSpacer);

    // add Load Game button
    menuItems.add(
      OutlinedButton(
        onPressed: () => _showLoadGameDialog(),
        style: ThemeStyle.difficultyButtonThemeData(context, '').style,
        child: const Text('Load Game'),
      ),
    );
    menuItems.add(spacing.verticalSpacer);

    // Stats button
    menuItems.add(
      OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const StatsPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          );
        },
        style: ThemeStyle.difficultyButtonThemeData(context, '').style,
        child: const Text('Stats'),
      ),
    );

    menuItems.add(spacing.verticalSpacer);

    // How To Play button
    menuItems.add(
      OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const HelpPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          );
        },
        style: ThemeStyle.difficultyButtonThemeData(context, '').style,
        child: const Text('How to play'),
      ),
    );

    menuItems.add(spacing.verticalSpacer);

    // Options button
    menuItems.add(
      OutlinedButton(
        onPressed: () async {
          final settings = context.read<SettingsManager>();
          final navigator = Navigator.of(context);

          await navigator.push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const OptionsPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          );

          // Save settings upon returning from the options page.
          GameStorage.saveSettings(settings);
        },
        style: ThemeStyle.difficultyButtonThemeData(context, '').style,
        child: const Text('Options'),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        menuItems[0], // The Hero logo remains visible during the transition flight
        AnimatedOpacity(
          opacity: _transitionFinished ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          child: Column(mainAxisSize: MainAxisSize.min, children: menuItems.sublist(1)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: common.getAppBar(context, 'Sudoku'),
      backgroundColor: ThemeColor.getStartColor(context),
      body: common.getBackgroundBlurStack(
        blur: 2.5,
        alpha: 50,
        startColor: ThemeColor.getStartColor(context),
        context,
        Stack(
          children: [
            const FloatingNumbersBackground(count: 30),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.hasBoundedHeight ? constraints.maxHeight : 0.0,
                      minWidth: constraints.hasBoundedWidth ? constraints.maxWidth : 0.0,
                    ),
                    child: buildMenu(context),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

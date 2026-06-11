import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sudoku/core/components/common.dart' as common;
import 'package:sudoku/core/components/frosted_glass.dart';
import 'package:sudoku/core/components/spacing.dart' as spacing;
import 'package:sudoku/core/components/background_animations.dart';
import 'package:sudoku/core/components/confetti.dart';

import 'package:sudoku/core/storage/game_storage.dart';

import 'package:sudoku/core/theme/colors.dart';
import 'package:sudoku/core/theme/text.dart';

import 'package:sudoku/features/game/ui/new_game.dart';
import 'package:sudoku/features/game/ui/load_game.dart';
import 'package:sudoku/features/help/help.dart';
import 'package:sudoku/features/settings/logic/settings_manager.dart';
import 'package:sudoku/features/settings/ui/settings.dart';
import 'package:sudoku/features/stats/ui/stats.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  bool _transitionFinished = false;
  bool _hasAttachedListener = false;

  int _tapCount = 0;
  bool _showConfetti = false;
  late AnimationController _iconController;
  late Animation<double> _iconAnimation;
  Timer? _confettiTimer;

  @override
  void initState() {
    super.initState();
    // Load settings from storage when the app starts.
    _loadSettings();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _iconAnimation = const AlwaysStoppedAnimation(0.0);
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

  @override
  void dispose() {
    _iconController.dispose();
    _confettiTimer?.cancel();
    super.dispose();
  }

  void _handleIconTap() {
    setState(() {
      _tapCount++;
      if (_tapCount >= 5) {
        _showConfetti = true;
        _tapCount = 0;
        _confettiTimer?.cancel();
        _confettiTimer = Timer(const Duration(seconds: 10), () {
          if (mounted) {
            setState(() => _showConfetti = false);
          }
        });
      }
    });

    if (!_iconController.isAnimating) {
      final random = Random();
      final spins = 2 + random.nextInt(3); // 2 to 4 spins
      final direction = random.nextBool() ? 1.0 : -1.0;

      setState(() {
        _iconAnimation = Tween<double>(
          begin: 0.0,
          end: direction * spins,
        ).animate(CurvedAnimation(parent: _iconController, curve: Curves.easeInOutBack));
      });

      _iconController.forward(from: 0.0);
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

  Column buildMenu(BuildContext context) {
    // Initialize the items list with title + spacer.
    List<Widget> menuItems = [];

    // Icon and title
    menuItems.add(
      GestureDetector(
        onTap: _handleIconTap,
        child: RotationTransition(
          turns: _iconAnimation,
          child: Icon(
            Icons.grid_3x3_rounded,
            color: ThemeColor.getTextBodyColor(context),
            size: 100,
            shadows: [Shadow(color: ThemeColor.getAccentColor(context), blurRadius: 10)],
          ),
        ),
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
              pageBuilder: (context, animation, secondaryAnimation) => const NewGamePage(),
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
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const LoadGamePage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          );
        },
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
              pageBuilder: (context, animation, secondaryAnimation) => const SettingsPage(),
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
    return FrostedScaffold(
      appBar: common.getAppBar(context, 'Sudoku'),
      backgroundColor: ThemeColor.getStartColor(context),
      blur: 2.5,
      alpha: 50,
      startColor: ThemeColor.getStartColor(context),
      body: Stack(
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
          IgnorePointer(child: ConfettiWidget(play: _showConfetti)),
        ],
      ),
    );
  }
}

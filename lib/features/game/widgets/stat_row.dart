import 'package:flutter/material.dart';
import 'package:sudoku/core/extensions/string_extensions.dart';
import 'package:sudoku/core/theme/colors.dart';
import 'package:sudoku/core/theme/theme.dart';
import 'package:sudoku/core/theme/text.dart';
import 'package:sudoku/core/components/frosted_glass.dart';
import 'package:sudoku/features/game/logic/sudoku_manager.dart';
import 'package:sudoku/features/settings/logic/settings_manager.dart';
import 'package:sudoku/features/stats/widgets/stat_widgets.dart';
import 'package:sudoku/features/game/widgets/stopwatch.dart';

/// A styled capsule for displaying a game statistic.
class StatChip extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const StatChip({super.key, required this.child, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    Widget content = FrostedGlassBox(
      alpha: ThemeValues.alphaWeak,
      blur: ThemeValues.blurWeak,
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Center( // Removed widthFactor/heightFactor to let it size to child
        child: child,
      ),
    );

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: content,
      );
    }
    return IntrinsicWidth( // If no explicit width, size to content
      child: IntrinsicHeight( // If no explicit height, size to content
        child: content,
      ),
    );
  }
}

/// A responsive row of game statistics (difficulty, hints, mistakes, timer).
class GameStatRow extends StatelessWidget {
  final SudokuManager manager;
  final SettingsManager settings;
  final Widget timerWidget;
  final StopwatchManager timerManager;
  final bool isCompleted;

  const GameStatRow({
    super.key,
    required this.manager,
    required this.settings,
    required this.timerWidget,
    required this.timerManager,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmall = screenWidth < ThemeStyle.bpSM;
    final TextStyle statTextStyle = ThemeStyle.mediumGameText(
      context,
    ).copyWith(fontWeight: FontWeight.bold);

    // Dynamic dimensions based on screen size or font size factors
    final double iconSize = (statTextStyle.fontSize ?? 24);
    final double? chipWidth = isSmall ? null : (statTextStyle.fontSize ?? 18.0) * 7.5;
    final double? chipHeight = isSmall ? null : (statTextStyle.fontSize ?? 18.0) * 2.0;

    // Sync timer state if the game is already completed.
    if (timerManager.getState() == StopwatchStatus.running && isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => timerManager.pause());
    }

    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: isSmall ? 10.0 : 25.0,
      runSpacing: isSmall ? 10.0 : 20.0,
      children: [
        // DIFFICULTY
        StatGlowWrapper(
          value: manager.difficulty,
          glowColor: ThemeColor.getAccentColor(context),
          child: StatChip(
            width: chipWidth,
            height: chipHeight,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.emoji_events_outlined, size: iconSize, color: ThemeColor.getAccentColor(context)),
                const SizedBox(width: 6),
                Text(manager.difficulty.capitalize(), style: statTextStyle),
              ],
            ),
          ),
        ),
        // TIMER
        if (settings.enableTimer)
          StatChip(
            width: chipWidth,
            height: chipHeight,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.timer_outlined, size: iconSize, color: ThemeColor.getTextBodyColor(context)),
                const SizedBox(width: 6),
                timerWidget,
              ],
            ),
          )
        else
          Offstage(child: timerWidget),
        // HINTS
        StatGlowWrapper(
          value: manager.hintsUsed,
          glowColor: ThemeColor.getCellHintColor(context),
          child: StatChip(
            width: chipWidth,
            height: chipHeight,
            child: StatIconGroup(
              filledIcon: Icons.lightbulb,
              emptyIcon: Icons.lightbulb_outline,
              count: (manager.maxHints - manager.hintsUsed).clamp(0, manager.maxHints),
              total: manager.maxHints,
              color: ThemeColor.getCellHintColor(context),
              isSmall: isSmall,
              textStyle: statTextStyle,
              iconSize: iconSize,
            ),
          ),
        ),
        // LIVES
        if (settings.checkCorrectness)
          StatGlowWrapper(
            value: manager.mistakes,
            glowColor: Colors.redAccent,
            child: StatChip(
              width: chipWidth,
              height: chipHeight,
              child: StatIconGroup(
                filledIcon: Icons.favorite,
                emptyIcon: Icons.favorite_border,
                count: (manager.maxMistakes - manager.mistakes).clamp(0, manager.maxMistakes),
                total: manager.maxMistakes,
                color: Colors.redAccent,
                isSmall: isSmall,
                textStyle: statTextStyle,
                iconSize: iconSize,
              ),
            ),
          ),
      ],
    );
  }
}

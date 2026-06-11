import 'package:flutter/material.dart';
import 'package:sudoku/core/components/frosted_glass.dart';
import 'package:sudoku/core/theme/colors.dart';
import 'package:sudoku/core/theme/text.dart';
import 'package:sudoku/core/theme/theme.dart';
import 'package:sudoku/core/components/common.dart' as common;
import 'package:sudoku/core/components/page_layout.dart';
import 'package:sudoku/core/components/spacing.dart' as spacing;

/// A dedicated page explaining how to play Sudoku and the purpose of the icons.
class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Wraps a widget with a staggered fade and slide animation.
  Widget _buildAnimatedItem(int index, Widget child) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (index * 0.06).clamp(0.0, 1.0),
        ((index * 0.06) + 0.6).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FrostedScaffold(
      appBar: common.getAppBar(context, 'How to Play'),
      alpha: ThemeValues.alphaMid,
      blur: ThemeValues.blurStrong,
      startColor: ThemeColor.getStartColor(context),
      body: PageLayout(
        crossAxisAlignment: CrossAxisAlignment.start,
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 8),
          _buildAnimatedItem(
            0,
            _buildHelpSection(
              context,
              'Sudoku Basics',
              Icons.grid_on_outlined,
              'Sudoku is a logic-based number placement puzzle. The objective is to '
                  'fill a grid so that each column, row, and subgrid '
                  'contains all digits exactly once.',
            ),
          ),
          _buildAnimatedItem(
            1,
            _buildHelpSection(
              context,
              'How to Play',
              Icons.touch_app_outlined,
              'Select a cell by tapping it, then tap a number button at the bottom to fill it. '
                  'Use "Candidate" mode to track potential numbers when you aren\'t sure yet.',
            ),
          ),
          _buildAnimatedItem(2, _buildHelpSectionHeader(context, 'Controls & Icons')),
          _buildAnimatedItem(
            3,
            _buildHelpAction(
              context,
              Icons.add,
              ThemeColor.getNewGameAccentColor(context),
              'New Game',
              'Start a brand new puzzle. You can choose different grid sizes (4x4, 9x9, etc.) and difficulties.',
            ),
          ),
          _buildAnimatedItem(
            4,
            _buildHelpAction(
              context,
              Icons.save_outlined,
              Colors.blueAccent,
              'Save',
              'Manually save your current progress into one of three available save slots.',
            ),
          ),
          _buildAnimatedItem(
            5,
            _buildHelpAction(
              context,
              Icons.refresh,
              ThemeColor.getRestartAccentColor(context),
              'Restart',
              'Resets the current board back to its original state, clearing all your moves.',
            ),
          ),
          _buildAnimatedItem(
            6,
            _buildHelpAction(
              context,
              Icons.bar_chart,
              Colors.purpleAccent,
              'Stats',
              'View your personal records, including win rates and fastest solve times.',
            ),
          ),
          _buildAnimatedItem(
            7,
            _buildHelpAction(
              context,
              Icons.lightbulb,
              ThemeColor.getHintAccentColor(context),
              'Hint',
              'Stuck? Use a hint to fill the selected cell with its correct value.',
            ),
          ),
          _buildAnimatedItem(
            8,
            _buildHelpAction(
              context,
              Icons.settings,
              ThemeColor.getOptionBtnAccentColor(context),
              'Settings',
              'Customize your experience, including themes, lazy mode, and timer visibility.',
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHelpSectionHeader(BuildContext context, String title, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22, color: ThemeColor.getAccentColor(context)),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: ThemeStyle.subtitle(
                context,
              ).copyWith(color: ThemeColor.getAccentColor(context)),
            ),
          ],
        ),
        spacing.buildThinDivider(context),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildHelpSection(BuildContext context, String title, IconData icon, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHelpSectionHeader(context, title, icon: icon),
        Text(description, style: ThemeStyle.mediumGameText(context)),
        spacing.bigVerticalSpacer,
      ],
    );
  }

  Widget _buildHelpAction(
    BuildContext context,
    IconData icon,
    Color color,
    String label,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: ThemeStyle.mediumGameText(context).copyWith(fontWeight: FontWeight.bold),
                ),
                Text(description, style: ThemeStyle.helperText(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

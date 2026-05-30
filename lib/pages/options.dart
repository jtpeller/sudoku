import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sudoku/widgets/common.dart' as common;
import 'package:sudoku/data/settings_manager.dart';
import 'package:sudoku/game/generator.dart';

import 'package:sudoku/theme/colors.dart';
import 'package:sudoku/theme/text.dart';

import 'package:sudoku/widgets/spacing.dart' as spacing;
import 'package:sudoku/widgets/option_widgets.dart' as widgets;

class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (index * 0.05).clamp(0.0, 1.0),
        ((index * 0.05) + 0.5).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }

  /// Shows a confirmation dialog before resetting settings.
  void _showResetDialog(BuildContext context, SettingsManager mgr) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text('Reset Settings', style: ThemeStyle.subtitle(context)),
        content: Text(
          'Are you sure you want to reset all options to their default values?',
          style: ThemeStyle.mediumGameText(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: ThemeStyle.smallButtonText(context)),
          ),
          TextButton(
            onPressed: () {
              mgr.resetToDefaults();
              Navigator.pop(context);
            },
            child: Text(
              'Reset',
              style: ThemeStyle.smallButtonText(context).copyWith(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildOptions(BuildContext context) {
    final mgr = Provider.of<SettingsManager>(context);
    int itemIndex = 0;

    return [
      _buildAnimatedItem(
        itemIndex++,
        Center(child: Text('Appearance', style: ThemeStyle.subtitle(context))),
      ),
      spacing.smallVerticalSpacer,
      _buildAnimatedItem(itemIndex++, spacing.buildDivider(context)),
      spacing.verticalSpacer,
      _buildAnimatedItem(
        itemIndex++,
        widgets.IconOption(
          name: 'Theme Mode',
          icon: Icons.palette_outlined,
          helpText: 'Toggles between dark and light mode.',
          iconToggle: {
            Icon(Icons.light_mode_outlined): 'Light Mode',
            Icon(Icons.dark_mode_outlined): 'Dark Mode',
          },
          toggleCondition: mgr.themeMode == ThemeMode.dark,
          onPressed: () {
            mgr.toggleTheme();
          },
        ),
      ),

      /// GAMEPLAY
      spacing.bigVerticalSpacer,
      _buildAnimatedItem(
        itemIndex++,
        Center(child: Text('Gameplay', style: ThemeStyle.subtitle(context))),
      ),
      spacing.smallVerticalSpacer,
      _buildAnimatedItem(itemIndex++, spacing.buildDivider(context)),
      spacing.verticalSpacer,
      _buildAnimatedItem(
        itemIndex++,
        widgets.DropdownOption(
          label: 'Generation Style',
          icon: Icons.grid_view_rounded,
          helpText:
              'Influences how the empty cells are laid out.\n\n'
              'Symmetric: Empty cells are "reflected" across the sudoku grid for symmetry.\n\n'
              'Random: Empty cells are randomly chosen.',
          currentValue: mgr.generationMode,
          values: const [GenerationMode.symmetric, GenerationMode.random],
          options: const ['Symmetrical', 'Random'],
          onChanged: (GenerationMode? newValue) {
            if (newValue != null) {
              mgr.setGenerationMode(newValue);
            }
          },
        ),
      ),
      spacing.verticalSpacer,
      _buildAnimatedItem(itemIndex++, spacing.buildThinDivider(context)),
      spacing.verticalSpacer,
      _buildAnimatedItem(
        itemIndex++,
        widgets.SwitchOption(
          label: 'Lazy Mode',
          icon: Icons.auto_fix_high_outlined,
          helpText:
              "Upon input, moves the selected cell to the next non-correct cell, so you don't have to!",
          value: mgr.lazyMode,
          onChanged: (bool newValue) {
            mgr.setLazyMode(newValue);
          },
        ),
      ),
      // TODO: Implement the candidate update.
      //spacing.verticalSpacer,
      //spacing.buildThinDivider(context),
      //spacing.verticalSpacer,
      //widgets.SwitchOption(
      //  label: 'Candidate Update',
      //  helpText: 'Upon input, relevant and newly invalid candidates are removed!',
      //  value: mgr.candidateUpdate,
      //  onChanged: (bool newValue) {
      //    mgr.setCandidateUpdate(newValue);
      //  },
      //),
      spacing.verticalSpacer,
      _buildAnimatedItem(itemIndex++, spacing.buildThinDivider(context)),
      spacing.verticalSpacer,
      _buildAnimatedItem(
        itemIndex++,
        widgets.SwitchOption(
          label: 'Auto-Candidate Mode',
          icon: Icons.edit_note_rounded,
          helpText: 'Automatically fills in candidates for you.',
          value: mgr.autoCandidateMode,
          onChanged: (bool newValue) {
            mgr.setAutoCandidateMode(newValue);
          },
        ),
      ),

      /// STATS
      spacing.bigVerticalSpacer,
      _buildAnimatedItem(
        itemIndex++,
        Center(child: Text('Stats', style: ThemeStyle.subtitle(context))),
      ),
      spacing.smallVerticalSpacer,
      _buildAnimatedItem(itemIndex++, spacing.buildDivider(context)),
      spacing.verticalSpacer,
      _buildAnimatedItem(
        itemIndex++,
        widgets.SwitchOption(
          label: 'Check Correctness',
          icon: Icons.fact_check_outlined,
          helpText:
              'Check whether your entered cells are correct. This will also enable or disable the mistake counter.',
          value: mgr.checkCorrectness,
          onChanged: (bool newValue) {
            mgr.setCheckCorrectness(newValue);
          },
        ),
      ),
      spacing.verticalSpacer,
      _buildAnimatedItem(itemIndex++, spacing.buildThinDivider(context)),
      spacing.verticalSpacer,
      _buildAnimatedItem(
        itemIndex++,
        widgets.SwitchOption(
          label: 'Enable Timer',
          icon: Icons.timer_outlined,
          helpText:
              'If enabled, a timer is shown, which shows how long you have take to solve the puzzle. The timer automatically pauses when the game is not in focus, allowing you to do something else, like responding to a text, change your options, or doom scroll for a few hours.',
          value: mgr.enableTimer,
          onChanged: (bool newValue) {
            mgr.setEnableTimer(newValue);
          },
        ),
      ),
      spacing.bigVerticalSpacer,
      _buildAnimatedItem(
        itemIndex++,
        Center(
          child: OutlinedButton(
            onPressed: () => _showResetDialog(context, mgr),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(300.0, 30.0),
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.all(20),
              side: const BorderSide(color: Colors.redAccent),
              textStyle: ThemeStyle.largeButtonText(context),
            ),
            child: const Text('Reset to Defaults'),
          ),
        ),
      ),
      spacing.massiveVerticalSpacer,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: common.getAppBar(context, 'Options'),
      body: common.getBackgroundBlurStack(
        startColor: ThemeColor.getStartColor(context),
        alpha: 75,
        blur: ThemeColor.isDarkMode(context) ? 12.5 : 7.5,
        context,
        widgets.DualScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double minSize = 240.0;
                  final double maxWidth = 1000;
                  final double factor = MediaQuery.of(context).size.width > 1000 ? 0.6 : 1.0;
                  final double targetSize = constraints.maxWidth * factor;
                  final double containerSize =
                      targetSize > maxWidth
                          ? maxWidth
                          : (targetSize < minSize ? minSize : targetSize);

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: minSize,
                      minHeight: minSize,
                      maxWidth: containerSize,
                      //maxHeight: containerSize,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: buildOptions(context),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

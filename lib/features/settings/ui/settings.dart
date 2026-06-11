import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sudoku/core/components/common.dart' as common;
import 'package:sudoku/core/components/frosted_glass.dart';
import 'package:sudoku/core/components/page_layout.dart';
import 'package:sudoku/core/models/sudoku_grid.dart';
import 'package:sudoku/core/theme/theme.dart';
import 'package:sudoku/features/settings/logic/settings_manager.dart';

import 'package:sudoku/core/theme/colors.dart';
import 'package:sudoku/core/theme/text.dart';

import 'package:sudoku/core/components/spacing.dart' as spacing;
import 'package:sudoku/features/settings/widgets/settings_widget.dart' as widgets;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
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
      builder:
          (context) => AlertDialog.adaptive(
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
      spacing.verticalSpacer,
      _buildAnimatedItem(itemIndex++, spacing.buildThinDivider(context)),
      spacing.verticalSpacer,
      _buildAnimatedItem(
        itemIndex++,
        widgets.SwitchOption(
          label: 'Candidate Update',
          icon: Icons.delete_sweep_outlined,
          helpText: 'Upon input, relevant and newly invalid candidates are removed!',
          value: mgr.candidateUpdate,
          onChanged: (bool newValue) {
            mgr.setCandidateUpdate(newValue);
          },
        ),
      ),
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
    return FrostedScaffold(
      appBar: common.getAppBar(context, 'Options'),
      startColor: ThemeColor.getStartColor(context),
      alpha: ThemeValues.alphaStrong,
      blur: ThemeColor.isDarkMode(context) ? ThemeValues.blurStrong : ThemeValues.blurMid,
      body: PageLayout(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buildOptions(context),
      ),
    );
  }
}

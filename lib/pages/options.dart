import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/settings_manager.dart';
import '../data/sudoku_generator.dart';
import '../widgets/spacing.dart' as spacing;
import '../theme/text.dart';
import '../widgets/option_widgets.dart' as widgets;

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mgr = Provider.of<SettingsManager>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Options')),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double minSize = 350.0;
            final double maxWidth = 1000;
            final double targetSize = constraints.maxWidth * 0.8;
            //(constraints.maxWidth < constraints.maxHeight
            //        ? constraints.maxWidth
            //        : constraints.maxHeight) *
            //    0.9;
            final double containerSize =
                targetSize > maxWidth ? maxWidth : (targetSize < minSize ? minSize : targetSize);

            return widgets.DualScrollView(
              child: ConstrainedBox(
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
                    children: [
                      Text('Appearance', style: ThemeStyle.subtitle(context)),
                      spacing.smallVerticalSpacer,
                      spacing.buildDivider(context),
                      spacing.verticalSpacer,
                      widgets.IconOption(
                        name: 'Theme Mode',
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

                      /// STATS

                      spacing.bigVerticalSpacer,
                      Text('Gameplay', style: ThemeStyle.subtitle(context)),
                      spacing.smallVerticalSpacer,
                      spacing.buildDivider(context),
                      spacing.verticalSpacer,
                      widgets.DropdownOption(
                        label: 'Generation Style',
                        helpText: 'Influences how the empty cells are laid out.\n\n'
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
                      spacing.verticalSpacer,
                      spacing.buildThinDivider(context),
                      spacing.verticalSpacer,
                      widgets.SwitchOption(
                        label: 'Lazy Mode',
                        helpText: "Upon input, moves the selected cell to the next non-correct cell, so you don't have to!",
                        value: mgr.lazyMode, 
                        onChanged: (bool newValue) {
                          mgr.setLazyMode(newValue);
                        },
                      ),
                      spacing.verticalSpacer,
                      spacing.buildThinDivider(context),
                      spacing.verticalSpacer,
                      widgets.SwitchOption(
                        label: 'Auto-Candidate Mode',
                        helpText: 'Automatically fills in candidates for you.',
                        value: mgr.autoCandidateMode,
                        onChanged: (bool newValue) {
                          mgr.setAutoCandidateMode(newValue);
                        },
                      ),

                      /// STATS

                      spacing.bigVerticalSpacer,
                      Text('Stats', style: ThemeStyle.subtitle(context)),
                      spacing.smallVerticalSpacer,
                      spacing.buildDivider(context),
                      spacing.verticalSpacer,
                      widgets.SwitchOption(
                        label: 'Check Correctness',
                        helpText: 'Check whether your entered cells are correct. This will also enable or disable the mistake counter.',
                        value: mgr.checkCorrectness,
                        onChanged: (bool newValue) {
                          mgr.setCheckCorrectness(newValue);
                        },
                      ),
                      spacing.verticalSpacer,
                      spacing.buildThinDivider(context),
                      spacing.verticalSpacer,
                      widgets.SwitchOption(
                        label: 'Enable Timer',
                        helpText: 'If enabled, a timer is shown, which shows how long you have take to solve the puzzle. The timer automatically pauses when the game is not in focus, allowing you to do something else, like responding to a text, change your options, or doom scroll for a few hours.',
                        value: mgr.enableTimer,
                        onChanged: (bool newValue) {
                          mgr.setEnableTimer(newValue);
                        },
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// lib/options.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common.dart';
import 'settings_manager.dart';
import 'styles.dart';
import 'widgets.dart' as widgets;

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  Row buildIconToggleOption(
    SettingsManager mgr,
    BuildContext context,
    String name,
    bool toggleCondition,
    String msg,
    Map<Icon, String> iconToggle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        widgets.HelperText(text: name, helperText: msg),
        IconButton(
          icon: toggleCondition ? iconToggle.keys.first : iconToggle.keys.last,
          onPressed: () {
            mgr.toggleTheme();
          },
          tooltip: toggleCondition ? iconToggle.values.first : iconToggle.values.last,
          iconSize: ThemeStyle.option(context).fontSize! * 1.25,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mgr = Provider.of<SettingsManager>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Options')),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double minSize = 500.0;
            final double maxWidth = 1000;
            final double targetSize = constraints.maxWidth * 0.9;
            //(constraints.maxWidth < constraints.maxHeight
            //        ? constraints.maxWidth
            //        : constraints.maxHeight) *
            //    0.9;
            final double containerSize =
                targetSize > maxWidth ? maxWidth : (targetSize < minSize ? minSize : targetSize);

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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
                      widgets.smallVerticalSpacer,
                      widgets.buildDivider(context),
                      widgets.verticalSpacer,
                      buildIconToggleOption(
                        mgr,
                        context,
                        'Dark Mode',
                        mgr.themeMode == ThemeMode.dark,
                        'Toggles the theme between dark and light mode.',
                        {
                          Icon(Icons.light_mode_outlined): 'Light Mode',
                          Icon(Icons.dark_mode_outlined): 'Dark Mode',
                        },
                      ),
                      widgets.bigVerticalSpacer,
                      Text('Game', style: ThemeStyle.subtitle(context)),
                      widgets.smallVerticalSpacer,
                      widgets.buildDivider(context),
                      widgets.verticalSpacer,
                      widgets.DropdownOption(
                        label: 'Generation Style',
                        helpText: 'Symmetric mode is prettier, Random is more chaotic.',
                        currentValue: mgr.generationMode,
                        values: const [GenerationMode.symmetrical, GenerationMode.random],
                        options: const ['Symmetrical', 'Random'],
                        onChanged: (GenerationMode? newValue) {
                          if (newValue != null) {
                            mgr.setGenerationMode(newValue);
                          }
                        },
                      ),
                      widgets.verticalSpacer,
                      widgets.SwitchOption(
                        label: 'Lazy Mode',
                        helpText: 'When enabled, selected cell moves to next empty cell, but only if what you just entered was correct (includes hints). Skip cells by just choosing another.',
                        value: mgr.lazyMode, 
                        onChanged: (bool newValue) {
                          mgr.setLazyMode(newValue);
                        },
                      ),
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

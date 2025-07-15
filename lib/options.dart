// lib/options.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'styles.dart';
import 'theme_manager.dart';

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Options')),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double targetSize =
                (constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight) *
                0.5;

            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: targetSize, maxHeight: targetSize),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Appearance', style: ThemeStyle.subtitle(context)),
                    SizedBox(height: 16.0),
                    Divider(color: ThemeColor.getBorderColor(context), thickness: 1.0),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: 'Dark Mode ', style: ThemeStyle.option(context)),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Tooltip(
                                  message:
                                      'Toggles the application\'s theme between dark and light mode.',
                                  child: Transform.translate(
                                    // Use Transform.translate for fine-tuning
                                    offset: const Offset(0, -2.0), // Adjust the Y-offset as needed
                                    child: Icon(
                                      Icons.info_outline,
                                      size: ThemeStyle.option(context).fontSize! * 0.8,
                                      color: ThemeColor.getBodyText(context),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: themeManager.themeMode == ThemeMode.dark,
                          onChanged: (value) {
                            themeManager.toggleTheme();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

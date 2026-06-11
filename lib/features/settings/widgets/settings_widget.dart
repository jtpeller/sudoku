import 'package:flutter/material.dart';

import 'package:sudoku/core/components/common.dart' as common;

import 'package:sudoku/core/theme/colors.dart';
import 'package:sudoku/core/theme/text.dart';

class DualScrollView extends StatelessWidget {
  final Widget child;

  const DualScrollView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(scrollDirection: Axis.vertical, child: child),
    );
  }
}

///////////////////////////////
///     OPTIONS WIDGETS     ///
///////////////////////////////

// Dropdown Option Class
class DropdownOption<T> extends StatelessWidget {
  final String label;
  final String helpText;
  final List<String> options;
  final List<T> values;
  final T? currentValue;
  final ValueChanged<T?> onChanged;
  final IconData? icon;

  const DropdownOption({
    super.key,
    required this.label,
    required this.helpText,
    required this.currentValue,
    required this.values,
    required this.options,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return common.Option(
      breakpoint: ThemeStyle.bpSM, // large breakpoint bc of dropdown.
      label: label,
      helpText: helpText,
      icon: icon,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250),
        child: DropdownButton<T>(
          value: currentValue,
          onChanged: onChanged,
          items:
              values.map((T value) {
                int vIdx = values.indexOf(value);
                return DropdownMenuItem<T>(value: value, child: Center(child: Text(options[vIdx])));
              }).toList(),
          hint: Text('Select $label'),
          style: ThemeStyle.option(context),
          dropdownColor: ThemeColor.getAccentColor(context),
          isExpanded: true,
          padding: EdgeInsets.all(2.0),
          underline: Container(height: 1.0, color: ThemeColor.getTextBodyColor(context)),
          // modify to make it more appealing and compact
          alignment: Alignment.center,
          icon: Icon(Icons.arrow_drop_down_rounded, color: ThemeColor.getTextBodyColor(context)),
          // icon size should be based on the text size
          iconSize: ThemeStyle.option(context).fontSize! * 1.0,
          borderRadius: BorderRadius.circular(4.0),
          selectedItemBuilder: (BuildContext context) {
            return options.map((String option) {
              return Center(child: Text(option, style: ThemeStyle.option(context)));
            }).toList();
          },
        ),
      ),
    );
  }
}

class IconOption extends StatelessWidget {
  final String helpText;
  final Map<Icon, String> iconToggle;
  final String name;
  final bool toggleCondition;
  final VoidCallback onPressed;
  final IconData? icon;

  const IconOption({
    super.key,
    required this.helpText,
    required this.iconToggle,
    required this.name,
    required this.toggleCondition,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return common.Option(
      breakpoint: ThemeStyle.bpXS, // small breakpoint for switch
      label: name,
      helpText: helpText,
      icon: icon,
      child: common.FrostedTooltipIconButton(
        alpha: 150,
        borderRadius: 100,
        borderWidth: 2,
        accentColor: ThemeColor.getOptionAccentColor(context),
        startColor: ThemeColor.getIconButtonColor(context),
        icon: toggleCondition ? iconToggle.keys.first.icon! : iconToggle.keys.last.icon!,
        label: toggleCondition ? iconToggle.values.first : iconToggle.values.last,
        onPressed: onPressed,
      ),
    );
  }
}

class SwitchOption extends StatelessWidget {
  final String label;
  final String helpText;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  const SwitchOption({
    super.key,
    required this.label,
    required this.helpText,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return common.Option(
      breakpoint: ThemeStyle.bpXS, // small breakpoint for switch
      label: label,
      helpText: helpText,
      icon: icon,
      child: Switch(
        // The "oval" piece of the switch
        activeTrackColor: ThemeColor.getSwitchTrackOnColor(context),
        inactiveTrackColor: ThemeColor.getSwitchTrackOffColor(context),
        value: value,
        onChanged: onChanged,
        activeThumbColor: ThemeColor.getAccentColor(context),
      ),
    );
  }
}

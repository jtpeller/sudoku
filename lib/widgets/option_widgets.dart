import 'package:flutter/material.dart';

import 'common.dart' as common;
import 'spacing.dart';

import 'package:sudoku/theme/colors.dart';
import 'package:sudoku/theme/text.dart';

// Text with Helper
class HelperText extends StatelessWidget {
  final String text;
  final String helperText;
  final IconData? icon;

  const HelperText({super.key, required this.text, required this.helperText, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: ThemeColor.getAccentColor(context),
                size: ThemeStyle.option(context).fontSize,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(text, style: ThemeStyle.option(context)),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        Text(helperText, style: ThemeStyle.helperText(context)),
      ],
    );
  }
}

///////////////////////////////
///      COMMON WIDGETS     ///
///////////////////////////////

/// ResponsiveRow is a widget where,
///    If there's enough space, it implements a Row layout. Left item takes available space, and the right item will align to the end.
///    If not, these wrap, with each taking its own line.
class ResponsiveRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double breakpoint;

  const ResponsiveRow({
    super.key,
    required this.left,
    required this.right,
    required this.breakpoint,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > breakpoint) {
          // enough space for a row
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: Align(alignment: Alignment.centerLeft, child: left)),
              // some space
              horizontalSpacer,
              Align(alignment: Alignment.centerRight, child: right),
            ],
          );
        } else {
          // not enough space, stack them vertically
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Align(alignment: Alignment.centerLeft, child: left),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                alignment: Alignment.centerRight,
                child: right,
              ),
            ],
          );
        }
      },
    );
  }
}

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

class Option extends StatelessWidget {
  final String label;
  final String helpText;
  final Widget child;
  final double breakpoint;
  final IconData? icon;

  const Option({
    super.key,
    required this.label,
    required this.helpText,
    required this.child,
    required this.breakpoint,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResponsiveRow(
          breakpoint: breakpoint, // breakpoint for responsive layout
          left: HelperText(text: label, helperText: helpText, icon: icon),
          right: child,
        ),
        verticalSpacer, // space between options
      ],
    );
  }
}

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
    return Option(
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
    return Option(
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
    return Option(
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

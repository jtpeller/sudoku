import 'package:flutter/material.dart';
import 'spacing.dart';
import '../theme/styles.dart';

// Text with Helper
class HelperText extends StatelessWidget {
  final String text;
  final String helperText;

  const HelperText({super.key, required this.text, required this.helperText});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: double.infinity, // never have help text on the same line
      runSpacing: 16.0, // space between lines if wrapped
      children: [
        Text(text, style: ThemeStyle.option(context)),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Align(alignment: Alignment.centerRight, child: right),
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

  const Option({
    super.key, 
    required this.label,
    required this.helpText,
    required this.child,
    required this.breakpoint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResponsiveRow(
          breakpoint: breakpoint, // breakpoint for responsive layout
          left: HelperText(text: label, helperText: helpText),
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

  const DropdownOption({
    super.key,
    required this.label,
    required this.helpText,
    required this.currentValue,
    required this.values,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Option(
      breakpoint: 500.0, // large breakpoint bc of dropdown.
      label: label,
      helpText: helpText,
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
        isExpanded: false,
        padding: EdgeInsets.all(2.0),
        underline: Container(height: 1.0, color: ThemeColor.getBodyText(context)),
        // modify to make it more appealing and compact
        alignment: Alignment.center,
        icon: Icon(Icons.arrow_drop_down_rounded, color: ThemeColor.getBodyText(context)),
        // icon size should be based on the text size
        iconSize: ThemeStyle.option(context).fontSize! * 1.0,
        borderRadius: BorderRadius.circular(4.0),
        selectedItemBuilder: (BuildContext context) {
          return options.map((String option) {
            return Center(child: Text(option, style: ThemeStyle.option(context)));
          }).toList();
        },
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

  const IconOption({
    super.key,
    required this.helpText,
    required this.iconToggle,
    required this.name,
    required this.toggleCondition,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Option(
      breakpoint: 300.0, // small breakpoint for switch
      label: name,
      helpText: helpText,
      child: IconButton(
        icon: toggleCondition ? iconToggle.keys.first : iconToggle.keys.last,
        onPressed: onPressed,
        tooltip: toggleCondition ? iconToggle.values.first : iconToggle.values.last,
        iconSize: ThemeStyle.option(context).fontSize! * 1.25,
      ),
    );
  }
}

class SwitchOption extends StatelessWidget {
  final String label;
  final String helpText;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchOption({
    super.key,
    required this.label,
    required this.helpText,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Option(
      breakpoint: 300.0, // small breakpoint for switch
      label: label,
      helpText: helpText,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: ThemeColor.getAccentColor(context),
      ),
    );
  }
}

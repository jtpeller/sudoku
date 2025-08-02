import 'package:flutter/material.dart';
import 'styles.dart';

// constant widgets for reuse
const Widget verticalSpacer = SizedBox(height: 16);
const Widget horizontalSpacer = SizedBox(width: 16);

const Widget bigVerticalSpacer = SizedBox(height: 32);
const Widget bigHorizontalSpacer = SizedBox(width: 32);

const Widget smallVerticalSpacer = SizedBox(height: 8);
const Widget smallHorizontalSpacer = SizedBox(width: 8);

const Widget massiveVerticalSpacer = SizedBox(height: 64);
const Widget massiveHorizontalSpacer = SizedBox(width: 64);

// dividers and lines
Divider buildDivider(BuildContext context) {
  return Divider(color: ThemeColor.getBodyText(context), thickness: 1.0);
}

Divider buildThickDivider(BuildContext context) {
  return Divider(color: ThemeColor.getBodyText(context), thickness: 3.0);
}

// Text with Helper
class HelperText extends StatelessWidget {
  final String text;
  final String helperText;

  const HelperText({super.key, required this.text, required this.helperText});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '$text ', style: ThemeStyle.option(context)),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Tooltip(
              message: helperText,
              // only have margins on left and right
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ThemeColor.bgTooltip,
                borderRadius: BorderRadius.circular(8.0),
              ),
              textAlign: TextAlign.center,
              textStyle: ThemeStyle.tooltip(context),
              child: Transform.translate(
                offset: const Offset(0, -2.0),
                child: Icon(
                  Icons.info_outline,
                  size: ThemeStyle.option(context).fontSize! * 1.0,
                  color: ThemeColor.getBodyText(context),
                ),
              ),
            ),
          ),
        ],
      ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        HelperText(text: label, helperText: helpText),
        DropdownButton<T>(
          value: currentValue,
          onChanged: onChanged,
          items:
              values.map((T value) {
                int vIdx = values.indexOf(value);
                return DropdownMenuItem<T>(value: value, child: Text(options[vIdx]));
              }).toList(),
          hint: Text('Select $label'),
          style: ThemeStyle.option(context),
          dropdownColor: ThemeColor.getBgColor(context),
          isExpanded: false, // take horizontal space
        ),
      ],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        HelperText(text: label, helperText: helpText),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: ThemeColor.getAccentColor(context),
        ),
      ],
    );
  }
}

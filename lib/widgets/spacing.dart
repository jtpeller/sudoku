import 'package:flutter/material.dart';

import '../theme/styles.dart'; 

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
  return Divider(color: ThemeColor.getTextBodyColor(context), thickness: 1.0);
}

Divider buildThickDivider(BuildContext context) {
  return Divider(color: ThemeColor.getTextBodyColor(context), thickness: 3.0);
}

Divider buildThinDivider(BuildContext context) {
  return Divider(color: ThemeColor.getTextBodyColor(context), thickness: 0.5);
}

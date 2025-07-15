import 'package:flutter/material.dart';

import 'styles.dart';

// constant widgets for reuse
const Widget verticalSpacer = SizedBox(height: 16);

// grid tile
// isEditable parameter to determine styling
Widget tile(String val, int index, int subindex, BuildContext context, {bool isEditable = true}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: ThemeColor.getBorderColor(context), width: 0.25),
      // Alternate background colors for 3x3 blocks
      color: index % 2 == 0 ? ThemeColor.getBgColor(context) : ThemeColor.getBgColorLite(context),
    ),
    child: Center(
      child: Text(
        val,
        // Apply different text style based on editability
        style: isEditable ? ThemeStyle.gridText(context) : ThemeStyle.fixedGridText(context),
      ),
    ),
  );
}

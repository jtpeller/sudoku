import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sudoku/core/theme/colors.dart';
import 'package:sudoku/core/theme/text.dart';

enum BorderPicker { top, left, right, bottom }

///////////////////////////////
///       SHOW DIALOGS      ///
///////////////////////////////

/// Shows a dialog with "Yes" and "No" options.
void showYesNoDialog(
  BuildContext context,
  String title,
  String message, {
  VoidCallback? onYes,
  VoidCallback? onNo,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              if (onYes != null) {
                onYes();
              }
            },
            child: Text('Yes'),
          ),
          TextButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
              if (onNo != null) {
                onNo();
              }
            },
          ),
        ],
      );
    },
  );
}

void showInfoDialog(BuildContext context, String title, Widget content, {VoidCallback? onDone}) {
  EdgeInsets insetPadding = const EdgeInsets.symmetric(horizontal: 5.0, vertical: 24.0);
  double currentWidth = MediaQuery.of(context).size.width;

  if (currentWidth < 720) {
    insetPadding = const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0);
  } else if (currentWidth < 1200) {
    insetPadding = const EdgeInsets.symmetric(horizontal: 200.0, vertical: 24.0);
  } else {
    insetPadding = const EdgeInsets.symmetric(horizontal: 500.0, vertical: 24.0);
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: Icon(Icons.help_outline),
        title: Text(title),
        content: SingleChildScrollView(child: content),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              if (onDone != null) {
                onDone();
              }
            },
          ),
        ],
        insetPadding: insetPadding,
      );
    },
  );
}

///////////////////////////////
///   CUSTOM GAME WIDGETS   ///
///////////////////////////////

/// A `StatelessWidget` that represents a single tile on the Sudoku board.
///
/// It can display a single number or a 3x3 grid of candidates,
/// based on the provided `value` and `candidates` parameters.
class SudokuTile extends StatelessWidget {
  final int row;
  final int col;
  final int value;
  final int maxNumber;
  final Set<int> candidates;
  final int boxRows;
  final int boxCols;
  final Color bgColor;
  final bool isSelected;
  final bool isFixed;
  final bool isIncorrect;
  final bool isCorrect;
  final bool isHinted;
  final bool isValueSelected;
  final bool isHighlighted;
  final bool showCorrect;
  final VoidCallback onTap;
  final int alpha;

  bool get thickTop => (row % boxRows == 0);
  bool get thickBottom => ((row + 1) % boxRows == 0) || (row == (boxRows * boxCols) - 1);
  bool get thickLeft => (col % boxCols == 0);
  bool get thickRight => ((col + 1) % boxCols == 0) || (col == (boxRows * boxCols) - 1);

  const SudokuTile({
    super.key,
    required this.row,
    required this.col,
    required this.value,
    required this.maxNumber,
    required this.boxRows,
    required this.boxCols,
    required this.candidates,
    required this.isSelected,
    required this.isFixed,
    required this.isIncorrect,
    required this.isCorrect,
    required this.isHinted,
    required this.isValueSelected,
    required this.isHighlighted,
    required this.bgColor,
    required this.showCorrect,
    required this.onTap,
    required this.alpha,
  });

  @override
  Widget build(BuildContext context) {
    // Get the default background color based on the row and column
    Color backgroundColor = bgColor;

    // These override the default background color
    if (isSelected) {
      backgroundColor = ThemeColor.getAccentColor(context);
    } else if (isValueSelected) {
      backgroundColor = ThemeColor.getCellValueSelectedColor(context);
    } else if (isHinted) {
      backgroundColor = ThemeColor.getCellHintColor(context);
    } else if (isHighlighted) {
      backgroundColor = ThemeColor.getCellHighlightColor(context);
    }
    backgroundColor = backgroundColor.withAlpha(alpha);

    // Handle the borders
    var normalBorder = BorderSide(
      color: ThemeColor.getBorderColor(context),
      width: ThemeStyle.gridNormalBorder,
      style: BorderStyle.solid,
    );
    var thickBorder = BorderSide(
      color: ThemeColor.getBorderColor(context),
      width: ThemeStyle.gridThickBorder,
      style: BorderStyle.solid,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeIn,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            top: thickTop ? thickBorder : normalBorder,
            left: thickLeft ? thickBorder : normalBorder,
            right: thickRight ? thickBorder : normalBorder,
            bottom: thickBottom ? thickBorder : normalBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeColor.getBoxShadowColor(context),
              blurRadius: 1,
              spreadRadius: 0,
              offset: Offset.zero,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child: _buildTileContent(context),
      ),
    );
  }

  /// Builds the content of the Sudoku tile based on its value and candidates.
  Widget _buildTileContent(BuildContext context) {
    if (value != 0) {
      // decide which color to use
      Color textColor = ThemeColor.getTextGridColor(context);
      if (isHinted || isFixed) {
        textColor = ThemeColor.getTextFixedColor(context);
      } else if (isCorrect && showCorrect && !isHinted) {
        textColor = ThemeColor.getCellCorrectColor(context);
      } else if (isIncorrect && showCorrect) {
        textColor = ThemeColor.getCellWrongColor(context);
      }

      final bool isSmall = MediaQuery.of(context).size.width < 500;
      TextStyle textStyle =
          isFixed || isHinted
              ? ThemeStyle.fixedGridText(context).copyWith(color: textColor)
              : ThemeStyle.gridText(context).copyWith(color: textColor);
      
      if (isSmall) {
        textStyle = textStyle.copyWith(fontSize: (textStyle.fontSize ?? 18) * 1.15);
      }

      // Display a single number
      return Center(child: Text(value.toString(), style: textStyle));
    } else if (candidates.isNotEmpty) {
      // Display candidates
      return GridView.count(
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        crossAxisCount: (sqrt(maxNumber)).ceil(),
        childAspectRatio: sqrt(maxNumber).floor() / sqrt(maxNumber).ceil() + 0.05,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0.0),

        children: List.generate(maxNumber, (index) {
          final candidateNumber = index + 1;
          return Center(
            child: Text(
              candidates.contains(candidateNumber) ? candidateNumber.toString() : '',
              style: ThemeStyle.candidateText(context).copyWith(),
            ),
          );
        }),
      );
    } else {
      // Empty tile
      return Container();
    }
  }
}

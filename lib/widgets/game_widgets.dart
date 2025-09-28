import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text.dart';

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
  final Set<int> candidates;
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

  const SudokuTile({
    super.key,
    required this.row,
    required this.col,
    required this.value,
    required this.candidates,
    required this.isSelected,
    required this.isFixed,
    required this.isIncorrect,
    required this.isCorrect,
    required this.isHinted,
    required this.isValueSelected,
    required this.isHighlighted,
    required this.showCorrect,
    required this.onTap,
    required this.alpha,
  });

  @override
  Widget build(BuildContext context) {
    // first, get the default background color based on the row and column
    Color backgroundColor = _getDefaultBackgroundColor(context, row, col);

    // these override the default background color
    if (isSelected) {
      backgroundColor = ThemeColor.getAccentColor(context);
    } else if (isValueSelected) {
      backgroundColor = ThemeColor.getCellValueSelectedColor(context);
    } else if (isHighlighted) {
      backgroundColor = ThemeColor.getCellHighlightColor(context);
    } else if (isHinted) {
      backgroundColor = ThemeColor.getCellHintColor(context);
    }
    backgroundColor = backgroundColor.withAlpha(alpha);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeIn,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            top: _getBorderSide(row, col, context, BorderPicker.top),
            left: _getBorderSide(row, col, context, BorderPicker.left),
            right: _getBorderSide(row, col, context, BorderPicker.right),
            bottom: _getBorderSide(row, col, context, BorderPicker.bottom),
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

      TextStyle textStyle =
          isFixed || isHinted
              ? ThemeStyle.fixedGridText(context).copyWith(color: textColor)
              : ThemeStyle.gridText(context).copyWith(color: textColor);

      // Display a single number
      return Center(child: Text(value.toString(), style: textStyle));
    } else if (candidates.isNotEmpty) {
      // Display candidates
      return GridView.count(
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0.0),

        children: List.generate(9, (index) {
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

  Color _getDefaultBackgroundColor(BuildContext context, int row, int col) {
    // alternate by 3x3 grids
    return ((row ~/ 3) + (col ~/ 3)) % 2 == 0
        ? ThemeColor.getCellBgColor(context)
        : ThemeColor.getCellAccentColor(context);
  }

  BorderSide _getBorderSide(int row, int col, BuildContext context, BorderPicker side) {
    double width = ThemeStyle.gridNormalBorder;
    // if this is an edge of the 3x3 block, use a thicker border
    if ((col > 0 && col % 3 == 0 && side == BorderPicker.left) ||
        (row > 0 && row % 3 == 0 && side == BorderPicker.top) ||
        (col < 8 && col % 3 == 2 && side == BorderPicker.right) ||
        (row < 8 && row % 3 == 2 && side == BorderPicker.bottom)) {
      width = ThemeStyle.gridThickBorder;
    }
    return BorderSide(
      color: ThemeColor.getBorderColor(context),
      width: width,
      style: BorderStyle.solid,
    );
  }
}

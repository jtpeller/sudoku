import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text.dart';

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
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: content,
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
      );
    },
  );
}

///////////////////////////////
///   CUSTOM GAME WIDGETS   ///
///////////////////////////////

class TooltipIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const TooltipIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      textStyle: ThemeStyle.tooltip(context),
      child: IconButton(
        icon: Icon(icon),
        style: ThemeStyle.iconButtonThemeData(context).style,
        iconSize: ThemeStyle.option(context).fontSize! * 1.25,
        onPressed: onPressed,
      ),
    );
  }
}

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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            top: _getBorderSide(row, col, context, 'top'),
            left: _getBorderSide(row, col, context, 'left'),
            right: _getBorderSide(row, col, context, 'right'),
            bottom: _getBorderSide(row, col, context, 'bottom'),
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeColor.getBoxShadowColor(context),
              blurRadius: 1.0,
              offset: const Offset(0, 0),
              blurStyle: BlurStyle.solid,
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

  BorderSide _getBorderSide(row, col, context, side) {
    double width = ThemeStyle.gridNormalBorder;
    // if this is an edge of the 3x3 block, use a thicker border
    if ((col > 0 && col % 3 == 0 && side == 'left') ||
        (row > 0 && row % 3 == 0 && side == 'top') ||
        (col < 8 && col % 3 == 2 && side == 'right') ||
        (row < 8 && row % 3 == 2 && side == 'bottom')) {
      width = ThemeStyle.gridThickBorder;
    }
    return BorderSide(
      color: ThemeColor.getBorderColor(context),
      width: width,
      style: BorderStyle.solid,
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:sudoku/core/theme/colors.dart';
import 'package:sudoku/core/theme/theme.dart';
import 'package:sudoku/core/theme/text.dart';
import 'package:sudoku/core/components/frosted_glass.dart';

/// A unified input component for Sudoku that provides digit selection,
/// a clear button, and a toggle for Candidate vs. Normal input modes.
class DigitPad extends StatelessWidget {
  final int maxNumber;
  final bool isCandidateMode;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<int> onDigitPressed;
  final VoidCallback onClearPressed;
  final bool Function(int) isDigitFull;
  final int Function(int) getRemainingCount;
  final bool enableHaptics;

  const DigitPad({
    super.key,
    required this.maxNumber,
    required this.isCandidateMode,
    required this.onModeChanged,
    required this.onDigitPressed,
    required this.onClearPressed,
    required this.isDigitFull,
    required this.getRemainingCount,
    required this.enableHaptics,
  });

  @override
  Widget build(BuildContext context) {
    return _buildDigitGrid(context);
  }

  /// Builds the responsive grid of numbers and the clear (X) button.
  Widget _buildDigitGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isThin = constraints.maxWidth < ThemeStyle.bpSM;

        // Significantly shrink padding on mobile to maximize button size.
        double padding = isThin ? 0 : ThemeValues.spacingSuperSpacy;
        final int totalItems = maxNumber + 2;
        double width = constraints.maxWidth - padding;
        const double maxDesktopWidth = 600.0;
        if (width > maxDesktopWidth) width = maxDesktopWidth;

        int columns;
        if (isThin) {
          // Standard number pad layout for mobile (3 columns)
          // This naturally puts special buttons on the bottom row for 9x9 and 12x12.
          columns = 3;
        } else {
          // Desktop: calculate based on width, but ensure we wrap to at least 2 rows
          // for better visual balance and shorter mouse travel.
          final int maxColsForTwoRows = (totalItems / 2).ceil();
          columns = (width / 100).floor().clamp(2, maxColsForTwoRows);
        }

        // Ensure that on thin screens we still maintain at least a 2-row look
        //if (isThin) columns = math.max(columns, (totalItems / 2).ceil());

        // Adjust ratio: taller buttons on mobile to fill vertical space.
        final double ratio = ThemeStyle.getNumberButtonRatio(context);

        return SizedBox(
          width: width,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: ThemeValues.spacingMid,
              mainAxisSpacing: ThemeValues.spacingMid,
              childAspectRatio: ratio,
            ),
            itemCount: maxNumber + 2, // Numbers + Toggle + Clear
            itemBuilder: (context, index) {
              if (index < maxNumber) {
                final value = index + 1;
                final isFull = isDigitFull(value);

                final button = _DigitButton(
                  label: value.toString(),
                  isCandidateMode: isCandidateMode,
                  maxNumber: maxNumber,
                  isFull: isFull,
                  onPressed: () => onDigitPressed(value),
                  enableHaptics: enableHaptics,
                );

                if (isFull) return button;

                // Wrap in a Stack to overlay the badge without affecting button layout/size.
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(child: button),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Badge.count(
                        count: getRemainingCount(value),
                        textStyle: ThemeStyle.badgeCount(context),
                        backgroundColor: ThemeColor.getBadgeCountColor(context),
                        textColor: ThemeColor.getTextBodyColor(context),
                      ),
                    ),
                  ],
                );
              } else if (index == maxNumber) {
                // Mode toggle button.
                return _DigitButton(
                  icon: isCandidateMode ? Icons.edit_note : Icons.mode_edit_outline,
                  maxNumber: maxNumber,
                  isSelected: isCandidateMode,
                  onPressed: () => onModeChanged(!isCandidateMode),
                  enableHaptics: enableHaptics,
                );
              } else if (index == maxNumber + 1) {
                // Clear button.
                return _DigitButton(
                  maxNumber: maxNumber,
                  icon: Icons.backspace_outlined,
                  onPressed: onClearPressed,
                  enableHaptics: enableHaptics,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}

/// Internal helper for individual digit and clear buttons.
class _DigitButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isCandidateMode;
  final int maxNumber;
  final bool isFull;

  /// Whether this specific button is "active" or "selected" (used for the mode toggle highlight)
  final bool isSelected;

  final VoidCallback onPressed;
  final bool enableHaptics;

  const _DigitButton({
    this.label,
    this.icon,
    this.isCandidateMode = false,
    required this.maxNumber,
    this.isFull = false,
    this.isSelected = false,
    required this.onPressed,
    required this.enableHaptics,
  });

  @override
  Widget build(BuildContext context) {
    final bool isThin = MediaQuery.of(context).size.width < ThemeStyle.bpSM;
    final Color accentColor = ThemeColor.getAccentColor(context);

    final Color borderColor =
        isSelected
            ? accentColor
            : isFull
            ? ThemeColor.getCellCorrectColor(context).withAlpha(128)
            : ThemeColor.getBorderExtraColor(context);

    final Color buttonColor =
        isSelected
            ? accentColor
            : isFull
            ? ThemeColor.getCellCorrectColor(context).withAlpha(128)
            : ThemeColor.getCellAccentColor(context);

    return FrostedGlassButton(
      borderRadius: ThemeValues.circularRadius,
      alpha: ThemeValues.alphaStrong,
      borderColor: borderColor,
      borderWidth: ThemeValues.bWidthMid,
      startColor: buttonColor,
      onPressed: onPressed,
      enableHaptics: enableHaptics,
      padding: EdgeInsets.symmetric(vertical: isThin ? 6.0 : 6.0, horizontal: 3.0),
      child:
          icon != null
              ? Icon(
                icon,
                size:
                    (ThemeStyle.numberButtonText(context, sideLength: maxNumber).fontSize ??
                        20),
                color:
                    isSelected
                        ? Colors.white
                        : (icon == Icons.backspace_outlined ? Colors.redAccent : accentColor),
              )
              : Text(
                label!,
                style:
                    isCandidateMode
                        ? ThemeStyle.candidateText(context, sideLength: maxNumber).copyWith(
                          fontSize: math.max(ThemeStyle.candidateText(context,sideLength: maxNumber).fontSize!, 14),
                        )
                        : ThemeStyle.numberButtonText(context, sideLength: maxNumber).copyWith(
                          fontSize: math.max(ThemeStyle.numberButtonText(context,sideLength: maxNumber).fontSize!, 20),
                        ),
                textAlign: TextAlign.center,
              ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sudoku/core/models/sudoku_grid.dart';
import 'package:sudoku/core/theme/colors.dart';
import 'package:sudoku/core/theme/theme.dart';
import 'package:sudoku/features/game/widgets/game_widgets.dart' as widgets;

/// A reusable Sudoku board component that handles grid layout, 
/// highlighting logic, and staggered entry animations.
class SudokuBoard extends StatelessWidget {
  final SudokuGrid grid;
  final Key? gridKey;
  final int? selectedRow;
  final int? selectedCol;
  final int? selectedValue;
  final int? lastMoveRow;
  final int? lastMoveCol;
  final DateTime? lastMoveTime;
  final bool checkCorrectness;
  final bool autoCandidateMode;
  final GenerationMode generationMode;
  final void Function(int row, int col) onCellTap;

  const SudokuBoard({
    super.key,
    required this.grid,
    this.gridKey,
    this.selectedRow,
    this.selectedCol,
    this.selectedValue,
    this.lastMoveRow,
    this.lastMoveCol,
    this.lastMoveTime,
    required this.checkCorrectness,
    required this.autoCandidateMode,
    required this.generationMode,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double padding = 16.0;
        double size = math.min(constraints.maxWidth, constraints.maxHeight) - padding;

        // Enforce a maximum size for desktops, so it doesn't get too large.
        const double maxDesktopSize = 600.0;
        if (size > maxDesktopSize) {
          size = maxDesktopSize;
        }

        // Similarly, enforce a minimum size, so it is always readable.
        const double minAllowedSize = 300.0;
        if (size < minAllowedSize) {
          size = minAllowedSize;
        }

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: GridView.builder(
              key: gridKey,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: grid.gridLength,
                crossAxisSpacing: ThemeValues.noSpacing,
                mainAxisSpacing: ThemeValues.noSpacing,
                childAspectRatio: ThemeValues.squareRatio,
              ),
              itemCount: grid.gridSize,
              itemBuilder: (context, index) {
                int row = index ~/ grid.gridLength;
                int col = index % grid.gridLength;
                
                final cell = grid.get(row, col);
                final cellValue = cell.value;
                final isNull = cellValue == null;
                
                // Highlighting Logic
                bool highlighted = false;
                if (selectedRow != null && selectedCol != null) {
                  highlighted = grid.getScope(row, col).any(
                    (pos) => pos.$1 == selectedRow && pos.$2 == selectedCol
                  );
                }

                final tile = widgets.SudokuTile(
                  row: row,
                  col: col,
                  value: cellValue ?? 0,
                  maxNumber: grid.gridLength,
                  boxRows: grid.boxRows,
                  boxCols: grid.boxCols,
                  bgColor: (grid.getBoxIndex(row, col) % 2 == 0)
                      ? ThemeColor.getCellAccentColor(context)
                      : ThemeColor.getCellBgColor(context),
                  candidates: autoCandidateMode ? cell.realCandidates : cell.userCandidates,
                  isSelected: (selectedRow == row && selectedCol == col),
                  isFixed: !cell.isEditable,
                  isIncorrect: !cell.isCorrect && !isNull,
                  isCorrect: cell.isCorrect && cell.isEditable,
                  isHinted: cell.isHinted,
                  isValueSelected: cellValue == selectedValue && !isNull,
                  isHighlighted: highlighted,
                  showCorrect: checkCorrectness,
                  onTap: () => onCellTap(row, col),
                  alpha: ThemeValues.alphaStrong,
                );

                return StaggeredTileAnimation(
                  delay: _calculateAnimationDelay(row, col, grid.gridLength),
                  child: CellFeedbackWrapper(
                    isCorrect: checkCorrectness && 
                        lastMoveRow == row && lastMoveCol == col && cell.isCorrect,
                    isIncorrect: checkCorrectness && 
                        lastMoveRow == row && lastMoveCol == col && !cell.isCorrect,
                    trigger: lastMoveTime,
                    child: tile,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Duration _calculateAnimationDelay(int row, int col, int sideLength) {
    if (generationMode == GenerationMode.random) {
      return Duration(milliseconds: math.Random(row * sideLength + col).nextInt(500));
    } else {
      final double center = (sideLength - 1) / 2.0;
      final double dist = math.sqrt(math.pow(row - center, 2) + math.pow(col - center, 2));
      final double maxDist = math.sqrt(math.pow(center, 2) * 2);
      return Duration(milliseconds: (dist / (maxDist > 0 ? maxDist : 1) * 600).toInt());
    }
  }
}

class CellFeedbackWrapper extends StatefulWidget {
  final Widget child;
  final bool isCorrect;
  final bool isIncorrect;
  final dynamic trigger;

  const CellFeedbackWrapper({
    super.key,
    required this.child,
    required this.isCorrect,
    required this.isIncorrect,
    this.trigger,
  });

  @override
  State<CellFeedbackWrapper> createState() => _CellFeedbackWrapperState();
}

class _CellFeedbackWrapperState extends State<CellFeedbackWrapper> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 6.0).chain(CurveTween(curve: Curves.elasticIn)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 1),
    ]).animate(_shakeController);

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12).chain(CurveTween(curve: Curves.easeOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 1),
    ]).animate(_pulseController);
  }

  @override
  void didUpdateWidget(CellFeedbackWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      if (widget.isCorrect) _pulseController.forward(from: 0.0);
      if (widget.isIncorrect) _shakeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shakeAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Transform.translate(offset: Offset(_shakeAnimation.value, 0), child: child),
        );
      },
      child: widget.child,
    );
  }
}

class StaggeredTileAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const StaggeredTileAnimation({super.key, required this.child, required this.delay});

  @override
  State<StaggeredTileAnimation> createState() => _StaggeredTileAnimationState();
}

class _StaggeredTileAnimationState extends State<StaggeredTileAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    Future.delayed(widget.delay, () { if (mounted) _controller.forward(); });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(opacity: _opacity.value, child: Transform.scale(scale: _scale.value, child: child)),
      child: widget.child,
    );
  }
}
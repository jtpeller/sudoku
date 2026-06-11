import 'dart:math';

import 'package:sudoku/features/game/logic/difficulty.dart';

import 'package:sudoku/core/models/sudoku_grid.dart';

/// Manages the generation of the provided [SudokuGrid].
final class SudokuGenerator {
  /// Populate the provided [grid] with a valid Sudoku puzzle.
  ///
  /// The [difficulty] influences the number of cells removed.
  ///
  /// The size of the grid is guaranteed to be valid by [SudokuGrid],
  /// therefore the number of cells removed will be proportional.
  static void generate(
    SudokuGrid grid, {
    String difficulty = 'medium',
    GenerationMode mode = GenerationMode.symmetric,
    int? seed,
    void Function(double)? onProgress,
  }) {
    // Build a Sudoku Difficulty object
    SudokuDifficulty diff = SudokuDifficulty(grid.gridSize, difficulty: difficulty);

    final Random rng = Random(seed);

    // Generate using this class's generation methods.
    SudokuGenerator._generateGrid(grid, diff.cellsToRemove(), mode, rng, diff.currentDifficulty.logicLevel, onProgress);
  }

  /// Private helper responsible for generating the grid.
  static void _generateGrid(SudokuGrid grid, int cellsToRemove, GenerationMode mode, Random rng, int targetLevel, void Function(double)? onProgress) {
    // Fill the grid with the necessary data
    SudokuGenerator._fillGrid(grid, 0, 0, rng);
    onProgress?.call(0.1);

    // Remove cells from the grid.
    SudokuGenerator._removeCells(grid, cellsToRemove, mode, rng, targetLevel, onProgress);

    // Compute the candidates for each cell.
    SudokuGenerator.computeCandidates(grid);
    onProgress?.call(1.0);
  }

  /// Recursive backtracking function to fill the Sudoku [grid].
  static bool _fillGrid(SudokuGrid grid, int row, int col, Random rng) {
    if (row == grid.gridLength) {
      return true; // Board is completely filled
    }

    // Figure out the next row and column to work on.
    int nextRow = col == (grid.gridLength - 1) ? row + 1 : row;
    int nextCol = (col + 1) % grid.gridLength;

    // Randomly fill the grid.
    List<int> numbers = List.generate(grid.gridLength, (index) => index + 1)..shuffle(rng);

    // Validate it.
    for (int val in numbers) {
      if (SudokuGenerator._isValid(grid, row, col, val)) {
        grid.updateCellValue(row, col, val);
        grid.setSolution(row, col, val);
        if (SudokuGenerator._fillGrid(grid, nextRow, nextCol, rng)) {
          return true;
        }
        grid.updateCellValue(row, col, null); // Backtrack
      }
    }

    // Flow shouldn't ever reach this!
    return false;
  }

  /// Counts the number of solutions for the current [grid] up to [limit].
  ///
  /// This is used during generation to ensure that removing a cell doesn't
  /// result in multiple solutions (deadlocks).
  static int _countSolutions(SudokuGrid grid, int limit) {
    int count = 0;

    void backtrack(int index) {
      if (count >= limit) return;
      if (index == grid.gridSize) {
        count++;
        return;
      }

      int r = index ~/ grid.gridLength;
      int c = index % grid.gridLength;

      if (grid.get(r, c).value != null) {
        backtrack(index + 1);
        return;
      }

      for (int v = 1; v <= grid.gridLength; v++) {
        if (SudokuGenerator._isValid(grid, r, c, v)) {
          grid.get(r, c).value = v;
          backtrack(index + 1);
          grid.get(r, c).value = null;
        }
      }
    }

    backtrack(0);
    return count;
  }

  /// Analyzes the logical difficulty of the [grid].
  /// Returns the highest logic level required to solve it.
  static int _analyzeLogicLevel(SudokuGrid grid) {
    // Create a clone to simulate solving without affecting the real game
    SudokuGrid workGrid = SudokuGrid.fromList(
      grid.map((cell) => SudokuCell.copyFrom(cell)).toList(),
    );
    int highestLevel = 1;
    bool changed = true;

    while (changed) {
      changed = false;
      SudokuGenerator.computeCandidates(workGrid);

      // Check for Naked Singles (Level 1)
      for (int r = 0; r < workGrid.gridLength; r++) {
        for (int c = 0; c < workGrid.gridLength; c++) {
          var cell = workGrid.get(r, c);
          if (cell.value == null && cell.realCandidates.length == 1) {
            cell.value = cell.realCandidates.first; // Silent update
            changed = true;
          }
        }
      }
      if (changed) { changed = true; continue; }

      // Check for Hidden Singles (Level 2)
      if (_applyHiddenSingles(workGrid)) {
        highestLevel = max(highestLevel, 2);
        changed = true;
        continue;
      }

      // Check for X-Wings (Level 4)
      if (_applyXWings(workGrid)) {
        highestLevel = max(highestLevel, 4);
        changed = true;
        continue;
      }
    }

    // If not fully solved, it's Expert level (requires backtracking)
    bool solved = workGrid.every((cell) => cell.value != null);
    return solved ? highestLevel : 5;
  }

  /// Applies hidden singles to the provided [grid]
  ///
  /// Hidden Singles are situations where a number can only go in 
  /// one cell inside a region
  static bool _applyHiddenSingles(SudokuGrid grid) {
    for (int v = 1; v <= grid.gridLength; v++) {
      for (int i = 0; i < grid.gridLength; i++) {
        // Check rows, columns, and boxes
        if (_checkHiddenInUnit(grid, grid.getRow(i), v, i, 0)) return true;
        if (_checkHiddenInUnit(grid, grid.getColumn(i), v, i, 1)) return true;
        if (_checkHiddenInUnit(grid, grid.getBox(i), v, i, 2)) return true;
      }
    }
    return false;
  }

  /// Determines if, in the provided Iterable unit, whether there is a hidden
  /// single in that region.
  static bool _checkHiddenInUnit(SudokuGrid grid, Iterable<SudokuCell> unit, int val, int unitIdx, int type) {
    int count = 0;
    int lastIdx = -1;
    int i = 0;
    for (var cell in unit) {
      if (cell.value == val) return false;
      if (cell.value == null && cell.realCandidates.contains(val)) {
        count++;
        lastIdx = i;
      }
      i++;
    }
    if (count == 1) {
      int r, c;
      if (type == 0) { r = unitIdx; c = lastIdx; }
      else if (type == 1) { r = lastIdx; c = unitIdx; }
      else {
        int boxStartRow = (unitIdx ~/ grid.boxRows) * grid.boxRows;
        int boxStartCol = (unitIdx % grid.boxRows) * grid.boxCols;
        r = boxStartRow + (lastIdx ~/ grid.boxCols);
        c = boxStartCol + (lastIdx % grid.boxCols);
      }
      grid.get(r, c).value = val; // Silent update
      return true;
    }
    return false;
  }

  /// Applies X-Wing in the provided [grid].
  /// 
  /// An X-Wing is a single-digit pattern which appears across two rows / columns.
  /// A single digit has four possible cells which is possibly a particular value.
  /// 
  /// X-Wings are useful because they signal that those two columns (and rows) cannot 
  /// be that particular value.
  static bool _applyXWings(SudokuGrid grid) {
    for (int v = 1; v <= grid.gridLength; v++) {
      List<List<int>> rowOccurrences = [];
      for (int r = 0; r < grid.gridLength; r++) {
        List<int> cols = [];
        for (int c = 0; c < grid.gridLength; c++) {
          if (grid.get(r, c).value == null && grid.get(r, c).realCandidates.contains(v)) cols.add(c);
        }
        if (cols.length == 2) rowOccurrences.add([r, ...cols]);
      }
      for (int i = 0; i < rowOccurrences.length; i++) {
        for (int j = i + 1; j < rowOccurrences.length; j++) {
          var r1 = rowOccurrences[i];
          var r2 = rowOccurrences[j];
          if (r1[1] == r2[1] && r1[2] == r2[2]) {
            // In a full implementation, we'd remove candidates here and return true if changed
          }
        }
      }
    }
    return false;
  }

  // Checks if a number can be placed at a given row, col
  static bool _isValid(SudokuGrid grid, int row, int col, int num) {
    final int len = grid.gridLength;
    // Check row and column
    final int rowOffset = row * len;
    for (int i = 0; i < len; i++) {
      if (grid.data[rowOffset + i].value == num) return false;
      if (grid.data[i * len + col].value == num) return false;
    }

    // Check the box
    final int boxStartRow = (row ~/ grid.boxRows) * grid.boxRows;
    final int boxStartCol = (col ~/ grid.boxCols) * grid.boxCols;
    for (int r = boxStartRow; r < boxStartRow + grid.boxRows; r++) {
      final int rOffset = r * len;
      for (int c = boxStartCol; c < boxStartCol + grid.boxCols; c++) {
        if (grid.data[rOffset + c].value == num) return false;
      }
    }
    return true;
  }

  /// Public method to compute candidates for a given Sudoku board
  static void computeCandidates(SudokuGrid grid) {
    // Loop through and populate the candidates.
    for (int row = 0; row < grid.gridLength; row++) {
      for (int col = 0; col < grid.gridLength; col++) {
        var val = grid.get(row, col).value;
        if (val == null) {
          grid.setComputedCandidates(row, col, _getCandidates(grid, row, col));
        } else {
          // Fixed numbers are their own candidates
          grid.setComputedCandidates(row, col, {val});
        }
      }
    }
  }

  /// Helper method to get candidates for a specific cell
  static Set<int> _getCandidates(SudokuGrid grid, int row, int col) {
    Set<int> candidates = {for (int i = 1; i <= grid.gridLength; i++) i};
    final int len = grid.gridLength;
    final int rowOffset = row * len;
    for (int i = 0; i < len; i++) {
      int? v = grid.data[rowOffset + i].value;
      if (v != null) candidates.remove(v);
      v = grid.data[i * len + col].value;
      if (v != null) candidates.remove(v);
    }

    // Remove candidates based on the subgrid box
    final int boxStartRow = (row ~/ grid.boxRows) * grid.boxRows;
    final int boxStartCol = (col ~/ grid.boxCols) * grid.boxCols;
    for (int r = boxStartRow; r < boxStartRow + grid.boxRows; r++) {
      final int rOffset = r * len;
      for (int c = boxStartCol; c < boxStartCol + grid.boxCols; c++) {
        int? v = grid.data[rOffset + c].value;
        if (v != null) candidates.remove(v);
      }
    }
    return candidates;
  }

  /// Removes cells based on difficulty and mode.
  static void _removeCells(SudokuGrid grid, int cellsToRemove, GenerationMode mode, Random rng, int targetLevel, void Function(double)? onProgress) {
    // Remove cells based on the mode
    switch (mode) {
      case GenerationMode.symmetric:
        SudokuGenerator._removeSymmetrically(grid, cellsToRemove, rng, targetLevel, onProgress);
      case GenerationMode.random:
        SudokuGenerator._removeRandomly(grid, cellsToRemove, rng, targetLevel, onProgress);
    }
  }

  /// Randomly removes cells from the grid.
  static void _removeRandomly(SudokuGrid grid, int cellsToRemove, Random rng, int targetLevel, [void Function(double)? onProgress]) {
    // Get all positions and shuffle them to avoid bias.
    List<int> positions = List.generate(grid.gridSize, (i) => i)..shuffle(rng);
    int removed = 0;

    for (int i = 0; i < positions.length; i++) {
      int pos = positions[i];
      onProgress?.call(0.1 + (i / positions.length) * 0.9);
      int r = pos ~/ grid.gridLength;
      int c = pos % grid.gridLength;

      int? originalValue = grid.get(r, c).value;
      if (originalValue == null) continue;

      // Tentatively remove the value
      grid.updateCellValue(r, c, null);

      // Verify Uniqueness & Logic Level (Don't exceed target difficulty)
      if (SudokuGenerator._countSolutions(grid, 2) == 1) {
        int currentLevel = SudokuGenerator._analyzeLogicLevel(grid);
        if (currentLevel <= targetLevel) {
        grid.setEditable(r, c, true);
        removed++;
          if (removed >= cellsToRemove && currentLevel == targetLevel) break;
        } else {
          grid.updateCellValue(r, c, originalValue);
        }
      } else {
        grid.updateCellValue(r, c, originalValue);
      }
    }
  }

  /// Removes cells in the typical Sudoku manner, where it is symmetrical across row/col.
  static void _removeSymmetrically(SudokuGrid grid, int cellsToRemove, Random rng, int targetLevel, [void Function(double)? onProgress]) {
    // Create necessary items for removal process.
    final int rows = grid.rows;
    final int columns = grid.columns;

    // Generate pairs of symmetric positions
    List<(int, int)> positions = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        int rowWrap = rows - r - 1;
        int colWrap = columns - c - 1;
        // Add each unique pair (or center cell) once
        if (r * columns + c <= rowWrap * columns + colWrap) {
          positions.add((r, c));
        }
      }
    }
    positions.shuffle(rng);

    int removed = 0;
    for (int i = 0; i < positions.length; i++) {
      if (removed >= cellsToRemove) break;
      var pos = positions[i];
      onProgress?.call(0.1 + (i / positions.length) * 0.9);

      int r1 = pos.$1;
      int c1 = pos.$2;
      int r2 = rows - r1 - 1;
      int c2 = columns - c1 - 1;

      int? val1 = grid.get(r1, c1).value;
      int? val2 = grid.get(r2, c2).value;

      if (val1 == null || val2 == null) continue;

      // Tentatively remove the pair
      grid.updateCellValue(r1, c1, null);
      if (r1 != r2 || c1 != c2) grid.updateCellValue(r2, c2, null);

      // Verify uniqueness
      if (SudokuGenerator._countSolutions(grid, 2) == 1) {
        int currentLevel = SudokuGenerator._analyzeLogicLevel(grid);
        if (currentLevel <= targetLevel) {
          grid.setEditable(r1, c1, true);
          grid.setEditable(r2, c2, true);
          removed += (r1 == r2 && c1 == c2) ? 1 : 2;
        } else {
          grid.updateCellValue(r1, c1, val1);
          grid.updateCellValue(r2, c2, val2);
        }
      } else {
        // Restore the values
        grid.updateCellValue(r1, c1, val1);
        grid.updateCellValue(r2, c2, val2);
      }
    }
  }
}

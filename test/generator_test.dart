import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/models/sudoku_grid.dart';
import 'package:sudoku/features/game/logic/generator.dart';

void main() {
  group('SudokuGenerator Tests', () {
    test('Generate 4x4 symmetrical board', () {
      final grid = SudokuGrid.empty(gridLength: 4);
      grid.setGenerating(true);

      // Generate a game
      SudokuGenerator.generate(grid, difficulty: 'easy', mode: GenerationMode.symmetric, seed: 123);
      grid.setGenerating(false);

      // Verify basic dimensions and generated numbers
      expect(grid.gridLength, 4);
      expect(grid.boxRows, 2);
      expect(grid.boxCols, 2);

      // Verify that all cells have valid solution values (1..4)
      for (var cell in grid) {
        expect(cell.solution, inClosedOpenRange(1, 5));
      }

      // Symmetrical verification
      int editableCount = 0;
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          int oppositeRow = 4 - r - 1;
          int oppositeCol = 4 - c - 1;
          // Check that editability is symmetrical
          expect(grid.get(r, c).isEditable, grid.get(oppositeRow, oppositeCol).isEditable);
          if (grid.get(r, c).isEditable) editableCount++;
        }
      }
      expect(editableCount, greaterThan(0));
    });

    test('Generate 9x9 random board', () {
      final grid = SudokuGrid.empty(gridLength: 9);
      grid.setGenerating(true);

      SudokuGenerator.generate(grid, difficulty: 'medium', mode: GenerationMode.random, seed: 456);
      grid.setGenerating(false);

      expect(grid.gridLength, 9);

      // Count editable cells (removed cells)
      int editableCount = 0;
      for (var cell in grid) {
        expect(cell.solution, inClosedOpenRange(1, 10));
        if (cell.isEditable) {
          editableCount++;
          expect(cell.value, isNull);
        } else {
          expect(cell.value, cell.solution);
        }
      }
      expect(editableCount, greaterThan(0));
    });

    test('computeCandidates computes correct realCandidates', () {
      final grid = SudokuGrid.empty(gridLength: 9);
      grid.setGenerating(true);

      // Set some values in row 0
      grid.updateCellValue(0, 0, 1);
      grid.updateCellValue(0, 1, 2);
      grid.updateCellValue(0, 2, 3);

      // Set some values in column 4
      grid.updateCellValue(1, 4, 4);
      grid.updateCellValue(2, 4, 5);

      // Set some values in box 0 (rows 0..2, cols 0..2)
      grid.updateCellValue(1, 1, 6);

      // Compute candidates
      SudokuGenerator.computeCandidates(grid);

      // Cell (0, 4):
      // Row 0 has: 1, 2, 3, (0, 4) itself is empty
      // Col 4 has: 4, 5
      // Box 1 (rows 0..2, cols 3..5) has no other values
      // Candidates for (0, 4) should be {1..9} excluding {1, 2, 3, 4, 5}
      // i.e., {6, 7, 8, 9}
      final candidates = grid.get(0, 4).realCandidates;
      expect(candidates, equals({6, 7, 8, 9}));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/features/game/logic/sudoku_manager.dart';

void main() {
  group('SudokuManager Tests', () {
    late SudokuManager manager;

    setUp(() {
      // Setup mock SharedPreferences for storage testing
      SharedPreferences.setMockInitialValues({});
      manager = SudokuManager();
    });

    test('initial state and metrics', () {
      expect(manager.gridSize, 81, reason: 'Default grid size should be 81 (9x9)');
      expect(manager.maxNumber, 9, reason: 'Default max number should be 9');
      expect(manager.mistakes, 0, reason: 'Initial mistakes should be 0');
      expect(manager.hintsUsed, 0, reason: 'Initial hints used should be 0');
      expect(manager.isGameOver, isFalse, reason: 'Game should not be over initially');
      expect(manager.usedAutoCandidate, isFalse, reason: 'Auto-candidate should not be marked as used initially');
    });

    test('difficulty setter validation', () {
      manager.setDifficulty('easy');
      expect(manager.difficulty, 'easy', reason: 'Difficulty should be set to easy');

      manager.setDifficulty('Hard'); // case insensitive match check
      expect(manager.difficulty, 'hard', reason: 'Difficulty setting should be case-insensitive');

      expect(() => manager.setDifficulty('invalid_diff'), throwsArgumentError, reason: 'Invalid difficulty should throw ArgumentError');
    });

    test('grid size setter validation', () {
      manager.setGridSizeFromSideLength(4);
      expect(manager.gridSize, 16, reason: 'Side length 4 should result in grid size 16');
      expect(manager.length, 4.0, reason: 'Side length should be 4.0');

      manager.setGridSize(9); // 3x3 box grid size 9? Wait, side length 9 => grid size 81
      expect(manager.gridSize, 9, reason: 'Grid size should be set to 9');
      // 9 cells is 3x3 board.
      expect(manager.length, 3.0, reason: 'Side length should be 3.0 for grid size 9');

      // Primed size (not perfect square)
      expect(() => manager.setGridSize(10), throwsArgumentError, reason: 'Non-perfect square grid size should throw ArgumentError');
    });

    test('mistakes and game over limit', () {
      expect(manager.isGameOver, isFalse, reason: 'Game should not be over with 0 mistakes');

      manager.mistaken();
      expect(manager.mistakes, 1);
      expect(manager.isGameOver, isFalse);

      manager.mistaken();
      manager.mistaken();
      expect(manager.mistakes, 3, reason: 'Mistake count should be 3');
      expect(manager.isGameOver, isTrue, reason: 'Game should be over when mistakes reach the limit (3)');
    });

    test('hint usage correctly solves cell', () {
      manager.setGridSizeFromSideLength(9);
      manager.generateGame(seed: 42);

      // Find an editable cell
      int? row;
      int? col;
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (manager.isEditable(r, c)) {
            row = r;
            col = c;
            break;
          }
        }
        if (row != null) break;
      }

      expect(row, isNotNull, reason: 'Should find an editable row');
      expect(col, isNotNull, reason: 'Should find an editable column');
      expect(manager.isHinted(row!, col!), isFalse, reason: 'Cell should not be hinted initially');
      expect(manager.getValue(row, col), isNull, reason: 'Editable cell should be empty initially');

      // Request a hint
      final solution = manager.grid.get(row, col).solution;
      manager.hintUsed(row, col);
      manager.setAsSolved(row, col);

      // Verify cell is solved, marked hinted, and stats updated
      expect(manager.getValue(row, col), solution, reason: 'Cell value should match the solution after hint');
      expect(manager.isHinted(row, col), isTrue, reason: 'Cell should be marked as hinted');
      expect(manager.hintsUsed, 1, reason: 'Hint count should increment');
    });

    test('reset and clear operations', () {
      manager.setGridSizeFromSideLength(9);
      manager.generateGame(seed: 111);

      // Edit an editable cell
      int? row;
      int? col;
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (manager.isEditable(r, c)) {
            row = r;
            col = c;
            break;
          }
        }
        if (row != null) break;
      }
      expect(row, isNotNull, reason: 'Should find an editable row');
      expect(col, isNotNull, reason: 'Should find an editable column');

      // Manually set a value (regular user entry)
      manager.setValueAt(row!, col!, 9);
      
      // Use a hint on a DIFFERENT cell
      int hRow = (row + 1) % 9;
      int hCol = col;
      while (!manager.isEditable(hRow, hCol)) {
        hCol = (hCol + 1) % 9;
        if (hCol == 0) hRow = (hRow + 1) % 9;
      }
      final hSolution = manager.grid.get(hRow, hCol).solution;
      manager.hintUsed(hRow, hCol);
      manager.setAsSolved(hRow, hCol); // Marks as hinted so reset() ignores it

      // Make a mistake
      manager.mistaken();
      expect(manager.mistakes, 1, reason: 'Mistake count should be 1');

      // Reset (clears non-hinted edits, keeps hints)
      manager.reset();
      
      // Regular entry should be cleared, hinted entry remains
      expect(manager.getValue(row, col), isNull, reason: 'Regular entries should be cleared');
      expect(manager.getValue(hRow, hCol), hSolution, reason: 'Hints should be preserved');

      // Clear (resets everything, clears stats)
      manager.clear();
      expect(manager.mistakes, 0, reason: 'Mistakes should be reset to 0 after clear');
      expect(manager.hintsUsed, 0, reason: 'Hints should be reset to 0 after clear');
      expect(manager.getValue(row, col), isNull, reason: 'Cell value should be cleared after clear');
    });

    test('saveGame and loadGame persistence', () async {
      manager.setGridSizeFromSideLength(9);
      manager.generateGame(seed: 999);
      manager.mistaken();

      // Save the game
      await manager.saveGame(120.0, slot: 'test_save');

      // Create a new manager instance and load from storage
      final newManager = SudokuManager();
      final loadSuccess = await newManager.loadGame(slot: 'test_save');

      expect(loadSuccess, isTrue, reason: 'Game should load successfully from slot');
      expect(newManager.gridSize, manager.gridSize, reason: 'Grid size should be preserved after load');
      expect(newManager.mistakes, 1, reason: 'Mistake count should be preserved after load');
      expect(newManager.elapsedTime, 120.0, reason: 'Elapsed time should be preserved after load');

      // Verify grid cell contents match
      for (int i = 0; i < 81; i++) {
        int r = i ~/ 9;
        int c = i % 9;
        expect(newManager.getValue(r, c), manager.getValue(r, c), reason: 'Cell value at ($r, $c) should match original after load');
        expect(newManager.grid.get(r, c).solution, manager.grid.get(r, c).solution, reason: 'Cell solution at ($r, $c) should match original after load');
        expect(newManager.isEditable(r, c), manager.isEditable(r, c), reason: 'Cell editability at ($r, $c) should match original after load');
      }
    });
  });
}

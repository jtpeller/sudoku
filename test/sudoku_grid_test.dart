import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/models/sudoku_grid.dart';

void main() {
  group('SudokuGrid Model Tests', () {
    test('SudokuGrid.empty creates a valid empty grid with correct dimensions', () {
      final grid = SudokuGrid.empty(gridLength: 9);
      expect(grid.gridLength, 9);
      expect(grid.boxRows, 3);
      expect(grid.boxCols, 3);
      expect(grid.isEmpty, isTrue);
      
      // Check that all cells are initialized to default empty state
      for (var cell in grid) {
        expect(cell.value, isNull);
        expect(cell.solution, 0);
        expect(cell.isHinted, isFalse);
      }
    });

    test('dimsFromLength calculates non-square subgrids correctly', () {
      // Standard 9x9 -> 3x3 boxes
      expect(SudokuGrid.dimsFromLength(9), (3, 3));
      // 6x6 -> 2x3 boxes
      expect(SudokuGrid.dimsFromLength(6), (2, 3));
      // 4x4 -> 2x2 boxes
      expect(SudokuGrid.dimsFromLength(4), (2, 2));
    });

    test('updateCellValue updates metrics and detects conflicts', () {
      final grid = SudokuGrid.empty(gridLength: 9);
      grid.setGenerating(true); // Allow setting values in "empty" cells

      // Place initial value
      grid.updateCellValue(0, 0, 5);
      expect(grid.get(0, 0).value, 5);
      expect(grid.getCountOf(5), 1);
      expect(grid.getRemainingOf(5), 8);
      expect(grid.isFull(5), isFalse);

      // Place conflicting value in same row
      grid.updateCellValue(0, 8, 5);
      
      final conflicts = grid.getConflicts(0, 0);
      expect(conflicts, contains((0, 8)));
      expect(grid.getCountOf(5), 2);

      // Removing a value should update counts
      grid.updateCellValue(0, 8, null);
      expect(grid.getCountOf(5), 1);
      expect(grid.getConflicts(0, 0), isEmpty);
    });

    test('getBoxIndex identifies correct subgrid IDs', () {
      final grid = SudokuGrid.empty(gridLength: 9);
      // Top-left box
      expect(grid.getBoxIndex(0, 0), 0);
      expect(grid.getBoxIndex(2, 2), 0);
      // Top-middle box
      expect(grid.getBoxIndex(0, 3), 1);
      // Center box
      expect(grid.getBoxIndex(4, 4), 4);
      // Bottom-right box
      expect(grid.getBoxIndex(8, 8), 8);
    });

    test('getScope returns the union of row, column, and box neighbors', () {
      final grid = SudokuGrid.empty(gridLength: 4);
      // In a 4x4 grid, for cell (0,0):
      // Row peers: (0,1), (0,2), (0,3)
      // Col peers: (1,0), (2,0), (3,0)
      // Box peers: (0,1), (1,0), (1,1)
      // Distinct neighbors: 7
      final scope = grid.getScope(0, 0);
      
      expect(scope.length, 7);
      expect(scope, containsAll([(0, 1), (0, 2), (0, 3), (1, 0), (2, 0), (3, 0), (1, 1)]));
    });

    test('resetToBeginning clears non-hinted editable cells', () {
      final grid = SudokuGrid.empty(gridLength: 9);
      grid.setGenerating(true);
      
      // Set up a cell that is fixed (not editable)
      grid.updateCellValue(0, 0, 1);
      grid.get(0, 0).isEditable = false;
      
      // Set up a cell that is a hint
      grid.updateCellValue(0, 1, 2);
      grid.get(0, 1).isEditable = true;
      grid.get(0, 1).isHinted = true;
      
      // Set up a regular user entry
      grid.updateCellValue(0, 2, 3);
      grid.get(0, 2).isEditable = true;

      grid.resetToBeginning();

      expect(grid.get(0, 0).value, 1, reason: 'Fixed cells remain');
      expect(grid.get(0, 1).value, 2, reason: 'Hinted cells remain');
      expect(grid.get(0, 2).value, isNull, reason: 'User entries are cleared');
    });

    test('updateCellValue correctly tracks internal conflict counts', () {
      final grid = SudokuGrid.empty(gridLength: 9);
      grid.setGenerating(true);

      // (0, 0) starts with 0 conflicts
      expect(grid.getConflictCount(0, 0), 0, reason: 'Initial conflict count should be 0');

      // Add a value and create a row conflict
      grid.updateCellValue(0, 0, 1);
      grid.updateCellValue(0, 1, 1);

      expect(grid.getConflictCount(0, 0), 1, reason: '(0,0) should have 1 conflict after adding a row neighbor with same value');
      expect(grid.getConflictCount(0, 1), 1, reason: '(0,1) should have 1 conflict after being added as a row neighbor with same value');

      // Add a column conflict to (0,0)
      grid.updateCellValue(5, 0, 1);
      expect(grid.getConflictCount(0, 0), 2, reason: '(0,0) should have 2 conflicts after adding a column neighbor with same value');
      expect(grid.getConflictCount(5, 0), 1, reason: '(5,0) should have 1 conflict with (0,0)');

      // Remove the row conflict
      grid.updateCellValue(0, 1, null);
      expect(grid.getConflictCount(0, 0), 1, reason: '(0,0) conflict count should decrease after removing (0,1)');
      expect(grid.getConflictCount(0, 1), 0, reason: '(0,1) conflict count should reset to 0 after its value is cleared');
      expect(grid.getConflictCount(5, 0), 1, reason: '(5,0) conflict count should remain unchanged');
    });

    test('updateCellValue correctly tracks box-specific conflicts', () {
      final grid = SudokuGrid.empty(gridLength: 9);
      grid.setGenerating(true);

      // Place value at (0, 0)
      grid.updateCellValue(0, 0, 9);
      expect(grid.getConflictCount(0, 0), 0, reason: 'Initial placement should have 0 conflicts');

      // Place same value at (1, 1) - Same box, but different row/column
      grid.updateCellValue(1, 1, 9);
      expect(grid.getConflictCount(0, 0), 1, reason: '(0,0) should have 1 box conflict with (1,1)');
      expect(grid.getConflictCount(1, 1), 1, reason: '(1,1) should have 1 box conflict with (0,0)');

      // Place same value at (2, 2) - Same box, different row/column from both
      grid.updateCellValue(2, 2, 9);
      expect(grid.getConflictCount(0, 0), 2, reason: '(0,0) should have 2 box conflicts');
      expect(grid.getConflictCount(1, 1), 2, reason: '(1,1) should have 2 box conflicts');
      expect(grid.getConflictCount(2, 2), 2, reason: '(2,2) should have 2 box conflicts');

      // Remove (1, 1)
      grid.updateCellValue(1, 1, null);
      expect(grid.getConflictCount(0, 0), 1, reason: '(0,0) conflict count should decrease');
      expect(grid.getConflictCount(2, 2), 1, reason: '(2,2) conflict count should decrease');
      expect(grid.getConflictCount(1, 1), 0, reason: '(1,1) should have 0 conflicts after being cleared');
    });
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/models/grid.dart';
import 'package:sudoku/core/models/sudoku_grid.dart';

void main() {
  group('Grid<E> Base Class Tests', () {
    test('Constructor generation & bounds', () {
      final grid = Grid<int>.generate(rows: 3, columns: 4, generator: () => 0);
      expect(grid.rows, 3);
      expect(grid.columns, 4);
      expect(grid.gridSize, 12);
      expect(grid.get(0, 0), 0);

      expect(() => grid.get(-1, 0), throwsRangeError);
      expect(() => grid.get(3, 0), throwsRangeError);
      expect(() => grid.get(0, 4), throwsRangeError);
    });

    test('get and set', () {
      final grid = Grid<int>.generate(rows: 2, columns: 2, generator: () => 0);
      grid.set(0, 1, 42);
      expect(grid.get(0, 1), 42);
      expect(grid.get(1, 0), 0);
    });

    test('copyFrom success & failure', () {
      final source = Grid<int>.generate(rows: 2, columns: 2, generator: () => 5);
      final dest = Grid<int>.generate(rows: 2, columns: 2, generator: () => 0);
      dest.copyFrom(source);
      expect(dest.get(0, 0), 5);
      expect(dest.get(1, 1), 5);

      final mismatchedDest = Grid<int>.generate(rows: 3, columns: 2, generator: () => 0);
      expect(() => mismatchedDest.copyFrom(source), throwsArgumentError);
    });

    test('fromList constructor', () {
      final grid = Grid<int>.fromList(rows: 2, columns: 3, data: [1, 2, 3, 4, 5, 6]);
      expect(grid.get(0, 0), 1);
      expect(grid.get(0, 2), 3);
      expect(grid.get(1, 0), 4);
      expect(grid.get(1, 2), 6);

      expect(() => Grid<int>.fromList(rows: 2, columns: 3, data: [1, 2]), throwsAssertionError);
    });

    test('clone / deep copy', () {
      final grid = Grid<int>.fromList(rows: 2, columns: 2, data: [1, 2, 3, 4]);
      final cloned = grid.clone((e) => e);
      expect(cloned.get(0, 0), 1);
      expect(cloned.get(1, 1), 4);

      cloned.set(0, 0, 99);
      expect(grid.get(0, 0), 1); // Original unchanged
      expect(cloned.get(0, 0), 99);
    });

    test('getRow and getColumn', () {
      final grid = Grid<int>.fromList(rows: 3, columns: 3, data: [
        1, 2, 3,
        4, 5, 6,
        7, 8, 9,
      ]);

      expect(grid.getRow(1), [4, 5, 6]);
      expect(grid.getColumn(2), [3, 6, 9]);
    });
  });

  group('SudokuGrid Model Tests', () {
    test('dimsFromLength calculation', () {
      expect(SudokuGrid.dimsFromLength(9), (3, 3));
      expect(SudokuGrid.dimsFromLength(4), (2, 2));
      expect(SudokuGrid.dimsFromLength(6), (2, 3));
      expect(SudokuGrid.dimsFromLength(12), (3, 4));
    });

    test('empty grid creation and initial state', () {
      final grid = SudokuGrid.empty(gridLength: 9);
      expect(grid.gridLength, 9);
      expect(grid.boxRows, 3);
      expect(grid.boxCols, 3);
      expect(grid.isEmpty, isTrue);
      expect(grid.isNotEmpty, isFalse);

      for (var cell in grid) {
        expect(cell.value, isNull);
        expect(cell.solution, 0);
        expect(cell.isEditable, isFalse); // Default is false because _isGenerating is false
        expect(cell.isHinted, isFalse);
        expect(cell.userCandidates, isEmpty);
        expect(cell.realCandidates, isEmpty);
      }
    });

    test('updateCellValue counts and conflicts', () {
      final grid = SudokuGrid.empty(gridLength: 9);
      grid.setGenerating(true);

      // Initially count of 5 is 0
      expect(grid.getCountOf(5), 0);
      expect(grid.getRemainingOf(5), 9);
      expect(grid.isFull(5), isFalse);

      // Set value 5 at (0, 0)
      grid.updateCellValue(0, 0, 5);
      expect(grid.getCountOf(5), 1);
      expect(grid.getRemainingOf(5), 8);

      // Set conflicting value 5 at (0, 3) (same row)
      grid.updateCellValue(0, 3, 5);
      expect(grid.getCountOf(5), 2);

      // Conflicts checks
      final conflicts = grid.getConflicts(0, 0);
      expect(conflicts, contains((0, 3)));
    });

    test('cell copying and json serialization', () {
      final cell = SudokuCell(solution: 9, value: 5, isEditable: true, isHinted: true);
      cell.userCandidates = {1, 2, 3};
      cell.realCandidates = {9};

      final copiedCell = SudokuCell.copyFrom(cell);
      expect(copiedCell.solution, 9);
      expect(copiedCell.value, 5);
      expect(copiedCell.isEditable, isTrue);
      expect(copiedCell.isHinted, isTrue);
      expect(copiedCell.userCandidates, {1, 2, 3});
      expect(copiedCell.realCandidates, {9});

      final json = cell.toJson();
      expect(json['solution'], 9);
      expect(json['value'], 5);
      expect(json['isEditable'], isTrue);
      expect(json['isHinted'], isTrue);
      expect(json['userCandidates'], [1, 2, 3]);
      expect(json['realCandidates'], [9]);

      final cellFromMap = SudokuCell.fromMap(json);
      expect(cellFromMap.solution, 9);
      expect(cellFromMap.value, 5);
      expect(cellFromMap.isEditable, isTrue);
      expect(cellFromMap.isHinted, isTrue);
      expect(cellFromMap.userCandidates, {1, 2, 3});
      expect(cellFromMap.realCandidates, {9});
    });

    test('getScope lists all row, column, box neighbors', () {
      final grid = SudokuGrid.empty(gridLength: 9);
      final scope = grid.getScope(0, 0);

      // Scope for (0,0) in 9x9 should contain:
      // Row 0 neighbors: (0,1) to (0,8) [8 cells]
      // Col 0 neighbors: (1,0) to (8,0) [8 cells]
      // Box 0 neighbors: (1,1), (1,2), (2,1), (2,2) [4 cells - others are covered in row/col]
      // Total unique scope neighbors = 20 cells
      expect(scope.length, 20);

      expect(scope, contains((0, 1)));
      expect(scope, contains((8, 0)));
      expect(scope, contains((2, 2)));
      expect(scope, isNot(contains((0, 0)))); // shouldn't contain self
    });
  });
}

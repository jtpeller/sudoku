import 'dart:math';

class SudokuGenerator {
  late List<List<int>> _board;
  late List<List<dynamic>> _solution;
  late List<List<bool>> _isEditable;
  final Random _random = Random();

  // Public method to generate a Sudoku puzzle
  Map<String, dynamic> generateSudoku(String difficulty) {
    _board = List.generate(9, (_) => List.filled(9, 0));
    _solution = List.generate(9, (_) => List.filled(9, 0));
    _isEditable = List.generate(9, (_) => List.filled(9, false));

    _fillBoard(0, 0); // Fill the complete board
    _solution = List.from(_board.map((row) => List.from(row))); // Store the solution

    _removeCells(difficulty); // Remove cells based on difficulty

    return {'puzzle': _board, 'solution': _solution, 'isEditable': _isEditable};
  }

  // Recursive backtracking function to fill the 9x9 Sudoku board
  bool _fillBoard(int row, int col) {
    if (row == 9) {
      return true; // Board is completely filled
    }

    int nextRow = col == 8 ? row + 1 : row;
    int nextCol = (col + 1) % 9;

    List<int> numbers = List.generate(9, (index) => index + 1)..shuffle(_random);

    for (int num in numbers) {
      if (_isValid(row, col, num)) {
        _board[row][col] = num;
        if (_fillBoard(nextRow, nextCol)) {
          return true;
        }
        _board[row][col] = 0; // Backtrack
      }
    }
    return false;
  }

  // Checks if a number can be placed at a given row, col
  bool _isValid(int row, int col, int num) {
    // Check row
    for (int x = 0; x < 9; x++) {
      if (_board[row][x] == num) {
        return false;
      }
    }

    // Check column
    for (int x = 0; x < 9; x++) {
      if (_board[x][col] == num) {
        return false;
      }
    }

    // Check 3x3 box
    int startRow = row - row % 3;
    int startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_board[i + startRow][j + startCol] == num) {
          return false;
        }
      }
    }
    return true;
  }

  // Removes cells based on difficulty
  void _removeCells(String difficulty) {
    int cellsToRemove;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        cellsToRemove = 35;
      case 'medium':
        cellsToRemove = 45;
      case 'hard':
        cellsToRemove = 55;
      default:
        // Default to easy
        cellsToRemove = 35;
    }

    int removedCount = 0;
    while (removedCount < cellsToRemove) {
      int row = _random.nextInt(9);
      int col = _random.nextInt(9);

      if (_board[row][col] != 0) {
        _board[row][col] = 0;
        _isEditable[row][col] = true; // Mark as non-editable
        removedCount++;
      }
    }
  }
}

import 'dart:math';

enum SudokuDifficulty { beginner, easy, medium, hard, expert, impossible }

enum GenerationMode {symmetric, random}

class SudokuGenerator {
  late List<List<int>> _board;
  late List<List<int>> _solution;
  late List<List<bool>> _isEditable;
  final Random _random = Random();

  /// Generates a sudoku puzzle. Provides the board, solution, and which cells are editable.
  Map<String, dynamic> generateSudoku(SudokuDifficulty difficulty, {GenerationMode mode = GenerationMode.symmetric}) {
    _board = List.generate(9, (_) => List.filled(9, 0));
    _solution = List.generate(9, (_) => List.filled(9, 0));
    _isEditable = List.generate(9, (_) => List.filled(9, false));

    _fillBoard(0, 0); // Fill the complete board
    _solution = List.from(_board.map((row) => List<int>.from(row))); // Store the solution

    _removeCells(difficulty, mode); // Remove cells based on difficulty

    return {'puzzle': _board, 'solution': _solution, 'isEditable': _isEditable};
  }

  // Public method to compute candidates for a given Sudoku board
  static List<List<Set<int>>> computeCandidates(List<List<int>> puzzle, List<List<int>> solution) {
    List<List<Set<int>>> candidates = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (puzzle[row][col] == 0) {
          candidates[row][col] = _getCandidates(puzzle, row, col);
        } else {
          candidates[row][col] = {puzzle[row][col]}; // Fixed numbers are their own candidates
        }
      }
    }
    return candidates;
  }

  // Helper method to get candidates for a specific cell
  static Set<int> _getCandidates(List<List<int>> puzzle, int row, int col) {
    Set<int> candidates = Set.from(List.generate(9, (index) => index + 1));
    // Remove candidates based on row
    for (int x = 0; x < 9; x++) {
      if (puzzle[row][x] != 0) {
        candidates.remove(puzzle[row][x]);
      }
    }
    // Remove candidates based on column
    for (int x = 0; x < 9; x++) {
      if (puzzle[x][col] != 0) {
        candidates.remove(puzzle[x][col]);
      }
    }
    // Remove candidates based on 3x3 box
    int startRow = row - row % 3;
    int startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (puzzle[i + startRow][j + startCol] != 0) {
          candidates.remove(puzzle[i + startRow][j + startCol]);
        }
      }
    }
    return candidates;
  }

  static String getDifficultyName(SudokuDifficulty difficulty) {
    switch (difficulty) {
      case SudokuDifficulty.beginner:
        return 'Beginner';
      case SudokuDifficulty.easy:
        return 'Easy';
      case SudokuDifficulty.medium:
        return 'Medium';
      case SudokuDifficulty.hard:
        return 'Hard';
      case SudokuDifficulty.expert:
        return 'Expert';
      case SudokuDifficulty.impossible:
        return 'Impossible';
    }
  }

  static SudokuDifficulty getDifficulty(String name) {
    switch (name.toLowerCase()) {
      case 'beginner':
        return SudokuDifficulty.beginner;
      case 'easy':
        return SudokuDifficulty.easy;
      case 'medium':
        return SudokuDifficulty.medium;
      case 'hard':
        return SudokuDifficulty.hard;
      case 'expert':
        return SudokuDifficulty.expert;
      case 'impossible':
        return SudokuDifficulty.impossible;
      default:
        return SudokuDifficulty.easy; // Default to easy if unrecognized
    }
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
  void _removeCells(SudokuDifficulty difficulty, GenerationMode mode) {
    int cellsToRemove;
    switch (difficulty) {
      case SudokuDifficulty.beginner:
        cellsToRemove = 20;
      case SudokuDifficulty.easy:
        cellsToRemove = 30;
      case SudokuDifficulty.medium:
        cellsToRemove = 40;
      case SudokuDifficulty.hard:
        cellsToRemove = 50;
      case SudokuDifficulty.expert:
        cellsToRemove = 60;
      case SudokuDifficulty.impossible:
        cellsToRemove = 70;
    }

    // Remove cells based on the mode
    switch (mode) {
      case GenerationMode.symmetric:
        _removeSymmetrically(cellsToRemove);
      case GenerationMode.random:
        _removeRandomly(cellsToRemove);
    }
  }

  void _removeRandomly(int cellsToRemove) {
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

  void _removeSymmetrically(int cellsToRemove) {
    int removedCount = 0;
    while (removedCount < cellsToRemove) {
      int row = _random.nextInt(9);
      int col = _random.nextInt(9);

      // Ensure symmetric removal
      if (_board[row][col] != 0 && _board[8 - row][8 - col] != 0) {
        _board[row][col] = 0;
        _board[8 - row][8 - col] = 0;
        _isEditable[row][col] = true; // Mark as non-editable
        _isEditable[8 - row][8 - col] = true; // Mark symmetric cell as non-editable
        removedCount += 2; // Two cells removed
      }
    }
  }
}

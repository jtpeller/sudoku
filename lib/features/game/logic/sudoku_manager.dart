import 'dart:math';

import 'package:sudoku/core/storage/game_storage.dart';
import 'package:sudoku/features/game/logic/generator.dart';
import 'package:sudoku/features/game/logic/difficulty.dart';
import 'package:sudoku/features/stats/logic/stats.dart';
import 'package:sudoku/core/models/sudoku_grid.dart';

/// Responsible for managing the Sudoku Grid, game metrics, etc.
///
/// It is able to do the following:
///   - Generate a Sudoku Puzzle
///   - Manage that puzzles state, including get/set cells
///   - Create and track metrics about the game, like hints used.
///   - Provide any relevant metrics for the caller.
class SudokuManager {
  /// Size of the target grid
  int _gridSize = 81;

  /// A collection of quips and tips for the loading screen.
  static const List<String> loadingTips = [
    'Scanning rows, columns, and boxes is the bread and butter of Sudoku.',
    'Stuck? Try using Candidate Mode to track possibilities in each cell.',
    "The 'X-Wing' strategy can eliminate candidates across two rows and columns.",
    'Every valid Sudoku puzzle has exactly one unique solution.',
    "Focus on a single number to quickly see where it's missing in other boxes.",
    'Patience and logic are your best friends in Expert mode.',
    'Generating a high-quality puzzle involves complex backtracking math! Sit back and relax!',
    "A 'Naked Single' is a cell where only one number can possibly fit.",
    "'Hidden Singles' are numbers that only fit in one specific cell within a unit.",
    "I promise, you'll be solving soon!",
  ];

  /// Length of a single side; the square root of the grid size!
  double get length => sqrt(_gridSize);

  /// Difficulty of this particular game.
  late String _difficulty = 'medium';

  /// The maximum number of mistakes allowed before Game Over.
  final int maxMistakes = 3;

  /// The allotted number of hints allowed in a single game.
  final int maxHints = 3;

  /// Whether the game is over due to too many mistakes.
  bool get isGameOver => _mistakes >= maxMistakes;

  /// Number of hints used.
  int _hintsUsed = 0;

  /// Number of mistakes made.
  int _mistakes = 0;

  /// Elapsed time (as a ratio of the timer's duration).
  double _elapsedTime = 0.0;

  /// Whether auto-candidate mode was used at any point during the game.
  bool _usedAutoCandidate = false;

  /// Current progress of the puzzle generation (0.0 to 1.0).
  double _generationProgress = 0.0;

  /// The [SudokuGrid] object.
  late SudokuGrid _grid = SudokuGrid.empty(gridLength: 9);

  /// User statistics.
  late SudokuStats _stats = SudokuStats();

  /// Retrieves the underlying [SudokuGrid].
  SudokuGrid get grid => _grid;

  /// The size of the Sudoku Grid.
  int get gridSize => _gridSize;

  /// The maximum number for the Sudoku Puzzle
  int get maxNumber => _grid.gridLength;

  /// The number of rows in a box.
  int get boxRows => _grid.boxRows;

  /// The number of columns in a box.
  int get boxCols => _grid.boxCols;

  /// The difficulty of this game.
  String get difficulty => _difficulty;

  /// The number of hints used.
  int get hintsUsed => _hintsUsed;

  /// The number of mistakes made.
  int get mistakes => _mistakes;

  /// Whether auto-candidate mode was used.
  bool get usedAutoCandidate => _usedAutoCandidate;

  /// The elapsed time.
  double get elapsedTime => _elapsedTime;

  /// Retrieves the generation progress.
  double get generationProgress => _generationProgress;

  // Constructor does nothing!
  SudokuManager();

  // /////////////////////////////////////////////////////////////
  //    Load / Generate Game
  // /////////////////////////////////////////////////////////////

  /// Checks if there's a game to load.
  ///
  /// If it can be loaded, it will load it and return true.
  /// Otherwise, the caller must call [generateGame()].
  Future<bool> loadGame({String slot = 'auto'}) async {
    try {
      final Map<String, dynamic>? savedGame = await GameStorage.loadSave(slot: slot);
      if (savedGame != null) {
        // Game is saved. Load it properly
        _loadGame(savedGame);
        return true;
      }
    } catch (e) {
      // If loading fails due to corruption or schema changes, clear the bad data.
      await GameStorage.clear(slot: slot);
    }
    return false;
  }

  /// Loads the stats from storage
  Future<void> loadStats() async {
    _stats = await GameStorage.loadStats();
  }

  /// Generates the game board from scratch.
  ///
  /// The size of a grid's box is controlled by [subRows] x [subCols].
  ///
  /// The [difficulty] influences the number of cells the user must fill in.
  ///
  /// The [mode] controls how the cells are laid out in a grid.
  Future<void> generateGame({
    GenerationMode mode = GenerationMode.symmetric,
    int? seed,
    void Function(double)? onProgress,
  }) async {
    _generationProgress = 0.0;
    // Create a brand new grid.
    _grid = await SudokuGrid.generateGameAsync(
      gridSize: _gridSize,
      difficulty: _difficulty,
      mode: mode,
      seed: seed,
      onProgress: (p) {
        _generationProgress = p;
        onProgress?.call(p);
      },
    );

    // Reset all stats
    _hintsUsed = 0;
    _mistakes = 0;
    _elapsedTime = 0.0;
    _usedAutoCandidate = false;
  }

  void _loadGame(Map<String, dynamic> loadedData) {
    // Loads the game provided the particular map data.
    _difficulty = loadedData['difficulty'] ?? 'medium';
    _gridSize = loadedData['gridSize'] ?? 81;
    _hintsUsed = loadedData['hintsUsed'] ?? 0;
    _mistakes = loadedData['mistakes'] ?? 0;
    _elapsedTime = (loadedData['elapsedTime'] ?? 0.0).toDouble();
    _usedAutoCandidate = loadedData['usedAutoCandidate'] ?? false;

    // Load the grid data into this object's grid.
    var gridData = loadedData['grid'];
    if (gridData != null) {
      _grid = SudokuGrid.fromJson(gridData);
      SudokuGenerator.computeCandidates(_grid);
    }
  }

  /// Saves the current game state to storage.
  Future<void> saveGame(double elapsedTime, {String slot = 'auto'}) async {
    _elapsedTime = elapsedTime;
    await GameStorage.save({
      'difficulty': _difficulty,
      'gridSize': _gridSize,
      'hintsUsed': _hintsUsed,
      'mistakes': _mistakes,
      'elapsedTime': _elapsedTime,
      'usedAutoCandidate': _usedAutoCandidate,
      'grid': _grid.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    }, slot: slot);
  }

  /// Records the outcome of the current game.
  Future<void> recordGameResult(bool won, double elapsedTime) async {
    _elapsedTime = elapsedTime;
    _stats.recordGameEnd(
      sideLength: length.toInt(),
      difficulty: _difficulty,
      won: won,
      mistakes: _mistakes,
      hints: _hintsUsed,
      time: _elapsedTime,
      usedAutoCandidate: _usedAutoCandidate,
    );
    await GameStorage.saveStats(_stats);
  }

  // /////////////////////////////////////////////////////////////
  //    Set / Reset.
  // /////////////////////////////////////////////////////////////

  /// Marks that auto-candidate mode was used during this game.
  void markAutoCandidateUsed() {
    _usedAutoCandidate = true;
  }

  /// Sets the cell at row x col as hinted, and increments the number
  /// of hints used.
  void hintUsed(int row, int col) {
    _grid.get(row, col).isHinted = true;
    _hintsUsed++;
  }

  /// Increments the number of mistakes made.
  void mistaken() {
    _mistakes++;
  }

  /// Sets the difficulty to [difficulty], if valid.
  ///
  /// If invalid, an [ArgumentError] will be thrown.
  void setDifficulty(String difficulty) {
    String lowerCase = difficulty.toLowerCase();
    final names = getDifficultyNames();
    if (names.contains(lowerCase)) {
      _difficulty = lowerCase;
      return;
    }
    throw ArgumentError.value(difficulty, 'Difficulty');
  }

  /// Sets the grid size to [newGridSize], if valid.
  ///
  /// If invalid (say, it is not a perfect square), an [ArgumentError] will be thrown.
  void setGridSize(int newGridSize) {
    bool isPerfectSquare(int number) {
      if (number < 0) return false;
      int t = (sqrt(number) + 0.5).floor();
      return (t * t) == number;
    }

    if (!isPerfectSquare(newGridSize)) {
      throw ArgumentError.value(newGridSize, 'Grid Size');
    }

    _gridSize = newGridSize;
  }

  /// Sets the grid size via the provided [sideLength], if valid.
  ///
  /// If invalid (say, it is negative), an [ArgumentError] will be thrown.
  void setGridSizeFromSideLength(int sideLength) {
    if (sideLength <= 3) {
      throw ArgumentError.value(sideLength, 'Side Length');
    }
    setGridSize(pow(sideLength, 2).toInt());
  }

  // /////////////////////////////////////////////////////////////
  //   PUZZLE GRID MANAGEMENT
  // /////////////////////////////////////////////////////////////

  /// Retrieves the list of all difficulties supported.
  static List<String> getDifficultyNames() {
    return SudokuDifficulty.getDifficultyNames();
  }

  /// Checks whether the puzzle is in its "solved" state.
  ///
  /// Each cell must be correct for this to return true.
  bool isPuzzleSolved() {
    for (var cell in _grid) {
      if (!cell.isCorrect) {
        return false;
      }
    }
    return true;
  }

  /// Returns whether the provided [value] is full.
  ///
  /// For a number to be full, all entries are present in the board,
  /// but this does not require all values to be *correct*, or even
  /// *valid* (e.g., a single subgrid could be all 1s, and that
  /// would still count!)
  bool isFull(int value) {
    return _grid.isFull(value);
  }

  /// Returns the number of cells remaining that need to be filled
  /// in with [value].
  int getRemainingOf(int value) {
    return _grid.getRemainingOf(value);
  }

  /// Returns whether the underlying grid contains any values.
  bool get isNotEmpty => _grid.isNotEmpty;

  /// Sets the given cell as its solution.
  int setAsSolved(int row, int col) {
    int solution = _grid.get(row, col).solution;
    if (_grid.updateCellValue(row, col, solution)) {
      SudokuGenerator.computeCandidates(_grid);
    }
    return solution;
  }

  /// Retrieves the scope of cells that correspond to the selected cell.
  List<(int, int)> getScope(int row, int col) {
    return _grid.getScope(row, col);
  }

  /// Retrieves the box number of the provided cell.
  int getBoxNumber(int row, int col) {
    return _grid.getBoxIndex(row, col);
  }

  // /////////////////////////////////////////////////////////////
  //   CELL MANAGEMENT
  // /////////////////////////////////////////////////////////////

  /// Retrieves the cell value for the given [row] x [col].
  int? getValue(int row, int col) => _grid.get(row, col).value;

  /// Retrieves the user's candidate for the cell at [row] x [col].
  Set<int> getUserCandidates(int row, int col) => _grid.get(row, col).userCandidates;

  /// Retrieves the computer's candidate for the cell at [row] x [col].
  Set<int> getRealCandidates(int row, int col) => _grid.get(row, col).realCandidates;

  /// Retrieves the cell's hinted-ness for the given [row] x [col].
  bool isHinted(int row, int col) => _grid.get(row, col).isHinted;

  /// Retrieves the cell's correctness for the given [row] x [col].
  bool isCorrect(int row, int col) => _grid.get(row, col).isCorrect;

  /// Retrieves the cell's editability for the given [row] x [col].
  bool isEditable(int row, int col) {
    return _grid.get(row, col).isEditable;
  }

  /// Sets the value of the cell at [row] x [col] to [value].
  bool setValueAt(int row, int col, int? newValue) {
    bool updated = _grid.updateCellValue(row, col, newValue);
    if (updated) SudokuGenerator.computeCandidates(_grid);
    return updated;
  }

  /// Sets all cells as editable or uneditable.
  ///
  /// This is useful for when the UI wants to lock the user from
  /// editing (such as after winning).
  void setAllEditable({bool isEditable = false}) {
    for (var cell in _grid) {
      cell.isEditable = isEditable;
    }
  }

  /// For the cell at [row] x [col], toggles the candidate [value].
  ///
  /// If the [value] already exists in the candidates, it is removed.
  /// Otherwise, it is added to the set.
  ///
  /// A return value of false indicates removal, true indicates the
  /// value was added.
  bool toggleUserCandidate(int row, int col, int value) {
    var cell = _grid.get(row, col);
    var candidates = cell.userCandidates;

    // Remove the value if it already exists in the candidates.
    if (candidates.contains(value)) {
      cell.userCandidates.remove(value);
      return false;
    }

    // Add the value!
    cell.userCandidates.add(value);
    return true;
  }

  /// Clears the user's candidates in the cell at [row] x [col].
  bool clearUserCandidates(int row, int col) {
    return _grid.clearUserCandidates(row, col);
  }

  /// Removes [value] from the user candidates of all neighboring cells in
  /// the row, column, and box of [row] x [col].
  void removeUserCandidateFromNeighbors(int row, int col, int value) {
    final neighbors = getScope(row, col);
    for (var pos in neighbors) {
      _grid.get(pos.$1, pos.$2).userCandidates.remove(value);
    }
  }

  /// Resets the puzzle back to the original, fresh state.
  void reset() {
    _grid.resetToBeginning();
  }

  /// Clears the current board AND resets all metrics.
  void clear() {
    // First reset.
    reset();

    // Then reset all metrics.
    _hintsUsed = 0;
    _mistakes = 0;
    _elapsedTime = 0.0;
    _usedAutoCandidate = false;
  }
}

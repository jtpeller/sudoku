import 'package:sudoku/core/extensions/string_extensions.dart';

enum Difficulty {
  beginner(1), // Naked Singles
  easy(2),     // Hidden Singles
  medium(3),   // Pointing Pairs/Triples
  hard(4),     // X-Wings
  expert(5);   // Requires Backtracking/Guessing

  final int logicLevel;
  const Difficulty(this.logicLevel);
}

/// Manages the difficulty for the Sudoku Game.
class SudokuDifficulty {
  /// Map between the difficulties and the number of cells to remove.
  final Map<String, int> difficulties = {};

  /// The current difficulty enum value.
  late Difficulty currentDifficulty;

  /// The name of the current difficulty.
  String get name => currentDifficulty.name;

  /// Builds a difficulty object based on the provided string.
  SudokuDifficulty(int gridSize, {String? difficulty}) {
    // Validate that difficulty is OK.
    if (difficulty == null || !getDifficultyNames().contains(difficulty)) {
      throw ArgumentError.value(difficulty, 'Sudoku Difficulty');
    }

    // Define the difficulties list that can be used for cells-to-remove.
    for (var diff in Difficulty.values) {
      difficulties[diff.name] = ((diff.index + 2) * gridSize) ~/ 8;
    }

    // Set the current difficulty
    currentDifficulty = getDifficulty(difficulty);
  }

  /// Returns the number of cells to remove based on the current [Difficulty].
  int cellsToRemove() {
    return difficulties[currentDifficulty.name]!;
  }

  /// Retrieves all [Difficulty] values.
  static List<Difficulty> getDifficulties() {
    return Difficulty.values;
  }

  /// Retrieves all difficulty indexes.
  static List<int> getDifficultyValues() {
    return Difficulty.values.map((diff) => diff.index).toList();
  }

  /// Retrieves the names of the difficulties.
  /// 
  /// You may optionally [capitalize] them.
  static List<String> getDifficultyNames({bool capitalize = false}) {
    return Difficulty.values
        .map((diff) => capitalize ? diff.name.capitalize() : diff.name)
        .toList();
  }

  /// Converts from a difficulty name to the corresponding [Difficulty].
  static Difficulty getDifficulty(String name) {
    return Difficulty.values.byName(name);
  }

  /// Converts from a [Difficulty] to a difficulty's name.
  static String getDifficultyName(Difficulty diff, {bool capitalize = false}) {
    return capitalize ? diff.name.capitalize() : diff.name;
  }
}

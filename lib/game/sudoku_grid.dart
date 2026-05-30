import 'dart:math';

import 'package:sudoku/data/grid.dart';
import 'package:sudoku/game/generator.dart';

/// Defines a single cell in a sudoku grid.
///
/// The cell contains its current value, solution,
/// whether the cell is editable, is hinted, and
/// user / real candidates.
class SudokuCell {
  /// The correct value for this cell.
  int solution;

  /// User's current input.
  int? value;

  /// Whether this cell can be edited by the user.
  bool isEditable;

  /// Whether this cell was revealed via a hint.
  bool isHinted;

  /// User-entered candidates for this cell.
  Set<int> userCandidates = {};

  /// Real, valid candidates for this cell.
  Set<int> realCandidates = {};

  SudokuCell({required this.solution, this.value, this.isEditable = false, this.isHinted = false});

  /// Whether this cell has the correct value.
  bool get isCorrect => value == solution;

  /// Whether this cell has a value.
  bool get isEmpty => value == null;

  /// Performs a deep copy of [source].
  factory SudokuCell.copyFrom(SudokuCell source) {
    SudokuCell newCell = SudokuCell(
      value: source.value,
      solution: source.solution,
      isHinted: source.isHinted,
      isEditable: source.isEditable,
    );
    newCell.userCandidates = {...source.userCandidates};
    newCell.realCandidates = {...source.realCandidates};
    return newCell;
  }

  /// Defines a new [SudokuCell] from the provided map [data].
  factory SudokuCell.fromMap(Map<String, dynamic> source) {
    SudokuCell newCell = SudokuCell(
      value: source['value'],
      solution: source['solution'] ?? 0,
      isHinted: source['isHinted'] ?? false,
      isEditable: source['isEditable'] ?? false,
    );
    newCell.userCandidates =
        source['userCandidates'] != null ? Set<int>.from(source['userCandidates']) : <int>{};
    newCell.realCandidates =
        source['realCandidates'] != null ? Set<int>.from(source['realCandidates']) : <int>{};
    return newCell;
  }

  /// Converts this [SudokuCell] into a map for JSON serialization.
  Map<String, dynamic> toJson() => {
    'solution': solution,
    'value': value,
    'isEditable': isEditable,
    'isHinted': isHinted,
    'userCandidates': userCandidates.toList(),
    'realCandidates': realCandidates.toList(),
  };

  /// Resets a cell's value to null if it is editable and not hinted!
  void reset() {
    if (isEditable && !isHinted) {
      value = null;
    }
  }

  /// Returns a cell to its default values.
  void clear() {
    value = null;
    solution = 0;
    isHinted = false;
  }

  @override
  String toString() {
    return 'SudokuCell(val=$value, sol=$solution, edit=$isEditable, hint=$isHinted)';
  }
}

/// Implements the grid for this class.
class SudokuGrid extends Grid<SudokuCell> {
  late final int boxRows;
  late final int boxCols;
  final int gridLength;

  /// Whether this grid is being populated or not.
  bool _isGenerating = false;

  /// Counts of the occurrence of each cell in the grid.
  late final Map<int, int> _valueCounts;

  /// Stores how many conflicts are currently hitting a particular cell.
  /// This is indexed by row * col; in other words, this is a flattened grid.
  late final List<int> _conflictCounts;

  SudokuGrid._internal({required this.gridLength, required List<SudokuCell> cells})
    : super.fromList(rows: gridLength, columns: gridLength, data: cells) {
    // Initialize the box dimensions
    var tuple = SudokuGrid.dimsFromLength(gridLength);
    boxRows = tuple.$1;
    boxCols = tuple.$2;

    // Initialize the value counts.
    _initializeCounts(cells);

    // Initialize the conflict counts
    _conflictCounts = List.filled(gridLength * gridLength, 0);
    _initialFullScan();
  }

  /// Creates an empty Sudoku Grid.
  ///
  /// All solution values are set to 0, all cell values set to [null],
  /// and editable / hinted are left at default (true / false, respectively).
  factory SudokuGrid.empty({required int gridLength}) {
    // Generate empty list of cells.
    List<SudokuCell> cells = List.generate(gridLength * gridLength, (i) {
      return SudokuCell(solution: 0, value: null);
    });
    return SudokuGrid._internal(gridLength: gridLength, cells: cells);
  }

  /// Factory to handle the complex generation logic
  factory SudokuGrid.generateGame({
    required int gridSize,
    String difficulty = 'medium',
    GenerationMode mode = GenerationMode.symmetric,
    int? seed,
  }) {
    // Create an empty grid to be populated.
    SudokuGrid emptyGrid = SudokuGrid.empty(gridLength: SudokuGrid.lengthFromGridSize(gridSize));
    emptyGrid.setGenerating(true);

    // Generate the puzzle in this grid.
    SudokuGenerator.generate(emptyGrid, difficulty: difficulty, mode: mode, seed: seed);

    // Return this grid.
    emptyGrid.setGenerating(false);
    return emptyGrid;
  }

  /// Defines a new [SudokuGrid] from the provided [source] data.
  factory SudokuGrid.fromJson(List<dynamic> source) {
    // Loop through the data.
    List<SudokuCell> cells = [];
    for (var mapData in source) {
      // Create a SudokuCell from this data.
      cells.add(SudokuCell.fromMap(Map<String, dynamic>.from(mapData)));
    }
    return SudokuGrid.fromList(cells);
  }

  /// Defines a new [SudokuGrid] from a list of [SudokuCell] objects.
  factory SudokuGrid.fromList(List<SudokuCell> source) {
    return SudokuGrid._internal(
      gridLength: SudokuGrid.lengthFromGridSize(source.length),
      cells: source,
    );
  }

  /// Calculates the best subgrid layout for a given side length, [n].
  ///
  /// Avoid providing primes, because this will simply return 1 x n.
  ///
  /// Returns the row and column (in that order) for a given sub-grid
  /// (that is, the Sudoku box).
  static (int, int) dimsFromLength(int side) {
    int boxRows = sqrt(side).floor();
    while (side % boxRows != 0) {
      boxRows--;
    }
    int boxCols = side ~/ boxRows;
    return (boxRows, boxCols);
  }

  static (int, int) dimsFromGridSize(int n) {
    final int side = SudokuGrid.lengthFromGridSize(n);
    return dimsFromLength(side);
  }

  static int lengthFromGridSize(int n) {
    return sqrt(n).toInt();
  }

  /// Converts the entire grid into a list of maps for JSON serialization.
  List<Map<String, dynamic>> toJson() {
    return data.map((cell) => cell.toJson()).toList();
  }

  @override
  bool get isEmpty => every((cell) => cell.isEmpty);

  @override
  bool get isNotEmpty => any((cell) => !cell.isEmpty);

  // /////////////////////////////////////////////////////////////
  //   SETTERS
  // /////////////////////////////////////////////////////////////

  /// Updates the editability of the cell at [row] x [col].
  void setEditable(int row, int col, bool newValue) {
    var cell = get(row, col);
    cell.isEditable = newValue;
    set(row, col, cell);
  }

  /// Sets the grid to generating mode, which allows non-editable
  /// cells to be editable.
  void setGenerating(bool newValue) {
    _isGenerating = newValue;
  }

  /// Updates the real (computed) candidates of the cell at [row] x [col].
  void setComputedCandidates(int row, int col, Set<int> newCandidates) {
    var cell = get(row, col);
    cell.realCandidates = newCandidates;
    set(row, col, cell);
  }

  /// Sets the cell's value at [row] x [col].
  void setValue(int row, int col, int? newValue) {
    var cell = get(row, col);
    cell.value = newValue;
    set(row, col, cell);
  }

  /// Sets the cell's solution at [row] x [col].
  void setSolution(int row, int col, int newValue) {
    var cell = get(row, col);
    cell.solution = newValue;
    set(row, col, cell);
  }

  // /////////////////////////////////////////////////////////////
  //   NUMBER COUNT HANDLING
  // /////////////////////////////////////////////////////////////

  /// Populates the counts!
  void _initializeCounts(List<SudokuCell> cells) {
    // Initialize all possible numbers to 0
    _valueCounts = {for (var i = 1; i <= gridLength; i++) i: 0};

    for (var cell in cells) {
      if (cell.value != null) {
        _valueCounts[cell.value!] = (_valueCounts[cell.value!] ?? 0) + 1;
      }
    }
  }

  /// Updates the cell value for a particular cell (identified by [row]x[col]),
  /// then increments or decrements the old value count accordingly.
  bool updateCellValue(int row, int col, int? newValue) {
    var cell = get(row, col);
    final int? oldValue = cell.value;

    // If the cell is non-editable, do not update it.
    if (!cell.isEditable && !_isGenerating) {
      return false;
    }

    // If the new value is the same as the old, do nothing.
    if (oldValue == newValue) {
      return false;
    }

    // Decrement old value, if it was set to something.
    // If the old value wasn't null, undo this in the metrics.
    if (oldValue != null) {
      // Decrement the old value.
      _valueCounts[oldValue] = (_valueCounts[oldValue]! - 1).clamp(0, gridLength);

      // Update the impact zone for this cell.
      _updateImpactZone(row, col, oldValue, -1);
    }

    // Update the cell
    setValue(row, col, newValue);

    // Increment new value count
    if (newValue != null && newValue != 0) {
      // Increment this new value.
      _valueCounts[newValue] = (_valueCounts[newValue]! + 1);

      // Apply the influence of this new value.
      _updateImpactZone(row, col, newValue, 1);
    }
    return true;
  }

  /// Retrieves the count of occurrences of the provided [value] in the grid.
  int getCountOf(int value) => _valueCounts[value] ?? 0;

  /// Returns whether the provided value is full.
  bool isFull(int value) => (_valueCounts[value] ?? 0) >= gridLength;

  /// Retrieves the number of occurrences remaining to be filled in for the
  /// provided [value] in the grid.
  int getRemainingOf(int value) => (gridLength - (_valueCounts[value] ?? 0)).clamp(0, gridLength);

  // /////////////////////////////////////////////////////////////
  //   CONFLICT HANDLING
  // /////////////////////////////////////////////////////////////

  void _initialFullScan() {
    // Reset the counts to all zeros
    _conflictCounts.fillRange(0, _conflictCounts.length, 0);

    // Iterate through every cell in the grid
    for (int r = 0; r < gridLength; r++) {
      for (int c = 0; c < gridLength; c++) {
        final cell = get(r, c);

        // Only process cells that have a value
        if (cell.value != null) {
          final val = cell.value!;

          // Only check "forward" or "neighbors" to avoid double-counting
          // during the initial scan.
          _applyInitialConflicts(r, c, val);
        }
      }
    }
  }

  /// A specialized version of impact zone logic for the initial boot
  void _applyInitialConflicts(int row, int col, int value) {
    final neighbors = _getNeighbors(row, col);

    for (var pos in neighbors) {
      final neighborCell = get(pos.row, pos.col);

      // If a neighbor has the same value, they are in conflict.
      if (neighborCell.value == value) {
        // We increment the count for the current cell.
        // Note: The neighbor's count will be incremented when the loop
        // reaches that neighbor's coordinate, ensuring everyone is accounted for.
        _conflictCounts[row * gridLength + col]++;
      }
    }
  }

  /// [delta] is +1 when adding a value, -1 when removing/changing it
  void _updateImpactZone(int row, int col, int value, int delta) {
    // A cell's "Impact Zone" is its own Row, Column, and Box
    final neighbors = _getNeighbors(row, col);

    for (var pos in neighbors) {
      final neighborCell = get(pos.row, pos.col);

      // If the neighbor has the same value, they are in conflict
      if (neighborCell.value == value) {
        // Increment/Decrement the conflict counter for BOTH cells
        _changeConflict(row, col, delta);
        _changeConflict(pos.row, pos.col, delta);
      }
    }
  }

  void _changeConflict(int r, int c, int delta) {
    _conflictCounts[r * gridLength + c] += delta;
  }

  // /////////////////////////////////////////////////////////////
  //   GRID TRAVERSAL
  // /////////////////////////////////////////////////////////////

  /// Retrieves the neighbors for a given cell at [row]x[col].
  List<({int row, int col})> _getNeighbors(int row, int col) {
    final Set<({int row, int col})> positions = {};

    // Row and Column neighbors
    for (int i = 0; i < gridLength; i++) {
      if (i != col) positions.add((row: row, col: i));
      if (i != row) positions.add((row: i, col: col));
    }

    // Box neighbors
    final int boxStartRow = (row ~/ boxRows) * boxRows;
    final int boxStartCol = (col ~/ boxCols) * boxCols;
    for (int r = boxStartRow; r < boxStartRow + boxRows; r++) {
      for (int c = boxStartCol; c < boxStartCol + boxCols; c++) {
        if (r != row || c != col) {
          positions.add((row: r, col: c));
        }
      }
    }
    return positions.toList();
  }

  // Helper to find the box index for UI styling (thick borders)
  int getBoxIndex(int row, int col) {
    return (row ~/ boxRows) * boxRows + (col ~/ boxCols);
  }

  /// Returns a list of (row, col) coordinates that conflict with the cell at [row, col]
  List<(int, int)> getConflicts(int row, int col) {
    final List<(int, int)> conflicts = [];
    final cell = get(row, col);
    if (cell.value == null) return conflicts;

    final val = cell.value;

    // Check Row and Column
    for (int i = 0; i < gridLength; i++) {
      // Check Column (same row, different col)
      if (i != col && get(row, i).value == val) {
        conflicts.add((row, i));
      }
      // Check Row (different row, same col)
      if (i != row && get(i, col).value == val) {
        conflicts.add((i, col));
      }
    }

    // Check Subgrid (Box)
    final int boxStartRow = (row ~/ boxRows) * boxRows;
    final int boxStartCol = (col ~/ boxCols) * boxCols;

    for (int r = boxStartRow; r < boxStartRow + boxRows; r++) {
      for (int c = boxStartCol; c < boxStartCol + boxCols; c++) {
        if (r == row && c == col) continue; // Skip self
        if (get(r, c).value == val) {
          conflicts.add((r, c));
        }
      }
    }

    return conflicts;
  }

  // /////////////////////////////////////////////////////////////
  //   RESET AND CLEAR
  // /////////////////////////////////////////////////////////////

  /// Returns the game to its original, unsolved state.
  /// Hints are still left as-is!
  void resetToBeginning() {
    for (var cell in data) {
      if (cell.isEditable && !cell.isHinted) {
        cell.value = null;
      }
    }
  }

  /// Clears the board entirely
  void clear() {
    for (var cell in data) {
      cell.clear();
    }
  }

  /// Clears the user candidates. Returns true if there were candidates,
  /// and the clear was then successful.
  bool clearUserCandidates(int row, int col) {
    var cell = get(row, col);
    if (cell.userCandidates.isNotEmpty) {
      cell.userCandidates.clear();
      set(row, col, cell);
      return true;
    }
    return false;
  }

  // /////////////////////////////////////////////////////////////
  //   UI HELPERS
  // /////////////////////////////////////////////////////////////

  /// Returns all cells in a specific box (indexed 0 to N-1)
  Iterable<SudokuCell> getBox(int boxIndex) {
    final List<SudokuCell> boxCells = [];
    final int boxStartRow = (boxIndex ~/ boxRows) * boxRows;
    final int boxStartCol = (boxIndex % boxRows) * boxCols;

    for (int r = boxStartRow; r < boxStartRow + boxRows; r++) {
      for (int c = boxStartCol; c < boxStartCol + boxCols; c++) {
        boxCells.add(get(r, c));
      }
    }
    return boxCells;
  }

  /// Returns all coordinates that should be highlighted because they
  /// share a row, column, or box with the selected cell.
  List<(int, int)> getScope(int row, int col) {
    return _getNeighbors(row, col).map((e) => (e.row, e.col)).toList();
  }
}

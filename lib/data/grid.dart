import 'dart:collection';

/// A fixed-size 2-dimensional data structure.
///
/// A [Grid] ensures that all rows are the same length, and
/// that all columns are the same length.
///
/// The grid is initialized to the provided default value.
///
/// The default value being provided as a function can ensure
/// no reference bugs (like all cells referring to the same object!)
class Grid<E> extends IterableMixin<E> {
  final int rows;
  final int columns;
  final List<E> data;

  int get gridSize => rows * columns;

  // /////////////////////////////////////////////////////////////
  //   CONSTRUCTION
  // /////////////////////////////////////////////////////////////

  /// Initializes each cell by calling a factory function [generator].
  Grid.generate({required this.rows, required this.columns, required E Function() generator})
    : data = List<E>.generate(rows * columns, (_) => generator());

  /// Copies all values from [source] into this grid.
  ///
  /// An [ArgumentError] will be thrown if the [source] grid does
  /// not have the same dimensions.
  void copyFrom(Grid<E> source) {
    if (source.rows != rows || source.columns != columns) {
      throw ArgumentError('Source grid dimensions must match target grid.');
    }
    data.setAll(0, source.data);
  }

  // The missing fromList constructor
  Grid.fromList({required this.rows, required this.columns, required List<E> data})
    : assert(data.length == rows * columns, 'Data length must match dimensions'),
      data = List<E>.from(data);

  /// Creates a deep copy of the grid.
  /// The [elementCloner] function defines how to copy each individual element.
  Grid<E> clone(E Function(E element) elementCloner) {
    // Create a new grid using the factory constructor logic
    // Use a dummy value for initialization that will be overwritten.
    var newGrid = Grid.generate(rows: rows, columns: columns, generator: () => get(0, 0));

    // Populate the new grid by cloning each element from the current grid
    for (int i = 0; i < data.length; i++) {
      newGrid.data[i] = elementCloner(data[i]);
    }

    return newGrid;
  }

  // /////////////////////////////////////////////////////////////
  //   GETTERS AND SETTERS
  // /////////////////////////////////////////////////////////////

  /// Accesses the element at the specified [row] and [col].
  E get(int row, int col) {
    _checkBounds(row, col);
    return data[row * columns + col];
  }

  /// Sets the element at the specified [row] and [col].
  void set(int row, int col, E value) {
    _checkBounds(row, col);
    data[row * columns + col] = value;
  }

  /// Ensures indices are within the established [rows] and [columns].
  void _checkBounds(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= columns) {
      throw RangeError('Index out of bounds: ($row, $col)');
    }
  }

  // /////////////////////////////////////////////////////////////
  //   ITERATION
  // /////////////////////////////////////////////////////////////

  /// Implements [Iterable] by returning an iterator over the flattened data
  /// This allows top-left to bottom-right iteration.
  @override
  Iterator<E> get iterator => data.iterator;

  /// Returns a specific row as an [Iterable] for validation logic.
  Iterable<E> getRow(int row) {
    return data.skip(row * columns).take(columns);
  }

  /// Returns a specific column as an [Iterable] using a generator.
  Iterable<E> getColumn(int col) sync* {
    for (int r = 0; r < rows; r++) {
      yield get(r, col);
    }
  }

  // /////////////////////////////////////////////////////////////
  //   CONVERSION AND SERIALIZATION
  // /////////////////////////////////////////////////////////////

  /// Converts the grid into a nested List for JSON serialization.
  /// Useful for saving state.
  List<List<E>> toNestedList() {
    return List.generate(rows, (r) => getRow(r).toList());
  }
}

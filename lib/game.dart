import 'package:flutter/material.dart';

import 'styles.dart';
import 'widgets.dart' as widgets;
import 'sudoku_generator.dart'; // Import the new generator
import 'options.dart';

/// A [StatefulWidget] that represents the main game page for Sudoku.
///
/// Displays the Sudoku board and handles game logic based on the selected [difficulty].
///
/// The [difficulty] parameter determines the complexity of the generated puzzle.
class GamePage extends StatefulWidget {
  final String difficulty;

  const GamePage({super.key, required this.difficulty});

  @override
  State<GamePage> createState() => _GamePageState();
}

/// The state class for the [GamePage] widget.
///
/// Manages the game logic, UI updates, and user interactions for the Sudoku game page.
class _GamePageState extends State<GamePage> {
  late String _difficulty;
  // Initialize with empty boards to prevent LateInitializationError
  List<List<int>> _puzzleBoard = List.generate(9, (_) => List.filled(9, 0));
  List<List<dynamic>> _solutionBoard = List.generate(9, (_) => List.filled(9, 0));
  List<List<bool>> _isEditable = List.generate(9, (_) => List.filled(9, false));
  List<List<bool>> _isHinted = List.generate(9, (_) => List.filled(9, false));

  int? _selectedRow; // Currently selected cell row
  int? _selectedCol; // Currently selected cell column
  int _hintsUsed = 0; // Counter for hints used
  int _mistakes = 0; // Counter for mistakes made

  @override
  void initState() {
    super.initState();
    _difficulty = widget.difficulty;
    _generateNewPuzzle(); // Generate the initial puzzle
  }

  /// Generates a new Sudoku puzzle based on the current difficulty level.
  ///
  /// This method uses the `SudokuGenerator` to create a new puzzle and its solution.
  /// It updates the puzzle board, solution board, and editable cells in the state.
  /// Also resets the currently selected row and column to null.
  void _generateNewPuzzle() {
    final generator = SudokuGenerator();
    final generatedData = generator.generateSudoku(_difficulty);

    setState(() {
      _puzzleBoard = generatedData['puzzle'];
      _solutionBoard = generatedData['solution'];
      _isEditable = generatedData['isEditable'];
      _isHinted = List.generate(9, (_) => List.filled(9, false)); // Reset hints
      _hintsUsed = 0; // Reset hints used counter
      _mistakes = 0; // Reset mistakes counter
      // Reset selection
      _selectedRow = null; // Reset selection
      _selectedCol = null; // Reset selection
    });
  }

  /// Handles the tap event on a Sudoku cell at the given [row] and [col].
  ///
  /// If the tapped cell is editable, it selects the cell by updating [_selectedRow] and [_selectedCol].
  /// If the cell is not editable (i.e., a fixed cell), it deselects any currently selected cell.
  ///
  /// Uses [setState] to trigger a UI update after selection or deselection.
  ///
  /// Parameters:
  /// - [row]: The row index of the tapped cell.
  /// - [col]: The column index of the tapped cell.
  /// If the cell is editable, it will be selected; otherwise, it will be deselected.
  void _onCellTap(int row, int col) {
    // check if this cell is editable.
    if (_isEditable[row][col]) {
      setState(() {
        _selectedRow = row;
        _selectedCol = col;
      });
    } else {
      // not editable (this is a fixed cell). Deselect.
      setState(() {
        _selectedRow = null;
        _selectedCol = null;
      });
    }
  }

  bool _checkPuzzleSolved() {
    // check if the puzzle is solved
    if (_puzzleBoard.every((row) => row.every((cell) => cell != 0))) {
      // Show a dialog or message indicating the game is solved
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Congratulations!'),
              content: const Text('You have solved the Sudoku puzzle!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    _generateNewPuzzle(); // Generate a new puzzle
                  },
                  child: const Text('New Game'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
      );
      return true; // Puzzle is solved
    }
    return false; // Puzzle is not solved
  }

  /// Handles the tap event on a number button in the Sudoku game.
  ///
  /// If a cell is selected and it is not editable (i.e., not a pre-filled cell),
  /// updates the puzzle board at the selected cell with the tapped number.
  ///
  /// Parameters:
  /// - [number]: The number tapped by the user to be placed in the selected cell.
  void _onNumberButtonTap(int number) {
    // first, save the current cell value
    int original = _puzzleBoard[_selectedRow!][_selectedCol!];

    if (_selectedRow != null && _selectedCol != null && _isEditable[_selectedRow!][_selectedCol!]) {
      setState(() {
        _puzzleBoard[_selectedRow!][_selectedCol!] = number;
      });

      // Check if the entered number matches the solution
      if (number != _solutionBoard[_selectedRow!][_selectedCol!] && number != original) {
        // Increment mistakes counter
        _mistakes += 1;

        // error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Incorrect number!')));
      }

      _checkPuzzleSolved();
    }
  }

  /// Returns the color for a Sudoku grid cell at the specified [row] and [col].
  ///
  /// If the cell is currently selected (matches [_selectedRow] and [_selectedCol]),
  /// it returns the accent color to highlight the cell. Otherwise, it alternates
  /// between two background colors for visual distinction of 3x3 subgrids.
  ///
  /// Parameters:
  /// - [row]: The row index of the cell.
  /// - [col]: The column index of the cell.
  /// - [context]: The build context used to retrieve theme colors.
  ///
  /// Returns a [Color] representing the cell's background.
  Color _getCellColor(int row, int col, BuildContext context) {
    // these first rules override the highlighted colors

    // if the cell's value is incorrect, use the Theme's wrong color
    if (_puzzleBoard[row][col] != _solutionBoard[row][col] && _puzzleBoard[row][col] != 0) {
      return ThemeColor.getWrongColor(context);
    }

    // if this was a hint cell, use the hint color
    if (_isHinted[row][col]) {
      return ThemeColor.getHintColor(context);
    }

    // if the cell's value is correct (and not fixed), use the Theme's correct color
    if (_puzzleBoard[row][col] == _solutionBoard[row][col] && _isEditable[row][col]) {
      return ThemeColor.getCorrectColor(context);
    }

    // if this is the selected cell, highlight it
    if (_selectedRow == row && _selectedCol == col) {
      return ThemeColor.getAccentColor(context); // Highlight selected cell
    }

    // if not, highlight cells in the same row, column, or 3x3 block as selected
    if (_selectedRow != null && _selectedCol != null) {
      // Highlight row / col
      if (row == _selectedRow || col == _selectedCol) {
        return ThemeColor.getBgColorHigh(context);
      }

      // Highlight the box
      int selectedBoxRow = _selectedRow! ~/ 3;
      int selectedBoxCol = _selectedCol! ~/ 3;
      int currentBoxRow = row ~/ 3;
      int currentBoxCol = col ~/ 3;
      if (selectedBoxRow == currentBoxRow && selectedBoxCol == currentBoxCol) {
        return ThemeColor.getBgColorHigh(context);
      }
    }

    // Alternate colors for the grid cells
    return ((row ~/ 3) + (col ~/ 3)) % 2 == 0
        ? ThemeColor.getBgColor(context)
        : ThemeColor.getBgColorLite(context);
  }

  /// Returns the color for a Sudoku cell's border or background based on its position and selection state.
  ///
  /// Parameters:
  /// - [row]: The row index of the cell.
  /// - [col]: The column index of the cell.
  /// - [context]: The build context for accessing theme colors (light/dark mode).
  /// - [getBorder]: If `true`, returns a border color; if `false`, returns a background color.
  ///
  /// Returns:
  /// - A [Color] representing either the border or background color for the cell.
  Color _getBorderColor(int row, int col, BuildContext context) {
    // these first rules override the highlighted colors

    // if the cell's value is correct (and not fixed)...
    if (_puzzleBoard[row][col] == _solutionBoard[row][col] && _isEditable[row][col]) {
      return ThemeColor.getBorderColor(context);
    }

    // if this is the selected cell, highlight it
    if (_selectedRow == row && _selectedCol == col) {
      return ThemeColor.getAccentColor(context); // Highlight selected cell
    }

    // Highlight cells in the same row, column, or 3x3 block as selected
    if (_selectedRow != null && _selectedCol != null) {
      // Highlight row / col
      if (row == _selectedRow || col == _selectedCol) {
        return ThemeColor.getHighlightedBorderColor(context);
      }

      // Highlight the box
      int selectedBoxRow = _selectedRow! ~/ 3;
      int selectedBoxCol = _selectedCol! ~/ 3;
      int currentBoxRow = row ~/ 3;
      int currentBoxCol = col ~/ 3;
      if (selectedBoxRow == currentBoxRow && selectedBoxCol == currentBoxCol) {
        return ThemeColor.getHighlightedBorderColor(context);
      }
    }
    return ThemeColor.getBorderColor(context);
  }

  @override
  /// Builds the main Sudoku game screen:
  /// - App bar with title
  /// - Game title and difficulty display
  /// - Game control buttons (hint, settings)
  /// - 9x9 Sudoku grid with selectable cells
  /// - Number input buttons for cell entry
  /// - Clear cell button (to clear the selected cell)
  /// - Responsive layout with scroll support
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('Sudoku', style: ThemeStyle.gameTitle(context)),
              Text('Difficulty: $_difficulty', style: ThemeStyle.subtitle(context)),
              Text(
                'Hints Used: $_hintsUsed | Mistakes: $_mistakes',
                style: ThemeStyle.smallGameText(context),
              ),
              widgets.verticalSpacer,
              // game buttons (hint, settings, etc.)
              OverflowBar(
                children: <Widget>[
                  // New Game button
                  Tooltip(
                    message: 'New Game',
                    textStyle: ThemeStyle.tooltip(context),
                    child: IconButton(
                      icon: Icon(Icons.refresh),
                      style: ThemeStyle.iconButtonThemeData(context).style,
                      onPressed: () {
                        // open a dialog to confirm new game
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('New Game'),
                                content: const Text('Are you sure you want to start a new game?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                      _generateNewPuzzle(); // Generate a new puzzle
                                    },
                                    child: const Text('Yes'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: const Text('No'),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  ),
                  // Help button
                  Tooltip(
                    message: 'Help',
                    textStyle: ThemeStyle.tooltip(context),
                    child: IconButton(
                      icon: Icon(Icons.help_outline),
                      style: ThemeStyle.iconButtonThemeData(context).style,
                      onPressed: () {
                        // open a modal to show help information
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Help'),
                                content: Text(
                                  'Tap on a cell to select it. Use the number buttons to fill in the selected cell.\n'
                                  'Use the Hint button to reveal the correct number for the selected cell.\n'
                                  'Use the Clear Cell button to remove the number from the selected cell.\n'
                                  'You can also start a new game at any time.',
                                  style: ThemeStyle.mediumGameText(context),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  ),
                  // Hint button
                  Tooltip(
                    message: 'Hint',
                    textStyle: ThemeStyle.tooltip(context),
                    child: IconButton(
                      icon: Icon(Icons.lightbulb),
                      style: ThemeStyle.iconButtonThemeData(context).style,
                      onPressed: () {
                        if (_selectedRow != null &&
                            _selectedCol != null &&
                            _isEditable[_selectedRow!][_selectedCol!] &&
                            !_isHinted[_selectedRow!][_selectedCol!]) {
                          setState(() {
                            _puzzleBoard[_selectedRow!][_selectedCol!] =
                                _solutionBoard[_selectedRow!][_selectedCol!];
                          });
                          _hintsUsed += 1; // Increment hints used counter
                          _isHinted[_selectedRow!][_selectedCol!] = true;
                          _checkPuzzleSolved();
                        }

                        // Show a message if no cell is selected
                        if (_selectedRow == null || _selectedCol == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Select a cell first!',
                                style: ThemeStyle.tooltip(context),
                              ),
                              duration: Duration(seconds: 2),
                              dismissDirection: DismissDirection.up,
                            ),
                          );
                        }
                        // Show a message if the cell is already hinted or correct
                        else if (_selectedRow != null &&
                            _selectedCol != null &&
                            (_isHinted[_selectedRow!][_selectedCol!] ||
                                _puzzleBoard[_selectedRow!][_selectedCol!] ==
                                    _solutionBoard[_selectedRow!][_selectedCol!])) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'This cell is already correct!',
                                style: ThemeStyle.tooltip(context),
                              ),
                              duration: Duration(seconds: 2),
                              dismissDirection: DismissDirection.up,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  // Settings button
                  Tooltip(
                    message: 'Options',
                    textStyle: ThemeStyle.tooltip(context),
                    child: IconButton(
                      icon: Icon(Icons.settings),
                      style: ThemeStyle.iconButtonThemeData(context).style,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OptionsPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              // Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final double gridSize =
                      (constraints.maxWidth < constraints.maxHeight
                          ? constraints.maxWidth
                          : constraints.maxHeight) -
                      50; // Padding to prevent overflow
                  final double containerSize = gridSize > 500 ? 500 : gridSize;

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 300.0, // Minimum grid size
                        minHeight: 300.0, // Minimum grid size
                        maxWidth: containerSize,
                        maxHeight: containerSize,
                      ),
                      child: GridView.builder(
                        // Use GridView.builder for more control
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 9, // 9 cells in the main grid
                          mainAxisSpacing: 1,
                          crossAxisSpacing: 1.0,
                        ),
                        itemCount: 81, // 9x9 grid
                        itemBuilder: (context, index) {
                          int row = index ~/ 9;
                          int col = index % 9;
                          String cellValue =
                              _puzzleBoard[row][col] == 0 ? '' : _puzzleBoard[row][col].toString();

                          return GestureDetector(
                            onTap: () => _onCellTap(row, col),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: _getBorderColor(row, col, context),
                                    width: ThemeStyle.gridNormalBorder,
                                  ),
                                  top: BorderSide(
                                    color: _getBorderColor(row, col, context),
                                    width: ThemeStyle.gridNormalBorder,
                                  ),
                                  right: BorderSide(
                                    color: _getBorderColor(row, col, context),
                                    width: ThemeStyle.gridNormalBorder,
                                  ),
                                  bottom: BorderSide(
                                    color: _getBorderColor(row, col, context),
                                    width: ThemeStyle.gridNormalBorder,
                                  ),
                                ),
                                color: _getCellColor(row, col, context),
                              ),
                              child: Center(
                                child: Text(
                                  cellValue,
                                  style:
                                      _isEditable[row][col]
                                          ? ThemeStyle.gridText(context)
                                          : ThemeStyle.fixedGridText(context),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              widgets.verticalSpacer,
              // Number input buttons
              OverflowBar(
                children: List.generate(
                  9,
                  // Spacing between buttons
                  (numIndex) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: OutlinedButton(
                      style: ThemeStyle.gridButtonThemeData(context).style,
                      onPressed: () => _onNumberButtonTap(numIndex + 1),
                      child: Center(
                        child: Text(
                          (numIndex + 1).toString(),
                          style: ThemeStyle.buttonText(context),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Clear button
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: OutlinedButton(
                  style: ThemeStyle.gameButtonThemeData(context).style,
                  onPressed: () {
                    if (_selectedRow != null &&
                        _selectedCol != null &&
                        _isEditable[_selectedRow!][_selectedCol!]) {
                      setState(() {
                        _puzzleBoard[_selectedRow!][_selectedCol!] = 0; // Clear the cell
                      });
                    }
                  },
                  child: Text('Clear Cell', style: ThemeStyle.buttonText(context)),
                ),
              ),
              SizedBox(height: 50.0), // Additional space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}

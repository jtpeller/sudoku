import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common.dart';
import 'options.dart';
import 'settings_manager.dart';
import 'styles.dart';
import 'sudoku_generator.dart';
import 'widgets.dart' as widgets;

/// ### GamePage
///
/// A `StatefulWidget` that represents the main game page for Sudoku.
///
/// Displays the Sudoku board and handles game logic based on the selected `difficulty`.
///
/// `difficulty` determines the complexity of the generated puzzle.
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
  List<int> _numbersCount = List.filled(9, 0);

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
  void _generateNewPuzzle({GenerationMode mode = GenerationMode.random}) {
    final generator = SudokuGenerator();
    final generatedData = generator.generateSudoku(_difficulty, mode: mode.index);

    setState(() {
      _puzzleBoard = generatedData['puzzle'];
      _solutionBoard = generatedData['solution'];
      _isEditable = generatedData['isEditable'];
      _isHinted = List.generate(9, (_) => List.filled(9, false)); // Reset hints
      _numbersCount = _initNumbersCount();
      _hintsUsed = 0; // Reset hints used counter
      _mistakes = 0; // Reset mistakes counter
      // Reset selection
      _selectedRow = null; // Reset selection
      _selectedCol = null; // Reset selection
    });
  }

  /// Clears the current Sudoku puzzle.
  void _clearPuzzle() {
    // create a copy of the puzzle board
    List<List<int>> clearedBoard = List.generate(9, (i) => List.from(_puzzleBoard[i]));
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        // Clear only editable cells
        if (_isEditable[row][col]) {
          clearedBoard[row][col] = 0;
        }
      }
    }
    setState(() {
      _puzzleBoard = clearedBoard; // Update the puzzle board
      _isHinted = List.generate(9, (_) => List.filled(9, false)); // Reset hints
      _numbersCount = _initNumbersCount(); // Reset numbers count
      _hintsUsed = 0; // Reset hints used counter
      _mistakes = 0; // Reset mistakes counter
      _selectedRow = null; // Reset selection
      _selectedCol = null; // Reset selection
    });
    // Show a message indicating the puzzle has been cleared
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Puzzle cleared!', style: ThemeStyle.tooltip(context)),
        duration: Duration(seconds: 2),
        dismissDirection: DismissDirection.down,
      ),
    );
  }

  /// Checks if the Sudoku puzzle is solved.
  ///
  /// If puzzle board matches solution board, congratulate user. Offer new game / close.
  /// Otherwise, returns `false`.
  bool _checkPuzzleSolved(BuildContext context) {
    // check if the puzzle is solved
    if (_puzzleBoard.every((row) => row.every((cell) => cell != 0))) {
      String hintMsg =
          _hintsUsed > 0
              ? 'Hints Used: $_hintsUsed. (It\'s OK, I won\'t tell)\n'
              : 'No hints! Great job!\n';

      String mistakeMsg =
          _mistakes > 0
              ? 'Mistakes: $_mistakes. (It happens to the best of us.)\n'
              : 'No mistakes! Great job!\n';

      String perfect =
          _mistakes == 0 && _hintsUsed == 0
              ? 'Perfect Game! Great work!\nPlay Again?'
              : 'Play Again?';

      // Show a dialog or message indicating the game is solved
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Congratulations!', style: ThemeStyle.mediumGameText(context)),
              content: Text(
                'You solved an $_difficulty Sudoku puzzle!\n'
                "Here's your stats:"
                '> $hintMsg'
                '> $mistakeMsg'
                '$perfect',
                style: ThemeStyle.smallGameText(context),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _generateNewPuzzle(mode: context.read<SettingsManager>().generationMode); // Generate a new puzzle
                  },
                  child: const Text('New Game'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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

  /// Generates the number buttons for the Sudoku game.
  /// Creates buttons for numbers 1 to 9 and a clear button.
  /// Each button is wrapped in a [Padding] widget for spacing.
  /// The buttons are styled using the [ThemeStyle.gridButtonThemeData] method.
  /// The clear button allows the user to remove the number from the selected cell if it is editable.
  /// Returns a list of [Padding] widgets containing the buttons.
  List<Padding> _generateNumberButtons() {
    List<Padding> numbers = List.generate(9, (numIndex) {
      final num = numIndex + 1;
      final count = _numbersCount[numIndex];
      final isFull = count >= 9;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.5),
        child: OutlinedButton(
          onPressed: () => _onNumberButtonTap(num),
          style: OutlinedButton.styleFrom(
            backgroundColor:
                isFull ? ThemeColor.getCorrectColor(context) : ThemeColor.getBgColorLite(context),
            fixedSize: Size(50.0, 50.0),
            foregroundColor: ThemeColor.getBodyText(context),
            padding: EdgeInsets.all(0),
            shape: CircleBorder(),
            side: BorderSide(color: ThemeColor.getBorderColor(context)),
            textStyle: ThemeStyle.buttonText(context),
          ),
          child: Center(
            child: Text(
              (numIndex + 1).toString(),
              style: ThemeStyle.buttonText(context),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    });

    // add the clear button
    numbers.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.5),
        child: OutlinedButton(
          style: ThemeStyle.gridButtonThemeData(context).style,
          onPressed: _onClearButtonTap,
          child: Icon(Icons.clear, size: 40.0, color: ThemeColor.getBodyText(context)),
        ),
      ),
    );
    return numbers;
  }

  ///////////////////////////
  ///    GETTER METHODS   ///
  ///////////////////////////

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

  /// Returns the border side for a Sudoku grid cell at the specified [row] x [col] and [side].
  BorderSide _getBorderSide(row, col, context, side) {
    double width = ThemeStyle.gridNormalBorder;
    // if this is an edge of the 3x3 block, use a thicker border
    if ((col > 0 && col % 3 == 0 && side == 'left') ||
        (row > 0 && row % 3 == 0 && side == 'top') ||
        (col < 8 && col % 3 == 2 && side == 'right') ||
        (row < 8 && row % 3 == 2 && side == 'bottom')) {
      width = ThemeStyle.gridThickBorder;
    }
    return BorderSide(
      color: ThemeColor.getBorderColor(context),
      width: width,
      style: BorderStyle.solid,
    );
  }

  ///////////////////////////
  ///    EVENT HANDLERS   ///
  ///////////////////////////

  /// Handles the tap event on a Sudoku cell.
  ///
  /// Selects the cell at [row] x [col] (if it is editable).
  /// Otherwise deselects any currently selected cell (allows de-selection).
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

  /// Handles the tap event on a [number] button in the Sudoku game.
  ///
  /// The puzzle board will be updated with the tapped number at the currently selected cell.
  /// If no cell is selected, it issues a message to the user.
  void _onNumberButtonTap(int number) {
    // first, save the current cell value
    int original = _puzzleBoard[_selectedRow!][_selectedCol!];

    // check if a cell is selected and it is editable
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
      } else {
        // number matches, increment the count for this number
        _updateNumbersCount(number);
      }

      _checkPuzzleSolved(context);

      // initiate lazy mode if enabled
      if (context.read<SettingsManager>().lazyMode && number == _solutionBoard[_selectedRow!][_selectedCol!]) {
        _moveToNextCell();
      }
    }
  }

  /// Handles the tap event on the hint button.
  void _onHintButtonTap() {
    // ensure this selected cell is editable and not already hinted
    // and that the cell is not already correct
    if (_selectedRow != null &&
        _selectedCol != null &&
        _isEditable[_selectedRow!][_selectedCol!] &&
        !_isHinted[_selectedRow!][_selectedCol!] &&
        _puzzleBoard[_selectedRow!][_selectedCol!] !=
            _solutionBoard[_selectedRow!][_selectedCol!]) {
      setState(() {
        _puzzleBoard[_selectedRow!][_selectedCol!] = _solutionBoard[_selectedRow!][_selectedCol!];
        _isHinted[_selectedRow!][_selectedCol!] = true;
        _hintsUsed++;
        _updateNumbersCount(_solutionBoard[_selectedRow!][_selectedCol!]);
      });
      _checkPuzzleSolved(context);
    }
    // Show a message if no cell is selected
    else if (_selectedRow == null || _selectedCol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Select a cell first!', style: ThemeStyle.tooltip(context)),
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
          content: Text('This cell is already correct!', style: ThemeStyle.tooltip(context)),
          duration: Duration(seconds: 2),
          dismissDirection: DismissDirection.down,
        ),
      );
    }

    // initiate lazy mode if enabled
    if (context.read<SettingsManager>().lazyMode) {
      _moveToNextCell();
    }
  }

  /// Handles the clear button tap event.
  void _onClearButtonTap() {
    // disallow clearing if no cell is selected
    if (_selectedRow == null || _selectedCol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Select a cell first!', style: ThemeStyle.tooltip(context)),
          duration: Duration(seconds: 2),
          dismissDirection: DismissDirection.down,
        ),
      );
      return;
    }

    // disable clearing if the cell is already correct or hinted
    // an isHinted check is redundant, the cell would be correct anyway
    if (_puzzleBoard[_selectedRow!][_selectedCol!] ==
        _solutionBoard[_selectedRow!][_selectedCol!]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This cell is already correct!', style: ThemeStyle.tooltip(context)),
          duration: Duration(seconds: 2),
          dismissDirection: DismissDirection.down,
        ),
      );
      return;
    }
    if (_selectedRow != null && _selectedCol != null && _isEditable[_selectedRow!][_selectedCol!]) {
      setState(() {
        _puzzleBoard[_selectedRow!][_selectedCol!] = 0; // Clear the cell
      });
    }
  }

  ///////////////////////////
  ///    USEFUL METHODS   ///
  ///////////////////////////

  /// Initializes the count of how many times each number has been entered in the puzzle.
  List<int> _initNumbersCount() {
    // loop through the puzzle board and count
    List<int> temp = List.filled(9, 0);
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        int num = _puzzleBoard[row][col];
        if (num >= 1 && num <= 9) {
          temp[num - 1]++;
        }
      }
    }
    return temp; // Return the initialized count list
  }

  /// Moves to the next cell
  void _moveToNextCell() {
    // if no cell is selected, do nothing
    if (_selectedRow == null || _selectedCol == null) return;

    // move to the next editable cell
    for (int r = _selectedRow!; r < 9; r++) {
      for (int c = (r == _selectedRow! ? _selectedCol! + 1 : 0); c < 9; c++) {
        if (_isEditable[r][c]) {
          _onCellTap(r, c); // Select the next editable cell
          return; // Exit after selecting the next cell
        }
      }
    }
  }

  /// Updates the count of how many times a number has been entered in the puzzle.
  void _updateNumbersCount(int number, {bool increment = true}) {
    // only valid numbers (not that this should happen but who knows)!
    if (number < 1 || number > 9) return;

    // decide whether to increment or decrement the count
    if (increment) {
      _numbersCount[number - 1]++;
    } else {
      _numbersCount[number - 1]--;
    }
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
    final mgr = Provider.of<SettingsManager>(context);

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
              Wrap(
                alignment: WrapAlignment.center,
                children: <Widget>[
                  // New Game button
                  Tooltip(
                    message: 'New Game',
                    textStyle: ThemeStyle.tooltip(context),
                    child: IconButton(
                      icon: Icon(Icons.add),
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
                                      _generateNewPuzzle(mode: mgr.generationMode); // Generate a new puzzle
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
                  // Restart button
                  Tooltip(
                    message: 'Restart',
                    textStyle: ThemeStyle.tooltip(context),
                    child: IconButton(
                      icon: Icon(Icons.refresh),
                      style: ThemeStyle.iconButtonThemeData(context).style,
                      onPressed: () {
                        // open a dialog to confirm restart
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Restart Game'),
                                content: const Text('Are you sure you want to restart the game?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                      _clearPuzzle(); // Generate a new puzzle
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
                                content: RichText(
                                  text: TextSpan(
                                    style: ThemeStyle.smallGameText(context),
                                    children: [
                                      TextSpan(
                                        text: 'Sudoku is a logic-based number placement puzzle. '
                                        'The objective is to fill a 9x9 grid with digits so that each column, '
                                        'each row, and each of the nine 3x3 subgrids that compose the grid'
                                        'each contain all of the digits from 1 to 9.\n\n'
                                        'To fill in the grid, and solve the puzzle, tap on a cell in the grid to select it. '
                                        'Tap a number button to fill in the selected cell. When all the cells have been filled '
                                        'in and are correct, the puzzle is solved!\n\n'
                                        'Use the Hint button ('
                                      ),
                                      WidgetSpan(
                                        child: Icon(Icons.lightbulb, size: ThemeStyle.smallGameText(context).fontSize! * 1.2),
                                      ),
                                      TextSpan(
                                        text: ') to reveal the correct number for the selected cell.\n'
                                        'Use the Clear Button ('
                                      ),
                                      WidgetSpan(
                                        child: Icon(Icons.clear, size: ThemeStyle.smallGameText(context).fontSize! * 1.2),
                                      ), 
                                      TextSpan(
                                        text: ') to remove the number from the selected cell.\n'
                                        'You can also start a new game ('
                                      ),
                                      WidgetSpan(
                                        child: Icon(Icons.add, size: ThemeStyle.smallGameText(context).fontSize! * 1.2),
                                      ),
                                      TextSpan(text: ') at any time.'),
                                    ],
                                  ),
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
                      onPressed: _onHintButtonTap,
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
                  final double containerSize =
                      gridSize > 500 ? 500 : (gridSize < 300 ? 300 : gridSize);

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 300.0, // Minimum grid size
                        minHeight: 300.0, // Minimum grid size
                        maxWidth: containerSize,
                        maxHeight: containerSize,
                      ),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 9,
                          crossAxisSpacing: 0.0,
                          mainAxisSpacing: 0.0,
                          childAspectRatio: 1.0,
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
                                  left: _getBorderSide(row, col, context, 'left'),
                                  top: _getBorderSide(row, col, context, 'top'),
                                  right: _getBorderSide(row, col, context, 'right'),
                                  bottom: _getBorderSide(row, col, context, 'bottom'),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: ThemeColor.getBoxShadowColor(context),
                                    blurRadius: 1.0,
                                    offset: Offset(0, 0),
                                    blurStyle: BlurStyle.solid,
                                  ),
                                ],
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
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6.0, // Spacing between buttons
                runSpacing: 6.0, // Spacing between rows of buttons
                children: _generateNumberButtons(),
              ),
              widgets.massiveVerticalSpacer, // Additional space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}

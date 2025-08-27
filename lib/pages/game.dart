import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/settings_manager.dart';
import '../data/sudoku_generator.dart';

import '../theme/colors.dart';
import '../theme/text.dart';

import '../widgets/spacing.dart' as spacing;
import '../widgets/game_widgets.dart' as widgets;
import '../widgets/stopwatch.dart';

import 'options.dart';

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
  /// difficulty mode; Ex: 'Beginner' or 'Expert'
  late String _difficulty;

  /// Matrix of user's entries (plus fixed cells)
  List<List<int>> _puzzleBoard = List.generate(9, (_) => List.filled(9, 0));

  /// Matrix of solutions (compare against this for correctness)
  List<List<int>> _solutionBoard = List.generate(9, (_) => List.filled(9, 0));

  /// Matrix of flags on whether this cell is editable or not
  List<List<bool>> _isEditable = List.generate(9, (_) => List.filled(9, false));

  /// Matrix of flags on whether this cell was determined using a hint.
  List<List<bool>> _isHinted = List.generate(9, (_) => List.filled(9, false));

  /// List of counts of each number in the grid (1 thru 9)
  List<int> _numbersCount = List.filled(9, 0);

  /// Matrix of user's (or auto-candidate mode's) candidates
  List<List<Set<int>>> _candidateBoard = List.generate(9, (_) => List.generate(9, (_) => <int>{}));

  /// Whether the user is in candidate mode (true) or normal mode (false)
  bool _isCandidateMode = false;

  /// Currently selected cell's row
  int? _selectedRow;

  /// Currently selected cell's column
  int? _selectedCol;

  /// Currently selected cell's value
  int? _selectedValue;

  /// How many hints used in this game
  int _hintsUsed = 0;

  /// How many mistakes made in this game
  int _mistakes = 0;

  /// Manages the timer.
  StopwatchManager _timerMgr = StopwatchManager();

  /// the timer
  Stopwatch? _gameTimer;

  @override
  void initState() {
    super.initState();
    _difficulty = widget.difficulty;
    _generateNewPuzzle(); // Generate the initial puzzle
  }

  /// Generates a new Sudoku puzzle based on the current difficulty level.
  ///
  /// This method uses the [SudokuGenerator] class to create a new puzzle and its solution.
  /// It updates the puzzle board, solution board, and editable cells in the state.
  /// Also resets the currently selected row and column to null.
  void _generateNewPuzzle({GenerationMode mode = GenerationMode.symmetrical}) {
    final generator = SudokuGenerator();
    final generatedData = generator.generateSudoku(_difficulty, mode: mode.index);

    setState(() {
      _puzzleBoard = generatedData['puzzle'];
      _solutionBoard = generatedData['solution'];
      _isEditable = generatedData['isEditable'];
      _isHinted = List.generate(9, (_) => List.filled(9, false));
      _numbersCount = _initNumbersCount();
      _hintsUsed = 0;
      _mistakes = 0;
      // Reset selection
      _selectedRow = null;
      _selectedCol = null;
      _selectedValue = null;
    });

    _timerMgr.reset();
  }

  /// Clears the current Sudoku puzzle.
  void _clearPuzzle() {
    // create a copy of the puzzle board
    List<List<int>> clearedBoard = List.generate(9, (i) => List.from(_puzzleBoard[i]));
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        // Clear only editable cells
        if (_isEditable[r][c]) {
          clearedBoard[r][c] = 0;
        }
      }
    }

    setState(() {
      _puzzleBoard = clearedBoard; // Update the puzzle board
      _candidateBoard = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
      _isHinted = List.generate(9, (_) => List.filled(9, false)); // Reset hints
      _numbersCount = _initNumbersCount(); // Reset numbers count
      _hintsUsed = 0; // Reset hints used counter
      _mistakes = 0; // Reset mistakes counter
      _selectedRow = null; // Reset selection
      _selectedCol = null; // Reset selection
      _selectedValue = null; // Reset selected value
    });

    // reset the timer
    _timerMgr.reset();
    _timerMgr.start();

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
    bool isSolved = true;
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        // If any cell does not match the solution, return false
        if (_puzzleBoard[row][col] != _solutionBoard[row][col]) {
          isSolved = false;
          break;
        }
      }
    }

    // check if the puzzle is solved
    if (isSolved) {
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
      _timerMgr.pause();
      widgets.showYesNoDialog(
        context,
        'Congratulations!',
        'You solved an $_difficulty Sudoku puzzle in $_gameTimer!\n'
            "Here's your stats:\n"
            '> $hintMsg'
            '> $mistakeMsg'
            '$perfect',
        onYes: () {
          // generate new puzzle, and then resume timer.
          _generateNewPuzzle(
            mode: context.read<SettingsManager>().generationMode,
          ); // Generate a new puzzle
          _timerMgr.resume();
        },
        onNo: () {
          // only resume timer.
          _timerMgr.resume();
        },
      );
      return true; // Puzzle is solved
    }
    return false; // Puzzle is not solved
  }

  ///////////////////////////////
  ///     BUILDER METHODS     ///
  ///////////////////////////////

  /// returns the help text as a scrollable rich text widget.
  Widget _buildHelpText(BuildContext context) {
    return SingleChildScrollView(
      child: RichText(
        text: TextSpan(
          style: ThemeStyle.smallGameText(context),
          children: [
            TextSpan(
              text:
                  'Sudoku is a logic-based number placement puzzle. '
                  'The objective is to fill a 9x9 grid with digits so that each column, '
                  'each row, and each of the nine 3x3 subgrids that compose the grid '
                  'each contain all of the digits from 1 to 9.\n\n'
                  'To fill in the grid, and solve the puzzle, tap on a cell in the grid to select it. '
                  'Tap a number button to fill in the selected cell. When all the cells have been filled '
                  'in and are correct, the puzzle is solved!\n\n'
                  'Use the Hint button (',
            ),
            WidgetSpan(
              child: Icon(Icons.lightbulb, size: ThemeStyle.smallGameText(context).fontSize!),
            ),
            TextSpan(
              text:
                  ') to reveal the correct number for the selected cell.\n'
                  'Use the Clear Button (',
            ),
            WidgetSpan(child: Icon(Icons.clear, size: ThemeStyle.smallGameText(context).fontSize!)),
            TextSpan(
              text:
                  ') to remove the number from the selected cell.\n'
                  'You can also start a new game (',
            ),
            WidgetSpan(child: Icon(Icons.add, size: ThemeStyle.smallGameText(context).fontSize!)),
            TextSpan(text: ') at any time.'),
          ],
        ),
      ),
    );
  }

  /// Builds the
  List<Widget> _buildStatsRow(BuildContext context) {
    // init the list, and add difficulty / hints
    List<Widget> statsRow = [
      Text(_difficulty, style: ThemeStyle.mediumGameText(context)),
      Text('Hints: $_hintsUsed', style: ThemeStyle.mediumGameText(context)),
    ];

    // if check correctness is on, show mistakes
    if (context.read<SettingsManager>().checkCorrectness) {
      statsRow.add(Text('Mistakes: $_mistakes', style: ThemeStyle.mediumGameText(context)));
    }

    // finally, add the timer if enabled
    if (context.read<SettingsManager>().enableTimer) {
      statsRow.add(
        // TODO: add a pause button here.
        _gameTimer!,
      );
    }

    return statsRow;
  }

  /// Builds the Sudoku grid using a [GridView.builder].
  Widget _buildSudokuGrid() {
    // decide whether to compute candidates
    final computeCandidates = context.read<SettingsManager>().autoCandidateMode;
    final checkCorrectness = context.read<SettingsManager>().checkCorrectness;
    if (computeCandidates) {
      // compute candidates for the current puzzle
      _candidateBoard = SudokuGenerator.computeCandidates(_puzzleBoard, _solutionBoard);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double gridSize =
            (constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight) -
            50; // Padding to prevent overflow
        final double containerSize = gridSize > 500 ? 500 : (gridSize < 300 ? 300 : gridSize);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 300.0, // Minimum grid size
              minHeight: 300.0, // Minimum grid size
              maxWidth: containerSize,
              maxHeight: containerSize,
            ),
            child: GridView.builder(
              shrinkWrap: true, // Shrink to fit the content
              physics: NeverScrollableScrollPhysics(), // Disable scrolling
              padding: const EdgeInsets.all(0.0),
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
                int currentBoxRow = row ~/ 3;
                int currentBoxCol = col ~/ 3;
                bool highlighted =
                    _selectedRow != null &&
                    _selectedCol != null &&
                    (row == _selectedRow ||
                        col == _selectedCol ||
                        (_selectedRow! ~/ 3 == currentBoxRow &&
                            _selectedCol! ~/ 3 == currentBoxCol));

                return widgets.SudokuTile(
                  row: row,
                  col: col,
                  value: _puzzleBoard[row][col],
                  candidates: _candidateBoard[row][col],
                  isSelected: (_selectedRow == row && _selectedCol == col),
                  isFixed: !_isEditable[row][col],
                  isIncorrect:
                      _puzzleBoard[row][col] != _solutionBoard[row][col] &&
                      _puzzleBoard[row][col] != 0,
                  isCorrect:
                      _puzzleBoard[row][col] == _solutionBoard[row][col] && _isEditable[row][col],
                  isHinted: _isHinted[row][col],
                  isValueSelected:
                      _puzzleBoard[row][col] == _selectedValue && _puzzleBoard[row][col] != 0,
                  isHighlighted: highlighted,
                  showCorrect: checkCorrectness,
                  onTap: () => _onCellTap(row, col),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCandidateModeToggleButton() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              _isCandidateMode = false; // Toggle candidate mode
            });
          },
          style: ThemeStyle.candidateButtonThemeData(context, !_isCandidateMode).style,
          child: Text('Normal', style: ThemeStyle.smallButtonText(context)),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isCandidateMode = true; // Toggle candidate mode
            });
          },
          style: ThemeStyle.candidateButtonThemeData(context, _isCandidateMode).style,
          child: Text('Candidate', style: ThemeStyle.smallButtonText(context)),
        ),
      ],
    );
  }

  /// Generates the number buttons for the Sudoku game.
  /// Creates buttons for numbers 1 to 9 and a clear button.
  Widget _buildNumberButtons() {
    // set up the numbers list
    // numbers 1-9, plus a clear button
    List<String> numbers = List.generate(9, (index) => (index + 1).toString());
    numbers.add('X'); // Clear button

    // create via gridview
    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = 250.0;
        final maxWidth = 400.0;
        final double targetWidth =
            (constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight) -
            100; // Padding to prevent overflow
        final double containerSize =
            targetWidth > maxWidth ? maxWidth : (targetWidth < minWidth ? minWidth : targetWidth);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth, maxWidth: containerSize),
            child: GridView.count(
              crossAxisCount: 5, // 5 buttons per row
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1.8,
              padding: const EdgeInsets.all(0.0),
              shrinkWrap: true, // Shrink to fit the content
              physics: NeverScrollableScrollPhysics(), // Disable scrolling
              children: List.generate(numbers.length, (index) {
                final num = numbers[index];
                final isFull =
                    index < 9 ? _numbersCount[index] >= 9 : false; // Check if number is full

                return Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: OutlinedButton(
                    onPressed: () {
                      if (num == 'X') {
                        _onClearButtonTap(); // Clear button
                      } else {
                        _onNumberButtonTap(int.parse(num)); // Number button
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor:
                          isFull
                              ? ThemeColor.getCellCorrectColor(context)
                              : ThemeColor.getCellAccentColor(context),
                      foregroundColor: ThemeColor.getTextBodyColor(context),
                      padding: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                        side: BorderSide(color: ThemeColor.getBorderColor(context)),
                      ),
                      textStyle: ThemeStyle.numberButtonText(context),
                    ),
                    child: Center(
                      child:
                          num == 'X'
                              ? Icon(
                                Icons.clear,
                                size: ThemeStyle.numberButtonText(context).fontSize! * 1.2,
                              )
                              : Text(
                                num,
                                style:
                                    _isCandidateMode
                                        ? ThemeStyle.candidateText(context)
                                        : ThemeStyle.numberButtonText(context),
                                textAlign: TextAlign.center,
                              ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  ///////////////////////////
  ///    EVENT HANDLERS   ///
  ///////////////////////////

  /// Handles the tap event on a Sudoku cell.
  ///
  /// Selects the cell at [row] x [col]
  void _onCellTap(int row, int col) {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
      _selectedValue = _puzzleBoard[row][col];
    });
  }

  /// Handles the tap event on a [number] button in the Sudoku game.
  ///
  /// The puzzle board will be updated with the tapped number at the currently selected cell.
  /// If no cell is selected, it issues a message to the user.
  void _onNumberButtonTap(int number) {
    // check if a cell is selected and it is editable
    if (_selectedRow != null && _selectedCol != null && _isEditable[_selectedRow!][_selectedCol!]) {
      // save the current cell value
      int original = _puzzleBoard[_selectedRow!][_selectedCol!];

      if (_isCandidateMode) {
        // set state for candidate mode
        setState(() {
          // toggle the candidate number in the candidate board
          if (_candidateBoard[_selectedRow!][_selectedCol!].contains(number)) {
            _candidateBoard[_selectedRow!][_selectedCol!].remove(number);
          } else {
            _candidateBoard[_selectedRow!][_selectedCol!].add(number);
          }
        });
        return; // no need to continue, candidates are handled separately
      } else {
        // set state for number mode
        setState(() {
          _puzzleBoard[_selectedRow!][_selectedCol!] = number;
          _selectedValue = number; // Update selected value
        });
      }

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
      if (context.read<SettingsManager>().lazyMode &&
          number == _solutionBoard[_selectedRow!][_selectedCol!]) {
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
        _isEditable[_selectedRow!][_selectedCol!] = false; // set as non-editable.
        _hintsUsed++;
        _updateNumbersCount(_solutionBoard[_selectedRow!][_selectedCol!]);
        _selectedValue = _solutionBoard[_selectedRow!][_selectedCol!];
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
      return;
    }

    if (_isCandidateMode) {
      // clear candidates for the selected cell
      setState(() {
        _candidateBoard[_selectedRow!][_selectedCol!] = <int>{}; // Clear candidates
      });
      return; // no need to continue.
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

    // clear only if editable
    if (_selectedRow != null && _selectedCol != null && _isEditable[_selectedRow!][_selectedCol!]) {
      setState(() {
        _puzzleBoard[_selectedRow!][_selectedCol!] = 0;
        _selectedValue = null;
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
        if (_isEditable[r][c] && _puzzleBoard[r][c] != _solutionBoard[r][c]) {
          _onCellTap(r, c); // Select the next editable cell
          return; // Exit after selecting the next cell
        }
      }
    }

    // if a cell cannot be found, start at 0 and wrap around to the selected cell
    for (int r = 0; r < _selectedRow!; r++) {
      for (int c = 0; c < _selectedCol!; c++) {
        if (_isEditable[r][c] && _puzzleBoard[r][c] != _solutionBoard[r][c]) {
          _onCellTap(r, c);
          return;
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

    _gameTimer = Stopwatch(
      startSeconds: _timerMgr.elapsedSeconds + 0.0,
      countUp: true,
      manager: _timerMgr,
      textStyle: ThemeStyle.mediumGameText(context),
      autoStart: true,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Sudoku')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('Sudoku', style: ThemeStyle.gameTitle(context)),
              //Text(, style: ThemeStyle.subtitle(context)),
              Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 25.0,
                children: _buildStatsRow(context),
              ),
              spacing.verticalSpacer,
              spacing.smallVerticalSpacer,
              // Game buttons (hint, settings, etc.)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24.0,
                runSpacing: 8.0,
                children: <Widget>[
                  // New Game button
                  widgets.TooltipIconButton(
                    icon: Icons.add,
                    label: 'New Game',
                    onPressed: () {
                      _timerMgr.pause();
                      widgets.showYesNoDialog(
                        context,
                        'New Game',
                        'Are you sure you want to start a new game?',
                        onYes: () {
                          _generateNewPuzzle(mode: mgr.generationMode); // Generate a new puzzle
                          _timerMgr.resume();
                        },
                        onNo: () {
                          _timerMgr.resume();
                        },
                      );
                    },
                  ),
                  // Restart button
                  widgets.TooltipIconButton(
                    icon: Icons.refresh,
                    label: 'Restart',
                    onPressed: () {
                      // open a dialog to confirm restart
                      _timerMgr.pause();
                      widgets.showYesNoDialog(
                        context,
                        'Restart Game',
                        'Are you sure you want to restart the game?',
                        onYes: () {
                          _clearPuzzle(); // Generate a new puzzle
                        },
                        onNo: () {
                          _timerMgr.resume();
                        },
                      );
                      _timerMgr.resume();
                    },
                  ),
                  // Help button
                  widgets.TooltipIconButton(
                    icon: Icons.help_outline,
                    label: 'Help',
                    onPressed: () {
                      _timerMgr.pause();
                      widgets.showInfoDialog(
                        context,
                        'Help',
                        _buildHelpText(context),
                        onDone: () {
                          _timerMgr.resume();
                        },
                      );
                    },
                  ),
                  // Hint button
                  widgets.TooltipIconButton(
                    icon: Icons.lightbulb,
                    label: 'Hint',
                    onPressed: () {
                      _timerMgr.pause();
                      _onHintButtonTap();
                      _timerMgr.resume();
                    },
                  ),
                  // Settings button
                  widgets.TooltipIconButton(
                    icon: Icons.settings,
                    label: 'Options',
                    onPressed: () {
                      _timerMgr.pause();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OptionsPage()),
                      );
                      _timerMgr.resume();
                    },
                  ),
                ],
              ),
              spacing.smallVerticalSpacer,
              // Grid
              _buildSudokuGrid(),
              // Candidate mode toggle button
              spacing.smallVerticalSpacer,
              _buildCandidateModeToggleButton(),
              spacing.smallVerticalSpacer,
              // Number input buttons
              _buildNumberButtons(),
              spacing.massiveVerticalSpacer, // Additional space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}

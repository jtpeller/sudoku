import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/widgets/frosted_glass.dart';

import '../data/settings_manager.dart';
import '../data/sudoku_generator.dart';

import '../theme/colors.dart';
import '../theme/theme.dart';
import '../theme/text.dart';

import '../widgets/common.dart' as common;
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
  final SudokuDifficulty difficulty;

  const GamePage({super.key, required this.difficulty});

  @override
  State<GamePage> createState() => _GamePageState();
}

/// The state class for the [GamePage] widget.
///
/// Manages the game logic, UI updates, and user interactions for the Sudoku game page.
class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  /// difficulty mode; Ex: 'Beginner' or 'Expert'
  late SudokuDifficulty _difficulty;

  /// Matrix of user's entries (plus fixed cells)
  List<List<int>> _puzzleBoard = List.generate(9, (_) => List.filled(9, 0));

  /// Matrix of solutions (compare against this for correctness)
  List<List<int>> _solutionBoard = List.generate(9, (_) => List.filled(9, 0));

  /// Matrix of flags on whether this cell is editable or not
  List<List<bool>> _isEditable = List.generate(9, (_) => List.filled(9, false));

  /// Copy of the original is editable, used when user restarts.
  List<List<bool>> _originalIsEditable = List.generate(9, (_) => List.filled(9, false));

  /// Matrix of flags on whether this cell was determined using a hint.
  List<List<bool>> _isHinted = List.generate(9, (_) => List.filled(9, false));

  /// List of counts of each number in the grid (1 thru 9)
  List<int> _numbersCount = List.filled(9, 0);

  /// Matrix of user's candidates.
  List<List<Set<int>>> _userCandidateBoard = List.generate(
    9,
    (_) => List.generate(9, (_) => <int>{}),
  );

  /// Matrix of computed candidates.
  List<List<Set<int>>> _realCandidateBoard = List.generate(
    9,
    (_) => List.generate(9, (_) => <int>{}),
  );

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

  /// Whether the puzzle is solved.
  bool _completed = false;

  /// Manages the timer.
  StopwatchManager _timerMgr = StopwatchManager();

  /// the timer
  Stopwatch? _gameTimer;

  /// Initializes the game page.
  @override
  void initState() {
    super.initState();

    // add the observer to listen to app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Resume the timer to begin (if it has been initialized already).
    _timerMgr.resume();

    _difficulty = widget.difficulty;
    _generateNewPuzzle(); // Generate the initial puzzle
  }

  /// Handles dispose, which doesn't necessarily mean anything needs to be destroyed (e.g.,
  /// the timer may just be paused instead!).
  @override
  void dispose() {
    // Remove the observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// This is called when the app state changes, overriding behavior in
  /// [WidgetsBindingObserver].
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Pause the timer when the app is backgrounded
      _timerMgr.pause();
    } else if (state == AppLifecycleState.resumed) {
      // Resume the timer when the app is brought back to the foreground
      if (!_completed) {
        _timerMgr.resume();
      }
    }
  }

  /// Generates a new Sudoku puzzle based on the current difficulty level.
  ///
  /// This method uses the [SudokuGenerator] class to create a new puzzle and its solution.
  /// It updates the puzzle board, solution board, and editable cells in the state.
  /// Also resets the currently selected row and column to null.
  void _generateNewPuzzle() {
    final mode = context.read<SettingsManager>().generationMode;
    final generator = SudokuGenerator();
    final generatedData = generator.generateSudoku(_difficulty, mode: mode);

    setState(() {
      _puzzleBoard = generatedData['puzzle'];
      _solutionBoard = generatedData['solution'];
      _isEditable = generatedData['isEditable'];
      _originalIsEditable = List.generate(9, (i) => List.from(generatedData['isEditable'][i]));
      _isHinted = List.generate(9, (_) => List.filled(9, false));
      _numbersCount = _initNumbersCount();
      _realCandidateBoard = SudokuGenerator.computeCandidates(
        generatedData['puzzle'],
        generatedData['solution'],
      );
      _hintsUsed = 0;
      _mistakes = 0;
      _completed = false;
      // Reset selection
      _selectedRow = null;
      _selectedCol = null;
      _selectedValue = null;
    });

    _timerMgr.reset();
    _timerMgr.start();

    // select a cell if lazy mode is enabled.
    if (context.read<SettingsManager>().lazyMode) {
      _moveToNextCell(context);
    }
  }

  /// Clears the current Sudoku puzzle.
  void _clearPuzzle() {
    // create a copy of the puzzle board
    List<List<int>> clearedBoard = List.generate(9, (i) => List.from(_puzzleBoard[i]));
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        // Clear only originally-editable cells
        if (_originalIsEditable[r][c]) {
          clearedBoard[r][c] = 0;
        }
      }
    }

    setState(() {
      _puzzleBoard = clearedBoard; // Update the puzzle board
      _userCandidateBoard = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
      _isEditable = List.generate(9, (i) => List.from(_originalIsEditable[i]));
      _isHinted = List.generate(9, (_) => List.filled(9, false)); // Reset hints
      _numbersCount = _initNumbersCount(); // Reset numbers count
      _hintsUsed = 0; // Reset hints used counter
      _mistakes = 0; // Reset mistakes counter
      _completed = false; // Reset completion status
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
      // Safely pause the timer now.
      _timerMgr.pause();

      // Set every cell as uneditable
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          _isEditable[r][c] = false;
        }
      }

      // Set up stats strings.
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

      // Compute how to display the difficulty
      // ... extract the name of this difficulty.
      String diffname = _difficulty.name;

      // ... capitalize first letter.
      String firstLetter = _difficulty.name[0].toUpperCase();
      String remainingLetters = _difficulty.name.substring(1).toLowerCase();
      diffname = firstLetter + remainingLetters;

      // ... figure out a vs an.
      if (diffname.startsWith(RegExp('a|e|i|o|u', caseSensitive: false))) {
        diffname = 'an $diffname';
      } else {
        diffname = 'a $diffname';
      }

      // Build the dialog.
      widgets.showYesNoDialog(
        context,
        'Congratulations!',
        'You solved $diffname Sudoku puzzle!\n'
            "Here's your stats:\n"
            '> $hintMsg'
            '> $mistakeMsg'
            '> Time: ${_timerMgr.getTime()}\n\n'
            '$perfect',
        onYes: () {
          // generate new puzzle, and then resume timer.
          _generateNewPuzzle(); // Generate a new puzzle
        },
        onNo: () {
          _timerMgr.reset(seconds: _timerMgr.elapsedSeconds);
          _completed = true;
        },
      );
      return true; // Puzzle is solved
    }
    return false; // Puzzle is not solved
  }

  /// Checks if the current board state is in a deadlock state.
  ///
  /// This means the user cannot logically determine the remaining cells.
  bool _checkDeadlock() {
    // Loop through the rows.
    for (int r = 0; r < 9; r++) {
      // Loop through the columns.
      for (int c = 0; c < 9; c++) {
        // Only need to check empty cells.
        if (_puzzleBoard[r][c] == 0) {
          // if any empty cell has only one candidate, then not a deadlock
          if (_realCandidateBoard[r][c].length == 1) {
            return false;
          }

          // Deadlock can occur across several cells.
          // TODO: Therefore, checks need to scan multiple cells in order to determine whether
          // the cells are interwoven.

          // if any empty cell has multiple candidates, and one of them is the solution, then not a deadlock
          if (_realCandidateBoard[r][c].length > 1 &&
              _realCandidateBoard[r][c].contains(_solutionBoard[r][c])) {
            return false;
          }
        }
      }
    }
    return true;
  }

  ///////////////////////////////
  ///     BUILDER METHODS     ///
  ///////////////////////////////

  /// returns the help text as a scrollable rich text widget.
  Widget _buildHelpText(BuildContext context) {
    // TODO: Make this help text modal look much better.
    //final double size = ThemeStyle.smallGameText(context).fontSize!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sudoku Basics', style: ThemeStyle.mediumGameText(context)),
        spacing.buildThinDivider(context),
        Text(
          'Sudoku is a logic-based number placement puzzle. The objective is to '
          'fill a 9x9 grid with digits such that each column, row, and each of the nine '
          '3x3 subgrids that compose the grid each contain all digits from 1 to 9 exactly once.',
          style: ThemeStyle.smallGameText(context),
        ),
        spacing.bigVerticalSpacer,
        Text('How to Play', style: ThemeStyle.mediumGameText(context)),
        spacing.buildThinDivider(context),
        Text(
          'To fill in the grid (and solve the puzzle), select a cell in the grid by tapping on it.'
          'Then, tap a number at the bottom to fill in the selected cell with that number. The puzzle'
          'is solved when all the cells are filled in and correct.',
          style: ThemeStyle.smallGameText(context),
        ),
        spacing.bigVerticalSpacer,
        Text('Buttons', style: ThemeStyle.mediumGameText(context)),
        spacing.buildThinDivider(context),
        Wrap(
          children: [
            Icon(
              Icons.add,
              color: ThemeColor.getNewGameAccentColor(context),
              size: ThemeStyle.smallGameText(context).fontSize,
            ),
            Text(
              'New Game: Generates a new puzzle for you.',
              style: ThemeStyle.smallGameText(context),
            ),
          ],
        ),
        Wrap(
          children: [
            Icon(
              Icons.refresh,
              color: ThemeColor.getRestartAccentColor(context),
              size: ThemeStyle.smallGameText(context).fontSize,
            ),
            Text(
              'Restart: Resets this current puzzle to normal.',
              style: ThemeStyle.smallGameText(context),
            ),
          ],
        ),
        Wrap(
          children: [
            Icon(
              Icons.lightbulb,
              color: ThemeColor.getHintAccentColor(context),
              size: ThemeStyle.smallGameText(context).fontSize,
            ),
            Text(
              'Hint: Select a cell, then tap the lightbulb to fill in that cell.',
              style: ThemeStyle.smallGameText(context),
            ),
          ],
        ),
        Wrap(
          children: [
            Icon(
              Icons.settings,
              color: ThemeColor.getOptionBtnAccentColor(context),
              size: ThemeStyle.smallGameText(context).fontSize,
            ),
            Text(
              'Settings: Opens the menu to change game or appearance settings.',
              style: ThemeStyle.smallGameText(context),
            ),
          ],
        ),
        spacing.bigVerticalSpacer,
      ],
    );
  }

  /// Builds the
  List<Widget> _buildStatsRow(BuildContext context) {
    // init the list, and add difficulty / hints
    List<Widget> statsRow = [
      Text(
        SudokuGenerator.getDifficultyName(_difficulty),
        style: ThemeStyle.mediumGameText(context),
      ),
      Text('Hints: $_hintsUsed', style: ThemeStyle.mediumGameText(context)),
    ];

    // if check correctness is on, show mistakes
    if (context.read<SettingsManager>().checkCorrectness) {
      statsRow.add(Text('Mistakes: $_mistakes', style: ThemeStyle.mediumGameText(context)));
    }

    // finally, add the timer if enabled
    StopwatchStatus? status = _timerMgr.getState();
    if (context.read<SettingsManager>().enableTimer) {
      double width = ThemeStyle.getFontSize(context, 3, ThemeStyle.fontSizeMD);
      statsRow.add(SizedBox(width: width, child: Center(child: _gameTimer!)));
    } else {
      statsRow.add(Offstage(child: _gameTimer!));
    }

    // Check whether to prvent this timer from continuing.
    StopwatchStatus? nowStatus = _timerMgr.getState();
    if (status == StopwatchStatus.paused &&
        nowStatus == StopwatchStatus.running &&
        _completed == true) {
      // ensure enabling and then un-enabling does not re-begin the timer.
      _timerMgr.pause();
    }

    return statsRow;
  }

  List<Widget> _buildSudokuButtons(BuildContext context) {
    // Setup specific aspects that will be looped over to generate this widget list.
    // ... Labels
    List<String> labels = ['New Game', 'Restart', 'Help', 'Hint', 'Settings'];

    // ... Icons
    List<IconData> icons = [
      Icons.add,
      Icons.refresh,
      Icons.help_outline,
      Icons.lightbulb,
      Icons.settings,
    ];

    // ... Accent Colors
    List<Color> accentColors = [
      ThemeColor.getNewGameAccentColor(context),
      ThemeColor.getRestartAccentColor(context),
      ThemeColor.getHelpAccentColor(context),
      ThemeColor.getHintAccentColor(context),
      ThemeColor.getOptionBtnAccentColor(context),
    ];

    // ... Callbacks
    List<VoidCallback> callbacks = [
      _onNewGameButtonTap,
      _onRestartButtonTap,
      _onHelpButtonTap,
      _onHintButtonTap,
      _onSettingsButtonTap,
    ];

    // Build the widget list.
    List<Widget> widgetList = [];
    for (int i = 0; i < 5; i++) {
      widgetList.add(
        common.FrostedTooltipIconButton(
          alpha: ThemeValues.alphaStrong,
          blur: ThemeValues.blurStrong,
          borderRadius: ThemeValues.circularRadius,
          borderWidth: ThemeValues.bWidthMid,
          accentColor: accentColors[i],
          startColor: ThemeColor.getIconButtonColor(context),
          icon: icons[i],
          label: labels[i],
          onPressed: callbacks[i],
        ),
      );
    }

    // Return the built list
    return widgetList;
  }

  /// Builds the Sudoku grid using a [GridView.builder].
  Widget _buildSudokuGrid() {
    // decide whether to compute candidates
    final checkCorrectness = context.read<SettingsManager>().checkCorrectness;

    _realCandidateBoard = SudokuGenerator.computeCandidates(_puzzleBoard, _solutionBoard);

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
                crossAxisSpacing: ThemeValues.noSpacing,
                mainAxisSpacing: ThemeValues.noSpacing,
                childAspectRatio: ThemeValues.squareRatio,
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

                List<List<Set<int>>> whichCandidates =
                    context.read<SettingsManager>().autoCandidateMode
                        ? _realCandidateBoard
                        : _userCandidateBoard;

                return widgets.SudokuTile(
                  row: row,
                  col: col,
                  value: _puzzleBoard[row][col],
                  candidates: whichCandidates[row][col],
                  isSelected: (_selectedRow == row && _selectedCol == col),
                  isFixed: !_originalIsEditable[row][col],
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
                  alpha: ThemeValues.alphaStrong,
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Builds the Normal and Candidate mode buttons.
  Widget _buildCandidateModeToggleButton() {
    // Decide which color each button will be based on the mode.
    final Color candidateBColor =
        _isCandidateMode
            ? ThemeColor.getAccentColor(context)
            : ThemeColor.getBorderExtraColor(context);

    final Color normalBColor =
        !_isCandidateMode
            ? ThemeColor.getAccentColor(context)
            : ThemeColor.getBorderExtraColor(context);

    final Color candidateColor =
        _isCandidateMode
            ? ThemeColor.getAccentColor(context)
            : ThemeColor.getCellAccentColor(context);

    final Color normalColor =
        !_isCandidateMode
            ? ThemeColor.getAccentColor(context)
            : ThemeColor.getCellAccentColor(context);

    // Set up arrays for looping
    List<Color> colors = [normalColor, candidateColor];
    List<Color> bColors = [normalBColor, candidateBColor];
    List<String> labels = ['Normal', 'Candidate'];
    List<bool> workAround = [false, true];
    List<Widget> buttons = [];

    // Build Wrap contents using a loop.
    for (int i = 0; i < labels.length; i++) {
      buttons.add(
        FrostedGlassBox(
          startColor: colors[i],
          alpha: ThemeValues.alphaMid,
          blur: ThemeValues.blurMid,
          borderColor: bColors[i],
          borderRadius: ThemeValues.circularRadius,
          borderWidth: ThemeValues.bWidthMid,
          child: TextButton(
            onPressed: () {
              setState(() {
                _isCandidateMode = workAround[i];
              });
            },
            style: ThemeStyle.candidateButtonThemeData(context).style,
            child: Text(labels[i], style: ThemeStyle.mediumButtonText(context)),
          ),
        ),
      );
    }

    // Return the wrap
    return Wrap(
      spacing: ThemeValues.spacingSpacy,
      runSpacing: ThemeValues.spacingSpacy,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: buttons,
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
        final maxWidth = 500.0;
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
              crossAxisSpacing: ThemeValues.spacingSpacy,
              mainAxisSpacing: ThemeValues.spacingSpacy,
              childAspectRatio: ThemeValues.numberButtonRatio,
              padding: const EdgeInsets.all(0.0),
              shrinkWrap: true, // Shrink to fit the content
              physics: NeverScrollableScrollPhysics(), // Disable scrolling
              children: List.generate(numbers.length, (index) {
                final num = numbers[index];
                final isFull =
                    index < 9 ? _numbersCount[index] >= 9 : false; // Check if number is full

                // Decide border and start color based on isFull
                Color borderColor =
                    isFull
                        ? ThemeColor.getCellCorrectColor(context)
                        : ThemeColor.getBorderExtraColor(context);
                Color buttonColor =
                    isFull
                        ? ThemeColor.getCellCorrectColor(context)
                        : ThemeColor.getCellAccentColor(context);

                if (index < 9) {
                  return Badge.count(
                    count: 9 - _numbersCount[index],
                    textStyle: ThemeStyle.badgeCount(context),
                    backgroundColor: ThemeColor.getBadgeCountColor(context),
                    textColor: ThemeColor.getTextBodyColor(context),
                    padding: EdgeInsets.all(3.0),
                    isLabelVisible: _numbersCount[index] < 9,
                    child: FrostedGlassBox(
                      borderRadius: ThemeValues.circularRadius,
                      alpha: ThemeValues.alphaStrong,
                      borderColor: borderColor,
                      borderWidth: ThemeValues.bWidthMid,
                      startColor: buttonColor,
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: MaterialButton(
                          onPressed: () {
                            if (!_completed) {
                              _onNumberButtonTap(int.parse(num));
                            }
                          },
                          child: Center(
                            child: Text(
                              num,
                              style:
                                  _isCandidateMode
                                      ? ThemeStyle.candidateText(context)
                                      : ThemeStyle.numberButtonText(context),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return FrostedGlassBox(
                    borderRadius: ThemeValues.circularRadius,
                    alpha: ThemeValues.alphaStrong,
                    borderColor: borderColor,
                    borderWidth: ThemeValues.bWidthMid,
                    startColor: buttonColor,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: MaterialButton(
                        onPressed: () {
                          if (_completed) {
                            _onClearButtonTap();
                          }
                        },
                        child: Center(
                          child: Icon(
                            Icons.clear,
                            size: ThemeStyle.numberButtonText(context).fontSize! * 1.2,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  );
                }
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

  /// Handles the tap event on the New Game button.
  ///
  /// Opens a dialog to confirm new game creation.
  void _onNewGameButtonTap() {
    _timerMgr.pause();
    widgets.showYesNoDialog(
      context,
      'New Game',
      'Are you sure you want to start a new game?',
      onYes: () {
        _generateNewPuzzle(); // Generate a new puzzle
      },
      onNo: () {
        if (!_completed) {
          _timerMgr.resume();
        }
      },
    );
  }

  /// Handles the tap event on the Restart Button.
  ///
  /// Opens a dialog to confirm restart.
  void _onRestartButtonTap() {
    _timerMgr.pause();
    widgets.showYesNoDialog(
      context,
      'Restart Game',
      'Are you sure you want to restart the game?',
      onYes: () {
        _clearPuzzle(); // Generate a new puzzle
      },
      onNo: () {
        if (!_completed) {
          _timerMgr.resume();
        }
      },
    );
  }

  /// Handles the tap event on the help button.
  ///
  /// Creates a dialog with help information.
  void _onHelpButtonTap() {
    _timerMgr.pause();
    widgets.showInfoDialog(
      context,
      'Help',
      _buildHelpText(context),
      onDone: () {
        if (!_completed) {
          _timerMgr.resume();
        }
      },
    );
  }

  /// Handles the tap event on the hint button.
  ///
  /// If an editable cell is selected, the cell is filled in with the correct
  /// value, and marked as a "hinted" cell. A hint counter is incremented.
  ///
  /// If the cell is uneditable, already correct, or no cell is selected,
  /// this shows a toast message at the bottom detailing what happened.
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
      _moveToNextCell(context);
    }
  }

  /// Handles the tap event on the Settings button.
  ///
  /// Navigates to the Options page.
  void _onSettingsButtonTap() async {
    _timerMgr.pause();
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const OptionsPage(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
      ),
    );
    if (!_completed) {
      _timerMgr.resume();
    }
  }

  /// Handles the tap event on a Sudoku cell.
  ///
  /// Selects the cell at [row] x [col]
  void _onCellTap(int row, int col) {
    // Deselect if the same cell is tapped again
    if (row == _selectedRow && col == _selectedCol) {
      setState(() {
        _selectedRow = null;
        _selectedCol = null;
        _selectedValue = null;
      });
      return;
    }

    // Select the tapped cell.
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
          if (_userCandidateBoard[_selectedRow!][_selectedCol!].contains(number)) {
            _userCandidateBoard[_selectedRow!][_selectedCol!].remove(number);
          } else {
            _userCandidateBoard[_selectedRow!][_selectedCol!].add(number);
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
        // Check if this is a deadlock condition, where a user would not be able to logically deduce
        // the remaining cells. If that is the case, then accept this solution, and modify the solution board.
        bool isDeadlock = _checkDeadlock();
        if (isDeadlock) {
          // modify the solution board to accept this number
          _solutionBoard[_selectedRow!][_selectedCol!] = number;
          // recompute candidates
          _realCandidateBoard = SudokuGenerator.computeCandidates(_puzzleBoard, _solutionBoard);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Deadlock detected & resolved!')));
        }

        // Increment mistakes counter
        _mistakes += 1;

        // error message
        if (context.read<SettingsManager>().checkCorrectness) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Incorrect number!')));
        }
      } else if (number == _solutionBoard[_selectedRow!][_selectedCol!]) {
        // number matches, increment the count for this number
        _updateNumbersCount(number);
      } else {
        // This number was already entered, do nothing.
        return;
      }

      _checkPuzzleSolved(context);

      // initiate lazy mode if enabled
      if (context.read<SettingsManager>().lazyMode &&
          number == _solutionBoard[_selectedRow!][_selectedCol!]) {
        _moveToNextCell(context);
      }
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
        _userCandidateBoard[_selectedRow!][_selectedCol!] = <int>{}; // Clear candidates
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
  void _moveToNextCell(BuildContext context) {
    bool conditionalMove = context.read<SettingsManager>().checkCorrectness;
    // if no cell is selected, do nothing
    if (_selectedRow == null || _selectedCol == null) return;

    // move to the next editable cell
    for (int r = _selectedRow!; r < 9; r++) {
      for (int c = (r == _selectedRow! ? _selectedCol! + 1 : 0); c < 9; c++) {
        if ((_isEditable[r][c] && !conditionalMove) ||
            (_isEditable[r][c] && conditionalMove && _puzzleBoard[r][c] != _solutionBoard[r][c])) {
          _onCellTap(r, c); // Select the next editable cell
          return; // Exit after selecting the next cell
        }
      }
    }

    // if a cell cannot be found, start at 0 and wrap around to the selected cell
    for (int r = 0; r < _selectedRow!; r++) {
      for (int c = 0; c < _selectedCol!; c++) {
        if ((_isEditable[r][c] && !conditionalMove) ||
            (_isEditable[r][c] && conditionalMove && _puzzleBoard[r][c] != _solutionBoard[r][c])) {
          _onCellTap(r, c);
          return;
        }
      }
    }
  }

  /// Updates the count of how many times a number has been entered in the puzzle.
  void _updateNumbersCount(int number, {bool increment = true}) {
    // Loop through the entire grid and count
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {}
    }

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
    // Initialize the game timer
    _gameTimer = Stopwatch(
      startSeconds: _timerMgr.elapsedSeconds + 0.0,
      countUp: true,
      manager: _timerMgr,
      textStyle: ThemeStyle.mediumGameText(context),
      autoStart: true,
    );

    return Scaffold(
      appBar: common.getAppBar(context, 'Sudoku'),
      body: common.getBackgroundBlurStack(
        alpha: 50,
        blur: 5.0,
        startColor: ThemeColor.getStartColor(context),
        context,
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Title
                Text('Sudoku', style: ThemeStyle.gameTitle(context)),
                // Stats row
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
                  children: _buildSudokuButtons(context),
                ),
                spacing.smallVerticalSpacer,
                // Grid
                _buildSudokuGrid(),
                // Candidate mode toggle button
                spacing.smallVerticalSpacer,
                _buildCandidateModeToggleButton(),
                spacing.verticalSpacer,
                // Number input buttons
                _buildNumberButtons(),
                spacing.massiveVerticalSpacer, // Additional space at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}

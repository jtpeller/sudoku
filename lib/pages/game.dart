import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:sudoku/data/settings_manager.dart';
import 'package:sudoku/data/game_storage.dart';
import 'package:sudoku/data/messenger.dart';

import 'package:sudoku/game/sudoku_manager.dart';

import 'package:sudoku/extensions/string_extensions.dart';

import 'package:sudoku/theme/colors.dart';
import 'package:sudoku/theme/theme.dart';
import 'package:sudoku/theme/text.dart';

import 'package:sudoku/widgets/common.dart' as common;
import 'package:sudoku/widgets/frosted_glass.dart';
import 'package:sudoku/widgets/spacing.dart' as spacing;
import 'package:sudoku/widgets/game_widgets.dart' as widgets;
import 'package:sudoku/widgets/confetti.dart';
import 'package:sudoku/widgets/stat_widgets.dart';
import 'package:sudoku/widgets/stopwatch.dart';

import 'options.dart';
import 'stats.dart';
import 'help.dart';

/// Represents the main game page for Sudoku.
class GamePage extends StatefulWidget {
  final String? initialSlot;
  final bool forceNewGame;

  const GamePage({super.key, this.initialSlot, this.forceNewGame = false});

  @override
  State<GamePage> createState() => _GamePageState();
}

/// The state class for the [GamePage] widget.
///
/// Manages the game logic, UI updates, and user interactions for the Sudoku game page.
class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  /// Unique Key ensures that redraws can be triggered upon grid changes.
  // ignore: unused_field
  Key _gridKey = UniqueKey();

  /// Sudoku game manager.
  late SudokuManager _mgr;

  /// Cached reference to settings manager for safe access during dispose.
  late SettingsManager _settingsManager;

  /// Whether the user is in candidate mode (true) or normal mode (false)
  bool _isCandidateMode = false;

  /// Currently selected cell's row
  int? _selectedRow;

  /// Currently selected cell's column
  int? _selectedCol;

  /// Currently selected cell's value
  int? _selectedValue;

  /// Whether the puzzle is solved.
  bool _completed = false;

  /// Manages the timer.
  StopwatchManager _timerMgr = StopwatchManager();

  /// The timer
  Stopwatch? _gameTimer;

  /// Initializes the game page.
  @override
  void initState() {
    super.initState();

    // Cache the settings manager immediately.
    _settingsManager = context.read<SettingsManager>();

    // Initialize the manager
    _mgr = SudokuManager();

    // Check if there's a game that exists
    _initGame();

    // add the observer to listen to app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // select a cell if lazy mode is enabled.
    if (_settings().lazyMode) {
      _moveToNextCell(context);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsManager = context.read<SettingsManager>();
  }

  /// Handles dispose, which doesn't necessarily mean anything needs to be destroyed (e.g.,
  /// the timer may just be paused instead!).
  @override
  void dispose() {
    _saveGame();
    GameStorage.saveSettings(_settings());

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
      _saveGame();
      GameStorage.saveSettings(_settings());
    } else if (state == AppLifecycleState.resumed) {
      // Resume the timer when the app is brought back to the foreground
      if (!_completed) {
        _timerMgr.resume();
      }
    }
  }

  /// Checks whether a game state exists in storage. If it does, it loads and returns true.
  /// If not, it will return false, and do nothing to the state of this class.
  Future<void> _initGame() async {
    // Load the stats first.
    await _mgr.loadStats();

    bool ret = widget.forceNewGame ? false : await _mgr.loadGame(slot: widget.initialSlot ?? 'auto');
    if (!ret) {
      _newPuzzle();
    } else {
      setState(() {
        _timerMgr.reset(seconds: _mgr.elapsedTime);
        if (!_completed) {
          _timerMgr.resume();
        }
        _gridKey = UniqueKey();
      });
    }
  }

  /// Responsible for creating a new puzzle.
  void _newPuzzle() {
    _timerMgr.pause();

    showAdaptiveDialog(
      context: context,
      builder: (context) {
        // Using StatefulBuilder to manage the dialog's internal state
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog.adaptive(
              title: Center(
                child: Text('Choose your puzzle!', style: ThemeStyle.subtitle(context)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  spacing.buildThinDivider(context),
                  // Difficulty Selection
                  Text('Difficulty', style: ThemeStyle.mediumGameText(context)),
                  spacing.smallVerticalSpacer,
                  DropdownButton<String>(
                    value: _mgr.difficulty,
                    items:
                        SudokuManager.getDifficultyNames().map((String val) {
                          return DropdownMenuItem(value: val, child: Text(val.capitalize()));
                        }).toList(),
                    onChanged: (newValue) {
                      setState(() => _mgr.setDifficulty(newValue!));
                    },
                  ),
                  spacing.buildThinDivider(context),
                  // Grid Dimension Configuration
                  Text('Grid Size', style: ThemeStyle.mediumGameText(context)),
                  spacing.smallVerticalSpacer,
                  SegmentedButton<int>(
                    segments: const <ButtonSegment<int>>[
                      ButtonSegment<int>(value: 4, label: Text('4x4')),
                      ButtonSegment<int>(value: 6, label: Text('6x6')),
                      ButtonSegment<int>(value: 9, label: Text('9x9')),
                      ButtonSegment<int>(value: 12, label: Text('12x12')),
                    ],
                    selected: <int>{_mgr.length.toInt()}, // Expects a Set
                    onSelectionChanged: (Set<int> newSelection) {
                      setState(() {
                        _mgr.setGridSizeFromSideLength(newSelection.first.toInt());
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancel', style: ThemeStyle.smallButtonText(context)),
                  onPressed: () {
                    Navigator.pop(context);
                    _timerMgr.resume();
                  },
                ),
                TextButton(
                  child: Text('Go!', style: ThemeStyle.smallButtonText(context)),
                  onPressed: () {
                    // Generate the game.
                    var mode = _settings().generationMode;
                    _mgr.generateGame(mode: mode);
                    _resetSelected();
                    Navigator.pop(context);

                    // Reset timer and state first so it saves correctly.
                    _timerMgr.reset();
                    _completed = false;

                    // Save the newly generated game.
                    _saveGame();

                    // Trigger the change
                    setState(() {
                      _gridKey = UniqueKey();
                    });

                    // 'Tap' beginning cell.
                    _onCellTap(0, 0);
                    _moveToNextCell(context);
                    _timerMgr.start();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Clears the current Sudoku puzzle.
  void _clearPuzzle() {
    _mgr.reset();
    _timerMgr.reset();

    setState(() {
      _completed = false;
      _selectedRow = null;
      _selectedCol = null;
      _selectedValue = null;
      _gridKey = UniqueKey();
    });

    // Save the cleared state
    _saveGame();

    _timerMgr.start();

    // Show a message indicating the puzzle has been cleared
    _showSnackBar(message: 'Puzzle cleared!');
  }

  /// Checks if the Sudoku puzzle is solved.
  ///
  /// If puzzle board matches solution board, congratulate user. Offer new game / close.
  /// Otherwise, returns `false`.
  bool _checkPuzzleSolved(BuildContext context) {
    bool isSolved = _mgr.isPuzzleSolved();

    // check if the puzzle is solved
    if (isSolved) {
      // Safely pause the timer now.
      _timerMgr.pause();

      // Set every cell as NOT editable!
      _mgr.setAllEditable(isEditable: false);

      setState(() {
        _completed = true;
      });

      // Record the victory!
      _mgr.recordGameResult(true, _timerMgr.currentValue);

      // Clear the save when the puzzle is solved.
      GameStorage.clear();

      _showVictoryDialog(context);
      return true; // Puzzle is solved
    }
    return false; // Puzzle is not solved
  }

  /// Displays the improved completion screen.
  void _showVictoryDialog(BuildContext context) {
    final String timeStr = _timerMgr.getTime() ?? '00:00';
    final int mistakes = _mgr.mistakes;
    final int hints = _mgr.hintsUsed;
    final String diffName = _mgr.difficulty.capitalize();

    showAdaptiveDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Center(
            child: Text('Victory!', style: ThemeStyle.subtitle(context).copyWith(fontSize: 28)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You solved $diffName puzzle', style: ThemeStyle.smallGameText(context)),
              spacing.bigVerticalSpacer,
              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    Icons.timer_outlined,
                    timeStr,
                    'Time',
                    ThemeColor.getAccentColor(context),
                  ),
                  _buildStatItem(
                    Icons.error_outline,
                    mistakes.toString(),
                    'Mistakes',
                    Colors.redAccent,
                  ),
                  _buildStatItem(Icons.lightbulb_outline, hints.toString(), 'Hints', Colors.amber),
                ],
              ),
              spacing.bigVerticalSpacer,
              // Accomplishment badges
              if (mistakes == 0 && hints == 0)
                Text(
                  '🌟 PERFECT GAME 🌟',
                  style: ThemeStyle.mediumGameText(
                    context,
                  ).copyWith(color: Colors.amber, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                )
              else ...[
                if (mistakes == 0)
                  Text(
                    '✓ No Mistakes!',
                    style: ThemeStyle.smallGameText(context).copyWith(color: Colors.green),
                  ),
                if (hints == 0)
                  Text(
                    '✓ Zero Hints Used!',
                    style: ThemeStyle.smallGameText(context).copyWith(color: Colors.blueAccent),
                  ),
              ],
              spacing.verticalSpacer,
              Text('Play again?', style: ThemeStyle.mediumGameText(context)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Back to menu
              },
              child: Text(
                'Menu',
                style: ThemeStyle.smallButtonText(context).copyWith(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _newPuzzle();
              },
              child: Text('New Game', style: ThemeStyle.smallButtonText(context)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: ThemeStyle.mediumGameText(context).copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: ThemeStyle.helperText(context)),
      ],
    );
  }

  /// Displays the Game Over screen.
  void _showGameOverDialog(BuildContext context) {
    _timerMgr.pause();
    _mgr.setAllEditable(isEditable: false);

    // Clear the save when the game is over.
    GameStorage.clear();

    // Record the loss!
    _mgr.recordGameResult(false, _timerMgr.currentValue);

    showAdaptiveDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Center(
            child: Text(
              'Game Over',
              style: ThemeStyle.subtitle(context).copyWith(color: Colors.redAccent, fontSize: 28),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.heart_broken, size: 64, color: Colors.redAccent),
              spacing.verticalSpacer,
              Text('You ran out of lives!', style: ThemeStyle.mediumGameText(context)),
              spacing.smallVerticalSpacer,
              Text('Better luck next time.', style: ThemeStyle.smallGameText(context)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Menu',
                style: ThemeStyle.smallButtonText(context).copyWith(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _newPuzzle();
              },
              child: Text('Try Again', style: ThemeStyle.smallButtonText(context)),
            ),
          ],
        );
      },
    );
  }

  ///////////////////////////////
  ///     BUILDER METHODS     ///
  ///////////////////////////////

  /// Helper to build a styled capsule for game stats.
  Widget _buildStatChip(Widget child, {double? width}) {
    return SizedBox(
      width: width,
      height: 44,
      child: FrostedGlassBox(
        alpha: ThemeValues.alphaWeak,
        blur: ThemeValues.blurWeak,
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Center(widthFactor: width == null ? 1.0 : null, heightFactor: 1.0, child: child),
      ),
    );
  }

  /// Builds the heart icons for the lives system.
  Widget _buildLives() {
    int remainingLives = (_mgr.maxMistakes - _mgr.mistakes).clamp(0, _mgr.maxMistakes);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_mgr.maxMistakes, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: AnimatedHeart(isFilled: index < remainingLives),
        );
      }),
    );
  }

  /// Builds the game information row: difficulty, mistakes, timer, etc.
  List<Widget> _buildGameRow(BuildContext context) {
    List<Widget> statsRow = [];
    const double width = 175;

    // Difficulty Capsule
    statsRow.add(
      StatGlowWrapper(
        value: _mgr.difficulty,
        glowColor: ThemeColor.getAccentColor(context),
        child: _buildStatChip(
          Text(
            _mgr.difficulty.capitalize(),
            style: ThemeStyle.mediumGameText(context).copyWith(fontWeight: FontWeight.bold),
          ),
          width: width,
        ),
      ),
    );

    // Hints Capsule
    statsRow.add(
      StatGlowWrapper(
        value: _mgr.hintsUsed,
        glowColor: Colors.amber,
        child: _buildStatChip(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lightbulb_outline, size: 20, color: Colors.amber),
              spacing.smallHorizontalSpacer,
              Text('${_mgr.hintsUsed}', style: ThemeStyle.mediumGameText(context)),
            ],
          ),
          width: width,
        ),
      ),
    );

    // Lives Capsule (Mistakes)
    if (_settings().checkCorrectness) {
      statsRow.add(
        StatGlowWrapper(
          value: _mgr.mistakes,
          glowColor: Colors.redAccent,
          child: _buildStatChip(_buildLives(), width: width),
        ),
      );
    }

    // Timer Capsule
    if (_settings().enableTimer) {
      statsRow.add(_buildStatChip(_gameTimer!, width: width));
    } else {
      statsRow.add(Offstage(child: _gameTimer!));
    }

    // Check whether to prevent this timer from continuing.
    StopwatchStatus? nowStatus = _timerMgr.getState();
    if (nowStatus == StopwatchStatus.running && _completed == true) {
      // ensure enabling and then un-enabling does not re-begin the timer.
      _timerMgr.pause();
    }

    return statsRow;
  }

  /// Builds the Sudoku game buttons, like new game, hints, restart, settings, etc.
  List<Widget> _buildSudokuButtons(BuildContext context) {
    // Setup specific aspects that will be looped over to generate this widget list.
    // ... Labels
    List<String> labels = ['New Game', 'Save', 'Restart', 'Stats', 'Help', 'Hint', 'Settings'];

    // ... Icons
    List<IconData> icons = [
      Icons.add,
      Icons.save_outlined,
      Icons.refresh,
      Icons.bar_chart,
      Icons.help_outline,
      Icons.lightbulb,
      Icons.settings,
    ];

    // ... Accent Colors
    List<Color> accentColors = [
      ThemeColor.getNewGameAccentColor(context),
      Colors.blueAccent,
      ThemeColor.getRestartAccentColor(context),
      Colors.purpleAccent,
      ThemeColor.getHelpAccentColor(context),
      ThemeColor.getHintAccentColor(context),
      ThemeColor.getOptionBtnAccentColor(context),
    ];

    // ... Callbacks
    List<VoidCallback> callbacks = [
      _newPuzzle,
      _onSaveButtonTap,
      _onRestartButtonTap,
      _onStatsButtonTap,
      _onHelpButtonTap,
      _onHintButtonTap,
      _onSettingsButtonTap,
    ];

    // Build the widget list.
    List<Widget> widgetList = [];
    for (int i = 0; i < labels.length; i++) {
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
    // Decide whether to show correctness
    final checkCorrectness = _settings().checkCorrectness;
    double maxGridSize =
        ((ThemeStyle.gridText(context).fontSize!.toInt() * 2) * _mgr.maxNumber).toDouble();
    double minGridSize =
        ((ThemeStyle.gridText(context).fontSize!.toInt() * 1.5) * _mgr.maxNumber).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double gridSize =
            (constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight) -
            50; // Padding to prevent overflow
        final double containerSize =
            gridSize > maxGridSize
                ? maxGridSize
                : (gridSize < minGridSize ? minGridSize : gridSize);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: minGridSize, // Minimum grid size
              minHeight: minGridSize, // Minimum grid size
              maxWidth: containerSize,
              maxHeight: containerSize,
            ),
            child: GridView.builder(
              shrinkWrap: true, // Shrink to fit the content
              physics: NeverScrollableScrollPhysics(), // Disable scrolling
              padding: const EdgeInsets.all(0.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _mgr.length.toInt(),
                crossAxisSpacing: ThemeValues.noSpacing,
                mainAxisSpacing: ThemeValues.noSpacing,
                childAspectRatio: ThemeValues.squareRatio,
              ),
              itemCount: _mgr.gridSize,
              itemBuilder: (context, index) {
                int row = index ~/ _mgr.maxNumber;
                int col = index % _mgr.maxNumber;
                List<(int, int)> scope = _mgr.getScope(row, col);
                bool highlighted = false;
                if (_selectedRow != null && _selectedCol != null) {
                  highlighted = scope.contains((_selectedRow!, _selectedCol!));
                }

                Set<int> candidates =
                    _settings().autoCandidateMode
                        ? _mgr.getRealCandidates(row, col)
                        : _mgr.getUserCandidates(row, col);

                final cellValue = _mgr.getValue(row, col);
                final isNull = cellValue == null;
                final isEditable = _mgr.isEditable(row, col);

                return widgets.SudokuTile(
                  row: row,
                  col: col,
                  value: cellValue ?? 0,
                  maxNumber: _mgr.maxNumber,
                  boxRows: _mgr.boxRows,
                  boxCols: _mgr.boxCols,
                  bgColor:
                      (_mgr.getBoxNumber(row, col) % 2 == 0)
                          ? ThemeColor.getCellAccentColor(context)
                          : ThemeColor.getCellBgColor(context),
                  candidates: candidates,
                  isSelected: (_selectedRow == row && _selectedCol == col),
                  isFixed: !isEditable,
                  isIncorrect: _mgr.isCorrect(row, col) && !isNull,
                  isCorrect: _mgr.isCorrect(row, col) && isEditable,
                  isHinted: _mgr.isHinted(row, col),
                  isValueSelected: cellValue == _selectedValue && !isNull,
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
                _gridKey = UniqueKey();
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
  /// Creates buttons for numbers and a clear button.
  Widget _buildNumberButtons() {
    // Set up the numbers list, which includes numbers, plus a clear button.
    List<String> numbers = List.generate(_mgr.maxNumber, (index) => (index + 1).toString());
    numbers.add('X'); // Clear button

    // Create via gridview
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
              crossAxisSpacing: ThemeValues.spacingMid,
              mainAxisSpacing: ThemeValues.spacingMid,
              childAspectRatio: ThemeValues.getNumberButtonRatio(context),
              padding: const EdgeInsets.all(0.0),
              shrinkWrap: true, // Shrink to fit the content
              physics: NeverScrollableScrollPhysics(), // Disable scrolling
              children: List.generate(numbers.length, (index) {
                final num = numbers[index];
                final value = index + 1;
                final isFull = _mgr.isFull(value);

                // Decide border and start color based on isFull
                Color borderColor =
                    isFull
                        ? ThemeColor.getCellCorrectColor(context).withValues(alpha: 0.5)
                        : ThemeColor.getBorderExtraColor(context);
                Color buttonColor =
                    isFull
                        ? ThemeColor.getCellCorrectColor(context).withValues(alpha: 0.5)
                        : ThemeColor.getCellAccentColor(context);

                if (index < _mgr.maxNumber) {
                  return Badge.count(
                    count: _mgr.getRemainingOf(value),
                    textStyle: ThemeStyle.badgeCount(context),
                    backgroundColor: ThemeColor.getBadgeCountColor(context),
                    textColor: ThemeColor.getTextBodyColor(context),
                    padding: EdgeInsets.all(3.0),
                    isLabelVisible: !isFull,
                    child: FrostedGlassBox(
                      borderRadius: ThemeValues.circularRadius,
                      alpha: ThemeValues.alphaStrong,
                      borderColor: borderColor,
                      borderWidth: ThemeValues.bWidthMid,
                      startColor: buttonColor,
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: MaterialButton(
                          padding: EdgeInsets.zero,
                          minWidth: 0,
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
                        padding: EdgeInsets.zero,
                        minWidth: 0,
                        onPressed: () {
                          if (!_completed) {
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

  /// Displays a snack bar containing the provided [message], which
  /// persists for the provided [duration].
  void _showSnackBar({required String message, int duration = 2}) {
    GameFeedbackMessenger.showStatus(context, message, duration: duration);
  }

  ///////////////////////////
  ///    EVENT HANDLERS   ///
  ///////////////////////////

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
        _clearPuzzle(); // Reset to beginning
      },
      onNo: () {
        if (!_completed) {
          _timerMgr.resume();
        }
      },
    );
  }

  Future<void> _onSaveButtonTap() async {
    _timerMgr.pause();

    final List<Map<String, dynamic>?> slots = await Future.wait([
      GameStorage.loadSave(slot: '1'),
      GameStorage.loadSave(slot: '2'),
      GameStorage.loadSave(slot: '3'),
    ]);

    if (!mounted) return;

    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Center(child: Text('Save Game', style: ThemeStyle.subtitle(context))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < 3; i++) ...[
                _buildSaveSlotTile(context, 'Slot ${i + 1}', slots[i], '${i + 1}'),
                if (i < 2) spacing.smallVerticalSpacer,
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (!_completed) _timerMgr.resume();
              },
              child: Text('Cancel', style: ThemeStyle.smallButtonText(context)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSaveSlotTile(BuildContext context, String title, Map<String, dynamic>? data, String slotId) {
    final bool isEmpty = data == null;
    return ListTile(
      title: Text(title, style: ThemeStyle.mediumGameText(context)),
      subtitle: Text(isEmpty ? 'Empty Slot' : 'Overwrite existing save', style: ThemeStyle.helperText(context)),
      onTap: () async {
        bool proceed = true;
        if (!isEmpty) {
          proceed = await showAdaptiveDialog<bool>(
            context: context,
            builder: (context) => AlertDialog.adaptive(
              title: const Text('Overwrite Save?'),
              content: Text('Are you sure you want to overwrite the save in $title?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Overwrite')),
              ],
            ),
          ) ?? false;
        }
        if (proceed) {
          await _mgr.saveGame(_timerMgr.currentValue, slot: slotId);
          if (context.mounted) {
            Navigator.pop(context);
            _showSnackBar(message: 'Game saved to $title');
            if (!_completed) _timerMgr.resume();
          }
        }
      },
    );
  }

  /// Handles the tap event on the help button.
  ///
  /// Navigates to the Help page.
  void _onHelpButtonTap() async {
    _timerMgr.pause();
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HelpPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );

    if (!_completed) {
      _timerMgr.resume();
    }
  }

  /// Handles the tap event on the hint button.
  ///
  /// If an editable cell is selected, the cell is filled in with the correct
  /// value, and marked as a "hinted" cell. A hint counter is incremented.
  ///
  /// If the cell is uneditable, already correct, or no cell is selected,
  /// this shows a toast message at the bottom detailing what happened.
  void _onHintButtonTap() {
    // Show a message if no cell is selected
    if (_selectedRow == null || _selectedCol == null) {
      _showSnackBar(message: 'Select a cell first!');
      return;
    }

    /* We know that selected row / col are non-null now! */

    // If the cell is already hinted, show a message.
    if (_mgr.isHinted(_selectedRow!, _selectedCol!)) {
      _showSnackBar(message: 'This cell is already hinted!');
      return;
    }

    // If checkCorrectness is on AND the cell is correct, show a message.
    final checkCorrectness = _settings().checkCorrectness;
    if (checkCorrectness && _mgr.isCorrect(_selectedRow!, _selectedCol!)) {
      _showSnackBar(message: 'This cell is already correct!');
      return;
    }

    /* All non-hint cases covered. Provide the hint! */

    // Set the value in the internal grid.
    _selectedValue = _mgr.setAsSolved(_selectedRow!, _selectedCol!);

    // Increment hint count
    _mgr.hintUsed(_selectedRow!, _selectedCol!);

    // Save the game state after a hint is used.
    _saveGame();

    // Set state to trigger an update.
    setState(() {
      _gridKey = UniqueKey();
    });

    // Check if the puzzle is solved.
    _mgr.isPuzzleSolved();

    // Initiate lazy mode if enabled
    if (_settings().lazyMode) {
      _moveToNextCell(context);
    }
  }

  /// Handles the tap event on the Stats button.
  void _onStatsButtonTap() async {
    _timerMgr.pause();
    final navigator = Navigator.of(context);
    
    await navigator.push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const StatsPage(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
      ),
    );

    if (!_completed) {
      _timerMgr.resume();
    }
  }

  /// Handles the tap event on the Settings button.
  ///
  /// Navigates to the Options page.
  void _onSettingsButtonTap() async {
    _timerMgr.pause();
    final settings = _settings();
    final navigator = Navigator.of(context);

    await navigator.push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const OptionsPage(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
      ),
    );

    // Save settings upon returning from the options page.
    GameStorage.saveSettings(settings);

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
        _resetSelected();
        _gridKey = UniqueKey();
      });
      return;
    }

    // Select the tapped cell.
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
      _selectedValue = _mgr.getValue(row, col);
      _gridKey = UniqueKey();
    });
  }

  /// Handles the tap event on a [number] button in the Sudoku game.
  ///
  /// The puzzle board will be updated with the tapped number at the currently selected cell.
  /// If no cell is selected, it issues a message to the user.
  void _onNumberButtonTap(int number) {
    // Block if no cell is selected
    if (_selectedRow == null || _selectedCol == null) {
      return;
    }

    // Shorthand row / col for ease.
    final row = _selectedRow!;
    final col = _selectedCol!;

    // Block if the cell is not editable.
    if (!_mgr.isEditable(row, col)) {
      return;
    }

    // Set the state for candidate mode!
    if (_isCandidateMode) {
      setState(() {
        _mgr.toggleUserCandidate(row, col, number);
        _gridKey = UniqueKey();
      });
      _saveGame();
      return;
    }

    /* Cell is editable, do work on it! */

    // If the number is equal to the original, do nothing.
    int? original = _mgr.getValue(row, col);
    if (number == original) {
      return;
    }

    // If the number is already full, show a message and block the placement.
    if (_mgr.isFull(number)) {
      _showSnackBar(message: "All $number's are already on the board!");
      return;
    }

    // Set the state for this cell
    setState(() {
      _mgr.setValueAt(row, col, number);
      _selectedValue = number;
      _gridKey = UniqueKey();
    });

    // Save the game state after a move.
    _saveGame();

    // If the solution is wrong (and not equal to the original value),
    // Try to check for deadlock, then mark a mistake.
    if (!_mgr.isCorrect(row, col)) {
      // Check if this is a deadlock condition, where a user would not be able to logically deduce
      // the remaining cells. If that is the case, then accept this solution, and modify the solution board.
      //      bool isDeadlock = _checkDeadlock();
      //      if (isDeadlock) {
      //        // modify the solution board to accept this number
      //        _solutionBoard[_selectedRow!][_selectedCol!] = number;
      //        // recompute candidates
      //        _realCandidateBoard = SudokuGenerator.computeCandidates(_puzzleBoard, _solutionBoard);
      //
      //        _showSnackBar(message: 'Deadlock detected & resolved!');
      //      }

      // A mistake was made.
      _mgr.mistaken();
      HapticFeedback.vibrate();

      if (_settings().checkCorrectness) {
        if (_mgr.isGameOver) {
          _showGameOverDialog(context);
          return;
        }
        _showSnackBar(message: 'Incorrect number!');
      }
    }

    // Decide if the puzzle is solved.
    bool isSolved = _checkPuzzleSolved(context);

    // Initiate lazy mode if enabled
    if (!isSolved && _settings().lazyMode && _mgr.isCorrect(row, col)) {
      _moveToNextCell(context);
    }
  }

  /// Handles the clear button tap event.
  void _onClearButtonTap() {
    // Block clearing if no cell is selected
    if (_selectedRow == null || _selectedCol == null) {
      _showSnackBar(message: 'Cannot clear! Select a cell first!');
      return;
    }

    // If user is in candidate mode, clear those candidates from the cell.
    if (_isCandidateMode) {
      bool ret = _mgr.clearUserCandidates(_selectedRow!, _selectedCol!);
      if (ret) {
        _saveGame();
        setState(() {
          _gridKey = UniqueKey();
        });
      }
      return; // no need to continue.
    }

    // Avoid clearing if the cell is already correct (and checkCorrectness is true)
    // or if the cell is hinted.
    if ((_mgr.isCorrect(_selectedRow!, _selectedCol!) && _settings().checkCorrectness) ||
        _mgr.isHinted(_selectedRow!, _selectedCol!)) {
      _showSnackBar(message: 'Cannot clear! This cell is already correct!');
      return;
    }

    // Clear only if editable
    if (_mgr.isEditable(_selectedRow!, _selectedCol!)) {
      bool ret = _mgr.setValueAt(_selectedRow!, _selectedCol!, null);
      if (ret) {
        _saveGame();
        _selectedValue = null;
        setState(() {
          _gridKey = UniqueKey();
        });
      }
    }

    // Otherwise, there's nothing to do.
  }

  /// Persists the current game state including the timer.
  void _saveGame() {
    if (!_completed && !_mgr.isGameOver && _mgr.isNotEmpty) {
      _mgr.saveGame(_timerMgr.currentValue);
    }
  }

  ///////////////////////////
  ///    USEFUL METHODS   ///
  ///////////////////////////

  /// Moves to the next cell
  void _moveToNextCell(BuildContext context) {
    // Extract whether we should move to the next empty cell,
    // or the next empty or incorrect cell.
    bool conditionalMove = _settings().checkCorrectness;

    // If no cell is selected, default to 0.
    int startIdx = 0;
    if (_selectedRow != null && _selectedCol != null) {
      startIdx = _selectedRow! * _mgr.maxNumber + _selectedCol!;
    }
    int totalCells = _mgr.gridSize;

    for (int i = 1; i < totalCells; i++) {
      int idx = (startIdx + i) % totalCells;
      int r = idx ~/ _mgr.maxNumber;
      int c = idx % _mgr.maxNumber;

      bool editable = _mgr.isEditable(r, c);
      if (!editable) continue;

      int? val = _mgr.getValue(r, c);
      bool correct = _mgr.isCorrect(r, c);

      // If checkCorrectness is on, we move to cells that are not correct.
      // If checkCorrectness is off, we move to cells that are empty (null).
      if (conditionalMove ? !correct : val == null) {
        _onCellTap(r, c);
        return;
      }
    }
  }

  void _resetSelected() {
    _selectedCol = null;
    _selectedRow = null;
    _selectedValue = null;
  }

  /// Retrieves the settings object from the context.
  SettingsManager _settings() => _settingsManager;

  @override
  /// Builds the main Sudoku game screen:
  /// - App bar with title
  /// - Game title and difficulty display
  /// - Game control buttons (hint, settings)
  /// - Sudoku grid with selectable cells
  /// - Number input buttons for cell entry
  /// - Clear cell button (to clear the selected cell)
  /// - Responsive layout with scroll support
  Widget build(BuildContext context) {
    // Initialize the game timer
    _gameTimer = Stopwatch(
      startSeconds: _timerMgr.elapsedSeconds + 0.0,
      countUp: true,
      manager: _timerMgr,
      textStyle: ThemeStyle.mediumGameText(
        context,
      ).copyWith(fontFeatures: [const FontFeature.tabularFigures()]),
      autoStart: true,
    );

    // Track if auto-candidate mode is active at any point.
    if (_settings().autoCandidateMode) {
      _mgr.markAutoCandidateUsed();
    }

    return Scaffold(
      appBar: common.getAppBar(context, 'Sudoku'),
      body: Stack(
        children: [
          common.getBackgroundBlurStack(
            alpha: 50,
            blur: 5.0,
            startColor: ThemeColor.getStartColor(context),
            context,
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    spacing.verticalSpacer,
                    // Game Info row
                    Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 25.0,
                      children: _buildGameRow(context),
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
          if (_completed) const IgnorePointer(child: ConfettiWidget(play: true)),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/core/components/frosted_glass.dart';

import 'package:sudoku/core/components/page_layout.dart';
import 'package:sudoku/core/extensions/string_extensions.dart';
import 'package:sudoku/core/storage/game_storage.dart';
import 'package:sudoku/core/theme/colors.dart';
import 'package:sudoku/core/theme/theme.dart';
import 'package:sudoku/core/theme/text.dart';

import 'package:sudoku/core/components/common.dart' as common;
import 'package:sudoku/core/components/confetti.dart';
import 'package:sudoku/core/components/spacing.dart' as spacing;

import 'package:sudoku/features/game/logic/sudoku_manager.dart';
import 'package:sudoku/features/game/widgets/messenger.dart';
import 'package:sudoku/features/game/widgets/digit_pad.dart';
import 'package:sudoku/features/game/widgets/sudoku_board.dart';
import 'package:sudoku/features/game/widgets/game_widgets.dart' as widgets;
import 'package:sudoku/features/game/widgets/stat_row.dart';
import 'package:sudoku/features/game/widgets/stopwatch.dart';

import 'package:sudoku/features/game/ui/new_game.dart';
import 'package:sudoku/features/settings/logic/settings_manager.dart';

// Other pages for routing
import 'package:sudoku/features/stats/ui/stats.dart';
import 'package:sudoku/features/settings/ui/settings.dart';
import 'package:sudoku/features/help/help.dart';
import 'package:sudoku/features/game/ui/save_game.dart';

/// Represents the main game page for Sudoku.
class GamePage extends StatefulWidget {
  final String? initialSlot;
  final bool forceNewGame;
  final String? difficulty;
  final int? sideLength;
  final String? loadingTip;

  const GamePage({
    super.key,
    this.initialSlot,
    this.forceNewGame = false,
    this.difficulty,
    this.sideLength,
    this.loadingTip,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

/// The state class for the [GamePage] widget.
///
/// Manages the game logic, UI updates, and user interactions for the Sudoku game page.
class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  /// Unique Key ensures that redraws can be triggered upon grid changes.
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

  /// Tracking last move for feedback animations
  int? _lastMoveRow;
  int? _lastMoveCol;
  DateTime? _lastMoveTime;

  /// Whether the puzzle is solved.
  bool _completed = false;

  /// The tip to show during loading.
  late String _currentLoadingTip;

  /// Timer for swapping loading tips.
  Timer? _tipTimer;

  /// Whether the game is currently initializing.
  bool _isInitializing = true;

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

    // Select a tip for the loading screen.
    final tips = SudokuManager.loadingTips;
    _currentLoadingTip = widget.loadingTip ?? tips[math.Random().nextInt(tips.length)];

    // Check if there's a game that exists
    _initGame();
    _startTipTimer();

    // add the observer to listen to app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // select a cell if lazy mode is enabled.
    if (_settings().lazyMode) {
      _moveToNextCell(context);
    }
  }

  /// Starts a periodic timer to rotate through loading tips.
  void _startTipTimer() {
    _tipTimer?.cancel();
    _tipTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && _isInitializing) {
        final tips = SudokuManager.loadingTips;
        String newTip;
        do {
          newTip = tips[math.Random().nextInt(tips.length)];
        } while (newTip == _currentLoadingTip && tips.length > 1);

        setState(() {
          _currentLoadingTip = newTip;
        });
      } else {
        timer.cancel();
      }
    });
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
    _tipTimer?.cancel();
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
    setState(() => _isInitializing = true);

    // Load the stats first.
    await _mgr.loadStats();

    // If difficulty and sideLength are provided via constructor, generate a new game immediately.
    if (widget.difficulty != null && widget.sideLength != null) {
      _mgr.setDifficulty(widget.difficulty!);
      _mgr.setGridSizeFromSideLength(widget.sideLength!);
      await _mgr.generateGame(
        mode: _settings().generationMode,
        onProgress: (p) => setState(() {}),
      );
      _resetSelected();
      _timerMgr.reset();
      _completed = false;
      _saveGame();
      setState(() {
        _isInitializing = false;
        _gridKey = UniqueKey();
      });
      _onCellTap(0, 0);
      if (mounted) _moveToNextCell(context);
      _timerMgr.start();
      return;
    }

    bool ret =
        widget.forceNewGame ? false : await _mgr.loadGame(slot: widget.initialSlot ?? 'auto');
    if (!ret) {
      _newPuzzle();
    } else {
      setState(() {
        _isInitializing = false;
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

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => NewGamePage(
              initialDifficulty: _mgr.difficulty,
              initialSideLength: _mgr.length.toInt(),
            ),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
      ),
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

  /// Returns the data required to build the game control buttons.
  (List<String>, List<IconData>, List<Color>, List<VoidCallback>) _getButtonData(
    BuildContext context,
  ) {
    return (
      ['New Game', 'Save', 'Restart', 'Stats', 'Help', 'Hint', 'Settings'],
      [
        Icons.add,
        Icons.save_outlined,
        Icons.refresh,
        Icons.bar_chart,
        Icons.help_outline,
        Icons.lightbulb,
        Icons.settings,
      ],
      [
        ThemeColor.getNewGameAccentColor(context),
        Colors.blueAccent,
        ThemeColor.getRestartAccentColor(context),
        Colors.purpleAccent,
        ThemeColor.getHelpAccentColor(context),
        ThemeColor.getHintAccentColor(context),
        ThemeColor.getOptionBtnAccentColor(context),
      ],
      [
        _newPuzzle,
        _onSaveButtonTap,
        _onRestartButtonTap,
        _onStatsButtonTap,
        _onHelpButtonTap,
        _onHintButtonTap,
        _onSettingsButtonTap,
      ],
    );
  }

  /// Builds the Sudoku game buttons, like new game, hints, restart, settings, etc.
  List<Widget> _buildSudokuButtons(BuildContext context) {
    final data = _getButtonData(context);

    // Build the widget list.
    List<Widget> widgetList = [];
    for (int i = 0; i < data.$1.length; i++) {
      widgetList.add(
        common.FrostedTooltipIconButton(
          alpha: ThemeValues.alphaStrong,
          blur: ThemeValues.blurStrong,
          borderRadius: ThemeValues.circularRadius,
          borderWidth: ThemeValues.bWidthMid,
          accentColor: data.$3[i],
          startColor: ThemeColor.getIconButtonColor(context),
          icon: data.$2[i],
          label: data.$1[i],
          onPressed: data.$4[i],
        ),
      );
    }

    // Return the built list
    return widgetList;
  }

  /// Builds the Drawer for small screens.
  Widget _buildDrawer(BuildContext context) {
    final data = _getButtonData(context);

    return Drawer(
      backgroundColor: ThemeColor.getStartColor(context),
      child: Column(
        children: [
          DrawerHeader(
            child: Center(child: Text('Sudoku Menu', style: ThemeStyle.subtitle(context))),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: data.$1.length,
              itemBuilder: (context, i) {
                return ListTile(
                  leading: Icon(data.$2[i], color: data.$3[i]),
                  title: Text(data.$1[i], style: ThemeStyle.mediumGameText(context)),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    data.$4[i]();
                  },
                );
              },
            ),
          ),
        ],
      ),
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

    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                SaveGamePage(manager: _mgr, timerManager: _timerMgr),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
      ),
    );

    if (!_completed) {
      _timerMgr.resume();
    }
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
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
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
      _lastMoveRow = _selectedRow;
      _lastMoveCol = _selectedCol;
      _lastMoveTime = DateTime.now();
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
        pageBuilder: (context, animation, secondaryAnimation) => const SettingsPage(),
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
      });
      return;
    }

    // Select the tapped cell.
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
      _selectedValue = _mgr.getValue(row, col);
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
      _lastMoveRow = row;
      _lastMoveCol = col;
      _lastMoveTime = DateTime.now();

      if (_settings().candidateUpdate) {
        if (!_settings().checkCorrectness || _mgr.isCorrect(row, col)) {
          _mgr.removeUserCandidateFromNeighbors(row, col, number);
        }
      }
    });

    // Save the game state after a move.
    _saveGame();

    // If the solution is wrong (and not equal to the original value),
    // Try to check for deadlock, then mark a mistake.
    if (!_mgr.isCorrect(row, col)) {
      // A mistake was made.
      _mgr.mistaken();
      if (_settings().enableHaptics) {
        HapticFeedback.vibrate();
      }

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
        setState(() {});
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
        setState(() {});
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmall = screenWidth < ThemeStyle.bpSM;

    if (_isInitializing) {
      return FrostedScaffold(
        title: 'Sudoku',
        alpha: ThemeValues.alphaMid,
        blur: ThemeValues.blurMid,
        startColor: ThemeColor.getStartColor(context),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.blueAccent),
              spacing.bigVerticalSpacer,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _mgr.generationProgress,
                    minHeight: 10,
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                ),
              ),
              spacing.smallVerticalSpacer,
              Text(
                'Generating... ${(_mgr.generationProgress * 100).toInt()}%',
                style: ThemeStyle.mediumGameText(context),
              ),
              spacing.bigVerticalSpacer,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FrostedIconCard(
                  icon: Icons.tips_and_updates_outlined,
                  text: _currentLoadingTip,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Initialize the game timer
    _gameTimer = Stopwatch(
      startSeconds: _timerMgr.elapsedSeconds + 0.0,
      countUp: true,
      manager: _timerMgr,
      textStyle: (isSmall ? ThemeStyle.smallGameText(context) : ThemeStyle.mediumGameText(context))
          .copyWith(
            fontFeatures: [const FontFeature.tabularFigures()],
            fontWeight: FontWeight.bold,
          ),
      autoStart: true,
    );

    // Track if auto-candidate mode is active at any point.
    if (_settings().autoCandidateMode) {
      _mgr.markAutoCandidateUsed();
    }

    final digitPad = DigitPad(
      maxNumber: _mgr.maxNumber,
      isCandidateMode: _isCandidateMode,
      onModeChanged: (val) => setState(() => _isCandidateMode = val),
      onDigitPressed: (val) => _completed ? null : _onNumberButtonTap(val),
      onClearPressed: () => _completed ? null : _onClearButtonTap(),
      isDigitFull: (val) => _mgr.isFull(val),
      getRemainingCount: (val) => _mgr.getRemainingOf(val),
      enableHaptics: _settings().enableHaptics,
    );

    return FrostedScaffold(
      title: 'Sudoku',
      endDrawer: isSmall ? _buildDrawer(context) : null,
      alpha: ThemeValues.alphaMid,
      blur: ThemeValues.blurMid,
      startColor: ThemeColor.getStartColor(context),
      body: Column(
        children: [
          Expanded(
            child: PageLayout(
              children: <Widget>[
                spacing.bigVerticalSpacer,
                // Game Info row
                GameStatRow(
                  manager: _mgr,
                  settings: _settings(),
                  timerWidget: _gameTimer!,
                  timerManager: _timerMgr,
                  isCompleted: _completed,
                ),
                spacing.verticalSpacer,
                spacing.smallVerticalSpacer,
                if (!isSmall) ...[
                  // Game buttons (hint, settings, etc.)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24.0,
                    runSpacing: 8.0,
                    children: _buildSudokuButtons(context),
                  ),
                ],
                spacing.smallVerticalSpacer,
                // Sudoku Board
                Center(
                  child: SudokuBoard(
                    grid: _mgr.grid,
                    gridKey: _gridKey,
                    selectedRow: _selectedRow,
                    selectedCol: _selectedCol,
                    selectedValue: _selectedValue,
                    lastMoveRow: _lastMoveRow,
                    lastMoveCol: _lastMoveCol,
                    lastMoveTime: _lastMoveTime,
                    checkCorrectness: _settings().checkCorrectness,
                    autoCandidateMode: _settings().autoCandidateMode,
                    generationMode: _settings().generationMode,
                    onCellTap: _onCellTap,
                  ),
                ),
                spacing.bigVerticalSpacer,
                if (!isSmall) ...[digitPad, spacing.massiveVerticalSpacer],
                if (_completed) const IgnorePointer(child: ConfettiWidget(play: true)),
              ],
            ),
          ),
          if (isSmall)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeValues.spacingMid),
              child: digitPad,
            ),
          if (isSmall) spacing.smallVerticalSpacer,
        ],
      ),
    );
  }
}

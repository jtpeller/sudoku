/// Stores the stats of a particular difficulty.
class DifficultyStat {
  /// The number of games played on this difficulty.
  int played = 0;

  /// The number of games won on this difficulty.
  int won = 0;

  /// The number of mistakes made on this difficulty.
  int mistakes = 0;

  /// The number of hints used on this difficulty.
  int hints = 0;

  /// The number of games lost on this difficulty.
  int lost = 0;

  /// The time elapsed while playing this difficulty.
  double totalTime = 0.0;

  /// The time elapsed for successfully solved puzzles.
  double totalSolveTime = 0.0;

  /// The fastest solve time achieved for this difficulty.
  double? bestTime;

  /// The number of games played using auto-candidate mode.
  int autoCandidatePlayed = 0;

  /// The number of games won using auto-candidate mode.
  int autoCandidateWon = 0;

  /// Historical record of win/loss (true = win, false = loss).
  List<bool> history = [];

  /// Builds an empty [DifficultyStat].
  DifficultyStat();

  /// Builds a [DifficultyStat] from the provided [statData].
  factory DifficultyStat.fromMap(Map<String, dynamic> statData) {
    DifficultyStat emptyStat = DifficultyStat();
    emptyStat.played = statData['played'] ?? 0;
    emptyStat.won = statData['won'] ?? 0;
    emptyStat.lost = statData['lost'] ?? 0;
    emptyStat.mistakes = statData['mistakes'] ?? 0;
    emptyStat.hints = statData['hints'] ?? 0;
    emptyStat.totalTime = (statData['totalTime'] ?? 0.0).toDouble();
    emptyStat.totalSolveTime = (statData['totalSolveTime'] ?? 0.0).toDouble();
    emptyStat.bestTime = statData['bestTime']?.toDouble();
    emptyStat.autoCandidatePlayed = statData['autoCandidatePlayed'] ?? 0;
    emptyStat.autoCandidateWon = statData['autoCandidateWon'] ?? 0;
    if (statData['history'] != null) {
      emptyStat.history = List<bool>.from(statData['history']);
    }
    return emptyStat;
  }

  /// Calculates the average solve time (only for won games).
  double get averageSolveTime => won == 0 ? 0.0 : totalSolveTime / won;

  /// Calculates the win rate.
  double get winRate => played == 0 ? 0.0 : won / played;

  /// Converts this [DifficultyStat] to a map.
  Map<String, dynamic> toMap() => {
    'played': played,
    'won': won,
    'lost': lost,
    'mistakes': mistakes,
    'hints': hints,
    'totalTime': totalTime,
    'totalSolveTime': totalSolveTime,
    'bestTime': bestTime,
    'autoCandidatePlayed': autoCandidatePlayed,
    'autoCandidateWon': autoCandidateWon,
    'history': history,
  };
}

/// Stats for a particular Sudoku user.
class SudokuStats {
  /// Map of board side length (e.g., 9) to a map of difficulty names to stats.
  Map<int, Map<String, DifficultyStat>> statsByGridSize = {};

  SudokuStats();

  // /////////////////////////////////////////////////////////////
  //   METRIC MODIFIERS
  // /////////////////////////////////////////////////////////////

  /// Records the end of a game and updates the internal statistics.
  void recordGameEnd({
    required int sideLength,
    required String difficulty,
    required bool won,
    required int mistakes,
    required int hints,
    required double time,
    bool usedAutoCandidate = false,
  }) {
    statsByGridSize.putIfAbsent(sideLength, () => {});
    final diffMap = statsByGridSize[sideLength]!;
    diffMap.putIfAbsent(difficulty, () => DifficultyStat());

    final s = diffMap[difficulty]!;
    s.played++;

    if (usedAutoCandidate) {
      s.autoCandidatePlayed++;
    }

    if (won) {
      s.won++;
      if (usedAutoCandidate) {
        s.autoCandidateWon++;
      }
      s.totalSolveTime += time;

      // Update personal best time
      if (s.bestTime == null || time < s.bestTime!) {
        s.bestTime = time;
      }
    } else {
      s.lost++;
    }
    s.mistakes += mistakes;
    s.hints += hints;
    s.totalTime += time;

    // Track history for the trend line (limit to last 50 games)
    s.history.add(won);
    if (s.history.length > 50) {
      s.history.removeAt(0);
    }
  }

  /// Converts the stats to a JSON object
  Map<String, dynamic> toJson() {
    return statsByGridSize.map((key, value) => MapEntry(
          key.toString(),
          value.map((diff, stat) => MapEntry(diff, stat.toMap())),
        ));
  }

  /// Builds this class from provided map [data].
  factory SudokuStats.fromMap(Map<String, dynamic> data) {
    final s = SudokuStats();
    data.forEach((key, value) {
      final int gridSize = int.parse(key);
      final Map<String, DifficultyStat> diffMap = {};
      (value as Map<String, dynamic>).forEach((diff, statData) {
        diffMap[diff] = DifficultyStat.fromMap(statData);
      });
      s.statsByGridSize[gridSize] = diffMap;
    });
    return s;
  }

  /// Builds this class from provided [json] data.
  factory SudokuStats.fromJson(Map<String, dynamic> json) {
    return SudokuStats.fromMap(json);
  }
}

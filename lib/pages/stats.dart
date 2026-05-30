import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sudoku/data/game_storage.dart';
import 'package:sudoku/game/stats.dart';
import 'package:sudoku/game/difficulty.dart';
import 'package:sudoku/theme/text.dart';
import 'package:sudoku/theme/colors.dart';
import 'package:sudoku/theme/theme.dart';
import 'package:sudoku/widgets/common.dart' as common;
import 'package:sudoku/widgets/frosted_glass.dart';
import 'package:sudoku/widgets/spacing.dart' as spacing;
import 'package:sudoku/extensions/string_extensions.dart';

/// A page that displays Sudoku statistics categorized by grid size and difficulty.
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  SudokuStats? _stats;
  bool _isLoading = true;
  bool _showAutoCandidateOnly = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await GameStorage.loadStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  String _formatTime(double seconds) {
    if (seconds <= 0) return '--:--';
    int hrs = (seconds / 3600).floor();
    int mins = ((seconds % 3600) / 60).floor();
    int secs = (seconds % 60).floor();

    if (hrs > 0) {
      return '${hrs}h ${mins}m';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _resetStats() async {
    bool? firstConfirm = await showAdaptiveDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog.adaptive(
            title: Center(child: Text('Reset Statistics?', style: ThemeStyle.subtitle(context))),
            content: Text(
              'This will permanently delete all your Sudoku progress and records.',
              style: ThemeStyle.smallGameText(context),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: ThemeStyle.smallButtonText(context)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Reset',
                  style: ThemeStyle.smallButtonText(context).copyWith(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (firstConfirm != true) return;
    if (!mounted) return;

    bool? secondConfirm = await showAdaptiveDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog.adaptive(
            title: Center(
              child: Text('Are you absolutely sure?', style: ThemeStyle.subtitle(context)),
            ),
            content: Text(
              'There is no undoing this action.',
              style: ThemeStyle.smallGameText(context),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Go Back', style: ThemeStyle.smallButtonText(context)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'I am sure',
                  style: ThemeStyle.smallButtonText(context).copyWith(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (secondConfirm == true) {
      await GameStorage.clearStats();

      if (!mounted) return;
      _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Get unique grid sizes and sort them
    final gridSizes = {...(_stats?.statsByGridSize.keys ?? []), 4, 6, 9, 12}.toList();
    gridSizes.sort();

    int totalPlayed = 0;
    int totalWon = 0;
    double totalTime = 0.0;
    // Pre-populate with standard grid sizes so they always appear in the chart
    // even if no play time has been recorded for them yet.
    final Map<int, double> timeByGridSize = {4: 0.0, 6: 0.0, 9: 0.0, 12: 0.0};
    int autoCandidateGames = 0;

    _stats?.statsByGridSize.forEach((size, diffMap) {
      double sizeTotalTime = 0.0;
      diffMap.forEach((diff, stat) {
        autoCandidateGames += stat.autoCandidatePlayed;
        totalTime += stat.totalTime;
        sizeTotalTime += stat.totalTime;
        if (_showAutoCandidateOnly) {
          totalPlayed += stat.autoCandidatePlayed;
          totalWon += stat.autoCandidateWon;
        } else {
          totalPlayed += stat.played;
          totalWon += stat.won;
        }
      });
      timeByGridSize[size] = sizeTotalTime;
    });

    return DefaultTabController(
      length: gridSizes.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Statistics', style: ThemeStyle.subtitle(context)),
          centerTitle: true,
          backgroundColor: ThemeColor.getStartColor(context),
          actions: [
            IconButton(icon: const Icon(Icons.delete_forever_outlined), onPressed: _resetStats),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: ThemeColor.getAccentColor(context),
            labelStyle: ThemeStyle.smallButtonText(context),
            tabs: gridSizes.map((size) => Tab(text: '${size}x$size')).toList(),
          ),
        ),
        body: common.getBackgroundBlurStack(
          context,
          Column(
            children: [
              _buildCareerSummary(
                totalPlayed,
                totalWon,
                autoCandidateGames,
                totalTime,
                timeByGridSize,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mode: ${_showAutoCandidateOnly ? "Auto-Candidate Assisted" : "Standard"}',
                      style: ThemeStyle.helperText(context).copyWith(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.auto_fix_high, size: 16),
                        Switch.adaptive(
                          value: _showAutoCandidateOnly,
                          activeThumbColor: ThemeColor.getSwitchThumbOnColor(context),
                          inactiveThumbColor: ThemeColor.getSwitchThumbOffColor(context),
                          activeTrackColor: ThemeColor.getSwitchTrackOnColor(context),
                          inactiveTrackColor: ThemeColor.getSwitchTrackOffColor(context),
                          onChanged: (val) => setState(() => _showAutoCandidateOnly = val),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: gridSizes.map((size) => _buildGridSizeStats(size)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCareerSummary(
    int totalPlayed,
    int totalWon,
    int autoGames,
    double totalTime,
    Map<int, double> timeByGridSize,
  ) {
    final double winRate = totalPlayed > 0 ? (totalWon / totalPlayed) : 0.0;
    final String title =
        _showAutoCandidateOnly ? 'Auto-Assisted Summary' : 'Overall Career Summary';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: FrostedGlassBox(
        alpha: ThemeValues.alphaStrong,
        blur: ThemeValues.blurStrong,
        borderRadius: 20,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: ThemeStyle.mediumGameText(context).copyWith(fontWeight: FontWeight.bold),
              ),
              spacing.verticalSpacer,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryStat(
                    _showAutoCandidateOnly ? 'Assisted Games' : 'Total Games',
                    totalPlayed.toString(),
                  ),
                  _buildSummaryStat('Win Rate', '${(winRate * 100).toStringAsFixed(1)}%'),
                  _buildSummaryStat('Play Time', _formatTime(totalTime)),
                  // Only show the career auto-assisted count if we aren't already filtered to that mode.
                  if (!_showAutoCandidateOnly)
                    _buildSummaryStat('Auto-Assisted', autoGames.toString()),
                ],
              ),
              if (timeByGridSize.isNotEmpty) ...[
                spacing.verticalSpacer,
                _buildSectionHeader(context, 'Time Distribution by Grid'),
                const SizedBox(height: 8),
                _PlayTimeChart(timeData: timeByGridSize),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: ThemeStyle.mediumGameText(
            context,
          ).copyWith(color: ThemeColor.getAccentColor(context), fontWeight: FontWeight.bold),
        ),
        Text(label, style: ThemeStyle.helperText(context)),
      ],
    );
  }

  Widget _buildGridSizeStats(int gridSize) {
    final diffStats = _stats?.statsByGridSize[gridSize] ?? {};
    final difficulties = Difficulty.values;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: difficulties.length,
      itemBuilder: (context, index) {
        final diff = difficulties[index];
        final diffName = diff.name;
        final stat = diffStats[diffName] ?? DifficultyStat();
        final int played = _showAutoCandidateOnly ? stat.autoCandidatePlayed : stat.played;
        final int won = _showAutoCandidateOnly ? stat.autoCandidateWon : stat.won;
        final bool isUnplayed = played == 0;
        final double winRate = !isUnplayed ? (won / played) : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Opacity(
            opacity: isUnplayed ? 0.6 : 1.0,
            child: FrostedGlassBox(
              alpha: ThemeValues.alphaWeak,
              blur: ThemeValues.blurWeak,
              borderRadius: 16,
              child: ExpansionTile(
                enabled: !isUnplayed,
                shape: const RoundedRectangleBorder(side: BorderSide.none),
                title: Text(
                  diffName.capitalize(),
                  style: ThemeStyle.mediumGameText(context).copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  isUnplayed
                      ? 'No games played yet'
                      : 'Win Rate: ${(winRate * 100).toStringAsFixed(1)}% | Played: $played',
                  style: ThemeStyle.helperText(context),
                ),
                trailing:
                    isUnplayed
                        ? const Icon(Icons.lock_outline, size: 20)
                        : const Icon(Icons.expand_more),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        spacing.buildThinDivider(context),
                        if (stat.history.isNotEmpty) ...[
                          _buildSectionHeader(context, 'Win Rate Trend'),
                          _WinRateTrend(history: stat.history),
                          spacing.verticalSpacer,
                        ],
                        _buildStatRow('Games Won', stat.won.toString()),
                        _buildStatRow('Games Lost', stat.lost.toString()),
                        _buildStatRow(
                          'Personal Best',
                          _formatTime(stat.bestTime ?? 0.0),
                          icon: Icons.emoji_events_outlined,
                          valueColor: Colors.amber,
                        ),
                        _buildStatRow('Average Solve Time', _formatTime(stat.averageSolveTime)),
                        _buildStatRow('Total Mistakes', stat.mistakes.toString()),
                        _buildStatRow('Total Hints Used', stat.hints.toString()),
                        _buildStatRow('Total Play Time', _formatTime(stat.totalTime)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: ThemeStyle.helperText(context).copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {IconData? icon, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: valueColor ?? ThemeColor.getAccentColor(context)),
                const SizedBox(width: 8),
              ],
              Text(label, style: ThemeStyle.smallGameText(context)),
            ],
          ),
          Text(
            value,
            style: ThemeStyle.smallGameText(context).copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? ThemeColor.getAccentColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget that paints a trend line of the win rate over time.
class _WinRateTrend extends StatelessWidget {
  final List<bool> history;

  const _WinRateTrend({required this.history});

  @override
  Widget build(BuildContext context) {
    final accentColor = ThemeColor.getAccentColor(context);

    return Container(
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CustomPaint(
        painter: _TrendPainter(
          history: history,
          lineColor: accentColor,
          fillColor: accentColor.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<bool> history;
  final Color lineColor;
  final Color fillColor;

  _TrendPainter({required this.history, required this.lineColor, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final List<double> winRates = [];
    int winCount = 0;
    for (int i = 0; i < history.length; i++) {
      if (history[i]) winCount++;
      winRates.add(winCount / (i + 1));
    }

    final path = Path();
    final fillPath = Path();
    final double stepX = history.length > 1 ? size.width / (history.length - 1) : size.width;

    for (int i = 0; i < winRates.length; i++) {
      final x = i * stepX;
      final y = size.height - (winRates[i] * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      if (i == winRates.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    if (winRates.isNotEmpty) {
      final lastX = (winRates.length - 1) * stepX;
      final lastY = size.height - (winRates.last * size.height);
      canvas.drawCircle(
        Offset(lastX, lastY),
        3.0,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// A simple bar chart to visualize play time per grid size.
class _PlayTimeChart extends StatelessWidget {
  final Map<int, double> timeData;

  const _PlayTimeChart({required this.timeData});

  String _formatTimeShort(double seconds) {
    if (seconds <= 0) return '0m';
    int hrs = (seconds / 3600).floor();
    int mins = ((seconds % 3600) / 60).floor();
    if (hrs > 0) return '${hrs}h ${mins}m';
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    if (timeData.isEmpty) return const SizedBox.shrink();

    final sortedSizes = timeData.keys.toList()..sort();
    final maxTime = timeData.values.reduce(math.max);
    final accentColor = ThemeColor.getAccentColor(context);

    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children:
            sortedSizes.map((size) {
              final time = timeData[size]!;
              // Calculate height ratio based on max time spent in any grid size
              final double ratio = maxTime > 0 ? (time / maxTime) : 0.0;

              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatTimeShort(time),
                      style: ThemeStyle.helperText(context).copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 30,
                      height: (ratio * 50).clamp(4.0, 50.0),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.8),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${size}x$size',
                      style: ThemeStyle.helperText(context).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}

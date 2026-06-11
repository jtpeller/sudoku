import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sudoku/core/storage/game_storage.dart';
import 'package:sudoku/features/stats/logic/stats.dart';
import 'package:sudoku/features/game/logic/difficulty.dart';
import 'package:sudoku/core/theme/text.dart';
import 'package:sudoku/core/theme/colors.dart';
import 'package:sudoku/core/theme/theme.dart';
import 'package:sudoku/core/components/common.dart' as common;
import 'package:sudoku/core/components/frosted_glass.dart';
import 'package:sudoku/core/components/spacing.dart' as spacing;
import 'package:sudoku/core/extensions/string_extensions.dart';

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
  final ScrollController _tabScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.blue;
      case 'hard':
        return Colors.orange;
      case 'expert':
        return Colors.red;
      case 'insane':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showAutoCandidateInfo() {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text('Statistics Filtering', style: ThemeStyle.subtitle(context)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assisted Mode:',
                  style: ThemeStyle.smallGameText(context).copyWith(fontWeight: FontWeight.bold)),
              Text(
                'Filters records to only show games where "Auto-Candidate" mode was used at any point. '
                'This allows you to see how your speed and win rate differ when receiving help.',
                style: ThemeStyle.smallGameText(context),
              ),
              const SizedBox(height: 12),
              Text('Standard Mode:',
                  style: ThemeStyle.smallGameText(context).copyWith(fontWeight: FontWeight.bold)),
              Text('Displays statistics for all other games played.',
                  style: ThemeStyle.smallGameText(context)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it', style: ThemeStyle.smallButtonText(context)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const FrostedScaffold(body: Center(child: CircularProgressIndicator()));
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
    final Set<int> playedSizes = {};

    _stats?.statsByGridSize.forEach((size, diffMap) {
      double sizeTotalTime = 0.0;
      bool sizeHasPlayed = false;
      diffMap.forEach((diff, stat) {
        autoCandidateGames += stat.autoCandidatePlayed;
        totalTime += stat.totalTime;
        sizeTotalTime += stat.totalTime;
        if (_showAutoCandidateOnly) {
          totalPlayed += stat.autoCandidatePlayed;
          totalWon += stat.autoCandidateWon;
          if (stat.autoCandidatePlayed > 0) sizeHasPlayed = true;
        } else {
          totalPlayed += stat.played;
          totalWon += stat.won;
          if (stat.played > 0) sizeHasPlayed = true;
        }
      });
      timeByGridSize[size] = sizeTotalTime;
      if (sizeHasPlayed) playedSizes.add(size);
    });

    return DefaultTabController(
      length: gridSizes.length,
      child: Scaffold(
        appBar: common.getAppBar(
          context,
          'Statistics',
          actions: [
            IconButton(icon: const Icon(Icons.delete_forever_outlined), onPressed: _resetStats),
          ],
        ),
        body: common.FrostedBlurStack(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Column(
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
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        children: [
                          _buildModeLabel(context),
                          _buildModeSwitch(context),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                elevation: 2,
                toolbarHeight: 0,
                bottom: _buildTabBar(context, gridSizes, playedSizes),
              ),
            ],
            body: TabBarView(
              children: gridSizes.map((size) => _buildGridSizeStats(size)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTabBar(BuildContext context, List<dynamic> gridSizes, Set<int> playedSizes) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: ThemeColor.getAppBarColor(context),
          border: Border(
            bottom: BorderSide(
              color: ThemeColor.getTextBodyColor(context).withValues(alpha: 0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              visualDensity: VisualDensity.adaptivePlatformDensity,
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                if (_tabScrollController.hasClients) {
                  _tabScrollController.animateTo(
                    math.max(0, _tabScrollController.offset - 100),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                key: const PageStorageKey('stats_tab_scroll_view'),
                primary: false,
                controller: _tabScrollController,
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: IntrinsicWidth(
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    isScrollable: false,
                    indicatorColor: ThemeColor.getAccentColor(context),
                    labelColor: ThemeColor.getAccentColor(context),
                    unselectedLabelColor: ThemeColor.getTextBodyColor(context),
                    labelStyle: ThemeStyle.smallButtonText(context).copyWith(fontWeight: FontWeight.bold),
                    tabs: gridSizes.map((size) {
                      final bool hasPlayed = playedSizes.contains(size);
                      return Tab(
                        child: Opacity(
                          opacity: hasPlayed ? 1.0 : 0.4,
                          child: Text('${size}x$size Grid'),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                if (_tabScrollController.hasClients) {
                  _tabScrollController.animateTo(
                    math.min(_tabScrollController.position.maxScrollExtent, _tabScrollController.offset + 100),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeLabel(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Mode: ${_showAutoCandidateOnly ? "Assisted" : "Standard"}',
          style: ThemeStyle.helperText(context).copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.info_outline, size: 18, color: ThemeColor.getAccentColor(context)),
          onPressed: _showAutoCandidateInfo,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildModeSwitch(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
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
        _showAutoCandidateOnly ? 'Assisted' : 'Career Summary';

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
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 16,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: ThemeStyle.mediumGameText(
            context,
          ).copyWith(color: ThemeColor.getAccentColor(context), fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(label, style: ThemeStyle.helperText(context), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildGridSizeStats(int gridSize) {
    final diffStats = _stats?.statsByGridSize[gridSize] ?? {};
    final difficulties = Difficulty.values;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Ensure cards don't exceed screen width on narrow devices
        final double cardWidth = math.min(350.0, constraints.maxWidth - 32);

        return SingleChildScrollView(
          primary: false,
          padding: const EdgeInsets.all(16.0),
          child: Center(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: difficulties.map((diff) {
            final diffName = diff.name;
            final stat = diffStats[diffName] ?? DifficultyStat();
            final int played = _showAutoCandidateOnly ? stat.autoCandidatePlayed : stat.played;
            final int won = _showAutoCandidateOnly ? stat.autoCandidateWon : stat.won;
            final bool isUnplayed = played == 0;
            final double winRate = !isUnplayed ? (won / played) : 0.0;
            final Color diffColor = _getDifficultyColor(diffName);

            return SizedBox(
              width: cardWidth,
              child: Opacity(
                opacity: isUnplayed ? 0.6 : 1.0,
                child: FrostedGlassBox(
                  alpha: ThemeValues.alphaWeak,
                  blur: ThemeValues.blurWeak,
                  borderRadius: 16,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isUnplayed ? Icons.emoji_events_outlined : Icons.emoji_events,
                              color: isUnplayed ? Colors.grey : diffColor,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    diffName.capitalize(),
                                    style: ThemeStyle.mediumGameText(
                                      context,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    isUnplayed
                                        ? 'No games played yet'
                                        : 'Win Rate: ${(winRate * 100).toStringAsFixed(1)}% | Played: $played',
                                    style: ThemeStyle.helperText(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (!isUnplayed) ...[
                          const SizedBox(height: 12),
                          spacing.buildThinDivider(context),
                          const SizedBox(height: 8),
                          _buildStatRow('Games Won', won.toString(), icon: Icons.check_circle_outline,
                                iconColor: ThemeColor.getCellCorrectColor(context),
                              ),
                          _buildStatRow(
                            'Games Lost',
                            (_showAutoCandidateOnly ? (played - won) : stat.lost).toString(),
                            icon: Icons.cancel_outlined,
                            iconColor: ThemeColor.getCellWrongColor(context)
                          ),
                          _buildStatRow(
                            'Personal Best',
                            _formatTime(stat.bestTime ?? 0.0),
                            icon: Icons.star_outline,
                            valueColor: Colors.amber,
                            iconColor: Colors.amber
                          ),
                          _buildStatRow(
                            'Average Solve Time',
                            _formatTime(stat.averageSolveTime),
                            icon: Icons.av_timer_outlined,
                          ),
                          _buildStatRow('Total Mistakes', stat.mistakes.toString(), icon: Icons.error_outline, iconColor: ThemeColor.getCellWrongColor(context)),
                          _buildStatRow('Total Hints Used', stat.hints.toString(), icon: Icons.lightbulb_outline, iconColor: ThemeColor.getHintAccentColor(context)),
                          _buildStatRow('Total Play Time', _formatTime(stat.totalTime), icon: Icons.history),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
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

  Widget _buildStatRow(String label, String value, {IconData? icon, Color? valueColor, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: iconColor ?? ThemeColor.getTextBodyColor(context)),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: ThemeStyle.smallGameText(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: ThemeStyle.smallGameText(context).copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? ThemeColor.getTextBodyColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple bar chart to visualize play time per grid size.
class _PlayTimeChart extends StatelessWidget {
  final Map<int, double> timeData;

  const _PlayTimeChart({required this.timeData});

  String _formatTimeShort(double seconds) {
    if (seconds <= 0) return '0s';
    int hrs = (seconds / 3600).floor();
    int mins = ((seconds % 3600) / 60).floor();
    int secs = (seconds % 60).floor();

    if (hrs > 0) return '${hrs}h ${mins}m';
    if (mins > 0) return '${mins}m ${secs}s';
    return '${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    if (timeData.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final sortedSizes = timeData.keys.toList()..sort();
        final accentColor = ThemeColor.getAccentColor(context);

        // If the container is too narrow, switch to a text-based summary.
        if (constraints.maxWidth < 300) {
          final playedSizes = sortedSizes.where((size) => timeData[size]! > 0).toList();

          if (playedSizes.isEmpty) {
            return Center(
              child: Text('No play time recorded yet', style: ThemeStyle.helperText(context)),
            );
          }

          return Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 12,
            children:
                playedSizes.map((size) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${size}x$size',
                        style: ThemeStyle.helperText(context).copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatTimeShort(timeData[size]!),
                        style: ThemeStyle.helperText(
                          context,
                        ).copyWith(color: accentColor, fontSize: 12),
                      ),
                    ],
                  );
                }).toList(),
          );
        }

        final maxTime = timeData.values.reduce(math.max);

        return SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children:
                sortedSizes.map((size) {
                  final time = timeData[size]!;
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
                          style: ThemeStyle.helperText(
                            context,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        );
      },
    );
  }
}

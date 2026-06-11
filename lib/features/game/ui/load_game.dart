import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sudoku/core/components/common.dart' as common;
import 'package:sudoku/core/components/frosted_glass.dart';
import 'package:sudoku/core/components/page_layout.dart';
import 'package:sudoku/core/components/spacing.dart' as spacing;
import 'package:sudoku/core/extensions/string_extensions.dart';
import 'package:sudoku/core/storage/game_storage.dart';
import 'package:sudoku/core/theme/colors.dart';
import 'package:sudoku/core/theme/text.dart';
import 'package:sudoku/core/theme/theme.dart';
import 'package:sudoku/features/game/ui/game.dart';
import 'package:sudoku/features/game/widgets/messenger.dart';

/// A dedicated page for loading a previously saved Sudoku game.
class LoadGamePage extends StatefulWidget {
  const LoadGamePage({super.key});

  @override
  State<LoadGamePage> createState() => _LoadGamePageState();
}

class _LoadGamePageState extends State<LoadGamePage> {
  List<Map<String, dynamic>?> _slots = [null, null, null, null];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final slots = await Future.wait([
      GameStorage.loadSave(slot: '1'),
      GameStorage.loadSave(slot: '2'),
      GameStorage.loadSave(slot: '3'),
      GameStorage.loadSave(slot: 'auto'),
    ]);
    if (mounted) {
      setState(() {
        _slots = slots;
        _loading = false;
      });
    }
  }

  Future<void> _handleDelete(int index) async {
    final String slotId = index == 3 ? 'auto' : '${index + 1}';
    final String title = index == 3 ? 'Auto-Save' : 'Slot ${index + 1}';

    final bool? confirm = await showAdaptiveDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog.adaptive(
            title: const Text('Delete Save?'),
            content: Text('Are you sure you want to delete the save in $title?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: ThemeStyle.smallButtonText(context).copyWith(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await GameStorage.clear(slot: slotId);
      if (mounted) {
        GameFeedbackMessenger.showStatus(context, 'Save deleted from $title');
        _loadSlots();
      }
    }
  }

  String _formatTimestamp(String? isoString) {
    if (isoString == null) return 'No date info';
    final DateTime dt = DateTime.parse(isoString).toLocal();
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatElapsedTime(double seconds) {
    int mins = (seconds / 60).floor();
    int secs = (seconds % 60).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return FrostedScaffold(
      appBar: common.getAppBar(context, 'Load Game'),
      alpha: ThemeValues.alphaMid,
      blur: ThemeValues.blurStrong,
      startColor: ThemeColor.getStartColor(context),
      body: PageLayout(
        children: [
          spacing.bigVerticalSpacer,
          Text(
            'Select a game to resume',
            style: ThemeStyle.subtitle(context),
            textAlign: TextAlign.center,
          ),
          spacing.verticalSpacer,
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            ...List.generate(4, (index) {
              final data = _slots[index];
              final bool isEmpty = data == null;
              final String slotId = index == 3 ? 'auto' : '${index + 1}';
              final String title = index == 3 ? 'Auto-Save' : 'Slot ${index + 1}';
              final int gridSize = data?['gridSize'] ?? 81;
              final int sideLength = sqrt(gridSize).toInt();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Card(
                  color: ThemeColor.getIconButtonColor(context).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeValues.circularRadius),
                    side: BorderSide(
                      color: ThemeColor.getAccentColor(context).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeValues.circularRadius),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Icon(
                      index == 3 ? Icons.auto_awesome : Icons.save,
                      color: isEmpty ? Colors.grey : Colors.blueAccent,
                      size: 32,
                    ),
                    title: Text(
                      title,
                      style: ThemeStyle.mediumGameText(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      isEmpty
                          ? 'Empty Slot'
                          : 'Saved: ${_formatTimestamp(data['timestamp'])}\n${(data['difficulty'] as String? ?? 'unknown').capitalize()} | ${sideLength}x$sideLength | ${_formatElapsedTime((data['elapsedTime'] ?? 0.0).toDouble())}',
                      style: ThemeStyle.helperText(context),
                    ),
                    onTap:
                        isEmpty
                            ? null
                            : () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation, secondaryAnimation) =>
                                          GamePage(initialSlot: slotId),
                                  transitionsBuilder:
                                      (context, animation, secondaryAnimation, child) =>
                                          FadeTransition(opacity: animation, child: child),
                                ),
                              );
                            },
                    trailing:
                        isEmpty
                            ? null
                            : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _handleDelete(index),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                  ),
                ),
              );
            }),
          spacing.massiveVerticalSpacer,
        ],
      ),
    );
  }
}

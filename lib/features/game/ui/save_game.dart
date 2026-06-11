import 'package:flutter/material.dart';
import 'package:sudoku/core/components/common.dart' as common;
import 'package:sudoku/core/components/frosted_glass.dart';
import 'package:sudoku/core/components/page_layout.dart';
import 'package:sudoku/core/components/spacing.dart' as spacing;
import 'package:sudoku/core/storage/game_storage.dart';
import 'package:sudoku/core/theme/colors.dart';
import 'package:sudoku/core/theme/text.dart';
import 'package:sudoku/core/theme/theme.dart';
import 'package:sudoku/features/game/logic/sudoku_manager.dart';
import 'package:sudoku/features/game/widgets/messenger.dart';
import 'package:sudoku/features/game/widgets/stopwatch.dart';

/// A dedicated page for saving the current Sudoku game into one of several slots.
class SaveGamePage extends StatefulWidget {
  final SudokuManager manager;
  final StopwatchManager timerManager;

  const SaveGamePage({super.key, required this.manager, required this.timerManager});

  @override
  State<SaveGamePage> createState() => _SaveGamePageState();
}

class _SaveGamePageState extends State<SaveGamePage> {
  List<Map<String, dynamic>?> _slots = [null, null, null];
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
    ]);
    if (mounted) {
      setState(() {
        _slots = slots;
        _loading = false;
      });
    }
  }

  Future<void> _handleSave(int index) async {
    final String slotId = '${index + 1}';
    final String title = 'Slot $slotId';
    final bool isEmpty = _slots[index] == null;

    bool proceed = true;
    if (!isEmpty) {
      proceed =
          await showAdaptiveDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog.adaptive(
                  title: const Text('Overwrite Save?'),
                  content: Text('Are you sure you want to overwrite the save in $title?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Overwrite'),
                    ),
                  ],
                ),
          ) ??
          false;
    }

    if (proceed) {
      await widget.manager.saveGame(widget.timerManager.currentValue, slot: slotId);
      if (mounted) {
        GameFeedbackMessenger.showStatus(context, 'Game saved to $title');
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handleDelete(int index) async {
    final String slotId = '${index + 1}';
    final bool? confirm = await showAdaptiveDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog.adaptive(
            title: const Text('Delete Save?'),
            content: Text('Are you sure you want to delete the save in Slot $slotId?'),
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
        GameFeedbackMessenger.showStatus(context, 'Save deleted from Slot $slotId');
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

  @override
  Widget build(BuildContext context) {
    return FrostedScaffold(
      appBar: common.getAppBar(context, 'Save Game'),
      alpha: ThemeValues.alphaMid,
      blur: ThemeValues.blurStrong,
      startColor: ThemeColor.getStartColor(context),
      body: PageLayout(
        children: [
          spacing.bigVerticalSpacer,
          Text(
            'Choose a save slot',
            style: ThemeStyle.subtitle(context),
            textAlign: TextAlign.center,
          ),
          spacing.verticalSpacer,
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            ...List.generate(3, (index) {
              final data = _slots[index];
              final bool isEmpty = data == null;
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
                      isEmpty ? Icons.save_alt_outlined : Icons.save,
                      color: isEmpty ? Colors.grey : Colors.blueAccent,
                      size: 32,
                    ),
                    title: Text(
                      'Slot ${index + 1}',
                      style: ThemeStyle.mediumGameText(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      isEmpty
                          ? 'Empty Slot'
                          : 'Saved: ${_formatTimestamp(data['timestamp'])}\n${data['difficulty'] ?? 'Unknown'} - ${data['gridSize'] ?? '??'} cells',
                      style: ThemeStyle.helperText(context),
                    ),
                    onTap: () => _handleSave(index),
                    trailing:
                        isEmpty
                            ? const Icon(Icons.chevron_right)
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

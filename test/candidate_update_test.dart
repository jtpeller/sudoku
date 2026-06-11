import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/logic/sudoku_manager.dart';
import 'package:sudoku/features/settings/logic/settings_manager.dart';

void main() {
  group('SettingsManager Candidate Update Option Tests', () {
    test('default value is false', () {
      final settings = SettingsManager();
      expect(settings.candidateUpdate, isFalse);
    });

    test('toggle setting updates value and notifies', () {
      final settings = SettingsManager();
      bool notified = false;
      settings.addListener(() {
        notified = true;
      });

      settings.setCandidateUpdate(true);
      expect(settings.candidateUpdate, isTrue);
      expect(notified, isTrue);
    });

    test('resetToDefaults resets candidateUpdate to false', () {
      final settings = SettingsManager();
      settings.setCandidateUpdate(true);
      expect(settings.candidateUpdate, isTrue);

      settings.resetToDefaults();
      expect(settings.candidateUpdate, isFalse);
    });

    test('toJson and loadFromMap serializes/deserializes correctly', () {
      final settings = SettingsManager();
      settings.setCandidateUpdate(true);

      final json = settings.toJson();
      expect(json['candidateUpdate'], isTrue);

      final loadedSettings = SettingsManager();
      loadedSettings.loadFromMap({'candidateUpdate': true});
      expect(loadedSettings.candidateUpdate, isTrue);

      loadedSettings.loadFromMap({'candidateUpdate': false});
      expect(loadedSettings.candidateUpdate, isFalse);
    });
  });

  group('SudokuManager Candidate Update Logic Tests', () {
    late SudokuManager manager;

    setUp(() {
      manager = SudokuManager();
      manager.setGridSizeFromSideLength(9);
      manager.generateGame(seed: 42);
    });

    test('removeUserCandidateFromNeighbors removes value from neighbor cells', () {
      // Find an editable cell
      int? row;
      int? col;
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (manager.isEditable(r, c)) {
            row = r;
            col = c;
            break;
          }
        }
        if (row != null) break;
      }

      expect(row, isNotNull);
      expect(col, isNotNull);

      final neighbors = manager.getScope(row!, col!);
      expect(neighbors, isNotEmpty);

      // Add a test candidate to the neighbors
      const testVal = 7;
      for (var pos in neighbors) {
        manager.grid.get(pos.$1, pos.$2).userCandidates.add(testVal);
      }

      // Verify candidates are added
      for (var pos in neighbors) {
        expect(manager.grid.get(pos.$1, pos.$2).userCandidates.contains(testVal), isTrue);
      }

      // Execute remove from neighbors
      manager.removeUserCandidateFromNeighbors(row, col, testVal);

      // Verify they are removed
      for (var pos in neighbors) {
        expect(manager.grid.get(pos.$1, pos.$2).userCandidates.contains(testVal), isFalse);
      }
    });
  });
}

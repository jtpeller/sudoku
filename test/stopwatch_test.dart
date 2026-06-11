import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/features/game/widgets/stopwatch.dart';

void main() {
  group('StopwatchManager Logic Tests', () {
    test('initializes with default values', () {
      final manager = StopwatchManager();
      expect(manager.currentValue, 0.0);
      expect(manager.isRunning(), isFalse);
      expect(manager.isPaused(), isFalse);
      expect(manager.getState(), isNull);
    });

    test('manages state transitions without attached widget', () {
      // This tests the manager's ability to "buffer" state before the UI builds
      final manager = StopwatchManager();

      manager.start();
      expect(manager.getState(), StopwatchStatus.running);
      expect(manager.isRunning(), isTrue);

      manager.pause();
      expect(manager.getState(), StopwatchStatus.paused);

      manager.resume();
      expect(manager.getState(), StopwatchStatus.running);

      manager.stop();
      expect(manager.getState(), StopwatchStatus.stopped);
    });

    test('reset sets values correctly', () {
      final manager = StopwatchManager();
      
      manager.reset(seconds: 45.5);
      expect(manager.currentValue, 45.5);
      expect(manager.getState(), StopwatchStatus.stopped);
    });

    test('isPaused and isStopped logic', () {
      final manager = StopwatchManager();
      
      // Before state attachment, these check the _status variable
      manager.pause();
      expect(manager.getState(), StopwatchStatus.paused);
      
      manager.stop();
      expect(manager.getState(), StopwatchStatus.stopped);

      // Now correctly checks _status as a fallback
      expect(manager.isStopped(), isTrue); 
    });
  });
}
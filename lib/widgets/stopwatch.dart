import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Enum to represent Timer status
enum StopwatchStatus { stopped, running, paused, completed, invalid }

/// A simple widget that can count up or down infinitely
///
/// Can be paused / resumed, reset, and set.
class Stopwatch extends StatefulWidget {
  /// Starting point in seconds.
  final double startSeconds;

  /// Number of seconds that have elapsed
  final double elapsedSeconds;

  /// Whether to count up (1, 2, 3...) `true` or count down (10, 9, 8, ...) `false`
  final bool countUp;

  /// Whether the timer should start immediately.
  final bool autoStart;

  /// Timer's delimiter, for how things are separated
  final String delimiter;

  /// TextStyle for timer text.
  final TextStyle? textStyle;

  /// How the timer seconds will be displayed.
  final String? textFormat;

  /// Callback for startup
  final VoidCallback? onStart;

  /// Callback for completion
  final VoidCallback? onComplete;

  /// manager, which must be saved in the widget so the TimerState may provide it
  /// necessary values for initialization.
  final StopwatchManager manager;

  Stopwatch({
    super.key,
    required this.startSeconds,
    required this.countUp,
    required this.manager,
    this.autoStart = true,
    this.delimiter = ':',
    this.elapsedSeconds = 0.0,
    this.textStyle,
    this.textFormat,
    this.onStart,
    this.onComplete,
  });

  @override
  State<StatefulWidget> createState() => _StopwatchState();
}

class _StopwatchState extends State<Stopwatch> with TickerProviderStateMixin {
  late Ticker _ticker;
  Duration _baseTime = Duration.zero;
  Duration _sessionTime = Duration.zero;
  StopwatchStatus _timerStatus = StopwatchStatus.stopped;

  /// The status of this stopwatch.
  StopwatchStatus get timerStatus => _timerStatus;

  String get time => parse(currentDuration);

  /// Returns the Duration value that has elapsed.
  Duration get currentDuration {
    if (widget.countUp) {
      return _baseTime + _sessionTime;
    }

    Duration remaining = _baseTime - _sessionTime;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Retrieves the current value of the timer.
  double get value => currentDuration.inMicroseconds / 1000000.0;

  /// Set the current elapsed seconds to the [seconds] provided.
  void setSeconds(double seconds) {
    widget.manager.elapsedSeconds = seconds;
    _baseTime = Duration(microseconds: (seconds * 1000000).toInt());
    _sessionTime = Duration.zero;
    if (_ticker.isActive) _ticker.stop();
    setState(() {});
  }

  /// Set the current elapsed seconds to the [time] provided.
  void setNewTime(DateTime time) {
    if (widget.manager.elapsedSeconds == 0.0) {
      setSeconds(DateTime.now().difference(time).inSeconds.toDouble());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      style: widget.textStyle ?? const TextStyle(fontSize: 16.0, color: Colors.black),
    );
  }

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((elapsedTime) {
      _sessionTime = elapsedTime;
      setState(() {});
      if (!widget.countUp && currentDuration == Duration.zero) {
        if (_timerStatus == StopwatchStatus.running) {
          _onComplete();
          stop();
        }
      }
    });

    widget.manager._state = this;

    // If the manager has a saved status (e.g., from a previous state during a rebuild),
    // restore it. Otherwise, follow the widget's autoStart policy.
    if (widget.manager._status != null) {
      _timerStatus = widget.manager._status!;
      _baseTime = Duration(microseconds: (widget.manager.elapsedSeconds * 1000000).toInt());
      if (_timerStatus == StopwatchStatus.running) {
        _resume();
      }
    } else {
      widget.manager.elapsedSeconds = widget.startSeconds;
      if (widget.autoStart) {
        start(startSeconds: widget.startSeconds);
      }
    }
  }

  @override
  void dispose() {
    // Store state in manager so it can be restored if the widget is recreated.
    widget.manager.elapsedSeconds = value;
    widget.manager._status = _timerStatus;
    widget.manager._state = null;
    _ticker.dispose();
    super.dispose();
  }

  /// Begin the timer for the first time.
  ///
  /// Does nothing if the timer is already 'running'.
  void start({double? startSeconds}) {
    if (_timerStatus != StopwatchStatus.running) {
      if (startSeconds != null) {
        _baseTime = Duration(microseconds: (startSeconds * 1000000).toInt());
      }
      _sessionTime = Duration.zero;
      _timerStatus = StopwatchStatus.running;
      _ticker.start();

      // Call the on start
      widget.onStart?.call();
      setState(() {});
    }
  }

  /// Temporarily stop the timer's counting.
  ///
  /// Does nothing if the state is not 'running'.
  void pause() {
    if (_timerStatus == StopwatchStatus.running) {
      _baseTime = currentDuration;
      _sessionTime = Duration.zero;
      _ticker.stop();
      _timerStatus = StopwatchStatus.paused;
      widget.manager._status = _timerStatus;
      setState(() {});
    }
  }

  /// Un-pause a timer that is currently paused.
  ///
  /// Does nothing if the state is not 'paused'.
  void resume() {
    // Allow resuming from paused or stopped (which happens after a reset during game load)
    if (_timerStatus == StopwatchStatus.paused ||
        _timerStatus == StopwatchStatus.stopped) {
      _timerStatus = StopwatchStatus.running;
      widget.manager._status = _timerStatus;
      _resume();
      setState(() {});
    }
  }

  void _resume() {
    _ticker.start();
  }

  /// Stop the timer, putting it in a stopped state.
  void stop() {
    _ticker.stop();
    _baseTime = Duration.zero;
    _sessionTime = Duration.zero;
    _timerStatus = StopwatchStatus.stopped;
    setState(() {});
  }

  /// Parses the provided [duration] into [format].
  ///
  /// [Duration] is parsed, and the optional [delimiter] is used as breaks if applicable.
  ///
  /// Returns the formatted String (Ex: "05:44:13" if format is "HH:MM:SS")
  String parse(Duration duration, {String delimiter = ':'}) {
    String hours = duration.inHours.toString();
    String minutes = (duration.inMinutes % 60).toString();
    String seconds = (duration.inSeconds % 60).toString();

    String hoursPadded = hours.padLeft(2, '0');
    String minutesPadded = minutes.padLeft(2, '0');
    String secondsPadded = seconds.padLeft(2, '0');

    String format = widget.textFormat ?? 'MM:SS';

    // replace everything
    return format
        .replaceAll('HH', hoursPadded)
        .replaceAll('MM', minutesPadded)
        .replaceAll('SS', secondsPadded)
        .replaceAll('H', hours)
        .replaceAll('M', minutes)
        .replaceAll('S', seconds)
        .replaceAll(':', delimiter);
  }

  void _onComplete() {
    if (widget.onComplete != null) widget.onComplete!();
  }

  /// Get time from the timer
  String getTime() {
    return parse(currentDuration, delimiter: widget.delimiter);
  }
}

/// Manages the [_StopwatchState], enabling simple external control of the timer
/// without having to have access to the Timer widget itself.
class StopwatchManager {
  _StopwatchState? _state;
  StopwatchStatus? _status;
  late double elapsedSeconds = 0.0;

  /// Constructor
  StopwatchManager();

  /// Begin the Timer
  void start() {
    if (_state != null) {
      _state!.start();
    } else {
      _status = StopwatchStatus.running;
    }
  }

  /// Temporarily pause the timer
  void pause() {
    if (_state != null) {
      _state!.pause();
    } else {
      _status = StopwatchStatus.paused;
    }
  }

  /// Continue the timer
  void resume() {
    if (_state != null) {
      _state!.resume();
    } else {
      _status = StopwatchStatus.running;
    }
  }

  /// Stop the timer
  void stop() {
    if (_state != null) {
      _state!.stop();
    } else {
      _status = StopwatchStatus.stopped;
    }
  }

  /// Reset the timer, optionally to the provided seconds value
  void reset({double? seconds}) {
    stop();
    elapsedSeconds = seconds ?? 0.0;
    if (_state != null) {
      _state!.setSeconds(elapsedSeconds);
    }
  }

  /// Set the timer to time since the provided [time].
  void setNewTime(DateTime time) {
    if (_state != null) {
      _state!.setNewTime(time);
    }
  }

  /// Whether the timer is in a 'running' state
  bool isRunning() {
    if (_state != null) {
      return _state!.timerStatus == StopwatchStatus.running;
    }
    return false;
  }

  /// Whether the timer is completed
  bool isCompleted() {
    if (_state != null) {
      return _state!.timerStatus == StopwatchStatus.completed;
    }
    return false;
  }

  /// Whether the timer is paused
  bool isPaused() {
    if (_state != null) {
      return _state!.timerStatus == StopwatchStatus.paused;
    }
    return false;
  }

  /// Whether the timer is stopped
  bool isStopped() {
    if (_state != null) {
      return _state!.timerStatus == StopwatchStatus.stopped;
    }
    return false;
  }

  /// retrieves the state
  StopwatchStatus? getState() {
    if (_state != null) {
      return _state!.timerStatus;
    }
    return _status;
  }

  /// retrieves the time
  String? getTime() {
    if (_state != null) {
      return _state!.time;
    }
    return null;
  }

  /// Retrieves the current value of the timer.
  double get currentValue {
    if (_state != null) {
      return _state!.value;
    }
    return elapsedSeconds;
  }
}

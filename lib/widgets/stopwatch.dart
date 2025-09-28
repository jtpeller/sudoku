import 'package:flutter/material.dart';

/// Enum to represent Timer status
enum StopwatchStatus { stopped, running, paused, completed, invalid }

/// Timer
/// -----
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
  late AnimationController _controller;
  StopwatchStatus _timerStatus = StopwatchStatus.stopped;

  StopwatchStatus get timerStatus => _timerStatus;

  String get time {
    return parse(elapsed);
  }

  Duration get elapsed {
    if (_controller.isDismissed) {
      return Duration(seconds: 0);
    } else {
      return _controller.duration! * _controller.value;
    }
  }

  void setSeconds(double seconds) {
    widget.manager.elapsedSeconds = seconds;
    _controller.value = widget.manager.elapsedSeconds;
  }

  void setNewTime(DateTime time) {
    if (widget.manager.elapsedSeconds == 0.0) {
      DateTime now = DateTime.now();
      widget.manager.elapsedSeconds = now.difference(time).inSeconds.toDouble();
      _controller.value = widget.manager.elapsedSeconds;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Text(
          time,
          style: widget.textStyle ?? const TextStyle(fontSize: 16.0, color: Colors.black),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: Duration(days: 365));

    _controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.forward:
          _onStart();
        case AnimationStatus.reverse:
          _onStart();
        case AnimationStatus.dismissed:
          _onComplete();
        case AnimationStatus.completed:
          _onComplete();
      }
    });

    // initialize manager's state
    widget.manager._state = this;
    widget.manager.elapsedSeconds = widget.startSeconds;

    // begin timer, if auto-start is on.
    if (widget.autoStart) {
      start(startSeconds: widget.startSeconds);
    }
  }

  @override
  void dispose() {
    widget.manager.elapsedSeconds = _controller.value;
    _controller.dispose();
    super.dispose();
  }

  /// Begin the timer for the first time.
  ///
  /// Does nothing if the timer is already 'running'.
  void start({double? startSeconds}) {
    if (_timerStatus != StopwatchStatus.running) {
      // reset controller
      _controller.reset();
      _timerStatus = StopwatchStatus.running;

      // decide when to start
      double begin = 0.0;
      if (startSeconds == null) {
        begin = widget.countUp ? 0.0 : 1.0;
      } else {
        begin = startSeconds;
      }

      // decide which way to count
      if (widget.countUp) {
        _controller.forward(from: begin);
      } else {
        _controller.reverse(from: begin);
      }

      // call the on start
      widget.onStart?.call();
      setState(() {});
    }
  }

  /// Temporarily stop the timer's counting.
  ///
  /// Does nothing if the state is not 'running'.
  void pause() {
    if (_timerStatus == StopwatchStatus.running) {
      _controller.stop();
      _timerStatus = StopwatchStatus.paused;
      widget.manager.elapsedSeconds = _controller.value;
      setState(() {});
    }
  }

  /// Un-pause a timer that is currently paused.
  ///
  /// Does nothing if the state is not 'paused'.
  void resume() {
    if (_timerStatus == StopwatchStatus.paused) {
      _timerStatus = StopwatchStatus.running;
      double restore = widget.manager.elapsedSeconds.toDouble();
      if (widget.countUp) {
        _controller.forward(from: restore);
      } else {
        _controller.reverse(from: restore);
      }
      setState(() {});
    }
  }

  /// Stop the timer, putting it in a stopped state.
  void stop() {
    _controller.stop();
    _controller.reset();
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

  void _onStart() {
    if (widget.onStart != null) widget.onStart!();
  }

  void _onComplete() {
    if (widget.onComplete != null) widget.onComplete!();
  }

  /// Get time from the timer
  String getTime() {
    return parse(elapsed, delimiter: widget.delimiter);
  }
}

/// Manages the [_StopwatchState], enabling simple external control of the timer
/// without having to have access to the Timer widget itself.
class StopwatchManager {
  _StopwatchState? _state;
  late double elapsedSeconds = 0.0;

  /// Constructor
  StopwatchManager();

  /// Begin the Timer
  void start() {
    if (_state != null) {
      _state!.start();
    }
  }

  /// Temporarily pause the timer
  void pause() {
    if (_state != null) {
      _state!.pause();
    }
  }

  /// Continue the timer
  void resume() {
    if (_state != null) {
      _state!.resume();
    }
  }

  /// Stop the timer
  void stop() {
    if (_state != null) {
      _state!.stop();
    }
  }

  /// Reset the timer, optionally to the provided seconds value
  void reset({double? seconds}) {
    stop();
    if (_state != null) {
      _state!.setSeconds(seconds ?? 0.0);
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
    return null;
  }

  /// retrieves the time
  String? getTime() {
    if (_state != null) {
      return _state!.time;
    }
    return null;
  }
}

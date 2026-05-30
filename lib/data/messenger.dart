import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku/theme/colors.dart';
import 'package:sudoku/theme/text.dart';

/// A custom message system for game feedback.
/// 
/// It supports animations shaking and color flashing 
/// when duplicate messages are detected.
class GameFeedbackMessenger {
  static OverlayEntry? _overlayEntry;
  static String? _lastMessage;
  static Timer? _dismissTimer;
  static final GlobalKey<_FeedbackWidgetState> _widgetKey = GlobalKey();

  /// Function to show the status [message] for a particular [duration].
  static void showStatus(BuildContext context, String message, {int duration = 2}) {
    final overlay = Overlay.of(context);

    // Capture the current theme from the caller's context. This ensures that the 
    // Overlay reflects the correct Light/Dark mode settings.
    final theme = Theme.of(context);

    // If the message is the same, trigger the shake animation on the existing widget
    if (_lastMessage == message && _overlayEntry != null) {
      _widgetKey.currentState?.shake();
      _resetTimer(duration);
      return;
    }

    // Otherwise, dismiss any existing message and show the new one
    _dismiss();

    _lastMessage = message;
    _overlayEntry = OverlayEntry(
      builder: (context) => Theme(
        data: theme,
        child: _FeedbackWidget(key: _widgetKey, message: message),
      ),
    );

    overlay.insert(_overlayEntry!);
    _resetTimer(duration);
  }

  /// Resets this class's timer for the duration.
  /// 
  /// Used when a duplicate is detected, so it may display for longer.
  static void _resetTimer(int duration) {
    _dismissTimer?.cancel();
    _dismissTimer = Timer(Duration(seconds: duration), () {
      _dismiss();
    });
  }

  /// Dismisses the current message.
  static void _dismiss() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _lastMessage = null;
    _dismissTimer?.cancel();
    _dismissTimer = null;
  }
}

/// Stateful widget to provide the message.
/// 
/// This widget is responsible for the shaking, color, and entrance animations.
class _FeedbackWidget extends StatefulWidget {
  final String message;

  const _FeedbackWidget({required Key key, required this.message}) : super(key: key);

  @override
  _FeedbackWidgetState createState() => _FeedbackWidgetState();
}

/// State class for [_FeedbackWidget]
class _FeedbackWidgetState extends State<_FeedbackWidget> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _colorController;
  late AnimationController _entranceController;

  late Animation<double> _shakeAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _fadeAnimation;

  // Track consecutive shakes to escalate haptic feedback intensity
  int _shakeCount = 0;
  DateTime? _lastShakeTimestamp;

  @override
  void initState() {
    super.initState();

    // Shake Animation: Horizontal movement
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    // Color Animation: Flash to red
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Entrance Animation: Fade and Slide Up
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();

    _fadeAnimation = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // didChangeDependencies is called after initState and whenever dependencies 
    // like the Theme change. This is the correct place to query the context 
    // for theme-specific values.
    final baseColor = ThemeColor.getAccentColor(context);
    final baseBorder = ThemeColor.getBorderColor(context);

    _colorAnimation = ColorTween(
      begin: baseColor,
      end: Colors.red.shade900,
    ).animate(_colorController);

    _borderColorAnimation = ColorTween(
      begin: baseBorder,
      end: Colors.red.shade900,
    ).animate(_colorController);
  }

  /// Initiate a shake of this widget.
  void shake() {
    final now = DateTime.now();

    // If the next shake happens quickly (within 600ms), increase intensity
    if (_lastShakeTimestamp != null &&
        now.difference(_lastShakeTimestamp!) < const Duration(milliseconds: 600)) {
      _shakeCount++;
    } else {
      _shakeCount = 1;
    }
    _lastShakeTimestamp = now;

    // Escalate the haptic impact based on the consecutive count
    switch (_shakeCount) {
      case 1: HapticFeedback.lightImpact();
      case 2: HapticFeedback.mediumImpact();
      case 3: HapticFeedback.heavyImpact();
      default: HapticFeedback.vibrate(); // Maximum feedback for repeated spamming
    }

    _shakeController.forward(from: 0);
    _colorController.forward(from: 0).then((_) => _colorController.reverse());
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _colorController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
          child: AnimatedBuilder(
            animation: Listenable.merge([_shakeController, _colorController, _entranceController]),
            builder: (context, child) {
              return Opacity(   // For handling the fade.
                opacity: _fadeAnimation.value,
                child: Transform.translate(   // For handling the shake.
                  offset: Offset(_shakeAnimation.value, (1.0 - _fadeAnimation.value) * 20),
                  child: Material(    // For handling the color.
                    elevation: 6,
                    color: _colorAnimation.value,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderColorAnimation.value!, width: 3),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // The actual Icon and message.
                          const Icon(Icons.info_outline, color: Colors.white70, size: 20),
                          const SizedBox(width: 12),
                          Flexible(
                            child: DefaultTextStyle(
                              style: ThemeStyle.tooltip(context),
                              child: Text(widget.message, style: ThemeStyle.smallGameText(context).copyWith(fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

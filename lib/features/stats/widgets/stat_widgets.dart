import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A wrapper that creates a subtle glow effect when the provided [value] changes.
class StatGlowWrapper extends StatefulWidget {
  final Widget child;
  final dynamic value;
  final Color glowColor;

  const StatGlowWrapper({super.key, required this.child, required this.value, required this.glowColor});

  @override
  State<StatGlowWrapper> createState() => _StatGlowWrapperState();
}

class _StatGlowWrapperState extends State<StatGlowWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(StatGlowWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation only when the monitored value changes
    if (widget.value != oldWidget.value) {
      _controller.forward(from: 0.0).then((_) {
        if (mounted) _controller.reverse();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: _animation.value * 0.5),
                blurRadius: 12 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A generic stat icon that animates (pops/shakes) when its state or value changes.
class AnimatedStatIcon extends StatefulWidget {
  final bool isFilled;
  final IconData filledIcon;
  final IconData? emptyIcon;
  final Color color;
  final double size;
  final dynamic triggerValue;

  const AnimatedStatIcon({
    super.key,
    required this.isFilled,
    required this.filledIcon,
    this.emptyIcon,
    required this.color,
    this.size = 24,
    this.triggerValue,
  });

  @override
  State<AnimatedStatIcon> createState() => _AnimatedStatIconState();
}

class _AnimatedStatIconState extends State<AnimatedStatIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0).chain(CurveTween(curve: Curves.bounceIn)), weight: 60),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedStatIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation if fill state changes or the external trigger value changes
    if (oldWidget.isFilled != widget.isFilled || oldWidget.triggerValue != widget.triggerValue) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate shake: a sine wave that dampens over the animation duration
        double shake = 0.0;
        if (_controller.isAnimating) {
          shake = math.sin(_controller.value * math.pi * 6) * 0.15 * (1.0 - _controller.value);
        }

        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: shake,
            child: Icon(
              widget.isFilled ? widget.filledIcon : (widget.emptyIcon ?? widget.filledIcon),
              color: widget.isFilled ? widget.color : widget.color.withValues(alpha: 0.5),
              size: widget.size,
            ),
          ),
        );
      },
    );
  }
}

/// Displays a group of stat icons.
/// - If [isSmall] is true or [total] is null: displays a single animated icon and a count.
/// - Otherwise: displays a row of individual icons up to [total].
class StatIconGroup extends StatelessWidget {
  final IconData filledIcon;
  final IconData? emptyIcon;
  final int count;
  final int? total;
  final Color color;
  final bool isSmall;
  final TextStyle textStyle;
  final double iconSize;

  const StatIconGroup({
    super.key,
    required this.filledIcon,
    this.emptyIcon,
    required this.count,
    this.total,
    required this.color,
    required this.isSmall,
    required this.textStyle,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    if (isSmall || total == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedStatIcon(
            isFilled: true,
            filledIcon: filledIcon,
            color: color,
            size: iconSize,
            triggerValue: count,
          ),
          const SizedBox(width: 4),
          Text('$count', style: textStyle),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total!, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: AnimatedStatIcon(
            isFilled: index < count,
            filledIcon: filledIcon,
            emptyIcon: emptyIcon,
            color: color,
            size: iconSize,
          ),
        );
      }),
    );
  }
}
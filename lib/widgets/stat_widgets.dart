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

/// A widget that displays a heart icon and animates (pops/shakes) when it is emptied.
class AnimatedHeart extends StatefulWidget {
  final bool isFilled;
  const AnimatedHeart({super.key, required this.isFilled});

  @override
  State<AnimatedHeart> createState() => _AnimatedHeartState();
}

class _AnimatedHeartState extends State<AnimatedHeart> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(AnimatedHeart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation only when a heart goes from filled to empty (mistake made)
    if (oldWidget.isFilled && !widget.isFilled) {
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
              widget.isFilled ? Icons.favorite : Icons.favorite_border,
              color: widget.isFilled ? Colors.redAccent : Colors.redAccent.withValues(alpha: 0.5),
              size: 24,
            ),
          ),
        );
      },
    );
  }
}
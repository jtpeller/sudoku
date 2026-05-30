import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sudoku/theme/colors.dart';

/// A background animation of numbers that fade in and shift up.
class FloatingNumbersBackground extends StatelessWidget {
  final int count;

  const FloatingNumbersBackground({super.key, this.count = 50});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final random = math.Random();
        return Stack(
          children: List.generate(count, (index) {
            final startX = random.nextDouble() * constraints.maxWidth;
            final startY = random.nextDouble() * constraints.maxHeight;
            final duration = Duration(milliseconds: 3000 + random.nextInt(3000));
            final delay = Duration(milliseconds: random.nextInt(2500));

            return AnimatedNumber(
              startX: startX,
              startY: startY,
              duration: duration,
              delay: delay,
              value: random.nextInt(9) + 1,
            );
          }),
        );
      },
    );
  }
}

class AnimatedNumber extends StatefulWidget {
  final double startX;
  final double startY;
  final Duration duration;
  final Duration delay;
  final int value;

  const AnimatedNumber({
    super.key,
    required this.startX,
    required this.startY,
    required this.duration,
    required this.delay,
    required this.value,
  });

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.25), weight: 25),
      TweenSequenceItem(tween: ConstantTween(0.25), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.25, end: 0.0), weight: 25),
    ]).animate(_controller);

    _translate = Tween<double>(begin: 0, end: -120).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.repeat();
    });
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
        return Positioned(
          left: widget.startX,
          top: widget.startY + _translate.value,
          child: Opacity(
            opacity: _opacity.value,
            child: Text(
              widget.value.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ThemeColor.getAccentColor(context),
              ),
            ),
          ),
        );
      },
    );
  }
}
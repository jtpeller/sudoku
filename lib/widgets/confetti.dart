import 'dart:math';
import 'package:flutter/material.dart';

/// A simple confetti animation widget that drops colorful squares.
class ConfettiWidget extends StatefulWidget {
  final bool play;
  const ConfettiWidget({super.key, required this.play});

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiPiece> _pieces = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        if (mounted) setState(() {});
      });

    if (widget.play) {
      _start();
    }
  }

  void _start() {
    _pieces.clear();
    for (int i = 0; i < 150; i++) {
      _pieces.add(_ConfettiPiece(_random));
    }
    _controller.repeat();
  }

  @override
  void didUpdateWidget(ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) {
      _start();
    } else if (!widget.play && oldWidget.play) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.play) return const SizedBox.shrink();
    return CustomPaint(
      painter: _ConfettiPainter(_pieces),
      size: Size.infinite,
    );
  }
}

class _ConfettiPiece {
  late double x, y, size, vx, vy, angle, spin;
  late Color color;
  final Random random;

  _ConfettiPiece(this.random) {
    init();
  }

  void init() {
    x = random.nextDouble() * 1000;
    y = -random.nextDouble() * 500; // Start at various heights above the screen
    size = random.nextDouble() * 8 + 4;
    vx = (random.nextDouble() - 0.5) * 4;
    vy = random.nextDouble() * 5 + 3;
    angle = random.nextDouble() * 2 * pi;
    spin = (random.nextDouble() - 0.5) * 0.2;
    color = Colors.primaries[random.nextInt(Colors.primaries.length)];
  }

  void update() {
    x += vx;
    y += vy;
    angle += spin;
    if (y > 1000) {
      init();
      y = -20;
    }
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  _ConfettiPainter(this.pieces);

  @override
  void paint(Canvas canvas, Size size) {
    for (var piece in pieces) {
      piece.update();
      final paint = Paint()..color = piece.color;
      final posX = (piece.x / 1000) * size.width;
      
      canvas.save();
      canvas.translate(posX, piece.y);
      canvas.rotate(piece.angle);
      canvas.drawRect(Rect.fromLTWH(-piece.size / 2, -piece.size / 2, piece.size, piece.size), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
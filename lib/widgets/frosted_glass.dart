import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedGlassBox extends StatelessWidget {
  final Widget child;
  final double blur;
  final int alpha;
  final int borderAlpha;
  final Color startColor;
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;

  const FrostedGlassBox({
    super.key,
    required this.child,
    this.blur = 5.0,
    this.alpha = 50,
    this.borderAlpha = 255,
    this.startColor = Colors.white,
    this.borderColor = Colors.white,
    this.borderRadius = 15.0,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: startColor.withAlpha(alpha),
            border: Border.all(color: borderColor.withAlpha(borderAlpha), width: borderWidth),
            // Requires both to have border radius, else there will be strange borders.
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}

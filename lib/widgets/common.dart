import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text.dart';

import 'frosted_glass.dart';

String getBgImagePath(ThemeMode darkmode) {
  return darkmode == ThemeMode.dark
      ? 'assets/img/sudoku-bg-dark.png'
      : 'assets/img/sudoku-bg-lite.png';
}

AppBar getAppBar(BuildContext context, String title) {
  return AppBar(
    title: Text(title),
    backgroundColor: ThemeColor.getAppBarColor(context),
    centerTitle: true,
  );
}

Stack getBackgroundBlurStack(
  BuildContext context,
  Widget child, {
  int alpha = 50,
  double blur = 5.0,
  Color startColor = Colors.transparent,
}) {
  return Stack(
    children: <Widget>[
      Image.asset(
        getBgImagePath(
          Theme.of(context).brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
        ),
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      ),
      FrostedGlassBox(
        alpha: alpha,
        blur: blur,
        borderAlpha: 0,
        borderRadius: 0.0,
        startColor: startColor,
        child: child,
      ),
    ],
  );
}

class TooltipIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onPressed;

  const TooltipIconButton({
    super.key,
    required this.icon,
    this.iconColor = Colors.white,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      textStyle: ThemeStyle.tooltip(context),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        style: ThemeStyle.iconButtonThemeData(context).style,
        iconSize: ThemeStyle.option(context).fontSize! * 1.25,
        onPressed: onPressed,
      ),
    );
  }
}

class FrostedTooltipIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  final int alpha;
  final double blur;
  final int borderAlpha;
  final double borderRadius;
  final double borderWidth;
  final Color startColor;
  final Color accentColor;

  const FrostedTooltipIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.alpha = 100,
    this.blur = 5.0,
    this.borderAlpha = 255,
    this.borderRadius = 100,
    this.borderWidth = 2,
    this.startColor = Colors.grey,
    this.accentColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return FrostedGlassBox(
      alpha: alpha,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      borderColor: accentColor,
      startColor: startColor,
      child: TooltipIconButton(
        icon: icon,
        iconColor: accentColor,
        label: label,
        onPressed: onPressed,
      ),
    );
  }
}

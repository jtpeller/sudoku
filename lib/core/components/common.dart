import 'package:flutter/material.dart';

import 'package:sudoku/core/theme/colors.dart';
import 'package:sudoku/core/theme/text.dart';
import 'package:sudoku/core/components/spacing.dart';

import 'frosted_glass.dart';

String getBgImagePath(ThemeMode darkmode) {
  return darkmode == ThemeMode.dark
      ? 'assets/img/sudoku-bg-dark.png'
      : 'assets/img/sudoku-bg-lite.png';
}

AppBar getAppBar(BuildContext context, String title, {List<Widget>? actions}) {
  return AppBar(
    title: Text(title, style: ThemeStyle.subtitle(context)),
    backgroundColor: ThemeColor.getAppBarColor(context),
    centerTitle: true,
    actions: actions,
  );
}

class FrostedBlurStack extends StatelessWidget {
  final Widget child;
  final int alpha;
  final double blur;
  final Color startColor;

  const FrostedBlurStack({
    super.key,
    required this.child,
    this.alpha = 50,
    this.blur = 5.0,
    this.startColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
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

/// Text with Helper
class HelperText extends StatelessWidget {
  final String text;
  final String helperText;
  final IconData? icon;

  const HelperText({super.key, required this.text, required this.helperText, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: ThemeColor.getAccentColor(context),
                size: ThemeStyle.option(context).fontSize,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(text, style: ThemeStyle.option(context)),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        Text(helperText, style: ThemeStyle.helperText(context)),
      ],
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double breakpoint;

  const ResponsiveRow({
    super.key,
    required this.left,
    required this.right,
    required this.breakpoint,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > breakpoint) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: Align(alignment: Alignment.centerLeft, child: left)),
              horizontalSpacer,
              Align(alignment: Alignment.centerRight, child: right),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Align(alignment: Alignment.centerLeft, child: left),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                alignment: Alignment.centerRight,
                child: right,
              ),
            ],
          );
        }
      },
    );
  }
}

class Option extends StatelessWidget {
  final String label;
  final String helpText;
  final Widget child;
  final double breakpoint;
  final IconData? icon;

  const Option({
    super.key,
    required this.label,
    required this.helpText,
    required this.child,
    required this.breakpoint,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResponsiveRow(
          breakpoint: breakpoint,
          left: HelperText(text: label, helperText: helpText, icon: icon),
          right: child,
        ),
        verticalSpacer,
      ],
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
    return Tooltip(
      message: label,
      textStyle: ThemeStyle.tooltip(context),
      child: FrostedGlassButton(
        alpha: alpha,
        blur: blur,
        borderAlpha: borderAlpha,
        borderRadius: borderRadius,
        borderWidth: borderWidth,
        borderColor: accentColor,
        startColor: startColor,
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: accentColor,
          size: ThemeStyle.option(context).fontSize! * 1.25,
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku/core/components/common.dart' as common;
import 'package:sudoku/core/components/spacing.dart' as spacing;
import 'package:sudoku/core/theme/colors.dart';
import 'package:sudoku/core/theme/text.dart';

class FrostedGlassBox extends StatelessWidget {
  final Widget child;
  final double blur;
  final int alpha;
  final int borderAlpha;
  final Color startColor;
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsets padding;

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
    this.padding = const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
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

/// A specific frosted card that displays an icon and a descriptive quip.
class FrostedIconCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const FrostedIconCard({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: FrostedGlassBox(
        key: ValueKey<String>('$text-${icon.codePoint}'),
        alpha: 30,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 48, color: ThemeColor.getAccentColor(context)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: ThemeStyle.mediumGameText(context).copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A Scaffold wrapper that applies the consistent frosted glass background.
/// Perfect for full-screen dialogs and sub-pages.
class FrostedScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final int alpha;
  final double blur;
  final Color? startColor;
  final PreferredSizeWidget? appBar;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final AlignmentDirectional persistentFooterAlignment;
  final Widget? drawer;
  final DrawerCallback? onDrawerChanged;
  final Widget? endDrawer;
  final DrawerCallback? onEndDrawerChanged;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? drawerScrimColor;
  final double? drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;

  const FrostedScaffold({
    super.key,
    this.title,
    required this.body,
    this.alpha = 50,
    this.blur = 5.0,
    this.startColor,
    this.appBar,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.persistentFooterAlignment = AlignmentDirectional.centerEnd,
    this.drawer,
    this.onDrawerChanged,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? (title != null ? common.getAppBar(context, title!, actions: actions) : null),
      backgroundColor: backgroundColor ?? ThemeColor.getStartColor(context),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons,
      persistentFooterAlignment: persistentFooterAlignment,
      drawer: drawer,
      onDrawerChanged: onDrawerChanged,
      endDrawer: endDrawer,
      onEndDrawerChanged: onEndDrawerChanged,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
      drawerDragStartBehavior: drawerDragStartBehavior,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      drawerScrimColor: drawerScrimColor,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      restorationId: restorationId,
      body: common.FrostedBlurStack(
        alpha: alpha,
        blur: blur,
        startColor: startColor ?? ThemeColor.getStartColor(context),
        child: body,
      ),
    );
  }
}

class FrostedGlassButton extends StatelessWidget {
  final Widget? child;
  final IconData? icon;
  final String? label;
  final String? tooltip;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final double blur;
  final int alpha;
  final int borderAlpha;
  final Color startColor;
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsets padding;
  final bool enableHaptics;
  final AlignmentGeometry? alignment;
  final double? iconSize;
  final Color? iconColor;

  const FrostedGlassButton({
    super.key,
    this.child,
    this.icon,
    this.label,
    this.tooltip,
    this.onPressed,
    this.onLongPress,
    this.blur = 5.0,
    this.alpha = 50,
    this.borderAlpha = 255,
    this.startColor = Colors.white,
    this.borderColor = Colors.white,
    this.borderRadius = 15.0,
    this.borderWidth = 1.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.enableHaptics = false,
    this.alignment = Alignment.center,
    this.iconSize,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = iconColor ?? ThemeColor.getAccentColor(context);

    Widget? content = child;

    if (content == null) {
      Widget? iconWidget = icon != null
          ? Icon(
              icon,
              size: iconSize,
              color: effectiveColor,
            )
          : null;

      if (iconWidget != null && label != null) {
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            spacing.smallHorizontalSpacer,
            Text(
              label!,
              style: ThemeStyle.smallButtonText(context).copyWith(color: effectiveColor),
            ),
          ],
        );
      } else {
        content = iconWidget ??
            (label != null
                ? Text(
                    label!,
                    style: ThemeStyle.smallButtonText(context).copyWith(color: effectiveColor),
                  )
                : const SizedBox.shrink());
      }
    }

    final Widget button = IntrinsicWidth(
      child: IntrinsicHeight(
        child: FrostedGlassBox(
          blur: blur,
          alpha: alpha,
          borderAlpha: borderAlpha,
          startColor: startColor,
          borderColor: borderColor,
          borderRadius: borderRadius,
          borderWidth: borderWidth,
          padding: EdgeInsets.zero, // FrostedGlassBox itself has no padding
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed != null
                  ? () {
                      if (enableHaptics) HapticFeedback.lightImpact();
                      onPressed!();
                    }
                  : null,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                padding: padding,
                alignment: alignment,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        textStyle: ThemeStyle.tooltip(context),
        child: button,
      );
    }

    return button;
  }
}

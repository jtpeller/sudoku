import 'package:flutter/material.dart';

/// A generalized page layout manager that centralizes responsiveness,
/// scrolling, and overflow handling.
///
/// Similar to a Bootstrap "container", it constrains content width on large
/// screens while providing a flexible layout on smaller ones.
class PageLayout extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double? maxWidth;
  final bool scrollable;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const PageLayout({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.maxWidth,
    this.scrollable = true,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Basic responsive width logic inspired by Bootstrap containers
    double effectiveMaxWidth = maxWidth ??
        (screenWidth >= 1200
            ? 1140
            : screenWidth >= 992
                ? 960
                : screenWidth >= 768
                    ? 720
                    : screenWidth);

    Column column = Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );

    if (scrollable) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: effectiveMaxWidth,
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(padding: padding, child: column),
              ),
            ),
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: Padding(padding: padding, child: column),
      ),
    );
  }
}
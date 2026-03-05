import 'package:flutter/material.dart';

/// Responsive breakpoints for the application
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double minWidth = 375;
}

/// Screen type based on width
enum ScreenType { mobile, tablet, desktop }

/// Get screen type from width
ScreenType getScreenType(double width) {
  if (width < Breakpoints.mobile) return ScreenType.mobile;
  if (width < Breakpoints.tablet) return ScreenType.tablet;
  return ScreenType.desktop;
}

/// A widget that rebuilds based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType, BoxConstraints constraints) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final screenType = getScreenType(width);
        return builder(context, screenType, constraints);
      },
    );
  }
}

/// Extension for responsive context helpers
extension ResponsiveContext on BuildContext {
  /// Get screen type based on current width
  ScreenType get screenType {
    final width = MediaQuery.of(this).size.width;
    return getScreenType(width);
  }

  /// Check if current screen is mobile
  bool get isMobile => screenType == ScreenType.mobile;

  /// Check if current screen is tablet
  bool get isTablet => screenType == ScreenType.tablet;

  /// Check if current screen is desktop
  bool get isDesktop => screenType == ScreenType.desktop;

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;
}

/// A responsive value that changes based on screen type
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  /// Get value for screen type (tablet falls back to desktop if not specified)
  T get(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? desktop;
      case ScreenType.desktop:
        return desktop;
    }
  }

  /// Get value from context
  T of(BuildContext context) => get(context.screenType);
}

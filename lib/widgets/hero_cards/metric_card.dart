import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../theme/app_themes.dart';

/// A card with a colored left border accent
class MetricCard extends StatelessWidget {
  final Color accentColor;
  final Widget child;

  const MetricCard({
    super.key,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final isMobile = context.isMobile;
    final borderRadius = isMobile ? 8.0 : 12.0;

    return Container(
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: theme.border, width: 1),
      ),
      child: Stack(
        children: [
          // Colored left accent bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: isMobile ? 3 : 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  bottomLeft: Radius.circular(borderRadius),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            child: child,
          ),
        ],
      ),
    );
  }
}

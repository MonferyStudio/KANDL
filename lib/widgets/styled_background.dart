import 'package:flutter/material.dart';

import '../theme/app_themes.dart';

/// Stylized background with grid pattern and vignette effect
class StyledBackground extends StatelessWidget {
  final bool showGrid;
  final bool showVignette;
  final bool showGlows;
  final double gridOpacity;
  final double gridSize;

  const StyledBackground({
    super.key,
    this.showGrid = true,
    this.showVignette = true,
    this.showGlows = true,
    this.gridOpacity = 0.5,
    this.gridSize = 40,  // Subtle grid
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return SizedBox.expand(
      child: Stack(
        children: [
          // Base background
          Container(color: theme.background),

          // Grid pattern
          if (showGrid)
            Positioned.fill(
              child: CustomPaint(
                painter: GridPainter(
                  gridSize: gridSize,
                  opacity: gridOpacity,
                  fadeCenter: true,
                  gridColor: theme.isDark
                      ? const Color(0xFF252535)
                      : theme.border.withValues(alpha: 0.3),
                ),
              ),
            ),

          // Corner glows (only show on dark themes)
          if (showGlows && theme.isDark) ...[
            // Top-left primary glow
            Positioned(
              top: -150,
              left: -150,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      theme.cyan.withValues(alpha: 0.15),
                      theme.cyan.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Bottom-right secondary glow
            Positioned(
              bottom: -150,
              right: -150,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      theme.orange.withValues(alpha: 0.12),
                      theme.orange.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Top-right subtle accent glow
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      theme.purple.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ],

          // Vignette effect (darker edges - only for dark themes)
          if (showVignette && theme.isDark)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    stops: const [0.5, 0.85, 1.0],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom painter for grid lines - simple and subtle
class GridPainter extends CustomPainter {
  final double gridSize;
  final double opacity;
  final bool fadeCenter;
  final Color gridColor;

  GridPainter({
    required this.gridSize,
    required this.opacity,
    this.fadeCenter = true,
    this.gridColor = const Color(0xFF252535),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final linePaint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      double alpha = opacity;
      if (fadeCenter) {
        final distanceFromCenter = (x - centerX).abs() / centerX;
        alpha = opacity * (0.5 + distanceFromCenter * 0.5);
      }
      linePaint.color = gridColor.withValues(alpha: alpha.clamp(0.0, 1.0));
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      double alpha = opacity;
      if (fadeCenter) {
        final distanceFromCenter = (y - centerY).abs() / centerY;
        alpha = opacity * (0.5 + distanceFromCenter * 0.5);
      }
      linePaint.color = gridColor.withValues(alpha: alpha.clamp(0.0, 1.0));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize ||
        oldDelegate.opacity != opacity ||
        oldDelegate.fadeCenter != fadeCenter ||
        oldDelegate.gridColor != gridColor;
  }
}

/// Alternative: Dot pattern background
class DotPatternBackground extends StatelessWidget {
  final double dotSpacing;
  final double dotSize;
  final double opacity;

  const DotPatternBackground({
    super.key,
    this.dotSpacing = 30,
    this.dotSize = 1.5,
    this.opacity = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return SizedBox.expand(
      child: Stack(
        children: [
          Container(color: theme.background),
          Positioned.fill(
            child: CustomPaint(
              painter: DotPainter(
                spacing: dotSpacing,
                dotSize: dotSize,
                opacity: opacity,
                dotColor: theme.border,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DotPainter extends CustomPainter {
  final double spacing;
  final double dotSize;
  final double opacity;
  final Color dotColor;

  DotPainter({
    required this.spacing,
    required this.dotSize,
    required this.opacity,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final paint = Paint()
      ..color = dotColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotPainter oldDelegate) {
    return oldDelegate.spacing != spacing ||
        oldDelegate.dotSize != dotSize ||
        oldDelegate.opacity != opacity ||
        oldDelegate.dotColor != dotColor;
  }
}

/// Scanline effect (like old CRT monitors)
class ScanlineOverlay extends StatelessWidget {
  final double opacity;
  final double lineHeight;

  const ScanlineOverlay({
    super.key,
    this.opacity = 0.05,
    this.lineHeight = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: ScanlinePainter(
            opacity: opacity,
            lineHeight: lineHeight,
          ),
        ),
      ),
    );
  }
}

class ScanlinePainter extends CustomPainter {
  final double opacity;
  final double lineHeight;

  ScanlinePainter({required this.opacity, required this.lineHeight});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final paint = Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    for (double y = 0; y < size.height; y += lineHeight * 2) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, lineHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScanlinePainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.lineHeight != lineHeight;
  }
}

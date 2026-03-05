import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';

/// Shimmer loading effect widget
class Shimmer extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final bool enabled;

  const Shimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled && _controller.isAnimating) {
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
    final theme = context.watchTheme;

    if (!widget.enabled) {
      return widget.child;
    }

    final baseColor = widget.baseColor ?? theme.surface;
    final highlightColor = widget.highlightColor ?? theme.border;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              transform: _SlidingGradientTransform(_controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double progress;

  const _SlidingGradientTransform(this.progress);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (progress * 2 - 1), 0, 0);
  }
}

/// Shimmer placeholder for loading states
class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerPlaceholder({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }
}

/// Shimmer card placeholder
class ShimmerCard extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerCard({
    super.key,
    this.width,
    this.height = 100,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Shimmer list item placeholder
class ShimmerListItem extends StatelessWidget {
  final double height;
  final bool showAvatar;
  final int lines;

  const ShimmerListItem({
    super.key,
    this.height = 72,
    this.showAvatar = true,
    this.lines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return Shimmer(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (showAvatar)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            if (showAvatar) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(lines, (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: index < lines - 1 ? 8 : 0),
                    child: Container(
                      width: index == 0 ? double.infinity : 150,
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading for charts
class ShimmerChart extends StatelessWidget {
  final double height;

  const ShimmerChart({
    super.key,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return Shimmer(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Fake chart lines
            Positioned.fill(
              child: CustomPaint(
                painter: _ShimmerChartPainter(theme: theme),
              ),
            ),
            // Bottom axis
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 24,
              child: Container(
                color: theme.surface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerChartPainter extends CustomPainter {
  final AppThemeData theme;

  _ShimmerChartPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.surface
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw fake grid lines
    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint..color = theme.border.withValues(alpha: 0.3),
      );
    }

    // Draw fake chart line
    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.6,
      size.width,
      size.height * 0.3,
    );
    canvas.drawPath(path, paint..color = theme.surface);
  }

  @override
  bool shouldRepaint(covariant _ShimmerChartPainter oldDelegate) =>
      oldDelegate.theme != theme;
}

/// Pulsing dot indicator
class PulsingDot extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration duration;

  const PulsingDot({
    super.key,
    this.color,
    this.size = 8,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final effectiveColor = widget.color ?? theme.positive;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: effectiveColor.withValues(alpha: _animation.value),
            boxShadow: [
              BoxShadow(
                color: effectiveColor.withValues(alpha: _animation.value * 0.5),
                blurRadius: widget.size * _animation.value,
                spreadRadius: widget.size * 0.2 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Loading spinner with glow
class GlowSpinner extends StatefulWidget {
  final Color? color;
  final double size;
  final double strokeWidth;

  const GlowSpinner({
    super.key,
    this.color,
    this.size = 32,
    this.strokeWidth = 3,
  });

  @override
  State<GlowSpinner> createState() => _GlowSpinnerState();
}

class _GlowSpinnerState extends State<GlowSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final effectiveColor = widget.color ?? theme.cyan;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: effectiveColor.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircularProgressIndicator(
            strokeWidth: widget.strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_themes.dart';
import '../../core/big_number.dart';
import '../../core/number_formatter.dart';

/// A price display that pulses green/red when value changes
class PricePulse extends StatefulWidget {
  final BigNumber price;
  final TextStyle? style;
  final bool showCurrency;
  final Duration pulseDuration;

  const PricePulse({
    super.key,
    required this.price,
    this.style,
    this.showCurrency = true,
    this.pulseDuration = const Duration(milliseconds: 600),
  });

  @override
  State<PricePulse> createState() => _PricePulseState();
}

class _PricePulseState extends State<PricePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  BigNumber _previousPrice = BigNumber.zero;
  Color _pulseColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _previousPrice = widget.price;

    _controller = AnimationController(
      duration: widget.pulseDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(PricePulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.price != widget.price) {
      final theme = context.theme;
      // Determine direction
      if (widget.price > _previousPrice) {
        _pulseColor = theme.positive;
      } else if (widget.price < _previousPrice) {
        _pulseColor = theme.negative;
      }
      _previousPrice = widget.price;
      _controller.forward(from: 0);
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
    final text = widget.showCurrency
        ? NumberFormatter.formatPrice(widget.price)
        : NumberFormatter.formatPlain(widget.price);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: _pulseColor.withValues(alpha: _pulseAnimation.value * 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            text,
            style: (widget.style ?? const TextStyle()).copyWith(
              color: Color.lerp(
                widget.style?.color ?? theme.textPrimary,
                _pulseColor,
                _pulseAnimation.value * 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A percentage change display that pulses on change
class PercentChangePulse extends StatefulWidget {
  final double percent;
  final TextStyle? style;
  final Duration pulseDuration;
  final bool showBackground;

  const PercentChangePulse({
    super.key,
    required this.percent,
    this.style,
    this.pulseDuration = const Duration(milliseconds: 600),
    this.showBackground = true,
  });

  @override
  State<PercentChangePulse> createState() => _PercentChangePulseState();
}

class _PercentChangePulseState extends State<PercentChangePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.pulseDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(PercentChangePulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.percent - widget.percent).abs() > 0.01) {
      _controller.forward(from: 0);
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
    final isPositive = widget.percent >= 0;
    final color = isPositive ? theme.positive : theme.negative;
    final text = NumberFormatter.formatPercent(widget.percent);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: widget.showBackground
                ? BoxDecoration(
                    color: color.withValues(alpha: 0.15 + (_pulseAnimation.value * 0.15)),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3 + (_pulseAnimation.value * 0.3)),
                    ),
                    boxShadow: _pulseAnimation.value > 0
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: _pulseAnimation.value * 0.4),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  )
                : null,
            child: Text(
              text,
              style: (widget.style ?? const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )).copyWith(color: color),
            ),
          ),
        );
      },
    );
  }
}

/// Animated arrow indicator for price direction
class PriceArrow extends StatefulWidget {
  final double change;
  final double size;
  final Duration duration;

  const PriceArrow({
    super.key,
    required this.change,
    this.size = 16,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<PriceArrow> createState() => _PriceArrowState();
}

class _PriceArrowState extends State<PriceArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -4), weight: 30),
      TweenSequenceItem(tween: Tween(begin: -4, end: 2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 2, end: 0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(PriceArrow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation when sign changes
    if ((oldWidget.change >= 0) != (widget.change >= 0) ||
        (oldWidget.change.abs() - widget.change.abs()).abs() > 0.1) {
      _controller.forward(from: 0);
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

    if (widget.change.abs() < 0.001) {
      return Icon(
        Icons.remove,
        size: widget.size,
        color: theme.textSecondary,
      );
    }

    final isUp = widget.change > 0;
    final color = isUp ? theme.positive : theme.negative;

    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, isUp ? _bounceAnimation.value : -_bounceAnimation.value),
          child: Icon(
            isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            size: widget.size,
            color: color,
          ),
        );
      },
    );
  }
}

/// Sparkline mini chart with pulse effect on new data
class SparklinePulse extends StatefulWidget {
  final List<double> values;
  final double width;
  final double height;
  final Color? lineColor;
  final Color? fillColor;
  final double strokeWidth;

  const SparklinePulse({
    super.key,
    required this.values,
    this.width = 60,
    this.height = 24,
    this.lineColor,
    this.fillColor,
    this.strokeWidth = 1.5,
  });

  @override
  State<SparklinePulse> createState() => _SparklinePulseState();
}

class _SparklinePulseState extends State<SparklinePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(SparklinePulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values.length != widget.values.length ||
        (widget.values.isNotEmpty &&
            oldWidget.values.isNotEmpty &&
            widget.values.last != oldWidget.values.last)) {
      _controller.forward(from: 0);
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

    if (widget.values.isEmpty) {
      return SizedBox(width: widget.width, height: widget.height);
    }

    final isPositive = widget.values.length > 1
        ? widget.values.last >= widget.values.first
        : true;
    final lineColor = widget.lineColor ??
        (isPositive ? theme.positive : theme.negative);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _SparklinePainter(
            values: widget.values,
            lineColor: lineColor,
            fillColor: widget.fillColor ?? lineColor.withValues(alpha: 0.2),
            strokeWidth: widget.strokeWidth,
            glowIntensity: (1 - _animation.value) * 0.5,
          ),
        );
      },
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;
  final double strokeWidth;
  final double glowIntensity;

  _SparklinePainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
    required this.strokeWidth,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    final effectiveRange = range == 0 ? 1.0 : range;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height -
          ((values[i] - minValue) / effectiveRange) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw glow if active
    if (glowIntensity > 0) {
      final glowPaint = Paint()
        ..color = lineColor.withValues(alpha: glowIntensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(path, glowPaint);
    }

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Draw end dot with pulse
    if (values.length > 1) {
      final lastX = size.width;
      final lastY = size.height -
          ((values.last - minValue) / effectiveRange) * size.height;

      if (glowIntensity > 0) {
        final dotGlowPaint = Paint()
          ..color = lineColor.withValues(alpha: glowIntensity)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(lastX, lastY), 4 + glowIntensity * 4, dotGlowPaint);
      }

      final dotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(lastX, lastY), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.glowIntensity != glowIntensity;
  }
}

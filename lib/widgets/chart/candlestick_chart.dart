import 'package:flutter/material.dart';
import '../../models/chart_data.dart';
import '../../theme/app_themes.dart';
import '../../core/number_formatter.dart';

class CandlestickChart extends StatefulWidget {
  final List<CandleData> candles;
  final bool showCrosshair;
  final bool showTooltip;

  const CandlestickChart({
    super.key,
    required this.candles,
    this.showCrosshair = true,
    this.showTooltip = true,
  });

  @override
  State<CandlestickChart> createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<CandlestickChart> {
  Offset? _hoverPosition;
  int? _hoveredCandleIndex;

  @override
  void didUpdateWidget(CandlestickChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset hover state if candles list changed to prevent stale index
    if (widget.candles.length != oldWidget.candles.length) {
      _hoveredCandleIndex = null;
      _hoverPosition = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    if (widget.candles.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: theme.textSecondary),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (event) {
            setState(() {
              _hoverPosition = event.localPosition;
              _hoveredCandleIndex = _getCandleIndexAtPosition(
                event.localPosition.dx,
                constraints.maxWidth,
              );
            });
          },
          onExit: (_) {
            setState(() {
              _hoverPosition = null;
              _hoveredCandleIndex = null;
            });
          },
          child: Stack(
            children: [
              // Chart
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _CandlestickPainter(
                  candles: widget.candles,
                  hoveredIndex: _hoveredCandleIndex,
                  theme: theme,
                ),
              ),
              // Crosshair
              if (widget.showCrosshair && _hoverPosition != null)
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _CrosshairPainter(
                    position: _hoverPosition!,
                    candles: widget.candles,
                    theme: theme,
                  ),
                ),
              // Tooltip (with bounds check to prevent index errors)
              if (widget.showTooltip &&
                  _hoveredCandleIndex != null &&
                  _hoveredCandleIndex! < widget.candles.length)
                _buildTooltip(constraints, theme),
            ],
          ),
        );
      },
    );
  }

  int? _getCandleIndexAtPosition(double x, double width) {
    if (widget.candles.isEmpty) return null;

    final candleWidth = width / (widget.candles.length * 1.5);
    final spacing = candleWidth * 0.5;
    final totalWidth = candleWidth + spacing;

    final index = ((x - spacing / 2) / totalWidth).floor();
    if (index >= 0 && index < widget.candles.length) {
      return index;
    }
    return null;
  }

  Widget _buildTooltip(BoxConstraints constraints, AppThemeData theme) {
    // Safety check in case candles list changed
    if (_hoveredCandleIndex == null || _hoveredCandleIndex! >= widget.candles.length) {
      return const SizedBox.shrink();
    }
    final candle = widget.candles[_hoveredCandleIndex!];
    final isRight = (_hoverPosition?.dx ?? 0) > constraints.maxWidth / 2;

    return Positioned(
      top: 8,
      left: isRight ? 8 : null,
      right: isRight ? null : 8,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.card.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatTime(candle.timestamp),
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            _TooltipRow(
              label: 'O',
              value: NumberFormatter.formatPrice(candle.open),
              color: theme.textPrimary,
            ),
            _TooltipRow(
              label: 'H',
              value: NumberFormatter.formatPrice(candle.high),
              color: theme.positive,
            ),
            _TooltipRow(
              label: 'L',
              value: NumberFormatter.formatPrice(candle.low),
              color: theme.negative,
            ),
            _TooltipRow(
              label: 'C',
              value: NumberFormatter.formatPrice(candle.close),
              color: candle.isBullish ? theme.positive : theme.negative,
            ),
            Divider(color: theme.border, height: 12),
            _TooltipRow(
              label: 'Vol',
              value: NumberFormatter.formatVolume(candle.volume),
              color: theme.cyan,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class _TooltipRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TooltipRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _CandlestickPainter extends CustomPainter {
  final List<CandleData> candles;
  final int? hoveredIndex;
  final AppThemeData theme;

  _CandlestickPainter({
    required this.candles,
    this.hoveredIndex,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    // Find min and max prices for scaling
    double minPrice = candles.first.low.toDouble();
    double maxPrice = candles.first.high.toDouble();

    for (final candle in candles) {
      final low = candle.low.toDouble();
      final high = candle.high.toDouble();
      if (low < minPrice) minPrice = low;
      if (high > maxPrice) maxPrice = high;
    }

    // Add padding to min/max
    final padding = (maxPrice - minPrice) * 0.1;
    minPrice -= padding;
    maxPrice += padding;

    final priceRange = maxPrice - minPrice;
    if (priceRange == 0) return;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = theme.border.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw border
    final borderPaint = Paint()
      ..color = theme.border
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      borderPaint,
    );

    // Calculate candle width and spacing
    final candleWidth = size.width / (candles.length * 1.5);
    final spacing = candleWidth * 0.5;

    // Draw candles
    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = spacing + (i * (candleWidth + spacing));

      final open = candle.open.toDouble();
      final close = candle.close.toDouble();
      final high = candle.high.toDouble();
      final low = candle.low.toDouble();

      final isBullish = candle.isBullish;
      final isHovered = i == hoveredIndex;
      var color = isBullish ? theme.positive : theme.negative;

      // Highlight hovered candle
      if (isHovered) {
        color = color.withValues(alpha: 1.0);
      } else if (hoveredIndex != null) {
        color = color.withValues(alpha: 0.5);
      }

      // Convert prices to y coordinates
      final openY = size.height - ((open - minPrice) / priceRange * size.height);
      final closeY = size.height - ((close - minPrice) / priceRange * size.height);
      final highY = size.height - ((high - minPrice) / priceRange * size.height);
      final lowY = size.height - ((low - minPrice) / priceRange * size.height);

      // Draw glow for hovered candle
      if (isHovered) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        final bodyTop = isBullish ? closeY : openY;
        final bodyBottom = isBullish ? openY : closeY;
        final bodyHeight = (bodyBottom - bodyTop).abs().clamp(1.0, double.infinity);

        canvas.drawRect(
          Rect.fromLTWH(x - 4, bodyTop - 4, candleWidth + 8, bodyHeight + 8),
          glowPaint,
        );
      }

      // Draw wick (high-low line)
      final wickPaint = Paint()
        ..color = color
        ..strokeWidth = isHovered ? 2 : 1;

      canvas.drawLine(
        Offset(x + candleWidth / 2, highY),
        Offset(x + candleWidth / 2, lowY),
        wickPaint,
      );

      // Draw body (open-close rectangle)
      final bodyPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final bodyTop = isBullish ? closeY : openY;
      final bodyBottom = isBullish ? openY : closeY;
      final bodyHeight = (bodyBottom - bodyTop).abs().clamp(1.0, double.infinity);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, bodyTop, candleWidth, bodyHeight),
          const Radius.circular(1),
        ),
        bodyPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) {
    return oldDelegate.candles != candles || oldDelegate.hoveredIndex != hoveredIndex || oldDelegate.theme != theme;
  }
}

class _CrosshairPainter extends CustomPainter {
  final Offset position;
  final List<CandleData> candles;
  final AppThemeData theme;

  _CrosshairPainter({
    required this.position,
    required this.candles,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.textSecondary.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Dashed line effect
    const dashWidth = 4.0;
    const dashSpace = 4.0;

    // Vertical line
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(position.dx, startY),
        Offset(position.dx, (startY + dashWidth).clamp(0, size.height)),
        paint,
      );
      startY += dashWidth + dashSpace;
    }

    // Horizontal line
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, position.dy),
        Offset((startX + dashWidth).clamp(0, size.width), position.dy),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    // Draw price label on right
    if (candles.isNotEmpty) {
      double minPrice = candles.first.low.toDouble();
      double maxPrice = candles.first.high.toDouble();

      for (final candle in candles) {
        final low = candle.low.toDouble();
        final high = candle.high.toDouble();
        if (low < minPrice) minPrice = low;
        if (high > maxPrice) maxPrice = high;
      }

      final padding = (maxPrice - minPrice) * 0.1;
      minPrice -= padding;
      maxPrice += padding;

      final price = maxPrice - (position.dy / size.height) * (maxPrice - minPrice);
      final priceText = '\$${price.toStringAsFixed(2)}';

      final textPainter = TextPainter(
        text: TextSpan(
          text: priceText,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Background for price label
      final labelRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width - textPainter.width - 8,
          position.dy - textPainter.height / 2 - 2,
          textPainter.width + 6,
          textPainter.height + 4,
        ),
        const Radius.circular(3),
      );

      canvas.drawRRect(
        labelRect,
        Paint()..color = theme.surface,
      );

      textPainter.paint(
        canvas,
        Offset(size.width - textPainter.width - 5, position.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CrosshairPainter oldDelegate) {
    return oldDelegate.position != position || oldDelegate.theme != theme;
  }
}

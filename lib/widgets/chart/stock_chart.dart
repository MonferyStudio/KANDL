import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import '../../models/chart_data.dart';
import '../../l10n/app_localizations.dart';
import 'timeframe_selector.dart';
import 'volume_bars.dart';
import 'line_chart_widget.dart';
import 'candlestick_chart.dart';

enum ChartType { candlestick, line }
enum PositionDisplayMode { averaged, individual }

class StockChart extends StatefulWidget {
  final String companyId;

  const StockChart({
    super.key,
    required this.companyId,
  });

  @override
  State<StockChart> createState() => _StockChartState();
}

class _StockChartState extends State<StockChart> {
  ChartType _chartType = ChartType.candlestick;
  TimeFrame _selectedTimeframe = TimeFrame.thirtyMinutes;
  PositionDisplayMode _positionMode = PositionDisplayMode.averaged;

  // Zoom/pan state
  int _visibleCandleCount = 40;
  int _scrollOffset = 0; // 0 = most recent candles visible
  double _lastScaleWidth = 0; // track chart width for drag sensitivity

  List<CandleData> _getVisibleCandles(List<CandleData> allCandles) {
    final total = allCandles.length;
    if (total == 0) return allCandles;
    final visible = _visibleCandleCount.clamp(10, total);
    final offset = _scrollOffset.clamp(0, total - visible);
    final end = total - offset;
    final start = (end - visible).clamp(0, total);
    return allCandles.sublist(start, end);
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, int totalCandles) {
    setState(() {
      // Pinch zoom
      if (details.pointerCount >= 2) {
        final scaleFactor = details.horizontalScale;
        if (scaleFactor != 1.0) {
          final newCount = (_visibleCandleCount / scaleFactor).round();
          _visibleCandleCount = newCount.clamp(10, totalCandles);
        }
      } else {
        // Horizontal pan
        final sensitivity = _lastScaleWidth > 0
            ? totalCandles / _lastScaleWidth * 0.5
            : 0.1;
        final delta = (details.focalPointDelta.dx * sensitivity).round();
        _scrollOffset = (_scrollOffset + delta).clamp(
          0,
          (totalCandles - _visibleCandleCount.clamp(10, totalCandles)),
        );
      }
    });
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // Claim the event so it doesn't scroll the parent page
      GestureBinding.instance.pointerSignalResolver.register(event, (event) {
        setState(() {
          final zoomDelta = (event as PointerScrollEvent).scrollDelta.dy > 0 ? 5 : -5;
          _visibleCandleCount = (_visibleCandleCount + zoomDelta).clamp(10, 500);
        });
      });
    }
  }

  void _resetZoom(int totalCandles) {
    setState(() {
      _visibleCandleCount = totalCandles;
      _scrollOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Consumer<GameService>(
      builder: (context, game, _) {
        final stockState = game.getStockState(widget.companyId);
        if (stockState == null) {
          return Center(
            child: Text(
              'Stock not found',
              style: TextStyle(color: theme.textSecondary),
            ),
          );
        }

        final allCandles = stockState.getCandles(_selectedTimeframe);
        final visibleCandles = _getVisibleCandles(allCandles);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with chart type toggle and timeframe selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Chart type toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ChartTypeButton(
                          icon: Icons.candlestick_chart,
                          isActive: _chartType == ChartType.candlestick,
                          onTap: () => setState(() => _chartType = ChartType.candlestick),
                        ),
                        _ChartTypeButton(
                          icon: Icons.show_chart,
                          isActive: _chartType == ChartType.line,
                          onTap: () => setState(() => _chartType = ChartType.line),
                        ),
                      ],
                    ),
                  ),

                  // Timeframe selector
                  TimeframeSelector(
                    selectedTimeframe: _selectedTimeframe,
                    onTimeframeChanged: (timeframe) {
                      setState(() => _selectedTimeframe = timeframe);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Chart with position overlay + zoom/pan gestures
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    _lastScaleWidth = constraints.maxWidth;
                    return Listener(
                      onPointerSignal: _handlePointerSignal,
                      child: GestureDetector(
                        onScaleUpdate: (details) => _handleScaleUpdate(details, allCandles.length),
                        onDoubleTap: () => _resetZoom(allCandles.length),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Main chart
                            _chartType == ChartType.candlestick
                                ? CandlestickChart(candles: visibleCandles)
                                : LineChartWidget(candles: visibleCandles),

                            // Position price lines + labels
                            _PositionOverlay(
                              companyId: widget.companyId,
                              currentPrice: stockState.currentPrice,
                              candles: visibleCandles,
                              chartHeight: constraints.maxHeight,
                              chartWidth: constraints.maxWidth,
                              mode: _positionMode,
                              onToggleMode: () {
                                setState(() {
                                  _positionMode = _positionMode == PositionDisplayMode.averaged
                                      ? PositionDisplayMode.individual
                                      : PositionDisplayMode.averaged;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Volume bars
              VolumeBars(candles: visibleCandles),
            ],
          ),
        );
      },
    );
  }
}

class _ChartTypeButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ChartTypeButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? theme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? theme.background : theme.textSecondary,
        ),
      ),
    );
  }
}

/// Helper: compute min/max prices from candles (same formula as _CandlestickPainter)
({double minPrice, double maxPrice}) _chartPriceRange(List<CandleData> candles) {
  if (candles.isEmpty) return (minPrice: 0, maxPrice: 1);
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
  return (minPrice: minPrice, maxPrice: maxPrice);
}

/// Convert a price to Y coordinate on the chart
double _priceToY(double price, double minPrice, double maxPrice, double chartHeight) {
  final priceRange = maxPrice - minPrice;
  if (priceRange == 0) return chartHeight / 2;
  return chartHeight - ((price - minPrice) / priceRange * chartHeight);
}

/// Overlay that shows position markers at their price levels on the chart
class _PositionOverlay extends StatelessWidget {
  final String companyId;
  final BigNumber currentPrice;
  final List<CandleData> candles;
  final double chartHeight;
  final double chartWidth;
  final PositionDisplayMode mode;
  final VoidCallback onToggleMode;

  const _PositionOverlay({
    required this.companyId,
    required this.currentPrice,
    required this.candles,
    required this.chartHeight,
    required this.chartWidth,
    required this.mode,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);

    return Consumer<GameService>(
      builder: (context, game, _) {
        final position = game.positions
            .where((p) => p.company.id == companyId && p.hasShares)
            .firstOrNull;

        if (position == null || candles.isEmpty) {
          return const SizedBox.shrink();
        }

        final range = _chartPriceRange(candles);
        final isLong = position.type == PositionType.long;
        final pnl = position.unrealizedPnL(currentPrice);
        final pnlPercent = position.unrealizedPnLPercent(currentPrice);
        final isPositive = !pnl.isNegative;

        final List<Widget> children = [];

        if (mode == PositionDisplayMode.averaged) {
          // Single line at average cost
          final avgPrice = position.averageCost.toDouble();
          final y = _priceToY(avgPrice, range.minPrice, range.maxPrice, chartHeight);

          children.add(_buildPriceLine(
            y: y,
            color: isPositive ? theme.positive : theme.negative,
            chartWidth: chartWidth,
          ));

          children.add(_buildPositionLabel(
            y: y,
            theme: theme,
            l10n: l10n,
            isLong: isLong,
            isPositive: isPositive,
            shares: position.shares,
            price: position.averageCost,
            pnl: pnl,
            pnlPercent: pnlPercent,
          ));
        } else {
          // Individual trade entries (only open buys/shorts, not sells)
          final entryTrades = position.trades.where((t) =>
            isLong ? t.isBuy : t.isShort
          ).toList();

          for (final trade in entryTrades) {
            final tradePrice = trade.pricePerShare.toDouble();
            final y = _priceToY(tradePrice, range.minPrice, range.maxPrice, chartHeight);
            final tradePnl = isLong
                ? (currentPrice - trade.pricePerShare).multiplyByDouble(trade.shares)
                : (trade.pricePerShare - currentPrice).multiplyByDouble(trade.shares);
            final tradeIsPositive = !tradePnl.isNegative;

            children.add(_buildPriceLine(
              y: y,
              color: tradeIsPositive ? theme.positive : theme.negative,
              chartWidth: chartWidth,
              isDashed: true,
            ));

            children.add(_buildTradeLabel(
              y: y,
              theme: theme,
              isPositive: tradeIsPositive,
              shares: trade.shares,
              price: trade.pricePerShare,
              pnl: tradePnl,
            ));
          }
        }

        // SL/TP price lines
        final avgPrice = position.averageCost.toDouble();
        if (game.stopLossEnabled && game.hasStopLoss) {
          final slPrice = isLong
              ? avgPrice * (1 - game.stopLossPercent)
              : avgPrice * (1 + game.stopLossPercent);
          final slY = _priceToY(slPrice, range.minPrice, range.maxPrice, chartHeight);

          children.add(_buildPriceLine(
            y: slY,
            color: theme.negative.withValues(alpha: 0.6),
            chartWidth: chartWidth,
            isDashed: true,
          ));
          children.add(_buildSLTPLabel(
            y: slY,
            text: 'SL ${(game.stopLossPercent * 100).toStringAsFixed(0)}%',
            color: theme.negative,
            theme: theme,
          ));
        }
        if (game.takeProfitEnabled && game.hasTakeProfit) {
          final tpPrice = isLong
              ? avgPrice * (1 + game.takeProfitPercent)
              : avgPrice * (1 - game.takeProfitPercent);
          final tpY = _priceToY(tpPrice, range.minPrice, range.maxPrice, chartHeight);

          children.add(_buildPriceLine(
            y: tpY,
            color: theme.positive.withValues(alpha: 0.6),
            chartWidth: chartWidth,
            isDashed: true,
          ));
          children.add(_buildSLTPLabel(
            y: tpY,
            text: 'TP ${(game.takeProfitPercent * 100).toStringAsFixed(0)}%',
            color: theme.positive,
            theme: theme,
          ));
        }

        // Toggle button (top-right)
        children.add(Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onToggleMode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: theme.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: theme.border, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mode == PositionDisplayMode.averaged
                        ? Icons.compress
                        : Icons.expand,
                    size: 12,
                    color: theme.textSecondary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    mode == PositionDisplayMode.averaged
                        ? l10n.get('position_averaged')
                        : l10n.get('position_individual'),
                    style: TextStyle(
                      fontSize: 9,
                      color: theme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));

        // Summary P&L badge (top-left)
        children.add(Positioned(
          top: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.card.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: (isPositive ? theme.positive : theme.negative).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: (isLong ? theme.positive : theme.negative).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    isLong ? 'LONG' : 'SHORT',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: isLong ? theme.positive : theme.negative,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${position.shares.toStringAsFixed(0)} ${l10n.shares}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 12,
                  color: isPositive ? theme.positive : theme.negative,
                ),
                const SizedBox(width: 2),
                Text(
                  '${NumberFormatter.format(pnl, showSign: true)} (${pnlPercent >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? theme.positive : theme.negative,
                  ),
                ),
              ],
            ),
          ),
        ));

        return Stack(children: children);
      },
    );
  }

  Widget _buildPriceLine({
    required double y,
    required Color color,
    required double chartWidth,
    bool isDashed = false,
  }) {
    // Clamp Y to chart bounds
    final clampedY = y.clamp(0.0, chartHeight);
    return Positioned(
      top: clampedY,
      left: 0,
      right: 0,
      child: CustomPaint(
        size: Size(chartWidth, 1),
        painter: _DashedLinePainter(
          color: color.withValues(alpha: isDashed ? 0.5 : 0.7),
          dashWidth: isDashed ? 4 : 6,
          dashSpace: isDashed ? 4 : 3,
        ),
      ),
    );
  }

  Widget _buildPositionLabel({
    required double y,
    required AppThemeData theme,
    required AppLocalizations l10n,
    required bool isLong,
    required bool isPositive,
    required double shares,
    required BigNumber price,
    required BigNumber pnl,
    required double pnlPercent,
  }) {
    // Position label on the right, vertically centered on the price line
    final clampedY = y.clamp(20.0, chartHeight - 20.0);
    final color = isPositive ? theme.positive : theme.negative;

    return Positioned(
      top: clampedY - 10,
      right: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: theme.card.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
        ),
        child: Text(
          'AVG ${NumberFormatter.formatPrice(price)}',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _buildTradeLabel({
    required double y,
    required AppThemeData theme,
    required bool isPositive,
    required double shares,
    required BigNumber price,
    required BigNumber pnl,
  }) {
    final clampedY = y.clamp(20.0, chartHeight - 20.0);
    final color = isPositive ? theme.positive : theme.negative;

    return Positioned(
      top: clampedY - 9,
      right: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: theme.card.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        ),
        child: Text(
          '${shares.toStringAsFixed(0)}x ${NumberFormatter.formatPrice(price)}',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _buildSLTPLabel({
    required double y,
    required String text,
    required Color color,
    required AppThemeData theme,
  }) {
    final clampedY = y.clamp(20.0, chartHeight - 20.0);

    return Positioned(
      top: clampedY - 9,
      left: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

/// Paints a dashed horizontal line
class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  _DashedLinePainter({
    required this.color,
    this.dashWidth = 6,
    this.dashSpace = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset((startX + dashWidth).clamp(0, size.width), 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) {
    return old.color != color || old.dashWidth != dashWidth || old.dashSpace != dashSpace;
  }
}

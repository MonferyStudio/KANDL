import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/chart_data.dart';
import '../../theme/app_themes.dart';

class LineChartWidget extends StatelessWidget {
  final List<CandleData> candles;

  const LineChartWidget({
    super.key,
    required this.candles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    if (candles.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: theme.textSecondary),
        ),
      );
    }

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

    return LineChart(
      LineChartData(
        minY: minPrice,
        maxY: maxPrice,
        lineTouchData: LineTouchData(enabled: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: theme.border, width: 1),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxPrice - minPrice) / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.border.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
        lineBarsData: [
          LineChartBarData(
            spots: candles.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.close.toDouble(),
              );
            }).toList(),
            isCurved: true,
            color: theme.cyan,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  theme.cyan.withValues(alpha: 0.3),
                  theme.cyan.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

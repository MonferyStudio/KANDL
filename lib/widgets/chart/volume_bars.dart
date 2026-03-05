import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/chart_data.dart';
import '../../theme/app_themes.dart';

class VolumeBars extends StatelessWidget {
  final List<CandleData> candles;

  const VolumeBars({
    super.key,
    required this.candles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    if (candles.isEmpty) {
      return const SizedBox(height: 60);
    }

    // Find max volume for scaling
    final maxVolume = candles.fold<double>(
      0,
      (max, candle) => candle.volume.toDouble() > max ? candle.volume.toDouble() : max,
    );

    if (maxVolume == 0) {
      return const SizedBox(height: 60);
    }

    return SizedBox(
      height: 60,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: maxVolume,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          barGroups: candles.asMap().entries.map((entry) {
            final index = entry.key;
            final candle = entry.value;
            final volume = candle.volume.toDouble();
            final color = candle.isBullish ? theme.positive : theme.negative;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: volume,
                  color: color.withValues(alpha: 0.3),
                  width: 2,
                  borderRadius: BorderRadius.zero,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

import '../core/core.dart';

/// Represents a candlestick data point with OHLC values
class CandleData {
  final DateTime timestamp;
  final BigNumber open;
  final BigNumber high;
  final BigNumber low;
  final BigNumber close;
  final BigNumber volume;

  CandleData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  /// Returns true if the candle closed higher than it opened (bullish)
  bool get isBullish => close >= open;

  /// Returns the percentage change from open to close
  double get changePercent {
    if (open.isZero) return 0.0;
    final change = close - open;
    return (change.toDouble() / open.toDouble()) * 100;
  }
}

/// Configuration for chart timeframes (in-game time)
/// Game timing: 300 real seconds = 11 in-game hours (660 minutes)
/// 1 in-game minute = 300/660 = 0.4545 real seconds
class TimeframeConfig {
  final TimeFrame timeframe;
  final String label;
  final int secondsPerCandle; // Real seconds per candle
  final int maxCandles;
  final int inGameMinutes; // In-game minutes this represents

  const TimeframeConfig({
    required this.timeframe,
    required this.label,
    required this.secondsPerCandle,
    required this.inGameMinutes,
    this.maxCandles = 100,
  });

  /// Convert in-game minutes to real seconds
  /// 660 in-game minutes = 300 real seconds
  static int inGameMinutesToRealSeconds(int minutes) {
    return (minutes * 300 / 660).round();
  }

  /// Predefined configurations for all supported timeframes (in-game time)
  static final configs = {
    // 30 min in-game = ~14 real seconds
    TimeFrame.thirtyMinutes: TimeframeConfig(
      timeframe: TimeFrame.thirtyMinutes,
      label: '30m',
      secondsPerCandle: inGameMinutesToRealSeconds(30),
      inGameMinutes: 30,
      maxCandles: 100,
    ),
    // 1 hour in-game = ~27 real seconds
    TimeFrame.oneHour: TimeframeConfig(
      timeframe: TimeFrame.oneHour,
      label: '1h',
      secondsPerCandle: inGameMinutesToRealSeconds(60),
      inGameMinutes: 60,
      maxCandles: 100,
    ),
    // 2 hours in-game = ~55 real seconds
    TimeFrame.twoHours: TimeframeConfig(
      timeframe: TimeFrame.twoHours,
      label: '2h',
      secondsPerCandle: inGameMinutesToRealSeconds(120),
      inGameMinutes: 120,
      maxCandles: 100,
    ),
    // 4 hours in-game = ~109 real seconds
    TimeFrame.fourHours: TimeframeConfig(
      timeframe: TimeFrame.fourHours,
      label: '4h',
      secondsPerCandle: inGameMinutesToRealSeconds(240),
      inGameMinutes: 240,
      maxCandles: 100,
    ),
  };
}

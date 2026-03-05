/// Market-wide indicators and metrics
class MarketIndicators {
  final double fearGreedIndex; // 0-100 (0=Extreme Fear, 100=Extreme Greed)
  final double marketBreadth; // -1 to 1 (% advancing - % declining)
  final int advancingStocks;
  final int decliningStocks;
  final int unchangedStocks;
  final int newHighs; // Stocks at 52-week high
  final int newLows; // Stocks at 52-week low
  final double volatilityIndex; // VIX-like metric
  final Map<String, double> sectorRotation; // Sector performance rankings
  final DateTime timestamp;

  const MarketIndicators({
    required this.fearGreedIndex,
    required this.marketBreadth,
    required this.advancingStocks,
    required this.decliningStocks,
    required this.unchangedStocks,
    required this.newHighs,
    required this.newLows,
    required this.volatilityIndex,
    required this.sectorRotation,
    required this.timestamp,
  });

  /// Get Fear & Greed sentiment label
  String get fearGreedLabel {
    if (fearGreedIndex >= 80) return 'Extreme Greed';
    if (fearGreedIndex >= 60) return 'Greed';
    if (fearGreedIndex > 40) return 'Neutral';
    if (fearGreedIndex > 20) return 'Fear';
    return 'Extreme Fear';
  }

  /// Get market breadth label
  String get breadthLabel {
    if (marketBreadth > 0.3) return 'Very Bullish';
    if (marketBreadth > 0.1) return 'Bullish';
    if (marketBreadth > -0.1) return 'Mixed';
    if (marketBreadth > -0.3) return 'Bearish';
    return 'Very Bearish';
  }

  /// Get volatility label
  String get volatilityLabel {
    if (volatilityIndex < 15) return 'Low';
    if (volatilityIndex < 25) return 'Normal';
    if (volatilityIndex < 35) return 'Elevated';
    return 'High';
  }

  /// Get top performing sector
  String? get leadingSector {
    if (sectorRotation.isEmpty) return null;
    final sorted = sectorRotation.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  /// Get worst performing sector
  String? get laggingSector {
    if (sectorRotation.isEmpty) return null;
    final sorted = sectorRotation.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return sorted.first.key;
  }

  /// Calculate overall market health score (0-100)
  double get marketHealthScore {
    double score = 0.0;

    // Fear & Greed contributes 30%
    score += (fearGreedIndex / 100) * 30;

    // Market breadth contributes 30%
    score += ((marketBreadth + 1) / 2) * 30;

    // New highs vs lows contributes 20%
    final total = newHighs + newLows;
    if (total > 0) {
      score += (newHighs / total) * 20;
    } else {
      score += 10; // Neutral
    }

    // Volatility (inverse) contributes 20%
    final volScore = (50 - volatilityIndex).clamp(0, 50) / 50;
    score += volScore * 20;

    return score.clamp(0, 100);
  }
}

/// Market regime classification
enum MarketRegime {
  strongBear,  // Extreme bearish conditions
  bear,        // Bearish conditions
  neutral,     // Sideways/mixed market
  bull,        // Bullish conditions
  strongBull,  // Extreme bullish conditions
}

/// Market regime data with historical tracking
class MarketRegimeData {
  final MarketRegime currentRegime;
  final double regimeStrength; // -1 to 1 (-1 = very bearish, +1 = very bullish)
  final int daysInCurrentRegime;
  final DateTime lastRegimeChange;
  final MarketRegime? previousRegime;

  const MarketRegimeData({
    required this.currentRegime,
    required this.regimeStrength,
    required this.daysInCurrentRegime,
    required this.lastRegimeChange,
    this.previousRegime,
  });

  /// Get regime label
  String get regimeLabel {
    switch (currentRegime) {
      case MarketRegime.strongBull:
        return 'Strong Bull';
      case MarketRegime.bull:
        return 'Bull Market';
      case MarketRegime.neutral:
        return 'Neutral';
      case MarketRegime.bear:
        return 'Bear Market';
      case MarketRegime.strongBear:
        return 'Strong Bear';
    }
  }

  /// Get regime emoji
  String get regimeEmoji {
    switch (currentRegime) {
      case MarketRegime.strongBull:
        return '🚀';
      case MarketRegime.bull:
        return '📈';
      case MarketRegime.neutral:
        return '➡️';
      case MarketRegime.bear:
        return '📉';
      case MarketRegime.strongBear:
        return '💥';
    }
  }

  /// Get regime description
  String get description {
    switch (currentRegime) {
      case MarketRegime.strongBull:
        return 'Extreme optimism. Stocks trending strongly upward.';
      case MarketRegime.bull:
        return 'Positive sentiment. Stocks generally rising.';
      case MarketRegime.neutral:
        return 'Mixed signals. Market lacks clear direction.';
      case MarketRegime.bear:
        return 'Negative sentiment. Stocks generally falling.';
      case MarketRegime.strongBear:
        return 'Extreme pessimism. Stocks trending strongly downward.';
    }
  }

  /// Influence on stock prices (multiplier)
  double get priceInfluence {
    switch (currentRegime) {
      case MarketRegime.strongBull:
        return 1.25;  // Reduced from 1.5 - 25% stronger upward moves
      case MarketRegime.bull:
        return 1.1;  // Reduced from 1.2 - 10% stronger upward moves
      case MarketRegime.neutral:
        return 1.0;  // No influence
      case MarketRegime.bear:
        return 0.9;  // Changed from 0.8 - 10% more downward pressure
      case MarketRegime.strongBear:
        return 0.75;  // Changed from 0.5 - 25% more downward pressure
    }
  }

  /// Volatility multiplier based on regime
  double get volatilityMultiplier {
    switch (currentRegime) {
      case MarketRegime.strongBull:
      case MarketRegime.strongBear:
        return 1.15;  // Reduced from 1.3 - more volatile in extremes
      case MarketRegime.bull:
      case MarketRegime.bear:
        return 1.05;  // Reduced from 1.1 - slightly more volatile
      case MarketRegime.neutral:
        return 1.0;  // Normal volatility
    }
  }

  /// Check if in bullish regime
  bool get isBullish => currentRegime == MarketRegime.bull ||
                        currentRegime == MarketRegime.strongBull;

  /// Check if in bearish regime
  bool get isBearish => currentRegime == MarketRegime.bear ||
                        currentRegime == MarketRegime.strongBear;
}

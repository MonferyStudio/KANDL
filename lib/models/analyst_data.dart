enum AnalystRating {
  strongBuy,
  buy,
  hold,
  sell,
  strongSell,
}

/// Analyst consensus data for a stock
class AnalystData {
  final String companyId;
  final AnalystRating consensusRating;
  final int buyRatings;
  final int holdRatings;
  final int sellRatings;
  final double priceTargetHigh;
  final double priceTargetLow;
  final double priceTargetAverage;
  final DateTime lastUpdated;

  const AnalystData({
    required this.companyId,
    required this.consensusRating,
    required this.buyRatings,
    required this.holdRatings,
    required this.sellRatings,
    required this.priceTargetHigh,
    required this.priceTargetLow,
    required this.priceTargetAverage,
    required this.lastUpdated,
  });

  int get totalRatings => buyRatings + holdRatings + sellRatings;

  String get ratingLabel {
    switch (consensusRating) {
      case AnalystRating.strongBuy:
        return 'Strong Buy';
      case AnalystRating.buy:
        return 'Buy';
      case AnalystRating.hold:
        return 'Hold';
      case AnalystRating.sell:
        return 'Sell';
      case AnalystRating.strongSell:
        return 'Strong Sell';
    }
  }

  /// Get upside/downside potential from current price
  double getUpsidePotential(double currentPrice) {
    if (currentPrice == 0) return 0.0;
    return ((priceTargetAverage - currentPrice) / currentPrice) * 100;
  }
}

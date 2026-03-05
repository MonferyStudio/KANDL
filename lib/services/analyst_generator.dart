import 'dart:math';
import '../models/analyst_data.dart';
import '../models/stock_state.dart';

class AnalystGenerator {
  static final Random _random = Random();

  /// Generate analyst data based on stock performance and characteristics
  static AnalystData generateAnalystData(StockState state) {
    final company = state.company;
    final currentPrice = state.currentPrice.toDouble();

    // Base number of analysts (more for blue chips)
    int numAnalysts = company.isBlueChip ? 15 + _random.nextInt(10) : 5 + _random.nextInt(8);

    // Determine sentiment based on recent performance and fundamentals
    double sentiment = _calculateSentiment(state);

    // Generate ratings distribution based on sentiment
    final ratings = _generateRatings(numAnalysts, sentiment);

    // Generate price targets based on current price and sentiment
    final priceTargets = _generatePriceTargets(currentPrice, sentiment, company.volatility);

    // Determine consensus rating
    final consensusRating = _determineConsensus(ratings['buy']!, ratings['hold']!, ratings['sell']!);

    return AnalystData(
      companyId: company.id,
      consensusRating: consensusRating,
      buyRatings: ratings['buy']!,
      holdRatings: ratings['hold']!,
      sellRatings: ratings['sell']!,
      priceTargetHigh: priceTargets['high']!,
      priceTargetLow: priceTargets['low']!,
      priceTargetAverage: priceTargets['average']!,
      lastUpdated: DateTime.now(),
    );
  }

  /// Calculate overall sentiment score (-1 to 1)
  static double _calculateSentiment(StockState state) {
    double sentiment = 0.0;
    final company = state.company;

    // Factor 1: Recent price performance (30%)
    final dayChange = state.dayChangePercent;
    sentiment += (dayChange / 10).clamp(-0.3, 0.3);

    // Factor 2: RSI (20%)
    final rsi = state.rsi;
    if (rsi < 30) {
      sentiment += 0.2; // Oversold, bullish
    } else if (rsi > 70) {
      sentiment -= 0.2; // Overbought, bearish
    }

    // Factor 3: Position relative to 52-week range (20%)
    final distanceFromHigh = state.distanceFrom52WeekHigh;
    if (distanceFromHigh > -10) {
      sentiment += 0.15; // Near highs, bullish
    } else if (distanceFromHigh < -50) {
      sentiment += 0.05; // Deep discount, slightly bullish
    }

    // Factor 4: Company fundamentals (15%)
    if (company.isBlueChip) {
      sentiment += 0.1; // Blue chips are safer bets
    }
    if (company.isPennyStock) {
      sentiment -= 0.05; // Penny stocks are riskier
    }

    // Factor 5: P/E ratio (15%)
    if (company.peRatio < 15) {
      sentiment += 0.1; // Undervalued
    } else if (company.peRatio > 30) {
      sentiment -= 0.05; // Overvalued
    }

    // Random noise (±10%)
    sentiment += (_random.nextDouble() - 0.5) * 0.2;

    return sentiment.clamp(-1.0, 1.0);
  }

  /// Generate ratings distribution based on sentiment
  static Map<String, int> _generateRatings(int numAnalysts, double sentiment) {
    // Convert sentiment to buy probability
    // -1.0 sentiment = 0% buy, 0.0 = 50% buy, 1.0 = 100% buy
    double buyProb = (sentiment + 1.0) / 2.0;
    double sellProb = 1.0 - buyProb;

    int buyRatings = 0;
    int holdRatings = 0;
    int sellRatings = 0;

    for (int i = 0; i < numAnalysts; i++) {
      final rand = _random.nextDouble();

      if (rand < buyProb * 0.7) {
        buyRatings++;
      } else if (rand > 1.0 - sellProb * 0.5) {
        sellRatings++;
      } else {
        holdRatings++;
      }
    }

    // Ensure at least one rating exists
    if (buyRatings == 0 && holdRatings == 0 && sellRatings == 0) {
      holdRatings = 1;
    }

    return {
      'buy': buyRatings,
      'hold': holdRatings,
      'sell': sellRatings,
    };
  }

  /// Generate price targets
  static Map<String, double> _generatePriceTargets(
    double currentPrice,
    double sentiment,
    double volatility,
  ) {
    // Average target based on sentiment
    // Sentiment range: -1 to 1, target range: -20% to +30%
    final averageUpsidePercent = sentiment * 25; // -25% to +25%
    final averageTarget = currentPrice * (1.0 + averageUpsidePercent / 100);

    // High and low targets based on volatility
    final spread = currentPrice * volatility * 0.8; // More volatile = wider spread

    final highTarget = averageTarget + spread;
    final lowTarget = (averageTarget - spread).clamp(currentPrice * 0.5, double.infinity);

    return {
      'high': highTarget,
      'low': lowTarget,
      'average': averageTarget,
    };
  }

  /// Determine consensus rating from distribution
  static AnalystRating _determineConsensus(int buy, int hold, int sell) {
    final total = buy + hold + sell;
    if (total == 0) return AnalystRating.hold;

    final buyPercent = (buy / total) * 100;
    final sellPercent = (sell / total) * 100;

    if (buyPercent >= 70) {
      return AnalystRating.strongBuy;
    } else if (buyPercent >= 50) {
      return AnalystRating.buy;
    } else if (sellPercent >= 50) {
      return AnalystRating.sell;
    } else if (sellPercent >= 70) {
      return AnalystRating.strongSell;
    } else {
      return AnalystRating.hold;
    }
  }
}

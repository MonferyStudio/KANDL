import '../core/core.dart';

/// Breakdown of portfolio composition and risk metrics
class PortfolioBreakdown {
  // Sector allocation (sector name -> percentage of portfolio)
  final Map<String, double> sectorAllocation;
  final Map<String, BigNumber> sectorValues;

  // Position type breakdown
  final double longPercentage;
  final double shortPercentage;
  final BigNumber longValue;
  final BigNumber shortValue;

  // Diversification metrics
  final int totalPositions;
  final int distinctSectors;
  final double concentrationRisk; // 0-1, higher = more concentrated
  final BigNumber largestPositionValue;
  final String? largestPositionTicker;

  // Risk metrics
  final double portfolioVolatility; // Weighted average volatility
  final double avgPositionSize; // Average % per position

  const PortfolioBreakdown({
    required this.sectorAllocation,
    required this.sectorValues,
    required this.longPercentage,
    required this.shortPercentage,
    required this.longValue,
    required this.shortValue,
    required this.totalPositions,
    required this.distinctSectors,
    required this.concentrationRisk,
    required this.largestPositionValue,
    this.largestPositionTicker,
    required this.portfolioVolatility,
    required this.avgPositionSize,
  });

  /// Diversification score (0-100, higher = better diversified)
  double get diversificationScore {
    double score = 50.0; // Start neutral

    // More positions = better (up to 20 points)
    final positionScore = (totalPositions.clamp(1, 10) / 10) * 20;
    score += positionScore;

    // More sectors = better (up to 20 points)
    final sectorScore = (distinctSectors.clamp(1, 5) / 5) * 20;
    score += sectorScore;

    // Lower concentration = better (up to 30 points)
    final concentrationScore = (1 - concentrationRisk) * 30;
    score += concentrationScore;

    // Lower volatility = better (up to 30 points)
    final volScore = (1 - (portfolioVolatility.clamp(0, 2) / 2)) * 30;
    score += volScore;

    return score.clamp(0, 100);
  }

  /// Diversification label
  String get diversificationLabel {
    final score = diversificationScore;
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Poor';
    return 'Very Poor';
  }

  /// Risk level based on concentration and volatility
  String get riskLevel {
    if (concentrationRisk > 0.7 || portfolioVolatility > 1.5) return 'High';
    if (concentrationRisk > 0.5 || portfolioVolatility > 1.0) return 'Medium';
    return 'Low';
  }

  /// Get top N sectors by allocation
  List<MapEntry<String, double>> getTopSectors(int n) {
    final sorted = sectorAllocation.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(n).toList();
  }
}

import '../core/core.dart';

/// Represents a company/stock with fake names
class CompanyData {
  final String id;
  final String name;
  final String ticker;
  final String description;
  final String sectorId;
  final double initialPrice;
  final double sharesOutstanding;
  final double peRatio;
  final double dividendYield;
  final double volatility;
  final double sectorCorrelation;
  final bool isBlueChip;
  final bool isPennyStock;
  final bool isMemeStock;
  final double earningsReactivity;
  final double newsReactivity;
  final CompanyTier tier; // Company tier for progression system

  const CompanyData({
    required this.id,
    required this.name,
    required this.ticker,
    this.description = '',
    required this.sectorId,
    required this.initialPrice,
    this.sharesOutstanding = 1000000000,
    this.peRatio = 20.0,
    this.dividendYield = 0.0,
    this.volatility = 1.0,
    this.sectorCorrelation = 0.7,
    this.isBlueChip = false,
    this.isPennyStock = false,
    this.isMemeStock = false,
    this.earningsReactivity = 1.0,
    this.newsReactivity = 1.0,
    this.tier = CompanyTier.starter, // Default to starter for backwards compatibility
  });

  BigNumber get initialPriceBN => BigNumber(initialPrice);
  BigNumber get initialMarketCap => BigNumber(initialPrice * sharesOutstanding);
  String get displayName => '$name ($ticker)';
}

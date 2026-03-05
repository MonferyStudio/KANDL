enum NewsCategory {
  earnings,
  market,
  sector,
  company,
  economy,
  regulation,
  merger,
  product,
  // Gameplay-affecting categories
  platform,      // Trading platform news (fees, features)
  bonus,         // Cash bonuses, rewards
  restriction,   // Trading restrictions (short ban, limits)
  event,         // Special events (flash sales, circuit breakers)
  informant,     // Informant tip purchases
}

/// Types of gameplay effects that news can trigger
enum GameplayEffectType {
  none,
  feeMultiplier,      // Multiply trading fees
  shortSellingBan,    // Disable short selling
  cashBonus,          // Give player cash
  upgradeDiscount,    // Discount on upgrades
  circuitBreaker,     // Pause trading temporarily
  volatilitySpike,    // Increase market volatility
  dividendBonus,      // Bonus on dividend income
  positionLimit,      // Limit max shares per position
  signalJammer,       // Inverts trading signals (On Sale ↔ Overheated, etc.)
  trendReversal,      // All sector trends reverse direction
  marketManipulation, // Random stock gets massive artificial price impact
}

enum NewsSentiment {
  veryPositive,
  positive,
  neutral,
  negative,
  veryNegative,
}

/// Represents a news item that affects the market
class NewsItem {
  final String id;
  final String headline;
  final String description;
  final NewsCategory category;
  final NewsSentiment sentiment;
  final DateTime timestamp;
  final String? companyId;
  final String? sectorId;
  final double impactMagnitude; // 0.0 to 1.0

  // Gameplay effect fields
  final GameplayEffectType effectType;
  final double effectValue; // Multiplier or amount depending on effect
  final int effectDurationDays; // How many days the effect lasts (0 = instant)

  // Localization fields
  final String? templateKey; // Key for looking up localized text
  final String? companyName; // For template substitution
  final String? sectorName; // For template substitution
  final int? quarter; // For template substitution

  const NewsItem({
    required this.id,
    required this.headline,
    required this.description,
    required this.category,
    required this.sentiment,
    required this.timestamp,
    this.companyId,
    this.sectorId,
    this.impactMagnitude = 0.5,
    this.effectType = GameplayEffectType.none,
    this.effectValue = 0.0,
    this.effectDurationDays = 0,
    this.templateKey,
    this.companyName,
    this.sectorName,
    this.quarter,
  });

  /// Whether this news has a gameplay effect
  bool get hasGameplayEffect => effectType != GameplayEffectType.none;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  String get categoryLabel {
    switch (category) {
      case NewsCategory.earnings:
        return 'Earnings';
      case NewsCategory.market:
        return 'Market';
      case NewsCategory.sector:
        return 'Sector';
      case NewsCategory.company:
        return 'Company';
      case NewsCategory.economy:
        return 'Economy';
      case NewsCategory.regulation:
        return 'Regulation';
      case NewsCategory.merger:
        return 'M&A';
      case NewsCategory.product:
        return 'Product';
      case NewsCategory.platform:
        return 'Platform';
      case NewsCategory.bonus:
        return 'Bonus';
      case NewsCategory.restriction:
        return 'Restriction';
      case NewsCategory.event:
        return 'Event';
      case NewsCategory.informant:
        return 'Informant';
    }
  }
}

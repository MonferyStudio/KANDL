/// Meta-progression system for permanent bonuses across all runs
/// These bonuses persist between prestiges and new games

/// Types of permanent bonuses
enum MetaBonusType {
  stockBonus,          // % bonus shares when buying
  commissionCut,       // % reduction on commission fees
  startingCash,        // Extra cash at start of each run
  quotaReduction,      // % reduction on all quotas
  informantVisitBonus, // % increased chance of informant visits
  fintokAccuracyBonus, // % increased FinTok tip accuracy
  luckyStartingShares, // Free shares at start of each run
  vipStatus,           // First upgrade of each year is Legendary
  // New types (added at end for save compatibility)
  upgradeLuck,         // % better rarity in upgrade shop
  insurance,           // % loss reduction on losing trades
  interestRate,        // % daily interest on cash
  extraReroll,         // Extra free rerolls in shop
}

/// A single meta bonus entry
class MetaBonus {
  final MetaBonusType type;
  final double value;
  final String sourceId; // Achievement ID or other source that granted this

  const MetaBonus({
    required this.type,
    required this.value,
    required this.sourceId,
  });

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'value': value,
    'sourceId': sourceId,
  };

  factory MetaBonus.fromJson(Map<String, dynamic> json) {
    final typeIndex = json['type'] as int;
    return MetaBonus(
      type: typeIndex < MetaBonusType.values.length
          ? MetaBonusType.values[typeIndex]
          : MetaBonusType.startingCash, // fallback for unknown types
      value: (json['value'] as num).toDouble(),
      sourceId: json['sourceId'],
    );
  }
}

/// Persistent meta-progression state
class MetaProgression {
  List<MetaBonus> bonuses;

  // Cached totals (calculated from bonuses)
  double _cachedStockBonus = 0;
  double _cachedCommissionCut = 0;
  double _cachedStartingCash = 0;
  double _cachedQuotaReduction = 0;
  double _cachedInformantBonus = 0;
  double _cachedFintokAccuracy = 0;
  int _cachedLuckyShares = 0;
  bool _cachedVipStatus = false;
  double _cachedUpgradeLuck = 0;
  double _cachedInsurance = 0;
  double _cachedInterestRate = 0;
  int _cachedExtraRerolls = 0;

  MetaProgression({List<MetaBonus>? bonuses}) : bonuses = bonuses ?? [] {
    _recalculateTotals();
  }

  // === Getters for cumulative bonuses ===

  /// Total stock bonus rate (e.g., 0.05 = 5% bonus shares)
  /// Capped at 25%
  double get stockBonusRate => _cachedStockBonus.clamp(0, 0.25);

  /// Total commission reduction (e.g., 0.10 = 10% off fees)
  /// Capped at 75%
  double get commissionReduction => _cachedCommissionCut.clamp(0, 0.75);

  /// Total extra starting cash
  double get startingCashBonus => _cachedStartingCash;

  /// Total quota reduction (e.g., 0.15 = 15% easier quotas)
  /// Capped at 50%
  double get quotaReduction => _cachedQuotaReduction.clamp(0, 0.50);

  /// Total informant visit bonus (e.g., 0.20 = 20% more likely)
  /// Capped at 50%
  double get informantVisitBonus => _cachedInformantBonus.clamp(0, 0.50);

  /// Total FinTok accuracy bonus (e.g., 0.15 = +15% accuracy)
  /// Capped at 30%
  double get fintokAccuracyBonus => _cachedFintokAccuracy.clamp(0, 0.30);

  /// Number of free shares at start of each run
  int get luckyStartingShares => _cachedLuckyShares;

  /// Whether player has VIP status (first upgrade = legendary)
  bool get hasVipStatus => _cachedVipStatus;

  /// Upgrade luck bonus (e.g., 0.15 = +15% rarity boost in shop)
  /// Capped at 25%
  double get upgradeLuck => _cachedUpgradeLuck.clamp(0, 0.25);

  /// Insurance (e.g., 0.20 = -20% loss reduction on losing trades)
  /// Capped at 30%
  double get insurance => _cachedInsurance.clamp(0, 0.30);

  /// Daily interest rate on cash (e.g., 0.004 = 0.4%/day)
  /// Capped at 1%/day
  double get interestRate => _cachedInterestRate.clamp(0, 0.01);

  /// Extra free rerolls in upgrade shop
  int get extraRerolls => _cachedExtraRerolls;

  // === Helper methods ===

  void _recalculateTotals() {
    _cachedStockBonus = 0;
    _cachedCommissionCut = 0;
    _cachedStartingCash = 0;
    _cachedQuotaReduction = 0;
    _cachedInformantBonus = 0;
    _cachedFintokAccuracy = 0;
    _cachedLuckyShares = 0;
    _cachedVipStatus = false;
    _cachedUpgradeLuck = 0;
    _cachedInsurance = 0;
    _cachedInterestRate = 0;
    _cachedExtraRerolls = 0;

    for (final bonus in bonuses) {
      switch (bonus.type) {
        case MetaBonusType.stockBonus:
          _cachedStockBonus += bonus.value;
          break;
        case MetaBonusType.commissionCut:
          _cachedCommissionCut += bonus.value;
          break;
        case MetaBonusType.startingCash:
          _cachedStartingCash += bonus.value;
          break;
        case MetaBonusType.quotaReduction:
          _cachedQuotaReduction += bonus.value;
          break;
        case MetaBonusType.informantVisitBonus:
          _cachedInformantBonus += bonus.value;
          break;
        case MetaBonusType.fintokAccuracyBonus:
          _cachedFintokAccuracy += bonus.value;
          break;
        case MetaBonusType.luckyStartingShares:
          _cachedLuckyShares += bonus.value.toInt();
          break;
        case MetaBonusType.vipStatus:
          _cachedVipStatus = true;
          break;
        case MetaBonusType.upgradeLuck:
          _cachedUpgradeLuck += bonus.value;
          break;
        case MetaBonusType.insurance:
          _cachedInsurance += bonus.value;
          break;
        case MetaBonusType.interestRate:
          _cachedInterestRate += bonus.value;
          break;
        case MetaBonusType.extraReroll:
          _cachedExtraRerolls += bonus.value.toInt();
          break;
      }
    }
  }

  /// Add a new bonus
  void addBonus(MetaBonus bonus) {
    bonuses.add(bonus);
    _recalculateTotals();
  }

  /// Check if a bonus from a specific source already exists
  bool hasBonusFromSource(String sourceId) {
    return bonuses.any((b) => b.sourceId == sourceId);
  }

  /// Get all bonuses of a specific type
  List<MetaBonus> getBonusesByType(MetaBonusType type) {
    return bonuses.where((b) => b.type == type).toList();
  }

  /// Get display text for a bonus type
  String getBonusDisplayText(MetaBonusType type) {
    switch (type) {
      case MetaBonusType.stockBonus:
        return '+${(stockBonusRate * 100).toStringAsFixed(1)}% bonus shares';
      case MetaBonusType.commissionCut:
        return '-${(commissionReduction * 100).toStringAsFixed(1)}% commission';
      case MetaBonusType.startingCash:
        return '+\$${startingCashBonus.toStringAsFixed(0)} starting cash';
      case MetaBonusType.quotaReduction:
        return '-${(quotaReduction * 100).toStringAsFixed(1)}% quotas';
      case MetaBonusType.informantVisitBonus:
        return '+${(informantVisitBonus * 100).toStringAsFixed(0)}% informant visits';
      case MetaBonusType.fintokAccuracyBonus:
        return '+${(fintokAccuracyBonus * 100).toStringAsFixed(0)}% FinTok accuracy';
      case MetaBonusType.luckyStartingShares:
        return '+$luckyStartingShares starting shares';
      case MetaBonusType.vipStatus:
        return 'VIP: 1st upgrade/year = Legendary';
      case MetaBonusType.upgradeLuck:
        return '+${(upgradeLuck * 100).toStringAsFixed(1)}% upgrade luck';
      case MetaBonusType.insurance:
        return '-${(insurance * 100).toStringAsFixed(1)}% loss reduction';
      case MetaBonusType.interestRate:
        return '+${(interestRate * 100).toStringAsFixed(3)}%/day interest';
      case MetaBonusType.extraReroll:
        return '+$extraRerolls free rerolls';
    }
  }

  /// Get active bonuses summary for display
  List<String> getActiveBonusesSummary() {
    final summary = <String>[];
    if (stockBonusRate > 0) summary.add(getBonusDisplayText(MetaBonusType.stockBonus));
    if (commissionReduction > 0) summary.add(getBonusDisplayText(MetaBonusType.commissionCut));
    if (startingCashBonus > 0) summary.add(getBonusDisplayText(MetaBonusType.startingCash));
    if (quotaReduction > 0) summary.add(getBonusDisplayText(MetaBonusType.quotaReduction));
    if (informantVisitBonus > 0) summary.add(getBonusDisplayText(MetaBonusType.informantVisitBonus));
    if (fintokAccuracyBonus > 0) summary.add(getBonusDisplayText(MetaBonusType.fintokAccuracyBonus));
    if (luckyStartingShares > 0) summary.add(getBonusDisplayText(MetaBonusType.luckyStartingShares));
    if (hasVipStatus) summary.add(getBonusDisplayText(MetaBonusType.vipStatus));
    if (upgradeLuck > 0) summary.add(getBonusDisplayText(MetaBonusType.upgradeLuck));
    if (insurance > 0) summary.add(getBonusDisplayText(MetaBonusType.insurance));
    if (interestRate > 0) summary.add(getBonusDisplayText(MetaBonusType.interestRate));
    if (extraRerolls > 0) summary.add(getBonusDisplayText(MetaBonusType.extraReroll));
    return summary;
  }

  // === Serialization ===

  Map<String, dynamic> toJson() => {
    'bonuses': bonuses.map((b) => b.toJson()).toList(),
  };

  factory MetaProgression.fromJson(Map<String, dynamic> json) {
    final meta = MetaProgression(
      bonuses: json['bonuses'] != null
          ? (json['bonuses'] as List)
              .map((b) => MetaBonus.fromJson(b as Map<String, dynamic>))
              .toList()
          : [],
    );
    return meta;
  }
}

/// Helper to describe meta bonus rewards for UI
class MetaRewardDescription {
  static String describe(MetaBonusType type, double value) {
    switch (type) {
      case MetaBonusType.stockBonus:
        return '+${(value * 100).toStringAsFixed(1)}% bonus shares (permanent)';
      case MetaBonusType.commissionCut:
        return '-${(value * 100).toStringAsFixed(1)}% commission (permanent)';
      case MetaBonusType.startingCash:
        return '+\$${value.toStringAsFixed(0)} starting cash (permanent)';
      case MetaBonusType.quotaReduction:
        return '-${(value * 100).toStringAsFixed(1)}% quotas (permanent)';
      case MetaBonusType.informantVisitBonus:
        return '+${(value * 100).toStringAsFixed(0)}% informant visits (permanent)';
      case MetaBonusType.fintokAccuracyBonus:
        return '+${(value * 100).toStringAsFixed(0)}% FinTok accuracy (permanent)';
      case MetaBonusType.luckyStartingShares:
        return '+${value.toInt()} starting shares (permanent)';
      case MetaBonusType.vipStatus:
        return 'VIP Status: 1st upgrade each year is Legendary';
      case MetaBonusType.upgradeLuck:
        return '+${(value * 100).toStringAsFixed(1)}% upgrade luck (permanent)';
      case MetaBonusType.insurance:
        return '-${(value * 100).toStringAsFixed(1)}% loss reduction (permanent)';
      case MetaBonusType.interestRate:
        return '+${(value * 100).toStringAsFixed(3)}%/day interest (permanent)';
      case MetaBonusType.extraReroll:
        return '+${value.toInt()} free rerolls (permanent)';
    }
  }

  static String icon(MetaBonusType type) {
    switch (type) {
      case MetaBonusType.stockBonus:
        return '🎁';
      case MetaBonusType.commissionCut:
        return '💸';
      case MetaBonusType.startingCash:
        return '💰';
      case MetaBonusType.quotaReduction:
        return '📉';
      case MetaBonusType.informantVisitBonus:
        return '🕵️';
      case MetaBonusType.fintokAccuracyBonus:
        return '📱';
      case MetaBonusType.luckyStartingShares:
        return '🍀';
      case MetaBonusType.vipStatus:
        return '👑';
      case MetaBonusType.upgradeLuck:
        return '🔮';
      case MetaBonusType.insurance:
        return '🛡️';
      case MetaBonusType.interestRate:
        return '🏦';
      case MetaBonusType.extraReroll:
        return '🎲';
    }
  }
}

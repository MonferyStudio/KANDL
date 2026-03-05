/// Achievement definitions and tracking for the game
///
/// Achievements provide long-term goals with permanent rewards
/// that persist across prestige/new games.

enum AchievementCategory {
  trading,      // Buy/sell related
  profit,       // Money/gains related
  portfolio,    // Portfolio management
  market,       // Market knowledge (informant, fintok, challenges, tokens)
  risk,         // Risk-taking/management
  milestone,    // Game progression
  secret,       // Hidden achievements
}

enum AchievementTier {
  bronze,   // Easy, small rewards
  silver,   // Medium difficulty
  gold,     // Hard, significant rewards
  platinum, // Very hard, major rewards
  diamond,  // Near impossible, legendary rewards
}

/// Condition types for achievement completion
enum AchievementCondition {
  // Trading conditions
  totalTrades,           // Execute N trades
  profitableTrades,      // Execute N profitable trades
  consecutiveProfits,    // N profitable trades in a row
  singleTradeProfit,     // Make X profit in a single trade
  singleTradeLoss,       // Survive X loss in a single trade
  tradesInOneDay,        // Execute N trades in a single day

  // Portfolio conditions
  portfolioValue,        // Reach X portfolio value
  netWorth,              // Reach X net worth (cash + portfolio)
  positionsHeld,         // Hold N positions simultaneously
  sectorsInvested,       // Invest in N different sectors
  holdDuration,          // Hold a stock for N days
  maxPositionsFilled,    // Hold max positions at once (cumulative count)
  upgradesOwned,         // Own N upgrades in a single run
  cashOnHand,            // Have X cash on hand at any point

  // Profit conditions
  totalProfit,           // Total profit earned
  dailyProfit,           // Profit in a single day
  yearlyProfit,          // Profit in a single year
  profitPercentage,      // Gain X% on investment
  totalLoss,             // Total money lost on trades

  // Market conditions
  buyAtLow,              // Buy at day's low
  sellAtHigh,            // Sell at day's high
  perfectTrade,          // Buy at low, sell at high same day
  contrarian,            // Profit from news contradictions
  dipBuys,               // Buy stocks that dropped significantly
  sellHighs,             // Sell stocks at their high
  informantTipsBought,   // Buy N tips from the informant
  fintokTipsFollowed,    // Follow N FinTok tips
  challengesCompleted,   // Complete N daily challenges
  tokensPlaced,          // Place N tokens on companies

  // Risk conditions
  shortPosition,         // Open a short position
  leveragedTrade,        // Use leverage/margin
  allInTrade,            // Use 90%+ of cash in one trade
  recoverFromLoss,       // Recover from X% portfolio loss

  // Milestone conditions
  daysPlayed,            // Play for N days
  yearsCompleted,        // Complete N years
  quotasMet,             // Meet N quotas
  prestigeCount,         // Prestige N times
  noTradeDay,            // Complete a day with 0 trades (cumulative count)
}

/// Reward types for achievements
enum RewardType {
  // Instant rewards (current run only)
  cashBonus,             // One-time cash bonus (current run)
  prestigePoints,        // Bonus prestige points

  // Meta-progression rewards (permanent across all runs)
  startingCash,          // Bonus starting cash (permanent)
  stockBonus,            // % bonus shares when buying (permanent)
  commissionCut,         // % reduction on fees (permanent)
  quotaReduction,        // % easier quotas (permanent)
  informantBonus,        // % more informant visits (permanent)
  fintokAccuracy,        // % better FinTok tips (permanent)
  luckyShares,           // Free shares at run start (permanent)
  vipStatus,             // First upgrade/year = Legendary (permanent)

  // Special rewards
  unlockUpgrade,         // Unlock a special upgrade
  cosmetic,              // UI theme/cosmetic unlock

  // New permanent reward types
  upgradeLuck,           // % better rarity in upgrade shop
  insurance,             // % loss reduction on losing trades
  interestRate,          // % daily interest on cash
  extraReroll,           // Extra free rerolls in shop
}

class AchievementReward {
  final RewardType type;
  final double value;           // Amount/multiplier
  final String? unlockId;       // For unlock types, the ID of what to unlock

  const AchievementReward({
    required this.type,
    required this.value,
    this.unlockId,
  });

  String get description {
    switch (type) {
      case RewardType.cashBonus:
        return '+\$${value.toInt()} bonus';
      case RewardType.prestigePoints:
        return '+${value.toInt()} prestige points';
      case RewardType.startingCash:
        return '+\$${value.toInt()} starting cash';
      case RewardType.stockBonus:
        return '+${(value * 100).toStringAsFixed(1)}% bonus shares';
      case RewardType.commissionCut:
        return '-${(value * 100).toStringAsFixed(1)}% commission';
      case RewardType.quotaReduction:
        return '-${(value * 100).toStringAsFixed(1)}% quotas';
      case RewardType.informantBonus:
        return '+${(value * 100).toStringAsFixed(0)}% informant visits';
      case RewardType.fintokAccuracy:
        return '+${(value * 100).toStringAsFixed(0)}% FinTok accuracy';
      case RewardType.luckyShares:
        return '+${value.toInt()} starting shares';
      case RewardType.vipStatus:
        return 'VIP: 1st upgrade/year = Legendary';
      case RewardType.unlockUpgrade:
        return 'Unlock: $unlockId';
      case RewardType.cosmetic:
        return 'Cosmetic: $unlockId';
      case RewardType.upgradeLuck:
        return '+${(value * 100).toStringAsFixed(1)}% upgrade luck';
      case RewardType.insurance:
        return '-${(value * 100).toStringAsFixed(1)}% loss reduction';
      case RewardType.interestRate:
        return '+${(value * 100).toStringAsFixed(3)}%/day interest';
      case RewardType.extraReroll:
        return '+${value.toInt()} free rerolls';
    }
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'value': value,
    'unlockId': unlockId,
  };

  factory AchievementReward.fromJson(Map<String, dynamic> json) {
    return AchievementReward(
      type: RewardType.values.firstWhere((e) => e.name == json['type']),
      value: (json['value'] as num).toDouble(),
      unlockId: json['unlockId'] as String?,
    );
  }
}

/// Definition of an achievement (static data)
class AchievementDefinition {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementCategory category;
  final AchievementTier tier;
  final AchievementCondition condition;
  final double targetValue;
  final List<AchievementReward> rewards;
  final bool isSecret;
  final String? prerequisiteId;  // Must complete this achievement first

  const AchievementDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.tier,
    required this.condition,
    required this.targetValue,
    required this.rewards,
    this.isSecret = false,
    this.prerequisiteId,
  });

  /// Get tier color for display
  int get tierColorValue {
    switch (tier) {
      case AchievementTier.bronze:
        return 0xFFCD7F32;
      case AchievementTier.silver:
        return 0xFFC0C0C0;
      case AchievementTier.gold:
        return 0xFFFFD700;
      case AchievementTier.platinum:
        return 0xFFE5E4E2;
      case AchievementTier.diamond:
        return 0xFFB9F2FF;
    }
  }
}

/// Progress tracking for an achievement
class AchievementProgress {
  final String achievementId;
  double currentValue;
  bool isCompleted;
  DateTime? completedAt;
  bool rewardClaimed;

  AchievementProgress({
    required this.achievementId,
    this.currentValue = 0,
    this.isCompleted = false,
    this.completedAt,
    this.rewardClaimed = false,
  });

  double getProgressPercent(double targetValue) {
    if (targetValue <= 0) return 0;
    return (currentValue / targetValue * 100).clamp(0, 100);
  }

  void updateProgress(double value, double targetValue) {
    currentValue = value;
    if (currentValue >= targetValue && !isCompleted) {
      isCompleted = true;
      completedAt = DateTime.now();
    }
  }

  void incrementProgress(double amount, double targetValue) {
    updateProgress(currentValue + amount, targetValue);
  }

  Map<String, dynamic> toJson() => {
    'achievementId': achievementId,
    'currentValue': currentValue,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
    'rewardClaimed': rewardClaimed,
  };

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      achievementId: json['achievementId'] as String,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      rewardClaimed: json['rewardClaimed'] as bool? ?? false,
    );
  }
}

// Helper constants for tier pattern BB SS GG PP DD
const _b = AchievementTier.bronze;
const _s = AchievementTier.silver;
const _g = AchievementTier.gold;
const _p = AchievementTier.platinum;
const _d = AchievementTier.diamond;

/// All achievement definitions — ~296 achievements
/// Every condition chain follows BB SS GG PP DD (10 entries)
/// except sectorsInvested (capped at 6 sectors)
class Achievements {
  static const List<AchievementDefinition> all = [
    // ================================================================
    // TRADING (40) — Trades, streaks, speed, wins
    // ================================================================

    // --- totalTrades (10): 1, 10, 50, 250, 1k, 5k, 25k, 100k, 500k, 1M ---
    AchievementDefinition(id: 'trade_1', name: 'First Steps', description: 'Execute your first trade', icon: '🎯', category: AchievementCategory.trading, tier: _b, condition: AchievementCondition.totalTrades, targetValue: 1, rewards: []),
    AchievementDefinition(id: 'trade_10', name: 'Active Trader', description: 'Execute 10 trades', icon: '📊', category: AchievementCategory.trading, tier: _b, condition: AchievementCondition.totalTrades, targetValue: 10, rewards: []),
    AchievementDefinition(id: 'trade_50', name: 'Frequent Trader', description: 'Execute 50 trades', icon: '📈', category: AchievementCategory.trading, tier: _s, condition: AchievementCondition.totalTrades, targetValue: 50, rewards: []),
    AchievementDefinition(id: 'trade_250', name: 'Busy Trader', description: 'Execute 250 trades', icon: '💹', category: AchievementCategory.trading, tier: _s, condition: AchievementCondition.totalTrades, targetValue: 250, rewards: []),
    AchievementDefinition(id: 'trade_1k', name: 'Floor Trader', description: 'Execute 1,000 trades', icon: '🏦', category: AchievementCategory.trading, tier: _g, condition: AchievementCondition.totalTrades, targetValue: 1000, rewards: []),
    AchievementDefinition(id: 'trade_5k', name: 'Trading Machine', description: 'Execute 5,000 trades', icon: '🤖', category: AchievementCategory.trading, tier: _g, condition: AchievementCondition.totalTrades, targetValue: 5000, rewards: []),
    AchievementDefinition(id: 'trade_25k', name: 'Market Veteran', description: 'Execute 25,000 trades', icon: '🎖️', category: AchievementCategory.trading, tier: _p, condition: AchievementCondition.totalTrades, targetValue: 25000, rewards: []),
    AchievementDefinition(id: 'trade_100k', name: 'Trading Legend', description: 'Execute 100,000 trades', icon: '🏛️', category: AchievementCategory.trading, tier: _p, condition: AchievementCondition.totalTrades, targetValue: 100000, rewards: []),
    AchievementDefinition(id: 'trade_500k', name: 'Trading Titan', description: 'Execute 500,000 trades', icon: '⚡', category: AchievementCategory.trading, tier: _d, condition: AchievementCondition.totalTrades, targetValue: 500000, rewards: []),
    AchievementDefinition(id: 'trade_1m', name: 'Wall Street God', description: 'Execute 1,000,000 trades', icon: '👑', category: AchievementCategory.trading, tier: _d, condition: AchievementCondition.totalTrades, targetValue: 1000000, rewards: []),

    // --- consecutiveProfits (10): 3, 5, 7, 10, 15, 25, 50, 75, 100, 150 ---
    AchievementDefinition(id: 'streak_3', name: 'Lucky Streak', description: '3 profitable trades in a row', icon: '🍀', category: AchievementCategory.trading, tier: _b, condition: AchievementCondition.consecutiveProfits, targetValue: 3, rewards: []),
    AchievementDefinition(id: 'streak_5', name: 'Hot Streak', description: '5 profitable trades in a row', icon: '🔥', category: AchievementCategory.trading, tier: _b, condition: AchievementCondition.consecutiveProfits, targetValue: 5, rewards: []),
    AchievementDefinition(id: 'streak_7', name: 'Winning Streak', description: '7 profitable trades in a row', icon: '🔥🔥', category: AchievementCategory.trading, tier: _s, condition: AchievementCondition.consecutiveProfits, targetValue: 7, rewards: []),
    AchievementDefinition(id: 'streak_10', name: 'On Fire', description: '10 profitable trades in a row', icon: '💥', category: AchievementCategory.trading, tier: _s, condition: AchievementCondition.consecutiveProfits, targetValue: 10, rewards: []),
    AchievementDefinition(id: 'streak_15', name: 'Unstoppable', description: '15 profitable trades in a row', icon: '🔥🔥🔥', category: AchievementCategory.trading, tier: _g, condition: AchievementCondition.consecutiveProfits, targetValue: 15, rewards: []),
    AchievementDefinition(id: 'streak_25', name: 'Midas Touch', description: '25 profitable trades in a row', icon: '✨', category: AchievementCategory.trading, tier: _g, condition: AchievementCondition.consecutiveProfits, targetValue: 25, rewards: []),
    AchievementDefinition(id: 'streak_50', name: 'Market Wizard', description: '50 profitable trades in a row', icon: '🧙', category: AchievementCategory.trading, tier: _p, condition: AchievementCondition.consecutiveProfits, targetValue: 50, rewards: []),
    AchievementDefinition(id: 'streak_75', name: 'Trading Prodigy', description: '75 profitable trades in a row', icon: '🌟', category: AchievementCategory.trading, tier: _p, condition: AchievementCondition.consecutiveProfits, targetValue: 75, rewards: []),
    AchievementDefinition(id: 'streak_100', name: 'Streak God', description: '100 profitable trades in a row', icon: '💎', category: AchievementCategory.trading, tier: _d, condition: AchievementCondition.consecutiveProfits, targetValue: 100, rewards: []),
    AchievementDefinition(id: 'streak_150', name: 'Untouchable', description: '150 profitable trades in a row', icon: '♾️', category: AchievementCategory.trading, tier: _d, condition: AchievementCondition.consecutiveProfits, targetValue: 150, rewards: []),

    // --- tradesInOneDay (10): 3, 5, 8, 12, 15, 20, 30, 50, 75, 100 ---
    AchievementDefinition(id: 'daytrading_3', name: 'Quick Fingers', description: '3 trades in a single day', icon: '⚡', category: AchievementCategory.trading, tier: _b, condition: AchievementCondition.tradesInOneDay, targetValue: 3, rewards: []),
    AchievementDefinition(id: 'daytrading_5', name: 'Speed Trader', description: '5 trades in a single day', icon: '⚡⚡', category: AchievementCategory.trading, tier: _b, condition: AchievementCondition.tradesInOneDay, targetValue: 5, rewards: []),
    AchievementDefinition(id: 'daytrading_8', name: 'Fast Trader', description: '8 trades in a single day', icon: '🏎️', category: AchievementCategory.trading, tier: _s, condition: AchievementCondition.tradesInOneDay, targetValue: 8, rewards: []),
    AchievementDefinition(id: 'daytrading_12', name: 'Rush Hour', description: '12 trades in a single day', icon: '🚀', category: AchievementCategory.trading, tier: _s, condition: AchievementCondition.tradesInOneDay, targetValue: 12, rewards: []),
    AchievementDefinition(id: 'daytrading_15', name: 'Day Dealer', description: '15 trades in a single day', icon: '💨', category: AchievementCategory.trading, tier: _g, condition: AchievementCondition.tradesInOneDay, targetValue: 15, rewards: []),
    AchievementDefinition(id: 'daytrading_20', name: 'Trading Frenzy', description: '20 trades in a single day', icon: '🌪️', category: AchievementCategory.trading, tier: _g, condition: AchievementCondition.tradesInOneDay, targetValue: 20, rewards: []),
    AchievementDefinition(id: 'daytrading_30', name: 'Hyperactive', description: '30 trades in a single day', icon: '⚡⚡⚡', category: AchievementCategory.trading, tier: _p, condition: AchievementCondition.tradesInOneDay, targetValue: 30, rewards: []),
    AchievementDefinition(id: 'daytrading_50', name: 'Trading Storm', description: '50 trades in a single day', icon: '🌩️', category: AchievementCategory.trading, tier: _p, condition: AchievementCondition.tradesInOneDay, targetValue: 50, rewards: []),
    AchievementDefinition(id: 'daytrading_75', name: 'Market Blitz', description: '75 trades in a single day', icon: '💫', category: AchievementCategory.trading, tier: _d, condition: AchievementCondition.tradesInOneDay, targetValue: 75, rewards: []),
    AchievementDefinition(id: 'daytrading_100', name: 'Hyper Trader', description: '100 trades in a single day', icon: '🔱', category: AchievementCategory.trading, tier: _d, condition: AchievementCondition.tradesInOneDay, targetValue: 100, rewards: []),

    // --- profitableTrades (10): 1, 10, 25, 50, 100, 250, 500, 1k, 2.5k, 5k ---
    AchievementDefinition(id: 'wintrade_1', name: 'In The Green', description: 'Make your first profitable trade', icon: '💚', category: AchievementCategory.trading, tier: _b, condition: AchievementCondition.profitableTrades, targetValue: 1, rewards: []),
    AchievementDefinition(id: 'wintrade_10', name: 'Getting Good', description: '10 profitable trades', icon: '✅', category: AchievementCategory.trading, tier: _b, condition: AchievementCondition.profitableTrades, targetValue: 10, rewards: []),
    AchievementDefinition(id: 'wintrade_25', name: 'Skilled Trader', description: '25 profitable trades', icon: '📗', category: AchievementCategory.trading, tier: _s, condition: AchievementCondition.profitableTrades, targetValue: 25, rewards: []),
    AchievementDefinition(id: 'wintrade_50', name: 'Consistent Winner', description: '50 profitable trades', icon: '🏅', category: AchievementCategory.trading, tier: _s, condition: AchievementCondition.profitableTrades, targetValue: 50, rewards: []),
    AchievementDefinition(id: 'wintrade_100', name: 'Profit Hunter', description: '100 profitable trades', icon: '🎯', category: AchievementCategory.trading, tier: _g, condition: AchievementCondition.profitableTrades, targetValue: 100, rewards: []),
    AchievementDefinition(id: 'wintrade_250', name: 'Money Maker', description: '250 profitable trades', icon: '💰', category: AchievementCategory.trading, tier: _g, condition: AchievementCondition.profitableTrades, targetValue: 250, rewards: []),
    AchievementDefinition(id: 'wintrade_500', name: 'Profit Machine', description: '500 profitable trades', icon: '🤑', category: AchievementCategory.trading, tier: _p, condition: AchievementCondition.profitableTrades, targetValue: 500, rewards: []),
    AchievementDefinition(id: 'wintrade_1k', name: 'Profit King', description: '1,000 profitable trades', icon: '👑', category: AchievementCategory.trading, tier: _p, condition: AchievementCondition.profitableTrades, targetValue: 1000, rewards: []),
    AchievementDefinition(id: 'wintrade_2500', name: 'Midas', description: '2,500 profitable trades', icon: '🏆', category: AchievementCategory.trading, tier: _d, condition: AchievementCondition.profitableTrades, targetValue: 2500, rewards: []),
    AchievementDefinition(id: 'wintrade_5k', name: 'Untouchable Trader', description: '5,000 profitable trades', icon: '💎', category: AchievementCategory.trading, tier: _d, condition: AchievementCondition.profitableTrades, targetValue: 5000, rewards: []),

    // ================================================================
    // PROFIT (30) — Total profit, daily records, single trade
    // ================================================================

    // --- totalProfit (10): 1k, 5k, 25k, 100k, 500k, 2.5M, 10M, 50M, 250M, 1B ---
    AchievementDefinition(id: 'profit_1k', name: 'Pocket Money', description: 'Earn \$1,000 total profit', icon: '💵', category: AchievementCategory.profit, tier: _b, condition: AchievementCondition.totalProfit, targetValue: 1000, rewards: []),
    AchievementDefinition(id: 'profit_5k', name: 'Solid Start', description: 'Earn \$5,000 total profit', icon: '💰', category: AchievementCategory.profit, tier: _b, condition: AchievementCondition.totalProfit, targetValue: 5000, rewards: []),
    AchievementDefinition(id: 'profit_25k', name: 'Solid Returns', description: 'Earn \$25,000 total profit', icon: '💰💰', category: AchievementCategory.profit, tier: _s, condition: AchievementCondition.totalProfit, targetValue: 25000, rewards: []),
    AchievementDefinition(id: 'profit_100k', name: 'Six Figures', description: 'Earn \$100,000 total profit', icon: '💎', category: AchievementCategory.profit, tier: _s, condition: AchievementCondition.totalProfit, targetValue: 100000, rewards: []),
    AchievementDefinition(id: 'profit_500k', name: 'Big Gains', description: 'Earn \$500,000 total profit', icon: '💎💎', category: AchievementCategory.profit, tier: _g, condition: AchievementCondition.totalProfit, targetValue: 500000, rewards: []),
    AchievementDefinition(id: 'profit_2500k', name: 'Half Millionaire', description: 'Earn \$2,500,000 total profit', icon: '🏆', category: AchievementCategory.profit, tier: _g, condition: AchievementCondition.totalProfit, targetValue: 2500000, rewards: []),
    AchievementDefinition(id: 'profit_10m', name: 'Millionaire', description: 'Earn \$10,000,000 total profit', icon: '👑', category: AchievementCategory.profit, tier: _p, condition: AchievementCondition.totalProfit, targetValue: 10000000, rewards: []),
    AchievementDefinition(id: 'profit_50m', name: 'Multi-Millionaire', description: 'Earn \$50,000,000 total profit', icon: '💎👑', category: AchievementCategory.profit, tier: _p, condition: AchievementCondition.totalProfit, targetValue: 50000000, rewards: []),
    AchievementDefinition(id: 'profit_250m', name: 'Quarter Billionaire', description: 'Earn \$250,000,000 total profit', icon: '🌟', category: AchievementCategory.profit, tier: _d, condition: AchievementCondition.totalProfit, targetValue: 250000000, rewards: []),
    AchievementDefinition(id: 'profit_1b', name: 'Billionaire', description: 'Earn \$1,000,000,000 total profit', icon: '♾️', category: AchievementCategory.profit, tier: _d, condition: AchievementCondition.totalProfit, targetValue: 1000000000, rewards: []),

    // --- dailyProfit (10): 100, 500, 2.5k, 10k, 50k, 250k, 1M, 5M, 25M, 100M ---
    AchievementDefinition(id: 'daily_100', name: 'Decent Day', description: 'Make \$100 profit in a single day', icon: '☀️', category: AchievementCategory.profit, tier: _b, condition: AchievementCondition.dailyProfit, targetValue: 100, rewards: []),
    AchievementDefinition(id: 'daily_500', name: 'Good Day', description: 'Make \$500 profit in a single day', icon: '🌤️', category: AchievementCategory.profit, tier: _b, condition: AchievementCondition.dailyProfit, targetValue: 500, rewards: []),
    AchievementDefinition(id: 'daily_2500', name: 'Great Day', description: 'Make \$2,500 profit in a single day', icon: '🌟', category: AchievementCategory.profit, tier: _s, condition: AchievementCondition.dailyProfit, targetValue: 2500, rewards: []),
    AchievementDefinition(id: 'daily_10k', name: 'Perfect Day', description: 'Make \$10,000 profit in a single day', icon: '⭐', category: AchievementCategory.profit, tier: _s, condition: AchievementCondition.dailyProfit, targetValue: 10000, rewards: []),
    AchievementDefinition(id: 'daily_50k', name: 'Golden Day', description: 'Make \$50,000 profit in a single day', icon: '🌅', category: AchievementCategory.profit, tier: _g, condition: AchievementCondition.dailyProfit, targetValue: 50000, rewards: []),
    AchievementDefinition(id: 'daily_250k', name: 'Incredible Day', description: 'Make \$250,000 profit in a single day', icon: '🔥', category: AchievementCategory.profit, tier: _g, condition: AchievementCondition.dailyProfit, targetValue: 250000, rewards: []),
    AchievementDefinition(id: 'daily_1m', name: 'Legendary Day', description: 'Make \$1,000,000 profit in a single day', icon: '💫', category: AchievementCategory.profit, tier: _p, condition: AchievementCondition.dailyProfit, targetValue: 1000000, rewards: []),
    AchievementDefinition(id: 'daily_5m', name: 'Mythical Day', description: 'Make \$5,000,000 profit in a single day', icon: '🌈', category: AchievementCategory.profit, tier: _p, condition: AchievementCondition.dailyProfit, targetValue: 5000000, rewards: []),
    AchievementDefinition(id: 'daily_25m', name: 'Godlike Day', description: 'Make \$25,000,000 profit in a single day', icon: '🔱', category: AchievementCategory.profit, tier: _d, condition: AchievementCondition.dailyProfit, targetValue: 25000000, rewards: []),
    AchievementDefinition(id: 'daily_100m', name: 'Transcendent Day', description: 'Make \$100,000,000 profit in a single day', icon: '♾️', category: AchievementCategory.profit, tier: _d, condition: AchievementCondition.dailyProfit, targetValue: 100000000, rewards: []),

    // --- singleTradeProfit (10): 100, 500, 2.5k, 10k, 50k, 250k, 1M, 5M, 25M, 100M ---
    AchievementDefinition(id: 'bigtrade_100', name: 'Nice Trade', description: 'Make \$100 from a single trade', icon: '📗', category: AchievementCategory.profit, tier: _b, condition: AchievementCondition.singleTradeProfit, targetValue: 100, rewards: []),
    AchievementDefinition(id: 'bigtrade_500', name: 'Good Trade', description: 'Make \$500 from a single trade', icon: '💵', category: AchievementCategory.profit, tier: _b, condition: AchievementCondition.singleTradeProfit, targetValue: 500, rewards: []),
    AchievementDefinition(id: 'bigtrade_2500', name: 'Big Fish', description: 'Make \$2,500 from a single trade', icon: '🐟', category: AchievementCategory.profit, tier: _s, condition: AchievementCondition.singleTradeProfit, targetValue: 2500, rewards: []),
    AchievementDefinition(id: 'bigtrade_10k', name: 'Whale Trade', description: 'Make \$10,000 from a single trade', icon: '🐋', category: AchievementCategory.profit, tier: _s, condition: AchievementCondition.singleTradeProfit, targetValue: 10000, rewards: []),
    AchievementDefinition(id: 'bigtrade_50k', name: 'Monster Trade', description: 'Make \$50,000 from a single trade', icon: '🦈', category: AchievementCategory.profit, tier: _g, condition: AchievementCondition.singleTradeProfit, targetValue: 50000, rewards: []),
    AchievementDefinition(id: 'bigtrade_250k', name: 'Mega Trade', description: 'Make \$250,000 from a single trade', icon: '🐉', category: AchievementCategory.profit, tier: _g, condition: AchievementCondition.singleTradeProfit, targetValue: 250000, rewards: []),
    AchievementDefinition(id: 'bigtrade_1m', name: 'Legendary Trade', description: 'Make \$1,000,000 from a single trade', icon: '🌟', category: AchievementCategory.profit, tier: _p, condition: AchievementCondition.singleTradeProfit, targetValue: 1000000, rewards: []),
    AchievementDefinition(id: 'bigtrade_5m', name: 'Epic Trade', description: 'Make \$5,000,000 from a single trade', icon: '💎', category: AchievementCategory.profit, tier: _p, condition: AchievementCondition.singleTradeProfit, targetValue: 5000000, rewards: []),
    AchievementDefinition(id: 'bigtrade_25m', name: 'God Trade', description: 'Make \$25,000,000 from a single trade', icon: '👑', category: AchievementCategory.profit, tier: _d, condition: AchievementCondition.singleTradeProfit, targetValue: 25000000, rewards: []),
    AchievementDefinition(id: 'bigtrade_100m', name: 'Universe Trade', description: 'Make \$100,000,000 from a single trade', icon: '♾️', category: AchievementCategory.profit, tier: _d, condition: AchievementCondition.singleTradeProfit, targetValue: 100000000, rewards: []),

    // ================================================================
    // PORTFOLIO (36) — Value, sectors, holding, cash
    // ================================================================

    // --- portfolioValue (10): 1k, 5k, 25k, 100k, 500k, 2.5M, 10M, 50M, 250M, 1B ---
    AchievementDefinition(id: 'portfolio_1k', name: 'Small Portfolio', description: 'Reach \$1,000 portfolio value', icon: '📁', category: AchievementCategory.portfolio, tier: _b, condition: AchievementCondition.portfolioValue, targetValue: 1000, rewards: []),
    AchievementDefinition(id: 'portfolio_5k', name: 'Growing Portfolio', description: 'Reach \$5,000 portfolio value', icon: '📈', category: AchievementCategory.portfolio, tier: _b, condition: AchievementCondition.portfolioValue, targetValue: 5000, rewards: []),
    AchievementDefinition(id: 'portfolio_25k', name: 'Serious Investor', description: 'Reach \$25,000 portfolio value', icon: '📊', category: AchievementCategory.portfolio, tier: _s, condition: AchievementCondition.portfolioValue, targetValue: 25000, rewards: []),
    AchievementDefinition(id: 'portfolio_100k', name: 'Fund Manager', description: 'Reach \$100,000 portfolio value', icon: '🏢', category: AchievementCategory.portfolio, tier: _s, condition: AchievementCondition.portfolioValue, targetValue: 100000, rewards: []),
    AchievementDefinition(id: 'portfolio_500k', name: 'Big Player', description: 'Reach \$500,000 portfolio value', icon: '🏛️', category: AchievementCategory.portfolio, tier: _g, condition: AchievementCondition.portfolioValue, targetValue: 500000, rewards: []),
    AchievementDefinition(id: 'portfolio_2500k', name: 'Hedge Fund', description: 'Reach \$2,500,000 portfolio value', icon: '🏰', category: AchievementCategory.portfolio, tier: _g, condition: AchievementCondition.portfolioValue, targetValue: 2500000, rewards: []),
    AchievementDefinition(id: 'portfolio_10m', name: 'Portfolio King', description: 'Reach \$10,000,000 portfolio value', icon: '👑', category: AchievementCategory.portfolio, tier: _p, condition: AchievementCondition.portfolioValue, targetValue: 10000000, rewards: []),
    AchievementDefinition(id: 'portfolio_50m', name: 'Portfolio Emperor', description: 'Reach \$50,000,000 portfolio value', icon: '🌟', category: AchievementCategory.portfolio, tier: _p, condition: AchievementCondition.portfolioValue, targetValue: 50000000, rewards: []),
    AchievementDefinition(id: 'portfolio_250m', name: 'Portfolio God', description: 'Reach \$250,000,000 portfolio value', icon: '💎', category: AchievementCategory.portfolio, tier: _d, condition: AchievementCondition.portfolioValue, targetValue: 250000000, rewards: []),
    AchievementDefinition(id: 'portfolio_1b', name: 'Portfolio Titan', description: 'Reach \$1,000,000,000 portfolio value', icon: '♾️', category: AchievementCategory.portfolio, tier: _d, condition: AchievementCondition.portfolioValue, targetValue: 1000000000, rewards: []),

    // --- sectorsInvested (6): 1, 2, 3, 4, 5, 6 — capped by game design ---
    AchievementDefinition(id: 'sector_1', name: 'First Sector', description: 'Invest in 1 sector', icon: '🏷️', category: AchievementCategory.portfolio, tier: _b, condition: AchievementCondition.sectorsInvested, targetValue: 1, rewards: []),
    AchievementDefinition(id: 'sector_2', name: 'Two Markets', description: 'Invest in 2 sectors', icon: '🎨', category: AchievementCategory.portfolio, tier: _b, condition: AchievementCondition.sectorsInvested, targetValue: 2, rewards: []),
    AchievementDefinition(id: 'sector_3', name: 'Diversified', description: 'Invest in 3 sectors', icon: '🌍', category: AchievementCategory.portfolio, tier: _s, condition: AchievementCondition.sectorsInvested, targetValue: 3, rewards: []),
    AchievementDefinition(id: 'sector_4', name: 'Well Spread', description: 'Invest in 4 sectors', icon: '🗺️', category: AchievementCategory.portfolio, tier: _s, condition: AchievementCondition.sectorsInvested, targetValue: 4, rewards: []),
    AchievementDefinition(id: 'sector_5', name: 'Broad Investor', description: 'Invest in 5 sectors', icon: '🌐', category: AchievementCategory.portfolio, tier: _g, condition: AchievementCondition.sectorsInvested, targetValue: 5, rewards: []),
    AchievementDefinition(id: 'sector_all', name: 'Full Spectrum', description: 'Invest in all available sectors', icon: '🌈', category: AchievementCategory.portfolio, tier: _d, condition: AchievementCondition.sectorsInvested, targetValue: 6, rewards: []),

    // --- holdDuration (10): 7, 14, 30, 60, 90, 120, 180, 250, 365, 500 ---
    AchievementDefinition(id: 'hold_7', name: 'Paper Hands', description: 'Hold a stock for 7 days', icon: '📄', category: AchievementCategory.portfolio, tier: _b, condition: AchievementCondition.holdDuration, targetValue: 7, rewards: []),
    AchievementDefinition(id: 'hold_14', name: 'Patient Trader', description: 'Hold a stock for 14 days', icon: '⏳', category: AchievementCategory.portfolio, tier: _b, condition: AchievementCondition.holdDuration, targetValue: 14, rewards: []),
    AchievementDefinition(id: 'hold_30', name: 'Diamond Hands', description: 'Hold a stock for 30 days', icon: '💎🙌', category: AchievementCategory.portfolio, tier: _s, condition: AchievementCondition.holdDuration, targetValue: 30, rewards: []),
    AchievementDefinition(id: 'hold_60', name: 'Iron Will', description: 'Hold a stock for 60 days', icon: '🛡️', category: AchievementCategory.portfolio, tier: _s, condition: AchievementCondition.holdDuration, targetValue: 60, rewards: []),
    AchievementDefinition(id: 'hold_90', name: 'Steady Holder', description: 'Hold a stock for 90 days', icon: '⚓', category: AchievementCategory.portfolio, tier: _g, condition: AchievementCondition.holdDuration, targetValue: 90, rewards: []),
    AchievementDefinition(id: 'hold_120', name: 'True Believer', description: 'Hold a stock for 120 days', icon: '🏔️', category: AchievementCategory.portfolio, tier: _g, condition: AchievementCondition.holdDuration, targetValue: 120, rewards: []),
    AchievementDefinition(id: 'hold_180', name: 'Unshakeable', description: 'Hold a stock for 180 days', icon: '🗿', category: AchievementCategory.portfolio, tier: _p, condition: AchievementCondition.holdDuration, targetValue: 180, rewards: []),
    AchievementDefinition(id: 'hold_250', name: 'Long Hauler', description: 'Hold a stock for 250 days', icon: '🏋️', category: AchievementCategory.portfolio, tier: _p, condition: AchievementCondition.holdDuration, targetValue: 250, rewards: []),
    AchievementDefinition(id: 'hold_365', name: 'Year Holder', description: 'Hold a stock for 365 days', icon: '📅', category: AchievementCategory.portfolio, tier: _d, condition: AchievementCondition.holdDuration, targetValue: 365, rewards: []),
    AchievementDefinition(id: 'hold_500', name: 'Eternal Diamond', description: 'Hold a stock for 500 days', icon: '♾️💎', category: AchievementCategory.portfolio, tier: _d, condition: AchievementCondition.holdDuration, targetValue: 500, rewards: []),

    // --- cashOnHand (10): 1k, 5k, 25k, 100k, 500k, 2.5M, 10M, 50M, 250M, 1B ---
    AchievementDefinition(id: 'cash_1k', name: 'Cash Holder', description: 'Have \$1,000 cash on hand', icon: '💵', category: AchievementCategory.portfolio, tier: _b, condition: AchievementCondition.cashOnHand, targetValue: 1000, rewards: []),
    AchievementDefinition(id: 'cash_5k', name: 'Cash Saver', description: 'Have \$5,000 cash on hand', icon: '💵💵', category: AchievementCategory.portfolio, tier: _b, condition: AchievementCondition.cashOnHand, targetValue: 5000, rewards: []),
    AchievementDefinition(id: 'cash_25k', name: 'Cash Rich', description: 'Have \$25,000 cash on hand', icon: '💰', category: AchievementCategory.portfolio, tier: _s, condition: AchievementCondition.cashOnHand, targetValue: 25000, rewards: []),
    AchievementDefinition(id: 'cash_100k', name: 'Cash Hoarder', description: 'Have \$100,000 cash on hand', icon: '🏦', category: AchievementCategory.portfolio, tier: _s, condition: AchievementCondition.cashOnHand, targetValue: 100000, rewards: []),
    AchievementDefinition(id: 'cash_500k', name: 'Cash King', description: 'Have \$500,000 cash on hand', icon: '💰💰', category: AchievementCategory.portfolio, tier: _g, condition: AchievementCondition.cashOnHand, targetValue: 500000, rewards: []),
    AchievementDefinition(id: 'cash_2500k', name: 'Cash Baron', description: 'Have \$2,500,000 cash on hand', icon: '🤑', category: AchievementCategory.portfolio, tier: _g, condition: AchievementCondition.cashOnHand, targetValue: 2500000, rewards: []),
    AchievementDefinition(id: 'cash_10m', name: 'Cash Emperor', description: 'Have \$10,000,000 cash on hand', icon: '👑', category: AchievementCategory.portfolio, tier: _p, condition: AchievementCondition.cashOnHand, targetValue: 10000000, rewards: []),
    AchievementDefinition(id: 'cash_50m', name: 'Cash Tycoon', description: 'Have \$50,000,000 cash on hand', icon: '🌟', category: AchievementCategory.portfolio, tier: _p, condition: AchievementCondition.cashOnHand, targetValue: 50000000, rewards: []),
    AchievementDefinition(id: 'cash_250m', name: 'Cash God', description: 'Have \$250,000,000 cash on hand', icon: '💎', category: AchievementCategory.portfolio, tier: _d, condition: AchievementCondition.cashOnHand, targetValue: 250000000, rewards: []),
    AchievementDefinition(id: 'cash_1b', name: 'Scrooge', description: 'Have \$1,000,000,000 cash on hand', icon: '♾️', category: AchievementCategory.portfolio, tier: _d, condition: AchievementCondition.cashOnHand, targetValue: 1000000000, rewards: []),

    // ================================================================
    // MILESTONE (40) — Days, years, quotas, prestige
    // ================================================================

    // --- daysPlayed (10): 1, 7, 15, 30, 60, 100, 200, 365, 500, 1000 ---
    AchievementDefinition(id: 'day_1', name: 'First Day', description: 'Complete your first trading day', icon: '📅', category: AchievementCategory.milestone, tier: _b, condition: AchievementCondition.daysPlayed, targetValue: 1, rewards: []),
    AchievementDefinition(id: 'day_7', name: 'First Week', description: 'Survive 7 trading days', icon: '📆', category: AchievementCategory.milestone, tier: _b, condition: AchievementCondition.daysPlayed, targetValue: 7, rewards: []),
    AchievementDefinition(id: 'day_15', name: 'Getting Comfortable', description: 'Survive 15 trading days', icon: '🗓️', category: AchievementCategory.milestone, tier: _s, condition: AchievementCondition.daysPlayed, targetValue: 15, rewards: []),
    AchievementDefinition(id: 'day_30', name: 'First Month', description: 'Survive 30 trading days', icon: '📋', category: AchievementCategory.milestone, tier: _s, condition: AchievementCondition.daysPlayed, targetValue: 30, rewards: []),
    AchievementDefinition(id: 'day_60', name: 'Seasoned', description: 'Survive 60 trading days', icon: '📌', category: AchievementCategory.milestone, tier: _g, condition: AchievementCondition.daysPlayed, targetValue: 60, rewards: []),
    AchievementDefinition(id: 'day_100', name: 'Centurion', description: 'Survive 100 trading days', icon: '💯', category: AchievementCategory.milestone, tier: _g, condition: AchievementCondition.daysPlayed, targetValue: 100, rewards: []),
    AchievementDefinition(id: 'day_200', name: 'Marathon Trader', description: 'Survive 200 trading days', icon: '🏃', category: AchievementCategory.milestone, tier: _p, condition: AchievementCondition.daysPlayed, targetValue: 200, rewards: []),
    AchievementDefinition(id: 'day_365', name: 'Full Calendar', description: 'Survive 365 trading days', icon: '🎆', category: AchievementCategory.milestone, tier: _p, condition: AchievementCondition.daysPlayed, targetValue: 365, rewards: []),
    AchievementDefinition(id: 'day_500', name: 'Endless Grind', description: 'Survive 500 trading days', icon: '⚙️', category: AchievementCategory.milestone, tier: _d, condition: AchievementCondition.daysPlayed, targetValue: 500, rewards: []),
    AchievementDefinition(id: 'day_1000', name: 'Eternal Trader', description: 'Survive 1,000 trading days', icon: '♾️', category: AchievementCategory.milestone, tier: _d, condition: AchievementCondition.daysPlayed, targetValue: 1000, rewards: []),

    // --- yearsCompleted (10): 1, 2, 3, 5, 7, 10, 15, 25, 50, 100 ---
    AchievementDefinition(id: 'year_1', name: 'First Year', description: 'Complete your first year', icon: '🎊', category: AchievementCategory.milestone, tier: _b, condition: AchievementCondition.yearsCompleted, targetValue: 1, rewards: []),
    AchievementDefinition(id: 'year_2', name: 'Second Year', description: 'Complete 2 years', icon: '🎉', category: AchievementCategory.milestone, tier: _b, condition: AchievementCondition.yearsCompleted, targetValue: 2, rewards: []),
    AchievementDefinition(id: 'year_3', name: 'Experienced', description: 'Complete 3 years', icon: '🏅', category: AchievementCategory.milestone, tier: _s, condition: AchievementCondition.yearsCompleted, targetValue: 3, rewards: []),
    AchievementDefinition(id: 'year_5', name: 'Market Sage', description: 'Complete 5 years', icon: '🎗️', category: AchievementCategory.milestone, tier: _s, condition: AchievementCondition.yearsCompleted, targetValue: 5, rewards: []),
    AchievementDefinition(id: 'year_7', name: 'Veteran', description: 'Complete 7 years', icon: '🎖️', category: AchievementCategory.milestone, tier: _g, condition: AchievementCondition.yearsCompleted, targetValue: 7, rewards: []),
    AchievementDefinition(id: 'year_10', name: 'Wall Street Elder', description: 'Complete 10 years', icon: '🏆', category: AchievementCategory.milestone, tier: _g, condition: AchievementCondition.yearsCompleted, targetValue: 10, rewards: []),
    AchievementDefinition(id: 'year_15', name: 'Market Legend', description: 'Complete 15 years', icon: '🌟', category: AchievementCategory.milestone, tier: _p, condition: AchievementCondition.yearsCompleted, targetValue: 15, rewards: []),
    AchievementDefinition(id: 'year_25', name: 'Timeless Trader', description: 'Complete 25 years', icon: '⏳', category: AchievementCategory.milestone, tier: _p, condition: AchievementCondition.yearsCompleted, targetValue: 25, rewards: []),
    AchievementDefinition(id: 'year_50', name: 'Eternal Sage', description: 'Complete 50 years', icon: '🗿', category: AchievementCategory.milestone, tier: _d, condition: AchievementCondition.yearsCompleted, targetValue: 50, rewards: []),
    AchievementDefinition(id: 'year_100', name: 'Immortal', description: 'Complete 100 years', icon: '♾️', category: AchievementCategory.milestone, tier: _d, condition: AchievementCondition.yearsCompleted, targetValue: 100, rewards: []),

    // --- quotasMet (10): 1, 5, 10, 25, 50, 100, 250, 500, 1k, 2.5k ---
    AchievementDefinition(id: 'quota_1', name: 'First Quota', description: 'Meet your first quota', icon: '✔️', category: AchievementCategory.milestone, tier: _b, condition: AchievementCondition.quotasMet, targetValue: 1, rewards: []),
    AchievementDefinition(id: 'quota_5', name: 'Quota Hunter', description: 'Meet 5 quotas', icon: '☑️', category: AchievementCategory.milestone, tier: _b, condition: AchievementCondition.quotasMet, targetValue: 5, rewards: []),
    AchievementDefinition(id: 'quota_10', name: 'Quota Crusher', description: 'Meet 10 quotas', icon: '✅', category: AchievementCategory.milestone, tier: _s, condition: AchievementCondition.quotasMet, targetValue: 10, rewards: []),
    AchievementDefinition(id: 'quota_25', name: 'Quota Pro', description: 'Meet 25 quotas', icon: '🎯', category: AchievementCategory.milestone, tier: _s, condition: AchievementCondition.quotasMet, targetValue: 25, rewards: []),
    AchievementDefinition(id: 'quota_50', name: 'Quota Master', description: 'Meet 50 quotas', icon: '🏅', category: AchievementCategory.milestone, tier: _g, condition: AchievementCondition.quotasMet, targetValue: 50, rewards: []),
    AchievementDefinition(id: 'quota_100', name: 'Quota Legend', description: 'Meet 100 quotas', icon: '👑', category: AchievementCategory.milestone, tier: _g, condition: AchievementCondition.quotasMet, targetValue: 100, rewards: []),
    AchievementDefinition(id: 'quota_250', name: 'Quota Machine', description: 'Meet 250 quotas', icon: '🤖', category: AchievementCategory.milestone, tier: _p, condition: AchievementCondition.quotasMet, targetValue: 250, rewards: []),
    AchievementDefinition(id: 'quota_500', name: 'Quota King', description: 'Meet 500 quotas', icon: '⚜️', category: AchievementCategory.milestone, tier: _p, condition: AchievementCondition.quotasMet, targetValue: 500, rewards: []),
    AchievementDefinition(id: 'quota_1k', name: 'Quota God', description: 'Meet 1,000 quotas', icon: '🔱', category: AchievementCategory.milestone, tier: _d, condition: AchievementCondition.quotasMet, targetValue: 1000, rewards: []),
    AchievementDefinition(id: 'quota_2500', name: 'Quota Immortal', description: 'Meet 2,500 quotas', icon: '♾️', category: AchievementCategory.milestone, tier: _d, condition: AchievementCondition.quotasMet, targetValue: 2500, rewards: []),

    // --- prestigeCount (10): 1, 3, 5, 10, 25, 50, 100, 250, 500, 1000 ---
    AchievementDefinition(id: 'prestige_1', name: 'Fresh Start', description: 'Prestige for the first time', icon: '🔄', category: AchievementCategory.milestone, tier: _b, condition: AchievementCondition.prestigeCount, targetValue: 1, rewards: []),
    AchievementDefinition(id: 'prestige_3', name: 'Starting Over', description: 'Prestige 3 times', icon: '🔁', category: AchievementCategory.milestone, tier: _b, condition: AchievementCondition.prestigeCount, targetValue: 3, rewards: []),
    AchievementDefinition(id: 'prestige_5', name: 'Seasoned Restarter', description: 'Prestige 5 times', icon: '⭐', category: AchievementCategory.milestone, tier: _s, condition: AchievementCondition.prestigeCount, targetValue: 5, rewards: []),
    AchievementDefinition(id: 'prestige_10', name: 'Veteran Restarter', description: 'Prestige 10 times', icon: '⭐⭐', category: AchievementCategory.milestone, tier: _s, condition: AchievementCondition.prestigeCount, targetValue: 10, rewards: []),
    AchievementDefinition(id: 'prestige_25', name: 'Prestige Pro', description: 'Prestige 25 times', icon: '🌟', category: AchievementCategory.milestone, tier: _g, condition: AchievementCondition.prestigeCount, targetValue: 25, rewards: []),
    AchievementDefinition(id: 'prestige_50', name: 'Prestige Master', description: 'Prestige 50 times', icon: '🌟🌟', category: AchievementCategory.milestone, tier: _g, condition: AchievementCondition.prestigeCount, targetValue: 50, rewards: []),
    AchievementDefinition(id: 'prestige_100', name: 'Prestige Legend', description: 'Prestige 100 times', icon: '💫', category: AchievementCategory.milestone, tier: _p, condition: AchievementCondition.prestigeCount, targetValue: 100, rewards: []),
    AchievementDefinition(id: 'prestige_250', name: 'Prestige King', description: 'Prestige 250 times', icon: '👑', category: AchievementCategory.milestone, tier: _p, condition: AchievementCondition.prestigeCount, targetValue: 250, rewards: []),
    AchievementDefinition(id: 'prestige_500', name: 'Prestige God', description: 'Prestige 500 times', icon: '🔱', category: AchievementCategory.milestone, tier: _d, condition: AchievementCondition.prestigeCount, targetValue: 500, rewards: []),
    AchievementDefinition(id: 'prestige_1k', name: 'Prestige Immortal', description: 'Prestige 1,000 times', icon: '♾️', category: AchievementCategory.milestone, tier: _d, condition: AchievementCondition.prestigeCount, targetValue: 1000, rewards: []),

    // ================================================================
    // RISK (40) — Shorts, all-in, recovery, losses
    // ================================================================

    // --- shortPosition (10): 1, 5, 10, 25, 50, 100, 250, 500, 1k, 5k ---
    AchievementDefinition(id: 'short_1', name: 'Bear Mode', description: 'Open your first short position', icon: '🐻', category: AchievementCategory.risk, tier: _b, condition: AchievementCondition.shortPosition, targetValue: 1, rewards: []),
    AchievementDefinition(id: 'short_5', name: 'Short Seller', description: 'Open 5 short positions', icon: '🐻‍❄️', category: AchievementCategory.risk, tier: _b, condition: AchievementCondition.shortPosition, targetValue: 5, rewards: []),
    AchievementDefinition(id: 'short_10', name: 'Bear Trader', description: 'Open 10 short positions', icon: '📉', category: AchievementCategory.risk, tier: _s, condition: AchievementCondition.shortPosition, targetValue: 10, rewards: []),
    AchievementDefinition(id: 'short_25', name: 'Bear Hunter', description: 'Open 25 short positions', icon: '🎯', category: AchievementCategory.risk, tier: _s, condition: AchievementCondition.shortPosition, targetValue: 25, rewards: []),
    AchievementDefinition(id: 'short_50', name: 'Bear Master', description: 'Open 50 short positions', icon: '🏹', category: AchievementCategory.risk, tier: _g, condition: AchievementCondition.shortPosition, targetValue: 50, rewards: []),
    AchievementDefinition(id: 'short_100', name: 'Bear Market Pro', description: 'Open 100 short positions', icon: '🐻🐻', category: AchievementCategory.risk, tier: _g, condition: AchievementCondition.shortPosition, targetValue: 100, rewards: []),
    AchievementDefinition(id: 'short_250', name: 'Bear King', description: 'Open 250 short positions', icon: '👑', category: AchievementCategory.risk, tier: _p, condition: AchievementCondition.shortPosition, targetValue: 250, rewards: []),
    AchievementDefinition(id: 'short_500', name: 'Bear Legend', description: 'Open 500 short positions', icon: '🌟', category: AchievementCategory.risk, tier: _p, condition: AchievementCondition.shortPosition, targetValue: 500, rewards: []),
    AchievementDefinition(id: 'short_1k', name: 'Bear God', description: 'Open 1,000 short positions', icon: '🔱', category: AchievementCategory.risk, tier: _d, condition: AchievementCondition.shortPosition, targetValue: 1000, rewards: []),
    AchievementDefinition(id: 'short_5k', name: 'Eternal Bear', description: 'Open 5,000 short positions', icon: '♾️', category: AchievementCategory.risk, tier: _d, condition: AchievementCondition.shortPosition, targetValue: 5000, rewards: []),

    // --- allInTrade (10): 1, 3, 5, 10, 25, 50, 100, 250, 500, 1000 ---
    AchievementDefinition(id: 'allin_1', name: 'YOLO', description: 'Use 90%+ of cash in a single trade', icon: '🎰', category: AchievementCategory.risk, tier: _b, condition: AchievementCondition.allInTrade, targetValue: 1, rewards: []),
    AchievementDefinition(id: 'allin_3', name: 'Risk Taker', description: 'Go all-in 3 times', icon: '🎲', category: AchievementCategory.risk, tier: _b, condition: AchievementCondition.allInTrade, targetValue: 3, rewards: []),
    AchievementDefinition(id: 'allin_5', name: 'Degen Trader', description: 'Go all-in 5 times', icon: '💥', category: AchievementCategory.risk, tier: _s, condition: AchievementCondition.allInTrade, targetValue: 5, rewards: []),
    AchievementDefinition(id: 'allin_10', name: 'High Roller', description: 'Go all-in 10 times', icon: '🎰🎰', category: AchievementCategory.risk, tier: _s, condition: AchievementCondition.allInTrade, targetValue: 10, rewards: []),
    AchievementDefinition(id: 'allin_25', name: 'No Fear', description: 'Go all-in 25 times', icon: '🦁', category: AchievementCategory.risk, tier: _g, condition: AchievementCondition.allInTrade, targetValue: 25, rewards: []),
    AchievementDefinition(id: 'allin_50', name: 'All or Nothing', description: 'Go all-in 50 times', icon: '🔥', category: AchievementCategory.risk, tier: _g, condition: AchievementCondition.allInTrade, targetValue: 50, rewards: []),
    AchievementDefinition(id: 'allin_100', name: 'Degen King', description: 'Go all-in 100 times', icon: '👑', category: AchievementCategory.risk, tier: _p, condition: AchievementCondition.allInTrade, targetValue: 100, rewards: []),
    AchievementDefinition(id: 'allin_250', name: 'Degen Legend', description: 'Go all-in 250 times', icon: '🌟', category: AchievementCategory.risk, tier: _p, condition: AchievementCondition.allInTrade, targetValue: 250, rewards: []),
    AchievementDefinition(id: 'allin_500', name: 'Degen God', description: 'Go all-in 500 times', icon: '🔱', category: AchievementCategory.risk, tier: _d, condition: AchievementCondition.allInTrade, targetValue: 500, rewards: []),
    AchievementDefinition(id: 'allin_1k', name: 'Maximum Degen', description: 'Go all-in 1,000 times', icon: '♾️', category: AchievementCategory.risk, tier: _d, condition: AchievementCondition.allInTrade, targetValue: 1000, rewards: []),

    // --- recoverFromLoss (10): 10%, 20%, 30%, 40%, 50%, 60%, 70%, 80%, 90%, 95% ---
    AchievementDefinition(id: 'recover_10', name: 'Minor Setback', description: 'Recover from a 10% portfolio loss', icon: '🩹', category: AchievementCategory.risk, tier: _b, condition: AchievementCondition.recoverFromLoss, targetValue: 10, rewards: []),
    AchievementDefinition(id: 'recover_20', name: 'Bounce Back', description: 'Recover from a 20% portfolio loss', icon: '🔄', category: AchievementCategory.risk, tier: _b, condition: AchievementCondition.recoverFromLoss, targetValue: 20, rewards: []),
    AchievementDefinition(id: 'recover_30', name: 'Resilient', description: 'Recover from a 30% portfolio loss', icon: '💪', category: AchievementCategory.risk, tier: _s, condition: AchievementCondition.recoverFromLoss, targetValue: 30, rewards: []),
    AchievementDefinition(id: 'recover_40', name: 'Hard Recovery', description: 'Recover from a 40% portfolio loss', icon: '🦅', category: AchievementCategory.risk, tier: _s, condition: AchievementCondition.recoverFromLoss, targetValue: 40, rewards: []),
    AchievementDefinition(id: 'recover_50', name: 'Comeback Kid', description: 'Recover from a 50% portfolio loss', icon: '🔥', category: AchievementCategory.risk, tier: _g, condition: AchievementCondition.recoverFromLoss, targetValue: 50, rewards: []),
    AchievementDefinition(id: 'recover_60', name: 'Phoenix', description: 'Recover from a 60% portfolio loss', icon: '🐦‍🔥', category: AchievementCategory.risk, tier: _g, condition: AchievementCondition.recoverFromLoss, targetValue: 60, rewards: []),
    AchievementDefinition(id: 'recover_70', name: 'Iron Will', description: 'Recover from a 70% portfolio loss', icon: '🛡️', category: AchievementCategory.risk, tier: _p, condition: AchievementCondition.recoverFromLoss, targetValue: 70, rewards: []),
    AchievementDefinition(id: 'recover_80', name: 'Unbreakable', description: 'Recover from a 80% portfolio loss', icon: '🗿', category: AchievementCategory.risk, tier: _p, condition: AchievementCondition.recoverFromLoss, targetValue: 80, rewards: []),
    AchievementDefinition(id: 'recover_90', name: 'From The Ashes', description: 'Recover from a 90% portfolio loss', icon: '🌋', category: AchievementCategory.risk, tier: _d, condition: AchievementCondition.recoverFromLoss, targetValue: 90, rewards: []),
    AchievementDefinition(id: 'recover_95', name: 'Miracle Recovery', description: 'Recover from a 95% portfolio loss', icon: '✨', category: AchievementCategory.risk, tier: _d, condition: AchievementCondition.recoverFromLoss, targetValue: 95, rewards: []),

    // --- totalLoss (10): 100, 1k, 5k, 25k, 100k, 500k, 2.5M, 10M, 50M, 500M ---
    AchievementDefinition(id: 'loss_100', name: 'First Scratch', description: 'Lose \$100 total', icon: '🩸', category: AchievementCategory.risk, tier: _b, condition: AchievementCondition.totalLoss, targetValue: 100, rewards: []),
    AchievementDefinition(id: 'loss_1k', name: 'Tuition Paid', description: 'Lose \$1,000 total', icon: '📕', category: AchievementCategory.risk, tier: _b, condition: AchievementCondition.totalLoss, targetValue: 1000, rewards: []),
    AchievementDefinition(id: 'loss_5k', name: 'Expensive Lessons', description: 'Lose \$5,000 total', icon: '📕📕', category: AchievementCategory.risk, tier: _s, condition: AchievementCondition.totalLoss, targetValue: 5000, rewards: []),
    AchievementDefinition(id: 'loss_25k', name: 'Deep Wounds', description: 'Lose \$25,000 total', icon: '🩹🩹', category: AchievementCategory.risk, tier: _s, condition: AchievementCondition.totalLoss, targetValue: 25000, rewards: []),
    AchievementDefinition(id: 'loss_100k', name: 'Battle Scarred', description: 'Lose \$100,000 total', icon: '⚔️', category: AchievementCategory.risk, tier: _g, condition: AchievementCondition.totalLoss, targetValue: 100000, rewards: []),
    AchievementDefinition(id: 'loss_500k', name: 'War Veteran', description: 'Lose \$500,000 total', icon: '🎖️', category: AchievementCategory.risk, tier: _g, condition: AchievementCondition.totalLoss, targetValue: 500000, rewards: []),
    AchievementDefinition(id: 'loss_2500k', name: 'Scarred Forever', description: 'Lose \$2,500,000 total', icon: '💔', category: AchievementCategory.risk, tier: _p, condition: AchievementCondition.totalLoss, targetValue: 2500000, rewards: []),
    AchievementDefinition(id: 'loss_10m', name: 'Loss Legend', description: 'Lose \$10,000,000 total', icon: '🖤', category: AchievementCategory.risk, tier: _p, condition: AchievementCondition.totalLoss, targetValue: 10000000, rewards: []),
    AchievementDefinition(id: 'loss_50m', name: 'Loss Titan', description: 'Lose \$50,000,000 total', icon: '🕳️', category: AchievementCategory.risk, tier: _d, condition: AchievementCondition.totalLoss, targetValue: 50000000, rewards: []),
    AchievementDefinition(id: 'loss_500m', name: 'Infinite Pain', description: 'Lose \$500,000,000 total', icon: '♾️', category: AchievementCategory.risk, tier: _d, condition: AchievementCondition.totalLoss, targetValue: 500000000, rewards: []),

    // ================================================================
    // MARKET (40) — Informant, FinTok, challenges, tokens
    // ================================================================

    // --- informantTipsBought (10): 1, 5, 10, 25, 50, 100, 250, 500, 1k, 2.5k ---
    AchievementDefinition(id: 'informant_1', name: 'First Contact', description: 'Buy your first informant tip', icon: '🕵️', category: AchievementCategory.market, tier: _b, condition: AchievementCondition.informantTipsBought, targetValue: 1, rewards: []),
    AchievementDefinition(id: 'informant_5', name: 'Informant Friend', description: 'Buy 5 informant tips', icon: '🕵️‍♂️', category: AchievementCategory.market, tier: _b, condition: AchievementCondition.informantTipsBought, targetValue: 5, rewards: []),
    AchievementDefinition(id: 'informant_10', name: 'Insider Info', description: 'Buy 10 informant tips', icon: '🤝', category: AchievementCategory.market, tier: _s, condition: AchievementCondition.informantTipsBought, targetValue: 10, rewards: []),
    AchievementDefinition(id: 'informant_25', name: 'Deep Connections', description: 'Buy 25 informant tips', icon: '🔗', category: AchievementCategory.market, tier: _s, condition: AchievementCondition.informantTipsBought, targetValue: 25, rewards: []),
    AchievementDefinition(id: 'informant_50', name: 'Informant Network', description: 'Buy 50 informant tips', icon: '🕸️', category: AchievementCategory.market, tier: _g, condition: AchievementCondition.informantTipsBought, targetValue: 50, rewards: []),
    AchievementDefinition(id: 'informant_100', name: 'Intelligence Hub', description: 'Buy 100 informant tips', icon: '🏢', category: AchievementCategory.market, tier: _g, condition: AchievementCondition.informantTipsBought, targetValue: 100, rewards: []),
    AchievementDefinition(id: 'informant_250', name: 'Spy Master', description: 'Buy 250 informant tips', icon: '🎭', category: AchievementCategory.market, tier: _p, condition: AchievementCondition.informantTipsBought, targetValue: 250, rewards: []),
    AchievementDefinition(id: 'informant_500', name: 'Shadow Broker', description: 'Buy 500 informant tips', icon: '🌑', category: AchievementCategory.market, tier: _p, condition: AchievementCondition.informantTipsBought, targetValue: 500, rewards: []),
    AchievementDefinition(id: 'informant_1k', name: 'Information God', description: 'Buy 1,000 informant tips', icon: '🔱', category: AchievementCategory.market, tier: _d, condition: AchievementCondition.informantTipsBought, targetValue: 1000, rewards: []),
    AchievementDefinition(id: 'informant_2500', name: 'Omniscient', description: 'Buy 2,500 informant tips', icon: '♾️', category: AchievementCategory.market, tier: _d, condition: AchievementCondition.informantTipsBought, targetValue: 2500, rewards: []),

    // --- fintokTipsFollowed (10): 1, 5, 10, 25, 50, 100, 250, 500, 1k, 2.5k ---
    AchievementDefinition(id: 'fintok_1', name: 'First Follow', description: 'Follow your first FinTok tip', icon: '📱', category: AchievementCategory.market, tier: _b, condition: AchievementCondition.fintokTipsFollowed, targetValue: 1, rewards: []),
    AchievementDefinition(id: 'fintok_5', name: 'FinTok Fan', description: 'Follow 5 FinTok tips', icon: '📲', category: AchievementCategory.market, tier: _b, condition: AchievementCondition.fintokTipsFollowed, targetValue: 5, rewards: []),
    AchievementDefinition(id: 'fintok_10', name: 'FinTok Follower', description: 'Follow 10 FinTok tips', icon: '👍', category: AchievementCategory.market, tier: _s, condition: AchievementCondition.fintokTipsFollowed, targetValue: 10, rewards: []),
    AchievementDefinition(id: 'fintok_25', name: 'FinTok Regular', description: 'Follow 25 FinTok tips', icon: '🤳', category: AchievementCategory.market, tier: _s, condition: AchievementCondition.fintokTipsFollowed, targetValue: 25, rewards: []),
    AchievementDefinition(id: 'fintok_50', name: 'FinTok Addict', description: 'Follow 50 FinTok tips', icon: '📵', category: AchievementCategory.market, tier: _g, condition: AchievementCondition.fintokTipsFollowed, targetValue: 50, rewards: []),
    AchievementDefinition(id: 'fintok_100', name: 'FinTok Guru', description: 'Follow 100 FinTok tips', icon: '🧠', category: AchievementCategory.market, tier: _g, condition: AchievementCondition.fintokTipsFollowed, targetValue: 100, rewards: []),
    AchievementDefinition(id: 'fintok_250', name: 'FinTok Legend', description: 'Follow 250 FinTok tips', icon: '🌟', category: AchievementCategory.market, tier: _p, condition: AchievementCondition.fintokTipsFollowed, targetValue: 250, rewards: []),
    AchievementDefinition(id: 'fintok_500', name: 'FinTok King', description: 'Follow 500 FinTok tips', icon: '👑', category: AchievementCategory.market, tier: _p, condition: AchievementCondition.fintokTipsFollowed, targetValue: 500, rewards: []),
    AchievementDefinition(id: 'fintok_1k', name: 'FinTok God', description: 'Follow 1,000 FinTok tips', icon: '🔱', category: AchievementCategory.market, tier: _d, condition: AchievementCondition.fintokTipsFollowed, targetValue: 1000, rewards: []),
    AchievementDefinition(id: 'fintok_2500', name: 'FinTok Immortal', description: 'Follow 2,500 FinTok tips', icon: '♾️', category: AchievementCategory.market, tier: _d, condition: AchievementCondition.fintokTipsFollowed, targetValue: 2500, rewards: []),

    // --- challengesCompleted (10): 1, 5, 10, 25, 50, 100, 250, 500, 1k, 2.5k ---
    AchievementDefinition(id: 'challenge_1', name: 'First Challenge', description: 'Complete a daily challenge', icon: '📋', category: AchievementCategory.market, tier: _b, condition: AchievementCondition.challengesCompleted, targetValue: 1, rewards: []),
    AchievementDefinition(id: 'challenge_5', name: 'Challenge Seeker', description: 'Complete 5 daily challenges', icon: '🏋️', category: AchievementCategory.market, tier: _b, condition: AchievementCondition.challengesCompleted, targetValue: 5, rewards: []),
    AchievementDefinition(id: 'challenge_10', name: 'Challenge Accepted', description: 'Complete 10 daily challenges', icon: '🏋️‍♂️', category: AchievementCategory.market, tier: _s, condition: AchievementCondition.challengesCompleted, targetValue: 10, rewards: []),
    AchievementDefinition(id: 'challenge_25', name: 'Challenge Addict', description: 'Complete 25 daily challenges', icon: '💪', category: AchievementCategory.market, tier: _s, condition: AchievementCondition.challengesCompleted, targetValue: 25, rewards: []),
    AchievementDefinition(id: 'challenge_50', name: 'Challenge Crusher', description: 'Complete 50 daily challenges', icon: '🥊', category: AchievementCategory.market, tier: _g, condition: AchievementCondition.challengesCompleted, targetValue: 50, rewards: []),
    AchievementDefinition(id: 'challenge_100', name: 'Challenge Master', description: 'Complete 100 daily challenges', icon: '🥇', category: AchievementCategory.market, tier: _g, condition: AchievementCondition.challengesCompleted, targetValue: 100, rewards: []),
    AchievementDefinition(id: 'challenge_250', name: 'Challenge Legend', description: 'Complete 250 daily challenges', icon: '🏆', category: AchievementCategory.market, tier: _p, condition: AchievementCondition.challengesCompleted, targetValue: 250, rewards: []),
    AchievementDefinition(id: 'challenge_500', name: 'Challenge King', description: 'Complete 500 daily challenges', icon: '👑', category: AchievementCategory.market, tier: _p, condition: AchievementCondition.challengesCompleted, targetValue: 500, rewards: []),
    AchievementDefinition(id: 'challenge_1k', name: 'Challenge God', description: 'Complete 1,000 daily challenges', icon: '🔱', category: AchievementCategory.market, tier: _d, condition: AchievementCondition.challengesCompleted, targetValue: 1000, rewards: []),
    AchievementDefinition(id: 'challenge_2500', name: 'Challenge Immortal', description: 'Complete 2,500 daily challenges', icon: '♾️', category: AchievementCategory.market, tier: _d, condition: AchievementCondition.challengesCompleted, targetValue: 2500, rewards: []),

    // --- tokensPlaced (10): 1, 5, 10, 25, 50, 100, 250, 500, 1k, 2.5k ---
    AchievementDefinition(id: 'token_1', name: 'Token Holder', description: 'Place your first token', icon: '🪙', category: AchievementCategory.market, tier: _b, condition: AchievementCondition.tokensPlaced, targetValue: 1, rewards: []),
    AchievementDefinition(id: 'token_5', name: 'Token Fan', description: 'Place 5 tokens', icon: '🪙🪙', category: AchievementCategory.market, tier: _b, condition: AchievementCondition.tokensPlaced, targetValue: 5, rewards: []),
    AchievementDefinition(id: 'token_10', name: 'Token Collector', description: 'Place 10 tokens', icon: '💿', category: AchievementCategory.market, tier: _s, condition: AchievementCondition.tokensPlaced, targetValue: 10, rewards: []),
    AchievementDefinition(id: 'token_25', name: 'Token Trader', description: 'Place 25 tokens', icon: '🥈', category: AchievementCategory.market, tier: _s, condition: AchievementCondition.tokensPlaced, targetValue: 25, rewards: []),
    AchievementDefinition(id: 'token_50', name: 'Token Master', description: 'Place 50 tokens', icon: '🥇', category: AchievementCategory.market, tier: _g, condition: AchievementCondition.tokensPlaced, targetValue: 50, rewards: []),
    AchievementDefinition(id: 'token_100', name: 'Token Baron', description: 'Place 100 tokens', icon: '💰', category: AchievementCategory.market, tier: _g, condition: AchievementCondition.tokensPlaced, targetValue: 100, rewards: []),
    AchievementDefinition(id: 'token_250', name: 'Token King', description: 'Place 250 tokens', icon: '👑', category: AchievementCategory.market, tier: _p, condition: AchievementCondition.tokensPlaced, targetValue: 250, rewards: []),
    AchievementDefinition(id: 'token_500', name: 'Token Legend', description: 'Place 500 tokens', icon: '🌟', category: AchievementCategory.market, tier: _p, condition: AchievementCondition.tokensPlaced, targetValue: 500, rewards: []),
    AchievementDefinition(id: 'token_1k', name: 'Token God', description: 'Place 1,000 tokens', icon: '🔱', category: AchievementCategory.market, tier: _d, condition: AchievementCondition.tokensPlaced, targetValue: 1000, rewards: []),
    AchievementDefinition(id: 'token_2500', name: 'Token Immortal', description: 'Place 2,500 tokens', icon: '♾️', category: AchievementCategory.market, tier: _d, condition: AchievementCondition.tokensPlaced, targetValue: 2500, rewards: []),

    // ================================================================
    // SECRET (70) — Hidden achievements, discovered by playing
    // ================================================================

    // --- perfectTrade (10): 1, 3, 5, 10, 25, 50, 100, 250, 500, 1000 ---
    AchievementDefinition(id: 'perfect_1', name: 'Perfect Timing', description: 'Buy at the day\'s low and sell at the high', icon: '🎯', category: AchievementCategory.secret, tier: _b, condition: AchievementCondition.perfectTrade, targetValue: 1, rewards: [], isSecret: true),
    AchievementDefinition(id: 'perfect_3', name: 'Lucky Trader', description: '3 perfect trades', icon: '🎯🎯', category: AchievementCategory.secret, tier: _b, condition: AchievementCondition.perfectTrade, targetValue: 3, rewards: [], isSecret: true),
    AchievementDefinition(id: 'perfect_5', name: 'Sharp Eye', description: '5 perfect trades', icon: '👁️', category: AchievementCategory.secret, tier: _s, condition: AchievementCondition.perfectTrade, targetValue: 5, rewards: [], isSecret: true),
    AchievementDefinition(id: 'perfect_10', name: 'Market Reader', description: '10 perfect trades', icon: '📖', category: AchievementCategory.secret, tier: _s, condition: AchievementCondition.perfectTrade, targetValue: 10, rewards: [], isSecret: true),
    AchievementDefinition(id: 'perfect_25', name: 'Perfect Pro', description: '25 perfect trades', icon: '🔮', category: AchievementCategory.secret, tier: _g, condition: AchievementCondition.perfectTrade, targetValue: 25, rewards: [], isSecret: true),
    AchievementDefinition(id: 'perfect_50', name: 'Oracle', description: '50 perfect trades', icon: '🔮🔮', category: AchievementCategory.secret, tier: _g, condition: AchievementCondition.perfectTrade, targetValue: 50, rewards: [], isSecret: true),
    AchievementDefinition(id: 'perfect_100', name: 'Market Oracle', description: '100 perfect trades', icon: '🌟', category: AchievementCategory.secret, tier: _p, condition: AchievementCondition.perfectTrade, targetValue: 100, rewards: [], isSecret: true),
    AchievementDefinition(id: 'perfect_250', name: 'Prophet', description: '250 perfect trades', icon: '✨', category: AchievementCategory.secret, tier: _p, condition: AchievementCondition.perfectTrade, targetValue: 250, rewards: [], isSecret: true),
    AchievementDefinition(id: 'perfect_500', name: 'Omniscient Trader', description: '500 perfect trades', icon: '👑', category: AchievementCategory.secret, tier: _d, condition: AchievementCondition.perfectTrade, targetValue: 500, rewards: [], isSecret: true),
    AchievementDefinition(id: 'perfect_1k', name: 'Time Traveler', description: '1,000 perfect trades', icon: '♾️', category: AchievementCategory.secret, tier: _d, condition: AchievementCondition.perfectTrade, targetValue: 1000, rewards: [], isSecret: true),

    // --- contrarian (10): 1, 3, 5, 10, 25, 50, 100, 250, 500, 1000 ---
    AchievementDefinition(id: 'contrarian_1', name: 'Contrarian', description: 'Profit from a news contradiction', icon: '🔮', category: AchievementCategory.secret, tier: _b, condition: AchievementCondition.contrarian, targetValue: 1, rewards: [], isSecret: true),
    AchievementDefinition(id: 'contrarian_3', name: 'Skeptic', description: 'Profit from 3 news contradictions', icon: '🤔', category: AchievementCategory.secret, tier: _b, condition: AchievementCondition.contrarian, targetValue: 3, rewards: [], isSecret: true),
    AchievementDefinition(id: 'contrarian_5', name: 'Against The Grain', description: 'Profit from 5 news contradictions', icon: '🔄', category: AchievementCategory.secret, tier: _s, condition: AchievementCondition.contrarian, targetValue: 5, rewards: [], isSecret: true),
    AchievementDefinition(id: 'contrarian_10', name: 'News Denier', description: 'Profit from 10 news contradictions', icon: '📰❌', category: AchievementCategory.secret, tier: _s, condition: AchievementCondition.contrarian, targetValue: 10, rewards: [], isSecret: true),
    AchievementDefinition(id: 'contrarian_25', name: 'Contrarian Pro', description: 'Profit from 25 news contradictions', icon: '🧠', category: AchievementCategory.secret, tier: _g, condition: AchievementCondition.contrarian, targetValue: 25, rewards: [], isSecret: true),
    AchievementDefinition(id: 'contrarian_50', name: 'Contrarian Master', description: 'Profit from 50 news contradictions', icon: '🧙', category: AchievementCategory.secret, tier: _g, condition: AchievementCondition.contrarian, targetValue: 50, rewards: [], isSecret: true),
    AchievementDefinition(id: 'contrarian_100', name: 'Contrarian Legend', description: 'Profit from 100 news contradictions', icon: '🌟', category: AchievementCategory.secret, tier: _p, condition: AchievementCondition.contrarian, targetValue: 100, rewards: [], isSecret: true),
    AchievementDefinition(id: 'contrarian_250', name: 'Contrarian King', description: 'Profit from 250 news contradictions', icon: '👑', category: AchievementCategory.secret, tier: _p, condition: AchievementCondition.contrarian, targetValue: 250, rewards: [], isSecret: true),
    AchievementDefinition(id: 'contrarian_500', name: 'Contrarian God', description: 'Profit from 500 news contradictions', icon: '🔱', category: AchievementCategory.secret, tier: _d, condition: AchievementCondition.contrarian, targetValue: 500, rewards: [], isSecret: true),
    AchievementDefinition(id: 'contrarian_1k', name: 'Contrarian Immortal', description: 'Profit from 1,000 news contradictions', icon: '♾️', category: AchievementCategory.secret, tier: _d, condition: AchievementCondition.contrarian, targetValue: 1000, rewards: [], isSecret: true),

    // --- dipBuys (10): 1, 5, 10, 25, 50, 100, 250, 500, 1k, 2.5k ---
    AchievementDefinition(id: 'dip_1', name: 'Dip Buyer', description: 'Buy a stock that dropped significantly', icon: '🛒', category: AchievementCategory.secret, tier: _b, condition: AchievementCondition.dipBuys, targetValue: 1, rewards: [], isSecret: true),
    AchievementDefinition(id: 'dip_5', name: 'Bargain Hunter', description: 'Buy 5 dipping stocks', icon: '🏷️', category: AchievementCategory.secret, tier: _b, condition: AchievementCondition.dipBuys, targetValue: 5, rewards: [], isSecret: true),
    AchievementDefinition(id: 'dip_10', name: 'Bottom Fisher', description: 'Buy 10 dipping stocks', icon: '🎣', category: AchievementCategory.secret, tier: _s, condition: AchievementCondition.dipBuys, targetValue: 10, rewards: [], isSecret: true),
    AchievementDefinition(id: 'dip_25', name: 'Dip Master', description: 'Buy 25 dipping stocks', icon: '🛍️', category: AchievementCategory.secret, tier: _s, condition: AchievementCondition.dipBuys, targetValue: 25, rewards: [], isSecret: true),
    AchievementDefinition(id: 'dip_50', name: 'Fire Sale King', description: 'Buy 50 dipping stocks', icon: '🔥🛒', category: AchievementCategory.secret, tier: _g, condition: AchievementCondition.dipBuys, targetValue: 50, rewards: [], isSecret: true),
    AchievementDefinition(id: 'dip_100', name: 'Crash Buyer', description: 'Buy 100 dipping stocks', icon: '📉🛒', category: AchievementCategory.secret, tier: _g, condition: AchievementCondition.dipBuys, targetValue: 100, rewards: [], isSecret: true),
    AchievementDefinition(id: 'dip_250', name: 'Blood In Streets', description: 'Buy 250 dipping stocks', icon: '🩸', category: AchievementCategory.secret, tier: _p, condition: AchievementCondition.dipBuys, targetValue: 250, rewards: [], isSecret: true),
    AchievementDefinition(id: 'dip_500', name: 'Dip Legend', description: 'Buy 500 dipping stocks', icon: '🌟', category: AchievementCategory.secret, tier: _p, condition: AchievementCondition.dipBuys, targetValue: 500, rewards: [], isSecret: true),
    AchievementDefinition(id: 'dip_1k', name: 'Dip God', description: 'Buy 1,000 dipping stocks', icon: '🔱', category: AchievementCategory.secret, tier: _d, condition: AchievementCondition.dipBuys, targetValue: 1000, rewards: [], isSecret: true),
    AchievementDefinition(id: 'dip_2500', name: 'Eternal Dip Buyer', description: 'Buy 2,500 dipping stocks', icon: '♾️', category: AchievementCategory.secret, tier: _d, condition: AchievementCondition.dipBuys, targetValue: 2500, rewards: [], isSecret: true),

    // --- sellHighs (10): 1, 5, 10, 25, 50, 100, 250, 500, 1k, 2.5k ---
    AchievementDefinition(id: 'sellhigh_1', name: 'Peak Seller', description: 'Sell a stock at its high', icon: '📤', category: AchievementCategory.secret, tier: _b, condition: AchievementCondition.sellHighs, targetValue: 1, rewards: [], isSecret: true),
    AchievementDefinition(id: 'sellhigh_5', name: 'Top Timer', description: 'Sell 5 stocks at their high', icon: '⏰', category: AchievementCategory.secret, tier: _b, condition: AchievementCondition.sellHighs, targetValue: 5, rewards: [], isSecret: true),
    AchievementDefinition(id: 'sellhigh_10', name: 'High Seller', description: 'Sell 10 stocks at their high', icon: '🔝', category: AchievementCategory.secret, tier: _s, condition: AchievementCondition.sellHighs, targetValue: 10, rewards: [], isSecret: true),
    AchievementDefinition(id: 'sellhigh_25', name: 'Top Predictor', description: 'Sell 25 stocks at their high', icon: '🎯', category: AchievementCategory.secret, tier: _s, condition: AchievementCondition.sellHighs, targetValue: 25, rewards: [], isSecret: true),
    AchievementDefinition(id: 'sellhigh_50', name: 'Peak Master', description: 'Sell 50 stocks at their high', icon: '🏔️', category: AchievementCategory.secret, tier: _g, condition: AchievementCondition.sellHighs, targetValue: 50, rewards: [], isSecret: true),
    AchievementDefinition(id: 'sellhigh_100', name: 'Summit King', description: 'Sell 100 stocks at their high', icon: '⛰️', category: AchievementCategory.secret, tier: _g, condition: AchievementCondition.sellHighs, targetValue: 100, rewards: [], isSecret: true),
    AchievementDefinition(id: 'sellhigh_250', name: 'Peak Legend', description: 'Sell 250 stocks at their high', icon: '🌟', category: AchievementCategory.secret, tier: _p, condition: AchievementCondition.sellHighs, targetValue: 250, rewards: [], isSecret: true),
    AchievementDefinition(id: 'sellhigh_500', name: 'Peak God', description: 'Sell 500 stocks at their high', icon: '👑', category: AchievementCategory.secret, tier: _p, condition: AchievementCondition.sellHighs, targetValue: 500, rewards: [], isSecret: true),
    AchievementDefinition(id: 'sellhigh_1k', name: 'Top Caller', description: 'Sell 1,000 stocks at their high', icon: '🔱', category: AchievementCategory.secret, tier: _d, condition: AchievementCondition.sellHighs, targetValue: 1000, rewards: [], isSecret: true),
    AchievementDefinition(id: 'sellhigh_2500', name: 'Eternal Peak', description: 'Sell 2,500 stocks at their high', icon: '♾️', category: AchievementCategory.secret, tier: _d, condition: AchievementCondition.sellHighs, targetValue: 2500, rewards: [], isSecret: true),

    // --- noTradeDay (10): 1, 3, 5, 10, 25, 50, 100, 200, 365, 500 ---
    AchievementDefinition(id: 'notrade_1', name: 'Patience', description: 'Complete a day without trading', icon: '🧘', category: AchievementCategory.secret, tier: _b, condition: AchievementCondition.noTradeDay, targetValue: 1, rewards: [], isSecret: true),
    AchievementDefinition(id: 'notrade_3', name: 'Zen Trader', description: '3 days without trading', icon: '🧘‍♂️', category: AchievementCategory.secret, tier: _b, condition: AchievementCondition.noTradeDay, targetValue: 3, rewards: [], isSecret: true),
    AchievementDefinition(id: 'notrade_5', name: 'Calm Mind', description: '5 days without trading', icon: '☮️', category: AchievementCategory.secret, tier: _s, condition: AchievementCondition.noTradeDay, targetValue: 5, rewards: [], isSecret: true),
    AchievementDefinition(id: 'notrade_10', name: 'Meditative', description: '10 days without trading', icon: '🕊️', category: AchievementCategory.secret, tier: _s, condition: AchievementCondition.noTradeDay, targetValue: 10, rewards: [], isSecret: true),
    AchievementDefinition(id: 'notrade_25', name: 'Monk Trader', description: '25 days without trading', icon: '📿', category: AchievementCategory.secret, tier: _g, condition: AchievementCondition.noTradeDay, targetValue: 25, rewards: [], isSecret: true),
    AchievementDefinition(id: 'notrade_50', name: 'Still Waters', description: '50 days without trading', icon: '🌊', category: AchievementCategory.secret, tier: _g, condition: AchievementCondition.noTradeDay, targetValue: 50, rewards: [], isSecret: true),
    AchievementDefinition(id: 'notrade_100', name: 'Patient Master', description: '100 days without trading', icon: '🏔️', category: AchievementCategory.secret, tier: _p, condition: AchievementCondition.noTradeDay, targetValue: 100, rewards: [], isSecret: true),
    AchievementDefinition(id: 'notrade_200', name: 'Zen Master', description: '200 days without trading', icon: '🌸', category: AchievementCategory.secret, tier: _p, condition: AchievementCondition.noTradeDay, targetValue: 200, rewards: [], isSecret: true),
    AchievementDefinition(id: 'notrade_365', name: 'Year of Silence', description: '365 days without trading', icon: '🔱', category: AchievementCategory.secret, tier: _d, condition: AchievementCondition.noTradeDay, targetValue: 365, rewards: [], isSecret: true),
    AchievementDefinition(id: 'notrade_500', name: 'Eternal Patience', description: '500 days without trading', icon: '♾️', category: AchievementCategory.secret, tier: _d, condition: AchievementCondition.noTradeDay, targetValue: 500, rewards: [], isSecret: true),

    // --- maxPositionsFilled (10): 1, 5, 10, 25, 50, 100, 250, 500, 1k, 2.5k ---
    AchievementDefinition(id: 'maxpos_1', name: 'All Slots Full', description: 'Fill all position slots at once', icon: '📦', category: AchievementCategory.secret, tier: _b, condition: AchievementCondition.maxPositionsFilled, targetValue: 1, rewards: [], isSecret: true),
    AchievementDefinition(id: 'maxpos_5', name: 'Packed Portfolio', description: 'Fill all slots 5 times', icon: '📦📦', category: AchievementCategory.secret, tier: _b, condition: AchievementCondition.maxPositionsFilled, targetValue: 5, rewards: [], isSecret: true),
    AchievementDefinition(id: 'maxpos_10', name: 'Always Full', description: 'Fill all slots 10 times', icon: '🗄️', category: AchievementCategory.secret, tier: _s, condition: AchievementCondition.maxPositionsFilled, targetValue: 10, rewards: [], isSecret: true),
    AchievementDefinition(id: 'maxpos_25', name: 'Portfolio Stacker', description: 'Fill all slots 25 times', icon: '📚', category: AchievementCategory.secret, tier: _s, condition: AchievementCondition.maxPositionsFilled, targetValue: 25, rewards: [], isSecret: true),
    AchievementDefinition(id: 'maxpos_50', name: 'Position Hoarder', description: 'Fill all slots 50 times', icon: '🏗️', category: AchievementCategory.secret, tier: _g, condition: AchievementCondition.maxPositionsFilled, targetValue: 50, rewards: [], isSecret: true),
    AchievementDefinition(id: 'maxpos_100', name: 'Slot Machine', description: 'Fill all slots 100 times', icon: '🎰', category: AchievementCategory.secret, tier: _g, condition: AchievementCondition.maxPositionsFilled, targetValue: 100, rewards: [], isSecret: true),
    AchievementDefinition(id: 'maxpos_250', name: 'Position Legend', description: 'Fill all slots 250 times', icon: '🌟', category: AchievementCategory.secret, tier: _p, condition: AchievementCondition.maxPositionsFilled, targetValue: 250, rewards: [], isSecret: true),
    AchievementDefinition(id: 'maxpos_500', name: 'Full House King', description: 'Fill all slots 500 times', icon: '👑', category: AchievementCategory.secret, tier: _p, condition: AchievementCondition.maxPositionsFilled, targetValue: 500, rewards: [], isSecret: true),
    AchievementDefinition(id: 'maxpos_1k', name: 'Position God', description: 'Fill all slots 1,000 times', icon: '🔱', category: AchievementCategory.secret, tier: _d, condition: AchievementCondition.maxPositionsFilled, targetValue: 1000, rewards: [], isSecret: true),
    AchievementDefinition(id: 'maxpos_2500', name: 'Eternal Full', description: 'Fill all slots 2,500 times', icon: '♾️', category: AchievementCategory.secret, tier: _d, condition: AchievementCondition.maxPositionsFilled, targetValue: 2500, rewards: [], isSecret: true),

    // --- upgradesOwned (10): 3, 5, 7, 10, 13, 16, 19, 22, 25, 29 ---
    AchievementDefinition(id: 'upgrade_3', name: 'First Upgrades', description: 'Own 3 upgrades in a single run', icon: '⬆️', category: AchievementCategory.secret, tier: _b, condition: AchievementCondition.upgradesOwned, targetValue: 3, rewards: [], isSecret: true),
    AchievementDefinition(id: 'upgrade_5', name: 'Upgrade Fan', description: 'Own 5 upgrades in a single run', icon: '⬆️⬆️', category: AchievementCategory.secret, tier: _b, condition: AchievementCondition.upgradesOwned, targetValue: 5, rewards: [], isSecret: true),
    AchievementDefinition(id: 'upgrade_7', name: 'Upgrade Collector', description: 'Own 7 upgrades in a single run', icon: '📦', category: AchievementCategory.secret, tier: _s, condition: AchievementCondition.upgradesOwned, targetValue: 7, rewards: [], isSecret: true),
    AchievementDefinition(id: 'upgrade_10', name: 'Upgrade Hoarder', description: 'Own 10 upgrades in a single run', icon: '🗃️', category: AchievementCategory.secret, tier: _s, condition: AchievementCondition.upgradesOwned, targetValue: 10, rewards: [], isSecret: true),
    AchievementDefinition(id: 'upgrade_13', name: 'Upgrade Pro', description: 'Own 13 upgrades in a single run', icon: '📈', category: AchievementCategory.secret, tier: _g, condition: AchievementCondition.upgradesOwned, targetValue: 13, rewards: [], isSecret: true),
    AchievementDefinition(id: 'upgrade_16', name: 'Upgrade Master', description: 'Own 16 upgrades in a single run', icon: '🏅', category: AchievementCategory.secret, tier: _g, condition: AchievementCondition.upgradesOwned, targetValue: 16, rewards: [], isSecret: true),
    AchievementDefinition(id: 'upgrade_19', name: 'Upgrade Legend', description: 'Own 19 upgrades in a single run', icon: '🌟', category: AchievementCategory.secret, tier: _p, condition: AchievementCondition.upgradesOwned, targetValue: 19, rewards: [], isSecret: true),
    AchievementDefinition(id: 'upgrade_22', name: 'Upgrade King', description: 'Own 22 upgrades in a single run', icon: '👑', category: AchievementCategory.secret, tier: _p, condition: AchievementCondition.upgradesOwned, targetValue: 22, rewards: [], isSecret: true),
    AchievementDefinition(id: 'upgrade_25', name: 'Fully Loaded', description: 'Own 25 upgrades in a single run', icon: '🚀', category: AchievementCategory.secret, tier: _d, condition: AchievementCondition.upgradesOwned, targetValue: 25, rewards: [], isSecret: true),
    AchievementDefinition(id: 'upgrade_29', name: 'Maximum Power', description: 'Own 29 upgrades in a single run', icon: '♾️', category: AchievementCategory.secret, tier: _d, condition: AchievementCondition.upgradesOwned, targetValue: 29, rewards: [], isSecret: true),
  ];

  /// Get achievement by ID
  static AchievementDefinition? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get achievements by category
  static List<AchievementDefinition> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }

  /// Get achievements by tier
  static List<AchievementDefinition> getByTier(AchievementTier tier) {
    return all.where((a) => a.tier == tier).toList();
  }

  /// Get achievements by condition
  static List<AchievementDefinition> getByCondition(AchievementCondition condition) {
    return all.where((a) => a.condition == condition).toList();
  }

  /// Get non-secret achievements
  static List<AchievementDefinition> getVisible() {
    return all.where((a) => !a.isSecret).toList();
  }

  // ================================================================
  // Reward computation (mapping tables + tier scaling)
  // ================================================================

  /// PP awarded per tier position (B1 B2 S1 S2 G1 G2 P1 P2 D1 D2)
  static const List<int> _ppByPosition = [1, 1, 2, 3, 5, 8, 15, 25, 40, 75];

  /// Condition → bonus type mapping (30 chains)
  static const Map<AchievementCondition, RewardType> _conditionBonus = {
    // TRADING
    AchievementCondition.totalTrades: RewardType.commissionCut,
    AchievementCondition.tradesInOneDay: RewardType.commissionCut,
    AchievementCondition.consecutiveProfits: RewardType.insurance,
    AchievementCondition.profitableTrades: RewardType.stockBonus,
    // PROFIT
    AchievementCondition.totalProfit: RewardType.startingCash,
    AchievementCondition.dailyProfit: RewardType.startingCash,
    AchievementCondition.singleTradeProfit: RewardType.startingCash,
    // PORTFOLIO
    AchievementCondition.portfolioValue: RewardType.interestRate,
    AchievementCondition.cashOnHand: RewardType.interestRate,
    AchievementCondition.holdDuration: RewardType.stockBonus,
    AchievementCondition.sectorsInvested: RewardType.startingCash,
    // MILESTONE
    AchievementCondition.daysPlayed: RewardType.quotaReduction,
    AchievementCondition.yearsCompleted: RewardType.quotaReduction,
    AchievementCondition.quotasMet: RewardType.quotaReduction,
    AchievementCondition.prestigeCount: RewardType.startingCash,
    // RISK
    AchievementCondition.shortPosition: RewardType.insurance,
    AchievementCondition.allInTrade: RewardType.insurance,
    AchievementCondition.recoverFromLoss: RewardType.startingCash,
    AchievementCondition.totalLoss: RewardType.insurance,
    // MARKET
    AchievementCondition.informantTipsBought: RewardType.informantBonus,
    AchievementCondition.fintokTipsFollowed: RewardType.fintokAccuracy,
    AchievementCondition.challengesCompleted: RewardType.extraReroll,
    AchievementCondition.tokensPlaced: RewardType.stockBonus,
    // SECRET
    AchievementCondition.perfectTrade: RewardType.upgradeLuck,
    AchievementCondition.contrarian: RewardType.upgradeLuck,
    AchievementCondition.dipBuys: RewardType.startingCash,
    AchievementCondition.sellHighs: RewardType.startingCash,
    AchievementCondition.noTradeDay: RewardType.quotaReduction,
    AchievementCondition.maxPositionsFilled: RewardType.stockBonus,
    AchievementCondition.upgradesOwned: RewardType.upgradeLuck,
  };

  /// Bonus scaling for Gold+ tiers (6 values: G1, G2, P1, P2, D1, D2)
  static const Map<RewardType, List<double>> _bonusScaling = {
    RewardType.commissionCut: [0.0005, 0.001, 0.0015, 0.0025, 0.004, 0.006],
    RewardType.stockBonus:    [0.0003, 0.0005, 0.0008, 0.0012, 0.002, 0.003],
    RewardType.startingCash:  [50, 100, 250, 500, 1000, 2500],
    RewardType.quotaReduction:[0.002, 0.003, 0.005, 0.008, 0.012, 0.015],
    RewardType.informantBonus:[0.01, 0.02, 0.03, 0.05, 0.08, 0.12],
    RewardType.fintokAccuracy:[0.01, 0.02, 0.03, 0.05, 0.08, 0.12],
    RewardType.upgradeLuck:   [0.002, 0.003, 0.005, 0.008, 0.012, 0.02],
    RewardType.insurance:     [0.002, 0.003, 0.005, 0.008, 0.015, 0.02],
    RewardType.interestRate:  [0.00005, 0.0001, 0.0002, 0.0003, 0.0005, 0.0008],
    RewardType.extraReroll:   [1, 1, 1, 1, 2, 2],
  };

  /// Compute the position (0-based) of an achievement within its condition chain,
  /// sorted by ascending targetValue.
  static int _positionInChain(AchievementDefinition def) {
    final chain = all
        .where((a) => a.condition == def.condition)
        .toList()
      ..sort((a, b) => a.targetValue.compareTo(b.targetValue));
    final idx = chain.indexWhere((a) => a.id == def.id);
    return idx >= 0 ? idx : 0;
  }

  /// Compute rewards for an achievement (PP always + meta bonus at Gold+).
  static List<AchievementReward> computeRewards(AchievementDefinition def) {
    final position = _positionInChain(def);
    final rewards = <AchievementReward>[];

    // PP reward (all tiers)
    final ppIndex = position.clamp(0, _ppByPosition.length - 1);
    rewards.add(AchievementReward(
      type: RewardType.prestigePoints,
      value: _ppByPosition[ppIndex].toDouble(),
    ));

    // Meta bonus (Gold+ only, i.e. position >= 4 in a 10-chain)
    if (position >= 4) {
      final bonusType = _conditionBonus[def.condition];
      final scaling = bonusType != null ? _bonusScaling[bonusType] : null;
      if (bonusType != null && scaling != null) {
        final bonusIdx = (position - 4).clamp(0, scaling.length - 1);
        rewards.add(AchievementReward(
          type: bonusType,
          value: scaling[bonusIdx],
        ));
      }
    }

    return rewards;
  }
}

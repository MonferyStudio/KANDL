import 'package:flutter/foundation.dart';

import '../models/achievement.dart';
import '../models/meta_progression.dart';

/// Service for tracking and managing achievements
class AchievementService extends ChangeNotifier {
  final Map<String, AchievementProgress> _progress = {};

  // Meta progression (persists across runs)
  MetaProgression _metaProgression = MetaProgression();

  // === PERSISTENT COUNTERS (saved across sessions) ===

  // Trading counters
  int _totalTrades = 0;
  int _profitableTrades = 0;
  int _consecutiveProfits = 0;
  int _maxConsecutiveProfits = 0;
  int _maxTradesInOneDay = 0;

  // Profit counters
  double _totalProfit = 0;
  double _maxDailyProfit = 0;
  double _maxSingleTradeProfit = 0;

  // Loss counters
  double _totalLoss = 0;

  // Portfolio counters
  int _maxHoldDuration = 0;
  int _maxPositionsFilled = 0; // cumulative count of times max positions held
  int _maxUpgradesOwned = 0;
  double _maxCashOnHand = 0;

  // Milestone counters
  int _daysPlayed = 0;
  int _yearsCompleted = 0;
  int _quotasMet = 0;
  int _prestigeCount = 0;

  // Risk counters
  int _shortPositions = 0;
  int _allInTrades = 0;
  int _perfectTrades = 0;
  int _contrarianProfits = 0;
  int _maxRecoveryPercent = 0; // 0-100, max % loss recovered from

  // Market counters
  int _informantTipsBought = 0;
  int _fintokTipsFollowed = 0;
  int _challengesCompleted = 0;
  int _tokensPlaced = 0;

  // Secret counters
  int _totalDipBuys = 0;
  int _totalSellHighs = 0;
  int _noTradeDays = 0;

  // Session tracking (not persisted, reset each session)
  double _sessionStartValue = 0;
  double _sessionLowestValue = double.infinity;

  // Callbacks for notifications
  void Function(String name, String icon, String reward)? onAchievementUnlocked;
  void Function(int points)? onPrestigePointsEarned;

  // === GETTERS ===

  MetaProgression get metaProgression => _metaProgression;

  List<AchievementProgress> get allProgress => _progress.values.toList();

  int get completedCount => _progress.values.where((p) => p.isCompleted).length;

  int get totalCount => Achievements.all.length;

  double get completionPercent =>
      totalCount > 0 ? (completedCount / totalCount) * 100 : 0;

  int get unclaimedRewardsCount =>
      _progress.values.where((p) => p.isCompleted && !p.rewardClaimed).length;

  bool get hasUnclaimedRewards => unclaimedRewardsCount > 0;

  /// Initialize progress tracking for all achievements
  void initialize() {
    for (final achievement in Achievements.all) {
      if (!_progress.containsKey(achievement.id)) {
        _progress[achievement.id] = AchievementProgress(
          achievementId: achievement.id,
        );
      }
    }
  }

  /// Get progress for a specific achievement
  AchievementProgress? getProgress(String achievementId) {
    return _progress[achievementId];
  }

  /// Check if an achievement is completed
  bool isCompleted(String achievementId) {
    return _progress[achievementId]?.isCompleted ?? false;
  }

  /// Get visible achievements with progress
  List<(AchievementDefinition, AchievementProgress)> getVisibleAchievements() {
    final result = <(AchievementDefinition, AchievementProgress)>[];

    for (final achievement in Achievements.all) {
      final progress = _progress[achievement.id];
      if (progress == null) continue;

      // Show if not secret, or if secret and completed
      if (!achievement.isSecret || progress.isCompleted) {
        result.add((achievement, progress));
      }
    }

    return result;
  }

  /// Get achievements by category with progress
  List<(AchievementDefinition, AchievementProgress)> getByCategory(
      AchievementCategory category) {
    return getVisibleAchievements()
        .where((item) => item.$1.category == category)
        .toList();
  }

  /// Get recently completed achievements (last 5)
  List<(AchievementDefinition, AchievementProgress)> getRecentlyCompleted() {
    final completed = getVisibleAchievements()
        .where((item) => item.$2.isCompleted && item.$2.completedAt != null)
        .toList();

    completed.sort((a, b) => b.$2.completedAt!.compareTo(a.$2.completedAt!));

    return completed.take(5).toList();
  }

  // ================================================================
  // CORE CHECK LOGIC — condition-based, auto-covers all achievements
  // ================================================================

  /// Check all achievements matching a condition against a value.
  /// Automatically handles any number of achievements per condition.
  void _checkByCondition(AchievementCondition condition, double value) {
    for (final achievement in Achievements.getByCondition(condition)) {
      _updateAchievement(achievement.id, value);
    }
  }

  void _updateAchievement(String id, double value) {
    final achievement = Achievements.getById(id);
    if (achievement == null) return;

    final progress = _progress[id];
    if (progress == null || progress.isCompleted) return;

    final wasCompleted = progress.isCompleted;
    progress.updateProgress(value, achievement.targetValue);

    if (!wasCompleted && progress.isCompleted) {
      _onAchievementCompleted(achievement);
    }

    notifyListeners();
  }

  void _onAchievementCompleted(AchievementDefinition achievement) {
    final rewards = Achievements.computeRewards(achievement);
    final rewardDesc = rewards.isNotEmpty
        ? rewards.map((r) => r.description).join(' + ')
        : 'Achievement unlocked!';

    onAchievementUnlocked?.call(
      achievement.name,
      achievement.icon,
      rewardDesc,
    );
  }

  // ================================================================
  // TRACKING METHODS (called by GameService via callbacks)
  // ================================================================

  /// Record a trade execution
  void recordTrade({required bool profitable, required double profit}) {
    _totalTrades++;

    if (profitable) {
      _profitableTrades++;
      _consecutiveProfits++;
      _totalProfit += profit;

      if (profit > _maxSingleTradeProfit) {
        _maxSingleTradeProfit = profit;
      }
      if (_consecutiveProfits > _maxConsecutiveProfits) {
        _maxConsecutiveProfits = _consecutiveProfits;
      }
    } else {
      _consecutiveProfits = 0;
      _totalLoss += profit; // profit = absolute loss amount
    }

    _checkByCondition(AchievementCondition.totalTrades, _totalTrades.toDouble());
    _checkByCondition(AchievementCondition.profitableTrades, _profitableTrades.toDouble());
    _checkByCondition(AchievementCondition.consecutiveProfits, _maxConsecutiveProfits.toDouble());
    _checkByCondition(AchievementCondition.totalProfit, _totalProfit);
    _checkByCondition(AchievementCondition.singleTradeProfit, _maxSingleTradeProfit);
    _checkByCondition(AchievementCondition.totalLoss, _totalLoss);
  }

  /// Record daily stats at end of day
  void recordDayEnd({
    required double dailyProfit,
    required double portfolioValue,
    required int sectorsInvested,
    required int tradesThisDay,
    required double cashOnHand,
    required int upgradesOwned,
  }) {
    _daysPlayed++;

    if (dailyProfit > _maxDailyProfit) {
      _maxDailyProfit = dailyProfit;
    }

    if (tradesThisDay > _maxTradesInOneDay) {
      _maxTradesInOneDay = tradesThisDay;
    }

    if (tradesThisDay == 0) {
      _noTradeDays++;
    }

    if (cashOnHand > _maxCashOnHand) {
      _maxCashOnHand = cashOnHand;
    }

    if (upgradesOwned > _maxUpgradesOwned) {
      _maxUpgradesOwned = upgradesOwned;
    }

    _checkByCondition(AchievementCondition.daysPlayed, _daysPlayed.toDouble());
    _checkByCondition(AchievementCondition.dailyProfit, _maxDailyProfit);
    _checkByCondition(AchievementCondition.tradesInOneDay, _maxTradesInOneDay.toDouble());
    _checkByCondition(AchievementCondition.noTradeDay, _noTradeDays.toDouble());
    _checkByCondition(AchievementCondition.cashOnHand, _maxCashOnHand);
    _checkByCondition(AchievementCondition.upgradesOwned, _maxUpgradesOwned.toDouble());
    _checkByCondition(AchievementCondition.portfolioValue, portfolioValue);
    _checkByCondition(AchievementCondition.sectorsInvested, sectorsInvested.toDouble());
  }

  /// Record year completion
  void recordYearEnd() {
    _yearsCompleted++;
    _checkByCondition(AchievementCondition.yearsCompleted, _yearsCompleted.toDouble());
  }

  /// Record quota met
  void recordQuotaMet() {
    _quotasMet++;
    _checkByCondition(AchievementCondition.quotasMet, _quotasMet.toDouble());
  }

  /// Record prestige
  void recordPrestige() {
    _prestigeCount++;
    _checkByCondition(AchievementCondition.prestigeCount, _prestigeCount.toDouble());
  }

  /// Record short position opened
  void recordShortPosition() {
    _shortPositions++;
    _checkByCondition(AchievementCondition.shortPosition, _shortPositions.toDouble());
  }

  /// Record all-in trade (90%+ of cash)
  void recordAllInTrade() {
    _allInTrades++;
    _checkByCondition(AchievementCondition.allInTrade, _allInTrades.toDouble());
  }

  /// Record perfect trade (buy at low, sell at high)
  void recordPerfectTrade() {
    _perfectTrades++;
    _checkByCondition(AchievementCondition.perfectTrade, _perfectTrades.toDouble());
  }

  /// Record contrarian profit (from news contradiction)
  void recordContrarianProfit() {
    _contrarianProfits++;
    _checkByCondition(AchievementCondition.contrarian, _contrarianProfits.toDouble());
  }

  /// Record position hold duration
  void recordHoldDuration(int days) {
    if (days > _maxHoldDuration) {
      _maxHoldDuration = days;
      _checkByCondition(AchievementCondition.holdDuration, _maxHoldDuration.toDouble());
    }
  }

  /// Record informant tip purchased
  void recordInformantTip() {
    _informantTipsBought++;
    _checkByCondition(AchievementCondition.informantTipsBought, _informantTipsBought.toDouble());
  }

  /// Record FinTok tip followed
  void recordFintokTip() {
    _fintokTipsFollowed++;
    _checkByCondition(AchievementCondition.fintokTipsFollowed, _fintokTipsFollowed.toDouble());
  }

  /// Record daily challenge completed
  void recordChallengeCompleted() {
    _challengesCompleted++;
    _checkByCondition(AchievementCondition.challengesCompleted, _challengesCompleted.toDouble());
  }

  /// Record token placed on a company
  void recordTokenPlaced() {
    _tokensPlaced++;
    _checkByCondition(AchievementCondition.tokensPlaced, _tokensPlaced.toDouble());
  }

  /// Record buying a stock at a dip (significant drop)
  void recordDipBuy() {
    _totalDipBuys++;
    _checkByCondition(AchievementCondition.dipBuys, _totalDipBuys.toDouble());
  }

  /// Record selling a stock at its high
  void recordSellHigh() {
    _totalSellHighs++;
    _checkByCondition(AchievementCondition.sellHighs, _totalSellHighs.toDouble());
  }

  /// Record holding max positions at once (cumulative counter)
  void recordMaxPositions() {
    _maxPositionsFilled++;
    _checkByCondition(AchievementCondition.maxPositionsFilled, _maxPositionsFilled.toDouble());
  }

  /// Track portfolio value for recovery achievement chain
  void trackPortfolioValue(double currentValue) {
    if (_sessionStartValue == 0) {
      _sessionStartValue = currentValue;
      _sessionLowestValue = currentValue;
      return;
    }

    if (currentValue < _sessionLowestValue) {
      _sessionLowestValue = currentValue;
    }

    // Calculate recovery percentage if we had a loss
    if (_sessionLowestValue < _sessionStartValue) {
      final lossPercent = (1 - _sessionLowestValue / _sessionStartValue) * 100;
      final recoveryRatio = currentValue / _sessionStartValue;

      // If we've recovered back to starting value after a dip
      if (recoveryRatio >= 1.0 && lossPercent > _maxRecoveryPercent) {
        _maxRecoveryPercent = lossPercent.round().clamp(0, 100);
        _checkByCondition(AchievementCondition.recoverFromLoss, _maxRecoveryPercent.toDouble());
      }
    }
  }

  // ================================================================
  // REWARD CLAIMING (kept for future reward system)
  // ================================================================

  /// Claim rewards for a completed achievement
  List<AchievementReward> claimRewards(String achievementId) {
    final progress = _progress[achievementId];
    if (progress == null || !progress.isCompleted || progress.rewardClaimed) {
      return [];
    }

    final achievement = Achievements.getById(achievementId);
    if (achievement == null) return [];

    progress.rewardClaimed = true;

    final rewards = Achievements.computeRewards(achievement);
    _applyMetaRewards(rewards, achievementId);

    notifyListeners();

    return rewards;
  }

  /// Claim all unclaimed rewards
  List<AchievementReward> claimAllRewards() {
    final allRewards = <AchievementReward>[];

    for (final progress in _progress.values) {
      if (progress.isCompleted && !progress.rewardClaimed) {
        final achievement = Achievements.getById(progress.achievementId);
        if (achievement != null) {
          final rewards = Achievements.computeRewards(achievement);
          allRewards.addAll(rewards);
          progress.rewardClaimed = true;
          _applyMetaRewards(rewards, achievement.id);
        }
      }
    }

    notifyListeners();
    return allRewards;
  }

  /// Apply meta progression rewards from achievement
  void _applyMetaRewards(List<AchievementReward> rewards, String sourceId) {
    if (_metaProgression.hasBonusFromSource(sourceId)) return;

    for (final reward in rewards) {
      // Prestige points are applied instantly via callback (not stored in meta)
      if (reward.type == RewardType.prestigePoints) {
        onPrestigePointsEarned?.call(reward.value.toInt());
        continue;
      }

      MetaBonusType? bonusType;

      switch (reward.type) {
        case RewardType.startingCash:
          bonusType = MetaBonusType.startingCash;
          break;
        case RewardType.stockBonus:
          bonusType = MetaBonusType.stockBonus;
          break;
        case RewardType.commissionCut:
          bonusType = MetaBonusType.commissionCut;
          break;
        case RewardType.quotaReduction:
          bonusType = MetaBonusType.quotaReduction;
          break;
        case RewardType.informantBonus:
          bonusType = MetaBonusType.informantVisitBonus;
          break;
        case RewardType.fintokAccuracy:
          bonusType = MetaBonusType.fintokAccuracyBonus;
          break;
        case RewardType.luckyShares:
          bonusType = MetaBonusType.luckyStartingShares;
          break;
        case RewardType.vipStatus:
          bonusType = MetaBonusType.vipStatus;
          break;
        case RewardType.upgradeLuck:
          bonusType = MetaBonusType.upgradeLuck;
          break;
        case RewardType.insurance:
          bonusType = MetaBonusType.insurance;
          break;
        case RewardType.interestRate:
          bonusType = MetaBonusType.interestRate;
          break;
        case RewardType.extraReroll:
          bonusType = MetaBonusType.extraReroll;
          break;
        default:
          continue;
      }

      _metaProgression.addBonus(MetaBonus(
        type: bonusType,
        value: reward.value,
        sourceId: sourceId,
      ));
    }
  }

  // Meta progression getters
  double get startingCashBonus => _metaProgression.startingCashBonus;
  double get stockBonusRate => _metaProgression.stockBonusRate;
  double get commissionReduction => _metaProgression.commissionReduction;
  double get quotaReduction => _metaProgression.quotaReduction;
  double get informantVisitBonus => _metaProgression.informantVisitBonus;
  double get fintokAccuracyBonus => _metaProgression.fintokAccuracyBonus;
  int get luckyStartingShares => _metaProgression.luckyStartingShares;
  bool get hasVipStatus => _metaProgression.hasVipStatus;
  double get upgradeLuck => _metaProgression.upgradeLuck;
  double get insuranceRate => _metaProgression.insurance;
  double get interestRate => _metaProgression.interestRate;
  int get extraRerolls => _metaProgression.extraRerolls;

  /// Reset session tracking (for new game)
  void resetSession() {
    _sessionStartValue = 0;
    _sessionLowestValue = double.infinity;
  }

  // ================================================================
  // JSON SERIALIZATION
  // ================================================================

  Map<String, dynamic> toJson() => {
        'progress': _progress.map((k, v) => MapEntry(k, v.toJson())),
        'metaProgression': _metaProgression.toJson(),
        // Trading
        'totalTrades': _totalTrades,
        'profitableTrades': _profitableTrades,
        'maxConsecutiveProfits': _maxConsecutiveProfits,
        'maxTradesInOneDay': _maxTradesInOneDay,
        // Profit
        'totalProfit': _totalProfit,
        'maxDailyProfit': _maxDailyProfit,
        'maxSingleTradeProfit': _maxSingleTradeProfit,
        // Loss
        'totalLoss': _totalLoss,
        // Portfolio
        'maxHoldDuration': _maxHoldDuration,
        'maxPositionsFilled': _maxPositionsFilled,
        'maxUpgradesOwned': _maxUpgradesOwned,
        'maxCashOnHand': _maxCashOnHand,
        // Milestone
        'daysPlayed': _daysPlayed,
        'yearsCompleted': _yearsCompleted,
        'quotasMet': _quotasMet,
        'prestigeCount': _prestigeCount,
        // Risk
        'shortPositions': _shortPositions,
        'allInTrades': _allInTrades,
        'perfectTrades': _perfectTrades,
        'contrarianProfits': _contrarianProfits,
        'maxRecoveryPercent': _maxRecoveryPercent,
        // Market
        'informantTipsBought': _informantTipsBought,
        'fintokTipsFollowed': _fintokTipsFollowed,
        'challengesCompleted': _challengesCompleted,
        'tokensPlaced': _tokensPlaced,
        // Secret
        'totalDipBuys': _totalDipBuys,
        'totalSellHighs': _totalSellHighs,
        'noTradeDays': _noTradeDays,
      };

  void loadFromJson(Map<String, dynamic> json) {
    _progress.clear();

    if (json['progress'] != null) {
      final progressMap = json['progress'] as Map<String, dynamic>;
      for (final entry in progressMap.entries) {
        _progress[entry.key] =
            AchievementProgress.fromJson(entry.value as Map<String, dynamic>);
      }
    }

    if (json['metaProgression'] != null) {
      _metaProgression = MetaProgression.fromJson(
          json['metaProgression'] as Map<String, dynamic>);
    } else {
      _metaProgression = MetaProgression();
    }

    // Initialize any missing achievements (new ones added since last save)
    initialize();

    // Trading
    _totalTrades = json['totalTrades'] ?? 0;
    _profitableTrades = json['profitableTrades'] ?? 0;
    _maxConsecutiveProfits = json['maxConsecutiveProfits'] ?? 0;
    _maxTradesInOneDay = json['maxTradesInOneDay'] ?? 0;

    // Profit
    _totalProfit = (json['totalProfit'] ?? 0).toDouble();
    _maxDailyProfit = (json['maxDailyProfit'] ?? 0).toDouble();
    _maxSingleTradeProfit = (json['maxSingleTradeProfit'] ?? 0).toDouble();

    // Loss
    _totalLoss = (json['totalLoss'] ?? 0).toDouble();

    // Portfolio
    _maxHoldDuration = json['maxHoldDuration'] ?? 0;
    _maxPositionsFilled = json['maxPositionsFilled'] ?? 0;
    _maxUpgradesOwned = json['maxUpgradesOwned'] ?? 0;
    _maxCashOnHand = (json['maxCashOnHand'] ?? 0).toDouble();

    // Milestone
    _daysPlayed = json['daysPlayed'] ?? 0;
    _yearsCompleted = json['yearsCompleted'] ?? 0;
    _quotasMet = json['quotasMet'] ?? 0;
    _prestigeCount = json['prestigeCount'] ?? 0;

    // Risk
    _shortPositions = json['shortPositions'] ?? 0;
    _allInTrades = json['allInTrades'] ?? 0;
    _perfectTrades = json['perfectTrades'] ?? 0;
    _contrarianProfits = json['contrarianProfits'] ?? 0;
    // Backward-compatible: old saves had bool hasRecoveredFrom50Loss
    final recoveryValue = json['maxRecoveryPercent'];
    if (recoveryValue is int) {
      _maxRecoveryPercent = recoveryValue;
    } else if (json['hasRecoveredFrom50Loss'] == true) {
      _maxRecoveryPercent = 50; // migrate old bool to percentage
    } else {
      _maxRecoveryPercent = 0;
    }

    // Market
    _informantTipsBought = json['informantTipsBought'] ?? 0;
    _fintokTipsFollowed = json['fintokTipsFollowed'] ?? 0;
    _challengesCompleted = json['challengesCompleted'] ?? 0;
    _tokensPlaced = json['tokensPlaced'] ?? 0;

    // Secret
    _totalDipBuys = json['totalDipBuys'] ?? 0;
    _totalSellHighs = json['totalSellHighs'] ?? 0;
    _noTradeDays = json['noTradeDays'] ?? 0;

    // Reset session counter (not persisted)
    _consecutiveProfits = 0;

    notifyListeners();
  }

  /// Reset all progress (for testing)
  void resetAll() {
    _progress.clear();

    _totalTrades = 0;
    _profitableTrades = 0;
    _consecutiveProfits = 0;
    _maxConsecutiveProfits = 0;
    _maxTradesInOneDay = 0;

    _totalProfit = 0;
    _maxDailyProfit = 0;
    _maxSingleTradeProfit = 0;

    _totalLoss = 0;

    _maxHoldDuration = 0;
    _maxPositionsFilled = 0;
    _maxUpgradesOwned = 0;
    _maxCashOnHand = 0;

    _daysPlayed = 0;
    _yearsCompleted = 0;
    _quotasMet = 0;
    _prestigeCount = 0;

    _shortPositions = 0;
    _allInTrades = 0;
    _perfectTrades = 0;
    _contrarianProfits = 0;
    _maxRecoveryPercent = 0;

    _informantTipsBought = 0;
    _fintokTipsFollowed = 0;
    _challengesCompleted = 0;
    _tokensPlaced = 0;

    _totalDipBuys = 0;
    _totalSellHighs = 0;
    _noTradeDays = 0;

    _sessionStartValue = 0;
    _sessionLowestValue = double.infinity;

    initialize();
    notifyListeners();
  }
}

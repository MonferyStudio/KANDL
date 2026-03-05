/// Type of daily challenge
enum ChallengeType {
  makeTrades,         // Complete X trades
  profitAmount,       // Make $X in profit
  tradeSector,        // Trade in a specific sector
  buyDip,             // Buy a stock that dropped 5%+
  sellHigh,           // Sell a stock that gained 10%+
  diversify,          // Hold positions in X different sectors
  dayTrader,          // Complete all trades in a single day
  perfectTiming,      // Buy at day low or sell at day high
  contrarianPlay,     // Profit from a bearish news stock
  holdAndProfit,      // Hold a position for X days and profit
  noLosses,           // End day with no losing trades
  volumeTrader,       // Trade total value of $X
}

/// Difficulty of a challenge
enum ChallengeDifficulty {
  easy,     // Green - small rewards
  medium,   // Yellow - medium rewards
  hard,     // Orange - good rewards
  extreme,  // Red - great rewards
}

/// A single daily challenge
class DailyChallenge {
  final String id;
  final ChallengeType type;
  final String title;
  final String description;
  final ChallengeDifficulty difficulty;
  final int targetValue;     // What the player needs to achieve
  final double cashReward;   // Minimum cash reward (floor)
  final double rewardPercent; // % of net worth as reward (0.005 = 0.5%)
  final String? bonusReward; // Description of any bonus reward

  int currentProgress;
  bool isCompleted;
  bool rewardClaimed;
  final int dayCreated;

  DailyChallenge({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.targetValue,
    required this.cashReward,
    this.rewardPercent = 0.0,
    this.bonusReward,
    this.currentProgress = 0,
    this.isCompleted = false,
    this.rewardClaimed = false,
    required this.dayCreated,
  });

  double get progressPercent =>
      targetValue > 0 ? (currentProgress / targetValue).clamp(0.0, 1.0) : 0.0;

  String get progressText => '$currentProgress / $targetValue';

  String get difficultyLabel {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'Easy';
      case ChallengeDifficulty.medium:
        return 'Medium';
      case ChallengeDifficulty.hard:
        return 'Hard';
      case ChallengeDifficulty.extreme:
        return 'Extreme';
    }
  }

  String get difficultyEmoji {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return '🟢';
      case ChallengeDifficulty.medium:
        return '🟡';
      case ChallengeDifficulty.hard:
        return '🟠';
      case ChallengeDifficulty.extreme:
        return '🔴';
    }
  }

  /// Update progress and check completion
  void updateProgress(int value) {
    if (isCompleted) return;
    currentProgress = value;
    if (currentProgress >= targetValue) {
      currentProgress = targetValue;
      isCompleted = true;
    }
  }

  /// Increment progress by amount
  void incrementProgress(int amount) {
    updateProgress(currentProgress + amount);
  }

  /// Compute actual reward based on net worth
  double computeReward(double netWorth) {
    if (rewardPercent <= 0) return cashReward;
    return netWorth * rewardPercent;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'title': title,
    'description': description,
    'difficulty': difficulty.index,
    'targetValue': targetValue,
    'cashReward': cashReward,
    'rewardPercent': rewardPercent,
    'bonusReward': bonusReward,
    'currentProgress': currentProgress,
    'isCompleted': isCompleted,
    'rewardClaimed': rewardClaimed,
    'dayCreated': dayCreated,
  };

  factory DailyChallenge.fromJson(Map<String, dynamic> json) => DailyChallenge(
    id: json['id'],
    type: ChallengeType.values[json['type']],
    title: json['title'],
    description: json['description'],
    difficulty: ChallengeDifficulty.values[json['difficulty']],
    targetValue: json['targetValue'],
    cashReward: (json['cashReward'] as num).toDouble(),
    rewardPercent: (json['rewardPercent'] as num?)?.toDouble() ?? 0.0,
    bonusReward: json['bonusReward'],
    currentProgress: json['currentProgress'] ?? 0,
    isCompleted: json['isCompleted'] ?? false,
    rewardClaimed: json['rewardClaimed'] ?? false,
    dayCreated: json['dayCreated'],
  );
}

/// State of daily challenges
class DailyChallengeState {
  List<DailyChallenge> activeChallenges;
  int lastRefreshDay;
  int totalChallengesCompleted;
  int consecutiveDaysCompleted; // Days in a row with all challenges done

  DailyChallengeState({
    List<DailyChallenge>? activeChallenges,
    this.lastRefreshDay = 0,
    this.totalChallengesCompleted = 0,
    this.consecutiveDaysCompleted = 0,
  }) : activeChallenges = activeChallenges ?? [];

  int get completedToday => activeChallenges.where((c) => c.isCompleted).length;
  int get totalToday => activeChallenges.length;
  bool get allCompletedToday => completedToday == totalToday && totalToday > 0;
  int get unclaimedRewards => activeChallenges.where((c) => c.isCompleted && !c.rewardClaimed).length;

  Map<String, dynamic> toJson() => {
    'activeChallenges': activeChallenges.map((c) => c.toJson()).toList(),
    'lastRefreshDay': lastRefreshDay,
    'totalChallengesCompleted': totalChallengesCompleted,
    'consecutiveDaysCompleted': consecutiveDaysCompleted,
  };

  factory DailyChallengeState.fromJson(Map<String, dynamic> json) => DailyChallengeState(
    activeChallenges: json['activeChallenges'] != null
        ? (json['activeChallenges'] as List)
            .map((c) => DailyChallenge.fromJson(c as Map<String, dynamic>))
            .toList()
        : [],
    lastRefreshDay: json['lastRefreshDay'] ?? 0,
    totalChallengesCompleted: json['totalChallengesCompleted'] ?? 0,
    consecutiveDaysCompleted: json['consecutiveDaysCompleted'] ?? 0,
  );
}

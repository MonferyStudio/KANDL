import '../core/core.dart';

/// Complete game state for saving/loading
class GameState {
  int currentDay;
  int currentYear;
  double dayTimer;
  BigNumber cash;
  BigNumber currentQuotaTarget;
  BigNumber currentQuotaProgress;
  int failedQuotas;
  double gameSpeed;
  bool isPaused;

  GameState({
    this.currentDay = 1,
    this.currentYear = 1,
    this.dayTimer = 60,
    BigNumber? cash,
    BigNumber? currentQuotaTarget,
    BigNumber? currentQuotaProgress,
    this.failedQuotas = 0,
    this.gameSpeed = 1.0,
    this.isPaused = false,
  })  : cash = cash ?? BigNumber(10000),
        currentQuotaTarget = currentQuotaTarget ?? BigNumber(50000),
        currentQuotaProgress = currentQuotaProgress ?? BigNumber.zero;

  Map<String, dynamic> toJson() => {
        'currentDay': currentDay,
        'currentYear': currentYear,
        'dayTimer': dayTimer,
        'cash': cash.toJson(),
        'currentQuotaTarget': currentQuotaTarget.toJson(),
        'currentQuotaProgress': currentQuotaProgress.toJson(),
        'failedQuotas': failedQuotas,
        'gameSpeed': gameSpeed,
        'isPaused': isPaused,
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      currentDay: json['currentDay'] ?? 1,
      currentYear: json['currentYear'] ?? 1,
      dayTimer: (json['dayTimer'] ?? 60).toDouble(),
      cash: json['cash'] != null
          ? BigNumber.fromJson(json['cash'])
          : BigNumber(10000),
      currentQuotaTarget: json['currentQuotaTarget'] != null
          ? BigNumber.fromJson(json['currentQuotaTarget'])
          : BigNumber(50000),
      currentQuotaProgress: json['currentQuotaProgress'] != null
          ? BigNumber.fromJson(json['currentQuotaProgress'])
          : BigNumber.zero,
      failedQuotas: json['failedQuotas'] ?? 0,
      gameSpeed: (json['gameSpeed'] ?? 1.0).toDouble(),
      isPaused: json['isPaused'] ?? false,
    );
  }
}

/// Prestige/meta progression state
class PrestigeState {
  int prestigeLevel;
  int totalYearsPlayed;
  List<String> unlockedBotIds;
  Map<String, int> upgradeLevels;
  BigNumber lifetimeEarnings;
  BigNumber bestSingleTrade;
  int bestWinStreak;

  PrestigeState({
    this.prestigeLevel = 0,
    this.totalYearsPlayed = 0,
    List<String>? unlockedBotIds,
    Map<String, int>? upgradeLevels,
    BigNumber? lifetimeEarnings,
    BigNumber? bestSingleTrade,
    this.bestWinStreak = 0,
  })  : unlockedBotIds = unlockedBotIds ?? [],
        upgradeLevels = upgradeLevels ?? {},
        lifetimeEarnings = lifetimeEarnings ?? BigNumber.zero,
        bestSingleTrade = bestSingleTrade ?? BigNumber.zero;

  Map<String, dynamic> toJson() => {
        'prestigeLevel': prestigeLevel,
        'totalYearsPlayed': totalYearsPlayed,
        'unlockedBotIds': unlockedBotIds,
        'upgradeLevels': upgradeLevels,
        'lifetimeEarnings': lifetimeEarnings.toJson(),
        'bestSingleTrade': bestSingleTrade.toJson(),
        'bestWinStreak': bestWinStreak,
      };

  factory PrestigeState.fromJson(Map<String, dynamic> json) {
    return PrestigeState(
      prestigeLevel: json['prestigeLevel'] ?? 0,
      totalYearsPlayed: json['totalYearsPlayed'] ?? 0,
      unlockedBotIds: List<String>.from(json['unlockedBotIds'] ?? []),
      upgradeLevels: Map<String, int>.from(json['upgradeLevels'] ?? {}),
      lifetimeEarnings: json['lifetimeEarnings'] != null
          ? BigNumber.fromJson(json['lifetimeEarnings'])
          : BigNumber.zero,
      bestSingleTrade: json['bestSingleTrade'] != null
          ? BigNumber.fromJson(json['bestSingleTrade'])
          : BigNumber.zero,
      bestWinStreak: json['bestWinStreak'] ?? 0,
    );
  }
}

/// Complete save data
class SaveData {
  final String version;
  final DateTime savedAt;
  final GameState gameState;
  final PrestigeState prestigeState;
  final List<Map<String, dynamic>> positions;
  final List<Map<String, dynamic>> stockPrices;

  SaveData({
    this.version = '1.0',
    DateTime? savedAt,
    GameState? gameState,
    PrestigeState? prestigeState,
    this.positions = const [],
    this.stockPrices = const [],
  })  : savedAt = savedAt ?? DateTime.now(),
        gameState = gameState ?? GameState(),
        prestigeState = prestigeState ?? PrestigeState();

  Map<String, dynamic> toJson() => {
        'version': version,
        'savedAt': savedAt.toIso8601String(),
        'gameState': gameState.toJson(),
        'prestigeState': prestigeState.toJson(),
        'positions': positions,
        'stockPrices': stockPrices,
      };

  factory SaveData.fromJson(Map<String, dynamic> json) {
    return SaveData(
      version: json['version'] ?? '1.0',
      savedAt: json['savedAt'] != null
          ? DateTime.parse(json['savedAt'])
          : DateTime.now(),
      gameState: json['gameState'] != null
          ? GameState.fromJson(json['gameState'])
          : GameState(),
      prestigeState: json['prestigeState'] != null
          ? PrestigeState.fromJson(json['prestigeState'])
          : PrestigeState(),
      positions: List<Map<String, dynamic>>.from(json['positions'] ?? []),
      stockPrices: List<Map<String, dynamic>>.from(json['stockPrices'] ?? []),
    );
  }
}

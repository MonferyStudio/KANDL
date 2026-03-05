import 'dart:math';
import '../models/daily_challenge.dart';

/// Challenge templates grouped by difficulty
class ChallengeTemplates {
  // === EASY CHALLENGES ===
  static final List<Map<String, dynamic>> easy = [
    {
      'type': ChallengeType.makeTrades,
      'title': 'Active Trader',
      'description': 'Complete {target} trades today',
      'target': 3,
      'reward': 25.0,
    },
    {
      'type': ChallengeType.profitAmount,
      'title': 'Small Gains',
      'description': 'Make \${target} in profit',
      'target': 50,
      'reward': 30.0,
    },
    {
      'type': ChallengeType.diversify,
      'title': 'Spread Your Bets',
      'description': 'Hold positions in {target} different sectors',
      'target': 2,
      'reward': 35.0,
    },
    {
      'type': ChallengeType.volumeTrader,
      'title': 'Volume Trader',
      'description': 'Trade a total value of \${target}',
      'target': 500,
      'reward': 25.0,
    },
  ];

  // === MEDIUM CHALLENGES ===
  static final List<Map<String, dynamic>> medium = [
    {
      'type': ChallengeType.makeTrades,
      'title': 'Busy Trader',
      'description': 'Complete {target} trades today',
      'target': 6,
      'reward': 75.0,
    },
    {
      'type': ChallengeType.profitAmount,
      'title': 'Solid Returns',
      'description': 'Make \${target} in profit',
      'target': 150,
      'reward': 100.0,
    },
    {
      'type': ChallengeType.buyDip,
      'title': 'Dip Buyer',
      'description': 'Buy {target} stocks that dropped 5%+',
      'target': 2,
      'reward': 80.0,
    },
    {
      'type': ChallengeType.sellHigh,
      'title': 'Profit Taker',
      'description': 'Sell {target} positions with 10%+ gain',
      'target': 1,
      'reward': 90.0,
    },
    {
      'type': ChallengeType.diversify,
      'title': 'Diversified Portfolio',
      'description': 'Hold positions in {target} different sectors',
      'target': 3,
      'reward': 85.0,
    },
    {
      'type': ChallengeType.volumeTrader,
      'title': 'Big Mover',
      'description': 'Trade a total value of \${target}',
      'target': 2000,
      'reward': 70.0,
    },
  ];

  // === HARD CHALLENGES ===
  static final List<Map<String, dynamic>> hard = [
    {
      'type': ChallengeType.makeTrades,
      'title': 'Trading Frenzy',
      'description': 'Complete {target} trades today',
      'target': 10,
      'reward': 200.0,
    },
    {
      'type': ChallengeType.profitAmount,
      'title': 'Big Profits',
      'description': 'Make \${target} in profit',
      'target': 500,
      'reward': 250.0,
    },
    {
      'type': ChallengeType.noLosses,
      'title': 'Flawless Day',
      'description': 'End the day with no losing trades (min {target} trades)',
      'target': 3,
      'reward': 300.0,
    },
    {
      'type': ChallengeType.buyDip,
      'title': 'Dip Hunter',
      'description': 'Buy {target} stocks that dropped 5%+',
      'target': 4,
      'reward': 180.0,
    },
    {
      'type': ChallengeType.sellHigh,
      'title': 'Peak Seller',
      'description': 'Sell {target} positions with 15%+ gain',
      'target': 2,
      'reward': 220.0,
    },
    {
      'type': ChallengeType.contrarianPlay,
      'title': 'Contrarian',
      'description': 'Profit from {target} stocks with recent negative news',
      'target': 1,
      'reward': 250.0,
      'bonus': '+5% profit bonus on contrarian trades',
    },
  ];

  // === EXTREME CHALLENGES ===
  static final List<Map<String, dynamic>> extreme = [
    {
      'type': ChallengeType.profitAmount,
      'title': 'Whale Gains',
      'description': 'Make \${target} in profit',
      'target': 1000,
      'reward': 500.0,
    },
    {
      'type': ChallengeType.noLosses,
      'title': 'Perfect Record',
      'description': 'End the day with no losing trades (min {target} trades)',
      'target': 5,
      'reward': 600.0,
      'bonus': '+10% starting cash next run',
    },
    {
      'type': ChallengeType.makeTrades,
      'title': 'Market Dominator',
      'description': 'Complete {target} trades today',
      'target': 15,
      'reward': 400.0,
    },
    {
      'type': ChallengeType.diversify,
      'title': 'Master Diversifier',
      'description': 'Hold positions in {target} different sectors',
      'target': 5,
      'reward': 350.0,
      'bonus': 'Unlock bonus diversification reward',
    },
    {
      'type': ChallengeType.volumeTrader,
      'title': 'Volume King',
      'description': 'Trade a total value of \${target}',
      'target': 10000,
      'reward': 450.0,
    },
  ];
}

/// Generate a set of daily challenges for a given day
List<DailyChallenge> generateDailyChallenges(int currentDay, Random random) {
  final challenges = <DailyChallenge>[];

  // Always generate 3 challenges: 1 easy, 1 medium, 1 hard/extreme

  // Easy challenge
  final easyTemplate = ChallengeTemplates.easy[random.nextInt(ChallengeTemplates.easy.length)];
  challenges.add(_createChallenge(easyTemplate, ChallengeDifficulty.easy, currentDay, random));

  // Medium challenge
  final mediumTemplate = ChallengeTemplates.medium[random.nextInt(ChallengeTemplates.medium.length)];
  challenges.add(_createChallenge(mediumTemplate, ChallengeDifficulty.medium, currentDay, random));

  // Hard or Extreme challenge (20% chance for extreme)
  final isExtreme = random.nextDouble() < 0.20;
  final hardTemplates = isExtreme ? ChallengeTemplates.extreme : ChallengeTemplates.hard;
  final hardTemplate = hardTemplates[random.nextInt(hardTemplates.length)];
  challenges.add(_createChallenge(
    hardTemplate,
    isExtreme ? ChallengeDifficulty.extreme : ChallengeDifficulty.hard,
    currentDay,
    random,
  ));

  return challenges;
}

DailyChallenge _createChallenge(
  Map<String, dynamic> template,
  ChallengeDifficulty difficulty,
  int currentDay,
  Random random,
) {
  final type = template['type'] as ChallengeType;
  final baseTarget = template['target'] as int;
  final baseReward = template['reward'] as double;

  // Scale target and reward based on day (progression)
  final dayMultiplier = 1.0 + (currentDay / 30) * 0.3;
  final adjustedTarget = (baseTarget * dayMultiplier).round();
  final adjustedReward = baseReward * dayMultiplier;

  // Reward percent of net worth by difficulty
  final rewardPercent = switch (difficulty) {
    ChallengeDifficulty.easy => 0.005,     // 0.5%
    ChallengeDifficulty.medium => 0.015,   // 1.5%
    ChallengeDifficulty.hard => 0.03,      // 3%
    ChallengeDifficulty.extreme => 0.05,   // 5%
  };

  // Create description with target
  var description = template['description'] as String;
  description = description.replaceAll('{target}', adjustedTarget.toString());

  return DailyChallenge(
    id: 'challenge_${currentDay}_${type.index}_${random.nextInt(10000)}',
    type: type,
    title: template['title'],
    description: description,
    difficulty: difficulty,
    targetValue: adjustedTarget,
    cashReward: adjustedReward,
    rewardPercent: rewardPercent,
    bonusReward: template['bonus'],
    dayCreated: currentDay,
  );
}

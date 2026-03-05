import 'dart:math' as math;
import '../core/core.dart';

/// Represents a purchasable upgrade
class UpgradeData {
  final String id;
  final String name;
  final String icon;
  final String description;
  final UpgradeCategory category;
  final double baseCost;
  final double costMultiplier;
  final int maxLevel;
  final double effectPerLevel;
  final String effectDescription;
  final int requiredPrestigeLevel;
  final String? prerequisiteUpgradeId;
  final int prerequisiteLevel;
  final bool persistsThroughPrestige;

  const UpgradeData({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.category,
    required this.baseCost,
    this.costMultiplier = 1.5,
    this.maxLevel = 10,
    this.effectPerLevel = 0.1,
    this.effectDescription = '',
    this.requiredPrestigeLevel = 0,
    this.prerequisiteUpgradeId,
    this.prerequisiteLevel = 0,
    this.persistsThroughPrestige = false,
  });

  BigNumber getCostForLevel(int level) {
    if (level <= 0) return BigNumber(baseCost);
    return BigNumber(baseCost * math.pow(costMultiplier, level));
  }

  double getEffectAtLevel(int level) {
    return effectPerLevel * level;
  }

  String getEffectDescriptionAtLevel(int level) {
    double effect = getEffectAtLevel(level);

    switch (category) {
      case UpgradeCategory.trading:
        return '-${(effect * 100).toStringAsFixed(0)}% trading fees';
      case UpgradeCategory.information:
        return '+${(effect * 100).toStringAsFixed(0)}% market insight';
      case UpgradeCategory.portfolio:
        return '+${level * 5} max positions';
      case UpgradeCategory.unlock:
        return 'Unlock $level new companies';
      case UpgradeCategory.risk:
        return '-${(effect * 100).toStringAsFixed(0)}% max loss';
      case UpgradeCategory.income:
        return '+\$${(effect * 100).toStringAsFixed(0)} passive income';
      case UpgradeCategory.time:
        return '+${(effect * 10).toStringAsFixed(0)}s per day';
      case UpgradeCategory.quota:
        return '-${(effect * 100).toStringAsFixed(0)}% quota requirement';
    }
  }

  bool canPurchase({
    required int currentLevel,
    required BigNumber currentCash,
    required int prestigeLevel,
    required int Function(String) getUpgradeLevel,
  }) {
    if (currentLevel >= maxLevel) return false;
    if (prestigeLevel < requiredPrestigeLevel) return false;
    if (prerequisiteUpgradeId != null &&
        getUpgradeLevel(prerequisiteUpgradeId!) < prerequisiteLevel) {
      return false;
    }
    if (currentCash < getCostForLevel(currentLevel)) return false;

    return true;
  }
}

import 'dart:math';
import '../core/core.dart';
import '../models/upgrade.dart';

/// All available static upgrades in the game
const List<Upgrade> allStaticUpgrades = [
  // ============================================
  // TRADING UPGRADES (strategy, bonuses)
  // ============================================

  // Strategy upgrades
  Upgrade(
    id: 'momentum_rider',
    name: 'Momentum Rider',
    description: '+10% profit on your next trade after 3 consecutive wins.',
    icon: '\u{1F525}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.rare,
    effects: {'momentumBonus': 0.10, 'momentumStreak': 3},
  ),
  Upgrade(
    id: 'contrarian',
    name: 'Contrarian',
    description: '+20% profit when buying a stock that dropped >10% today.',
    icon: '\u{1F504}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.rare,
    effects: {'contrarianBonus': 0.20, 'contrarianThreshold': 0.10},
  ),
  Upgrade(
    id: 'day_trader',
    name: 'Day Trader',
    description: '+5% bonus when you buy and sell the same stock in one day.',
    icon: '\u{26A1}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.uncommon,
    effects: {'dayTradeBonus': 0.05},
  ),

  // Analyst precision chain (improves signal accuracy from 50% base)
  Upgrade(
    id: 'analyst_1',
    name: 'Junior Analyst',
    description: 'Trading signals are 60% accurate (base: 50%).',
    icon: '\u{1F4CB}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.common,
    effects: {'analystPrecision': 0.10},
  ),
  Upgrade(
    id: 'analyst_2',
    name: 'Senior Analyst',
    description: 'Trading signals are 75% accurate.',
    icon: '\u{1F4CA}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.rare,
    effects: {'analystPrecision': 0.15},
    prerequisites: ['analyst_1'],
  ),
  Upgrade(
    id: 'analyst_3',
    name: 'Expert Analyst',
    description: 'Trading signals are 90% accurate.',
    icon: '\u{1F9E0}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.epic,
    effects: {'analystPrecision': 0.15},
    prerequisites: ['analyst_2'],
  ),

  // Stock bonus chain (1 -> 2 -> 3 -> max)
  Upgrade(
    id: 'stock_bonus_1',
    name: 'Loyalty Rewards',
    description: 'Receive 2% bonus shares on every purchase.',
    icon: '\u{1F381}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.uncommon,
    effects: {'stockBonusRate': 0.02},
  ),
  Upgrade(
    id: 'stock_bonus_2',
    name: 'Premium Rewards',
    description: 'Receive 5% bonus shares on every purchase.',
    icon: '\u{1F380}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.rare,
    effects: {'stockBonusRate': 0.05},
    prerequisites: ['stock_bonus_1'],
  ),
  Upgrade(
    id: 'stock_bonus_3',
    name: 'VIP Rewards',
    description: 'Receive 8% bonus shares on every purchase.',
    icon: '\u{1F3C6}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.epic,
    effects: {'stockBonusRate': 0.08},
    prerequisites: ['stock_bonus_2'],
  ),
  Upgrade(
    id: 'stock_bonus_max',
    name: 'Whale Rewards',
    description: 'Receive 12% bonus shares on every purchase.',
    icon: '\u{1F40B}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.legendary,
    effects: {'stockBonusRate': 0.12},
    prerequisites: ['stock_bonus_3'],
  ),

  // ============================================
  // INCOME UPGRADES (passive gains)
  // ============================================

  Upgrade(
    id: 'tax_refund',
    name: 'Tax Refund',
    description: 'Recover 10% of your realized losses as cash at end of day.',
    icon: '\u{1F9FE}',
    category: UpgradeCategory.income,
    rarity: UpgradeRarity.uncommon,
    effects: {'lossRecoveryPercent': 0.10},
  ),

  // ============================================
  // TIME UPGRADES (longer days)
  // ============================================

  Upgrade(
    id: 'longer_day_1',
    name: 'Extended Hours',
    description: 'Trading day is 10 seconds longer',
    icon: '\u{23F0}',
    category: UpgradeCategory.time,
    rarity: UpgradeRarity.rare,
    effects: {'extraDaySeconds': 10},
    isRepeatable: true,
  ),
  Upgrade(
    id: 'longer_day_2',
    name: 'Night Trading',
    description: 'Trading day is 20 seconds longer',
    icon: '\u{1F319}',
    category: UpgradeCategory.time,
    rarity: UpgradeRarity.epic,
    effects: {'extraDaySeconds': 20},
  ),
  Upgrade(
    id: 'quantum_trader',
    name: 'Quantum Trader',
    description: 'Trading day is 60 seconds longer',
    icon: '\u{231B}',
    category: UpgradeCategory.time,
    rarity: UpgradeRarity.legendary,
    effects: {'extraDaySeconds': 60},
  ),

  // ============================================
  // QUOTA UPGRADES (easier quotas)
  // ============================================

  Upgrade(
    id: 'quota_reduction_1',
    name: 'Lenient Boss',
    description: 'Quota reduced by 10%',
    icon: '\u{1F60A}',
    category: UpgradeCategory.quota,
    rarity: UpgradeRarity.rare,
    effects: {'quotaReduction': 0.10},
    isRepeatable: true,
  ),
  Upgrade(
    id: 'quota_reduction_2',
    name: 'Easy Mode',
    description: 'Quota reduced by 20%',
    icon: '\u{1F388}',
    category: UpgradeCategory.quota,
    rarity: UpgradeRarity.epic,
    effects: {'quotaReduction': 0.20},
  ),
  Upgrade(
    id: 'extra_day',
    name: 'Deadline Extension',
    description: '+1 day to meet quota',
    icon: '\u{1F4C5}',
    category: UpgradeCategory.quota,
    rarity: UpgradeRarity.legendary,
    effects: {'extraQuotaDays': 1},
  ),

  // ============================================
  // NEWS UPGRADES (more information)
  // ============================================

  Upgrade(
    id: 'morning_edition',
    name: 'Morning Edition',
    description: '+1 extra news at the start of each day',
    icon: '\u{1F4F0}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.uncommon,
    effects: {'extraMorningNews': 1},
  ),
  Upgrade(
    id: 'evening_edition',
    name: 'Evening Edition',
    description: '+1 extra news at mid-day',
    icon: '\u{1F305}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.rare,
    effects: {'extraMidDayNews': 1},
  ),
  Upgrade(
    id: 'news_cycle_24h',
    name: '24h News Cycle',
    description: '+1 news at morning AND mid-day',
    icon: '\u{1F4FA}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.epic,
    effects: {'extraMorningNews': 1, 'extraMidDayNews': 1},
  ),
];

// ============================================
// SECTOR-SPECIFIC UPGRADE TEMPLATES
// Sector is assigned dynamically at generation time
// ============================================

/// Sector Shield templates: reduce losses on a specific sector
/// Values balanced so legendary (30%) + full talent tree sector shields (20%) = 50% max
const List<Upgrade> sectorShieldTemplates = [
  Upgrade(
    id: 'sector_shield_common',
    name: 'Sector Shield',
    description: 'Reduce losses by 3% on {sector} stocks',
    icon: '\u{1F6E1}\u{FE0F}',
    category: UpgradeCategory.risk,
    rarity: UpgradeRarity.common,
    effects: {'sectorLossReduction': 0.03},
    templateType: 'sector_shield',
  ),
  Upgrade(
    id: 'sector_shield_uncommon',
    name: 'Sector Shield',
    description: 'Reduce losses by 7% on {sector} stocks',
    icon: '\u{1F6E1}\u{FE0F}',
    category: UpgradeCategory.risk,
    rarity: UpgradeRarity.uncommon,
    effects: {'sectorLossReduction': 0.07},
    templateType: 'sector_shield',
  ),
  Upgrade(
    id: 'sector_shield_rare',
    name: 'Sector Shield',
    description: 'Reduce losses by 15% on {sector} stocks',
    icon: '\u{1F6E1}\u{FE0F}',
    category: UpgradeCategory.risk,
    rarity: UpgradeRarity.rare,
    effects: {'sectorLossReduction': 0.15},
    templateType: 'sector_shield',
  ),
  Upgrade(
    id: 'sector_shield_epic',
    name: 'Sector Shield',
    description: 'Reduce losses by 22% on {sector} stocks',
    icon: '\u{1F6E1}\u{FE0F}',
    category: UpgradeCategory.risk,
    rarity: UpgradeRarity.epic,
    effects: {'sectorLossReduction': 0.22},
    templateType: 'sector_shield',
  ),
  Upgrade(
    id: 'sector_shield_legendary',
    name: 'Sector Shield',
    description: 'Reduce losses by 30% on {sector} stocks',
    icon: '\u{1F6E1}\u{FE0F}',
    category: UpgradeCategory.risk,
    rarity: UpgradeRarity.legendary,
    effects: {'sectorLossReduction': 0.30},
    templateType: 'sector_shield',
  ),
];

/// Sector Edge templates: boost profits on a specific sector
/// Values balanced so legendary (30%) + full talent tree sector profits (50%) = 80% max
const List<Upgrade> sectorEdgeTemplates = [
  Upgrade(
    id: 'sector_edge_common',
    name: 'Sector Edge',
    description: 'Boost profits by 3% on {sector} stocks',
    icon: '\u{1F4C8}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.common,
    effects: {'sectorProfitBoost': 0.03},
    templateType: 'sector_edge',
  ),
  Upgrade(
    id: 'sector_edge_uncommon',
    name: 'Sector Edge',
    description: 'Boost profits by 7% on {sector} stocks',
    icon: '\u{1F4C8}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.uncommon,
    effects: {'sectorProfitBoost': 0.07},
    templateType: 'sector_edge',
  ),
  Upgrade(
    id: 'sector_edge_rare',
    name: 'Sector Edge',
    description: 'Boost profits by 15% on {sector} stocks',
    icon: '\u{1F4C8}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.rare,
    effects: {'sectorProfitBoost': 0.15},
    templateType: 'sector_edge',
  ),
  Upgrade(
    id: 'sector_edge_epic',
    name: 'Sector Edge',
    description: 'Boost profits by 22% on {sector} stocks',
    icon: '\u{1F4C8}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.epic,
    effects: {'sectorProfitBoost': 0.22},
    templateType: 'sector_edge',
  ),
  Upgrade(
    id: 'sector_edge_legendary',
    name: 'Sector Edge',
    description: 'Boost profits by 30% on {sector} stocks',
    icon: '\u{1F4C8}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.legendary,
    effects: {'sectorProfitBoost': 0.30},
    templateType: 'sector_edge',
  ),
];

/// Situational Income templates: passive income based on portfolio context
const List<Upgrade> incomeTemplates = [
  Upgrade(
    id: 'income_per_stock',
    name: 'Stock Dividend',
    description: 'Earn \$1 per stock held at end of day',
    icon: '\u{1F4B5}',
    category: UpgradeCategory.income,
    rarity: UpgradeRarity.common,
    effects: {'incomePerStock': 1.0},
    templateType: 'income_situational',
  ),
  Upgrade(
    id: 'income_per_sector',
    name: 'Sector Diversification',
    description: 'Earn \$10 per distinct sector in your portfolio',
    icon: '\u{1F310}',
    category: UpgradeCategory.income,
    rarity: UpgradeRarity.uncommon,
    effects: {'incomePerSector': 10.0},
    templateType: 'income_situational',
  ),
  Upgrade(
    id: 'income_per_upgrade',
    name: 'Knowledge Pays',
    description: 'Earn \$5 per upgrade owned at end of day',
    icon: '\u{1F4DA}',
    category: UpgradeCategory.income,
    rarity: UpgradeRarity.rare,
    effects: {'incomePerUpgrade': 5.0},
    templateType: 'income_situational',
  ),
  Upgrade(
    id: 'income_portfolio_percent',
    name: 'Portfolio Interest',
    description: 'Earn 1% of portfolio value as cash daily',
    icon: '\u{1F3E6}',
    category: UpgradeCategory.income,
    rarity: UpgradeRarity.epic,
    effects: {'incomePortfolioPercent': 0.01},
    templateType: 'income_situational',
  ),
  Upgrade(
    id: 'income_combo',
    name: 'Wealth Engine',
    description: 'Earn \$2/stock + \$15/sector + 0.5% portfolio value daily',
    icon: '\u{1F4B0}',
    category: UpgradeCategory.income,
    rarity: UpgradeRarity.legendary,
    effects: {'incomePerStock': 2.0, 'incomePerSector': 15.0, 'incomePortfolioPercent': 0.005},
    templateType: 'income_situational',
  ),
];

/// Sector Insight templates: bias news toward a specific sector
/// Higher rarity = more info about the sector you're specializing in
const List<Upgrade> sectorInsightTemplates = [
  Upgrade(
    id: 'sector_insight_common',
    name: 'Sector Insight',
    description: '+20% chance news targets {sector}',
    icon: '\u{1F4F0}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.common,
    effects: {'sectorNewsBias': 0.20},
    templateType: 'sector_insight',
  ),
  Upgrade(
    id: 'sector_insight_uncommon',
    name: 'Sector Insight',
    description: '+35% chance news targets {sector}',
    icon: '\u{1F4F0}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.uncommon,
    effects: {'sectorNewsBias': 0.35},
    templateType: 'sector_insight',
  ),
  Upgrade(
    id: 'sector_insight_rare',
    name: 'Sector Insight',
    description: '+50% chance news targets {sector}',
    icon: '\u{1F4F0}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.rare,
    effects: {'sectorNewsBias': 0.50},
    templateType: 'sector_insight',
  ),
  Upgrade(
    id: 'sector_insight_epic',
    name: 'Sector Insight',
    description: '+70% chance news targets {sector} + sentiment preview',
    icon: '\u{1F4F0}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.epic,
    effects: {'sectorNewsBias': 0.70, 'sectorNewsPreview': true},
    templateType: 'sector_insight',
  ),
  Upgrade(
    id: 'sector_insight_legendary',
    name: 'Sector Insight',
    description: '1 guaranteed {sector} news/day + sentiment preview',
    icon: '\u{1F4F0}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.legendary,
    effects: {'sectorNewsBias': 1.0, 'sectorNewsPreview': true, 'sectorGuaranteedNews': true},
    templateType: 'sector_insight',
  ),
];

/// Sector Dominance templates: reward for concentrating positions in one sector
/// Bonus per position held in the sector when selling
const List<Upgrade> sectorDominanceTemplates = [
  Upgrade(
    id: 'sector_dominance_common',
    name: 'Sector Dominance',
    description: '+2% profit per {sector} position held',
    icon: '\u{1F451}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.common,
    effects: {'sectorDominanceBonus': 0.02},
    templateType: 'sector_dominance',
  ),
  Upgrade(
    id: 'sector_dominance_uncommon',
    name: 'Sector Dominance',
    description: '+4% profit per {sector} position held',
    icon: '\u{1F451}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.uncommon,
    effects: {'sectorDominanceBonus': 0.04},
    templateType: 'sector_dominance',
  ),
  Upgrade(
    id: 'sector_dominance_rare',
    name: 'Sector Dominance',
    description: '+7% profit per {sector} position held',
    icon: '\u{1F451}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.rare,
    effects: {'sectorDominanceBonus': 0.07},
    templateType: 'sector_dominance',
  ),
  Upgrade(
    id: 'sector_dominance_epic',
    name: 'Sector Dominance',
    description: '+10% profit per {sector} position held',
    icon: '\u{1F451}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.epic,
    effects: {'sectorDominanceBonus': 0.10},
    templateType: 'sector_dominance',
  ),
  Upgrade(
    id: 'sector_dominance_legendary',
    name: 'Sector Dominance',
    description: '+15% profit per {sector} position held + -5% fees',
    icon: '\u{1F451}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.legendary,
    effects: {'sectorDominanceBonus': 0.15, 'sectorDominanceFeeReduction': 0.05},
    templateType: 'sector_dominance',
  ),
];

/// Winning Streak templates: bonus per consecutive profitable trade (higher rarity replaces lower)
const List<Upgrade> winningStreakTemplates = [
  Upgrade(
    id: 'winning_streak_common',
    name: 'Hot Streak',
    description: '+2% profit per consecutive winning trade',
    icon: '\u{1F525}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.common,
    effects: {'winStreakBonus': 0.02},
    templateType: 'winning_streak',
  ),
  Upgrade(
    id: 'winning_streak_uncommon',
    name: 'Hot Streak',
    description: '+4% profit per consecutive winning trade',
    icon: '\u{1F525}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.uncommon,
    effects: {'winStreakBonus': 0.04},
    templateType: 'winning_streak',
  ),
  Upgrade(
    id: 'winning_streak_rare',
    name: 'Hot Streak',
    description: '+8% profit per consecutive winning trade',
    icon: '\u{1F525}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.rare,
    effects: {'winStreakBonus': 0.08},
    templateType: 'winning_streak',
  ),
  Upgrade(
    id: 'winning_streak_epic',
    name: 'Hot Streak',
    description: '+15% profit per consecutive winning trade',
    icon: '\u{1F525}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.epic,
    effects: {'winStreakBonus': 0.15},
    templateType: 'winning_streak',
  ),
  Upgrade(
    id: 'winning_streak_legendary',
    name: 'Hot Streak',
    description: '+25% profit per consecutive winning trade',
    icon: '\u{1F525}',
    category: UpgradeCategory.trading,
    rarity: UpgradeRarity.legendary,
    effects: {'winStreakBonus': 0.25},
    templateType: 'winning_streak',
  ),
];

/// All template lists for easy iteration
const List<List<Upgrade>> allTemplates = [
  sectorShieldTemplates,
  sectorEdgeTemplates,
  incomeTemplates,
  sectorInsightTemplates,
  sectorDominanceTemplates,
  winningStreakTemplates,
];

/// Combined list: all upgrades (static + templates)
List<Upgrade> get allUpgrades => [
  ...allStaticUpgrades,
  ...sectorShieldTemplates,
  ...sectorEdgeTemplates,
  ...incomeTemplates,
  ...sectorInsightTemplates,
  ...sectorDominanceTemplates,
  ...winningStreakTemplates,
];

/// Get upgrade by ID (searches static + templates)
Upgrade? getUpgradeById(String id) {
  try {
    return allUpgrades.firstWhere((u) => u.id == id);
  } catch (_) {
    return null;
  }
}

/// Get upgrades by category
List<Upgrade> getUpgradesByCategory(UpgradeCategory category) {
  return allUpgrades.where((u) => u.category == category).toList();
}

/// Get upgrades by rarity
List<Upgrade> getUpgradesByRarity(UpgradeRarity rarity) {
  return allUpgrades.where((u) => u.rarity == rarity).toList();
}

/// Generate a random upgrade from the pool, respecting rarity weights
/// For sector-specific templates, assigns a random sector
Upgrade generateRandomUpgrade({
  required Random random,
  List<AcquiredUpgrade> acquiredUpgrades = const [],
  double rarityBoost = 0.0, // 0.0 = normal, positive = shift toward higher rarities
  Set<String> excludeIds = const {}, // Exclude these upgrade IDs from the pool
}) {
  // Build weighted pool from all upgrades
  final pool = <Upgrade>[];
  final weights = <double>[];

  for (final upgrade in allUpgrades) {
    // Skip if excluded (prevent duplicates within same roll set)
    if (excludeIds.contains(upgrade.id)) continue;

    // Skip if already acquired and not repeatable (static upgrades only)
    if (!upgrade.isRepeatable && !upgrade.isTemplate) {
      final alreadyHas = acquiredUpgrades.any((a) => a.upgradeId == upgrade.id);
      if (alreadyHas) continue;
    }

    // For global templates (non-sector, e.g. winning_streak), skip if already have equal/better
    if (upgrade.isTemplate && !upgrade.isSectorSpecific && upgrade.templateType != 'income_situational') {
      final existing = acquiredUpgrades.where(
        (a) => a.templateType == upgrade.templateType
      ).firstOrNull;
      if (existing != null && existing.rarity != null &&
          upgrade.rarityIndex <= UpgradeRarity.values.indexOf(existing.rarity!)) {
        continue;
      }
    }

    // For sector-specific upgrades, skip if no sector can benefit from this rarity
    if (upgrade.isSectorSpecific && upgrade.templateType != 'income_situational') {
      final hasUsefulSector = SectorType.values.any((sector) {
        final existing = acquiredUpgrades.where((a) =>
          a.templateType == upgrade.templateType && a.sector == sector
        ).firstOrNull;
        return existing == null ||
          upgrade.rarityIndex > UpgradeRarity.values.indexOf(existing.rarity!);
      });
      if (!hasUsefulSector) continue;
    }

    // Check prerequisites
    if (upgrade.prerequisites.isNotEmpty) {
      final hasAll = upgrade.prerequisites.every(
        (prereq) => acquiredUpgrades.any((a) => a.upgradeId == prereq),
      );
      if (!hasAll) continue;
    }

    double weight = upgrade.selectionWeight;

    // Apply rarity boost (shift weight toward rarer items)
    if (rarityBoost > 0) {
      switch (upgrade.rarity) {
        case UpgradeRarity.common:
          weight *= (1 - rarityBoost * 0.4).clamp(0.1, 1.0);
          break;
        case UpgradeRarity.uncommon:
          weight *= 1.0;
          break;
        case UpgradeRarity.rare:
          weight *= (1 + rarityBoost * 0.6);
          break;
        case UpgradeRarity.epic:
          weight *= (1 + rarityBoost * 0.8);
          break;
        case UpgradeRarity.legendary:
          weight *= (1 + rarityBoost * 1.0);
          break;
      }
    }

    pool.add(upgrade);
    weights.add(weight);
  }

  if (pool.isEmpty) return allStaticUpgrades.first;

  // Weighted random selection
  final totalWeight = weights.reduce((a, b) => a + b);
  double roll = random.nextDouble() * totalWeight;
  for (int i = 0; i < pool.length; i++) {
    roll -= weights[i];
    if (roll <= 0) {
      final selected = pool[i];
      // Assign random sector if sector-specific (only sectors where this rarity is useful)
      if (selected.isSectorSpecific && selected.templateType != 'income_situational') {
        final usefulSectors = SectorType.values.where((sector) {
          final existing = acquiredUpgrades.where((a) =>
            a.templateType == selected.templateType && a.sector == sector
          ).firstOrNull;
          return existing == null ||
            selected.rarityIndex > UpgradeRarity.values.indexOf(existing.rarity!);
        }).toList();
        if (usefulSectors.isNotEmpty) {
          return selected.withSector(usefulSectors[random.nextInt(usefulSectors.length)]);
        }
        // Fallback: all sectors covered, pick any
        return selected.withSector(SectorType.values[random.nextInt(SectorType.values.length)]);
      }
      return selected;
    }
  }

  return pool.last;
}

/// Check if a new upgrade would replace an existing one (same template type, higher rarity)
/// For sector templates: must also match sector. For global templates: sector is null == null.
/// Returns the AcquiredUpgrade that would be replaced, or null
AcquiredUpgrade? getReplacedUpgrade(Upgrade newUpgrade, List<AcquiredUpgrade> acquiredUpgrades) {
  if (newUpgrade.templateType == null) return null;

  for (final acquired in acquiredUpgrades) {
    if (acquired.templateType == newUpgrade.templateType &&
        acquired.sector == newUpgrade.sector && // null == null for global templates
        acquired.rarity != null &&
        newUpgrade.rarityIndex > UpgradeRarity.values.indexOf(acquired.rarity!)) {
      return acquired;
    }
  }
  return null;
}

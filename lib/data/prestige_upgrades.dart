import 'package:flutter/material.dart';

/// Prestige upgrade that persists across runs
class PrestigeUpgrade {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int cost; // Cost in prestige points
  final PrestigeUpgradeCategory category;
  final Map<String, dynamic> effects;
  final List<String> prerequisites; // IDs of required prestige upgrades
  final int maxLevel; // 1 = one-time purchase, >1 = can be purchased multiple times
  final Color color;

  const PrestigeUpgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.cost,
    required this.category,
    required this.effects,
    this.prerequisites = const [],
    this.maxLevel = 1,
    this.color = Colors.purple,
  });
}

enum PrestigeUpgradeCategory {
  starting,    // Starting bonuses
  trading,     // Trading advantages
  information, // Market insights
  meta,        // Meta-game upgrades
}

/// Helper to build a chain of tiered upgrades with auto-linked prerequisites
List<PrestigeUpgrade> _buildChain({
  required List<String> ids,
  required List<String> names,
  required List<String> descriptions,
  required List<String> icons,
  required List<int> costs,
  required PrestigeUpgradeCategory category,
  required List<Map<String, dynamic>> effects,
  required Color color,
}) {
  return List.generate(ids.length, (i) => PrestigeUpgrade(
    id: ids[i],
    name: names[i],
    description: descriptions[i],
    icon: icons[i],
    cost: costs[i],
    category: category,
    effects: effects[i],
    prerequisites: i > 0 ? [ids[i - 1]] : [],
    color: color,
  ));
}

/// All available prestige upgrades
final List<PrestigeUpgrade> allPrestigeUpgrades = [
  // ═══════════════════════════════════════════
  // STARTING BONUSES — Starting Cash (10 tiers)
  // Total: +$444,200 starting cash
  // ═══════════════════════════════════════════
  ..._buildChain(
    ids: [
      'prestige_starting_cash_1',
      'prestige_starting_cash_2',
      'prestige_starting_cash_3',
      'prestige_starting_cash_4',
      'prestige_starting_cash_5',
      'prestige_starting_cash_6',
      'prestige_starting_cash_7',
      'prestige_starting_cash_8',
      'prestige_starting_cash_9',
      'prestige_starting_cash_10',
    ],
    names: [
      'Seed Money I', 'Seed Money II', 'Seed Money III', 'Silver Spoon',
      'Trust Fund', 'Angel Investor', 'Venture Capital', 'Hedge Fund',
      'Dynasty Wealth', 'Infinite Money',
    ],
    descriptions: [
      'Start each run with +\$200 bonus cash.',
      'Start each run with +\$500 bonus cash.',
      'Start each run with +\$1,000 bonus cash.',
      'Start each run with +\$2,500 bonus cash.',
      'Start each run with +\$5,000 bonus cash.',
      'Start each run with +\$10,000 bonus cash.',
      'Start each run with +\$25,000 bonus cash.',
      'Start each run with +\$50,000 bonus cash.',
      'Start each run with +\$100,000 bonus cash.',
      'Start each run with +\$250,000 bonus cash.',
    ],
    icons: ['💵', '💰', '🏦', '👑', '💎', '🦋', '🏗️', '🏰', '🌆', '✨'],
    costs: [5, 10, 20, 35, 55, 80, 120, 180, 280, 420],
    category: PrestigeUpgradeCategory.starting,
    effects: [
      {'startingCashBonus': 200.0},
      {'startingCashBonus': 500.0},
      {'startingCashBonus': 1000.0},
      {'startingCashBonus': 2500.0},
      {'startingCashBonus': 5000.0},
      {'startingCashBonus': 10000.0},
      {'startingCashBonus': 25000.0},
      {'startingCashBonus': 50000.0},
      {'startingCashBonus': 100000.0},
      {'startingCashBonus': 250000.0},
    ],
    color: Colors.green,
  ),

  // ═══════════════════════════════════════════
  // TRADING — Fee Reduction (5 tiers, additive)
  // Total: 60% fee reduction
  // ═══════════════════════════════════════════
  ..._buildChain(
    ids: [
      'prestige_fee_reduction',
      'prestige_fee_reduction_2',
      'prestige_fee_reduction_3',
      'prestige_fee_reduction_4',
      'prestige_fee_reduction_5',
    ],
    names: [
      'Broker Connections', 'Wall Street Insider', 'VIP Trading',
      'Market Maker', 'Zero Commission',
    ],
    descriptions: [
      'Reduce trading fees by 15%.',
      'Reduce trading fees by an additional 15%.',
      'Reduce trading fees by an additional 10%.',
      'Reduce trading fees by an additional 10%.',
      'Reduce trading fees by an additional 10%.',
    ],
    icons: ['🤝', '⭐', '🎫', '📡', '⚡'],
    costs: [10, 25, 45, 75, 120],
    category: PrestigeUpgradeCategory.trading,
    effects: [
      {'startingFeeReduction': 0.15},
      {'startingFeeReduction': 0.15},
      {'startingFeeReduction': 0.10},
      {'startingFeeReduction': 0.10},
      {'startingFeeReduction': 0.10},
    ],
    color: Colors.blue,
  ),

  // ═══════════════════════════════════════════
  // TRADING — Extra Positions (6 tiers, additive)
  // Total: +16 position slots
  // ═══════════════════════════════════════════
  ..._buildChain(
    ids: [
      'prestige_extra_position',
      'prestige_extra_position_2',
      'prestige_extra_position_3',
      'prestige_extra_position_4',
      'prestige_extra_position_5',
      'prestige_extra_position_6',
    ],
    names: [
      'Extended Desk', 'Diversified Portfolio', 'Trading Floor',
      'Multi-Desk Trader', 'Institutional Scale', 'Market Domination',
    ],
    descriptions: [
      'Start each run with +2 max position slots.',
      'Start each run with +2 max position slots.',
      'Start each run with +2 max position slots.',
      'Start each run with +3 max position slots.',
      'Start each run with +3 max position slots.',
      'Start each run with +4 max position slots.',
    ],
    icons: ['📊', '📈', '🏢', '💻', '🖥️', '🌐'],
    costs: [20, 40, 65, 95, 140, 200],
    category: PrestigeUpgradeCategory.trading,
    effects: [
      {'startingMaxPositions': 2},
      {'startingMaxPositions': 2},
      {'startingMaxPositions': 2},
      {'startingMaxPositions': 3},
      {'startingMaxPositions': 3},
      {'startingMaxPositions': 4},
    ],
    color: Colors.purple,
  ),

  // Stop Loss (single)
  const PrestigeUpgrade(
    id: 'prestige_stop_loss',
    name: 'Stop Loss',
    description: 'Unlock stop loss orders. Auto-sell when positions drop below your threshold.',
    icon: '🛑',
    cost: 30,
    category: PrestigeUpgradeCategory.trading,
    effects: {'unlockStopLoss': true},
    color: Colors.red,
  ),

  // Take Profit (single)
  const PrestigeUpgrade(
    id: 'prestige_take_profit',
    name: 'Take Profit',
    description: 'Unlock take profit orders. Auto-sell when positions reach your target gain.',
    icon: '🎯',
    cost: 30,
    category: PrestigeUpgradeCategory.trading,
    effects: {'unlockTakeProfit': true},
    color: Colors.green,
  ),

  // Short Immunity (single)
  const PrestigeUpgrade(
    id: 'prestige_short_immunity',
    name: 'Short Immunity',
    description: 'Short selling bans from events don\'t affect you.',
    icon: '🛡️',
    cost: 60,
    category: PrestigeUpgradeCategory.trading,
    effects: {'shortBanImmunity': true},
    color: Colors.indigo,
  ),

  // ═══════════════════════════════════════════
  // INFORMATION — Unlock Random Sector Tier (3 tiers)
  // ═══════════════════════════════════════════
  ..._buildChain(
    ids: ['prestige_unlock_tier', 'prestige_unlock_tier_2', 'prestige_unlock_tier_3'],
    names: ['Insider Access', 'Elite Network', 'Market Titan'],
    descriptions: [
      'Start each run with the standard tier of a random sector unlocked.',
      'Start each run with the premium tier of a random sector unlocked.',
      'Start each run with the elite tier of a random sector unlocked.',
    ],
    icons: ['🔓', '🔑', '👑'],
    costs: [15, 35, 150],
    category: PrestigeUpgradeCategory.information,
    effects: [
      {'unlockRandomSectorTier': 'standard'},
      {'unlockRandomSectorTier': 'premium'},
      {'unlockRandomSectorTier': 'elite'},
    ],
    color: Colors.orange,
  ),

  // ═══════════════════════════════════════════
  // META — Quota Reduction (5 tiers, additive)
  // Total: 40% quota reduction
  // ═══════════════════════════════════════════
  ..._buildChain(
    ids: [
      'prestige_quota_reduction',
      'prestige_quota_reduction_2',
      'prestige_quota_reduction_3',
      'prestige_quota_reduction_4',
      'prestige_quota_reduction_5',
    ],
    names: [
      'Relaxed Targets', 'Sympathetic Manager', 'Lenient Board',
      'Flexible Goals', 'Rubber Stamp',
    ],
    descriptions: [
      'Reduce quota targets by 10%.',
      'Reduce quota targets by an additional 10%.',
      'Reduce quota targets by an additional 8%.',
      'Reduce quota targets by an additional 7%.',
      'Reduce quota targets by an additional 5%.',
    ],
    icons: ['📉', '📋', '🤵', '📌', '🏖️'],
    costs: [20, 45, 75, 120, 180],
    category: PrestigeUpgradeCategory.meta,
    effects: [
      {'startingQuotaReduction': 0.10},
      {'startingQuotaReduction': 0.10},
      {'startingQuotaReduction': 0.08},
      {'startingQuotaReduction': 0.07},
      {'startingQuotaReduction': 0.05},
    ],
    color: Colors.teal,
  ),

  // ═══════════════════════════════════════════
  // META — Skip Quota Bonus (2 tiers, additive)
  // Total: +25% bonus on excess (base 15% → 40%)
  // ═══════════════════════════════════════════
  ..._buildChain(
    ids: [
      'prestige_skip_bonus',
      'prestige_skip_bonus_2',
    ],
    names: ['Early Bird Bonus', 'Overachiever'],
    descriptions: [
      'Get 25% bonus on excess when skipping quota early (instead of 15%).',
      'Get 40% bonus on excess when skipping quota early.',
    ],
    icons: ['⏩', '🏆'],
    costs: [40, 80],
    category: PrestigeUpgradeCategory.meta,
    effects: [
      {'skipQuotaBonus': 0.10},
      {'skipQuotaBonus': 0.15},
    ],
    color: Colors.yellow,
  ),

  // ═══════════════════════════════════════════
  // META — Extra Time (5 tiers, additive)
  // Total: +195 seconds per day
  // ═══════════════════════════════════════════
  ..._buildChain(
    ids: [
      'prestige_extra_time',
      'prestige_extra_time_2',
      'prestige_extra_time_3',
      'prestige_extra_time_4',
      'prestige_extra_time_5',
    ],
    names: [
      'Early Bird', 'Time Lord', 'Extended Hours',
      'After Hours', 'Time Dilation',
    ],
    descriptions: [
      'Start each day with +30 seconds.',
      'Start each day with +30 seconds.',
      'Start each day with +30 seconds.',
      'Start each day with +45 seconds.',
      'Start each day with +60 seconds.',
    ],
    icons: ['⏰', '⌛', '🕐', '🌙', '⏳'],
    costs: [25, 50, 80, 120, 180],
    category: PrestigeUpgradeCategory.meta,
    effects: [
      {'startingExtraSeconds': 30},
      {'startingExtraSeconds': 30},
      {'startingExtraSeconds': 30},
      {'startingExtraSeconds': 45},
      {'startingExtraSeconds': 60},
    ],
    color: Colors.cyan,
  ),

  // ═══════════════════════════════════════════
  // META — Passive Income (8 tiers, additive)
  // Total: +$2,130 per day
  // ═══════════════════════════════════════════
  ..._buildChain(
    ids: [
      'prestige_passive_income',
      'prestige_passive_income_2',
      'prestige_passive_income_3',
      'prestige_passive_income_4',
      'prestige_passive_income_5',
      'prestige_passive_income_6',
      'prestige_passive_income_7',
      'prestige_passive_income_8',
    ],
    names: [
      'Side Hustle', 'Investment Portfolio', 'Rental Empire', 'Dividend King',
      'Revenue Stream', 'Cash Machine', 'Money Printer', 'Infinite Wealth',
    ],
    descriptions: [
      'Earn \$20 passive income at the end of each day.',
      'Earn +\$30 passive income at the end of each day.',
      'Earn +\$50 passive income at the end of each day.',
      'Earn +\$80 passive income at the end of each day.',
      'Earn +\$150 passive income at the end of each day.',
      'Earn +\$300 passive income at the end of each day.',
      'Earn +\$500 passive income at the end of each day.',
      'Earn +\$1,000 passive income at the end of each day.',
    ],
    icons: ['💸', '🏠', '🏘️', '💲', '💧', '🏧', '🖨️', '♾️'],
    costs: [30, 55, 85, 120, 170, 240, 340, 500],
    category: PrestigeUpgradeCategory.meta,
    effects: [
      {'startingPassiveIncome': 20.0},
      {'startingPassiveIncome': 30.0},
      {'startingPassiveIncome': 50.0},
      {'startingPassiveIncome': 80.0},
      {'startingPassiveIncome': 150.0},
      {'startingPassiveIncome': 300.0},
      {'startingPassiveIncome': 500.0},
      {'startingPassiveIncome': 1000.0},
    ],
    color: Colors.pink,
  ),

  // ═══════════════════════════════════════════
  // META — Compound Interest (5 tiers, additive)
  // Total: 6% daily interest
  // ═══════════════════════════════════════════
  ..._buildChain(
    ids: [
      'prestige_compound_interest',
      'prestige_compound_interest_2',
      'prestige_compound_interest_3',
      'prestige_compound_interest_4',
      'prestige_compound_interest_5',
    ],
    names: [
      'Compound Interest', 'Savings Account', 'High Yield Fund',
      'Investment Bank', 'Central Bank Access',
    ],
    descriptions: [
      'Earn 2% interest on your cash balance at the end of each day.',
      'Earn +1% interest on your cash balance at the end of each day.',
      'Earn +1% interest on your cash balance at the end of each day.',
      'Earn +1% interest on your cash balance at the end of each day.',
      'Earn +1% interest on your cash balance at the end of each day.',
    ],
    icons: ['🏛️', '💳', '📊', '🔐', '🪙'],
    costs: [70, 110, 160, 230, 320],
    category: PrestigeUpgradeCategory.meta,
    effects: [
      {'cashInterestRate': 0.02},
      {'cashInterestRate': 0.01},
      {'cashInterestRate': 0.01},
      {'cashInterestRate': 0.01},
      {'cashInterestRate': 0.01},
    ],
    color: Colors.amber,
  ),

  // ═══════════════════════════════════════════
  // META — Prestige Accelerator (5 tiers, additive)
  // Total: +300% prestige points
  // ═══════════════════════════════════════════
  ..._buildChain(
    ids: [
      'prestige_accelerator',
      'prestige_accelerator_2',
      'prestige_accelerator_3',
      'prestige_accelerator_4',
      'prestige_accelerator_5',
    ],
    names: [
      'Prestige Accelerator', 'Prestige Turbo', 'Prestige Overdrive',
      'Prestige Singularity', 'Prestige Ascension',
    ],
    descriptions: [
      'Earn 50% more prestige points each run.',
      'Earn +50% more prestige points each run.',
      'Earn +50% more prestige points each run.',
      'Earn +50% more prestige points each run.',
      'Earn +100% more prestige points each run.',
    ],
    icons: ['🚀', '💨', '⚡', '🌀', '🌟'],
    costs: [100, 160, 240, 350, 500],
    category: PrestigeUpgradeCategory.meta,
    effects: [
      {'prestigePointMultiplier': 0.50},
      {'prestigePointMultiplier': 0.50},
      {'prestigePointMultiplier': 0.50},
      {'prestigePointMultiplier': 0.50},
      {'prestigePointMultiplier': 1.00},
    ],
    color: Colors.deepPurple,
  ),

  // ═══════════════════════════════════════════
  // UNIQUE UPGRADES (no tiers)
  // ═══════════════════════════════════════════
  const PrestigeUpgrade(
    id: 'prestige_reroll',
    name: 'Reroll Master',
    description: 'Reroll your upgrade choices once per day.',
    icon: '🎲',
    cost: 40,
    category: PrestigeUpgradeCategory.meta,
    effects: {'upgradeRerollsPerDay': 1},
    color: Colors.orange,
  ),
  const PrestigeUpgrade(
    id: 'prestige_lucky_start',
    name: 'Lucky Start',
    description: 'Your first upgrade each run is guaranteed to be Rare or better.',
    icon: '🍀',
    cost: 60,
    category: PrestigeUpgradeCategory.meta,
    effects: {'guaranteedRareFirst': true},
    color: Colors.green,
  ),
  const PrestigeUpgrade(
    id: 'prestige_second_chance',
    name: 'Second Chance',
    description: 'Once per run, survive a failed quota and continue playing.',
    icon: '💫',
    cost: 120,
    category: PrestigeUpgradeCategory.meta,
    effects: {'quotaFailFreebie': 1},
    color: Colors.amber,
  ),
  const PrestigeUpgrade(
    id: 'prestige_golden_parachute',
    name: 'Golden Parachute',
    description: 'Keep 25% of your cash when a run ends from failed quota.',
    icon: '🪂',
    cost: 50,
    category: PrestigeUpgradeCategory.meta,
    effects: {'keepCashOnFailPercent': 0.25},
    color: Colors.yellow,
  ),
  const PrestigeUpgrade(
    id: 'prestige_quick_learner',
    name: 'Quick Learner',
    description: 'Get 4 upgrade choices instead of 3 each day.',
    icon: '📚',
    cost: 35,
    category: PrestigeUpgradeCategory.meta,
    effects: {'extraUpgradeChoices': 1},
    color: Colors.indigo,
  ),
  const PrestigeUpgrade(
    id: 'prestige_market_veteran',
    name: 'Market Veteran',
    description: 'Choose a free daily upgrade at the start of each run.',
    icon: '🎖️',
    cost: 80,
    category: PrestigeUpgradeCategory.meta,
    effects: {'startingUpgrades': 1},
    color: Colors.deepOrange,
  ),

  // ═══════════════════════════════════════════
  // SHOP & LUCK UPGRADES
  // ═══════════════════════════════════════════

  // Luck Boost (3 tiers): shift rarity weights for all upgrade generation
  ..._buildChain(
    ids: [
      'prestige_luck_boost',
      'prestige_luck_boost_2',
      'prestige_luck_boost_3',
    ],
    names: ['Lucky Charm', 'Fortune Favored', 'Golden Touch'],
    descriptions: [
      'Slightly increase rare+ upgrade chance in shop.',
      'Further increase rare+ upgrade chance in shop.',
      'Greatly increase rare+ upgrade chance in shop.',
    ],
    icons: ['🍀', '🌟', '✨'],
    costs: [50, 100, 200],
    category: PrestigeUpgradeCategory.meta,
    effects: [
      {'shopRarityBoost': 0.3},
      {'shopRarityBoost': 0.3},
      {'shopRarityBoost': 0.4},
    ],
    color: Colors.green,
  ),

  // Reroll Boost (3 tiers): increase free rerolls per slot
  ..._buildChain(
    ids: [
      'prestige_reroll_boost',
      'prestige_reroll_boost_2',
      'prestige_reroll_boost_3',
    ],
    names: ['Second Look', 'Fresh Options', 'Infinite Browsing'],
    descriptions: [
      '+1 free reroll per upgrade slot (shop & daily).',
      '+1 free reroll per upgrade slot (shop & daily).',
      '+1 free reroll per upgrade slot (shop & daily).',
    ],
    icons: ['🔄', '🎰', '♾️'],
    costs: [40, 80, 160],
    category: PrestigeUpgradeCategory.meta,
    effects: [
      {'extraFreeRerolls': 1},
      {'extraFreeRerolls': 1},
      {'extraFreeRerolls': 1},
    ],
    color: Colors.cyan,
  ),

  // Sector Amplifier (single): boost sector-specific upgrade effects
  const PrestigeUpgrade(
    id: 'prestige_sector_amplifier',
    name: 'Sector Amplifier',
    description: 'Sector Shield and Sector Edge upgrades are 25% more effective.',
    icon: '📡',
    cost: 120,
    category: PrestigeUpgradeCategory.trading,
    effects: {'sectorAmplifier': 0.25},
    color: Colors.purple,
  ),

  // === ROBOT TRADERS ===
  ..._buildChain(
    ids: ['robot_slot_1', 'robot_slot_2', 'robot_slot_3', 'robot_slot_4', 'robot_slot_5'],
    names: ['Robot Bay', 'Robot Slot II', 'Robot Slot III', 'Robot Slot IV', 'Robot Slot V'],
    descriptions: [
      'Unlock robot traders and gain your first trading bot.',
      'Unlock a second trading bot.',
      'Unlock a third trading bot.',
      'Unlock a fourth trading bot.',
      'Unlock a fifth trading bot.',
    ],
    icons: ['🤖', '🤖', '🤖', '🤖', '🤖'],
    costs: [15, 20, 30, 45, 65],
    category: PrestigeUpgradeCategory.meta,
    effects: [
      {'robotSlots': 1},
      {'robotSlots': 1},
      {'robotSlots': 1},
      {'robotSlots': 1},
      {'robotSlots': 1},
    ],
    color: const Color(0xFFF97316),
  ),
  const PrestigeUpgrade(
    id: 'robot_blueprint',
    name: 'Blueprint Memory',
    description: 'Robots keep 50% of their upgrade levels between runs.',
    icon: '🧠',
    cost: 35,
    category: PrestigeUpgradeCategory.meta,
    effects: {'robotBlueprintMemory': true},
    prerequisites: ['robot_slot_1'],
    color: Color(0xFFA855F7),
  ),
  const PrestigeUpgrade(
    id: 'robot_overclock',
    name: 'Overclock',
    description: '+1 trade per day for all robots.',
    icon: '⚡',
    cost: 25,
    category: PrestigeUpgradeCategory.meta,
    effects: {'robotOverclock': true},
    prerequisites: ['robot_slot_1'],
    color: Color(0xFFF59E0B),
  ),
  const PrestigeUpgrade(
    id: 'robot_deep_pockets',
    name: 'Deep Pockets',
    description: '+30% maximum budget allocable to each robot.',
    icon: '💰',
    cost: 20,
    category: PrestigeUpgradeCategory.meta,
    effects: {'robotDeepPockets': 1.0},
    prerequisites: ['robot_slot_1'],
    color: Color(0xFF10B981),
  ),
];

/// Get prestige upgrade by ID
PrestigeUpgrade? getPrestigeUpgradeById(String id) {
  return allPrestigeUpgrades.where((u) => u.id == id).firstOrNull;
}

/// Get available prestige upgrades (not yet purchased and prerequisites met)
List<PrestigeUpgrade> getAvailablePrestigeUpgrades(List<String> purchasedIds) {
  return allPrestigeUpgrades.where((u) {
    // Already purchased
    if (purchasedIds.contains(u.id)) return false;

    // Check prerequisites
    for (final prereq in u.prerequisites) {
      if (!purchasedIds.contains(prereq)) return false;
    }

    return true;
  }).toList();
}

/// Get prestige upgrades by category
List<PrestigeUpgrade> getPrestigeUpgradesByCategory(
    PrestigeUpgradeCategory category, List<String> purchasedIds) {
  return getAvailablePrestigeUpgrades(purchasedIds)
      .where((u) => u.category == category)
      .toList();
}

import '../core/enums.dart';
import '../models/talent_node.dart';

// ─────────────────────────────────────────────────
//  KANDL Talent Tree — Prestige v2
//  324 nodes across 5 branches + root
// ─────────────────────────────────────────────────

/// All sector IDs used in the tree, matching SectorType values.
const _sectorIds = [
  'tech', 'healthcare', 'finance', 'energy',
  'consumer', 'industrial', 'realestate', 'telecom',
  'materials', 'utilities', 'gaming', 'crypto',
  'aerospace', 'commodities', 'forex', 'indices',
];

const _sectorNames = {
  'tech': 'Tech',
  'healthcare': 'Health',
  'finance': 'Finance',
  'energy': 'Energy',
  'consumer': 'Consumer',
  'industrial': 'Industry',
  'realestate': 'Real Est.',
  'telecom': 'Telecom',
  'materials': 'Materials',
  'utilities': 'Utilities',
  'gaming': 'Gaming',
  'crypto': 'Crypto',
  'aerospace': 'Aero',
  'commodities': 'Commod.',
  'forex': 'Forex',
  'indices': 'Indices',
};

const _sectorIcons = {
  'tech': '\u{1F4BB}',
  'healthcare': '\u{1F3E5}',
  'finance': '\u{1F3E6}',
  'energy': '\u26A1',
  'consumer': '\u{1F6D2}',
  'industrial': '\u{1F3ED}',
  'realestate': '\u{1F3E0}',
  'telecom': '\u{1F4E1}',
  'materials': '\u{1FAA8}',
  'utilities': '\u{1F4A1}',
  'gaming': '\u{1F3AE}',
  'crypto': '\u20BF',
  'aerospace': '\u{1F680}',
  'commodities': '\u{1F6E2}\uFE0F',
  'forex': '\u{1F4B1}',
  'indices': '\u{1F4CA}',
};

// ─── Build all nodes ───

List<TalentNode> _buildAllNodes() {
  final nodes = <TalentNode>[];

  // ═══════════ GENERAL ROOT ═══════════
  nodes.add(const TalentNode(
    id: 'general_root',
    icon: '\u2B50',
    name: 'Starting Capital',
    description: 'Your first step into the prestige tree',
    effectText: '+\$200 starting cash',
    cost: 1,
    branch: TalentBranch.root,
    effects: {'startingCashBonus': 200.0},
    size: TalentNodeSize.lg,
  ));

  // ═══════════ TRADER BRANCH (up from general_root) ═══════════
  nodes.addAll(_buildTraderBranch());

  // ═══════════ AUTOMATION BRANCH (left from general_root) ═══════════
  nodes.addAll(_buildAutomationBranch());

  // ═══════════ SURVIVAL BRANCH (down from general_root) ═══════════
  nodes.addAll(_buildSurvivalBranch());

  // ═══════════ INTELLIGENCE BRANCH (right from general_root) ═══════════
  nodes.addAll(_buildIntelligenceBranch());

  // ═══════════ SECTOR ROOT ═══════════
  nodes.add(const TalentNode(
    id: 'sector_root',
    icon: '\u{1F310}',
    name: 'Sector Mastery',
    description: 'Specialize in market sectors',
    effectText: '+\$200 starting cash',
    cost: 1,
    branch: TalentBranch.sectors,
    effects: {'startingCashBonus': 200.0},
    size: TalentNodeSize.lg,
  ));

  // ═══════════ SECTORS (fan) ═══════════
  nodes.addAll(_buildSectorFan());

  return nodes;
}

// ═══════════ TRADER BRANCH ═══════════
// Spine: 10 nodes going up from general_root (cash + position slots)
// Side branches from spine #2, #4, #5, #7:
//   #2 left: Stop Loss / Take Profit (5 nodes)
//   #2 right: Tempo Trading (6 nodes)
//   #4 left: Winning Streak (3 nodes)
//   #5 left: Limit Orders (2 nodes)
//   #5 right: Profit Multipliers (4 nodes)
//   #7 left: Leverage (5 nodes)
//   #7 right: Compound Interest (3 nodes)

List<TalentNode> _buildTraderBranch() {
  final nodes = <TalentNode>[];

  // ── Spine: 10 nodes ──
  const spineData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('tr_seed1',  '\u{1F4B0}', 'Seed Money I',      'Your first trading capital',    '+\$200 starting cash',   3,  {'startingCashBonus': 200.0}),
    ('tr_slot1',  '\u{1F4CA}', 'Extra Slot I',      'Expand your portfolio',         '+1 max position',        5,  {'extraPositionSlots': 1}),
    ('tr_seed2',  '\u{1F4B0}', 'Seed Money II',     'Growing your seed fund',        '+\$300 starting cash',   8,  {'startingCashBonus': 300.0}),
    ('tr_slot2',  '\u{1F4CA}', 'Extra Slot II',     'More room to trade',            '+1 max position',        12, {'extraPositionSlots': 1}),
    ('tr_seed3',  '\u{1F4B0}', 'Seed Money III',    'Serious starting capital',      '+\$500 starting cash',   16, {'startingCashBonus': 500.0}),
    ('tr_slot3',  '\u{1F4CA}', 'Extra Slot III',    'Diversify further',             '+1 max position',        22, {'extraPositionSlots': 1}),
    ('tr_slot4',  '\u{1F4CA}', 'Extra Slot IV',     'Portfolio expansion',           '+2 max positions',       28, {'extraPositionSlots': 2}),
    ('tr_slot5',  '\u{1F4CA}', 'Extra Slot V',      'Major portfolio growth',        '+2 max positions',       36, {'extraPositionSlots': 2}),
    ('tr_slot6',  '\u{1F4CA}', 'Extra Slot VI',     'Maximum capacity',              '+3 max positions',       46, {'extraPositionSlots': 3}),
    ('tr_cap',    '\u{1F451}', 'Infinite Trader',   'No limits on your portfolio',   'Unlimited positions',    60, {'unlimitedPositions': true}),
  ];

  for (int i = 0; i < spineData.length; i++) {
    final d = spineData[i];
    nodes.add(TalentNode(
      id: d.$1,
      icon: d.$2,
      name: d.$3,
      description: d.$4,
      effectText: d.$5,
      cost: d.$6,
      branch: TalentBranch.trader,
      parentId: i == 0 ? 'general_root' : spineData[i - 1].$1,
      effects: d.$7,
      size: i == 0 ? TalentNodeSize.sm : (i == spineData.length - 1 ? TalentNodeSize.md : TalentNodeSize.xs),
    ));
  }

  // ── Side branch from spine #2 (tr_slot1) — LEFT: Stop Loss / Take Profit ──
  const slTpData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('tr_sl',          '\u{1F6D1}', 'Stop Loss',             'Auto-sell when losses hit your threshold',           'Unlock stop loss + slider',  3,  {'stopLossUnlock': true}),
    ('tr_tp',          '\u{1F3AF}', 'Take Profit',           'Auto-sell when gains hit your target',               'Unlock take profit + slider', 3, {'takeProfitUnlock': true}),
    ('tr_trailing',    '\u{1F4C8}', 'Trailing Stop',         'Stop loss follows price upward automatically',       'Smart SL follows gains',     5,  {'trailingStopUnlock': true}),
    ('tr_partial_tp',  '\u2702\uFE0F',  'Partial Take Profit',  'Sell half at target, let the rest ride',          'Sell 50% at TP',             8,  {'partialTakeProfitUnlock': true}),
    ('tr_safety',      '\u{1F6E1}\uFE0F', 'Safety Net',       'Your first stop loss trigger is softened',          '1st SL: -50% loss/run',      12, {'safetyNetUnlock': true}),
  ];

  for (int i = 0; i < slTpData.length; i++) {
    final d = slTpData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.trader,
      parentId: i == 0 ? 'tr_slot1' : slTpData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── Side branch from spine #2 (tr_slot1) — RIGHT: Tempo Trading ──
  const tempoData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('tr_qf1',      '\u26A1',       'Quick Flip I',      'Day trading pays a premium',             '+10% same-day profit',    3,  {'quickFlipBonus': 0.10}),
    ('tr_qf2',      '\u26A1',       'Quick Flip II',     'Sharper reflexes, bigger rewards',       '+20% same-day profit',    5,  {'quickFlipBonus': 0.10}),
    ('tr_scalper',  '\u{1F4A8}',    'Scalper',           'In and out with zero friction',          'No fees on same-day',     8,  {'scalperNoFees': true}),
    ('tr_patient1', '\u{1F9D8}',    'Patient Trader I',  'Good things come to those who wait',     '+5% on 3+ day holds',     5,  {'holdBonus3d': 0.05}),
    ('tr_patient2', '\u{1F9D8}',    'Patient Trader II', 'Patience is a virtue',                   '+10% on 5+ day holds',    8,  {'holdBonus5d': 0.10}),
    ('tr_diamond',  '\u{1F48E}',    'Diamond Hands',     'Never let go of a winner',               '+20% on 7+ day holds',    12, {'holdBonus7d': 0.20}),
  ];

  for (int i = 0; i < tempoData.length; i++) {
    final d = tempoData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.trader,
      parentId: i == 0 ? 'tr_slot1' : tempoData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── Side branch from spine #4 (tr_slot2) — LEFT: Winning Streak ──
  const streakData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('tr_streak',     '\u{1F525}', 'Winning Streak',  'Each consecutive win boosts the next',        '+5% per consecutive win (max 3)',   5,  {'streakBonusPerWin': 0.05, 'streakMaxStacks': 3}),
    ('tr_hot_hand',   '\u{1F3B0}', 'Hot Hand',        'Your luck compounds the longer you ride it',  '+8% per win, max 6 stacks',         10, {'streakBonusPerWin': 0.08, 'streakMaxStacks': 6}),
    ('tr_resilient',  '\u{1F9CA}', 'Resilient',       'A bad trade slows you down, not stops you',   'Losses halve streak instead of reset', 15, {'streakKeepOnLoss': true}),
  ];

  for (int i = 0; i < streakData.length; i++) {
    final d = streakData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.trader,
      parentId: i == 0 ? 'tr_slot2' : streakData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── Side branch from spine #5 (tr_seed3) — LEFT: Limit Orders ──
  const limitData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('tr_limit_orders', '\u{1F4CB}', 'Limit Orders',      'Set a target price for auto buy or sell',        'Unlock limit orders',         5,  {'limitOrdersUnlock': true}),
    ('tr_smart_orders', '\u{1F517}', 'Smart Orders',      'Auto-attach stop loss and take profit to orders', 'SL/TP on limit orders',      8,  {'smartOrdersUnlock': true}),
  ];

  for (int i = 0; i < limitData.length; i++) {
    final d = limitData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.trader,
      parentId: i == 0 ? 'tr_seed3' : limitData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── Side branch from spine #5 (tr_seed3) — RIGHT: Profit Multipliers ──
  const profitData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('tr_profit1', '\u{1F4B5}', 'Sharp Eye I',   'Spot opportunities others miss',    '+5% trade profits',     4,  {'profitMultiplier': 0.05}),
    ('tr_profit2', '\u{1F4B5}', 'Sharp Eye II',  'Market patterns become clear',      '+10% trade profits',    6,  {'profitMultiplier': 0.05}),
    ('tr_profit3', '\u{1F4B5}', 'Sharp Eye III', 'You see the matrix',                '+15% trade profits',    10, {'profitMultiplier': 0.05}),
    ('tr_eagle',   '\u{1F985}', 'Eagle Eye',     'Nothing escapes your gaze',         '+25% trade profits',    15, {'profitMultiplier': 0.10}),
  ];

  for (int i = 0; i < profitData.length; i++) {
    final d = profitData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.trader,
      parentId: i == 0 ? 'tr_seed3' : profitData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── Side branch from spine #7 (tr_slot4) — LEFT: Leverage ──
  const leverageData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('tr_margin',       '\u{1F4B3}', 'Margin Account',   'Access to borrowed capital',              'Unlock x1.25 leverage',    8,  {'leverageMax': 1.25}),
    ('tr_lev15',        '\u{1F4B3}', 'Leverage x1.5',    'Increase your buying power',              'Unlock x1.5 leverage',     10, {'leverageMax': 1.5}),
    ('tr_lev2',         '\u{1F525}', 'Leverage x2',      'Double the stakes',                       'Unlock x2 leverage',       15, {'leverageMax': 2.0}),
    ('tr_margin_shield','\u{1F6E1}\uFE0F', 'Margin Shield', 'Soften the blow of liquidation',       '-50% liquidation penalty', 12, {'marginShield': true}),
    ('tr_lev3',         '\u{1F525}', 'Leverage x3',      'Maximum risk, maximum reward',            'Unlock x3 leverage',       20, {'leverageMax': 3.0}),
  ];

  for (int i = 0; i < leverageData.length; i++) {
    final d = leverageData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.trader,
      parentId: i == 0 ? 'tr_slot4' : leverageData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── Side branch from spine #7 (tr_slot4) — RIGHT: Compound Interest ──
  const interestData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('tr_interest1', '\u{1F3E6}', 'Interest I',   'Your cash starts working for you',    '0.1% daily on idle cash',   8,  {'compoundInterestRate': 0.001}),
    ('tr_interest2', '\u{1F3E6}', 'Interest II',  'Better rates, bigger returns',        '0.3% daily on idle cash',   12, {'compoundInterestRate': 0.002}),
    ('tr_interest3', '\u{1F3E6}', 'Interest III', 'Premium banking privileges',          '0.5% daily on idle cash',   18, {'compoundInterestRate': 0.002}),
  ];

  for (int i = 0; i < interestData.length; i++) {
    final d = interestData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.trader,
      parentId: i == 0 ? 'tr_slot4' : interestData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  return nodes;
}

// ═══════════ AUTOMATION BRANCH ═══════════
// Spine: 10 robot slots going left from general_root
// Sub-branches spread across different robots:
//   #2 up:  Discount (3 nodes) — global upgrade cost reduction
//   #3 down: Starting Level (3 nodes) — all robots start at higher level
//   #5 up:  Seed Money (3 nodes) — global starting budget
//   #6 down: Win Rate (3 nodes) — global win rate bonus
//   #8 up:  Speed (2 nodes) — robots trade faster
//   #9 down: Auto-Collect (1 node) — collect all robot wallets

const _robotNames = ['Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon',
                     'Zeta', 'Eta', 'Theta', 'Iota', 'Kappa'];

List<TalentNode> _buildAutomationBranch() {
  final nodes = <TalentNode>[];

  // ── Spine: 10 robot slots ──
  const slotCosts = [3, 5, 8, 12, 16, 22, 28, 36, 46, 60];

  for (int i = 0; i < 10; i++) {
    final slot = i + 1;
    final name = _robotNames[i];
    nodes.add(TalentNode(
      id: 'auto_slot_$slot',
      icon: '\u{1F916}',
      name: 'Robot $name',
      description: 'Unlock robot trading slot $slot',
      effectText: '+1 robot slot',
      cost: slotCosts[i],
      branch: TalentBranch.automation,
      parentId: i == 0 ? 'general_root' : 'auto_slot_$i',
      effects: const {'robotSlots': 1},
      size: i == 0 ? TalentNodeSize.sm : TalentNodeSize.xs,
    ));
  }

  // ── From #2 (Beta) — UP: Global Discount ──
  const discData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('auto_disc1', '\u{1F4B8}', 'Bulk Discount I',   'Negotiate better rates for all robots',       '-10% upgrade cost (all)',  4, {'robotUpgradeCostReduction': 0.10}),
    ('auto_disc2', '\u{1F4B8}', 'Bulk Discount II',  'Volume discounts on robot upgrades',          '-20% upgrade cost (all)',  8, {'robotUpgradeCostReduction': 0.10}),
    ('auto_disc3', '\u{1F4B8}', 'Bulk Discount III', 'Maximum cost efficiency',                     '-30% upgrade cost (all)', 14, {'robotUpgradeCostReduction': 0.10}),
  ];
  for (int i = 0; i < discData.length; i++) {
    final d = discData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.automation,
      parentId: i == 0 ? 'auto_slot_2' : discData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── From #3 (Gamma) — DOWN: Global Starting Level ──
  const lvlData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('auto_lvl1', '\u{1F4CA}', 'Boot Camp I',   'All robots start pre-trained',       'All robots start Lv.1',  5, {'robotStartLevel': 1}),
    ('auto_lvl2', '\u{1F4C8}', 'Boot Camp II',  'Advanced robot training program',    'All robots start Lv.2', 10, {'robotStartLevel': 2}),
    ('auto_lvl3', '\u{1F31F}', 'Boot Camp III', 'Elite robot training',               'All robots start Lv.3', 18, {'robotStartLevel': 3}),
  ];
  for (int i = 0; i < lvlData.length; i++) {
    final d = lvlData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.automation,
      parentId: i == 0 ? 'auto_slot_3' : lvlData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── From #5 (Epsilon) — UP: Global Seed Money ──
  const seedData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('auto_seed1', '\u{1F4B5}', 'Startup Fund I',   'Give robots a head start',       'All robots start +\$50',   6, {'robotSeedMoney': 50.0}),
    ('auto_seed2', '\u{1F4B5}', 'Startup Fund II',  'Bigger robot budgets',           'All robots start +\$100', 12, {'robotSeedMoney': 50.0}),
    ('auto_seed3', '\u{1F4B5}', 'Startup Fund III', 'Serious robot capital',          'All robots start +\$200', 20, {'robotSeedMoney': 100.0}),
  ];
  for (int i = 0; i < seedData.length; i++) {
    final d = seedData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.automation,
      parentId: i == 0 ? 'auto_slot_5' : seedData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── From #6 (Zeta) — DOWN: Win Rate ──
  const wrData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('auto_wr1', '\u{1F3AF}', 'Calibration I',   'Better algorithms for all robots',    '+2% win rate (all)',  8, {'robotWinRateBonus': 0.02}),
    ('auto_wr2', '\u{1F3AF}', 'Calibration II',  'Fine-tuned decision engines',         '+5% win rate (all)', 16, {'robotWinRateBonus': 0.03}),
    ('auto_wr3', '\u{1F3AF}', 'Calibration III', 'State-of-the-art trading AI',         '+8% win rate (all)', 25, {'robotWinRateBonus': 0.03}),
  ];
  for (int i = 0; i < wrData.length; i++) {
    final d = wrData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.automation,
      parentId: i == 0 ? 'auto_slot_6' : wrData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── From #8 (Theta) — UP: Speed ──
  const speedData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('auto_speed1', '\u26A1', 'Overclock I',  'Robots execute trades faster',    '+25% robot speed',  15, {'robotSpeedBonus': 0.25}),
    ('auto_speed2', '\u26A1', 'Overclock II', 'Maximum robot throughput',        '+50% robot speed',  20, {'robotSpeedBonus': 0.25}),
  ];
  for (int i = 0; i < speedData.length; i++) {
    final d = speedData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.automation,
      parentId: i == 0 ? 'auto_slot_8' : speedData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── From #9 (Iota) — DOWN: Auto-Collect All ──
  nodes.add(const TalentNode(
    id: 'auto_collect',
    icon: '\u{1F4E5}',
    name: 'Auto-Collect',
    description: 'Full automation pipeline',
    effectText: 'Auto-collect all robot wallets',
    cost: 20,
    branch: TalentBranch.automation,
    parentId: 'auto_slot_9',
    effects: {'robotAutoCollect': 999},
    size: TalentNodeSize.xs,
  ));

  return nodes;
}

// ═══════════ SURVIVAL BRANCH ═══════════
// Spine: 8 nodes going down from general_root (days, lives, quota reduction)
// Side branches from spine #2, #4, #7:
//   #2 left: Skip Boost (3 nodes)
//   #2 right: Loss Recovery (3 nodes)
//   #4 left: Overtime (3 nodes)
//   #4 right: PP Boost (3 nodes)
//   #7 left: Early Finish (3 nodes)
//   #7 right: Momentum (3 nodes)

List<TalentNode> _buildSurvivalBranch() {
  final nodes = <TalentNode>[];

  // ── Spine: 8 nodes ──
  const spineData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects, TalentNodeSize size)>[
    ('sv_day1',   '\u{1F4C5}', 'Extra Day I',       'More time to meet your quota',              '+1 day per quota',           3,  {'extraQuotaDays': 1}, TalentNodeSize.sm),
    ('sv_life1',  '\u2764\uFE0F',  'Extra Life I',  'Survive a failed quota',                    '+1 life per run',            8,  {'extraLives': 1}, TalentNodeSize.xs),
    ('sv_day2',   '\u{1F4C5}', 'Extra Day II',      'Extended trading window',                   '+1 day per quota',          10,  {'extraQuotaDays': 1}, TalentNodeSize.xs),
    ('sv_quota1', '\u{1F4C9}', 'Quota Relief I',    'Lower the bar slightly',                    '-5% quota target',          12,  {'survivalQuotaReduction': 0.05}, TalentNodeSize.xs),
    ('sv_life2',  '\u2764\uFE0F',  'Extra Life II', 'Another chance to recover',                 '+1 life per run',           18,  {'extraLives': 1}, TalentNodeSize.xs),
    ('sv_quota2', '\u{1F4C9}', 'Quota Relief II',   'More breathing room on targets',            '-5% quota target',          22,  {'survivalQuotaReduction': 0.05}, TalentNodeSize.xs),
    ('sv_day3',   '\u{1F4C5}', 'Extra Day III',     'Maximum trading time',                      '+1 day per quota',          28,  {'extraQuotaDays': 1}, TalentNodeSize.xs),
    ('sv_cap',    '\u{1F451}', 'Last Stand',         'Your final safety net',                     '+1 life, -25% quota on res.', 50, {'extraLives': 1, 'resurrectQuotaReduction': 0.25}, TalentNodeSize.md),
  ];

  for (int i = 0; i < spineData.length; i++) {
    final d = spineData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.survival,
      parentId: i == 0 ? 'general_root' : spineData[i - 1].$1,
      effects: d.$7,
      size: d.$8,
    ));
  }

  // ── From spine #2 (sv_life1) — LEFT: Skip Boost ──
  const skipData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('sv_skip1', '\u23E9', 'Skip Bonus I',    'More reward for skipping a quota',       '+10% skip bonus',               4, {'skipQuotaBonus': 0.10}),
    ('sv_skip2', '\u23E9', 'Skip Bonus II',   'Bigger skip rewards',                    '+20% skip bonus',               8, {'skipQuotaBonus': 0.10}),
    ('sv_skip3', '\u{1F525}', 'Skip Streak',  'Consecutive skips compound',             '+5% per consecutive skip',     14, {'skipStreakBonus': 0.05}),
  ];
  for (int i = 0; i < skipData.length; i++) {
    final d = skipData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.survival,
      parentId: i == 0 ? 'sv_life1' : skipData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── From spine #2 (sv_life1) — RIGHT: Loss Recovery ──
  const recovData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('sv_recov1', '\u{1F489}', 'Loss Recovery I',   'Recover a fraction of your losses',    '3% loss recovery',   5, {'lossRecoveryPercent': 0.03}),
    ('sv_recov2', '\u{1F489}', 'Loss Recovery II',  'Better loss mitigation',               '6% loss recovery',  10, {'lossRecoveryPercent': 0.03}),
    ('sv_recov3', '\u{1F489}', 'Loss Recovery III', 'Significant loss cushion',             '10% loss recovery', 16, {'lossRecoveryPercent': 0.04}),
  ];
  for (int i = 0; i < recovData.length; i++) {
    final d = recovData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.survival,
      parentId: i == 0 ? 'sv_life1' : recovData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── From spine #4 (sv_quota1) — LEFT: Overtime ──
  const graceData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('sv_grace1',      '\u23F0', 'Overtime I',     'Emergency extra day on failed quota',       '+1 emergency day',                8, {'overtimeDays': 1}),
    ('sv_grace2',      '\u23F0', 'Overtime II',    'More time under pressure',                  '+2 emergency days total',        14, {'overtimeDays': 1}),
    ('sv_second_wind', '\u{1F4AA}', 'Second Wind', 'Bounce back stronger after using a life',  '+15% profits for 3 days on res.', 20, {'secondWindBonus': 0.15}),
  ];
  for (int i = 0; i < graceData.length; i++) {
    final d = graceData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.survival,
      parentId: i == 0 ? 'sv_quota1' : graceData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── From spine #4 (sv_quota1) — RIGHT: PP Boost ──
  const ppData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('sv_pp1', '\u2B50', 'PP Boost I',   'Earn more prestige points',      '+10% PP earned',   6, {'ppMultiplier': 0.10}),
    ('sv_pp2', '\u2B50', 'PP Boost II',  'Greater prestige gains',         '+20% PP earned',  12, {'ppMultiplier': 0.10}),
    ('sv_pp3', '\u2B50', 'PP Boost III', 'Maximum prestige efficiency',    '+35% PP earned',  20, {'ppMultiplier': 0.15}),
  ];
  for (int i = 0; i < ppData.length; i++) {
    final d = ppData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.survival,
      parentId: i == 0 ? 'sv_quota1' : ppData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── From spine #7 (sv_day3) — LEFT: Early Finish ──
  const earlyData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('sv_early1',   '\u{1F3C3}', 'Early Bird I',  'Bonus PP for finishing quota early',     '+5% PP if 1+ day early',    8, {'earlyFinishPP': 0.05}),
    ('sv_early2',   '\u{1F3C3}', 'Early Bird II', 'Bigger early finish rewards',            '+10% PP if 2+ days early', 14, {'earlyFinishPP2': 0.10}),
    ('sv_speedrun', '\u26A1',    'Speedrunner',   'The ultimate time challenge reward',     'x2 PP if all quotas early', 25, {'speedrunPPMultiplier': true}),
  ];
  for (int i = 0; i < earlyData.length; i++) {
    final d = earlyData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.survival,
      parentId: i == 0 ? 'sv_day3' : earlyData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── From spine #7 (sv_day3) — RIGHT: Momentum ──
  const momentumData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('sv_streak1', '\u{1F525}', 'Hot Streak I',     'Consecutive quotas build momentum',          '+2% profit per quota streak',  8, {'streakProfitBonus': 0.02}),
    ('sv_streak2', '\u{1F525}', 'Hot Streak II',    'Stronger streak bonuses',                    '+4% profit per quota streak', 14, {'streakProfitBonus': 0.02}),
    ('sv_streak3', '\u{1F48E}', 'Unbreakable',      'Your streak persists even after using a life', 'Streak survives life use',  22, {'streakPersists': true}),
  ];
  for (int i = 0; i < momentumData.length; i++) {
    final d = momentumData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.survival,
      parentId: i == 0 ? 'sv_day3' : momentumData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  return nodes;
}

// ═══════════ INTELLIGENCE BRANCH ═══════════
// Spine: 8 nodes going right from general_root (rerolls, luck, upgrades)
// Sub-branches:
//   #2 up:   Informant Secret (6 nodes) — tips, cost reduction, foresight
//   #2 down: FintTok (5 nodes) — accuracy, extra influencers, flag bad tips
//   #5 up:   News & Events (5 nodes) — extra news, category preview, block events
//   #5 down: Informant Advanced (3 nodes) — precision, extra free tips

List<TalentNode> _buildIntelligenceBranch() {
  final nodes = <TalentNode>[];

  // ── Spine: 8 nodes ──
  const spineData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects, TalentNodeSize size)>[
    ('in_reroll1', '\u{1F3B2}', 'Free Reroll I',     'Better options at no cost',                '+1 free reroll/slot',            3,  {'extraFreeRerolls': 1}, TalentNodeSize.sm),
    ('in_luck1',   '\u{1F340}', 'Lucky Charm',        'Fortune smiles upon your shop',            '+0.3 shop rarity boost',         5,  {'shopRarityBoost': 0.3}, TalentNodeSize.xs),
    ('in_reroll2', '\u{1F3B2}', 'Free Reroll II',     'Even more free rerolls',                   '+1 free reroll/slot',            8,  {'extraFreeRerolls': 1}, TalentNodeSize.xs),
    ('in_choice',  '\u{1F4DA}', 'Quick Learner',      'See more upgrade options each day',        '+1 upgrade choice',             12,  {'extraUpgradeChoices': 1}, TalentNodeSize.xs),
    ('in_luck2',   '\u{1F31F}', 'Fortune Favored',    'Rare upgrades appear more often',          '+0.3 shop rarity boost',        16,  {'shopRarityBoost': 0.3}, TalentNodeSize.xs),
    ('in_reroll3', '\u{1F3B2}', 'Free Reroll III',    'Maximum free rerolls',                     '+1 free reroll/slot',           22,  {'extraFreeRerolls': 1}, TalentNodeSize.xs),
    ('in_luck3',   '\u2728',    'Golden Touch',        'Greatly increased rare upgrade chance',    '+0.4 shop rarity boost',        32,  {'shopRarityBoost': 0.4}, TalentNodeSize.xs),
    ('in_cap',     '\u{1F396}\uFE0F', 'Market Veteran', 'Free upgrade at start + guaranteed rare', 'Starting upgrade (Rare+)',     50,  {'startingUpgrades': 1, 'guaranteedRareFirst': true}, TalentNodeSize.md),
  ];

  for (int i = 0; i < spineData.length; i++) {
    final d = spineData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.intelligence,
      parentId: i == 0 ? 'general_root' : spineData[i - 1].$1,
      effects: d.$7,
      size: d.$8,
    ));
  }

  // ── From spine #2 (in_luck1) — UP: Secret Informant ──
  const informantData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('in_tip_free1',  '\u{1F4AC}', 'Free Intel I',    'One tip on the house each day',            '+1 free tip/day',       3,  {'freeTipsPerDay': 1}),
    ('in_tip_free2',  '\u{1F4AC}', 'Free Intel II',   'Another free daily tip',                   '+1 free tip/day',       6,  {'freeTipsPerDay': 1}),
    ('in_tip_disc1',  '\u{1F4B2}', 'Discount I',      'Cheaper intel from your sources',          '-25% tip cost',         5,  {'tipCostReduction': 0.25}),
    ('in_tip_disc2',  '\u{1F4B2}', 'Discount II',     'Deep discounts on all tips',               '-50% tip cost total',   10, {'tipCostReduction': 0.25}),
    ('in_tip_exact',  '\u{1F50D}', 'Exact Intel',     'Tips reveal the precise percentage',       'Tips show exact %',     14, {'tipExactPercent': true}),
  ];
  for (int i = 0; i < informantData.length; i++) {
    final d = informantData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.intelligence,
      parentId: i == 0 ? 'in_luck1' : informantData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── From spine #2 (in_luck1) — DOWN: FintTok ──
  const fintokData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('in_ftk_acc1',  '\u{1F4F1}', 'Better Sources I',     'Influencers are slightly more reliable',    '+10% FintTok accuracy',     4,  {'fintokAccuracyBonus': 0.10}),
    ('in_ftk_acc2',  '\u{1F4F1}', 'Better Sources II',    'Even more trustworthy content',             '+10% FintTok accuracy',     8,  {'fintokAccuracyBonus': 0.10}),
    ('in_ftk_slot1', '\u{1F4E2}', 'Extra Influencer I',   'Room for one more voice in your feed',      '+1 active influencer',      6,  {'extraActiveInfluencers': 1}),
    ('in_ftk_slot2', '\u{1F4E2}', 'Extra Influencer II',  'An even bigger FintTok feed',               '+1 active influencer',     12,  {'extraActiveInfluencers': 1}),
    ('in_ftk_flag',  '\u{26A0}\uFE0F', 'Flag Bad Tips',   'Unreliable tips are marked with a warning', 'Flag bad tips',            16,  {'flagBadTips': true}),
  ];
  for (int i = 0; i < fintokData.length; i++) {
    final d = fintokData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.intelligence,
      parentId: i == 0 ? 'in_luck1' : fintokData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── From spine #5 (in_luck2) — UP: News & Events ──
  const newsData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('in_news1',    '\u{1F4F0}', 'Extra News I',      'More daily market news',                    '+1 news/day',               5,  {'extraNewsPerDay': 1}),
    ('in_news2',    '\u{1F4F0}', 'Extra News II',     'Even more market coverage',                 '+1 news/day',              10,  {'extraNewsPerDay': 1}),
    ('in_block1',   '\u{1F6AB}', 'Block Event',       'Cancel one negative event per run',         'Block 1 bad event/run',    14,  {'blockBadEvents': 1}),
    ('in_disinfo',  '\u{1F6E1}\uFE0F', 'Disinfo Shield', 'Immune to false news and market manipulation', 'Disinfo immunity',   22,  {'disinfoShield': true}),
  ];
  for (int i = 0; i < newsData.length; i++) {
    final d = newsData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.intelligence,
      parentId: i == 0 ? 'in_luck2' : newsData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  // ── From spine #5 (in_luck2) — DOWN: Advanced Informant ──
  const advInfoData = <(String id, String icon, String name, String desc, String effect, int cost, Map<String, dynamic> effects)>[
    ('in_tip_prec1', '\u{1F3AF}', 'Precision I',     'More accurate intel from your sources',     '+25% tip precision',      6,  {'tipPrecisionMultiplier': 0.25}),
    ('in_tip_prec2', '\u{1F3AF}', 'Precision II',    'Near-perfect market intelligence',          '+50% tip precision',     12,  {'tipPrecisionMultiplier': 0.25}),
    ('in_tip_free3', '\u{1F4AC}', 'Free Intel III',  'Maximum free daily intelligence',           '+1 free tip/day',        18,  {'freeTipsPerDay': 1}),
  ];
  for (int i = 0; i < advInfoData.length; i++) {
    final d = advInfoData[i];
    nodes.add(TalentNode(
      id: d.$1, icon: d.$2, name: d.$3, description: d.$4, effectText: d.$5, cost: d.$6,
      branch: TalentBranch.intelligence,
      parentId: i == 0 ? 'in_luck2' : advInfoData[i - 1].$1,
      effects: d.$7,
      size: TalentNodeSize.xxs,
    ));
  }

  return nodes;
}

List<TalentNode> _buildSectorFan() {
  final nodes = <TalentNode>[];

  // Sector hub is now a label only (not a purchasable node).
  // Each sector spoke: T1 → profit → shield → income → T2 → profit → shield → income → T3 → profit → shield → income → Capstone
  // All nodes are in-line along the spoke (no perpendicular branches).

  const tierCosts = [3, 8, 16];
  const bonusCosts = [2, 5, 10];

  for (final sectorId in _sectorIds) {
    final sName = _sectorNames[sectorId]!;
    final sIcon = _sectorIcons[sectorId]!;

    String prevId = 'sector_root';

    for (int t = 0; t < 3; t++) {
      final tier = t + 1;
      final tierId = '${sectorId}_t$tier';

      // Tier unlock node
      nodes.add(TalentNode(
        id: tierId,
        icon: t == 0 ? sIcon : (t == 1 ? '\u{1F4C8}' : '\u{1F31F}'),
        name: '$sName T$tier',
        description: t == 0
            ? 'Enter $sName sector'
            : 'Advance to Tier $tier in $sName',
        effectText: 'Unlock $sName Tier $tier',
        cost: tierCosts[t],
        branch: TalentBranch.sectors,
        parentId: prevId,
        effects: {'unlockSectorTier_$sectorId': tier},
        size: TalentNodeSize.xs,
        sectorId: sectorId,
      ));

      prevId = tierId;

      // 3 bonus nodes after each tier: profit, shield, income
      final profitPct = tier == 1 ? 5 : tier == 2 ? 8 : 12; // T1=5%, T2=8%, T3=12% → 25% total (50% w/ capstone)
      final lossPct = tier == 1 ? 2 : tier == 2 ? 3 : 5; // T1=2%, T2=3%, T3=5% → 10% total (20% w/ capstone)
      final incomeVal = tier == 1 ? 5 : tier == 2 ? 10 : 20; // T1=$5, T2=$10, T3=$20 → $35 total ($70 w/ capstone)

      // Profit bonus
      final profitId = '${sectorId}_t${tier}_profit';
      nodes.add(TalentNode(
        id: profitId,
        icon: '\u{1F4B0}',
        name: '$sName Profit $tier',
        description: 'Boost $sName profits',
        effectText: '+$profitPct% profit in $sName',
        cost: bonusCosts[t],
        branch: TalentBranch.sectors,
        parentId: prevId,
        effects: {'sectorProfitBonus_$sectorId': profitPct / 100},
        size: TalentNodeSize.xxs,
        sectorId: sectorId,
      ));
      prevId = profitId;

      // Shield bonus
      final shieldId = '${sectorId}_t${tier}_shield';
      nodes.add(TalentNode(
        id: shieldId,
        icon: '\u{1F6E1}\uFE0F',
        name: '$sName Shield $tier',
        description: 'Reduce $sName losses',
        effectText: '-$lossPct% loss in $sName',
        cost: bonusCosts[t],
        branch: TalentBranch.sectors,
        parentId: prevId,
        effects: {'sectorLossShield_$sectorId': lossPct / 100},
        size: TalentNodeSize.xxs,
        sectorId: sectorId,
      ));
      prevId = shieldId;

      // Income bonus
      final incomeId = '${sectorId}_t${tier}_income';
      nodes.add(TalentNode(
        id: incomeId,
        icon: '\u{1F4B5}',
        name: '$sName Income $tier',
        description: 'Passive income from $sName',
        effectText: '+\$$incomeVal/day from $sName',
        cost: bonusCosts[t],
        branch: TalentBranch.sectors,
        parentId: prevId,
        effects: {'sectorPassiveIncome_$sectorId': incomeVal.toDouble()},
        size: TalentNodeSize.xxs,
        sectorId: sectorId,
      ));
      prevId = incomeId;
    }

    // Capstone: 2x all sector bonuses (big node)
    nodes.add(TalentNode(
      id: '${sectorId}_cap',
      icon: '\u{1F48E}',
      name: '$sName Mastery',
      description: 'Ultimate $sName specialization',
      effectText: '2x all $sName bonuses',
      cost: 120,
      branch: TalentBranch.sectors,
      parentId: prevId,
      effects: {'sectorCapstone_$sectorId': true},
      size: TalentNodeSize.md,
      sectorId: sectorId,
    ));
  }

  return nodes;
}

// ─── Hub labels (non-interactive branch headers) ───

class BranchLabel {
  final String id;
  final String icon;
  final String name;
  final TalentBranch branch;

  const BranchLabel(this.id, this.icon, this.name, this.branch);
}

const List<BranchLabel> branchLabels = [
  BranchLabel('gen_hub', '\u2B50', 'General', TalentBranch.root),
  BranchLabel('sc_hub', '\u{1F310}', 'Sectors', TalentBranch.sectors),
  // General tree branch placeholders (empty for now)
  BranchLabel('gb_trader', '\u{1F4C8}', 'Trader', TalentBranch.trader),
  BranchLabel('gb_survival', '\u{1F6E1}\uFE0F', 'Survival', TalentBranch.survival),
  BranchLabel('gb_automation', '\u{1F916}', 'Automation', TalentBranch.automation),
  BranchLabel('gb_intelligence', '\u{1F9E0}', 'Intelligence', TalentBranch.intelligence),
];

/// Labels at the tip of each sector spoke.
final List<BranchLabel> sectorSpokeLabels = [
  for (final id in _sectorIds)
    BranchLabel('sl_$id', _sectorIcons[id]!, _sectorNames[id]!, TalentBranch.sectors),
];

// ─── Public API ───

/// All talent tree nodes (built once, immutable).
final List<TalentNode> allTalentNodes = _buildAllNodes();

/// Lookup by ID (O(1) via map).
final Map<String, TalentNode> _nodeMap = {
  for (final n in allTalentNodes) n.id: n,
};

TalentNode? getTalentNodeById(String id) => _nodeMap[id];

/// Get all children of a given parent.
List<TalentNode> getChildNodes(String parentId) =>
    allTalentNodes.where((n) => n.parentId == parentId).toList();

/// Check if a node can be unlocked (parent is purchased, or no parent for root).
bool isNodeUnlockable(String nodeId, Set<String> purchased) {
  final node = _nodeMap[nodeId];
  if (node == null) return false;
  if (node.parentId == null) return true; // root
  return purchased.contains(node.parentId);
}

/// Get all nodes that are purchasable (parent bought, not yet purchased).
List<TalentNode> getAvailableTalentNodes(Set<String> purchased) =>
    allTalentNodes
        .where((n) => !purchased.contains(n.id) && isNodeUnlockable(n.id, purchased))
        .toList();

import '../core/big_number.dart';

const _robotNames = ['Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon'];
const _maxTradeHistory = 10;

class RobotTrade {
  final String companyName;
  final String companyTicker;
  final BigNumber amount;
  final bool isWin;
  final int day;

  const RobotTrade({
    required this.companyName,
    required this.companyTicker,
    required this.amount,
    required this.isWin,
    required this.day,
  });

  Map<String, dynamic> toJson() => {
    'companyName': companyName,
    'companyTicker': companyTicker,
    'amount': amount.toJson(),
    'isWin': isWin,
    'day': day,
  };

  factory RobotTrade.fromJson(Map<String, dynamic> json) => RobotTrade(
    companyName: json['companyName'] as String? ?? '',
    companyTicker: json['companyTicker'] as String? ?? '',
    amount: json['amount'] != null
        ? BigNumber.fromJson(json['amount'] as Map<String, dynamic>)
        : BigNumber.zero,
    isWin: json['isWin'] as bool? ?? true,
    day: json['day'] as int? ?? 0,
  );
}

class RobotTrader {
  final String id;
  final String name;
  BigNumber budget;
  BigNumber wallet;
  int precisionLevel;
  int efficiencyLevel;
  int frequencyLevel;
  int riskMgmtLevel;
  int capacityLevel;
  List<RobotTrade> tradeHistory;
  int tradesCompletedToday;

  RobotTrader({
    required this.id,
    required this.name,
    BigNumber? budget,
    BigNumber? wallet,
    this.precisionLevel = 0,
    this.efficiencyLevel = 0,
    this.frequencyLevel = 0,
    this.riskMgmtLevel = 0,
    this.capacityLevel = 0,
    List<RobotTrade>? tradeHistory,
    this.tradesCompletedToday = 0,
  })  : budget = budget ?? BigNumber.zero,
        wallet = wallet ?? BigNumber.zero,
        tradeHistory = tradeHistory ?? [];

  factory RobotTrader.create(String id, int index) {
    final name = index < _robotNames.length
        ? 'Bot-${_robotNames[index]}'
        : 'Bot-${index + 1}';
    return RobotTrader(id: id, name: name);
  }

  // === Computed stats ===

  bool get isActive => budget > BigNumber.zero;

  /// 45% at level 0 → 80% at level 9
  double get precisionPercent => 0.45 + (precisionLevel * 0.0389);

  /// 0.5% at level 0 → 3% at level 9
  double get efficiencyPercent => 0.005 + (efficiencyLevel * 0.00278);

  /// 1 trade/day at level 0 → 10 trades/day at level 9
  int get tradesPerDay => frequencyLevel + 1;

  /// 0% at level 0 → 70% at level 9
  double get lossReductionPercent => riskMgmtLevel * 0.0778;

  /// Safe accessor for capacityLevel (guards against hot-reload null on pre-existing instances).
  /// Uses dynamic cast to bypass Dart null safety type checks at runtime.
  int get safeCapacityLevel {
    final dynamic val = capacityLevel;
    if (val == null || val is! int) return 0;
    return val;
  }

  /// Budget multiplier: $100 base * 2^capacityLevel (no max level)
  /// Lv0=$100, Lv1=$200, Lv2=$400, Lv3=$800, Lv5=$3200, Lv10=$102K
  double get capacityMultiplier => 100.0 * (1 << safeCapacityLevel.clamp(0, 30));

  /// Add a trade to history, keeping only the last N entries
  void addTrade(RobotTrade trade) {
    tradeHistory.add(trade);
    if (tradeHistory.length > _maxTradeHistory) {
      tradeHistory.removeAt(0);
    }
  }

  // === Serialization ===

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'budget': budget.toJson(),
        'wallet': wallet.toJson(),
        'precisionLevel': precisionLevel,
        'efficiencyLevel': efficiencyLevel,
        'frequencyLevel': frequencyLevel,
        'riskMgmtLevel': riskMgmtLevel,
        'capacityLevel': safeCapacityLevel,
        'tradeHistory': tradeHistory.map((t) => t.toJson()).toList(),
        'tradesCompletedToday': tradesCompletedToday,
      };

  factory RobotTrader.fromJson(Map<String, dynamic> json) {
    return RobotTrader(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Bot',
      budget: json['budget'] != null
          ? BigNumber.fromJson(json['budget'] as Map<String, dynamic>)
          : BigNumber.zero,
      wallet: json['wallet'] != null
          ? BigNumber.fromJson(json['wallet'] as Map<String, dynamic>)
          : BigNumber.zero,
      precisionLevel: json['precisionLevel'] as int? ?? 0,
      efficiencyLevel: json['efficiencyLevel'] as int? ?? 0,
      frequencyLevel: json['frequencyLevel'] as int? ?? 0,
      riskMgmtLevel: json['riskMgmtLevel'] as int? ?? 0,
      capacityLevel: json['capacityLevel'] as int? ?? 0,
      tradeHistory: (json['tradeHistory'] as List<dynamic>?)
          ?.map((e) => RobotTrade.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      tradesCompletedToday: json['tradesCompletedToday'] as int? ?? 0,
    );
  }
}

import '../core/core.dart';

/// Represents a trading bot type
class BotData {
  final String id;
  final String name;
  final String icon;
  final String description;
  final BotType type;
  final bool unlockedByDefault;
  final int requiredPrestigeLevel;
  final double unlockCost;
  final double dailyOperatingCost;
  final double actionIntervalMinutes;
  final double maxTradePercent;
  
  // DCA specific
  final double dcaAmount;
  
  // Grid specific
  final double gridRangePercent;
  final int gridLevels;
  
  // Momentum specific
  final double momentumThreshold;
  
  // Dip buyer specific
  final double dipThresholdPercent;
  
  // Performance
  final double baseEfficiency;
  final double riskLevel;

  const BotData({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.type,
    this.unlockedByDefault = false,
    this.requiredPrestigeLevel = 0,
    this.unlockCost = 0,
    this.dailyOperatingCost = 0,
    this.actionIntervalMinutes = 60,
    this.maxTradePercent = 10,
    this.dcaAmount = 100,
    this.gridRangePercent = 10,
    this.gridLevels = 5,
    this.momentumThreshold = 2,
    this.dipThresholdPercent = 5,
    this.baseEfficiency = 1.0,
    this.riskLevel = 0.5,
  });

  BigNumber get unlockCostBN => BigNumber(unlockCost);
  BigNumber get dailyOperatingCostBN => BigNumber(dailyOperatingCost);
  BigNumber get dcaAmountBN => BigNumber(dcaAmount);

  String getStatusText(bool isRunning, String? targetTicker) {
    if (!isRunning) return 'Inactive';
    
    String stockInfo = targetTicker ?? 'No target';
    
    switch (type) {
      case BotType.dca:
        return 'Running - \$${dcaAmount.toStringAsFixed(0)}/interval on $stockInfo';
      case BotType.gridTrader:
        return 'Running - ${gridRangePercent.toStringAsFixed(0)}% range on $stockInfo';
      case BotType.momentumTrader:
        return 'Running - Tracking $stockInfo';
      case BotType.dipBuyer:
        return 'Running - Watching $stockInfo for ${dipThresholdPercent.toStringAsFixed(0)}% dip';
      case BotType.scalper:
        return 'Running - Scalping $stockInfo';
      case BotType.holder:
        return 'Holding $stockInfo';
    }
  }
}

import '../core/core.dart';
import 'company_data.dart';

/// A pending limit order that executes when price reaches a target.
/// Only 1 active order at a time (unlocked via Trader talent tree).
class LimitOrder {
  final String id;
  final CompanyData company;
  final double shares;
  final BigNumber targetPrice;
  final bool isBuyOrder; // true = buy when price <= target, false = sell when price >= target
  final double? stopLossPercent; // Auto-set SL after execution (if unlocked)
  final double? takeProfitPercent; // Auto-set TP after execution (if unlocked)
  final BigNumber reservedCash; // Cash locked for buy orders
  final int dayCreated;

  LimitOrder({
    required this.id,
    required this.company,
    required this.shares,
    required this.targetPrice,
    required this.isBuyOrder,
    this.stopLossPercent,
    this.takeProfitPercent,
    required this.reservedCash,
    required this.dayCreated,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'companyId': company.id,
    'shares': shares,
    'targetPrice': targetPrice.toDouble(),
    'isBuyOrder': isBuyOrder,
    'stopLossPercent': stopLossPercent,
    'takeProfitPercent': takeProfitPercent,
    'reservedCash': reservedCash.toDouble(),
    'dayCreated': dayCreated,
  };
}

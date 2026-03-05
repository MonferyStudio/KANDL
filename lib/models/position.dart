import '../core/core.dart';
import 'company_data.dart';

/// Represents a player's position in a stock
class Position {
  final CompanyData company;
  final PositionType type;
  double shares;
  BigNumber averageCost;
  BigNumber totalInvested;
  BigNumber totalFeesPaid;
  List<Trade> trades = [];

  Position({
    required this.company,
    this.type = PositionType.long,
  })  : shares = 0,
        averageCost = BigNumber.zero,
        totalInvested = BigNumber.zero,
        totalFeesPaid = BigNumber.zero;

  BigNumber currentValue(BigNumber currentPrice) {
    if (type == PositionType.long) {
      return currentPrice.multiplyByDouble(shares);
    } else {
      // Short: value = (2 * entryPrice - currentPrice) * shares
      // This represents the value we'd get back when covering
      return averageCost.multiplyByDouble(shares * 2) -
          currentPrice.multiplyByDouble(shares);
    }
  }

  BigNumber unrealizedPnL(BigNumber currentPrice) {
    if (type == PositionType.long) {
      return currentValue(currentPrice) - totalInvested - totalFeesPaid;
    } else {
      // Short P&L: (entryPrice - currentPrice) * shares - fees
      return (averageCost - currentPrice).multiplyByDouble(shares) - totalFeesPaid;
    }
  }

  double unrealizedPnLPercent(BigNumber currentPrice) {
    final totalCost = totalInvested + totalFeesPaid;
    if (totalCost.isZero) return 0;
    return totalCost.percentageChange(currentValue(currentPrice));
  }

  void buy(double sharesToBuy, BigNumber pricePerShare, BigNumber totalCost, {BigNumber? fees}) {
    // Calculate new average cost
    BigNumber existingValue = averageCost.multiplyByDouble(shares);
    BigNumber newValue = existingValue + totalCost;
    double newShares = shares + sharesToBuy;

    if (newShares > 0) {
      averageCost = newValue.divideByDouble(newShares);
    }

    shares = newShares;
    totalInvested = totalInvested + totalCost;
    if (fees != null) totalFeesPaid = totalFeesPaid + fees;

    trades.add(Trade(
      type: OrderType.marketBuy,
      shares: sharesToBuy,
      pricePerShare: pricePerShare,
      totalValue: totalCost,
      realizedPnL: BigNumber.zero,
      timestamp: DateTime.now(),
    ));
  }

  BigNumber sell(double sharesToSell, BigNumber pricePerShare, {BigNumber? exitFees}) {
    if (sharesToSell > shares) sharesToSell = shares;

    BigNumber saleValue = pricePerShare.multiplyByDouble(sharesToSell);
    BigNumber costBasis = averageCost.multiplyByDouble(sharesToSell);
    // Proportional entry fees for sold shares
    final proportion = shares > 0 ? sharesToSell / shares : 1.0;
    BigNumber entryFeesForSold = totalFeesPaid.multiplyByDouble(proportion);
    BigNumber realizedPnL = saleValue - costBasis - entryFeesForSold - (exitFees ?? BigNumber.zero);

    shares -= sharesToSell;

    if (shares > 0) {
      totalInvested = averageCost.multiplyByDouble(shares);
      totalFeesPaid = totalFeesPaid - entryFeesForSold;
    } else {
      totalInvested = BigNumber.zero;
      averageCost = BigNumber.zero;
      totalFeesPaid = BigNumber.zero;
    }

    trades.add(Trade(
      type: OrderType.marketSell,
      shares: sharesToSell,
      pricePerShare: pricePerShare,
      totalValue: saleValue,
      realizedPnL: realizedPnL,
      timestamp: DateTime.now(),
    ));

    return realizedPnL;
  }

  void short(double sharesToShort, BigNumber pricePerShare, BigNumber totalProceeds, {BigNumber? fees}) {
    // Calculate new average cost for short positions
    BigNumber existingValue = averageCost.multiplyByDouble(shares);
    BigNumber newValue = existingValue + totalProceeds;
    double newShares = shares + sharesToShort;

    if (newShares > 0) {
      averageCost = newValue.divideByDouble(newShares);
    }

    shares = newShares;
    totalInvested = totalInvested + totalProceeds;
    if (fees != null) totalFeesPaid = totalFeesPaid + fees;

    trades.add(Trade(
      type: OrderType.marketShort,
      shares: sharesToShort,
      pricePerShare: pricePerShare,
      totalValue: totalProceeds,
      realizedPnL: BigNumber.zero,
      timestamp: DateTime.now(),
    ));
  }

  BigNumber cover(double sharesToCover, BigNumber pricePerShare, {BigNumber? exitFees}) {
    if (sharesToCover > shares) sharesToCover = shares;

    BigNumber coverCost = pricePerShare.multiplyByDouble(sharesToCover);
    BigNumber entryProceeds = averageCost.multiplyByDouble(sharesToCover);
    // Proportional entry fees for covered shares
    final proportion = shares > 0 ? sharesToCover / shares : 1.0;
    BigNumber entryFeesForCovered = totalFeesPaid.multiplyByDouble(proportion);
    BigNumber realizedPnL = entryProceeds - coverCost - entryFeesForCovered - (exitFees ?? BigNumber.zero);

    shares -= sharesToCover;

    if (shares > 0) {
      totalInvested = averageCost.multiplyByDouble(shares);
      totalFeesPaid = totalFeesPaid - entryFeesForCovered;
    } else {
      totalInvested = BigNumber.zero;
      averageCost = BigNumber.zero;
      totalFeesPaid = BigNumber.zero;
    }

    trades.add(Trade(
      type: OrderType.marketCover,
      shares: sharesToCover,
      pricePerShare: pricePerShare,
      totalValue: coverCost,
      realizedPnL: realizedPnL,
      timestamp: DateTime.now(),
    ));

    return realizedPnL;
  }

  bool get hasShares => shares > 0;

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'companyId': company.id,
        'type': type.index,
        'shares': shares,
        'averageCost': averageCost.toJson(),
        'totalInvested': totalInvested.toJson(),
        'totalFeesPaid': totalFeesPaid.toJson(),
      };
}

class Trade {
  final OrderType type;
  final double shares;
  final BigNumber pricePerShare;
  final BigNumber totalValue;
  final BigNumber realizedPnL;
  final DateTime timestamp;

  Trade({
    required this.type,
    required this.shares,
    required this.pricePerShare,
    required this.totalValue,
    required this.realizedPnL,
    required this.timestamp,
  });

  bool get isBuy => type == OrderType.marketBuy || type == OrderType.limitBuy;
  bool get isSell => type == OrderType.marketSell || type == OrderType.limitSell;
  bool get isShort => type == OrderType.marketShort;
  bool get isCover => type == OrderType.marketCover;

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'shares': shares,
        'pricePerShare': pricePerShare.toJson(),
        'totalValue': totalValue.toJson(),
        'realizedPnL': realizedPnL.toJson(),
        'timestamp': timestamp.toIso8601String(),
      };
}

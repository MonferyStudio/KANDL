import '../core/core.dart';
import 'company_data.dart';

enum TradeType {
  buy,      // Open long position
  sell,     // Close long position
  short,    // Open short position
  cover,    // Close short position
}

/// Record of a completed trade
class TradeRecord {
  final String id;
  final CompanyData company;
  final TradeType type;
  final double shares;
  final BigNumber pricePerShare;
  final BigNumber totalValue;
  final BigNumber fees;
  final BigNumber? realizedPnL; // null for opening trades
  final DateTime timestamp;
  final int dayNumber;
  final double bonusShares; // Free bonus shares from meta progression

  const TradeRecord({
    required this.id,
    required this.company,
    required this.type,
    required this.shares,
    required this.pricePerShare,
    required this.totalValue,
    required this.fees,
    this.realizedPnL,
    required this.timestamp,
    required this.dayNumber,
    this.bonusShares = 0,
  });

  /// Whether this trade included bonus shares
  bool get hasBonusShares => bonusShares > 0;

  bool get isOpening => type == TradeType.buy || type == TradeType.short;
  bool get isClosing => type == TradeType.sell || type == TradeType.cover;

  String get typeLabel {
    switch (type) {
      case TradeType.buy:
        return 'BUY';
      case TradeType.sell:
        return 'SELL';
      case TradeType.short:
        return 'SHORT';
      case TradeType.cover:
        return 'COVER';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  /// Get color for the trade type
  bool get isBullish => type == TradeType.buy || type == TradeType.cover;

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'companyId': company.id,
        'type': type.index,
        'shares': shares,
        'pricePerShare': pricePerShare.toJson(),
        'totalValue': totalValue.toJson(),
        'fees': fees.toJson(),
        'realizedPnL': realizedPnL?.toJson(),
        'timestamp': timestamp.toIso8601String(),
        'dayNumber': dayNumber,
        'bonusShares': bonusShares,
      };
}

import 'dart:math' as math;
import 'big_number.dart';

/// Formats BigNumber values with appropriate suffixes (K, M, B, T, etc.)
class NumberFormatter {
  static const List<(int, String)> _suffixes = [
    (0, ''),
    (3, 'K'),
    (6, 'M'),
    (9, 'B'),
    (12, 'T'),
    (15, 'Qa'),
    (18, 'Qi'),
    (21, 'Sx'),
    (24, 'Sp'),
    (27, 'Oc'),
    (30, 'No'),
    (33, 'Dc'),
    (36, 'UDc'),
    (39, 'DDc'),
    (42, 'TDc'),
    (45, 'QaDc'),
    (48, 'QiDc'),
  ];

  /// Format a BigNumber with automatic suffix
  static String format(
    BigNumber value, {
    int decimals = 2,
    bool showSign = false,
    String currencySymbol = '\$',
  }) {
    if (value.isZero) {
      return '${currencySymbol}0';
    }

    bool negative = value.isNegative;
    BigNumber absValue = negative ? -value : value;

    // Below 100K: show full number with commas
    final absDouble = absValue.toDouble();
    if (absDouble < 100000) {
      String sign = '';
      if (negative) {
        sign = '-';
      } else if (showSign && !value.isZero) {
        sign = '+';
      }
      String formatted = absDouble.toStringAsFixed(decimals);
      // Trim unnecessary zeros
      if (decimals > 0 && formatted.contains('.')) {
        formatted = formatted.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      }
      // Add thousand separators
      final parts = formatted.split('.');
      parts[0] = parts[0].replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
      formatted = parts.join('.');
      return '$sign$currencySymbol$formatted';
    }

    // Find appropriate suffix (K starts at 100K, not 1K)
    int suffixIndex = 0;
    for (int i = _suffixes.length - 1; i >= 0; i--) {
      if (absValue.exponent >= _suffixes[i].$1) {
        suffixIndex = i;
        break;
      }
    }

    final (targetExp, suffix) = _suffixes[suffixIndex];
    double displayValue =
        absValue.mantissa * math.pow(10, absValue.exponent - targetExp);

    // Format string
    String sign = '';
    if (negative) {
      sign = '-';
    } else if (showSign && !value.isZero) {
      sign = '+';
    }

    String formatted = displayValue.toStringAsFixed(decimals);

    // Trim unnecessary zeros
    if (decimals > 0 && formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }

    return '$sign$currencySymbol$formatted$suffix';
  }

  /// Format without currency symbol
  static String formatPlain(
    BigNumber value, {
    int decimals = 2,
    bool showSign = false,
  }) {
    return format(value, decimals: decimals, showSign: showSign, currencySymbol: '');
  }

  /// Format as percentage
  static String formatPercent(
    double percent, {
    int decimals = 1,
    bool showSign = true,
  }) {
    String sign = '';
    if (percent > 0 && showSign) {
      sign = '+';
    } else if (percent < 0) {
      sign = '-';
    }

    return '$sign${percent.abs().toStringAsFixed(decimals)}%';
  }

  /// Format percentage change between two BigNumbers
  static String formatPercentChange(
    BigNumber from,
    BigNumber to, {
    int decimals = 1,
  }) {
    double percent = from.percentageChange(to);
    return formatPercent(percent, decimals: decimals);
  }

  /// Format for compact display
  static String formatCompact(BigNumber value) {
    return format(value, decimals: 1, currencySymbol: '');
  }

  /// Format volume
  static String formatVolume(BigNumber volume) {
    return format(volume, decimals: 1, currencySymbol: '');
  }

  /// Format price (always show 2 decimals)
  static String formatPrice(BigNumber price) {
    return format(price, decimals: 2);
  }

  /// Format market cap
  static String formatMarketCap(BigNumber marketCap) {
    return format(marketCap, decimals: 1);
  }

  /// Format P/E ratio
  static String formatPE(double pe) {
    if (pe <= 0) return 'N/A';
    return pe.toStringAsFixed(1);
  }

  /// Format time remaining (seconds to HH:MM:SS or MM:SS)
  static String formatTime(double seconds) {
    if (seconds < 0) seconds = 0;

    int hours = (seconds / 3600).floor();
    int minutes = ((seconds % 3600) / 60).floor();
    int secs = (seconds % 60).floor();

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Format day count
  static String formatDays(int days) {
    if (days == 1) return '1 day';
    return '$days days';
  }
}

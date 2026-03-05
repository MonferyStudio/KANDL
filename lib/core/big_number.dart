import 'dart:math' as math;
import 'number_formatter.dart';

/// Represents large numbers using mantissa and exponent (scientific notation).
/// Value = mantissa × 10^exponent
/// Example: 1,500,000,000 = 1.5 × 10^9
class BigNumber implements Comparable<BigNumber> {
  final double mantissa;
  final int exponent;

  static final BigNumber zero = BigNumber._(0, 0);
  static final BigNumber one = BigNumber._(1, 0);

  const BigNumber._(this.mantissa, this.exponent);

  factory BigNumber(double value) {
    if (value == 0) return zero;

    bool negative = value < 0;
    value = value.abs();

    int exp = (math.log(value) / math.ln10).floor();
    double mant = value / math.pow(10, exp);

    if (negative) mant = -mant;

    return BigNumber._normalize(mant, exp);
  }

  factory BigNumber.fromComponents(double mantissa, int exponent) {
    return BigNumber._normalize(mantissa, exponent);
  }

  static BigNumber _normalize(double mantissa, int exponent) {
    if (mantissa == 0) return zero;

    bool negative = mantissa < 0;
    double absMantissa = mantissa.abs();

    while (absMantissa >= 10) {
      absMantissa /= 10;
      exponent++;
    }

    while (absMantissa < 1 && absMantissa > 0) {
      absMantissa *= 10;
      exponent--;
    }

    return BigNumber._(negative ? -absMantissa : absMantissa, exponent);
  }

  double toDouble() {
    return mantissa * math.pow(10, exponent);
  }

  bool get isZero => mantissa == 0;
  bool get isNegative => mantissa < 0;
  bool get isPositive => mantissa > 0;

  // Arithmetic operators
  BigNumber operator +(BigNumber other) {
    if (isZero) return other;
    if (other.isZero) return this;

    int maxExp = math.max(exponent, other.exponent);
    double aAligned = mantissa * math.pow(10, exponent - maxExp);
    double bAligned = other.mantissa * math.pow(10, other.exponent - maxExp);

    return BigNumber.fromComponents(aAligned + bAligned, maxExp);
  }

  BigNumber operator -(BigNumber other) {
    return this + BigNumber._(-other.mantissa, other.exponent);
  }

  BigNumber operator *(BigNumber other) {
    return BigNumber.fromComponents(
      mantissa * other.mantissa,
      exponent + other.exponent,
    );
  }

  BigNumber operator /(BigNumber other) {
    if (other.isZero) throw ArgumentError('Division by zero');
    return BigNumber.fromComponents(
      mantissa / other.mantissa,
      exponent - other.exponent,
    );
  }

  BigNumber operator -() {
    return BigNumber._(-mantissa, exponent);
  }

  // Scalar operations
  BigNumber multiplyByDouble(double value) {
    return this * BigNumber(value);
  }

  BigNumber divideByDouble(double value) {
    return this / BigNumber(value);
  }

  // Comparison
  @override
  int compareTo(BigNumber other) {
    if (isZero && other.isZero) return 0;
    if (isZero) return other.isNegative ? 1 : -1;
    if (other.isZero) return isNegative ? -1 : 1;

    if (isNegative && !other.isNegative) return -1;
    if (!isNegative && other.isNegative) return 1;

    int expCompare = exponent.compareTo(other.exponent);
    if (expCompare != 0) {
      return isNegative ? -expCompare : expCompare;
    }

    return mantissa.compareTo(other.mantissa);
  }

  bool operator <(BigNumber other) => compareTo(other) < 0;
  bool operator >(BigNumber other) => compareTo(other) > 0;
  bool operator <=(BigNumber other) => compareTo(other) <= 0;
  bool operator >=(BigNumber other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) {
    if (other is! BigNumber) return false;
    return compareTo(other) == 0;
  }

  @override
  int get hashCode => Object.hash(mantissa, exponent);

  // Utility methods
  double percentageChange(BigNumber to) {
    if (isZero) return 0;
    BigNumber diff = to - this;
    return (diff / this).toDouble() * 100;
  }

  BigNumber applyPercent(double percent) {
    return this * BigNumber(1 + percent / 100);
  }

  @override
  String toString() {
    return NumberFormatter.format(this);
  }

  String toRawString() {
    return '${mantissa}e$exponent';
  }

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'mantissa': mantissa,
        'exponent': exponent,
      };

  factory BigNumber.fromJson(Map<String, dynamic> json) {
    return BigNumber.fromComponents(
      (json['mantissa'] as num).toDouble(),
      json['exponent'] as int,
    );
  }
}

/// Extension for easy BigNumber creation from num
extension NumToBigNumber on num {
  BigNumber get bn => BigNumber(toDouble());
}

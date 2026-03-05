import 'dart:math';
import 'package:flutter/material.dart';
import '../core/core.dart';

/// Represents a market event
class EventData {
  final String id;
  final String title;
  final String description;
  final String icon;
  final EventType type;
  final EventImpact impact;
  final List<String> affectedSectorIds;
  final List<String> affectedCompanyIds;
  final double priceImpactPercent;
  final double impactVariance;
  final int durationDays;
  final double volatilityMultiplier;
  final bool isRepeatable;
  final int cooldownDays;
  final double baseChancePercent;
  final List<String> tags;
  final Color color;

  const EventData({
    required this.id,
    required this.title,
    required this.description,
    this.icon = '📰',
    required this.type,
    required this.impact,
    this.affectedSectorIds = const [],
    this.affectedCompanyIds = const [],
    this.priceImpactPercent = 0.0,
    this.impactVariance = 5.0,
    this.durationDays = 1,
    this.volatilityMultiplier = 1.5,
    this.isRepeatable = true,
    this.cooldownDays = 7,
    this.baseChancePercent = 5.0,
    this.tags = const [],
    this.color = Colors.yellow,
  });

  bool get isMarketWide => affectedSectorIds.isEmpty && affectedCompanyIds.isEmpty;
  bool get isSectorWide => affectedSectorIds.isNotEmpty && affectedCompanyIds.isEmpty;
  bool get isCompanySpecific => affectedCompanyIds.isNotEmpty;

  double getRandomImpact() {
    final random = Random();
    double variance = (random.nextDouble() * 2 - 1) * impactVariance;
    return priceImpactPercent + variance;
  }

  String get impactDescription {
    switch (impact) {
      case EventImpact.veryPositive:
        return 'Very Bullish';
      case EventImpact.positive:
        return 'Bullish';
      case EventImpact.neutral:
        return 'Neutral';
      case EventImpact.negative:
        return 'Bearish';
      case EventImpact.veryNegative:
        return 'Very Bearish';
      case EventImpact.volatile:
        return 'High Volatility';
    }
  }
}

import 'package:flutter/material.dart';
import '../core/core.dart';

/// Represents a market sector (Technology, Healthcare, etc.)
class SectorData {
  final String id;
  final String name;
  final String icon;
  final String description;
  final SectorType type;
  final RegionType region;
  final double volatilityMultiplier;
  final double marketCorrelation;
  final double fedSensitivity;
  final double economicSensitivity;
  final List<String> tags;
  final Color color;

  const SectorData({
    required this.id,
    required this.name,
    required this.icon,
    this.description = '',
    required this.type,
    this.region = RegionType.us,
    this.volatilityMultiplier = 1.0,
    this.marketCorrelation = 1.0,
    this.fedSensitivity = 1.0,
    this.economicSensitivity = 1.0,
    this.tags = const [],
    this.color = Colors.white,
  });

  String get displayName => name;
  String get iconWithName => '$icon $name';
}

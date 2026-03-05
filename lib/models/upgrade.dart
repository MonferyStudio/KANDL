import 'package:flutter/material.dart';
import '../core/core.dart';

/// Represents an upgrade that can be offered to the player
class Upgrade {
  final String id;
  final String name;
  final String description;
  final String icon;
  final UpgradeCategory category;
  final UpgradeRarity rarity;
  final Map<String, dynamic> effects;
  final List<String> prerequisites;
  final bool isRepeatable;

  /// Template type for sector-specific upgrades (e.g., 'sector_shield', 'sector_edge')
  /// Used for replacement logic: same templateType + same sector = replaceable
  final String? templateType;

  /// Assigned sector for sector-specific upgrades (null for static upgrades)
  final SectorType? sector;

  const Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.rarity,
    required this.effects,
    this.prerequisites = const [],
    this.isRepeatable = false,
    this.templateType,
    this.sector,
  });

  /// Whether this is a template upgrade (has templateType for replacement logic)
  bool get isTemplate => templateType != null;

  /// Whether this template needs a sector assignment (sector_shield, sector_edge, etc.)
  bool get isSectorSpecific => templateType != null && templateType!.startsWith('sector_');

  /// Create a copy with a specific sector assigned
  Upgrade withSector(SectorType assignedSector) => Upgrade(
    id: id,
    name: name,
    description: description,
    icon: icon,
    category: category,
    rarity: rarity,
    effects: effects,
    prerequisites: prerequisites,
    isRepeatable: isRepeatable,
    templateType: templateType,
    sector: assignedSector,
  );

  /// Get color based on rarity
  Color get rarityColor {
    switch (rarity) {
      case UpgradeRarity.common:
        return const Color(0xFF9CA3AF); // Gray
      case UpgradeRarity.uncommon:
        return const Color(0xFF22C55E); // Green
      case UpgradeRarity.rare:
        return const Color(0xFF3B82F6); // Blue
      case UpgradeRarity.epic:
        return const Color(0xFFA855F7); // Purple
      case UpgradeRarity.legendary:
        return const Color(0xFFFBBF24); // Gold
    }
  }

  /// Get rarity label
  String get rarityLabel {
    switch (rarity) {
      case UpgradeRarity.common:
        return 'COMMON';
      case UpgradeRarity.uncommon:
        return 'UNCOMMON';
      case UpgradeRarity.rare:
        return 'RARE';
      case UpgradeRarity.epic:
        return 'EPIC';
      case UpgradeRarity.legendary:
        return 'LEGENDARY';
    }
  }

  /// Get weight for random selection (higher = more likely)
  double get selectionWeight {
    switch (rarity) {
      case UpgradeRarity.common:
        return 50.0;
      case UpgradeRarity.uncommon:
        return 30.0;
      case UpgradeRarity.rare:
        return 12.0;
      case UpgradeRarity.epic:
        return 5.0;
      case UpgradeRarity.legendary:
        return 1.0;
    }
  }

  /// Get cost based on rarity (used for reroll pricing reference)
  double get cost {
    switch (rarity) {
      case UpgradeRarity.common:
        return 25.0;
      case UpgradeRarity.uncommon:
        return 50.0;
      case UpgradeRarity.rare:
        return 100.0;
      case UpgradeRarity.epic:
        return 250.0;
      case UpgradeRarity.legendary:
        return 500.0;
    }
  }

  /// Rarity index for comparison (higher = better)
  int get rarityIndex => UpgradeRarity.values.indexOf(rarity);
}

/// Player's acquired upgrade instance
class AcquiredUpgrade {
  final String upgradeId;
  final int dayAcquired;
  final int yearAcquired;
  int stackCount;

  /// Template type for sector upgrades (mirrors Upgrade.templateType)
  final String? templateType;

  /// Assigned sector for sector upgrades
  final SectorType? sector;

  /// Rarity at time of acquisition (for replacement comparison)
  final UpgradeRarity? rarity;

  AcquiredUpgrade({
    required this.upgradeId,
    required this.dayAcquired,
    required this.yearAcquired,
    this.stackCount = 1,
    this.templateType,
    this.sector,
    this.rarity,
  });

  Map<String, dynamic> toJson() => {
        'upgradeId': upgradeId,
        'dayAcquired': dayAcquired,
        'yearAcquired': yearAcquired,
        'stackCount': stackCount,
        if (templateType != null) 'templateType': templateType,
        if (sector != null) 'sector': sector!.index,
        if (rarity != null) 'rarity': rarity!.index,
      };

  factory AcquiredUpgrade.fromJson(Map<String, dynamic> json) {
    return AcquiredUpgrade(
      upgradeId: json['upgradeId'],
      dayAcquired: json['dayAcquired'] ?? 1,
      yearAcquired: json['yearAcquired'] ?? 1,
      stackCount: json['stackCount'] ?? 1,
      templateType: json['templateType'],
      sector: json['sector'] != null
          ? SectorType.values[json['sector'] as int]
          : null,
      rarity: json['rarity'] != null
          ? UpgradeRarity.values[json['rarity'] as int]
          : null,
    );
  }
}

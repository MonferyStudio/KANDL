import '../core/enums.dart';

/// A single node in the prestige talent tree (v2).
/// Replaces the flat PrestigeUpgrade system.
class TalentNode {
  final String id;
  final String icon;
  final String name;
  final String description;
  final String effectText;
  final int cost;
  final TalentBranch branch;
  final String? parentId;
  final Map<String, dynamic> effects;
  final TalentNodeSize size;
  final bool isBadge;
  final String? sectorId;

  const TalentNode({
    required this.id,
    required this.icon,
    required this.name,
    required this.description,
    required this.effectText,
    required this.cost,
    required this.branch,
    this.parentId,
    required this.effects,
    this.size = TalentNodeSize.sm,
    this.isBadge = false,
    this.sectorId,
  });
}

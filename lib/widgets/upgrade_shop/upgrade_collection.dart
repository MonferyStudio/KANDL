import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../data/upgrades.dart';
import '../../l10n/app_localizations.dart';
import '../../models/upgrade.dart';
import '../../services/game_service.dart';
import '../../theme/app_themes.dart';

/// Dialog showing all upgrades in the game, with acquired ones highlighted.
class UpgradeCollection extends StatelessWidget {
  const UpgradeCollection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);

    return Consumer<GameService>(
      builder: (context, game, _) {
        final acquired = game.acquiredUpgrades;
        final acquiredIds = acquired.map((a) => a.upgradeId).toSet();

        // Group upgrades by category
        final categories = <UpgradeCategory, List<Upgrade>>{};
        for (final upgrade in allStaticUpgrades) {
          categories.putIfAbsent(upgrade.category, () => []).add(upgrade);
        }

        // Compute accurate total & discovered counts
        // Sector templates: each (type × sector × rarity) is a cell in the grid
        final sectorTemplateLists = [sectorShieldTemplates, sectorEdgeTemplates, sectorInsightTemplates, sectorDominanceTemplates];
        final sectorCells = sectorTemplateLists.length * SectorType.values.length * UpgradeRarity.values.length;
        final totalCount = allStaticUpgrades.length + sectorCells + incomeTemplates.length + winningStreakTemplates.length;

        int discoveredCount = 0;
        // Static upgrades
        discoveredCount += allStaticUpgrades.where((u) => acquiredIds.contains(u.id)).length;
        // Sector templates: count lit cells (all rarities up to owned)
        for (final templates in sectorTemplateLists) {
          final templateType = templates.first.templateType;
          for (final sector in SectorType.values) {
            int highestIndex = -1;
            for (final acq in acquired) {
              if (acq.templateType == templateType && acq.sector == sector && acq.rarity != null) {
                if (acq.rarity!.index > highestIndex) highestIndex = acq.rarity!.index;
              }
            }
            if (highestIndex >= 0) discoveredCount += highestIndex + 1;
          }
        }
        // Global templates
        discoveredCount += incomeTemplates.where((t) => acquiredIds.contains(t.id)).length;
        discoveredCount += winningStreakTemplates.where((t) => acquiredIds.contains(t.id)).length;

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: theme.card,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_mosaic, color: theme.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.collection.toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.textPrimary,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.discovered(discoveredCount, totalCount),
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: theme.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Static upgrades by category
                      for (final category in UpgradeCategory.values) ...[
                        if (categories.containsKey(category)) ...[
                          _CategorySection(
                            category: category,
                            upgrades: categories[category]!,
                            acquiredIds: acquiredIds,
                            acquired: acquired,
                            theme: theme,
                            l10n: l10n,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],

                      // Template upgrades section
                      _TemplateSectionHeader(
                        title: l10n.sectorShields,
                        icon: '\u{1F6E1}\u{FE0F}',
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      _TemplateGrid(
                        templates: sectorShieldTemplates,
                        acquired: acquired,
                        theme: theme,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 20),

                      _TemplateSectionHeader(
                        title: l10n.sectorEdges,
                        icon: '\u{1F4C8}',
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      _TemplateGrid(
                        templates: sectorEdgeTemplates,
                        acquired: acquired,
                        theme: theme,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 20),

                      _TemplateSectionHeader(
                        title: l10n.categoryName('income'),
                        icon: '\u{1F4B5}',
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      _IncomeGrid(
                        templates: incomeTemplates,
                        acquiredIds: acquiredIds,
                        theme: theme,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 20),

                      _TemplateSectionHeader(
                        title: l10n.sectorInsights,
                        icon: '\u{1F52E}',
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      _TemplateGrid(
                        templates: sectorInsightTemplates,
                        acquired: acquired,
                        theme: theme,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 20),

                      _TemplateSectionHeader(
                        title: l10n.sectorDominances,
                        icon: '\u{1F451}',
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      _TemplateGrid(
                        templates: sectorDominanceTemplates,
                        acquired: acquired,
                        theme: theme,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 20),

                      _TemplateSectionHeader(
                        title: l10n.winningStreaks,
                        icon: '\u{1F525}',
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      _IncomeGrid(
                        templates: winningStreakTemplates,
                        acquiredIds: acquiredIds,
                        theme: theme,
                        l10n: l10n,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Section header for a category of static upgrades
class _CategorySection extends StatelessWidget {
  final UpgradeCategory category;
  final List<Upgrade> upgrades;
  final Set<String> acquiredIds;
  final List<AcquiredUpgrade> acquired;
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _CategorySection({
    required this.category,
    required this.upgrades,
    required this.acquiredIds,
    required this.acquired,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final owned = upgrades.where((u) => acquiredIds.contains(u.id)).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.categoryName(category.name),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$owned/${upgrades.length}',
              style: TextStyle(
                fontSize: 11,
                color: theme.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: upgrades.map((upgrade) {
            final isOwned = acquiredIds.contains(upgrade.id);
            final acq = acquired.where((a) => a.upgradeId == upgrade.id).firstOrNull;
            final stackCount = acq?.stackCount ?? 0;
            return _CollectionCard(
              upgrade: upgrade,
              isOwned: isOwned,
              stackCount: upgrade.isRepeatable ? stackCount : 0,
              theme: theme,
              l10n: l10n,
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Individual upgrade card in the collection
class _CollectionCard extends StatefulWidget {
  final Upgrade upgrade;
  final bool isOwned;
  final int stackCount;
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _CollectionCard({
    required this.upgrade,
    required this.isOwned,
    required this.stackCount,
    required this.theme,
    required this.l10n,
  });

  @override
  State<_CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<_CollectionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final upgrade = widget.upgrade;
    final rarityColor = upgrade.rarityColor;
    final isOwned = widget.isOwned;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: '${widget.l10n.upgradeName(upgrade.id)}\n${widget.l10n.upgradeDescription(upgrade.id)}',
        waitDuration: const Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 90,
          height: 100,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isOwned
                ? rarityColor.withValues(alpha: 0.08)
                : theme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isOwned
                  ? (_isHovered ? rarityColor : rarityColor.withValues(alpha: 0.4))
                  : theme.border.withValues(alpha: 0.3),
              width: isOwned ? 2 : 1,
            ),
            boxShadow: isOwned && _isHovered
                ? [BoxShadow(color: rarityColor.withValues(alpha: 0.2), blurRadius: 8)]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Text(
                isOwned ? upgrade.icon : '?',
                style: TextStyle(
                  fontSize: isOwned ? 24 : 20,
                  color: isOwned ? null : theme.textMuted.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 4),
              // Name
              Text(
                isOwned
                    ? widget.l10n.upgradeName(upgrade.id)
                    : '???',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isOwned ? theme.textPrimary : theme.textMuted.withValues(alpha: 0.4),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Stack count for repeatable
              if (widget.stackCount > 1)
                Text(
                  'x${widget.stackCount}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: rarityColor,
                  ),
                ),
              // Rarity dot
              const SizedBox(height: 2),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOwned ? rarityColor : theme.textMuted.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section header for template upgrade groups
class _TemplateSectionHeader extends StatelessWidget {
  final String title;
  final String icon;
  final AppThemeData theme;

  const _TemplateSectionHeader({
    required this.title,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: theme.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

/// Grid showing sector template upgrades with sector x rarity matrix
class _TemplateGrid extends StatelessWidget {
  final List<Upgrade> templates;
  final List<AcquiredUpgrade> acquired;
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _TemplateGrid({
    required this.templates,
    required this.acquired,
    required this.theme,
    required this.l10n,
  });

  Color _rarityColor(UpgradeRarity rarity) {
    switch (rarity) {
      case UpgradeRarity.common: return const Color(0xFF9CA3AF);
      case UpgradeRarity.uncommon: return const Color(0xFF22C55E);
      case UpgradeRarity.rare: return const Color(0xFF3B82F6);
      case UpgradeRarity.epic: return const Color(0xFFA855F7);
      case UpgradeRarity.legendary: return const Color(0xFFFBBF24);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Find which sectors have been acquired at which rarity
    final templateType = templates.first.templateType;
    final acquiredMap = <SectorType, UpgradeRarity>{};
    for (final acq in acquired) {
      if (acq.templateType == templateType && acq.sector != null && acq.rarity != null) {
        final existing = acquiredMap[acq.sector!];
        if (existing == null || acq.rarity!.index > existing.index) {
          acquiredMap[acq.sector!] = acq.rarity!;
        }
      }
    }

    final sectors = SectorType.values;
    final rarities = UpgradeRarity.values;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rarity header row
          Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  '',
                  style: TextStyle(fontSize: 8, color: theme.textMuted),
                ),
              ),
              for (final rarity in rarities)
                SizedBox(
                  width: 28,
                  child: Center(
                    child: Text(
                      rarity.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: _rarityColor(rarity),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          // Sector rows
          for (final sector in sectors)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      l10n.sectorTypeName(sector.name),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: theme.textMuted,
                      ),
                    ),
                  ),
                  for (final rarity in rarities)
                    _SectorRarityCell(
                      isAcquired: acquiredMap[sector] != null &&
                          acquiredMap[sector]!.index >= rarity.index,
                      isExactRarity: acquiredMap[sector] == rarity,
                      rarityColor: _rarityColor(rarity),
                      theme: theme,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Single cell in the sector x rarity matrix
class _SectorRarityCell extends StatelessWidget {
  final bool isAcquired;
  final bool isExactRarity;
  final Color rarityColor;
  final AppThemeData theme;

  const _SectorRarityCell({
    required this.isAcquired,
    required this.isExactRarity,
    required this.rarityColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isExactRarity
            ? rarityColor.withValues(alpha: 0.4)
            : (isAcquired
                ? rarityColor.withValues(alpha: 0.15)
                : theme.surface.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: isExactRarity
              ? rarityColor
              : (isAcquired
                  ? rarityColor.withValues(alpha: 0.3)
                  : theme.border.withValues(alpha: 0.15)),
          width: isExactRarity ? 1.5 : 0.5,
        ),
      ),
      child: isExactRarity
          ? Center(
              child: Icon(
                Icons.check,
                size: 10,
                color: rarityColor,
              ),
            )
          : null,
    );
  }
}

/// Grid for income template upgrades (no sector, just rarity tiers)
class _IncomeGrid extends StatelessWidget {
  final List<Upgrade> templates;
  final Set<String> acquiredIds;
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _IncomeGrid({
    required this.templates,
    required this.acquiredIds,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: templates.map((upgrade) {
        final isOwned = acquiredIds.contains(upgrade.id);
        final rarityColor = upgrade.rarityColor;

        return Tooltip(
          message: '${l10n.upgradeName(upgrade.id)}\n${l10n.upgradeDescription(upgrade.id)}',
          waitDuration: const Duration(milliseconds: 300),
          child: Container(
            width: 90,
            height: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isOwned
                  ? rarityColor.withValues(alpha: 0.08)
                  : theme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isOwned
                    ? rarityColor.withValues(alpha: 0.4)
                    : theme.border.withValues(alpha: 0.3),
                width: isOwned ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isOwned ? upgrade.icon : '?',
                  style: TextStyle(
                    fontSize: isOwned ? 24 : 20,
                    color: isOwned ? null : theme.textMuted.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOwned ? l10n.upgradeName(upgrade.id) : '???',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isOwned ? theme.textPrimary : theme.textMuted.withValues(alpha: 0.4),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOwned ? rarityColor : theme.textMuted.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Show the upgrade collection dialog
void showUpgradeCollectionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) {
      final theme = ctx.watchTheme;
      return Dialog(
        backgroundColor: theme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const SizedBox(
          width: 750,
          height: 600,
          child: UpgradeCollection(),
        ),
      );
    },
  );
}

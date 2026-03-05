import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import '../../services/sound_service.dart';
import '../../data/sectors.dart';
import '../../models/models.dart';
import '../effects/effects.dart';
import '../tutorial/tutorial_keys.dart';

enum SectorSortOption {
  performance,
  volatility,
  name,
  stockCount,
}

class SectorsView extends StatefulWidget {
  const SectorsView({super.key});

  @override
  State<SectorsView> createState() => _SectorsViewState();
}

class _SectorsViewState extends State<SectorsView> {
  SectorSortOption _sortOption = SectorSortOption.performance;
  bool _ascending = false;

  List<SectorData> _getSortedSectors(GameService game) {
    final sectors = List<SectorData>.from(allSectors);

    sectors.sort((a, b) {
      int comparison;
      switch (_sortOption) {
        case SectorSortOption.performance:
          final perfA = game.getSectorPerformance(a.id);
          final perfB = game.getSectorPerformance(b.id);
          comparison = perfA.compareTo(perfB);
          break;
        case SectorSortOption.volatility:
          comparison = a.volatilityMultiplier.compareTo(b.volatilityMultiplier);
          break;
        case SectorSortOption.name:
          comparison = a.name.compareTo(b.name);
          break;
        case SectorSortOption.stockCount:
          final countA = game.getStocksBySector(a.id).length;
          final countB = game.getStocksBySector(b.id).length;
          comparison = countA.compareTo(countB);
          break;
      }
      return _ascending ? comparison : -comparison;
    });

    return sectors;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;

    return Consumer<GameService>(
      builder: (context, game, _) {
        final sortedSectors = _getSortedSectors(game);

        final sortButton = GestureDetector(
          onTap: () {
            SoundService().playClick();
            setState(() => _ascending = !_ascending);
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.border),
            ),
            child: Icon(
              _ascending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: theme.primary,
            ),
          ),
        );

        final filterChips = [
          _FilterChip(
            label: l10n.performance,
            isSelected: _sortOption == SectorSortOption.performance,
            onTap: () => setState(() => _sortOption = SectorSortOption.performance),
          ),
          _FilterChip(
            label: l10n.volatility,
            isSelected: _sortOption == SectorSortOption.volatility,
            onTap: () => setState(() => _sortOption = SectorSortOption.volatility),
          ),
          _FilterChip(
            label: l10n.name,
            isSelected: _sortOption == SectorSortOption.name,
            onTap: () => setState(() => _sortOption = SectorSortOption.name),
          ),
          _FilterChip(
            label: l10n.stocks,
            isSelected: _sortOption == SectorSortOption.stockCount,
            onTap: () => setState(() => _sortOption = SectorSortOption.stockCount),
          ),
        ];

        return Column(
          children: [
            // Filter bar
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: theme.card,
                border: Border(
                  bottom: BorderSide(color: theme.border, width: 1),
                ),
              ),
              child: isMobile
                  ? Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Text(
                                  l10n.get('sort_by'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                ...filterChips.expand((chip) => [chip, const SizedBox(width: 4)]).toList()
                                  ..removeLast(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        sortButton,
                      ],
                    )
                  : Row(
                      children: [
                        Text(
                          l10n.get('sort_by'),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...filterChips.expand((chip) => [chip, const SizedBox(width: 6)]).toList()
                          ..removeLast(),
                        const Spacer(),
                        sortButton,
                      ],
                    ),
            ),

            // Grid
            Expanded(
              child: GridView.builder(
                // Add extra bottom padding on mobile for collapsed bottom sheet
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 6 : 8,
                  isMobile ? 6 : 8,
                  isMobile ? 6 : 8,
                  isMobile ? 86 : 8,
                ),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isMobile ? 160 : 200,
                  // Lower aspect ratio = more height. Tablet needs more space.
                  childAspectRatio: isMobile ? 0.95 : (context.isTablet ? 0.95 : 1.1),
                  crossAxisSpacing: isMobile ? 8 : 10,
                  mainAxisSpacing: isMobile ? 8 : 10,
                ),
                itemCount: sortedSectors.length,
                itemBuilder: (context, index) {
                  final sector = sortedSectors[index];
                  return _SectorCard(
                    key: index == 0 ? TutorialKeys.firstSectorCard : null,
                    sector: sector,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return GestureDetector(
      onTap: () {
        SoundService().playClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary.withValues(alpha: 0.2) : theme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? theme.primary : theme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? theme.primary : theme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SectorCard extends StatelessWidget {
  final SectorData sector;

  const _SectorCard({super.key, required this.sector});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final game = context.read<GameService>();
    final performance = game.getSectorPerformance(sector.id);
    final stocks = game.getStocksBySector(sector.id);
    final isPositive = performance >= 0;
    final isMobile = context.isMobile;

    final isTablet = context.isTablet;
    final iconSize = isMobile ? 28.0 : (isTablet ? 30.0 : 36.0);
    final cardPadding = isMobile ? 10.0 : (isTablet ? 10.0 : 14.0);

    return HoverCard(
      onTap: () => game.selectSector(sector.id),
      glowColor: isPositive ? theme.positive : theme.negative,
      glowIntensity: 0.25,
      liftAmount: isMobile ? 4.0 : 6.0,
      padding: EdgeInsets.all(cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(isMobile || isTablet ? 6 : 8),
                ),
                child: Center(
                  child: Text(
                    sector.icon,
                    style: TextStyle(fontSize: isMobile ? 14 : (isTablet ? 15 : 18)),
                  ),
                ),
              ),
              PercentChangePulse(
                percent: performance,
                style: TextStyle(
                  fontSize: isMobile || isTablet ? 10 : 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile || isTablet ? 4 : 10),

          // Name
          Text(
            l10n.sectorName(sector.id),
            style: TextStyle(
              fontSize: isMobile ? 12 : (isTablet ? 12 : 14),
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),

          // Meta
          Text(
            l10n.stocksCountRegion(stocks.length, sector.region.name.toUpperCase()),
            style: TextStyle(
              fontSize: isMobile || isTablet ? 9 : 10,
              color: theme.textMuted,
            ),
          ),

          const Spacer(),

          // Stats
          Container(
            padding: EdgeInsets.only(top: isMobile || isTablet ? 4 : 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.border, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  label: l10n.volatility,
                  value: '${(sector.volatilityMultiplier * 100).toStringAsFixed(0)}%',
                  isCompact: isMobile || isTablet,
                ),
                _StatItem(
                  label: l10n.get('avg_change'),
                  value: NumberFormatter.formatPercent(performance),
                  valueColor: isPositive ? theme.positive : theme.negative,
                  isCompact: isMobile || isTablet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isCompact;

  const _StatItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: isCompact ? 7 : 8,
            color: theme.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: isCompact ? 1 : 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isCompact ? 10 : 12,
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.textPrimary,
          ),
        ),
      ],
    );
  }
}

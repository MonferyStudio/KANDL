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

enum StockSortOption {
  performance,
  price,
  volatility,
  ticker,
  marketCap,
}

class StocksView extends StatefulWidget {
  const StocksView({super.key});

  @override
  State<StocksView> createState() => _StocksViewState();
}

class _StocksViewState extends State<StocksView> {
  StockSortOption _sortOption = StockSortOption.performance;
  bool _ascending = false;

  List<StockState> _getSortedStocks(GameService game) {
    final sectorId = game.selectedSectorId;
    List<StockState> stocks = sectorId != null
        ? game.getStocksBySector(sectorId)
        : game.getTopMovers(count: 50, gainers: true);

    stocks = List.from(stocks);

    stocks.sort((a, b) {
      int comparison;
      switch (_sortOption) {
        case StockSortOption.performance:
          comparison = a.dayChangePercent.compareTo(b.dayChangePercent);
          break;
        case StockSortOption.price:
          comparison = a.currentPrice.compareTo(b.currentPrice);
          break;
        case StockSortOption.volatility:
          comparison = a.company.volatility.compareTo(b.company.volatility);
          break;
        case StockSortOption.ticker:
          comparison = a.company.ticker.compareTo(b.company.ticker);
          break;
        case StockSortOption.marketCap:
          comparison = a.marketCap.compareTo(b.marketCap);
          break;
      }
      return _ascending ? comparison : -comparison;
    });

    return stocks;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return Consumer<GameService>(
      builder: (context, game, _) {
        final sectorId = game.selectedSectorId;
        final sector = sectorId != null ? getSectorById(sectorId) : null;
        final stocks = _getSortedStocks(game);
        final isMobile = context.isMobile;

        return Column(
          children: [
            // Header
            _StocksHeader(sector: sector),

            // Filter bar
            _FilterBar(
              sortOption: _sortOption,
              ascending: _ascending,
              onSortChanged: (option) => setState(() => _sortOption = option),
              onAscendingChanged: () => setState(() => _ascending = !_ascending),
            ),

            // Stocks List
            Expanded(
              child: ListView.separated(
                // Add bottom padding on mobile for collapsed bottom sheet
                padding: EdgeInsets.only(bottom: isMobile ? 80 : 0),
                itemCount: stocks.length,
                separatorBuilder: (_, __) => Divider(
                  color: theme.border,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  return _StockRow(
                    key: index == 0 ? TutorialKeys.firstStockRow : null,
                    state: stocks[index],
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

class _FilterBar extends StatelessWidget {
  final StockSortOption sortOption;
  final bool ascending;
  final ValueChanged<StockSortOption> onSortChanged;
  final VoidCallback onAscendingChanged;

  const _FilterBar({
    required this.sortOption,
    required this.ascending,
    required this.onSortChanged,
    required this.onAscendingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;

    final chips = [
      _FilterChip(
        label: l10n.change,
        isSelected: sortOption == StockSortOption.performance,
        onTap: () => onSortChanged(StockSortOption.performance),
      ),
      _FilterChip(
        label: l10n.price,
        isSelected: sortOption == StockSortOption.price,
        onTap: () => onSortChanged(StockSortOption.price),
      ),
      _FilterChip(
        label: l10n.volatility,
        isSelected: sortOption == StockSortOption.volatility,
        onTap: () => onSortChanged(StockSortOption.volatility),
      ),
      _FilterChip(
        label: l10n.ticker,
        isSelected: sortOption == StockSortOption.ticker,
        onTap: () => onSortChanged(StockSortOption.ticker),
      ),
      _FilterChip(
        label: l10n.marketCap,
        isSelected: sortOption == StockSortOption.marketCap,
        onTap: () => onSortChanged(StockSortOption.marketCap),
      ),
    ];

    final sortButton = GestureDetector(
      onTap: () {
        SoundService().playClick();
        onAscendingChanged();
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: theme.border),
        ),
        child: Icon(
          ascending ? Icons.arrow_upward : Icons.arrow_downward,
          size: 16,
          color: theme.primary,
        ),
      ),
    );

    return Container(
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
                          l10n.sortBy,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        ...chips.expand((chip) => [chip, const SizedBox(width: 4)]).toList()
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
                  l10n.sortBy,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                ...chips.expand((chip) => [chip, const SizedBox(width: 6)]).toList()
                  ..removeLast(),
                const Spacer(),
                sortButton,
              ],
            ),
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

class _StocksHeader extends StatelessWidget {
  final SectorData? sector;

  const _StocksHeader({this.sector});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final game = context.read<GameService>();
    final isMobile = context.isMobile;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 6 : 8,
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              SoundService().playClick();
              game.goBack();
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 12,
                vertical: isMobile ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.border),
              ),
              child: isMobile
                  ? Icon(Icons.arrow_back, size: 16, color: theme.textSecondary)
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: 16, color: theme.textSecondary),
                        const SizedBox(width: 4),
                        Text(l10n.back, style: TextStyle(color: theme.textSecondary)),
                      ],
                    ),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),

          // Title
          Expanded(
            child: Row(
              children: [
                if (sector != null) ...[
                  Text(sector!.icon, style: TextStyle(fontSize: isMobile ? 16 : 20)),
                  SizedBox(width: isMobile ? 6 : 8),
                ],
                Expanded(
                  child: Text(
                    sector != null ? l10n.sectorName(sector!.id) : l10n.get('all_stocks'),
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  final StockState state;

  const _StockRow({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final game = context.watch<GameService>();
    final company = state.company;
    final changePercent = state.dayChangePercent;
    final rawSignal = state.currentSignal;
    final seed = company.id.hashCode ^ game.currentDay;
    final StockSignal signal;
    if (rawSignal == StockSignal.none) {
      signal = StockSignal.none;
    } else if (game.signalJammerActive) {
      signal = StockSignal.scrambled(seed);
    } else if ((seed.abs() % 100) >= (game.analystPrecision * 100).toInt()) {
      signal = StockSignal.scrambled(seed ~/ 100);
    } else {
      signal = rawSignal;
    }
    final isMobile = context.isMobile;

    final logoSize = isMobile ? 32.0 : 40.0;

    final isSaleSignal = signal == StockSignal.onSale || signal == StockSignal.goodDeal;

    return _SaleGlowWrapper(
      isActive: isSaleSignal,
      color: theme.positive,
      child: HoverRow(
        onTap: () => game.selectCompany(company.id),
        hoverColor: theme.surface.withValues(alpha: 0.5),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12,
          vertical: isMobile ? 10 : 14,
        ),
        child: Row(
        children: [
          // Logo placeholder
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              color: theme.border,
              borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
            ),
            child: Center(
              child: Text(
                company.ticker.substring(0, 2),
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  fontWeight: FontWeight.bold,
                  color: theme.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),

          // Name & Ticker + Signal
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.name,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      company.ticker,
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 10,
                        color: theme.textSecondary,
                      ),
                    ),
                    if (signal != StockSignal.none) ...[
                      const SizedBox(width: 6),
                      _SignalBadge(signal: signal),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Price with pulse effect (hidden on mobile to save space)
          if (!isMobile)
            Expanded(
              child: PricePulse(
                price: state.currentPrice,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textPrimary,
                ),
              ),
            ),

          // Change with pulse effect
          SizedBox(width: isMobile ? 4 : 8),
          PercentChangePulse(
            percent: changePercent,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Trade button with hover effect (icon only on mobile)
          SizedBox(width: isMobile ? 6 : 8),
          HoverScale(
            scale: 1.08,
            onTap: () => game.selectCompany(company.id),
            child: Container(
              padding: isMobile
                  ? const EdgeInsets.all(6)
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: isMobile
                  ? Icon(
                      Icons.trending_up,
                      size: 16,
                      color: theme.background,
                    )
                  : Text(
                      l10n.get('trade'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.background,
                      ),
                    ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Animated glow wrapper for stocks on sale
class _SaleGlowWrapper extends StatefulWidget {
  final bool isActive;
  final Color color;
  final Widget child;

  const _SaleGlowWrapper({required this.isActive, required this.color, required this.child});

  @override
  State<_SaleGlowWrapper> createState() => _SaleGlowWrapperState();
}

class _SaleGlowWrapperState extends State<_SaleGlowWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return widget.child;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.color.withValues(alpha: _glowAnimation.value),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _glowAnimation.value * 0.3),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SignalBadge extends StatelessWidget {
  final StockSignal signal;

  const _SignalBadge({required this.signal});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);

    final (label, color, icon) = switch (signal) {
      StockSignal.onSale => (l10n.signalOnSale, theme.positive, Icons.local_offer),
      StockSignal.goodDeal => (l10n.signalGoodDeal, theme.positive, Icons.thumb_up_alt_outlined),
      StockSignal.rising => (l10n.signalRising, theme.positive, Icons.trending_up),
      StockSignal.falling => (l10n.signalFalling, theme.negative, Icons.trending_down),
      StockSignal.pricey => (l10n.signalPricey, theme.orange, Icons.warning_amber_outlined),
      StockSignal.overheated => (l10n.signalOverheated, theme.negative, Icons.local_fire_department),
      StockSignal.none => ('', theme.textMuted, Icons.remove),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

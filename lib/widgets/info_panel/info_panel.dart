import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import '../../services/settings_service.dart';
import '../../data/sectors.dart';
import '../../data/companies.dart';
import '../../models/models.dart';

class InfoPanel extends StatelessWidget {
  final bool isSheet;
  final ScrollController? scrollController;

  const InfoPanel({
    super.key,
    this.isSheet = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Consumer<GameService>(
      builder: (context, game, _) {
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSheet) _buildHeader(context, game),
            if (!isSheet) Divider(color: theme.border, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildContent(context, game),
            ),
          ],
        );

        // Sheet mode: no container decoration, use provided scroll controller
        if (isSheet) {
          return SingleChildScrollView(
            controller: scrollController,
            child: content,
          );
        }

        // Desktop mode: container with fixed width and decoration
        return Container(
          width: 300,
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border),
          ),
          child: SingleChildScrollView(
            child: content,
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, GameService game) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    String title = l10n.information;
    IconData icon = Icons.info_outline;

    switch (game.currentView) {
      case ViewType.dashboard:
        title = l10n.marketOverview;
        icon = Icons.dashboard_outlined;
        break;
      case ViewType.market:
        if (game.selectedSectorId != null) {
          final sector = getSectorById(game.selectedSectorId!);
          title = sector?.name ?? l10n.market;
        } else {
          title = l10n.market;
        }
        icon = Icons.store_outlined;
        break;
      case ViewType.trading:
        if (game.selectedCompanyId != null) {
          final company = getCompanyById(game.selectedCompanyId!);
          title = company?.name ?? l10n.companyInfo;
        }
        icon = Icons.trending_up_outlined;
        break;
      case ViewType.portfolio:
        title = l10n.portfolioAnalysis;
        icon = Icons.account_balance_wallet_outlined;
        break;
      case ViewType.robots:
        title = l10n.robotsBay;
        icon = Icons.smart_toy_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: theme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, GameService game) {
    switch (game.currentView) {
      case ViewType.dashboard:
        return _buildDashboardInfo(context, game);
      case ViewType.market:
        if (game.selectedSectorId != null) {
          return _buildStocksInfo(context, game);
        }
        return _buildSectorInfo(context, game);
      case ViewType.trading:
        return _buildTradingInfo(context, game);
      case ViewType.portfolio:
        return _buildPositionsInfo(context, game);
      case ViewType.robots:
        return _buildRobotsInfo(context, game);
    }
  }

  Widget _buildRobotsInfo(BuildContext context, GameService game) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final robots = game.robots;

    // Aggregate stats across all robots
    final allTrades = robots.expand((r) => r.tradeHistory).toList();
    final totalWallet = robots.fold<BigNumber>(BigNumber.zero, (s, r) => s + r.wallet);
    final totalBudget = robots.fold<BigNumber>(BigNumber.zero, (s, r) => s + r.budget);
    final wins = allTrades.where((t) => t.isWin).length;
    final winRate = allTrades.isEmpty ? 0.0 : wins / allTrades.length * 100;

    // Group trades by day → compute daily net P&L
    final dayMap = <int, BigNumber>{};
    for (final trade in allTrades) {
      final prev = dayMap[trade.day] ?? BigNumber.zero;
      dayMap[trade.day] = trade.isWin
          ? prev + trade.amount
          : prev - trade.amount;
    }
    final sortedDays = dayMap.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overview section
        _sectionTitle(context, l10n.get('robot_overview')),
        const SizedBox(height: 8),
        _infoRow(context, l10n.get('robot_total_budget'), NumberFormatter.formatCompact(totalBudget)),
        _infoRow(context, l10n.get('robot_total_wallet'), NumberFormatter.formatCompact(totalWallet)),
        _infoRow(context, l10n.get('robot_upgrade_costs'), NumberFormatter.formatCompact(game.totalRobotExpenses)),
        _infoRow(context, l10n.get('robot_total_trades'), '${allTrades.length}'),
        _infoRow(context, l10n.winRate, '${winRate.toStringAsFixed(0)}%'),
        const SizedBox(height: 16),

        // Daily P&L log
        _sectionTitle(context, l10n.get('robot_daily_log')),
        const SizedBox(height: 8),
        if (sortedDays.isEmpty)
          Text(
            l10n.get('robot_no_trades'),
            style: TextStyle(color: theme.textMuted, fontSize: 12),
          )
        else
          for (final day in sortedDays.take(15)) ...[
            _robotDayRow(context, day, dayMap[day]!),
          ],
      ],
    );
  }

  Widget _robotDayRow(BuildContext context, int day, BigNumber netPnL) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isPositive = netPnL.isPositive;
    final isZero = netPnL.isZero;
    final color = isZero ? theme.textMuted : (isPositive ? theme.positive : theme.negative);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isZero ? Icons.remove : (isPositive ? Icons.trending_up : Icons.trending_down),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            l10n.dayNumber(day),
            style: TextStyle(
              fontSize: 12,
              color: theme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '${isPositive ? '+' : ''}${NumberFormatter.formatCompact(netPnL)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardInfo(BuildContext context, GameService game) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final recentNews = game.recentNews.take(8).toList();
    final indicators = game.marketIndicators;
    final regime = game.marketRegime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMarketRegimeSection(context, regime),
        const SizedBox(height: 16),

        if (indicators != null) ...[
          _buildMarketIndicatorsSection(context, indicators),
          const SizedBox(height: 16),
        ],
        _sectionTitle(context, l10n.recentNews),
        const SizedBox(height: 8),
        if (recentNews.isEmpty)
          Text(
            l10n.noNewsYet,
            style: TextStyle(color: theme.textSecondary, fontSize: 12),
          )
        else
          ...recentNews.map((news) => _newsItem(context, news)),
      ],
    );
  }

  Widget _buildSectorInfo(BuildContext context, GameService game) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final regime = game.marketRegime;
    final indicators = game.marketIndicators;
    final recentNews = game.recentNews.take(5).toList();

    // Get sectors sorted by performance
    final sectorPerformances = allSectors.map((sector) {
      final perf = game.getSectorPerformance(sector.id);
      return MapEntry(sector, perf);
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMarketRegimeSection(context, regime),
        const SizedBox(height: 16),

        if (indicators != null) ...[
          _buildMarketIndicatorsSection(context, indicators),
          const SizedBox(height: 16),
        ],

        // Sector performance ranking — visual bars
        _sectionTitle(context, l10n.sectorLeaders),
        const SizedBox(height: 8),
        ...sectorPerformances.map((entry) {
          final sector = entry.key;
          final perf = entry.value;
          final isPositive = perf >= 0;
          final color = isPositive ? theme.positive : theme.negative;
          final maxAbs = sectorPerformances.map((e) => e.value.abs()).fold<double>(0.01, (a, b) => a > b ? a : b);
          final barRatio = (perf.abs() / maxAbs).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GestureDetector(
              onTap: () => game.selectSector(sector.id),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(sector.icon, style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 3,
                    child: Text(
                      l10n.sectorName(sector.id),
                      style: TextStyle(fontSize: 10, color: theme.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: SizedBox(
                        height: 6,
                        child: LinearProgressIndicator(
                          value: barRatio,
                          backgroundColor: theme.border,
                          valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.7)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '${isPositive ? '+' : ''}${perf.toStringAsFixed(1)}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 16),
        _sectionTitle(context, l10n.marketNews),
        const SizedBox(height: 8),
        if (recentNews.isEmpty)
          Text(
            l10n.noNewsYet,
            style: TextStyle(color: theme.textSecondary, fontSize: 12),
          )
        else
          ...recentNews.map((news) => _newsItem(context, news)),
      ],
    );
  }

  Widget _buildStocksInfo(BuildContext context, GameService game) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    if (game.selectedSectorId == null) {
      return Center(
        child: Text(
          l10n.selectSectorToSeeDetails,
          style: TextStyle(color: theme.textSecondary),
        ),
      );
    }

    final sector = getSectorById(game.selectedSectorId!);
    if (sector == null) return const SizedBox();

    final stocks = game.getStocksBySector(sector.id);
    final myPositions = game.positions.where((p) => p.company.sectorId == sector.id).toList();
    final sectorNews = game.getNewsBySector(sector.id).take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectorNews.isNotEmpty) ...[
          _sectionTitle(context, l10n.sectorNews),
          const SizedBox(height: 8),
          ...sectorNews.map((news) => _newsItem(context, news)),
          const SizedBox(height: 16),
        ],

        _sectionTitle(context, l10n.sectorOverview),
        const SizedBox(height: 8),
        _infoRow(context, l10n.name, l10n.sectorName(sector.id)),
        _infoRow(context, l10n.type, sector.type.toString().split('.').last),
        _infoRow(context, l10n.region, sector.region.toString().split('.').last.toUpperCase()),
        _infoRow(context, l10n.stocks, '${stocks.length}'),
        const SizedBox(height: 16),

        if (context.watch<SettingsService>().expertMode) ...[
          _sectionTitle(context, l10n.characteristics),
          const SizedBox(height: 8),
          _infoRow(context, l10n.volatility, '${(sector.volatilityMultiplier * 100).toStringAsFixed(0)}%'),
          _infoRow(context, l10n.marketCorrelation, '${(sector.marketCorrelation * 100).toStringAsFixed(0)}%'),
          _infoRow(context, l10n.fedSensitivity, '${(sector.fedSensitivity * 100).toStringAsFixed(0)}%'),
        ],

        if (myPositions.isNotEmpty) ...[
          const SizedBox(height: 16),
          _sectionTitle(context, l10n.yourHoldings),
          const SizedBox(height: 8),
          _infoRow(context, l10n.positions, myPositions.length.toString()),
          _infoRow(context, l10n.totalShares, myPositions.fold<double>(0, (sum, p) => sum + p.shares).toStringAsFixed(0)),
        ],
      ],
    );
  }

  Widget _buildTradingInfo(BuildContext context, GameService game) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    if (game.selectedCompanyId == null) {
      return Center(
        child: Text(
          l10n.selectStockToSeeDetails,
          style: TextStyle(color: theme.textSecondary),
        ),
      );
    }

    final company = getCompanyById(game.selectedCompanyId!);
    final state = game.getStockState(game.selectedCompanyId!);
    if (company == null || state == null) return const SizedBox();

    final sector = getSectorById(company.sectorId);
    final position = game.positions.where((p) => p.company.id == company.id).firstOrNull;
    final companyNews = game.getNewsByCompany(company.id).take(3).toList();
    final expertMode = context.watch<SettingsService>().expertMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (companyNews.isNotEmpty) ...[
          _sectionTitle(context, l10n.recentNews),
          const SizedBox(height: 8),
          ...companyNews.map((news) => _newsItem(context, news)),
          const SizedBox(height: 16),
        ],

        Row(
          children: [
            Expanded(child: _sectionTitle(context, l10n.companyInfo)),
            GestureDetector(
              onTap: () => game.toggleFavorite(company.id),
              child: Icon(
                game.isFavorite(company.id) ? Icons.star : Icons.star_border,
                color: game.isFavorite(company.id) ? theme.yellow : theme.textMuted,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _infoRow(context, l10n.ticker, company.ticker),
        _infoRow(context, l10n.sector, sector?.name ?? l10n.unknown),
        if (expertMode) ...[
          _infoRowWithTooltip(context, l10n.marketCap, NumberFormatter.formatMarketCap(state.marketCap), l10n.get('tooltip_market_cap')),
          _infoRowWithTooltip(context, l10n.peRatio, NumberFormatter.formatPE(company.peRatio), l10n.get('tooltip_pe_ratio')),
        ],

        if (expertMode) ...[
          const SizedBox(height: 16),
          _sectionTitle(context, l10n.tradingStats),
          const SizedBox(height: 8),
          _infoRow(context, l10n.dayOpen, NumberFormatter.formatPrice(state.dayOpen)),
          _infoRow(context, l10n.dayHigh, NumberFormatter.formatPrice(state.dayHigh)),
          _infoRow(context, l10n.dayLow, NumberFormatter.formatPrice(state.dayLow)),
          _infoRow(context, l10n.volume, NumberFormatter.formatVolume(state.volume)),
        ],

        const SizedBox(height: 16),
        _sectionTitle(context, l10n.analystRatings),
        const SizedBox(height: 8),
        _buildAnalystSection(context, game, state),

        if (expertMode) ...[
          const SizedBox(height: 16),
          _sectionTitle(context, l10n.technicalAnalysis),
          const SizedBox(height: 8),
          _buildTechnicalSection(context, state),
        ],

        if (expertMode) ...[
          const SizedBox(height: 16),
          _sectionTitle(context, l10n.historicalPerformance),
          const SizedBox(height: 8),
          _buildPerformanceSection(context, state, game),
        ],

        if (expertMode) ...[
          const SizedBox(height: 16),
          _sectionTitle(context, l10n.weekRange52),
          const SizedBox(height: 8),
          _infoRow(context, l10n.high, NumberFormatter.formatPrice(state.fiftyTwoWeekHigh)),
          _infoRow(context, l10n.low, NumberFormatter.formatPrice(state.fiftyTwoWeekLow)),
          _infoRow(context, l10n.fromHigh, '${state.distanceFrom52WeekHigh.toStringAsFixed(1)}%'),
          _infoRow(context, l10n.fromLow, '+${state.distanceFrom52WeekLow.toStringAsFixed(1)}%'),
        ],

        if (expertMode) ...[
          const SizedBox(height: 16),
          _sectionTitle(context, l10n.characteristics),
          const SizedBox(height: 8),
          _infoRow(context, l10n.volatility, '${(company.volatility * 100).toStringAsFixed(0)}%'),
          _infoRow(context, l10n.blueChip, company.isBlueChip ? l10n.yes : l10n.no),
          _infoRow(context, l10n.pennyStock, company.isPennyStock ? l10n.yes : l10n.no),
        ],

        if (position != null) ...[
          const SizedBox(height: 16),
          _sectionTitle(context, l10n.yourPosition),
          const SizedBox(height: 8),
          _infoRow(context, l10n.type, position.type == PositionType.long ? l10n.long.toUpperCase() : l10n.short.toUpperCase()),
          _infoRow(context, l10n.shares, position.shares.toStringAsFixed(0)),
          _infoRow(context, l10n.avgCostLabel, NumberFormatter.formatPrice(position.averageCost)),
          _infoRow(context, l10n.marketValue, NumberFormatter.format(position.currentValue(state.currentPrice))),
          _infoRow(context, l10n.pnl, NumberFormatter.format(position.unrealizedPnL(state.currentPrice), showSign: true)),
        ],
      ],
    );
  }

  Widget _buildPositionsInfo(BuildContext context, GameService game) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final positions = game.positions;
    final longPositionsList = game.longPositions;
    final shortPositionsList = game.shortPositions;
    final recentTrades = game.recentTrades.take(8).toList();
    final breakdown = game.portfolioBreakdown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, l10n.recentActivity),
        const SizedBox(height: 8),
        if (recentTrades.isEmpty)
          Text(
            l10n.noTradesYet,
            style: TextStyle(color: theme.textSecondary, fontSize: 12),
          )
        else
          ...recentTrades.map((trade) => _tradeItem(context, trade)),

        const SizedBox(height: 16),
        _sectionTitle(context, l10n.portfolioSummary),
        const SizedBox(height: 8),
        // Visual positions bar
        _buildPositionsBar(context, game, positions.length, game.maxPositions,
            longPositionsList.length, shortPositionsList.length),

        const SizedBox(height: 16),
        _sectionTitle(context, l10n.performance),
        const SizedBox(height: 8),
        _infoRow(context, l10n.portfolioValueLabel, NumberFormatter.format(game.portfolioValue)),
        _infoRow(context, l10n.unrealizedPnL, NumberFormatter.format(game.unrealizedPnL, showSign: true)),
        _infoRow(context, l10n.realizedPnL, NumberFormatter.format(game.totalRealizedPnL, showSign: true)),

        if (context.watch<SettingsService>().expertMode) ...[
          const SizedBox(height: 16),
          _sectionTitle(context, l10n.tradingStats),
          const SizedBox(height: 8),
          _infoRow(context, l10n.totalTrades, '${game.totalTrades}'),
          _infoRow(context, l10n.winRate, '${(game.winRate * 100).toStringAsFixed(1)}%'),

          if (positions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionTitle(context, l10n.bestPerformer),
            const SizedBox(height: 8),
            ...() {
              final sorted = [...positions];
              sorted.sort((a, b) {
                final aState = game.getStockState(a.company.id);
                final bState = game.getStockState(b.company.id);
                if (aState == null || bState == null) return 0;
                final aPnL = a.unrealizedPnL(aState.currentPrice);
                final bPnL = b.unrealizedPnL(bState.currentPrice);
                return bPnL.compareTo(aPnL);
              });
              if (sorted.isEmpty) return <Widget>[];
              final best = sorted.first;
              final bestState = game.getStockState(best.company.id);
              if (bestState == null) return <Widget>[];
              return [
                _infoRow(context, l10n.stock, best.company.ticker),
                _infoRow(context, l10n.pnl, NumberFormatter.format(best.unrealizedPnL(bestState.currentPrice), showSign: true)),
              ];
            }(),
          ],

          if (breakdown != null) ...[
            const SizedBox(height: 16),
            _buildPortfolioBreakdownSection(context, breakdown),
          ],
        ],
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final theme = context.watchTheme;
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: theme.textPrimary,
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final theme = context.watchTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionsBar(BuildContext context, GameService game,
      int current, int max, int longCount, int shortCount) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isFull = current >= max;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Count + long/short breakdown
          Row(
            children: [
              Icon(Icons.view_column_outlined,
                  size: 14, color: isFull ? theme.orange : theme.textSecondary),
              const SizedBox(width: 5),
              Text(
                '$current/$max',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isFull ? theme.orange : theme.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              if (longCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.positive.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '${longCount}L',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: theme.positive,
                    ),
                  ),
                ),
              if (longCount > 0 && shortCount > 0) const SizedBox(width: 4),
              if (shortCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.negative.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '${shortCount}S',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: theme.negative,
                    ),
                  ),
                ),
              const Spacer(),
              if (isFull)
                Text(
                  l10n.positionsFull,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: theme.orange,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          // Slot bar
          Row(
            children: List.generate(max, (i) {
              final filled = i < current;
              final isLong = i < longCount;
              final color = filled
                  ? (isLong ? theme.positive : theme.negative)
                  : theme.border;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: i < max - 1 ? 2 : 0),
                  decoration: BoxDecoration(
                    color: filled ? color.withValues(alpha: 0.8) : color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _infoRowWithTooltip(BuildContext context, String label, String value, String tooltip) {
    final theme = context.watchTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 12, color: theme.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: tooltip,
                  child: Icon(Icons.help_outline, size: 12, color: theme.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalystSection(BuildContext context, GameService game, StockState state) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final expertMode = context.watch<SettingsService>().expertMode;
    final analystData = game.getAnalystData(state.company.id);
    if (analystData == null) {
      return Text(
        l10n.noAnalystData,
        style: TextStyle(color: theme.textSecondary, fontSize: 12),
      );
    }

    Color ratingColor;
    IconData ratingIcon;
    switch (analystData.consensusRating) {
      case AnalystRating.strongBuy:
        ratingColor = theme.positive;
        ratingIcon = Icons.rocket_launch;
        break;
      case AnalystRating.buy:
        ratingColor = theme.positive;
        ratingIcon = Icons.thumb_up;
        break;
      case AnalystRating.sell:
        ratingColor = theme.negative;
        ratingIcon = Icons.thumb_down;
        break;
      case AnalystRating.strongSell:
        ratingColor = theme.negative;
        ratingIcon = Icons.warning_amber;
        break;
      case AnalystRating.hold:
        ratingColor = theme.yellow;
        ratingIcon = Icons.pause_circle_outline;
        break;
    }

    final upsideVal = analystData.getUpsidePotential(state.currentPrice.toDouble());

    // Localized consensus label
    String ratingLabel;
    switch (analystData.consensusRating) {
      case AnalystRating.strongBuy:
        ratingLabel = l10n.get('strong_buy');
        break;
      case AnalystRating.buy:
        ratingLabel = l10n.buy;
        break;
      case AnalystRating.sell:
        ratingLabel = l10n.sell;
        break;
      case AnalystRating.strongSell:
        ratingLabel = l10n.get('strong_sell');
        break;
      case AnalystRating.hold:
        ratingLabel = l10n.hold;
        break;
    }
    final upsideColor = upsideVal >= 0 ? theme.positive : theme.negative;
    final total = analystData.totalRatings;
    final buyPct = total > 0 ? analystData.buyRatings / total : 0.0;
    final holdPct = total > 0 ? analystData.holdRatings / total : 0.0;
    final sellPct = total > 0 ? analystData.sellRatings / total : 0.0;

    // Price target range bar
    final currentPrice = state.currentPrice.toDouble();
    final ptLow = analystData.priceTargetLow;
    final ptHigh = analystData.priceTargetHigh;
    final ptAvg = analystData.priceTargetAverage;
    final rangeMin = (ptLow < currentPrice ? ptLow : currentPrice) * 0.95;
    final rangeMax = (ptHigh > currentPrice ? ptHigh : currentPrice) * 1.05;
    final rangeSpan = rangeMax - rangeMin;
    final currentPosRatio = rangeSpan > 0 ? ((currentPrice - rangeMin) / rangeSpan).clamp(0.0, 1.0) : 0.5;
    final targetPosRatio = rangeSpan > 0 ? ((ptAvg - rangeMin) / rangeSpan).clamp(0.0, 1.0) : 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Big consensus badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: ratingColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ratingColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(ratingIcon, color: ratingColor, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ratingLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ratingColor,
                      ),
                    ),
                    Text(
                      '${analystData.totalRatings} ${l10n.get('analysts').toLowerCase()}',
                      style: TextStyle(fontSize: 11, color: theme.textMuted),
                    ),
                  ],
                ),
              ),
              // Upside chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: upsideColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${upsideVal >= 0 ? '+' : ''}${upsideVal.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: upsideColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Buy / Hold / Sell visual bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                if (buyPct > 0) Expanded(flex: (buyPct * 100).round().clamp(1, 100), child: Container(color: theme.positive)),
                if (holdPct > 0) Expanded(flex: (holdPct * 100).round().clamp(1, 100), child: Container(color: theme.yellow)),
                if (sellPct > 0) Expanded(flex: (sellPct * 100).round().clamp(1, 100), child: Container(color: theme.negative)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Labels under bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${l10n.buy} ${(buyPct * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.positive),
            ),
            Text(
              '${l10n.hold} ${(holdPct * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.yellow),
            ),
            Text(
              '${l10n.sell} ${(sellPct * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.negative),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Price target range bar
        Text(
          l10n.priceTarget,
          style: TextStyle(fontSize: 11, color: theme.textMuted),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 32,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final currentX = currentPosRatio * width;
              final targetX = targetPosRatio * width;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Range bar background
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  // Colored range between current and target
                  Positioned(
                    top: 12,
                    left: currentX < targetX ? currentX : targetX,
                    width: (targetX - currentX).abs().clamp(2.0, width),
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: upsideColor.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  // Current price marker
                  Positioned(
                    left: currentX - 5,
                    top: 8,
                    child: Container(
                      width: 10,
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.textPrimary,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: theme.background, width: 1),
                      ),
                    ),
                  ),
                  // Target marker
                  Positioned(
                    left: targetX - 4,
                    top: 9,
                    child: Icon(Icons.flag, size: 12, color: upsideColor),
                  ),
                ],
              );
            },
          ),
        ),
        // Low / Target / High labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              NumberFormatter.formatPrice(BigNumber(ptLow)),
              style: TextStyle(fontSize: 9, color: theme.textMuted),
            ),
            Text(
              NumberFormatter.formatPrice(BigNumber(ptAvg)),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: upsideColor),
            ),
            Text(
              NumberFormatter.formatPrice(BigNumber(ptHigh)),
              style: TextStyle(fontSize: 9, color: theme.textMuted),
            ),
          ],
        ),

        // Expert-only detailed rows
        if (expertMode) ...[
          const SizedBox(height: 8),
          _infoRow(context, l10n.buy, '${analystData.buyRatings}'),
          _infoRow(context, l10n.hold, '${analystData.holdRatings}'),
          _infoRow(context, l10n.sell, '${analystData.sellRatings}'),
          _infoRow(context, l10n.ptHigh, NumberFormatter.formatPrice(BigNumber(analystData.priceTargetHigh))),
          _infoRow(context, l10n.ptLow, NumberFormatter.formatPrice(BigNumber(analystData.priceTargetLow))),
        ],
      ],
    );
  }

  Widget _buildSignalBanner(BuildContext context, StockSignal signal) {
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalSection(BuildContext context, StockState state) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final game = context.read<GameService>();
    final rawSignal = state.currentSignal;
    final seed = state.company.id.hashCode ^ game.currentDay;
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
    final rsi = state.rsi;
    Color rsiColor;
    String rsiLabel;

    if (rsi < 30) {
      rsiColor = theme.positive;
      rsiLabel = l10n.oversold;
    } else if (rsi > 70) {
      rsiColor = theme.negative;
      rsiLabel = l10n.overbought;
    } else {
      rsiColor = theme.textSecondary;
      rsiLabel = l10n.neutral;
    }

    final volRatio = state.volumeRatio;
    final volumeColor = volRatio > 1.5
        ? theme.positive
        : volRatio < 0.5
            ? theme.negative
            : theme.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Signal banner
        if (signal != StockSignal.none) ...[
          _buildSignalBanner(context, signal),
          const SizedBox(height: 10),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.rsi14,
              style: TextStyle(fontSize: 12, color: theme.textSecondary),
            ),
            Row(
              children: [
                Text(
                  rsi.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: rsiColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    rsiLabel,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: rsiColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        _infoRow(context, l10n.ma50, NumberFormatter.formatPrice(state.ma50)),
        _infoRow(context, l10n.ma200, NumberFormatter.formatPrice(state.ma200)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.volumeRatio,
              style: TextStyle(fontSize: 12, color: theme.textSecondary),
            ),
            Text(
              '${volRatio.toStringAsFixed(2)}x',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: volumeColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceSection(BuildContext context, StockState state, GameService game) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final performances = {
      '1D': state.performance1D,
      '1W': state.performance1W,
      '1M': state.performance1M,
      '3M': state.performance3M,
      'YTD': state.getPerformanceYTD(game.currentDay, GameService.daysPerYear),
      '1Y': state.performance1Y,
    };

    // Find best performing period
    String? bestPeriod;
    double? bestPerf;

    performances.forEach((period, perf) {
      if (perf != null && (bestPerf == null || perf > bestPerf!)) {
        bestPerf = perf;
        bestPeriod = period;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...performances.entries.map((entry) {
          final perf = entry.value;
          if (perf == null) {
            return _infoRow(context, entry.key, 'N/A');
          }

          final color = perf >= 0 ? theme.positive : theme.negative;
          final isBest = entry.key == bestPeriod && bestPerf != null && bestPerf! > 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                    if (isBest) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.positive.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          l10n.get('best'),
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: theme.positive,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${perf >= 0 ? '+' : ''}${perf.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _tradeItem(BuildContext context, TradeRecord trade) {
    final theme = context.watchTheme;
    final typeColor = trade.isBullish ? theme.positive : theme.negative;
    final hasPnL = trade.realizedPnL != null;

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: typeColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trade.typeLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: typeColor,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  trade.company.ticker,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
              ),
              Text(
                trade.timeAgo,
                style: TextStyle(
                  fontSize: 9,
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${trade.shares.toStringAsFixed(0)} @ ${NumberFormatter.formatPrice(trade.pricePerShare)}',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.textSecondary,
                ),
              ),
              if (hasPnL) ...[
                Text(
                  NumberFormatter.format(trade.realizedPnL!, showSign: true),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: trade.realizedPnL!.isPositive ? theme.positive : theme.negative,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketRegimeSection(BuildContext context, MarketRegimeData regime) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    Color regimeColor;
    if (regime.isBullish) {
      regimeColor = theme.positive;
    } else if (regime.isBearish) {
      regimeColor = theme.negative;
    } else {
      regimeColor = theme.textSecondary;
    }

    // Localized regime label + description
    String regimeLabel;
    String regimeDesc;
    switch (regime.currentRegime) {
      case MarketRegime.strongBull:
        regimeLabel = l10n.get('regime_strong_bull');
        regimeDesc = l10n.get('regime_desc_strong_bull');
      case MarketRegime.bull:
        regimeLabel = l10n.get('regime_bull');
        regimeDesc = l10n.get('regime_desc_bull');
      case MarketRegime.neutral:
        regimeLabel = l10n.get('regime_neutral');
        regimeDesc = l10n.get('regime_desc_neutral');
      case MarketRegime.bear:
        regimeLabel = l10n.get('regime_bear');
        regimeDesc = l10n.get('regime_desc_bear');
      case MarketRegime.strongBear:
        regimeLabel = l10n.get('regime_strong_bear');
        regimeDesc = l10n.get('regime_desc_strong_bear');
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: regimeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: regimeColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                regime.regimeEmoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      regimeLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: regimeColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      regimeDesc,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${l10n.get('days_in_regime')}: ${regime.daysInCurrentRegime}',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${(regime.regimeStrength * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: regimeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketIndicatorsSection(BuildContext context, MarketIndicators indicators) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final expertMode = context.watch<SettingsService>().expertMode;
    Color fearGreedColor;
    IconData fearGreedIcon;
    String fearGreedLabel;
    String fearGreedTip;
    if (indicators.fearGreedIndex >= 75) {
      fearGreedColor = theme.positive;
      fearGreedIcon = Icons.sentiment_very_satisfied;
      fearGreedLabel = l10n.get('fear_greed_extreme_greed');
      fearGreedTip = l10n.get('fear_greed_tip_extreme_greed');
    } else if (indicators.fearGreedIndex >= 60) {
      fearGreedColor = theme.positive;
      fearGreedIcon = Icons.sentiment_satisfied;
      fearGreedLabel = l10n.get('fear_greed_greed');
      fearGreedTip = l10n.get('fear_greed_tip_greed');
    } else if (indicators.fearGreedIndex >= 40) {
      fearGreedColor = theme.yellow;
      fearGreedIcon = Icons.sentiment_neutral;
      fearGreedLabel = l10n.get('fear_greed_neutral');
      fearGreedTip = l10n.get('fear_greed_tip_neutral');
    } else if (indicators.fearGreedIndex >= 25) {
      fearGreedColor = theme.orange;
      fearGreedIcon = Icons.sentiment_dissatisfied;
      fearGreedLabel = l10n.get('fear_greed_fear');
      fearGreedTip = l10n.get('fear_greed_tip_fear');
    } else {
      fearGreedColor = theme.negative;
      fearGreedIcon = Icons.sentiment_very_dissatisfied;
      fearGreedLabel = l10n.get('fear_greed_extreme_fear');
      fearGreedTip = l10n.get('fear_greed_tip_extreme_fear');
    }

    final totalStocks = indicators.advancingStocks + indicators.decliningStocks + indicators.unchangedStocks;
    final advPct = totalStocks > 0 ? indicators.advancingStocks / totalStocks : 0.0;
    final decPct = totalStocks > 0 ? indicators.decliningStocks / totalStocks : 0.0;
    final unchPct = totalStocks > 0 ? indicators.unchangedStocks / totalStocks : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, l10n.marketIndicators),
        const SizedBox(height: 10),

        // Fear & Greed — big visual gauge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: fearGreedColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: fearGreedColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(fearGreedIcon, color: fearGreedColor, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.fearGreed,
                          style: TextStyle(fontSize: 10, color: theme.textMuted),
                        ),
                        Text(
                          fearGreedLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: fearGreedColor,
                          ),
                        ),
                        Text(
                          '($fearGreedTip)',
                          style: TextStyle(
                            fontSize: 9,
                            fontStyle: FontStyle.italic,
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    indicators.fearGreedIndex.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: fearGreedColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Gradient gauge bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 8,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.negative, theme.orange, theme.yellow, theme.positive],
                          ),
                        ),
                      ),
                      // Marker
                      Align(
                        alignment: Alignment(
                          (indicators.fearGreedIndex / 50 - 1).clamp(-1.0, 1.0),
                          0,
                        ),
                        child: Container(
                          width: 4,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 2)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Market Health bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.marketHealth, style: TextStyle(fontSize: 11, color: theme.textMuted)),
            Text(
              '${indicators.marketHealthScore.toStringAsFixed(0)}/100',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (indicators.marketHealthScore / 100).clamp(0.0, 1.0),
            backgroundColor: theme.border,
            valueColor: AlwaysStoppedAnimation(
              indicators.marketHealthScore >= 60 ? theme.positive
                  : indicators.marketHealthScore >= 40 ? theme.yellow
                  : theme.negative,
            ),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 12),

        // Advancing / Declining / Unchanged — visual bar
        Text(l10n.marketBreadthLabel, style: TextStyle(fontSize: 11, color: theme.textMuted)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                if (advPct > 0) Expanded(flex: (advPct * 100).round().clamp(1, 100), child: Container(color: theme.positive)),
                if (unchPct > 0) Expanded(flex: (unchPct * 100).round().clamp(1, 100), child: Container(color: theme.yellow)),
                if (decPct > 0) Expanded(flex: (decPct * 100).round().clamp(1, 100), child: Container(color: theme.negative)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${l10n.advancing} ${indicators.advancingStocks}',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: theme.positive),
            ),
            Text(
              '${l10n.unchanged} ${indicators.unchangedStocks}',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: theme.yellow),
            ),
            Text(
              '${l10n.declining} ${indicators.decliningStocks}',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: theme.negative),
            ),
          ],
        ),

        // New highs/lows chips
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: theme.positive.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    Icon(Icons.arrow_upward, size: 14, color: theme.positive),
                    const SizedBox(height: 2),
                    Text(
                      '${indicators.newHighs}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.positive),
                    ),
                    Text(l10n.newHighs, style: TextStyle(fontSize: 8, color: theme.textMuted)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: theme.negative.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    Icon(Icons.arrow_downward, size: 14, color: theme.negative),
                    const SizedBox(height: 2),
                    Text(
                      '${indicators.newLows}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.negative),
                    ),
                    Text(l10n.newLows, style: TextStyle(fontSize: 8, color: theme.textMuted)),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Expert-only: volatility, leading/lagging sector
        if (expertMode) ...[
          const SizedBox(height: 8),
          _infoRow(context, l10n.volatility, '${indicators.volatilityIndex.toStringAsFixed(1)} (${indicators.volatilityLabel})'),
          if (indicators.leadingSector != null)
            _infoRow(context, l10n.leadingSector, indicators.leadingSector!),
          if (indicators.laggingSector != null)
            _infoRow(context, l10n.laggingSector, indicators.laggingSector!),
        ],
      ],
    );
  }

  Widget _buildPortfolioBreakdownSection(BuildContext context, PortfolioBreakdown breakdown) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    Color diversificationColor;
    final divScore = breakdown.diversificationScore;
    if (divScore >= 60) {
      diversificationColor = theme.positive;
    } else if (divScore >= 40) {
      diversificationColor = theme.textSecondary;
    } else {
      diversificationColor = theme.negative;
    }

    Color riskColor;
    switch (breakdown.riskLevel) {
      case 'Low':
        riskColor = theme.positive;
        break;
      case 'Medium':
        riskColor = theme.textSecondary;
        break;
      case 'High':
        riskColor = theme.negative;
        break;
      default:
        riskColor = theme.textSecondary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, l10n.portfolioBreakdown),
        const SizedBox(height: 8),

        // Diversification Score
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                l10n.diversification,
                style: TextStyle(fontSize: 12, color: theme.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  divScore.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: diversificationColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    breakdown.diversificationLabel,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: diversificationColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Risk Level
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                l10n.riskLevel,
                style: TextStyle(fontSize: 12, color: theme.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: riskColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                breakdown.riskLevel,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: riskColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        _infoRow(context, l10n.distinctSectors, '${breakdown.distinctSectors}'),
        _infoRow(context, l10n.avgPositionSize, '${breakdown.avgPositionSize.toStringAsFixed(1)}%'),
        _infoRow(context, l10n.concentration, '${(breakdown.concentrationRisk * 100).toStringAsFixed(1)}%'),
        _infoRow(context, l10n.portfolioVol, '${(breakdown.portfolioVolatility * 100).toStringAsFixed(1)}%'),

        if (breakdown.largestPositionTicker != null) ...[
          const SizedBox(height: 8),
          _infoRow(context, l10n.largestPosition, breakdown.largestPositionTicker!),
          _infoRow(context, l10n.largestValue, NumberFormatter.format(breakdown.largestPositionValue)),
        ],

        const SizedBox(height: 8),
        _sectionTitle(context, l10n.positionTypes),
        const SizedBox(height: 8),
        _infoRow(context, l10n.long, '${breakdown.longPercentage.toStringAsFixed(1)}%'),
        _infoRow(context, l10n.short, '${breakdown.shortPercentage.toStringAsFixed(1)}%'),

        if (breakdown.sectorAllocation.isNotEmpty) ...[
          const SizedBox(height: 8),
          _sectionTitle(context, l10n.sectorAllocation),
          const SizedBox(height: 8),
          ...breakdown.getTopSectors(5).map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${entry.value.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _newsItem(BuildContext context, NewsItem news) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    Color sentimentColor;
    switch (news.sentiment) {
      case NewsSentiment.veryPositive:
      case NewsSentiment.positive:
        sentimentColor = theme.positive;
        break;
      case NewsSentiment.negative:
      case NewsSentiment.veryNegative:
        sentimentColor = theme.negative;
        break;
      case NewsSentiment.neutral:
        sentimentColor = theme.textSecondary;
        break;
    }

    // Informant news uses a distinct purple color
    if (news.category == NewsCategory.informant) {
      sentimentColor = const Color(0xFFA855F7);
    }

    // Get localized text
    String headline = news.headline;
    String description = news.description;
    String category = news.categoryLabel;

    if (news.templateKey != null) {
      String? localizedSector;
      if (news.sectorId != null) {
        localizedSector = l10n.sectorName(news.sectorId!);
      } else if (news.sectorName != null) {
        localizedSector = news.sectorName;
      }

      // Handle midday news with format: midday_{prefix}:{type}_{sentiment}
      if (news.templateKey!.startsWith('midday_')) {
        final parts = news.templateKey!.split(':');
        if (parts.length == 2) {
          final prefixPart = parts[0]; // e.g., midday_reversal
          final templatePart = parts[1]; // e.g., company_positive

          // Get localized prefix
          String prefix = '';
          if (prefixPart.contains('update')) {
            prefix = l10n.middayPrefixUpdate;
          } else if (prefixPart.contains('correction')) {
            prefix = l10n.middayPrefixCorrection;
          } else if (prefixPart.contains('breaking')) {
            prefix = l10n.middayPrefixBreaking;
          } else if (prefixPart.contains('reversal')) {
            prefix = l10n.middayPrefixReversal;
          } else if (prefixPart.contains('recovery')) {
            prefix = l10n.middayPrefixRecovery;
          }

          headline = '$prefix${l10n.newsHeadline(
            'midday_$templatePart',
            company: news.companyName,
            sector: localizedSector,
          )}';
          description = l10n.newsDescription('midday_$templatePart');
        } else {
          // Fallback for malformed midday keys
          headline = news.headline;
          description = news.description;
        }
      } else {
        // Standard news handling
        headline = l10n.newsHeadline(
          news.templateKey!,
          company: news.companyName,
          sector: localizedSector,
          quarter: news.quarter?.toString(),
        );
        description = l10n.newsDescription(news.templateKey!);
      }
    }
    category = l10n.newsCategoryLabel(news.category.name);

    final game = context.read<GameService>();
    final isNavigable = (news.companyId != null && game.isCompanyUnlocked(news.companyId!)) ||
        (news.sectorId != null && news.companyId == null);

    final card = Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: sentimentColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: sentimentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: sentimentColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                news.timeAgo,
                style: TextStyle(
                  fontSize: 9,
                  color: theme.textSecondary,
                ),
              ),
              if (isNavigable) ...[
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 12, color: theme.textMuted),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            headline,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: theme.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (!isNavigable) return card;

    return _HoverableNewsItem(
      sentimentColor: sentimentColor,
      onTap: () {
        final game = context.read<GameService>();
        if (news.companyId != null) {
          game.selectCompany(news.companyId!);
        } else if (news.sectorId != null) {
          game.selectSector(news.sectorId!);
        }
      },
      child: card,
    );
  }
}

class _HoverableNewsItem extends StatefulWidget {
  final Color sentimentColor;
  final VoidCallback onTap;
  final Widget child;

  const _HoverableNewsItem({
    required this.sentimentColor,
    required this.onTap,
    required this.child,
  });

  @override
  State<_HoverableNewsItem> createState() => _HoverableNewsItemState();
}

class _HoverableNewsItemState extends State<_HoverableNewsItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.sentimentColor.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Opacity(
              opacity: _isHovered ? 0.85 : 1.0,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

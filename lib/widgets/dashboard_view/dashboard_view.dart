import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/core.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../data/upgrades.dart';
import '../../data/companies.dart';
import '../../services/game_service.dart';
import '../../services/sound_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_themes.dart';
import '../effects/effects.dart';
import '../challenges/challenges_panel.dart';
import '../tutorial/tutorial_keys.dart';

/// Dashboard view showing player-focused portfolio overview and stats
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Consumer<GameService>(
      builder: (context, game, _) {
        final hasPositions = game.positions.isNotEmpty;
        final breakdown = game.portfolioBreakdown;

        return SingleChildScrollView(
          // Add extra bottom padding on mobile to account for collapsed bottom sheet
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : 16,
            isMobile ? 12 : 16,
            isMobile ? 12 : 16,
            isMobile ? 92 : 16, // Extra bottom padding on mobile for bottom sheet
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Casual info bar: Player title + Prestige preview + Encouragement
              _CasualInfoBar(game: game),
              const SizedBox(height: 12),

              // Trade of the day recommendation
              if (game.tradeOfTheDayId != null)
                _TradeOfTheDay(game: game),
              if (game.tradeOfTheDayId != null)
                const SizedBox(height: 12),

              // Row 1: Pie Chart + Long/Short Gauge
              if (hasPositions && breakdown != null) ...[
                if (isMobile) ...[
                  _SectorAllocationChart(breakdown: breakdown),
                  const SizedBox(height: 12),
                  _LongShortGauge(breakdown: breakdown),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _SectorAllocationChart(breakdown: breakdown),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LongShortGauge(breakdown: breakdown),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
              ],

              // Row 2: Position Statistics + Trading Performance
              if (isMobile) ...[
                _PositionStatistics(key: TutorialKeys.positionStatistics, game: game),
                const SizedBox(height: 12),
                _TradingPerformance(key: TutorialKeys.tradingPerformance, game: game),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _PositionStatistics(key: TutorialKeys.positionStatistics, game: game)),
                    const SizedBox(width: 12),
                    Expanded(child: _TradingPerformance(key: TutorialKeys.tradingPerformance, game: game)),
                  ],
                ),
              const SizedBox(height: 16),

              // Row 3: Risk Metrics + Cash Allocation
              if (hasPositions && breakdown != null) ...[
                if (isMobile) ...[
                  _RiskMetrics(key: TutorialKeys.riskMetrics, breakdown: breakdown),
                  const SizedBox(height: 12),
                  _CashAllocation(game: game),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _RiskMetrics(key: TutorialKeys.riskMetrics, breakdown: breakdown)),
                      const SizedBox(width: 12),
                      Expanded(child: _CashAllocation(game: game)),
                    ],
                  ),
                const SizedBox(height: 16),
              ],

              // Row 4: Milestone Progress + Daily Challenges
              if (isMobile) ...[
                _MilestoneProgress(key: TutorialKeys.milestoneProgress, game: game),
                const SizedBox(height: 12),
                ChallengesPanel(key: TutorialKeys.challengesPanel),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _MilestoneProgress(key: TutorialKeys.milestoneProgress, game: game),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChallengesPanel(key: TutorialKeys.challengesPanel),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Row 5: Acquired Upgrades
              if (game.acquiredUpgrades.isNotEmpty) ...[
                _AcquiredUpgrades(game: game),
                const SizedBox(height: 16),
              ],

              // Row 6: Recent Activity
              if (isMobile) ...[
                _RecentTrades(key: TutorialKeys.recentTrades, game: game),
                const SizedBox(height: 12),
                _PositionNews(key: TutorialKeys.positionNews, game: game),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _RecentTrades(key: TutorialKeys.recentTrades, game: game)),
                    const SizedBox(width: 12),
                    Expanded(child: _PositionNews(key: TutorialKeys.positionNews, game: game)),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Pie chart showing sector allocation
class _SectorAllocationChart extends StatelessWidget {
  final PortfolioBreakdown breakdown;

  const _SectorAllocationChart({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final sectorColors = [
      theme.cyan,
      theme.positive,
      theme.orange,
      theme.primary,
      theme.negative,
      const Color(0xFF9B59B6),
      const Color(0xFF3498DB),
      const Color(0xFF1ABC9C),
      const Color(0xFFE67E22),
      const Color(0xFF95A5A6),
    ];

    final sectors = breakdown.getTopSectors(10);
    if (sectors.isEmpty) {
      return _buildEmptyCard(context, l10n.noPositions);
    }

    return HoverCard(
      glowColor: theme.cyan,
      glowIntensity: 0.15,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sectorAllocation.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                // Pie Chart
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: sectors.asMap().entries.map((entry) {
                        final index = entry.key;
                        final sector = entry.value;
                        return PieChartSectionData(
                          value: sector.value,
                          title: '${sector.value.toStringAsFixed(0)}%',
                          color: sectorColors[index % sectorColors.length],
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Legend
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sectors.asMap().entries.map((entry) {
                      final index = entry.key;
                      final sector = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: sectorColors[index % sectorColors.length],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                sector.key,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${sector.value.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: theme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, String message) {
    final theme = context.watchTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: theme.textSecondary),
        ),
      ),
    );
  }
}

/// Long/Short gauge showing position type breakdown
class _LongShortGauge extends StatelessWidget {
  final PortfolioBreakdown breakdown;

  const _LongShortGauge({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    return HoverCard(
      glowColor: theme.orange,
      glowIntensity: 0.15,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.longShort.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          // Visual gauge
          Container(
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Row(
                children: [
                  if (breakdown.longPercentage > 0)
                    Expanded(
                      flex: breakdown.longPercentage.round().clamp(1, 100),
                      child: Container(color: theme.positive),
                    ),
                  if (breakdown.shortPercentage > 0)
                    Expanded(
                      flex: breakdown.shortPercentage.round().clamp(1, 100),
                      child: Container(color: theme.negative),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Values
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.positive,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.long,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${breakdown.longPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.positive,
                    ),
                  ),
                  Text(
                    NumberFormatter.format(breakdown.longValue),
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.short,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.negative,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${breakdown.shortPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.negative,
                    ),
                  ),
                  Text(
                    NumberFormatter.format(breakdown.shortValue),
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Position statistics card
class _PositionStatistics extends StatelessWidget {
  final GameService game;

  const _PositionStatistics({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final profitable = game.profitablePositions;
    final losing = game.losingPositions;
    final total = game.positions.length;

    // Find best and worst positions
    Position? bestPosition;
    Position? worstPosition;
    double bestPnlPercent = double.negativeInfinity;
    double worstPnlPercent = double.infinity;

    for (final p in game.positions) {
      final state = game.getStockState(p.company.id);
      if (state == null) continue;
      final pnlPercent = p.unrealizedPnLPercent(state.currentPrice);
      if (pnlPercent > bestPnlPercent) {
        bestPnlPercent = pnlPercent;
        bestPosition = p;
      }
      if (pnlPercent < worstPnlPercent) {
        worstPnlPercent = pnlPercent;
        worstPosition = p;
      }
    }

    return HoverCard(
      glowColor: theme.positive,
      glowIntensity: 0.15,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.positionStatistics.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          // Profitable vs Losing bar
          if (total > 0) ...[
            Row(
              children: [
                Expanded(
                  child: _StatRow(
                    label: l10n.profitable,
                    value: profitable.toString(),
                    valueColor: theme.positive,
                  ),
                ),
                Expanded(
                  child: _StatRow(
                    label: l10n.losing,
                    value: losing.toString(),
                    valueColor: theme.negative,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Visual ratio bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: theme.surface,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  children: [
                    if (profitable > 0)
                      Expanded(
                        flex: profitable,
                        child: Container(color: theme.positive),
                      ),
                    if (losing > 0)
                      Expanded(
                        flex: losing,
                        child: Container(color: theme.negative),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Best Position
          if (bestPosition != null) ...[
            _PositionHighlight(
              label: l10n.bestPosition,
              ticker: bestPosition.company.ticker,
              pnlPercent: bestPnlPercent,
            ),
            const SizedBox(height: 8),
          ],
          // Worst Position
          if (worstPosition != null) ...[
            _PositionHighlight(
              label: l10n.worstPosition,
              ticker: worstPosition.company.ticker,
              pnlPercent: worstPnlPercent,
            ),
          ],
          if (total == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  l10n.noPositions,
                  style: TextStyle(color: theme.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PositionHighlight extends StatelessWidget {
  final String label;
  final String ticker;
  final double pnlPercent;

  const _PositionHighlight({
    required this.label,
    required this.ticker,
    required this.pnlPercent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final color = pnlPercent >= 0 ? theme.positive : theme.negative;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.textSecondary,
                ),
              ),
              Text(
                ticker,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            '${pnlPercent >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Trading performance card
class _TradingPerformance extends StatelessWidget {
  final GameService game;

  const _TradingPerformance({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final bestTrade = game.bestTrade;
    final worstTrade = game.worstTrade;
    final winStreakVal = game.winStreak;
    final loseStreakVal = game.loseStreak;

    return HoverCard(
      glowColor: theme.primary,
      glowIntensity: 0.15,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tradingPerformance.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatRow(
                  label: l10n.winRate,
                  value: '${(game.winRate * 100).toStringAsFixed(1)}%',
                  valueColor: game.winRate >= 0.5 ? theme.positive : theme.negative,
                ),
              ),
              Expanded(
                child: _StatRow(
                  label: l10n.totalTrades,
                  value: game.totalTrades.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatRow(
                  label: l10n.realizedPnL,
                  value: NumberFormatter.format(game.totalRealizedPnL, showSign: true),
                  valueColor: game.totalRealizedPnL.isPositive ? theme.positive : theme.negative,
                ),
              ),
              Expanded(
                child: _StatRow(
                  label: l10n.unrealizedPnL,
                  value: NumberFormatter.format(game.unrealizedPnL, showSign: true),
                  valueColor: game.unrealizedPnL.isPositive ? theme.positive : theme.negative,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Streak display — prominent when streak >= 3
          if (winStreakVal >= 3)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.positive.withValues(alpha: 0.2), theme.positive.withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.positive.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${'🔥' * (winStreakVal >= 5 ? 3 : winStreakVal >= 3 ? 2 : 1)} ${l10n.winStreak}: $winStreakVal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.positive,
                    ),
                  ),
                ],
              ),
            )
          else if (loseStreakVal >= 3)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.negative.withValues(alpha: 0.2), theme.negative.withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.negative.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '💀 ${l10n.loseStreak}: $loseStreakVal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.negative,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _StatRow(
                  label: winStreakVal > 0 ? '${l10n.winStreak} 🔥' : l10n.loseStreak,
                  value: winStreakVal > 0 ? winStreakVal.toString() : loseStreakVal.toString(),
                  valueColor: winStreakVal > 0 ? theme.positive : (loseStreakVal > 0 ? theme.negative : theme.textPrimary),
                ),
              ),
              Expanded(
                child: _StatRow(
                  label: l10n.tradesToday,
                  value: game.tradesToday.toString(),
                ),
              ),
            ],
          ),
          if (bestTrade != null || worstTrade != null) ...[
            const SizedBox(height: 12),
            Divider(color: theme.border, height: 1),
            const SizedBox(height: 12),
            if (bestTrade != null)
              _TradeHighlight(
                label: l10n.bestTradeEver,
                trade: bestTrade,
              ),
            if (worstTrade != null) ...[
              const SizedBox(height: 8),
              _TradeHighlight(
                label: l10n.worstTradeEver,
                trade: worstTrade,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _TradeHighlight extends StatelessWidget {
  final String label;
  final TradeRecord trade;

  const _TradeHighlight({
    required this.label,
    required this.trade,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final pnl = trade.realizedPnL ?? BigNumber.zero;
    final color = pnl.isPositive ? theme.positive : theme.negative;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: theme.textSecondary,
              ),
            ),
            Text(
              '${trade.company.ticker} (${trade.typeLabel})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          NumberFormatter.format(pnl, showSign: true),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Risk metrics card
class _RiskMetrics extends StatelessWidget {
  final PortfolioBreakdown breakdown;

  const _RiskMetrics({super.key, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final expertMode = context.watch<SettingsService>().expertMode;
    final diversScore = breakdown.diversificationScore;
    final riskLevelVal = breakdown.riskLevel;
    Color riskColor;
    switch (riskLevelVal) {
      case 'Low':
        riskColor = theme.positive;
        break;
      case 'Medium':
        riskColor = theme.orange;
        break;
      default:
        riskColor = theme.negative;
    }

    return HoverCard(
      glowColor: theme.orange,
      glowIntensity: 0.15,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.riskMetrics.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          // Diversification score bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.diversification,
                style: TextStyle(fontSize: 12, color: theme.textSecondary),
              ),
              Text(
                '${diversScore.toStringAsFixed(0)}/100 (${breakdown.diversificationLabel})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: diversScore >= 60 ? theme.positive : (diversScore >= 40 ? theme.orange : theme.negative),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: diversScore / 100,
              backgroundColor: theme.surface,
              valueColor: AlwaysStoppedAnimation(
                diversScore >= 60 ? theme.positive : (diversScore >= 40 ? theme.orange : theme.negative),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatRow(
                  label: l10n.riskLevel,
                  value: riskLevelVal,
                  valueColor: riskColor,
                ),
              ),
              Expanded(
                child: _StatRow(
                  label: l10n.positions,
                  value: breakdown.totalPositions.toString(),
                ),
              ),
            ],
          ),
          if (expertMode) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatRow(
                    label: l10n.sectors,
                    value: breakdown.distinctSectors.toString(),
                  ),
                ),
                Expanded(
                  child: _StatRow(
                    label: l10n.concentration,
                    value: '${(breakdown.concentrationRisk * 100).toStringAsFixed(0)}%',
                    valueColor: breakdown.concentrationRisk > 0.5 ? theme.negative : theme.textPrimary,
                  ),
                ),
              ],
            ),
            if (breakdown.largestPositionTicker != null) ...[
              const SizedBox(height: 8),
              _StatRow(
                label: l10n.largestPosition,
                value: '${breakdown.largestPositionTicker} (${NumberFormatter.format(breakdown.largestPositionValue)})',
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Cash allocation card
class _CashAllocation extends StatelessWidget {
  final GameService game;

  const _CashAllocation({required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final cashPct = game.cashRatio * 100;
    final investedPct = game.investedRatio * 100;

    return HoverCard(
      glowColor: theme.cyan,
      glowIntensity: 0.15,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.capitalAllocation.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          // Bar chart
          Container(
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Row(
                children: [
                  if (investedPct > 0)
                    Expanded(
                      flex: investedPct.round().clamp(1, 100),
                      child: Container(color: theme.cyan),
                    ),
                  if (cashPct > 0)
                    Expanded(
                      flex: cashPct.round().clamp(1, 100),
                      child: Container(color: theme.primary),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AllocationItem(
                label: l10n.invested,
                value: NumberFormatter.format(game.portfolioValue),
                percent: investedPct,
                color: theme.cyan,
              ),
              _AllocationItem(
                label: l10n.cash,
                value: NumberFormatter.format(game.cash),
                percent: cashPct,
                color: theme.primary,
                alignRight: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: theme.border, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.netWorth,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textSecondary,
                ),
              ),
              Text(
                NumberFormatter.format(game.netWorth),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AllocationItem extends StatelessWidget {
  final String label;
  final String value;
  final double percent;
  final Color color;
  final bool alignRight;

  const _AllocationItem({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          children: alignRight
              ? [
                  Text(label, style: TextStyle(fontSize: 11, color: theme.textSecondary)),
                  const SizedBox(width: 6),
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                ]
              : [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 6),
                  Text(label, style: TextStyle(fontSize: 11, color: theme.textSecondary)),
                ],
        ),
        const SizedBox(height: 4),
        Text(
          '${percent.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            color: theme.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Quota progress card
class _MilestoneProgress extends StatelessWidget {
  final GameService game;

  const _MilestoneProgress({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final progress = game.milestoneProgress;
    final quotaTargetVal = game.effectiveQuotaTarget;
    final quotaProgressVal = game.quotaProgress;
    final quotaRemaining = game.quotaRemaining;
    final quotaMetVal = game.quotaMet;
    final daysLeft = game.daysUntilQuota;

    final progressColor = quotaMetVal ? theme.positive : theme.primary;

    return HoverCard(
      glowColor: progressColor,
      glowIntensity: 0.2,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        quotaMetVal ? '✓ ${l10n.quotaMet.toUpperCase()}' : l10n.quotaTarget.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: quotaMetVal ? theme.positive : theme.textSecondary,
                          letterSpacing: 1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n.daysLeftLabel(daysLeft),
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  NumberFormatter.format(quotaTargetVal),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          Stack(
            children: [
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (progress / 100).clamp(0.0, 1.0),
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: quotaMetVal
                          ? [theme.positive, theme.cyan]
                          : [theme.cyan, theme.primary],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    '${progress.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n.earned}: ${NumberFormatter.format(quotaProgressVal)}',
                style: TextStyle(
                  fontSize: 11,
                  color: quotaMetVal ? theme.positive : theme.textSecondary,
                ),
              ),
              Text(
                quotaMetVal
                    ? '${l10n.bonus}: +${NumberFormatter.format(quotaProgressVal - quotaTargetVal)}'
                    : '${l10n.need}: ${NumberFormatter.format(quotaRemaining)}',
                style: TextStyle(
                  fontSize: 11,
                  color: quotaMetVal ? theme.positive : theme.negative,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Recent trades card
class _RecentTrades extends StatelessWidget {
  final GameService game;

  const _RecentTrades({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final trades = game.recentTrades.take(5).toList();

    return HoverCard(
      glowColor: theme.cyan,
      glowIntensity: 0.15,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recentTrades.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          if (trades.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  l10n.noTradesYet,
                  style: TextStyle(color: theme.textSecondary),
                ),
              ),
            )
          else
            ...trades.map((trade) => _TradeRow(trade: trade)),
        ],
      ),
    );
  }
}

class _TradeRow extends StatelessWidget {
  final TradeRecord trade;

  const _TradeRow({required this.trade});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final game = context.read<GameService>();
    final isBullish = trade.isBullish;
    final color = isBullish ? theme.positive : theme.negative;

    return HoverRow(
      onTap: () => game.selectCompany(trade.company.id),
      hoverColor: color.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              trade.typeLabel,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormatter.format(trade.totalValue),
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textPrimary,
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
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            size: 14,
            color: theme.textMuted,
          ),
        ],
      ),
    );
  }
}

/// News affecting positions card
class _PositionNews extends StatelessWidget {
  final GameService game;

  const _PositionNews({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final news = game.newsAffectingPositions.take(5).toList();

    return HoverCard(
      glowColor: theme.orange,
      glowIntensity: 0.15,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.newsAffectingPositions.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          if (news.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  l10n.noRelevantNews,
                  style: TextStyle(color: theme.textSecondary),
                ),
              ),
            )
          else
            ...news.map((item) => _NewsRow(news: item)),
        ],
      ),
    );
  }
}

class _NewsRow extends StatelessWidget {
  final NewsItem news;

  const _NewsRow({required this.news});

  void _onTap(GameService game) {
    if (news.companyId != null) {
      game.selectCompany(news.companyId!);
    } else if (news.sectorId != null) {
      game.selectSector(news.sectorId!);
    }
  }

  String _getLocalizedHeadline(AppLocalizations l10n) {
    if (news.templateKey == null) return news.headline;
    String? localizedSector;
    if (news.sectorId != null) {
      localizedSector = l10n.sectorName(news.sectorId!);
    } else if (news.sectorName != null) {
      localizedSector = news.sectorName;
    }
    return l10n.newsHeadline(
      news.templateKey!,
      company: news.companyName,
      sector: localizedSector,
      quarter: news.quarter?.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final game = context.read<GameService>();
    final hasTarget = news.companyId != null || news.sectorId != null;

    Color sentimentColor;
    switch (news.sentiment) {
      case NewsSentiment.veryPositive:
      case NewsSentiment.positive:
        sentimentColor = theme.positive;
        break;
      case NewsSentiment.veryNegative:
      case NewsSentiment.negative:
        sentimentColor = theme.negative;
        break;
      default:
        sentimentColor = theme.textSecondary;
    }

    final headline = _getLocalizedHeadline(l10n);
    final category = l10n.newsCategoryLabel(news.category.name);

    return HoverRow(
      onTap: hasTarget ? () => _onTap(game) : null,
      hoverColor: hasTarget ? sentimentColor.withValues(alpha: 0.1) : null,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: sentimentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  '$category • ${news.timeAgo}',
                  style: TextStyle(
                    fontSize: 9,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (hasTarget)
            Icon(
              Icons.chevron_right,
              size: 14,
              color: theme.textMuted,
            ),
        ],
      ),
    );
  }
}

/// Reusable stat row widget
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: theme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? theme.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Acquired upgrades display
class _AcquiredUpgrades extends StatelessWidget {
  final GameService game;

  const _AcquiredUpgrades({required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final acquired = game.acquiredUpgrades;

    return HoverCard(
      glowColor: theme.primary,
      glowIntensity: 0.15,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.acquiredUpgrades.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l10n.upgradesCount(acquired.length),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: acquired.map((acq) {
              final upgrade = allUpgrades.where((u) => u.id == acq.upgradeId).firstOrNull;
              if (upgrade == null) return const SizedBox.shrink();

              return _UpgradeChip(
                upgrade: upgrade,
                sector: acq.sector,
                stackCount: acq.stackCount,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _UpgradeChip extends StatelessWidget {
  final Upgrade upgrade;
  final SectorType? sector;
  final int stackCount;

  const _UpgradeChip({
    required this.upgrade,
    this.sector,
    required this.stackCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final effectiveSector = sector ?? upgrade.sector;
    return Tooltip(
      message: effectiveSector != null
          ? l10n.upgradeDescription(upgrade.id).replaceAll('{sector}', l10n.sectorTypeName(effectiveSector.name))
          : l10n.upgradeDescription(upgrade.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: upgrade.rarityColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: upgrade.rarityColor.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              upgrade.icon,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              l10n.upgradeName(upgrade.id),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: upgrade.rarityColor,
              ),
            ),
            if (stackCount > 1) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: upgrade.rarityColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'x$stackCount',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: upgrade.rarityColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Casual info bar: player title, prestige preview, encouragement
class _CasualInfoBar extends StatelessWidget {
  final GameService game;

  const _CasualInfoBar({required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;
    final title = l10n.get(game.playerTitle);
    final ppPreview = game.prestigePreview;
    final encouragement = game.encouragementMessage;

    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 14),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player title + prestige preview
          Row(
            children: [
              Icon(Icons.military_tech, color: theme.yellow, size: isMobile ? 18 : 22),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: theme.yellow,
                ),
              ),
              const Spacer(),
              // Prestige preview
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 10,
                  vertical: isMobile ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: theme.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.purple.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars, color: theme.purple, size: isMobile ? 12 : 14),
                    SizedBox(width: isMobile ? 3 : 4),
                    Text(
                      '$ppPreview PP',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        fontWeight: FontWeight.w600,
                        color: theme.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Encouragement message
          if (encouragement != null) ...[
            SizedBox(height: isMobile ? 6 : 8),
            Text(
              l10n.get(encouragement),
              style: TextStyle(
                fontSize: isMobile ? 11 : 13,
                color: theme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          // Personal bests row
          if (game.bestNetWorth > BigNumber.zero) ...[
            SizedBox(height: isMobile ? 8 : 10),
            Wrap(
              spacing: isMobile ? 8 : 12,
              runSpacing: 4,
              children: [
                _PersonalBestChip(
                  icon: Icons.trending_up,
                  label: l10n.get('best_net_worth'),
                  value: NumberFormatter.formatCompact(game.bestNetWorth),
                  color: theme.positive,
                  isMobile: isMobile,
                ),
                if (game.bestWinStreak > 0)
                  _PersonalBestChip(
                    icon: Icons.local_fire_department,
                    label: l10n.get('best_win_streak'),
                    value: '${game.bestWinStreak}',
                    color: theme.orange,
                    isMobile: isMobile,
                  ),
                if (game.mostDaysSurvived > 0)
                  _PersonalBestChip(
                    icon: Icons.calendar_today,
                    label: l10n.get('most_days_survived'),
                    value: '${game.mostDaysSurvived}',
                    color: theme.cyan,
                    isMobile: isMobile,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PersonalBestChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isMobile;

  const _PersonalBestChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: isMobile ? 12 : 14),
        SizedBox(width: isMobile ? 2 : 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 10 : 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Trade of the day recommendation card
class _TradeOfTheDay extends StatelessWidget {
  final GameService game;

  const _TradeOfTheDay({required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;
    final companyId = game.tradeOfTheDayId;
    if (companyId == null) return const SizedBox();

    final company = getCompanyById(companyId);
    if (company == null) return const SizedBox();

    final state = game.getStockState(companyId);
    if (state == null) return const SizedBox();

    return GestureDetector(
      onTap: () {
        SoundService().playClick();
        game.selectCompany(companyId);
      },
      child: Container(
        padding: EdgeInsets.all(isMobile ? 10 : 14),
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.positive.withValues(alpha: 0.3)),
          gradient: LinearGradient(
            colors: [
              theme.card,
              theme.positive.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.lightbulb, color: theme.yellow, size: isMobile ? 20 : 24),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.get('trade_of_the_day'),
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      color: theme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    '${company.name} (${company.ticker})',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormatter.formatPrice(state.currentPrice),
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                PercentChangePulse(
                  percent: state.dayChangePercent,
                  style: TextStyle(fontSize: isMobile ? 11 : 13, fontWeight: FontWeight.bold),
                  showBackground: false,
                ),
              ],
            ),
            SizedBox(width: isMobile ? 4 : 8),
            Icon(Icons.arrow_forward_ios, color: theme.textMuted, size: isMobile ? 14 : 16),
          ],
        ),
      ),
    );
  }
}

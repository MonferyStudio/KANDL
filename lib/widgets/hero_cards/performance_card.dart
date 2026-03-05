import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import '../../l10n/app_localizations.dart';
import 'metric_card.dart';

class PerformanceCard extends StatelessWidget {
  const PerformanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;

    return Consumer<GameService>(
      builder: (context, game, _) {
        final realizedPnL = game.totalRealizedPnL;
        final isProfit = realizedPnL.isPositive;
        final winRate = game.winRate * 100;
        final totalTrades = game.totalTrades;
        final winningTrades = (game.winRate * totalTrades).round();
        final totalExp = game.totalExpenses;
        final hasExpenses = !totalExp.isZero;
        final afterQuota = game.quotaProgress - game.effectiveQuotaTarget;
        final isQuotaPositive = !afterQuota.isNegative;

        return MetricCard(
          accentColor: theme.cyan,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: PERFORMANCE + Profit/Loss chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart_rounded, color: theme.cyan, size: isMobile ? 12 : 16),
                      SizedBox(width: isMobile ? 3 : 5),
                      Text(
                        l10n.performance.toUpperCase(),
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 14,
                          fontWeight: FontWeight.bold,
                          color: theme.textSecondary,
                          letterSpacing: isMobile ? 0.5 : 1,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 5 : 8,
                      vertical: isMobile ? 2 : 3,
                    ),
                    decoration: BoxDecoration(
                      color: (isProfit ? theme.positive : theme.negative)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isProfit ? l10n.profit.toUpperCase() : l10n.loss.toUpperCase(),
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 11,
                        fontWeight: FontWeight.w600,
                        color: isProfit ? theme.positive : theme.negative,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 1 : 4),

              // Realized P&L — big number
              Text(
                '${realizedPnL.isPositive ? '+' : ''}${NumberFormatter.format(realizedPnL)}',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 30,
                  fontWeight: FontWeight.bold,
                  color: isProfit ? theme.positive : theme.negative,
                  height: 1.1,
                ),
              ),

              // After quota + expenses — info line
              SizedBox(height: isMobile ? 1 : 2),
              Row(
                children: [
                  if (hasExpenses) ...[
                    Icon(Icons.receipt_long, color: theme.negative.withValues(alpha: 0.7), size: isMobile ? 9 : 11),
                    SizedBox(width: isMobile ? 2 : 3),
                    Text(
                      '-${NumberFormatter.format(totalExp)}',
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 10,
                        color: theme.negative,
                      ),
                    ),
                    SizedBox(width: isMobile ? 6 : 10),
                  ],
                  Icon(Icons.flag_rounded, color: (isQuotaPositive ? theme.positive : theme.negative).withValues(alpha: 0.7), size: isMobile ? 9 : 11),
                  SizedBox(width: isMobile ? 2 : 3),
                  Flexible(
                    child: Text(
                      '${l10n.afterQuota}: ${isQuotaPositive ? '+' : ''}${NumberFormatter.format(afterQuota)}',
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 11,
                        fontWeight: FontWeight.bold,
                        color: isQuotaPositive ? theme.positive : theme.negative,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Breakdown: Win Rate | Trades
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.emoji_events_outlined, color: theme.yellow.withValues(alpha: 0.7), size: isMobile ? 9 : 11),
                            SizedBox(width: isMobile ? 2 : 3),
                            Text(
                              l10n.winRate.toUpperCase(),
                              style: TextStyle(
                                fontSize: isMobile ? 7 : 9,
                                color: theme.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 1 : 2),
                        Text(
                          '${winRate.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 14,
                            fontWeight: FontWeight.w600,
                            color: winRate >= 50 ? theme.positive : theme.negative,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: isMobile ? 22 : 28,
                    color: theme.border,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: isMobile ? 6 : 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.trades.toUpperCase(),
                            style: TextStyle(
                              fontSize: isMobile ? 7 : 9,
                              color: theme.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: isMobile ? 1 : 2),
                          Row(
                            children: [
                              Text(
                                '$winningTrades',
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.positive,
                                ),
                              ),
                              Text(
                                ' / $totalTrades',
                                style: TextStyle(
                                  fontSize: isMobile ? 9 : 11,
                                  color: theme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

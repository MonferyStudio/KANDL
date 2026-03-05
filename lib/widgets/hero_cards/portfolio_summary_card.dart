import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import '../../l10n/app_localizations.dart';
import 'metric_card.dart';

class PortfolioSummaryCard extends StatelessWidget {
  const PortfolioSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;

    return Consumer<GameService>(
      builder: (context, game, _) {
        final netWorth = game.netWorth;
        final unrealizedPnL = game.unrealizedPnL;
        final unrealizedPercent = game.portfolioValue.isZero
            ? 0.0
            : unrealizedPnL.toDouble() / game.portfolioValue.toDouble() * 100;
        final isPositive = unrealizedPercent >= 0;

        return MetricCard(
          accentColor: theme.positive,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: FORTUNE + unrealized % chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: theme.positive, size: isMobile ? 12 : 16),
                      SizedBox(width: isMobile ? 3 : 5),
                      Text(
                        l10n.portfolio.toUpperCase(),
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
                      color: (isPositive ? theme.positive : theme.negative)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${isPositive ? '+' : ''}${unrealizedPercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 11,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? theme.positive : theme.negative,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 1 : 4),

              // Net Worth — big number
              Text(
                NumberFormatter.format(netWorth),
                style: TextStyle(
                  fontSize: isMobile ? 20 : 32,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                  height: 1.1,
                ),
              ),

              const Spacer(),

              // Breakdown: Cash | Invested
              Row(
                children: [
                  Expanded(
                    child: _BreakdownItem(
                      icon: Icons.payments_outlined,
                      label: l10n.cash.toUpperCase(),
                      value: NumberFormatter.format(game.cash),
                      color: theme.positive,
                      theme: theme,
                      isMobile: isMobile,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: isMobile ? 22 : 28,
                    color: theme.border,
                  ),
                  Expanded(
                    child: _BreakdownItem(
                      icon: Icons.trending_up,
                      label: l10n.holdings.toUpperCase(),
                      value: NumberFormatter.format(game.portfolioValue),
                      color: theme.cyan,
                      theme: theme,
                      isMobile: isMobile,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: isMobile ? 22 : 28,
                    color: theme.border,
                  ),
                  Expanded(
                    child: _BreakdownItem(
                      icon: Icons.view_column_outlined,
                      label: l10n.positions.toUpperCase(),
                      value: '${game.positions.length}/${game.maxPositions}',
                      color: game.positions.length >= game.maxPositions
                          ? theme.orange
                          : theme.textMuted,
                      theme: theme,
                      isMobile: isMobile,
                      alignEnd: true,
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

class _BreakdownItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final AppThemeData theme;
  final bool isMobile;
  final bool alignEnd;

  const _BreakdownItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
    required this.isMobile,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
      child: Column(
        crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color.withValues(alpha: 0.7), size: isMobile ? 9 : 11),
              SizedBox(width: isMobile ? 2 : 3),
              Text(
                label,
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
            value,
            style: TextStyle(
              fontSize: isMobile ? 11 : 14,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

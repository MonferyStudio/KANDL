import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';

class PortfolioCard extends StatelessWidget {
  const PortfolioCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Consumer<GameService>(
      builder: (context, game, _) {
        final netWorth = game.netWorth;
        final unrealizedPnL = game.unrealizedPnL;
        final unrealizedPercent = game.portfolioValue.isZero
            ? 0.0
            : unrealizedPnL.toDouble() / game.portfolioValue.toDouble() * 100;

        return Container(
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: theme.blue, width: 4),
              top: BorderSide(color: theme.border, width: 1),
              right: BorderSide(color: theme.border, width: 1),
              bottom: BorderSide(color: theme.border, width: 1),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PORTFOLIO',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  _ChangeChip(
                    percent: unrealizedPercent,
                    value: unrealizedPnL,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Value
              Text(
                NumberFormatter.format(netWorth),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                  height: 1.1,
                ),
              ),

              const Spacer(),
              Divider(color: theme.border, height: 12),
              const SizedBox(height: 4),

              // Breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BreakdownItem(
                    label: 'Cash',
                    value: NumberFormatter.format(game.cash),
                  ),
                  _BreakdownItem(
                    label: 'Invested',
                    value: NumberFormatter.format(game.portfolioValue),
                  ),
                  _BreakdownItem(
                    label: 'Positions',
                    value: '${game.positions.length}',
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

class _ChangeChip extends StatelessWidget {
  final double percent;
  final BigNumber value;

  const _ChangeChip({
    required this.percent,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final isPositive = percent >= 0;
    final color = isPositive ? theme.positive : theme.negative;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.125),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${isPositive ? '+' : ''}${percent.toStringAsFixed(1)}%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  final String label;
  final String value;

  const _BreakdownItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: theme.textMuted,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.textPrimary,
          ),
        ),
      ],
    );
  }
}

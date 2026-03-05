import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import 'metric_card.dart';

class HoldingsCard extends StatelessWidget {
  const HoldingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Consumer<GameService>(
      builder: (context, game, _) {
        final unrealizedPnL = game.unrealizedPnL;
        final unrealizedPercent = game.portfolioValue.isZero
            ? 0.0
            : unrealizedPnL.toDouble() / game.portfolioValue.toDouble() * 100;
        final isPositive = unrealizedPercent >= 0;

        return MetricCard(
          accentColor: theme.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HOLDINGS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isPositive ? theme.positive : theme.negative)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${isPositive ? '+' : ''}${unrealizedPercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? theme.positive : theme.negative,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                NumberFormatter.format(game.portfolioValue),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${game.positions.length} positions',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.textMuted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

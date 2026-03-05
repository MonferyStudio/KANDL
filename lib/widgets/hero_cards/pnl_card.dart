import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import 'metric_card.dart';

class PnLCard extends StatelessWidget {
  const PnLCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Consumer<GameService>(
      builder: (context, game, _) {
        final realizedPnL = game.totalRealizedPnL;
        final isPositive = realizedPnL.isPositive;

        return MetricCard(
          accentColor: theme.cyan,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'P&L',
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
                      isPositive ? 'PROFIT' : 'LOSS',
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
                NumberFormatter.format(realizedPnL),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? theme.positive : theme.negative,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Realized',
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

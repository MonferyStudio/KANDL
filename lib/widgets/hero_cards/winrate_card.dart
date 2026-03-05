import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import 'metric_card.dart';

class WinRateCard extends StatelessWidget {
  const WinRateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Consumer<GameService>(
      builder: (context, game, _) {
        final winRate = game.winRate * 100;
        final totalTrades = game.totalTrades;

        final winningTrades = (game.winRate * totalTrades).round();

        return MetricCard(
          accentColor: theme.purple,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WIN RATE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${winRate.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                  height: 1.1,
                ),
              ),
              const Spacer(),
              // Visual gauge bar
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: (winRate / 100).clamp(0.0, 1.0),
                    backgroundColor: theme.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      winRate >= 60 ? theme.positive
                          : winRate >= 40 ? theme.yellow
                          : theme.negative,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '$winningTrades',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.positive,
                    ),
                  ),
                  Text(
                    ' / ',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textMuted,
                    ),
                  ),
                  Text(
                    '$totalTrades',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'trades',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textMuted,
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

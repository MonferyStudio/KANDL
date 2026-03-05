import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import 'metric_card.dart';

class CashCard extends StatelessWidget {
  const CashCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Consumer<GameService>(
      builder: (context, game, _) {
        return MetricCard(
          accentColor: theme.positive,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CASH',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                NumberFormatter.format(game.cash),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                  height: 1.1,
                ),
              ),
              const Spacer(),
              Text(
                'Available',
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

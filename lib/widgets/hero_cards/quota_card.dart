import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import 'metric_card.dart';

class QuotaCard extends StatelessWidget {
  const QuotaCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Consumer<GameService>(
      builder: (context, game, _) {
        final progress = game.quotaProgressPercent.clamp(0.0, 100.0);
        final isOnTrack = progress >= (100 - game.daysUntilQuota * 3.33);

        return MetricCard(
          accentColor: theme.yellow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QUOTA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '${game.daysUntilQuota}d left',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isOnTrack ? theme.positive : theme.negative,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Target Value
              Text(
                NumberFormatter.format(game.effectiveQuotaTarget),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: theme.yellow,
                  height: 1.1,
                ),
              ),

              const Spacer(),

              // Progress Bar
              _ProgressBar(progress: progress / 100),
              const SizedBox(height: 8),

              // Year indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.background,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'Year ${game.currentYear}',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.yellow,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: theme.border,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.yellow,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

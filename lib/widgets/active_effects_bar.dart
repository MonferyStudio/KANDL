import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/active_effect.dart';
import '../models/event_data.dart';
import '../core/enums.dart';
import '../services/game_service.dart';
import '../theme/app_themes.dart';
import '../l10n/app_localizations.dart';

/// Widget displaying currently active gameplay effects
class ActiveEffectsBar extends StatelessWidget {
  const ActiveEffectsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    return Consumer<GameService>(
      builder: (context, game, _) {
        final effects = game.getLocalizedEffects(l10n);
        final hasEvent = game.hasActiveEvent;

        if (effects.isEmpty && !hasEvent) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.effectActive,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.textMuted,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              // Special event chip
              if (hasEvent) ...[
                _EventChip(
                  event: game.activeSpecialEvent!,
                  daysLeft: game.activeEventDaysLeft,
                ),
                if (effects.isNotEmpty) const SizedBox(width: 8),
              ],
              // Effect chips
              ...effects.map((effect) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _EffectChip(effect: effect),
              )),
            ],
          ),
        );
      },
    );
  }
}

class _EffectChip extends StatelessWidget {
  final ActiveEffect effect;

  const _EffectChip({required this.effect});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final color = effect.isPositive ? theme.positive : theme.negative;

    String remaining;
    if (effect.daysLeft <= 0) {
      remaining = l10n.effectToday;
    } else if (effect.daysLeft == 1) {
      remaining = l10n.effectDayRemaining('1');
    } else {
      remaining = l10n.effectDaysRemaining(effect.daysLeft.toString());
    }

    return Tooltip(
      message: '${effect.name}: ${effect.description}\n$remaining',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              effect.icon,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 4),
            Text(
              effect.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (effect.daysLeft > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '${effect.daysLeft}d',
                  style: TextStyle(
                    fontSize: 9,
                    color: theme.textMuted,
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

class _EventChip extends StatelessWidget {
  final EventData event;
  final int daysLeft;

  const _EventChip({required this.event, required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    // Determine color based on event impact
    Color color;
    switch (event.impact) {
      case EventImpact.veryPositive:
      case EventImpact.positive:
        color = theme.positive;
        break;
      case EventImpact.negative:
      case EventImpact.veryNegative:
        color = theme.negative;
        break;
      case EventImpact.neutral:
      case EventImpact.volatile:
        color = theme.orange;
        break;
    }

    final l10n = AppLocalizations.of(context);
    final remaining = daysLeft <= 0
        ? l10n.effectToday
        : daysLeft == 1
            ? l10n.effectDayRemaining('1')
            : l10n.effectDaysRemaining(daysLeft.toString());

    return Tooltip(
      message: '${event.title}\n${event.description}\n$remaining',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              event.icon,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 4),
            Text(
              event.title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                '${daysLeft}d',
                style: TextStyle(
                  fontSize: 9,
                  color: theme.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact version for smaller spaces
class ActiveEffectsCompact extends StatelessWidget {
  const ActiveEffectsCompact({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    return Consumer<GameService>(
      builder: (context, game, _) {
        final effects = game.getLocalizedEffects(l10n);

        if (effects.isEmpty) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: effects.map((effect) {
            final color = effect.isPositive ? theme.positive : theme.negative;
            return Tooltip(
              message: '${effect.name}: ${effect.description}',
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: color.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  effect.icon,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

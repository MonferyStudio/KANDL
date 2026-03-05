import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import '../../services/sound_service.dart';
import 'metric_card.dart';

class DayCard extends StatefulWidget {
  const DayCard({super.key});

  @override
  State<DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<DayCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Consumer<GameService>(
      builder: (context, game, _) {
        final isEndOfDay = game.isEndOfDay;

        return MetricCard(
          accentColor: isEndOfDay ? theme.cyan : theme.orange,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Day number
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAY',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.textSecondary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${game.currentDay}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isEndOfDay ? theme.cyan : theme.orange,
                      height: 1.0,
                    ),
                  ),
                ],
              ),

              // Right: Time and controls
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Market time or "CLOSED" label
                  if (isEndOfDay)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.negative.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'MARKET CLOSED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.negative,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  else
                    Text(
                      game.marketTimeDisplay,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.orange,
                        height: 1.0,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Control button: Next Day or Speed+Play/Pause
                  if (isEndOfDay)
                    _NextDayButton(
                      onTap: () {
                        SoundService().playClick();
                        game.nextDay();
                      },
                      pulseAnimation: _pulseAnimation,
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SpeedButton(
                          currentSpeed: game.gameSpeed,
                          onTap: () {
                            const speeds = [1.0, 2.0, 3.0];
                            final idx = speeds.indexOf(game.gameSpeed);
                            final next = speeds[(idx + 1) % speeds.length];
                            game.setGameSpeed(next);
                          },
                        ),
                        const SizedBox(width: 6),
                        _PlayPauseButton(
                          isPaused: game.isPaused,
                          onTap: () {
                            if (game.isPaused) {
                              game.startGame();
                            } else {
                              game.pauseGame();
                            }
                          },
                        ),
                      ],
                    ),
                  // Skip quota button
                  if (game.canSkipQuota) ...[
                    const SizedBox(height: 6),
                    _SkipQuotaButton(
                      onTap: () {
                        SoundService().playMoney();
                        game.skipQuota();
                      },
                      pulseAnimation: _pulseAnimation,
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NextDayButton extends StatelessWidget {
  final VoidCallback onTap;
  final Animation<double> pulseAnimation;

  const _NextDayButton({
    required this.onTap,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.cyan,
                  theme.cyan.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: theme.cyan.withValues(alpha: 0.4 * pulseAnimation.value),
                  blurRadius: 12 * pulseAnimation.value,
                  spreadRadius: 2 * pulseAnimation.value,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.skip_next_rounded,
                  color: theme.background,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'NEXT DAY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.background,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SpeedButton extends StatelessWidget {
  final double currentSpeed;
  final VoidCallback onTap;

  const _SpeedButton({
    required this.currentSpeed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final label = '${currentSpeed.toStringAsFixed(0)}x';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.textMuted, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SkipQuotaButton extends StatelessWidget {
  final VoidCallback onTap;
  final Animation<double> pulseAnimation;

  const _SkipQuotaButton({
    required this.onTap,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.yellow,
                  theme.yellow.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: theme.yellow.withValues(alpha: 0.3 * pulseAnimation.value),
                  blurRadius: 8 * pulseAnimation.value,
                  spreadRadius: 1 * pulseAnimation.value,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fast_forward_rounded,
                  color: theme.background,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'SKIP QUOTA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.background,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlayPauseButton extends StatefulWidget {
  final bool isPaused;
  final VoidCallback onTap;

  const _PlayPauseButton({
    required this.isPaused,
    required this.onTap,
  });

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final color = widget.isPaused ? theme.positive : theme.orange;

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.isPaused
                      ? color
                      : color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3 + _glowAnimation.value * 0.3),
                      blurRadius: 8 + _glowAnimation.value * 8,
                      spreadRadius: _glowAnimation.value * 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    widget.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: widget.isPaused ? theme.background : color,
                    size: 28,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

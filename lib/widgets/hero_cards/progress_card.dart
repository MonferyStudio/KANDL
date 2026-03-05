import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import '../../services/sound_service.dart';
import '../../l10n/app_localizations.dart';
import 'metric_card.dart';

class ProgressCard extends StatefulWidget {
  const ProgressCard({super.key});

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard>
    with SingleTickerProviderStateMixin {
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
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;

    return Consumer<GameService>(
      builder: (context, game, _) {
        final progress = game.quotaProgressPercent.clamp(0.0, 100.0);
        final isOnTrack = progress >= (100 - game.daysUntilQuota * 3.33);
        final isEndOfDay = game.isEndOfDay;
        final totalExp = game.totalExpenses;

        return MetricCard(
          accentColor: isEndOfDay ? theme.cyan : theme.orange,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Day, Time, and Play/Pause button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Day number
                  Text(
                    l10n.dayNumber(game.currentDay),
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 28,
                      fontWeight: FontWeight.bold,
                      color: isEndOfDay ? theme.cyan : theme.orange,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: isMobile ? 6 : 10),
                  // Time or Market Closed
                  isEndOfDay
                      ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 4 : 6,
                            vertical: isMobile ? 1 : 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.negative.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.closed.toUpperCase(),
                            style: TextStyle(
                              fontSize: isMobile ? 8 : 10,
                              fontWeight: FontWeight.bold,
                              color: theme.negative,
                            ),
                          ),
                        )
                      : Text(
                          game.marketTimeDisplay,
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 18,
                            fontWeight: FontWeight.w600,
                            color: theme.textMuted,
                            height: 1.0,
                          ),
                        ),
                  const Spacer(),
                  // Speed + Play/Pause or Next Day button
                  if (isEndOfDay)
                    _NextDayButton(
                      onTap: () {
                        SoundService().playClick();
                        game.nextDay();
                      },
                      pulseAnimation: _pulseAnimation,
                      isMobile: isMobile,
                    )
                  else ...[
                    _SpeedButton(
                      currentSpeed: game.gameSpeed,
                      isMobile: isMobile,
                      onTap: () {
                        const speeds = [1.0, 2.0, 3.0];
                        final idx = speeds.indexOf(game.gameSpeed);
                        final next = speeds[(idx + 1) % speeds.length];
                        game.setGameSpeed(next);
                      },
                    ),
                    SizedBox(width: isMobile ? 4 : 6),
                    _PlayPauseButton(
                      isPaused: game.isPaused,
                      isMobile: isMobile,
                      onTap: () {
                        if (game.isPaused) {
                          game.startGame();
                        } else {
                          game.pauseGame();
                        }
                      },
                    ),
                  ],
                ],
              ),
              // Skip quota button (visible when quota is met)
              if (game.canSkipQuota) ...[
                SizedBox(height: isMobile ? 4 : 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: _SkipQuotaButton(
                    onTap: () {
                      SoundService().playMoney();
                      game.skipQuota();
                    },
                    pulseAnimation: _pulseAnimation,
                    isMobile: isMobile,
                  ),
                ),
              ],

              const Spacer(),

              // Quota section — objective + days left
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.flag_rounded, color: theme.yellow.withValues(alpha: 0.7), size: isMobile ? 10 : 13),
                            SizedBox(width: isMobile ? 2 : 4),
                            Text(
                              l10n.quotaTarget.toUpperCase(),
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
                          NumberFormatter.format(game.effectiveQuotaTarget),
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 15,
                            fontWeight: FontWeight.bold,
                            color: theme.yellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Days left + expenses
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!totalExp.isZero)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long, color: theme.negative.withValues(alpha: 0.6), size: isMobile ? 8 : 10),
                            SizedBox(width: isMobile ? 2 : 3),
                            Text(
                              '-${NumberFormatter.format(totalExp)}',
                              style: TextStyle(
                                fontSize: isMobile ? 8 : 9,
                                color: theme.negative,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: isMobile ? 1 : 2),
                      Text(
                        l10n.daysLeftCount(game.daysUntilQuota),
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          fontWeight: FontWeight.w600,
                          color: isOnTrack ? theme.positive : theme.negative,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 4 : 6),

              // Progress bar with percentage
              _ProgressBar(progress: progress / 100, isMobile: isMobile),
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
  final bool isMobile;

  const _NextDayButton({
    required this.onTap,
    required this.pulseAnimation,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 12,
              vertical: isMobile ? 4 : 6,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.cyan,
                  theme.cyan.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: theme.cyan
                      .withValues(alpha: 0.4 * pulseAnimation.value),
                  blurRadius: 10 * pulseAnimation.value,
                  spreadRadius: 1 * pulseAnimation.value,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.skip_next_rounded,
                  color: theme.background,
                  size: isMobile ? 14 : 16,
                ),
                SizedBox(width: isMobile ? 2 : 4),
                Text(
                  l10n.nextDayBtn.toUpperCase(),
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 11,
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
  final bool isMobile;

  const _PlayPauseButton({
    required this.isPaused,
    required this.onTap,
    this.isMobile = false,
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
    final buttonSize = widget.isMobile ? 28.0 : 36.0;

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
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: widget.isPaused ? color : color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(widget.isMobile ? 6 : 8),
                  border: Border.all(
                    color: color,
                    width: widget.isMobile ? 1.5 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(
                          alpha: 0.3 + _glowAnimation.value * 0.3),
                      blurRadius: 6 + _glowAnimation.value * 6,
                      spreadRadius: _glowAnimation.value * 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    widget.isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    color: widget.isPaused ? theme.background : color,
                    size: widget.isMobile ? 16 : 22,
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

class _SpeedButton extends StatelessWidget {
  final double currentSpeed;
  final VoidCallback onTap;
  final bool isMobile;

  const _SpeedButton({
    required this.currentSpeed,
    required this.onTap,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final size = isMobile ? 28.0 : 36.0;
    final label = '${currentSpeed.toStringAsFixed(0)}x';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
          border: Border.all(color: theme.textMuted, width: isMobile ? 1 : 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
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
  final bool isMobile;

  const _SkipQuotaButton({
    required this.onTap,
    required this.pulseAnimation,
    this.isMobile = false,
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
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 12,
              vertical: isMobile ? 3 : 5,
            ),
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
                  size: isMobile ? 12 : 14,
                ),
                SizedBox(width: isMobile ? 2 : 4),
                Text(
                  'SKIP QUOTA',
                  style: TextStyle(
                    fontSize: isMobile ? 8 : 10,
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

class _ProgressBar extends StatelessWidget {
  final double progress;
  final bool isMobile;

  const _ProgressBar({required this.progress, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final height = isMobile ? 6.0 : 8.0;
    final percent = (progress * 100).clamp(0.0, 100.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.border,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Stack(
            children: [
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.yellow, theme.orange],
                    ),
                    borderRadius: BorderRadius.circular(height / 2),
                    boxShadow: [
                      if (value > 0.5)
                        BoxShadow(
                          color: theme.yellow.withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                    ],
                  ),
                ),
              ),
              // Percentage text centered
              Center(
                child: Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: isMobile ? 5 : 6,
                    fontWeight: FontWeight.bold,
                    color: value > 0.45 ? theme.background : theme.textMuted,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

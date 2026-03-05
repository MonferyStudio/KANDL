import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/core.dart';
import '../theme/app_themes.dart';
import '../services/game_service.dart';
import '../services/sound_service.dart';
import '../l10n/app_localizations.dart';

/// Milestone popup overlay — shown when player reaches a net worth milestone
class MilestonePopup extends StatelessWidget {
  const MilestonePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, game, _) {
        final milestone = game.pendingMilestone;
        if (milestone == null) return const SizedBox();

        return _MilestoneOverlay(
          milestone: milestone,
          onDismiss: () => game.dismissMilestone(),
        );
      },
    );
  }
}

class _MilestoneOverlay extends StatefulWidget {
  final int milestone;
  final VoidCallback onDismiss;

  const _MilestoneOverlay({required this.milestone, required this.onDismiss});

  @override
  State<_MilestoneOverlay> createState() => _MilestoneOverlayState();
}

class _MilestoneOverlayState extends State<_MilestoneOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.1), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.4)),
    );

    _controller.forward();
    SoundService().playMilestone();

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getMilestoneName(AppLocalizations l10n) {
    return l10n.get('milestone_${widget.milestone}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);

    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: Center(
          child: GestureDetector(
            onTap: widget.onDismiss,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.yellow.withValues(alpha: 0.9),
                    theme.orange.withValues(alpha: 0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.yellow.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🏆 ${l10n.get('milestone_reached')}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.background,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getMilestoneName(l10n),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: theme.background,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    NumberFormatter.formatCompact(BigNumber(widget.milestone.toDouble())),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.background.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ATH Golden flash — brief golden border flash when net worth hits all-time high
class AthFlash extends StatelessWidget {
  const AthFlash({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, game, _) {
        if (!game.isNewPersonalBest) return const SizedBox();
        return _AthFlashOverlay(onDismiss: () => game.dismissPersonalBest());
      },
    );
  }
}

class _AthFlashOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const _AthFlashOverlay({required this.onDismiss});

  @override
  State<_AthFlashOverlay> createState() => _AthFlashOverlayState();
}

class _AthFlashOverlayState extends State<_AthFlashOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 0.6), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0), weight: 70),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) => widget.onDismiss());
    SoundService().playAth();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, _) {
        if (_glowAnimation.value <= 0.01) return const SizedBox();
        return Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.yellow.withValues(alpha: _glowAnimation.value),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.yellow.withValues(alpha: _glowAnimation.value * 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// End-of-day narrative toast — shown at end of each day
class EndOfDayNarrative extends StatelessWidget {
  const EndOfDayNarrative({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, game, _) {
        final narrative = game.endOfDayNarrative;
        if (narrative == null || !game.isEndOfDay) return const SizedBox();

        final l10n = AppLocalizations.of(context);
        final theme = context.watchTheme;

        return Positioned(
          bottom: 100,
          left: 16,
          right: 16,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.card.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Text(
                l10n.get(narrative),
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Run summary overlay — shown when quota fails (before prestige shop)
class RunSummaryOverlay extends StatelessWidget {
  const RunSummaryOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, game, _) {
        final summary = game.runSummary;
        if (summary == null || !game.showPrestigeShop) return const SizedBox();

        return const SizedBox(); // The prestige shop already handles this; summary data is available via game.runSummary
      },
    );
  }
}

/// Confetti overlay — shows particles when a winning trade is closed
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => ConfettiOverlayState();
}

class ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final _random = math.Random();
  bool _isActive = false;

  static ConfettiOverlayState? _instance;
  static void trigger({int intensity = 20}) {
    _instance?._fire(intensity);
  }

  @override
  void initState() {
    super.initState();
    _instance = this;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isActive = false;
          _particles.clear();
        });
      }
    });
  }

  void _fire(int count) {
    _particles.clear();
    final colors = [
      Colors.red, Colors.blue, Colors.green, Colors.yellow,
      Colors.purple, Colors.orange, Colors.pink, Colors.cyan,
    ];
    for (int i = 0; i < count; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        y: -0.1 - _random.nextDouble() * 0.3,
        vx: (_random.nextDouble() - 0.5) * 0.3,
        vy: 0.3 + _random.nextDouble() * 0.5,
        rotation: _random.nextDouble() * 6.28,
        rotationSpeed: (_random.nextDouble() - 0.5) * 8,
        color: colors[_random.nextInt(colors.length)],
        size: 4 + _random.nextDouble() * 6,
      ));
    }
    _isActive = true;
    _controller.forward(from: 0);
    SoundService().playConfetti();
  }

  @override
  void dispose() {
    if (_instance == this) _instance = null;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isActive) return const SizedBox();

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  double x, y, vx, vy, rotation, rotationSpeed, size;
  Color color;

  _ConfettiParticle({
    required this.x, required this.y,
    required this.vx, required this.vy,
    required this.rotation, required this.rotationSpeed,
    required this.color, required this.size,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = (1 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final px = (p.x + p.vx * progress) * size.width;
      final py = (p.y + p.vy * progress) * size.height;
      final rot = p.rotation + p.rotationSpeed * progress;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rot);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

/// Floating text overlay for "+$X" when passive income / robot earns money
class FloatingTextOverlay extends StatefulWidget {
  const FloatingTextOverlay({super.key});

  @override
  State<FloatingTextOverlay> createState() => FloatingTextOverlayState();
}

class FloatingTextOverlayState extends State<FloatingTextOverlay> {
  final List<_FloatingText> _texts = [];
  static FloatingTextOverlayState? _instance;

  static void show(String text, {Color? color}) {
    _instance?._addText(text, color: color);
  }

  @override
  void initState() {
    super.initState();
    _instance = this;
  }

  @override
  void dispose() {
    if (_instance == this) _instance = null;
    super.dispose();
  }

  void _addText(String text, {Color? color}) {
    setState(() {
      _texts.add(_FloatingText(
        text: text,
        color: color,
        key: UniqueKey(),
      ));
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _texts.removeWhere((t) => t.key == _texts.firstOrNull?.key);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Also consume pending floating texts from GameService
    return Consumer<GameService>(
      builder: (context, game, _) {
        final theme = context.watchTheme;
        if (game.pendingFloatingTexts.isNotEmpty) {
          final pending = List.of(game.pendingFloatingTexts);
          game.consumeFloatingTexts();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            for (final entry in pending) {
              _addText(entry.key, color: entry.value ? theme.positive : theme.negative);
            }
          });
        }

        if (_texts.isEmpty) return const SizedBox();

        return Positioned(
          top: 120,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _texts.map((ft) => _FloatingTextWidget(
              key: ft.key,
              text: ft.text,
              color: ft.color,
            )).toList(),
          ),
        );
      },
    );
  }
}

class _FloatingText {
  final String text;
  final Color? color;
  final Key key;
  _FloatingText({required this.text, this.color, required this.key});
}

class _FloatingTextWidget extends StatefulWidget {
  final String text;
  final Color? color;

  const _FloatingTextWidget({super.key, required this.text, this.color});

  @override
  State<_FloatingTextWidget> createState() => _FloatingTextWidgetState();
}

class _FloatingTextWidgetState extends State<_FloatingTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1, end: 1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 30),
    ]).animate(_controller);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -30),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.color ?? theme.positive,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

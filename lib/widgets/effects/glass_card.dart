import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/sound_service.dart';
import '../../theme/app_themes.dart';

/// A card with glassmorphism effect (blur + transparency)
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double opacity;
  final List<BoxShadow>? shadows;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.padding,
    this.margin,
    this.opacity = 0.1,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final radius = borderRadius ?? BorderRadius.circular(16);
    final bgColor = backgroundColor ?? theme.card;
    final border = borderColor ?? Colors.white.withValues(alpha: 0.1);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: opacity),
              borderRadius: radius,
              border: Border.all(
                color: border,
                width: borderWidth,
              ),
              boxShadow: shadows,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A glassmorphism card with hover effect
class HoverGlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double blur;
  final Color? backgroundColor;
  final Color? glowColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const HoverGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.blur = 10.0,
    this.backgroundColor,
    this.glowColor,
    this.borderRadius,
    this.padding,
    this.margin,
  });

  @override
  State<HoverGlassCard> createState() => _HoverGlassCardState();
}

class _HoverGlassCardState extends State<HoverGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final radius = widget.borderRadius ?? BorderRadius.circular(16);
    final bgColor = widget.backgroundColor ?? theme.card;
    final glowColor = widget.glowColor ?? theme.cyan;

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap != null ? () {
          SoundService().playClick();
          widget.onTap!();
        } : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: widget.margin,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(alpha: _glowAnimation.value * 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: widget.blur,
                      sigmaY: widget.blur,
                    ),
                    child: Container(
                      padding: widget.padding,
                      decoration: BoxDecoration(
                        color: bgColor.withValues(alpha: 0.1 + (_glowAnimation.value * 0.05)),
                        borderRadius: radius,
                        border: Border.all(
                          color: Color.lerp(
                            Colors.white.withValues(alpha: 0.1),
                            glowColor.withValues(alpha: 0.5),
                            _glowAnimation.value,
                          )!,
                          width: 1,
                        ),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// A gradient card with animated gradient on hover
class GradientCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final List<Color>? colors;
  final List<Color>? hoverColors;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientCard({
    super.key,
    required this.child,
    this.onTap,
    this.colors,
    this.hoverColors,
    this.borderRadius,
    this.padding,
    this.margin,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  State<GradientCard> createState() => _GradientCardState();
}

class _GradientCardState extends State<GradientCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final radius = widget.borderRadius ?? BorderRadius.circular(12);
    final defaultColors = [
      theme.card,
      theme.surface,
    ];
    final defaultHoverColors = [
      theme.surface,
      theme.card.withValues(alpha: 0.8),
    ];

    final colors = widget.colors ?? defaultColors;
    final hoverColors = widget.hoverColors ?? defaultHoverColors;

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap != null ? () {
          SoundService().playClick();
          widget.onTap!();
        } : null,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              margin: widget.margin,
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  colors: List.generate(colors.length, (i) {
                    return Color.lerp(colors[i], hoverColors[i], _animation.value)!;
                  }),
                  begin: widget.begin,
                  end: widget.end,
                ),
                border: Border.all(
                  color: theme.border.withValues(alpha: 0.5 + (_animation.value * 0.3)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2 + (_animation.value * 0.1)),
                    blurRadius: 8 + (_animation.value * 8),
                    offset: Offset(0, 2 + (_animation.value * 2)),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// Animated border that glows and moves
class AnimatedGlowBorder extends StatefulWidget {
  final Widget child;
  final Color? color;
  final double width;
  final BorderRadius? borderRadius;
  final Duration duration;
  final bool animate;

  const AnimatedGlowBorder({
    super.key,
    required this.child,
    this.color,
    this.width = 2,
    this.borderRadius,
    this.duration = const Duration(seconds: 2),
    this.animate = true,
  });

  @override
  State<AnimatedGlowBorder> createState() => _AnimatedGlowBorderState();
}

class _AnimatedGlowBorderState extends State<AnimatedGlowBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedGlowBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final effectiveColor = widget.color ?? theme.cyan;
    final radius = widget.borderRadius ?? BorderRadius.circular(12);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: effectiveColor.withValues(alpha: 0.3 + (0.2 * (0.5 + 0.5 * (_controller.value * 2 - 1).abs()))),
                blurRadius: 8 + (4 * _controller.value),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: effectiveColor.withValues(alpha: 0.5 + (0.3 * _controller.value)),
                width: widget.width,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius.topLeft.x - widget.width),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

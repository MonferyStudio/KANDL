import 'package:flutter/material.dart';
import '../../services/sound_service.dart';
import '../../theme/app_themes.dart';

/// A card that lifts and glows on hover
class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? glowColor;
  final double glowIntensity;
  final double liftAmount;
  final Duration duration;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.glowColor,
    this.glowIntensity = 0.3,
    this.liftAmount = 4.0,
    this.duration = const Duration(milliseconds: 200),
    this.borderRadius,
    this.backgroundColor,
    this.padding,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _elevationAnimation = Tween<double>(begin: 0.0, end: widget.liftAmount).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: widget.glowIntensity).animate(
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
    final glowColor = widget.glowColor ?? theme.cyan;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(12);

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
              child: Transform.translate(
                offset: Offset(0, -_elevationAnimation.value),
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? theme.card,
                    borderRadius: borderRadius,
                    border: Border.all(
                      color: Color.lerp(
                        theme.border,
                        glowColor,
                        _glowAnimation.value,
                      )!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withValues(alpha: _glowAnimation.value * 0.5),
                        blurRadius: 20 * _glowAnimation.value,
                        spreadRadius: 2 * _glowAnimation.value,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8 + (_elevationAnimation.value * 2),
                        offset: Offset(0, 2 + _elevationAnimation.value),
                      ),
                    ],
                  ),
                  child: child,
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

/// A widget that scales slightly on hover
class HoverScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;

  const HoverScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 1.05,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: widget.scale).animate(
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
            return Transform.scale(
              scale: _animation.value,
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// A button with neon glow effect on hover
class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? color;
  final IconData? icon;
  final bool isLoading;
  final double width;
  final double height;

  const NeonButton({
    super.key,
    required this.text,
    this.onTap,
    this.color,
    this.icon,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 48,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
    final effectiveColor = widget.color ?? theme.cyan;

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) {
        _controller.reverse();
        setState(() => _isPressed = false);
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.isLoading ? null : (widget.onTap != null ? () {
          SoundService().playClick();
          widget.onTap!();
        } : null),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? 0.95 : _scaleAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      effectiveColor,
                      effectiveColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: effectiveColor.withValues(alpha: 0.3 + (_glowAnimation.value * 0.4)),
                      blurRadius: 8 + (_glowAnimation.value * 16),
                      spreadRadius: _glowAnimation.value * 2,
                    ),
                    BoxShadow(
                      color: effectiveColor.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.background,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: theme.background,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          widget.text,
                          style: TextStyle(
                            color: theme.background,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// A row that highlights on hover
class HoverRow extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? hoverColor;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;

  const HoverRow({
    super.key,
    required this.child,
    this.onTap,
    this.hoverColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.borderRadius,
  });

  @override
  State<HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<HoverRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final hoverColor = widget.hoverColor ?? theme.surface;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(8);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap != null ? () {
          SoundService().playClick();
          widget.onTap!();
        } : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _isHovered ? hoverColor : Colors.transparent,
            borderRadius: borderRadius,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Icon button with hover glow
class HoverIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final Color? hoverColor;
  final double size;
  final String? tooltip;

  const HoverIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.hoverColor,
    this.size = 24,
    this.tooltip,
  });

  @override
  State<HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<HoverIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
    final color = widget.color ?? theme.textSecondary;
    final hoverColor = widget.hoverColor ?? theme.cyan;

    Widget button = MouseRegion(
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hoverColor.withValues(alpha: _animation.value * 0.15),
                borderRadius: BorderRadius.circular(8),
                boxShadow: _animation.value > 0
                    ? [
                        BoxShadow(
                          color: hoverColor.withValues(alpha: _animation.value * 0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.icon,
                size: widget.size,
                color: Color.lerp(color, hoverColor, _animation.value),
              ),
            );
          },
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

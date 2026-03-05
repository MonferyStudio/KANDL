import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_themes.dart';
import '../../services/tutorial_service.dart';
import '../../l10n/app_localizations.dart';

/// Data for a single tutorial step
class TutorialStepData {
  final String title;
  final String description;
  final GlobalKey? targetKey;
  final Alignment tooltipAlignment;
  final VoidCallback? onNext;
  final bool showSkip;

  const TutorialStepData({
    required this.title,
    required this.description,
    this.targetKey,
    this.tooltipAlignment = Alignment.bottomCenter,
    this.onNext,
    this.showSkip = true,
  });
}

/// Overlay that highlights UI elements and shows tutorial tooltips
class TutorialOverlay extends StatefulWidget {
  final TutorialStepData stepData;
  final VoidCallback? onComplete; // Null means user must navigate themselves
  final VoidCallback onSkip;

  const TutorialOverlay({
    super.key,
    required this.stepData,
    this.onComplete,
    required this.onSkip,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
    _updateTargetRect();
  }

  @override
  void didUpdateWidget(TutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stepData.targetKey != widget.stepData.targetKey) {
      _updateTargetRect();
    }
  }

  void _updateTargetRect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final key = widget.stepData.targetKey;
      if (key?.currentContext != null) {
        final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          setState(() {
            _targetRect = Rect.fromLTWH(
              position.dx,
              position.dy,
              renderBox.size.width,
              renderBox.size.height,
            );
          });
        }
      } else {
        setState(() {
          _targetRect = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleNext() {
    widget.stepData.onNext?.call();
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // Dark overlay with spotlight cutout - IgnorePointer so clicks pass through
          Positioned.fill(
            child: IgnorePointer(
              child: _targetRect != null
                  ? CustomPaint(
                      size: screenSize,
                      painter: _SpotlightPainter(
                        targetRect: _targetRect!.inflate(8),
                        overlayColor: Colors.black.withValues(alpha: 0.7),
                        borderColor: theme.primary,
                      ),
                    )
                  : Container(
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
            ),
          ),

          // Pulsing border around target - IgnorePointer so clicks pass through
          if (_targetRect != null)
            Positioned(
              left: _targetRect!.left - 8,
              top: _targetRect!.top - 8,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: _targetRect!.width + 16,
                        height: _targetRect!.height + 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.primary,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primary.withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Tooltip - wrapped in Material for buttons, remains interactive
          _buildTooltip(context, theme, l10n, screenSize),
        ],
      ),
    );
  }

  Widget _buildTooltip(
    BuildContext context,
    dynamic theme,
    AppLocalizations l10n,
    Size screenSize,
  ) {
    // Calculate tooltip position based on target and alignment
    double? top, bottom, left, right;
    final tooltipWidth = 320.0;
    final padding = 16.0;

    if (_targetRect != null) {
      final alignment = widget.stepData.tooltipAlignment;

      if (alignment == Alignment.bottomCenter || alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight) {
        top = _targetRect!.bottom + 20;
      } else if (alignment == Alignment.topCenter || alignment == Alignment.topLeft || alignment == Alignment.topRight) {
        bottom = screenSize.height - _targetRect!.top + 20;
      } else {
        // Center vertically
        top = _targetRect!.center.dy - 100;
      }

      if (alignment == Alignment.centerLeft || alignment == Alignment.topLeft || alignment == Alignment.bottomLeft) {
        right = screenSize.width - _targetRect!.left + 20;
      } else if (alignment == Alignment.centerRight || alignment == Alignment.topRight || alignment == Alignment.bottomRight) {
        left = _targetRect!.right + 20;
      } else {
        // Center horizontally
        left = (_targetRect!.center.dx - tooltipWidth / 2).clamp(padding, screenSize.width - tooltipWidth - padding);
      }
    } else {
      // Center on screen if no target
      top = screenSize.height / 2 - 100;
      left = (screenSize.width - tooltipWidth) / 2;
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: tooltipWidth,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: theme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: theme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.stepData.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              widget.stepData.description,
              style: TextStyle(
                fontSize: 14,
                color: theme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                if (widget.stepData.showSkip)
                  TextButton(
                    onPressed: widget.onSkip,
                    child: Text(
                      l10n.tutorialSkip,
                      style: TextStyle(
                        color: theme.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const Spacer(),
                if (widget.onComplete != null)
                  ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: theme.background,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.tutorialGotIt,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  )
                else
                  // Hint to click the highlighted element
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app, color: theme.primary, size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l10n.get('tutorial_click_button'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}

/// Custom painter for spotlight effect
class _SpotlightPainter extends CustomPainter {
  final Rect targetRect;
  final Color overlayColor;
  final Color borderColor;

  _SpotlightPainter({
    required this.targetRect,
    required this.overlayColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;

    // Create path for overlay with cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(targetRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      targetRect != oldDelegate.targetRect ||
      overlayColor != oldDelegate.overlayColor;
}

/// Controller widget that manages tutorial steps for a specific flow
class TutorialController extends StatelessWidget {
  final Widget child;
  final Map<TutorialStep, TutorialStepData> steps;

  const TutorialController({
    super.key,
    required this.child,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorialService>(
      builder: (context, tutorial, _) {
        final currentStepData = steps[tutorial.currentStep];

        return Stack(
          children: [
            child,
            if (tutorial.isActive && currentStepData != null)
              TutorialOverlay(
                stepData: currentStepData,
                onComplete: () => tutorial.nextStep(),
                onSkip: () => tutorial.skipAll(),
              ),
          ],
        );
      },
    );
  }
}

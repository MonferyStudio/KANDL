import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../theme/app_themes.dart';
import 'portfolio_summary_card.dart';
import 'performance_card.dart';
import 'progress_card.dart';

class MetricsBar extends StatefulWidget {
  const MetricsBar({super.key});

  @override
  State<MetricsBar> createState() => _MetricsBarState();
}

class _MetricsBarState extends State<MetricsBar> {
  final ScrollController _scrollController = ScrollController();
  bool _showRightIndicator = true;
  bool _showLeftIndicator = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateIndicators);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateIndicators);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateIndicators() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    setState(() {
      _showLeftIndicator = currentScroll > 10;
      _showRightIndicator = currentScroll < maxScroll - 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    if (isMobile) {
      return _buildMobileLayout(context);
    }
    return _buildDesktopLayout();
  }

  /// Mobile: horizontal scroll with fixed-width cards + scroll indicators
  Widget _buildMobileLayout(BuildContext context) {
    final theme = context.watchTheme;

    return SizedBox(
      height: 110,
      child: Stack(
        children: [
          // Scrollable cards
          ListView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            children: const [
              SizedBox(
                width: 200,
                child: PortfolioSummaryCard(),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 190,
                child: PerformanceCard(),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 190,
                child: ProgressCard(),
              ),
              SizedBox(width: 8), // Extra padding at end
            ],
          ),
          // Left fade indicator
          if (_showLeftIndicator)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _ScrollIndicator(
                theme: theme,
                isLeft: true,
              ),
            ),
          // Right fade indicator with arrow hint
          if (_showRightIndicator)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _ScrollIndicator(
                theme: theme,
                isLeft: false,
              ),
            ),
        ],
      ),
    );
  }

  /// Desktop: row with 3 expanded cards
  Widget _buildDesktopLayout() {
    return SizedBox(
      height: 140,
      child: Row(
        children: const [
          Expanded(child: PortfolioSummaryCard()),
          SizedBox(width: 12),
          Expanded(child: PerformanceCard()),
          SizedBox(width: 12),
          Expanded(child: ProgressCard()),
        ],
      ),
    );
  }
}

/// Visual indicator showing more content available on scroll
class _ScrollIndicator extends StatelessWidget {
  final AppThemeData theme;
  final bool isLeft;

  const _ScrollIndicator({
    required this.theme,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          colors: [
            theme.background.withValues(alpha: 0),
            theme.background.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: theme.card,
            shape: BoxShape.circle,
            border: Border.all(color: theme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Icon(
            isLeft ? Icons.chevron_left : Icons.chevron_right,
            size: 14,
            color: theme.primary,
          ),
        ),
      ),
    );
  }
}

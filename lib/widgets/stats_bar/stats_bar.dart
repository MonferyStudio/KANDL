import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';


class StatsBar extends StatefulWidget {
  const StatsBar({super.key});

  @override
  State<StatsBar> createState() => _StatsBarState();
}

class _StatsBarState extends State<StatsBar> {
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
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;

    return Consumer<GameService>(
      builder: (context, game, _) {
        final topGainer = game.getTopMovers(count: 1, gainers: true).firstOrNull;
        final topLoser = game.getTopMovers(count: 1, gainers: false).firstOrNull;

        final cards = [
          _StatCard(
            icon: '📈',
            label: l10n.winRate,
            value: '${(game.winRate * 100).toStringAsFixed(0)}%',
            isMobile: isMobile,
          ),
          _StatCard(
            icon: '💰',
            label: l10n.realizedPnL,
            value: NumberFormatter.format(game.totalRealizedPnL, showSign: true),
            valueColor: game.totalRealizedPnL.isPositive
                ? theme.positive
                : game.totalRealizedPnL.isNegative
                    ? theme.negative
                    : null,
            isMobile: isMobile,
          ),
          _StatCard(
            icon: '🔥',
            label: l10n.topGainer,
            value: topGainer != null
                ? '${topGainer.company.ticker} ${NumberFormatter.formatPercent(topGainer.dayChangePercent)}'
                : '-',
            valueColor: theme.positive,
            onTap: topGainer != null
                ? () => game.selectCompany(topGainer.company.id)
                : null,
            isMobile: isMobile,
          ),
          _StatCard(
            icon: '❄️',
            label: l10n.topLoser,
            value: topLoser != null
                ? '${topLoser.company.ticker} ${NumberFormatter.formatPercent(topLoser.dayChangePercent)}'
                : '-',
            valueColor: theme.negative,
            onTap: topLoser != null
                ? () => game.selectCompany(topLoser.company.id)
                : null,
            isMobile: isMobile,
          ),
        ];

        if (isMobile) {
          return SizedBox(
            height: 50,
            child: Stack(
              children: [
                ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: cards.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, index) => SizedBox(
                    width: 120,
                    child: cards[index],
                  ),
                ),
                // Left indicator
                if (_showLeftIndicator)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: _ScrollIndicator(theme: theme, isLeft: true),
                  ),
                // Right indicator
                if (_showRightIndicator)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: _ScrollIndicator(theme: theme, isLeft: false),
                  ),
              ],
            ),
          );
        }

        return SizedBox(
          height: 60,
          child: Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                Expanded(child: cards[i]),
                if (i < cards.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        );
      },
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
      width: 24,
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
        child: Icon(
          isLeft ? Icons.chevron_left : Icons.chevron_right,
          size: 16,
          color: theme.primary.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final String icon;
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;
  final bool isMobile;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
    this.isMobile = false,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final isClickable = widget.onTap != null;
    final isMobile = widget.isMobile;

    return MouseRegion(
      onEnter: isClickable ? (_) => setState(() => _isHovered = true) : null,
      onExit: isClickable ? (_) => setState(() => _isHovered = false) : null,
      cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isHovered ? theme.card.withValues(alpha: 0.8) : theme.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered
                  ? (widget.valueColor ?? theme.border).withValues(alpha: 0.5)
                  : theme.border,
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 10,
            vertical: isMobile ? 6 : 8,
          ),
          child: Row(
            children: [
              Container(
                width: isMobile ? 26 : 32,
                height: isMobile ? 26 : 32,
                decoration: BoxDecoration(
                  color: theme.accent.withValues(alpha: 0.125),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    widget.icon,
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 10,
                        color: theme.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.value,
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        fontWeight: FontWeight.bold,
                        color: widget.valueColor ?? theme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

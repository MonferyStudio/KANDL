import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import '../../services/sound_service.dart';
import '../../services/settings_service.dart';
import '../../models/models.dart';
import '../../data/sectors.dart';
import '../effects/effects.dart';
import '../casual_overlays.dart';
import '../../l10n/app_localizations.dart';

class PositionsView extends StatelessWidget {
  const PositionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    return Consumer<GameService>(
      builder: (context, game, _) {
        final longPositions = game.longPositions;
        final shortPositions = game.shortPositions;
        final hasPositions = longPositions.isNotEmpty || shortPositions.isNotEmpty;

        if (!hasPositions) {
          return _EmptyPositionsView();
        }

        final isMobile = context.isMobile;

        return SingleChildScrollView(
          // Add bottom padding on mobile for collapsed bottom sheet
          padding: EdgeInsets.only(bottom: isMobile ? 80 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              _PositionsSummaryCard(
                longValue: game.longPortfolioValue,
                shortValue: game.shortPortfolioValue,
                longPnL: game.unrealizedPnLLong,
                shortPnL: game.unrealizedPnLShort,
                onCloseAll: () => _showCloseAllDialog(context, game),
              ),
              const SizedBox(height: 16),

              // Long Positions
              if (longPositions.isNotEmpty) ...[
                _SectionHeader(
                  title: l10n.get('long_positions'),
                  color: theme.positive,
                  count: longPositions.length,
                ),
                const SizedBox(height: 12),
                ...longPositions.map((position) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PositionCard(
                        position: position,
                        game: game,
                      ),
                    )),
                const SizedBox(height: 16),
              ],

              // Short Positions
              if (shortPositions.isNotEmpty) ...[
                _SectionHeader(
                  title: l10n.get('short_positions'),
                  color: theme.negative,
                  count: shortPositions.length,
                ),
                const SizedBox(height: 12),
                ...shortPositions.map((position) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PositionCard(
                        position: position,
                        game: game,
                      ),
                    )),
              ],
            ],
          ),
        );
      },
    );
  }
}

void _showCloseAllDialog(BuildContext context, GameService game) {
  final theme = context.theme;
  final l10n = AppLocalizations.of(context);
  final posCount = game.longPositions.length + game.shortPositions.length;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: theme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        l10n.get('close_all_positions'),
        style: TextStyle(color: theme.textPrimary),
      ),
      content: Text(
        l10n.get('close_all_confirm').replaceAll('{count}', '$posCount'),
        style: TextStyle(color: theme.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.get('cancel'), style: TextStyle(color: theme.textMuted)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            final closed = game.closeAllPositions();
            if (closed > 0) {
              SoundService().playSell();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.get('closed_all_positions').replaceAll('{count}', '$closed')),
                backgroundColor: theme.positive,
              ));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: theme.negative),
          child: Text(l10n.get('close_all'), style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

class _EmptyPositionsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: theme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.get('no_positions'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.get('start_trading_hint'),
            style: TextStyle(
              fontSize: 14,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionsSummaryCard extends StatelessWidget {
  final BigNumber longValue;
  final BigNumber shortValue;
  final BigNumber longPnL;
  final BigNumber shortPnL;
  final VoidCallback onCloseAll;

  const _PositionsSummaryCard({
    required this.longValue,
    required this.shortValue,
    required this.longPnL,
    required this.shortPnL,
    required this.onCloseAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;
    final totalValue = longValue + shortValue;
    final totalPnL = longPnL + shortPnL;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.get('portfolio_summary'),
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: l10n.get('total_value'),
                  value: NumberFormatter.format(totalValue),
                  color: theme.textPrimary,
                  isMobile: isMobile,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: l10n.get('total_pnl'),
                  value: NumberFormatter.format(totalPnL, showSign: true),
                  color: totalPnL.isPositive ? theme.positive : theme.negative,
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 12),
          Divider(color: theme.border, height: 1),
          SizedBox(height: isMobile ? 10 : 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryItem(
                      label: l10n.get('long_value'),
                      value: NumberFormatter.format(longValue),
                      color: theme.textSecondary,
                      isMobile: isMobile,
                    ),
                    SizedBox(height: isMobile ? 6 : 8),
                    _SummaryItem(
                      label: l10n.get('long_pnl'),
                      value: NumberFormatter.format(longPnL, showSign: true),
                      color: longPnL.isPositive ? theme.positive : theme.negative,
                      isMobile: isMobile,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryItem(
                      label: l10n.get('short_value'),
                      value: NumberFormatter.format(shortValue),
                      color: theme.textSecondary,
                      isMobile: isMobile,
                    ),
                    SizedBox(height: isMobile ? 6 : 8),
                    _SummaryItem(
                      label: l10n.get('short_pnl'),
                      value: NumberFormatter.format(shortPnL, showSign: true),
                      color: shortPnL.isPositive ? theme.positive : theme.negative,
                      isMobile: isMobile,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                SoundService().playClick();
                onCloseAll();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  color: theme.negative.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.negative.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    l10n.get('close_all_positions'),
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: theme.negative,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isMobile;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 10 : 12,
            color: theme.textSecondary,
          ),
        ),
        SizedBox(height: isMobile ? 2 : 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 13 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _PositionCard extends StatelessWidget {
  final Position position;
  final GameService game;

  const _PositionCard({
    required this.position,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;
    final expertMode = context.watch<SettingsService>().expertMode;
    final stockState = game.getStockState(position.company.id);
    if (stockState == null) return const SizedBox();

    final currentPrice = stockState.currentPrice;
    final currentValue = position.currentValue(currentPrice);
    final unrealizedPnL = position.unrealizedPnL(currentPrice);
    final unrealizedPnLPercent = position.unrealizedPnLPercent(currentPrice);

    final isLong = position.type == PositionType.long;
    final badgeColor = isLong ? theme.positive : theme.negative;
    final badgeText = isLong ? l10n.get('long') : l10n.get('short');

    final sector = getSectorById(position.company.sectorId);
    final sectorIcon = sector?.icon ?? '📊';

    // Pulse glow on positions moving strongly (+/-5%)
    final isBigMover = unrealizedPnLPercent.abs() >= 5;
    final glowColor = isBigMover
        ? (unrealizedPnL.isPositive ? theme.positive : theme.negative)
        : badgeColor;

    return HoverCard(
      onTap: () => game.selectCompany(position.company.id),
      glowColor: glowColor,
      glowIntensity: isBigMover ? 0.5 : 0.2,
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                sectorIcon,
                style: TextStyle(fontSize: isMobile ? 20 : 24),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      position.company.name,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      position.company.ticker,
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: isMobile ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText.toUpperCase(),
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 10,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // Position Details
          Row(
            children: [
              Expanded(
                child: _DetailItem(
                  label: l10n.get('shares'),
                  value: position.shares.toStringAsFixed(0),
                  isMobile: isMobile,
                ),
              ),
              if (expertMode)
                Expanded(
                  child: _DetailItem(
                    label: l10n.get('avg_cost'),
                    value: NumberFormatter.formatPrice(position.averageCost),
                    isMobile: isMobile,
                  ),
                ),
              Expanded(
                child: _DetailItem(
                  label: l10n.get('current'),
                  value: NumberFormatter.formatPrice(currentPrice),
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 12),
          Row(
            children: [
              if (expertMode)
                Expanded(
                  child: _DetailItem(
                    label: l10n.get('market_value'),
                    value: NumberFormatter.format(currentValue),
                    isMobile: isMobile,
                  ),
                ),
              Expanded(
                child: _DetailItem(
                  label: l10n.get('pnl'),
                  value: NumberFormatter.format(unrealizedPnL, showSign: true),
                  valueColor: unrealizedPnL.isPositive ? theme.positive : theme.negative,
                  isMobile: isMobile,
                ),
              ),
              Expanded(
                child: _DetailItem(
                  label: l10n.get('pnl_percent'),
                  value: NumberFormatter.formatPercent(unrealizedPnLPercent),
                  valueColor: unrealizedPnL.isPositive ? theme.positive : theme.negative,
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                flex: 3,
                child: NeonButton(
                  text: isLong ? l10n.sell.toUpperCase() : l10n.get('cover').toUpperCase(),
                  color: isLong ? theme.negative : theme.cyan,
                  onTap: () => _showClosePositionDialog(context),
                  height: isMobile ? 38 : 44,
                ),
              ),
              if (isLong) ...[
                SizedBox(width: isMobile ? 6 : 8),
                Expanded(
                  flex: 4,
                  child: NeonButton(
                    text: l10n.get('sell_all'),
                    color: theme.orange,
                    onTap: () {
                      SoundService().playSell();
                      game.sellAllOfStock(position.company.id);
                    },
                    height: isMobile ? 38 : 44,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showClosePositionDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLong = position.type == PositionType.long;
    final actionText = isLong ? l10n.sell : l10n.get('cover');
    double sharesToClose = position.shares;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final dialogTheme = context.watchTheme;
          final dialogL10n = AppLocalizations.of(context);
          return AlertDialog(
            backgroundColor: dialogTheme.card,
            title: Text(
              dialogL10n.get('close_position_title').replaceAll('{action}', actionText),
              style: TextStyle(color: dialogTheme.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dialogL10n.get('close_position_prompt').replaceAll('{action}', actionText.toLowerCase()),
                  style: TextStyle(color: dialogTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: dialogTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: dialogL10n.get('shares'),
                    labelStyle: TextStyle(color: dialogTheme.textSecondary),
                    filled: true,
                    fillColor: dialogTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: dialogTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: dialogTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: dialogTheme.primary),
                    ),
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) {
                      setState(() => sharesToClose = parsed.clamp(1, position.shares));
                    }
                  },
                  controller: TextEditingController(text: position.shares.toStringAsFixed(0)),
                ),
                const SizedBox(height: 8),
                Text(
                  dialogL10n.get('max_shares').replaceAll('{count}', position.shares.toStringAsFixed(0)),
                  style: TextStyle(
                    fontSize: 12,
                    color: dialogTheme.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  dialogL10n.cancel,
                  style: TextStyle(color: dialogTheme.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _executeClose(context, sharesToClose);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLong ? dialogTheme.negative : dialogTheme.cyan,
                ),
                child: Text(
                  actionText.toUpperCase(),
                  style: TextStyle(color: dialogTheme.background),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _executeClose(BuildContext context, double shares) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final isLong = position.type == PositionType.long;
    // Capture PnL before sell for confetti
    final state = game.getStockState(position.company.id);
    final pnlBefore = state != null ? position.unrealizedPnL(state.currentPrice) : BigNumber.zero;
    final success = isLong
        ? game.sell(position.company, shares)
        : game.cover(position.company, shares);

    if (success) {
      SoundService().playSell();
      if (pnlBefore.isPositive) {
        ConfettiOverlayState.trigger(intensity: 25);
        FloatingTextOverlayState.show(
          '+${NumberFormatter.formatCompact(pnlBefore)}',
          color: theme.positive,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isLong
                ? l10n.get('sold_shares').replaceAll('{count}', shares.toStringAsFixed(0)).replaceAll('{ticker}', position.company.ticker)
                : l10n.get('covered_shares').replaceAll('{count}', shares.toStringAsFixed(0)).replaceAll('{ticker}', position.company.ticker),
          ),
          backgroundColor: theme.positive,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isLong ? l10n.get('failed_to_sell') : l10n.get('insufficient_funds_cover'),
          ),
          backgroundColor: theme.negative,
        ),
      );
    }
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isMobile;

  const _DetailItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 9 : 10,
            color: theme.textSecondary,
          ),
        ),
        SizedBox(height: isMobile ? 2 : 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.bold,
            color: valueColor ?? theme.textPrimary,
          ),
        ),
      ],
    );
  }
}

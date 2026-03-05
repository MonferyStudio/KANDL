import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import '../../data/companies.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../services/sound_service.dart';
import '../../services/settings_service.dart';
import '../chart/stock_chart.dart';
import '../effects/effects.dart';
import '../casual_overlays.dart';

class TradingView extends StatefulWidget {
  const TradingView({super.key});

  @override
  State<TradingView> createState() => _TradingViewState();
}

class _TradingViewState extends State<TradingView> {
  bool _isLong = true;
  double _shares = 1;
  double _selectedLeverage = 1.0;
  final _sharesController = TextEditingController(text: '1');

  String _formatShares(double s) =>
      s == s.roundToDouble() ? s.toStringAsFixed(0) : s.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '');

  @override
  void dispose() {
    _sharesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;

    return Consumer<GameService>(
      builder: (context, game, _) {
        final companyId = game.selectedCompanyId;
        if (companyId == null) {
          return Center(
            child: Text(l10n.selectStockToTrade, style: TextStyle(color: theme.textSecondary)),
          );
        }

        final company = getCompanyById(companyId);
        if (company == null) {
          return Center(
            child: Text(l10n.stockNotFound, style: TextStyle(color: theme.textSecondary)),
          );
        }

        final state = game.getStockState(companyId);
        if (state == null) return const SizedBox();

        return SingleChildScrollView(
          // Add bottom padding on mobile to account for collapsed bottom sheet
          padding: EdgeInsets.only(bottom: isMobile ? 80 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _TradingHeader(company: company, state: state, onBack: () => game.goBack()),
              SizedBox(height: isMobile ? 12 : 16),

              // Price Chart
              SizedBox(
                height: isMobile ? 250 : 350,
                child: StockChart(companyId: companyId),
              ),
              SizedBox(height: isMobile ? 12 : 16),

              // Order Panel
              _OrderPanel(
                company: company,
                state: state,
                isLong: _isLong,
                shares: _shares,
                sharesController: _sharesController,
                onLongModeChanged: (isLong) => setState(() => _isLong = isLong),
                onSharesChanged: (shares) => setState(() => _shares = shares),
                onExecute: () => _executeOrder(game, company),
                selectedLeverage: _selectedLeverage,
                onLeverageChanged: (lev) => setState(() => _selectedLeverage = lev),
              ),
              SizedBox(height: isMobile ? 12 : 16),

              // Limit Order section (if unlocked)
              if (game.limitOrdersUnlock)
                _LimitOrderSection(company: company, state: state),
              if (game.limitOrdersUnlock)
                SizedBox(height: isMobile ? 12 : 16),

              // Active Positions for this stock
              _ActivePositions(companyId: companyId, currentPrice: state.currentPrice),
            ],
          ),
        );
      },
    );
  }

  void _executeOrder(GameService game, CompanyData company) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final leverage = _selectedLeverage;

    if (_isLong) {
      // Buy long position (with or without leverage)
      final success = leverage > 1.0
          ? game.buyWithLeverage(company, _shares, leverage)
          : game.buy(company, _shares);
      if (success) {
        SoundService().playBuy();
        final leverageText = leverage > 1.0 ? ' (${leverage}x)' : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.boughtSharesLong(_formatShares(_shares), company.ticker)}$leverageText'),
            backgroundColor: theme.positive,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.insufficientFunds),
            backgroundColor: theme.negative,
          ),
        );
      }
    } else {
      // Sell short position (with or without leverage)
      if (game.shortSellingBanned) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.get('short_selling_banned')),
            backgroundColor: theme.negative,
          ),
        );
      } else {
        final success = leverage > 1.0
            ? game.shortWithLeverage(company, _shares, leverage)
            : game.short(company, _shares);
        if (success) {
          SoundService().playSell();
          final leverageText = leverage > 1.0 ? ' (${leverage}x)' : '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.shortedShares(_formatShares(_shares), company.ticker)}$leverageText'),
              backgroundColor: theme.negative,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.insufficientFundsForShort),
              backgroundColor: theme.negative,
            ),
          );
        }
      }
    }
  }
}

class _TradingHeader extends StatelessWidget {
  final CompanyData company;
  final StockState state;
  final VoidCallback onBack;

  const _TradingHeader({
    required this.company,
    required this.state,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final changePercent = state.dayChangePercent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border, width: 1),
      ),
      child: Row(
        children: [
          // Back button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                SoundService().playClick();
                onBack();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.border),
                ),
                child: Icon(Icons.arrow_back, size: 16, color: theme.textSecondary),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.border,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                company.ticker.substring(0, 2),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Name & Ticker
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                Text(
                  company.ticker,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Price with pulse effect
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PricePulse(
                price: state.currentPrice,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
              PercentChangePulse(
                percent: changePercent,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                showBackground: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderPanel extends StatelessWidget {
  final CompanyData company;
  final StockState state;
  final bool isLong;
  final double shares;
  final TextEditingController sharesController;
  final ValueChanged<bool> onLongModeChanged;
  final ValueChanged<double> onSharesChanged;
  final VoidCallback onExecute;
  final double selectedLeverage;
  final ValueChanged<double> onLeverageChanged;

  const _OrderPanel({
    required this.company,
    required this.state,
    required this.isLong,
    required this.shares,
    required this.sharesController,
    required this.onLongModeChanged,
    required this.onSharesChanged,
    required this.onExecute,
    required this.selectedLeverage,
    required this.onLeverageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final game = context.read<GameService>();
    final expertMode = context.watch<SettingsService>().expertMode;

    final totalCost = state.currentPrice.multiplyByDouble(shares);
    final effectiveFee = game.effectiveFeePercent;
    final fee = totalCost.multiplyByDouble(effectiveFee / 100);
    final total = totalCost + fee;

    // Calculate bonus shares from meta progression + upgrades
    final bonusRate = game.totalStockBonusRate;
    final bonusShares = isLong && bonusRate > 0 ? (shares * bonusRate).floor() : 0;
    final totalShares = shares + bonusShares;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.placeOrder.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),

          // Long/Short toggle
          Row(
            children: [
              _OrderTypeButton(
                label: l10n.long.toUpperCase(),
                isActive: isLong,
                color: theme.positive,
                onTap: () => onLongModeChanged(true),
              ),
              const SizedBox(width: 8),
              _OrderTypeButton(
                label: l10n.short.toUpperCase(),
                isActive: !isLong,
                color: theme.negative,
                onTap: () => onLongModeChanged(false),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Shares input
          Text(
            l10n.shares,
            style: TextStyle(
              fontSize: 10,
              color: theme.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: sharesController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: theme.textPrimary, fontSize: 18),
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.background,
            ),
            onChanged: (value) {
              // Auto-convert comma to period for decimal input
              final normalized = value.replaceAll(',', '.');
              if (normalized != value) {
                sharesController.text = normalized;
                sharesController.selection = TextSelection.collapsed(offset: normalized.length);
              }
              final parsed = double.tryParse(normalized);
              if (parsed != null && parsed > 0) {
                // Limit to 3 decimal places
                final clamped = (parsed * 1000).floorToDouble() / 1000;
                onSharesChanged(clamped);
              }
            },
          ),
          const SizedBox(height: 12),

          // Quantity selector with +/- toggle
          _QuantitySelector(
              currentShares: shares,
              maxShares: () {
                final game = context.read<GameService>();
                final priceWithFee = state.currentPrice.toDouble() * (1 + game.effectiveFeePercent / 100);
                if (priceWithFee <= 0) return 0.0;
                final raw = game.cash.toDouble() / priceWithFee;
                return (raw * 1000).floorToDouble() / 1000;
              },
              onChanged: (newShares) {
                sharesController.text = newShares == newShares.roundToDouble()
                    ? newShares.toStringAsFixed(0)
                    : newShares.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '');
                onSharesChanged(newShares);
              },
            ),

          // Leverage selector (only if unlocked)
          if (game.leverageMax > 1.0) ...[
            const SizedBox(height: 16),
            _LeverageSelector(
              leverageMax: game.leverageMax,
              selectedLeverage: selectedLeverage,
              onChanged: onLeverageChanged,
              theme: theme,
              l10n: l10n,
            ),
          ],
          const SizedBox(height: 16),

          // Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isLong ? theme.positive.withValues(alpha: 0.3) : theme.negative.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                _SummaryRow(label: l10n.price, value: NumberFormatter.formatPrice(state.currentPrice)),
                _SummaryRow(label: l10n.shares, value: shares == shares.roundToDouble()
                    ? shares.toStringAsFixed(0)
                    : shares.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '')),
                if (bonusShares > 0)
                  _SummaryRow(
                    label: '🎁 ${l10n.get('bonus_shares')}',
                    value: '+$bonusShares',
                    valueColor: theme.purple,
                  ),
                if (bonusShares > 0)
                  _SummaryRow(
                    label: l10n.get('total_shares_label'),
                    value: totalShares.toStringAsFixed(0),
                    isBold: true,
                  ),
                const SizedBox(height: 4),
                if (expertMode) ...[
                  _SummaryRow(label: l10n.subtotal, value: NumberFormatter.format(totalCost)),
                  _FeeRow(
                    baseFeePercent: GameService.tradingFeePercent,
                    effectiveFeePercent: effectiveFee,
                    feeAmount: fee,
                    l10n: l10n,
                  ),
                  Divider(color: theme.border),
                ],
                _SummaryRow(
                  label: l10n.total,
                  value: NumberFormatter.format(total),
                  isBold: true,
                  valueColor: isLong ? theme.positive : theme.negative,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Auto Orders (SL/TP) — collapsible inside order panel
          if (game.hasStopLoss || game.hasTakeProfit)
            _CollapsibleAutoOrders(game: game),
          if (game.hasStopLoss || game.hasTakeProfit)
            const SizedBox(height: 16),

          // Execute button with neon glow
          NeonButton(
            text: isLong ? l10n.buyLongTicker(company.ticker) : l10n.sellShortTicker(company.ticker),
            color: isLong ? theme.positive : theme.negative,
            onTap: onExecute,
            height: 52,
          ),
        ],
      ),
    );
  }
}

class _CollapsibleAutoOrders extends StatefulWidget {
  final GameService game;
  const _CollapsibleAutoOrders({required this.game});

  @override
  State<_CollapsibleAutoOrders> createState() => _CollapsibleAutoOrdersState();
}

class _CollapsibleAutoOrdersState extends State<_CollapsibleAutoOrders> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final game = widget.game;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border, width: 1),
      ),
      child: Column(
        children: [
          // Header — tap to expand/collapse
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: theme.cyan),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.autoOrders,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                          ),
                        ),
                        Text(
                          l10n.get('auto_orders_desc'),
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status indicators (always shown when enabled)
                  if (game.hasStopLoss)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.negative.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'SL ${(game.stopLossPercent * 100).toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.negative),
                      ),
                    ),
                  if (game.hasTakeProfit)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.positive.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'TP ${(game.takeProfitPercent * 100).toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.positive),
                      ),
                    ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: theme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          if (_expanded) ...[
            Divider(height: 1, color: theme.border),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  if (game.hasStopLoss)
                    _AutoOrderSlider(
                      label: l10n.stopLoss,
                      description: l10n.stopLossDesc((game.stopLossPercent * 100).toStringAsFixed(0)),
                      icon: Icons.trending_down,
                      color: theme.negative,
                      percent: game.stopLossPercent,
                      onPercentChanged: game.setStopLossPercent,
                      min: 0.05,
                      max: 0.50,
                      divisions: 9,
                      theme: theme,
                    ),
                  if (game.hasStopLoss && game.trailingStopUnlock) ...[
                    const SizedBox(height: 4),
                    _TrailingStopCheckbox(game: game, theme: theme, l10n: l10n),
                  ],
                  if (game.hasStopLoss && game.hasTakeProfit)
                    const SizedBox(height: 10),
                  if (game.hasTakeProfit)
                    _AutoOrderSlider(
                      label: l10n.takeProfit,
                      description: l10n.takeProfitDesc((game.takeProfitPercent * 100).toStringAsFixed(0)),
                      icon: Icons.trending_up,
                      color: theme.positive,
                      percent: game.takeProfitPercent,
                      onPercentChanged: game.setTakeProfitPercent,
                      min: 0.05,
                      max: 1.0,
                      divisions: 19,
                      theme: theme,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrailingStopCheckbox extends StatelessWidget {
  final GameService game;
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _TrailingStopCheckbox({
    required this.game,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: game.trailingStopEnabled,
            onChanged: (v) => game.toggleTrailingStop(v ?? false),
            activeColor: theme.cyan,
            side: BorderSide(color: theme.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.auto_graph, size: 14, color: theme.cyan),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            l10n.get('trailing_stop'),
            style: TextStyle(fontSize: 12, color: theme.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _LeverageSelector extends StatelessWidget {
  final double leverageMax;
  final double selectedLeverage;
  final ValueChanged<double> onChanged;
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _LeverageSelector({
    required this.leverageMax,
    required this.selectedLeverage,
    required this.onChanged,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // Build available leverage tiers up to the player's max
    final tiers = <double>[1.0];
    for (final t in [1.25, 1.5, 2.0, 3.0]) {
      if (t <= leverageMax) tiers.add(t);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.speed, size: 16, color: theme.orange),
            const SizedBox(width: 6),
            Text(
              l10n.get('leverage'),
              style: TextStyle(
                fontSize: 10,
                color: theme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.get('leverage_desc'),
                style: TextStyle(
                  fontSize: 10,
                  color: theme.textMuted,
                ),
              ),
            ),
            if (selectedLeverage > 1.0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '⚠ ${l10n.get('leverage_warning')}',
                  style: TextStyle(fontSize: 8, color: theme.orange, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: tiers.map((tier) {
            final isSelected = selectedLeverage == tier;
            final isRisky = tier >= 2.0;
            final color = tier == 1.0
                ? theme.textSecondary
                : isRisky
                    ? theme.negative
                    : theme.orange;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: tier == tiers.last ? 0 : 6),
                child: GestureDetector(
                  onTap: () => onChanged(tier),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? color : theme.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tier == 1.0 ? '1x' : '${tier}x',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? color : theme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _OrderTypeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _OrderTypeButton({
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          SoundService().playClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.125) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? color : theme.border,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive ? color : theme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quantity selector with +/- toggle and quantity buttons
class _QuantitySelector extends StatefulWidget {
  final double currentShares;
  final double Function() maxShares;
  final ValueChanged<double> onChanged;

  const _QuantitySelector({
    required this.currentShares,
    required this.maxShares,
    required this.onChanged,
  });

  @override
  State<_QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<_QuantitySelector> {
  bool _isSubtractMode = false;

  static const List<int> _quantities = [1, 5, 10, 25, 100];

  void _applyQuantity(int value) {
    double newShares;
    if (_isSubtractMode) {
      newShares = (widget.currentShares - value).clamp(0.0, double.infinity);
    } else {
      newShares = widget.currentShares + value;
    }
    widget.onChanged(newShares);
  }

  void _applyMax() {
    widget.onChanged(widget.maxShares());
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final modeColor = _isSubtractMode ? theme.negative : theme.positive;

    return Column(
      children: [
        Row(
          children: [
            // Toggle button +/-
            GestureDetector(
              onTap: () {
                SoundService().playClick();
                setState(() => _isSubtractMode = !_isSubtractMode);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: modeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: modeColor, width: 2),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                    child: Icon(
                      _isSubtractMode ? Icons.remove : Icons.add,
                      key: ValueKey(_isSubtractMode),
                      color: modeColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            // Quantity buttons
            ..._quantities.map((value) => _QuantityButton(
              value: value,
              isSubtractMode: _isSubtractMode,
              onTap: () => _applyQuantity(value),
            )),
            // Max button
            _MaxButton(
              label: l10n.max.toUpperCase(),
              onTap: _applyMax,
            ),
          ],
        ),
      ],
    );
  }
}

/// Simple quantity button (just displays value and calls onTap)
class _QuantityButton extends StatelessWidget {
  final int value;
  final bool isSubtractMode;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.value,
    required this.isSubtractMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final color = isSubtractMode ? theme.negative : theme.positive;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          SoundService().playClick();
          onTap();
        },
        child: Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: theme.border),
          ),
          child: Center(
            child: Text(
              '${isSubtractMode ? '-' : '+'}$value',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Max button
class _MaxButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MaxButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          SoundService().playClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: theme.primary.withValues(alpha: 0.5)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? theme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final double baseFeePercent;
  final double effectiveFeePercent;
  final BigNumber feeAmount;
  final AppLocalizations l10n;

  const _FeeRow({
    required this.baseFeePercent,
    required this.effectiveFeePercent,
    required this.feeAmount,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final hasReduction = effectiveFeePercent < baseFeePercent - 0.001;
    final hasIncrease = effectiveFeePercent > baseFeePercent + 0.001;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label with fee percentage
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasReduction || hasIncrease) ...[
                  // Show base fee struck through
                  Text(
                    '${baseFeePercent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textMuted,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.feePercent(effectiveFeePercent.toStringAsFixed(2)),
                    style: TextStyle(
                      fontSize: 12,
                      color: hasReduction ? theme.positive : theme.negative,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else ...[
                  Text(
                    l10n.feePercent(effectiveFeePercent.toStringAsFixed(2)),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            NumberFormatter.format(feeAmount),
            style: TextStyle(
              fontSize: 13,
              color: hasReduction
                  ? theme.positive
                  : hasIncrease
                      ? theme.negative
                      : theme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows active positions for the current stock
class _ActivePositions extends StatelessWidget {
  final String companyId;
  final BigNumber currentPrice;

  const _ActivePositions({
    required this.companyId,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    return Consumer<GameService>(
      builder: (context, game, _) {
        final positions = game.positions
            .where((p) => p.company.id == companyId && p.hasShares)
            .toList();

        if (positions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.yourPositions.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  TextButton(
                    onPressed: () => game.setView(ViewType.portfolio),
                    child: Text(
                      l10n.viewAll,
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...positions.map((position) => _PositionRow(
                    position: position,
                    currentPrice: currentPrice,
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _PositionRow extends StatelessWidget {
  final Position position;
  final BigNumber currentPrice;

  const _PositionRow({
    required this.position,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final pnl = position.unrealizedPnL(currentPrice);
    final pnlPercent = position.unrealizedPnLPercent(currentPrice);
    final isLong = position.type == PositionType.long;
    final badgeColor = isLong ? theme.positive : theme.negative;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              isLong ? l10n.long.toUpperCase() : l10n.short.toUpperCase(),
              style: TextStyle(
                color: badgeColor,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Shares
          Expanded(
            flex: 2,
            child: Text(
              l10n.sharesCount(position.shares.toStringAsFixed(0)),
              style: TextStyle(
                fontSize: 13,
                color: theme.textPrimary,
              ),
            ),
          ),
          // Avg cost
          Expanded(
            flex: 2,
            child: Text(
              l10n.avgCost(NumberFormatter.formatPrice(position.averageCost)),
              style: TextStyle(
                fontSize: 12,
                color: theme.textSecondary,
              ),
            ),
          ),
          // P&L
          Expanded(
            flex: 2,
            child: Text(
              '${NumberFormatter.format(pnl, showSign: true)} (${pnlPercent >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: pnl.isNegative ? theme.negative : theme.positive,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          // Sell/Cover button
          Consumer<GameService>(
            builder: (context, game, _) {
              return GestureDetector(
                onTap: () => _showQuickCloseDialog(context, game, position, isLong, l10n, theme),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isLong ? theme.negative : theme.cyan).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: (isLong ? theme.negative : theme.cyan).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    isLong ? l10n.sell.toUpperCase() : l10n.get('cover').toUpperCase(),
                    style: TextStyle(
                      color: isLong ? theme.negative : theme.cyan,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static void _showQuickCloseDialog(
    BuildContext context,
    GameService game,
    Position position,
    bool isLong,
    AppLocalizations l10n,
    AppThemeData theme,
  ) {
    final actionText = isLong ? l10n.sell : l10n.get('cover');
    double sharesToClose = position.shares;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final dt = ctx.watchTheme;
          final dl = AppLocalizations.of(ctx);
          return AlertDialog(
            backgroundColor: dt.card,
            title: Text(
              dl.get('close_position_title').replaceAll('{action}', actionText),
              style: TextStyle(color: dt.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dl.get('close_position_prompt').replaceAll('{action}', actionText.toLowerCase()),
                  style: TextStyle(color: dt.textSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: dt.textPrimary),
                  decoration: InputDecoration(
                    labelText: dl.get('shares'),
                    labelStyle: TextStyle(color: dt.textSecondary),
                    filled: true,
                    fillColor: dt.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: dt.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: dt.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: dt.primary)),
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) setState(() => sharesToClose = parsed.clamp(1, position.shares));
                  },
                  controller: TextEditingController(text: position.shares.toStringAsFixed(0)),
                ),
                const SizedBox(height: 8),
                Text(
                  dl.get('max_shares').replaceAll('{count}', position.shares.toStringAsFixed(0)),
                  style: TextStyle(fontSize: 12, color: dt.textSecondary),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(dl.cancel, style: TextStyle(color: dt.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // Capture PnL before sell for confetti
                  final state = game.getStockState(position.company.id);
                  final pnlBefore = state != null ? position.unrealizedPnL(state.currentPrice) : BigNumber.zero;
                  final success = isLong
                      ? game.sell(position.company, sharesToClose)
                      : game.cover(position.company, sharesToClose);
                  if (success) {
                    SoundService().playSell();
                    if (pnlBefore.isPositive) {
                      ConfettiOverlayState.trigger(intensity: 25);
                      FloatingTextOverlayState.show(
                        '+${NumberFormatter.formatCompact(pnlBefore)}',
                        color: theme.positive,
                      );
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(isLong
                          ? dl.get('sold_shares').replaceAll('{count}', sharesToClose.toStringAsFixed(0)).replaceAll('{ticker}', position.company.ticker)
                          : dl.get('covered_shares').replaceAll('{count}', sharesToClose.toStringAsFixed(0)).replaceAll('{ticker}', position.company.ticker)),
                      backgroundColor: theme.positive,
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(isLong ? dl.get('failed_to_sell') : dl.get('insufficient_funds_cover')),
                      backgroundColor: theme.negative,
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: isLong ? dt.negative : dt.cyan),
                child: Text(actionText.toUpperCase(), style: TextStyle(color: dt.background)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AutoOrderSlider extends StatelessWidget {
  final String label;
  final String? description;
  final IconData icon;
  final Color color;
  final double percent;
  final ValueChanged<double> onPercentChanged;
  final double min;
  final double max;
  final int divisions;
  final AppThemeData theme;

  const _AutoOrderSlider({
    required this.label,
    this.description,
    required this.icon,
    required this.color,
    required this.percent,
    required this.onPercentChanged,
    required this.min,
    required this.max,
    required this.divisions,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
          ],
        ),
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 2),
            child: Text(
              description!,
              style: TextStyle(
                fontSize: 10,
                color: theme.textMuted,
              ),
            ),
          ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: color.withValues(alpha: 0.6),
                  inactiveTrackColor: theme.border,
                  thumbColor: color,
                  overlayColor: color.withValues(alpha: 0.2),
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                ),
                child: Slider(
                  value: percent,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onPercentChanged,
                ),
              ),
            ),
            SizedBox(
              width: 42,
              child: Text(
                '${(percent * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LimitOrderSection extends StatefulWidget {
  final CompanyData company;
  final StockState state;

  const _LimitOrderSection({required this.company, required this.state});

  @override
  State<_LimitOrderSection> createState() => _LimitOrderSectionState();
}

class _LimitOrderSectionState extends State<_LimitOrderSection> {
  bool _isBuyOrder = true;
  double _shares = 1;
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _priceController.text = widget.state.currentPrice.toDouble().toStringAsFixed(2);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final game = context.watch<GameService>();
    final pending = game.pendingLimitOrder;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: theme.cyan),
              const SizedBox(width: 6),
              Text(
                l10n.get('limit_orders'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Show pending order if exists
          if (pending != null && pending.company.id == widget.company.id) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (pending.isBuyOrder ? theme.positive : theme.negative).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (pending.isBuyOrder ? theme.positive : theme.negative).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    pending.isBuyOrder ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: pending.isBuyOrder ? theme.positive : theme.negative,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${pending.isBuyOrder ? "BUY" : "SELL"} ${pending.shares.toStringAsFixed(0)} @ \$${pending.targetPrice.toDouble().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: pending.isBuyOrder ? theme.positive : theme.negative,
                          ),
                        ),
                        Text(
                          l10n.get('waiting_for_price'),
                          style: TextStyle(fontSize: 10, color: theme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => game.cancelLimitOrder(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.negative.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n.get('cancel'),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.negative),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Buy/Sell toggle
            Row(
              children: [
                _OrderTypeButton(
                  label: l10n.get('limit_buy'),
                  isActive: _isBuyOrder,
                  color: theme.positive,
                  onTap: () => setState(() => _isBuyOrder = true),
                ),
                const SizedBox(width: 8),
                _OrderTypeButton(
                  label: l10n.get('limit_sell'),
                  isActive: !_isBuyOrder,
                  color: theme.negative,
                  onTap: () => setState(() => _isBuyOrder = false),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Target price + shares
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.get('target_price'),
                        style: TextStyle(fontSize: 10, color: theme.textMuted),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(fontSize: 13, color: theme.textPrimary),
                          decoration: InputDecoration(
                            prefixText: '\$ ',
                            prefixStyle: TextStyle(fontSize: 13, color: theme.textMuted),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: theme.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: theme.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: theme.cyan),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.get('shares'),
                        style: TextStyle(fontSize: 10, color: theme.textMuted),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 36,
                        child: Row(
                          children: [
                            _StepButton(
                              icon: Icons.remove,
                              onTap: () {
                                if (_shares > 1) setState(() => _shares--);
                              },
                              theme: theme,
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  _shares.toStringAsFixed(0),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            _StepButton(
                              icon: Icons.add,
                              onTap: () => setState(() => _shares++),
                              theme: theme,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Place order button
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: () {
                  final targetPrice = double.tryParse(_priceController.text);
                  if (targetPrice == null || targetPrice <= 0) return;
                  final success = game.placeLimitOrder(
                    company: widget.company,
                    shares: _shares,
                    targetPrice: BigNumber(targetPrice),
                    isBuyOrder: _isBuyOrder,
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.get('limit_order_placed')),
                        backgroundColor: theme.cyan,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.get('limit_order_failed')),
                        backgroundColor: theme.negative,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isBuyOrder ? theme.positive : theme.negative,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  _isBuyOrder ? l10n.get('place_limit_buy') : l10n.get('place_limit_sell'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.background,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final AppThemeData theme;

  const _StepButton({required this.icon, required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: theme.border),
        ),
        child: Icon(icon, size: 16, color: theme.textSecondary),
      ),
    );
  }
}

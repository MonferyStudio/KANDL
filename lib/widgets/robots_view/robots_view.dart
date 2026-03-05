import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import '../../models/models.dart';

class RobotsView extends StatelessWidget {
  const RobotsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;

    return Consumer<GameService>(
      builder: (context, game, _) {
        if (!game.hasRobots) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                l10n.robotNoSlots,
                style: TextStyle(color: theme.textMuted, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final robots = game.robots;
        final activeCount = robots.where((r) => r.isActive).length;

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: isMobile ? 80 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    l10n.robotsBay,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$activeCount/${robots.length} ${l10n.robotActive}',
                      style: TextStyle(
                        color: theme.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Robot cards
              for (final robot in robots) ...[
                _RobotCard(robot: robot),
                const SizedBox(height: 12),
              ],

              // Total earnings
              if (robots.any((r) => r.wallet > BigNumber.zero)) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.positive.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.positive.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.robotTotalEarnings,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        robots.fold<BigNumber>(BigNumber.zero, (s, r) => s + r.wallet).toString(),
                        style: TextStyle(
                          color: theme.positive,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _RobotCard extends StatelessWidget {
  final RobotTrader robot;
  const _RobotCard({required this.robot});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final game = context.read<GameService>();
    final maxBudget = game.robotMaxBudgetFor(robot);
    final budgetFill = maxBudget > BigNumber.zero
        ? (robot.budget.toDouble() / maxBudget.toDouble()).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: robot.isActive
              ? const Color(0xFFF97316).withValues(alpha: 0.4)
              : theme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: name + status
          Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                robot.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
              const Spacer(),
              if (robot.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.positive.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10n.robotActive,
                    style: TextStyle(color: theme.positive, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                )
              else
                const Text('💤', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),

          // === Budget section with progress bar ===
          Row(
            children: [
              Icon(Icons.account_balance, size: 13, color: const Color(0xFFF97316).withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Text(
                l10n.robotBudget.toUpperCase(),
                style: TextStyle(color: theme.textMuted, fontSize: 10, letterSpacing: 0.5),
              ),
              const Spacer(),
              Text(
                '${NumberFormatter.formatCompact(robot.budget)} / ${NumberFormatter.formatCompact(maxBudget)}',
                style: TextStyle(color: theme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: budgetFill,
              backgroundColor: theme.border,
              color: const Color(0xFFF97316),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),

          // === Earnings section ===
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: robot.wallet > BigNumber.zero
                  ? theme.positive.withValues(alpha: 0.08)
                  : theme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: robot.wallet > BigNumber.zero
                    ? theme.positive.withValues(alpha: 0.25)
                    : theme.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.savings_outlined,
                  size: 16,
                  color: robot.wallet > BigNumber.zero ? theme.positive : theme.textMuted,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.robotWallet.toUpperCase(),
                      style: TextStyle(color: theme.textMuted, fontSize: 9, letterSpacing: 0.5),
                    ),
                    Text(
                      NumberFormatter.formatCompact(robot.wallet),
                      style: TextStyle(
                        color: robot.wallet > BigNumber.zero ? theme.positive : theme.textMuted,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (robot.wallet > BigNumber.zero)
                  InkWell(
                    onTap: () => game.collectRobotWallet(robot.id),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.positive.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: theme.positive.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download, size: 13, color: theme.positive),
                          const SizedBox(width: 3),
                          Text(
                            l10n.robotCollect,
                            style: TextStyle(color: theme.positive, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Stats
          _StatBar(label: l10n.robotPrecision, level: robot.precisionLevel, valueText: '${(robot.precisionPercent * 100).toStringAsFixed(0)}%', theme: theme),
          const SizedBox(height: 4),
          _StatBar(label: l10n.robotEfficiency, level: robot.efficiencyLevel, valueText: '${(robot.efficiencyPercent * 100).toStringAsFixed(1)}%', theme: theme),
          const SizedBox(height: 4),
          _StatBar(label: l10n.robotFrequency, level: robot.frequencyLevel, valueText: '${robot.tradesPerDay}/day', theme: theme),
          const SizedBox(height: 4),
          _StatBar(label: l10n.robotRiskMgmt, level: robot.riskMgmtLevel, valueText: '${(robot.lossReductionPercent * 100).toStringAsFixed(0)}%', theme: theme),
          const SizedBox(height: 4),
          _CapacityStat(robot: robot, theme: theme, l10n: l10n),

          // Trade progress bar
          if (robot.isActive) ...[
            const SizedBox(height: 10),
            _TradeProgressBar(robot: robot, game: game, theme: theme, l10n: l10n),
          ],

          // Trade history
          if (robot.tradeHistory.isNotEmpty) ...[
            const SizedBox(height: 10),
            _TradeHistory(trades: robot.tradeHistory, theme: theme, l10n: l10n),
          ],

          const SizedBox(height: 12),

          // Action buttons
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _ActionButton(
                label: l10n.robotFund,
                icon: Icons.add_circle_outline,
                onTap: () => _showFundDialog(context, game, robot),
                theme: theme,
              ),
              if (robot.budget > BigNumber.zero)
                _ActionButton(
                  label: l10n.robotWithdraw,
                  icon: Icons.remove_circle_outline,
                  onTap: () => game.withdrawRobotBudget(robot.id),
                  theme: theme,
                  color: theme.negative,
                ),
              _ActionButton(
                label: l10n.robotUpgrade,
                icon: Icons.arrow_upward,
                onTap: () => _showUpgradeDialog(context, game, robot),
                theme: theme,
                color: const Color(0xFFA855F7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFundDialog(BuildContext context, GameService game, RobotTrader robot) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => _FundDialog(game: game, robot: robot, theme: theme, l10n: l10n),
    );
  }

  void _showUpgradeDialog(BuildContext context, GameService game, RobotTrader robot) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final currentRobot = game.robots.firstWhere((r) => r.id == robot.id);

            return AlertDialog(
              backgroundColor: theme.surface,
              title: Text(l10n.robotUpgrade, style: TextStyle(color: theme.textPrimary)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final stat in ['precision', 'efficiency', 'frequency', 'riskMgmt', 'capacity'])
                    _UpgradeRow(
                      stat: stat,
                      robot: currentRobot,
                      game: game,
                      theme: theme,
                      l10n: l10n,
                      onUpgrade: () {
                        game.upgradeRobotStat(robot.id, stat);
                        setState(() {});
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.close, style: TextStyle(color: theme.textMuted)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Fund dialog with manual input + preset quick-add buttons
class _FundDialog extends StatefulWidget {
  final GameService game;
  final RobotTrader robot;
  final dynamic theme;
  final AppLocalizations l10n;

  const _FundDialog({
    required this.game,
    required this.robot,
    required this.theme,
    required this.l10n,
  });

  @override
  State<_FundDialog> createState() => _FundDialogState();
}

class _FundDialogState extends State<_FundDialog> {
  final TextEditingController _controller = TextEditingController();
  BigNumber _amount = BigNumber.zero;

  BigNumber get _maxBudget => widget.game.robotMaxBudgetFor(widget.robot);
  BigNumber get _headroom => _maxBudget - widget.robot.budget;
  BigNumber get _cash => widget.game.cash;
  BigNumber get _maxFundable {
    final hr = _headroom;
    return hr > _cash ? _cash : hr;
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _controller.text.replaceAll(',', '').replaceAll(' ', '');
    if (text.isEmpty) {
      setState(() => _amount = BigNumber.zero);
      return;
    }
    final parsed = double.tryParse(text);
    if (parsed != null && parsed >= 0) {
      setState(() => _amount = BigNumber(parsed));
    }
  }

  void _setAmount(BigNumber val) {
    final clamped = val > _maxFundable ? _maxFundable : val;
    if (clamped <= BigNumber.zero) return;
    _amount = clamped;
    _controller.removeListener(_onTextChanged);
    _controller.text = NumberFormatter.formatCompact(clamped);
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    _controller.addListener(_onTextChanged);
    setState(() {});
  }

  void _addAmount(BigNumber val) {
    _setAmount(_amount + val);
  }

  void _confirm() {
    if (_amount <= BigNumber.zero) return;
    widget.game.fundRobot(widget.robot.id, _amount);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = widget.l10n;
    final canConfirm = _amount > BigNumber.zero && _headroom > BigNumber.zero;

    return AlertDialog(
      backgroundColor: theme.surface,
      title: Text(l10n.robotFund, style: TextStyle(color: theme.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Budget info
          Text(
            '${l10n.robotBudget}: ${widget.robot.budget} / $_maxBudget',
            style: TextStyle(color: theme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.get('cash')}: $_cash',
            style: TextStyle(color: theme.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // Manual input
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: TextStyle(color: theme.accent, fontSize: 18, fontWeight: FontWeight.bold),
              hintText: '0',
              hintStyle: TextStyle(color: theme.textMuted),
              filled: true,
              fillColor: theme.background as Color,
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
                borderSide: BorderSide(color: theme.accent, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),

          // Quick-add buttons
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final val in [100, 500, 1000, 5000])
                _QuickButton(
                  label: '+\$${NumberFormatter.formatCompact(BigNumber(val.toDouble()))}',
                  onTap: () => _addAmount(BigNumber(val.toDouble())),
                  theme: theme,
                ),
              _QuickButton(
                label: 'MAX',
                onTap: () => _setAmount(_maxFundable),
                theme: theme,
                highlight: true,
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel, style: TextStyle(color: theme.textMuted)),
        ),
        TextButton(
          onPressed: canConfirm ? _confirm : null,
          child: Text(
            l10n.robotFund,
            style: TextStyle(
              color: canConfirm ? theme.accent : theme.textMuted,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _TradeProgressBar extends StatelessWidget {
  final RobotTrader robot;
  final GameService game;
  final dynamic theme;
  final AppLocalizations l10n;

  const _TradeProgressBar({
    required this.robot,
    required this.game,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final totalTrades = robot.tradesPerDay;
    final completed = robot.tradesCompletedToday;
    final progress = game.dayProgress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.get('robot_next_trade'),
              style: TextStyle(color: theme.textMuted, fontSize: 10),
            ),
            const Spacer(),
            Text(
              '$completed/$totalTrades ${l10n.get('robot_trades_today')}',
              style: TextStyle(color: theme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: (theme.border as Color).withValues(alpha: 0.5),
            color: const Color(0xFFF97316),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

class _TradeHistory extends StatelessWidget {
  final List<RobotTrade> trades;
  final dynamic theme;
  final AppLocalizations l10n;

  const _TradeHistory({
    required this.trades,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // Show last 5, most recent first
    final recent = trades.length > 5 ? trades.sublist(trades.length - 5) : trades;
    final reversed = recent.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('robot_trade_history'),
          style: TextStyle(color: theme.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        for (final trade in reversed)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                Text(
                  trade.isWin ? '✓' : '✗',
                  style: TextStyle(
                    color: trade.isWin ? theme.positive : theme.negative,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  trade.companyTicker,
                  style: TextStyle(color: theme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                Text(
                  '${trade.isWin ? '+' : '-'}\$${NumberFormatter.formatCompact(trade.amount)}',
                  style: TextStyle(
                    color: trade.isWin ? theme.positive : theme.negative,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Text(
                  'D${trade.day}',
                  style: TextStyle(color: theme.textMuted, fontSize: 9),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final dynamic theme;
  final bool highlight;

  const _QuickButton({
    required this.label,
    required this.onTap,
    required this.theme,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: highlight
              ? (theme.accent as Color).withValues(alpha: 0.15)
              : (theme.border as Color).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: highlight
                ? (theme.accent as Color).withValues(alpha: 0.4)
                : theme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: highlight ? theme.accent : theme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CapacityStat extends StatelessWidget {
  final RobotTrader robot;
  final dynamic theme;
  final AppLocalizations l10n;

  const _CapacityStat({
    required this.robot,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final level = robot.safeCapacityLevel;
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(l10n.robotCapacity, style: TextStyle(color: theme.textMuted, fontSize: 11)),
        ),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: theme.border,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (level / (level + 5)).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: theme.cyan,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 55,
          child: Text(
            'Lv.$level',
            style: TextStyle(color: theme.cyan, fontSize: 11, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int level;
  final String valueText;
  final dynamic theme;

  const _StatBar({
    required this.label,
    required this.level,
    required this.valueText,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: TextStyle(color: theme.textMuted, fontSize: 11)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: level / 9,
              backgroundColor: theme.border,
              color: const Color(0xFFF97316),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 55,
          child: Text(
            valueText,
            style: TextStyle(color: theme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final dynamic theme;
  final Color? color;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.theme,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? theme.accent;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: (c as Color).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: c.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _UpgradeRow extends StatelessWidget {
  final String stat;
  final RobotTrader robot;
  final GameService game;
  final dynamic theme;
  final AppLocalizations l10n;
  final VoidCallback onUpgrade;

  const _UpgradeRow({
    required this.stat,
    required this.robot,
    required this.game,
    required this.theme,
    required this.l10n,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final level = game.getRobotStatLevel(robot.id, stat);
    final name = switch (stat) {
      'precision' => l10n.robotPrecision,
      'efficiency' => l10n.robotEfficiency,
      'frequency' => l10n.robotFrequency,
      'riskMgmt' => l10n.robotRiskMgmt,
      'capacity' => l10n.robotCapacity,
      _ => stat,
    };
    final isMax = game.isRobotStatMaxed(stat, level);
    final cost = game.getRobotUpgradeCost(robot.id, stat);
    final canAfford = !isMax && cost <= game.cash;

    // For capacity, compute the next max budget after upgrade
    String? capacityHint;
    if (stat == 'capacity') {
      final currentMax = game.robotMaxBudgetFor(robot);
      final nextMax = currentMax * BigNumber(2);
      capacityHint = '${NumberFormatter.formatCompact(currentMax)} → ${NumberFormatter.formatCompact(nextMax)}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: theme.textPrimary, fontSize: 13)),
                Text(
                  isMax ? 'MAX' : 'Lv.$level → ${level + 1} • ${NumberFormatter.formatCompact(cost)}',
                  style: TextStyle(
                    color: isMax ? theme.positive : theme.textMuted,
                    fontSize: 11,
                  ),
                ),
                if (capacityHint != null)
                  Text(
                    capacityHint,
                    style: TextStyle(
                      color: (theme.cyan as Color).withValues(alpha: 0.8),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          // Capacity is infinite — always show upgrade button
          if (!isMax)
            InkWell(
              onTap: canAfford ? onUpgrade : null,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: canAfford
                      ? const Color(0xFFA855F7).withValues(alpha: 0.15)
                      : (theme.border as Color).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+',
                  style: TextStyle(
                    color: canAfford ? const Color(0xFFA855F7) : theme.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

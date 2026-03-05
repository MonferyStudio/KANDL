import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sectors.dart';
import '../services/game_service.dart';
import '../theme/app_themes.dart';

/// Debug admin panel — only accessible in debug mode.
/// All references to this widget should be guarded by [kDebugMode].
class DebugPanel extends StatefulWidget {
  const DebugPanel({super.key});

  static bool get enabled => kDebugMode;

  @override
  State<DebugPanel> createState() => _DebugPanelState();
}

class _DebugPanelState extends State<DebugPanel> {
  // Trade simulator state
  String _selectedSectorId = 'tech';
  final _pnlController = TextEditingController(text: '1000');
  List<(String label, double value)>? _tradeResult;

  // Upgrade giver state
  String _upgradeType = 'sector_edge';
  String _upgradeRarity = 'legendary';
  String _upgradeSectorId = 'gaming';

  @override
  void dispose() {
    _pnlController.dispose();
    super.dispose();
  }

  void _runTradeSimulation(GameService game) {
    final basePnL = double.tryParse(_pnlController.text) ?? 0;
    setState(() {
      _tradeResult = game.debugSimulateTrade(_selectedSectorId, basePnL);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        title: Row(
          children: [
            Icon(Icons.bug_report, color: theme.negative, size: 24),
            const SizedBox(width: 8),
            Text(
              'DEBUG PANEL',
              style: TextStyle(
                color: theme.negative,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: Consumer<GameService>(
        builder: (context, game, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Current state
              _StateCard(game: game, theme: theme),
              const SizedBox(height: 16),

              // Cash cheats
              _Section(
                title: 'CASH',
                icon: Icons.attach_money,
                theme: theme,
                children: [
                  _CheatRow(
                    buttons: [
                      _CheatButton(label: '+\$1K', onTap: () => game.debugGiveCash(1000), theme: theme),
                      _CheatButton(label: '+\$10K', onTap: () => game.debugGiveCash(10000), theme: theme),
                      _CheatButton(label: '+\$100K', onTap: () => game.debugGiveCash(100000), theme: theme),
                      _CheatButton(label: '+\$1M', onTap: () => game.debugGiveCash(1000000), theme: theme),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Prestige Points
              _Section(
                title: 'PRESTIGE POINTS',
                icon: Icons.stars,
                theme: theme,
                children: [
                  _CheatRow(
                    buttons: [
                      _CheatButton(label: '+10 PP', onTap: () => game.debugGivePrestigePoints(10), theme: theme),
                      _CheatButton(label: '+50 PP', onTap: () => game.debugGivePrestigePoints(50), theme: theme),
                      _CheatButton(label: '+100 PP', onTap: () => game.debugGivePrestigePoints(100), theme: theme),
                      _CheatButton(label: '+500 PP', onTap: () => game.debugGivePrestigePoints(500), theme: theme),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Day advancement
              _Section(
                title: 'TIME',
                icon: Icons.access_time,
                theme: theme,
                children: [
                  _CheatRow(
                    buttons: [
                      _CheatButton(label: '+1 Day', onTap: () => game.debugAdvanceDays(1), theme: theme),
                      _CheatButton(label: '+5 Days', onTap: () => game.debugAdvanceDays(5), theme: theme),
                      _CheatButton(label: '+10 Days', onTap: () => game.debugAdvanceDays(10), theme: theme),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quota
              _Section(
                title: 'QUOTA',
                icon: Icons.flag,
                theme: theme,
                children: [
                  _CheatRow(
                    buttons: [
                      _CheatButton(label: '50%', onTap: () => game.debugSetQuotaProgress(50), theme: theme),
                      _CheatButton(label: '100%', onTap: () => game.debugSetQuotaProgress(100), theme: theme),
                      _CheatButton(label: '150%', onTap: () => game.debugSetQuotaProgress(150), theme: theme),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Unlocks
              _Section(
                title: 'UNLOCKS',
                icon: Icons.lock_open,
                theme: theme,
                children: [
                  _CheatRow(
                    buttons: [
                      _CheatButton(
                        label: 'All Companies',
                        onTap: () {
                          game.debugUnlockAllCompanies();
                          _showSnack(context, 'All companies unlocked', theme);
                        },
                        theme: theme,
                        wide: true,
                      ),
                      _CheatButton(
                        label: 'Max Robots',
                        onTap: () {
                          game.debugMaxRobots();
                          _showSnack(context, 'All robots maxed', theme);
                        },
                        theme: theme,
                        wide: true,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Trade Simulator
              _Section(
                title: 'TRADE SIMULATOR',
                icon: Icons.science,
                theme: theme,
                children: [
                  // Sector dropdown + PnL input
                  Row(
                    children: [
                      // Sector picker
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: theme.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: theme.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSectorId,
                              isExpanded: true,
                              dropdownColor: theme.surface,
                              style: TextStyle(color: theme.textPrimary, fontSize: 12),
                              items: allSectors.map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text('${s.icon} ${s.name}', style: TextStyle(color: theme.textPrimary, fontSize: 12)),
                              )).toList(),
                              onChanged: (v) => setState(() {
                                _selectedSectorId = v!;
                                _tradeResult = null;
                              }),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // PnL input
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _pnlController,
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          style: TextStyle(color: theme.textPrimary, fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Base P&L',
                            labelStyle: TextStyle(color: theme.textMuted, fontSize: 10),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: theme.border),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Quick amounts + simulate button
                  _CheatRow(
                    buttons: [
                      _CheatButton(label: '-1K', onTap: () { _pnlController.text = '-1000'; _runTradeSimulation(game); }, theme: theme),
                      _CheatButton(label: '+1K', onTap: () { _pnlController.text = '1000'; _runTradeSimulation(game); }, theme: theme),
                      _CheatButton(label: '+10K', onTap: () { _pnlController.text = '10000'; _runTradeSimulation(game); }, theme: theme),
                      _CheatButton(
                        label: 'Simulate',
                        onTap: () => _runTradeSimulation(game),
                        theme: theme,
                        wide: true,
                      ),
                    ],
                  ),
                  // Results
                  if (_tradeResult != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.background,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: theme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final (label, value) in _tradeResult!)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: label.startsWith('═')
                                            ? theme.textPrimary
                                            : theme.textSecondary,
                                        fontSize: label.startsWith('═') ? 13 : 11,
                                        fontWeight: label.startsWith('═')
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    value == 0 && !label.contains('P&L') ? '-' : _formatValue(value),
                                    style: TextStyle(
                                      color: value >= 0 ? theme.positive : theme.negative,
                                      fontSize: label.startsWith('═') ? 13 : 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Upgrade Giver
              _Section(
                title: 'GIVE UPGRADE',
                icon: Icons.card_giftcard,
                theme: theme,
                children: [
                  // Type + Rarity row
                  Row(
                    children: [
                      // Template type
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: theme.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: theme.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _upgradeType,
                              isExpanded: true,
                              dropdownColor: theme.surface,
                              style: TextStyle(color: theme.textPrimary, fontSize: 12),
                              items: const [
                                DropdownMenuItem(value: 'sector_edge', child: Text('Sector Edge')),
                                DropdownMenuItem(value: 'sector_shield', child: Text('Sector Shield')),
                              ],
                              onChanged: (v) => setState(() => _upgradeType = v!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Rarity
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: theme.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: theme.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _upgradeRarity,
                              isExpanded: true,
                              dropdownColor: theme.surface,
                              style: TextStyle(color: theme.textPrimary, fontSize: 12),
                              items: const [
                                DropdownMenuItem(value: 'common', child: Text('Common')),
                                DropdownMenuItem(value: 'uncommon', child: Text('Uncommon')),
                                DropdownMenuItem(value: 'rare', child: Text('Rare')),
                                DropdownMenuItem(value: 'epic', child: Text('Epic')),
                                DropdownMenuItem(value: 'legendary', child: Text('Legendary')),
                              ],
                              onChanged: (v) => setState(() => _upgradeRarity = v!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Sector picker + give button
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: theme.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: theme.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _upgradeSectorId,
                              isExpanded: true,
                              dropdownColor: theme.surface,
                              style: TextStyle(color: theme.textPrimary, fontSize: 12),
                              items: allSectors.map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text('${s.icon} ${s.name}', style: TextStyle(color: theme.textPrimary, fontSize: 12)),
                              )).toList(),
                              onChanged: (v) => setState(() => _upgradeSectorId = v!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CheatButton(
                        label: 'Give',
                        onTap: () {
                          final upgradeId = '${_upgradeType}_$_upgradeRarity';
                          final sector = allSectors.firstWhere((s) => s.id == _upgradeSectorId);
                          game.debugGiveUpgrade(upgradeId, sectorType: sector.type);
                          _showSnack(context, 'Gave $_upgradeRarity $_upgradeType (${sector.name})', theme);
                        },
                        theme: theme,
                        wide: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Quick shortcuts
                  _CheatRow(
                    buttons: [
                      for (final staticId in ['momentum_rider', 'contrarian', 'day_trader', 'tax_refund'])
                        _CheatButton(
                          label: staticId.replaceAll('_', ' ').split(' ').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' '),
                          onTap: () {
                            game.debugGiveUpgrade(staticId);
                            _showSnack(context, 'Gave $staticId', theme);
                          },
                          theme: theme,
                          wide: true,
                        ),
                    ],
                  ),
                  // Current upgrades count
                  const SizedBox(height: 6),
                  Text(
                    'Acquired: ${game.acquiredUpgrades.length} upgrades',
                    style: TextStyle(color: theme.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatValue(double v) {
    final sign = v >= 0 ? '+' : '';
    if (v.abs() >= 1000000) return '$sign${(v / 1000000).toStringAsFixed(2)}M';
    if (v.abs() >= 1000) return '$sign${(v / 1000).toStringAsFixed(2)}K';
    return '$sign${v.toStringAsFixed(2)}';
  }

  void _showSnack(BuildContext context, String msg, AppThemeData theme) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: theme.positive,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  final GameService game;
  final AppThemeData theme;

  const _StateCard({required this.game, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current State', style: TextStyle(color: theme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _StateLine(label: 'Day', value: '${game.currentDay}', theme: theme),
          _StateLine(label: 'Cash', value: game.cash.toString(), theme: theme),
          _StateLine(label: 'Net Worth', value: game.netWorth.toString(), theme: theme),
          _StateLine(label: 'PP', value: '${game.prestigePoints}', theme: theme),
          _StateLine(label: 'Quota', value: '${game.quotaProgressPercent.toStringAsFixed(1)}%', theme: theme),
          _StateLine(label: 'Companies', value: '${game.unlockedCompanyIds.length}', theme: theme),
          _StateLine(label: 'Robots', value: '${game.robots.length} (${game.robots.where((r) => r.isActive).length} active)', theme: theme),
        ],
      ),
    );
  }
}

class _StateLine extends StatelessWidget {
  final String label;
  final String value;
  final AppThemeData theme;

  const _StateLine({required this.label, required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.textSecondary, fontSize: 12)),
          Text(value, style: TextStyle(color: theme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final AppThemeData theme;
  final List<Widget> children;

  const _Section({required this.title, required this.icon, required this.theme, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.accent, size: 16),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(color: theme.accent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _CheatRow extends StatelessWidget {
  final List<Widget> buttons;
  const _CheatRow({required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: buttons,
    );
  }
}

class _CheatButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final AppThemeData theme;
  final bool wide;

  const _CheatButton({required this.label, required this.onTap, required this.theme, this.wide = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: wide ? null : 80,
        padding: EdgeInsets.symmetric(horizontal: wide ? 16 : 8, vertical: 10),
        decoration: BoxDecoration(
          color: theme.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: theme.accent.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(color: theme.accent, fontSize: 12, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

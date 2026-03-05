import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../l10n/app_localizations.dart';
import '../../models/upgrade.dart';
import '../../services/game_service.dart';
import '../../services/sound_service.dart';
import '../../theme/app_themes.dart';

/// Popup dialog for selecting daily upgrades (roguelike style)
/// All daily upgrades are FREE. Each card has an independent reroll button.
class UpgradePopup extends StatelessWidget {
  const UpgradePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return Consumer<GameService>(
      builder: (context, game, _) {
        if (!game.showUpgradeSelection || game.upgradeChoices.isEmpty) {
          return const SizedBox.shrink();
        }

        final isStarting = game.isStartingUpgradeSelection;
        final isMobile = context.isMobile;

        return Material(
          color: Colors.black.withValues(alpha: 0.85),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: (MediaQuery.of(context).size.width - 32).clamp(0, 900),
                maxHeight: (MediaQuery.of(context).size.height - 48).clamp(0, 650),
              ),
              margin: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  if (isStarting)
                    _StartingHeader()
                  else
                    _Header(day: game.currentDay),
                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    isStarting ? 'CHOOSE A FREE UPGRADE' : 'CHOOSE YOUR DAILY UPGRADE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Boosted rarity hint
                  if (!isStarting)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.cyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.cyan.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'BOOSTED RARITY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.cyan,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Upgrade cards with per-card reroll
                  Flexible(
                    child: isMobile
                        ? _DailyMobileCarousel(
                            upgrades: game.upgradeChoices,
                            dailyRerollsUsed: game.dailyRerollsUsed,
                            freeRollsPerDay: game.freeRollsPerDay,
                            onSelect: (i) {
                              SoundService().playClick();
                              game.selectUpgrade(i);
                            },
                            onReroll: (i) => game.rerollDailySlot(i),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < game.upgradeChoices.length; i++) ...[
                                if (i > 0) const SizedBox(width: 16),
                                Expanded(
                                  child: _DailyUpgradeSlot(
                                    index: i,
                                    upgrade: game.upgradeChoices[i],
                                    onSelect: () {
                                      SoundService().playClick();
                                      game.selectUpgrade(i);
                                    },
                                    onReroll: () => game.rerollDailySlot(i),
                                    canReroll: i < game.dailyRerollsUsed.length && game.dailyRerollsUsed[i] < game.freeRollsPerDay,
                                    rerollsLeft: i < game.dailyRerollsUsed.length ? (game.freeRollsPerDay - game.dailyRerollsUsed[i]).clamp(0, 99) : 0,
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Skip button
                  TextButton(
                    onPressed: () => game.skipUpgradeSelection(),
                    child: Text(
                      'SKIP',
                      style: TextStyle(
                        color: theme.textMuted,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
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

class _StartingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '\u{1F396}\u{FE0F}',
          style: TextStyle(fontSize: 36),
        ),
        const SizedBox(height: 8),
        Text(
          'MARKET VETERAN',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepOrange.withValues(alpha: 0),
                Colors.deepOrange,
                Colors.deepOrange.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final int day;

  const _Header({required this.day});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return Column(
      children: [
        Text(
          'DAY $day COMPLETE',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.cyan,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.cyan.withValues(alpha: 0),
                theme.cyan,
                theme.cyan.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A single daily upgrade slot with its own card + reroll button
class _DailyUpgradeSlot extends StatelessWidget {
  final int index;
  final Upgrade upgrade;
  final VoidCallback onSelect;
  final VoidCallback onReroll;
  final bool canReroll;
  final int rerollsLeft;

  const _DailyUpgradeSlot({
    required this.index,
    required this.upgrade,
    required this.onSelect,
    required this.onReroll,
    required this.canReroll,
    required this.rerollsLeft,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The upgrade card (Expanded so all cards share the same height)
        Expanded(
          child: _UpgradeCard(
            upgrade: upgrade,
            onSelect: onSelect,
          ),
        ),
        const SizedBox(height: 8),
        // Per-card reroll button
        if (canReroll)
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onReroll,
              icon: Icon(Icons.refresh, size: 14, color: theme.cyan),
              label: Text(
                'REROLL ($rerollsLeft)',
                style: TextStyle(
                  color: theme.cyan,
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                backgroundColor: theme.cyan.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: theme.cyan.withValues(alpha: 0.3)),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 32,
            child: Center(
              child: Text(
                'NO REROLLS',
                style: TextStyle(
                  fontSize: 9,
                  color: theme.textMuted.withValues(alpha: 0.5),
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _UpgradeCard extends StatefulWidget {
  final Upgrade upgrade;
  final VoidCallback onSelect;

  const _UpgradeCard({
    required this.upgrade,
    required this.onSelect,
  });

  @override
  State<_UpgradeCard> createState() => _UpgradeCardState();
}

class _UpgradeCardState extends State<_UpgradeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
    final l10n = AppLocalizations.of(context);
    final rarityColor = widget.upgrade.rarityColor;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onSelect,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isHovered
                        ? rarityColor
                        : rarityColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: rarityColor.withValues(alpha: _glowAnimation.value * 0.4),
                      blurRadius: 20 * _glowAnimation.value,
                      spreadRadius: 2 * _glowAnimation.value,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Rarity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: rarityColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: rarityColor.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.upgrade.rarityLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: rarityColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: rarityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          widget.upgrade.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    Text(
                      _getUpgradeName(l10n, widget.upgrade),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Category
                    Text(
                      _getCategoryLabel(widget.upgrade.category),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: theme.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      _getUpgradeDescription(l10n, widget.upgrade),
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // FREE select button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isHovered ? rarityColor : rarityColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'FREE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isHovered ? theme.background : theme.positive,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'SELECT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: _isHovered ? theme.background.withValues(alpha: 0.8) : rarityColor.withValues(alpha: 0.7),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getUpgradeName(AppLocalizations l10n, Upgrade upgrade) {
    if (upgrade.sector != null) {
      return '${l10n.upgradeName(upgrade.id)} (${l10n.sectorTypeName(upgrade.sector!.name)})';
    }
    return l10n.upgradeName(upgrade.id);
  }

  String _getUpgradeDescription(AppLocalizations l10n, Upgrade upgrade) {
    if (upgrade.sector != null) {
      return l10n.upgradeDescription(upgrade.id).replaceAll('{sector}', l10n.sectorTypeName(upgrade.sector!.name));
    }
    return l10n.upgradeDescription(upgrade.id);
  }

  String _getCategoryLabel(UpgradeCategory category) {
    switch (category) {
      case UpgradeCategory.trading: return 'TRADING';
      case UpgradeCategory.information: return 'INFORMATION';
      case UpgradeCategory.portfolio: return 'PORTFOLIO';
      case UpgradeCategory.unlock: return 'UNLOCK';
      case UpgradeCategory.risk: return 'RISK';
      case UpgradeCategory.income: return 'INCOME';
      case UpgradeCategory.time: return 'TIME';
      case UpgradeCategory.quota: return 'QUOTA';
    }
  }
}

/// Mobile carousel for daily upgrade cards (swipeable PageView)
class _DailyMobileCarousel extends StatefulWidget {
  final List<Upgrade> upgrades;
  final List<int> dailyRerollsUsed;
  final int freeRollsPerDay;
  final void Function(int) onSelect;
  final void Function(int) onReroll;

  const _DailyMobileCarousel({
    required this.upgrades,
    required this.dailyRerollsUsed,
    required this.freeRollsPerDay,
    required this.onSelect,
    required this.onReroll,
  });

  @override
  State<_DailyMobileCarousel> createState() => _DailyMobileCarouselState();
}

class _DailyMobileCarouselState extends State<_DailyMobileCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.78,
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return Column(
      children: [
        // Carousel
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.upgrades.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final canReroll = index < widget.dailyRerollsUsed.length && widget.dailyRerollsUsed[index] < widget.freeRollsPerDay;
              final rerollsLeft = index < widget.dailyRerollsUsed.length ? (widget.freeRollsPerDay - widget.dailyRerollsUsed[index]).clamp(0, 99) : 0;

              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double scale = 1.0;
                  double opacity = 1.0;
                  if (_pageController.position.haveDimensions) {
                    final page = _pageController.page ?? 0.0;
                    final diff = (page - index).abs();
                    scale = (1.0 - diff * 0.12).clamp(0.85, 1.0);
                    opacity = (1.0 - diff * 0.4).clamp(0.4, 1.0);
                  }
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                        child: _DailyUpgradeSlot(
                          index: index,
                          upgrade: widget.upgrades[index],
                          onSelect: () => widget.onSelect(index),
                          onReroll: () => widget.onReroll(index),
                          canReroll: canReroll,
                          rerollsLeft: rerollsLeft,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        // Navigation arrows + dots
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left arrow
              GestureDetector(
                onTap: _currentPage > 0
                    ? () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        )
                    : null,
                child: Icon(
                  Icons.chevron_left,
                  size: 28,
                  color: _currentPage > 0
                      ? theme.textSecondary
                      : theme.textMuted.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(width: 12),
              // Dots
              for (int i = 0; i < widget.upgrades.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == _currentPage ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? widget.upgrades[i].rarityColor
                        : theme.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
              const SizedBox(width: 12),
              // Right arrow
              GestureDetector(
                onTap: _currentPage < widget.upgrades.length - 1
                    ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        )
                    : null,
                child: Icon(
                  Icons.chevron_right,
                  size: 28,
                  color: _currentPage < widget.upgrades.length - 1
                      ? theme.textSecondary
                      : theme.textMuted.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

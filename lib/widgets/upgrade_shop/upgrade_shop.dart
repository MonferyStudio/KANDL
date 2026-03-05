import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../l10n/app_localizations.dart';
import '../../models/upgrade.dart';
import '../../services/game_service.dart';
import '../../services/sound_service.dart';
import '../../theme/app_themes.dart';
import 'upgrade_collection.dart';

/// Permanent upgrade shop accessible anytime during gameplay.
/// Upgrades are FREE to pick, but rerolling costs cash (increasing per reroll).
class UpgradeShop extends StatelessWidget {
  const UpgradeShop({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;
    return Consumer<GameService>(
      builder: (context, game, _) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: theme.card,
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 10 : 16,
                ),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: isMobile
                      ? null
                      : const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: isMobile
                    ? _MobileHeader(theme: theme, l10n: l10n, game: game)
                    : _DesktopHeader(theme: theme, l10n: l10n, game: game),
              ),

              // Shop slots or Roll button
              Expanded(
                child: game.shopUpgrades.isEmpty
                    ? _RollButton(
                        rarityPercents: game.getShopRarityPercents(),
                        cost: game.getShopRollCost(),
                        isFree: game.isNextRollFree,
                        canAfford: game.getShopRollCost() == 0 ||
                            game.cash >= BigNumber(game.getShopRollCost().toDouble()),
                        onRoll: () => game.rollShop(),
                        theme: theme,
                      )
                    : isMobile
                        ? _MobileCarousel(
                            upgrades: game.shopUpgrades,
                            onPick: (i) {
                              SoundService().playClick();
                              game.pickShopUpgrade(i);
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (int i = 0; i < game.shopUpgrades.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 12),
                                  Expanded(
                                    child: _ShopUpgradeCard(
                                      upgrade: game.shopUpgrades[i],
                                      onPick: () => game.pickShopUpgrade(i),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
              ),

              // Rarity odds bar (always visible)
              _RarityOddsBar(rarityPercents: game.getShopRarityPercents(), theme: theme),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  game.isNextRollFree
                      ? l10n.freeRollsRemaining(game.freeRollsPerDay - game.shopRollsToday)
                      : l10n.resetsDaily,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textMuted,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Desktop header - original layout
class _DesktopHeader extends StatelessWidget {
  final AppThemeData theme;
  final AppLocalizations l10n;
  final GameService game;

  const _DesktopHeader({required this.theme, required this.l10n, required this.game});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.storefront, color: theme.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.upgradeShopTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.shopSubtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textMuted,
                ),
              ),
            ],
          ),
        ),
        _CollectionButton(theme: theme),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.border),
          ),
          child: Text(
            '\$${game.cash.toDouble().toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.positive,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.close, color: theme.textMuted),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// Mobile header - compact two-row layout
class _MobileHeader extends StatelessWidget {
  final AppThemeData theme;
  final AppLocalizations l10n;
  final GameService game;

  const _MobileHeader({required this.theme, required this.l10n, required this.game});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: title + close
        Row(
          children: [
            Icon(Icons.storefront, color: theme.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.upgradeShopTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                  letterSpacing: 1,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(Icons.close, color: theme.textMuted, size: 22),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Row 2: cash + subtitle + collection
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: theme.border),
              ),
              child: Text(
                '\$${game.cash.toDouble().toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.positive,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.shopSubtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.textMuted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _CollectionButton(theme: theme),
          ],
        ),
      ],
    );
  }
}

/// Mobile carousel for shop upgrade cards
class _MobileCarousel extends StatefulWidget {
  final List<Upgrade> upgrades;
  final void Function(int) onPick;

  const _MobileCarousel({required this.upgrades, required this.onPick});

  @override
  State<_MobileCarousel> createState() => _MobileCarouselState();
}

class _MobileCarouselState extends State<_MobileCarousel> {
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
                        child: _ShopUpgradeCard(
                          upgrade: widget.upgrades[index],
                          onPick: () => widget.onPick(index),
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

/// Collection button to open the upgrade collection dialog
class _CollectionButton extends StatefulWidget {
  final AppThemeData theme;

  const _CollectionButton({required this.theme});

  @override
  State<_CollectionButton> createState() => _CollectionButtonState();
}

class _CollectionButtonState extends State<_CollectionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => showUpgradeCollectionDialog(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.primary.withValues(alpha: 0.15)
                : theme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered
                  ? theme.primary.withValues(alpha: 0.5)
                  : theme.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_mosaic,
                size: 14,
                color: _isHovered ? theme.primary : theme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                AppLocalizations.of(context).collection,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _isHovered ? theme.primary : theme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rarity odds stacked bar showing % for each rarity tier
class _RarityOddsBar extends StatelessWidget {
  final Map<UpgradeRarity, double> rarityPercents;
  final AppThemeData theme;

  const _RarityOddsBar({required this.rarityPercents, required this.theme});

  Color _rarityColor(UpgradeRarity rarity) {
    switch (rarity) {
      case UpgradeRarity.common: return const Color(0xFF9CA3AF);
      case UpgradeRarity.uncommon: return const Color(0xFF22C55E);
      case UpgradeRarity.rare: return const Color(0xFF3B82F6);
      case UpgradeRarity.epic: return const Color(0xFFA855F7);
      case UpgradeRarity.legendary: return const Color(0xFFFBBF24);
    }
  }

  String _rarityLabel(UpgradeRarity rarity) {
    switch (rarity) {
      case UpgradeRarity.common: return 'C';
      case UpgradeRarity.uncommon: return 'U';
      case UpgradeRarity.rare: return 'R';
      case UpgradeRarity.epic: return 'E';
      case UpgradeRarity.legendary: return 'L';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 14,
              child: Row(
                children: UpgradeRarity.values.map((rarity) {
                  final pct = rarityPercents[rarity] ?? 0;
                  if (pct <= 0) return const SizedBox.shrink();
                  return Expanded(
                    flex: (pct * 10).round().clamp(1, 10000),
                    child: Container(
                      color: _rarityColor(rarity).withValues(alpha: 0.6),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: UpgradeRarity.values.map((rarity) {
              final pct = rarityPercents[rarity] ?? 0;
              final color = _rarityColor(rarity);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${_rarityLabel(rarity)} ${pct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Big central roll button shown when shop is empty
class _RollButton extends StatefulWidget {
  final Map<UpgradeRarity, double> rarityPercents;
  final int cost;
  final bool isFree;
  final bool canAfford;
  final VoidCallback onRoll;
  final AppThemeData theme;

  const _RollButton({
    required this.rarityPercents,
    required this.cost,
    required this.isFree,
    required this.canAfford,
    required this.onRoll,
    required this.theme,
  });

  @override
  State<_RollButton> createState() => _RollButtonState();
}

class _RollButtonState extends State<_RollButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _rarityColor(UpgradeRarity rarity) {
    switch (rarity) {
      case UpgradeRarity.common: return const Color(0xFF9CA3AF);
      case UpgradeRarity.uncommon: return const Color(0xFF22C55E);
      case UpgradeRarity.rare: return const Color(0xFF3B82F6);
      case UpgradeRarity.epic: return const Color(0xFFA855F7);
      case UpgradeRarity.legendary: return const Color(0xFFFBBF24);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context);
    final percents = widget.rarityPercents;
    final isMobile = context.isMobile;
    final buttonSize = isMobile ? 140.0 : 180.0;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Roll button
          MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.canAfford ? widget.onRoll : null,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final enabled = widget.canAfford;
                  final baseColors = enabled
                      ? [
                          theme.primary,
                          theme.primary.withValues(alpha: 0.7),
                          const Color(0xFFA855F7),
                        ]
                      : [
                          theme.textMuted.withValues(alpha: 0.4),
                          theme.textMuted.withValues(alpha: 0.3),
                          theme.textMuted.withValues(alpha: 0.2),
                        ];
                  return Transform.scale(
                    scale: enabled
                        ? (_isHovered ? 1.08 : _pulseAnimation.value)
                        : 0.95,
                    child: Container(
                      width: buttonSize,
                      height: buttonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: baseColors,
                        ),
                        boxShadow: enabled
                            ? [
                                BoxShadow(
                                  color: theme.primary.withValues(
                                    alpha: 0.3 +
                                        (_pulseAnimation.value - 0.95) * 2,
                                  ),
                                  blurRadius:
                                      24 + (_pulseAnimation.value - 0.95) * 40,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.casino,
                            size: isMobile ? 36 : 44,
                            color: enabled
                                ? theme.background
                                : theme.background.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.roll,
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              color: enabled
                                  ? theme.background
                                  : theme.background.withValues(alpha: 0.5),
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: theme.background.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.isFree ? l10n.free : BigNumber(widget.cost.toDouble()).toString(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: enabled
                                    ? theme.background
                                    : theme.background.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Rarity percentages table
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 20,
              vertical: isMobile ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              children: [
                Text(
                  l10n.dropRates,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.textMuted,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: UpgradeRarity.values.map((rarity) {
                    final pct = percents[rarity] ?? 0;
                    final color = _rarityColor(rarity);
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 5 : 8),
                      child: Column(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.rarityName(rarity.name),
                            style: TextStyle(
                              fontSize: isMobile ? 8 : 9,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: isMobile ? 9 : 10,
                              fontWeight: FontWeight.bold,
                              color: theme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shop upgrade card with pick button
class _ShopUpgradeCard extends StatefulWidget {
  final Upgrade upgrade;
  final VoidCallback onPick;

  const _ShopUpgradeCard({
    required this.upgrade,
    required this.onPick,
  });

  @override
  State<_ShopUpgradeCard> createState() => _ShopUpgradeCardState();
}

class _ShopUpgradeCardState extends State<_ShopUpgradeCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
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
        onTap: widget.onPick,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isHovered
                        ? rarityColor
                        : rarityColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: rarityColor.withValues(alpha: _glowAnimation.value * 0.3),
                      blurRadius: 16 * _glowAnimation.value,
                      spreadRadius: 1 * _glowAnimation.value,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Rarity badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: rarityColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: rarityColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        widget.upgrade.rarityLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: rarityColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: rarityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          widget.upgrade.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Name
                    Text(
                      _getUpgradeName(l10n, widget.upgrade),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Category
                    Text(
                      l10n.categoryName(widget.upgrade.category.name),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: theme.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description - expands to fill remaining space
                    Expanded(
                      child: Text(
                        _getUpgradeDescription(l10n, widget.upgrade),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textSecondary,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Pick button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isHovered ? rarityColor : rarityColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.pick,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isHovered ? theme.background : rarityColor,
                          letterSpacing: 2,
                        ),
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
}

/// Show the upgrade shop dialog
void showUpgradeShopDialog(BuildContext context) {
  final isMobile = context.isMobile;
  showDialog(
    context: context,
    builder: (ctx) {
      final theme = ctx.watchTheme;
      if (isMobile) {
        return Dialog.fullscreen(
          backgroundColor: theme.card,
          child: const UpgradeShop(),
        );
      }
      return Dialog(
        backgroundColor: theme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const SizedBox(
          width: 700,
          height: 580,
          child: UpgradeShop(),
        ),
      );
    },
  );
}

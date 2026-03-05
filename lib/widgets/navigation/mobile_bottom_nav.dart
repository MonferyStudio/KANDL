import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import '../../services/sound_service.dart';
import '../../services/achievement_service.dart';
import '../../l10n/app_localizations.dart';
import '../achievements/achievements_panel.dart';
import '../fintok/fintok_panel.dart';
import '../upgrade_shop/upgrade_shop.dart';

class MobileBottomNav extends StatefulWidget {
  const MobileBottomNav({super.key});

  @override
  State<MobileBottomNav> createState() => _MobileBottomNavState();
}

class _MobileBottomNavState extends State<MobileBottomNav> {
  late ScrollController _scrollController;
  bool _showLeftIndicator = false;
  bool _showRightIndicator = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkScroll());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _checkScroll();
  }

  void _checkScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final newLeft = position.pixels > 10;
    final newRight = position.pixels < position.maxScrollExtent - 10;
    if (newLeft != _showLeftIndicator || newRight != _showRightIndicator) {
      setState(() {
        _showLeftIndicator = newLeft;
        _showRightIndicator = newRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);

    return Consumer<GameService>(
      builder: (context, game, _) {
        final currentIndex = _viewTypeToIndex(game.currentView);

        return Container(
          decoration: BoxDecoration(
            color: theme.card,
            border: Border(
              top: BorderSide(color: theme.border, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 65,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _NavItem(
                          icon: Icons.dashboard_outlined,
                          activeIcon: Icons.dashboard,
                          label: l10n.dashboard,
                          isActive: currentIndex == 0,
                          onTap: () => game.setView(ViewType.dashboard),
                          theme: theme,
                        ),
                        _NavItem(
                          icon: Icons.store_outlined,
                          activeIcon: Icons.store,
                          label: l10n.market,
                          isActive: currentIndex == 1,
                          onTap: () => game.setView(ViewType.market),
                          theme: theme,
                        ),
                        _NavItem(
                          icon: Icons.account_balance_wallet_outlined,
                          activeIcon: Icons.account_balance_wallet,
                          label: l10n.portfolio,
                          isActive: currentIndex == 2,
                          onTap: () => game.setView(ViewType.portfolio),
                          theme: theme,
                        ),
                        if (game.hasRobots)
                          _NavItem(
                            icon: Icons.smart_toy_outlined,
                            activeIcon: Icons.smart_toy,
                            label: l10n.robots,
                            isActive: currentIndex == 3,
                            onTap: () => game.setView(ViewType.robots),
                            theme: theme,
                          ),
                        // Shop
                        _ShopNavItem(theme: theme),
                        // FinTok
                        _FinTokNavItem(theme: theme),
                        // Achievements
                        _AchievementsNavItem(theme: theme, l10n: l10n),
                      ],
                    ),
                  ),
                  // Left scroll indicator
                  if (_showLeftIndicator)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: _ScrollIndicator(isLeft: true, theme: theme),
                    ),
                  // Right scroll indicator
                  if (_showRightIndicator)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: _ScrollIndicator(isLeft: false, theme: theme),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _viewTypeToIndex(ViewType viewType) {
    switch (viewType) {
      case ViewType.dashboard:
        return 0;
      case ViewType.market:
        return 1;
      case ViewType.portfolio:
        return 2;
      case ViewType.robots:
        return 3;
      case ViewType.trading:
        return 1;
    }
  }
}

class _ScrollIndicator extends StatelessWidget {
  final bool isLeft;
  final AppThemeData theme;

  const _ScrollIndicator({required this.isLeft, required this.theme});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 24,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
            colors: [
              theme.card,
              theme.card.withValues(alpha: 0),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            isLeft ? Icons.chevron_left : Icons.chevron_right,
            size: 16,
            color: theme.textMuted,
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final AppThemeData theme;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? theme.primary : theme.textSecondary;

    return SizedBox(
      width: 72,
      child: GestureDetector(
        onTap: () {
          SoundService().playClick();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? theme.primary.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shop nav item
class _ShopNavItem extends StatelessWidget {
  final AppThemeData theme;

  const _ShopNavItem({required this.theme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: GestureDetector(
        onTap: () {
          SoundService().playClick();
          showUpgradeShopDialog(context);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(
                Icons.storefront,
                color: theme.textSecondary,
                size: 26,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Shop',
              style: TextStyle(
                fontSize: 11,
                color: theme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// FinTok nav item with badge
class _FinTokNavItem extends StatelessWidget {
  final AppThemeData theme;

  const _FinTokNavItem({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, game, _) {
        final tipCount = game.recentTips.length;

        return SizedBox(
          width: 72,
          child: GestureDetector(
            onTap: () {
              SoundService().playClick();
              _showFinTokDialog(context, game);
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Icon(
                        Icons.play_circle_outline,
                        color: theme.textSecondary,
                        size: 26,
                      ),
                    ),
                    if (tipCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.cyan,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$tipCount',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'FinTok',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFinTokDialog(BuildContext context, GameService game) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.play_circle_outline, color: theme.cyan, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'FinTok',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: theme.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Content
              const Expanded(
                child: FinTokPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Achievements nav item with badge
class _AchievementsNavItem extends StatelessWidget {
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _AchievementsNavItem({required this.theme, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Consumer<AchievementService>(
      builder: (context, achievements, _) {
        final unclaimedCount = achievements.unclaimedRewardsCount;

        return SizedBox(
          width: 72,
          child: GestureDetector(
            onTap: () {
              SoundService().playClick();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AchievementsPanel(),
                ),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Icon(
                        Icons.emoji_events,
                        color: theme.textSecondary,
                        size: 26,
                      ),
                    ),
                    if (unclaimedCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.positive,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unclaimedCount',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.achievements,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

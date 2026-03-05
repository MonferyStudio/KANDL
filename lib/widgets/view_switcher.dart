import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/core.dart';
import '../theme/app_themes.dart';
import '../services/game_service.dart';
import '../services/sound_service.dart';
import '../services/achievement_service.dart';
import '../l10n/app_localizations.dart';
import 'achievements/achievements_panel.dart';
import 'fintok/fintok_panel.dart';
import 'tutorial/tutorial_keys.dart';
import 'upgrade_shop/upgrade_shop.dart';

class ViewSwitcher extends StatelessWidget {
  const ViewSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);

    return Consumer<GameService>(
      builder: (context, game, _) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ViewButton(
                icon: Icons.dashboard,
                label: l10n.dashboard,
                isActive: game.currentView == ViewType.dashboard,
                onTap: () => game.setView(ViewType.dashboard),
                theme: theme,
              ),
              _ViewButton(
                key: TutorialKeys.sectorsButton,
                icon: Icons.store,
                label: l10n.market,
                isActive: game.currentView == ViewType.market,
                onTap: () => game.setView(ViewType.market),
                theme: theme,
              ),
              _ViewButton(
                key: TutorialKeys.positionsButton,
                icon: Icons.account_balance_wallet,
                label: l10n.portfolio,
                isActive: game.currentView == ViewType.portfolio,
                onTap: () => game.setView(ViewType.portfolio),
                theme: theme,
              ),
              if (game.hasRobots)
                _ViewButton(
                  icon: Icons.smart_toy,
                  label: l10n.robots,
                  isActive: game.currentView == ViewType.robots,
                  onTap: () => game.setView(ViewType.robots),
                  theme: theme,
                ),
              // Shop button (opens dialog)
              _ShopNavButton(theme: theme),
              // Separator
              Container(
                width: 1,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: theme.border,
              ),
              // FinTok button
              _FinTokNavButton(key: TutorialKeys.finTokButton, theme: theme),
              // Achievements button
              _AchievementsNavButton(key: TutorialKeys.achievementsButton, theme: theme, l10n: l10n),
            ],
          ),
        );
      },
    );
  }
}

class _ViewButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final AppThemeData theme;

  const _ViewButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_ViewButton> createState() => _ViewButtonState();
}

class _ViewButtonState extends State<_ViewButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
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
    final theme = widget.theme;
    final accentColor = theme.primary;

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: () {
          SoundService().playClick();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isActive ? 1.0 : _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? accentColor
                      : accentColor.withValues(alpha: _glowAnimation.value * 0.15),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: !widget.isActive && _glowAnimation.value > 0
                      ? [
                          BoxShadow(
                            color: accentColor.withValues(alpha: _glowAnimation.value * 0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: 16,
                      color: widget.isActive
                          ? theme.background
                          : Color.lerp(
                              theme.textSecondary,
                              accentColor,
                              _glowAnimation.value,
                            ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: widget.isActive
                            ? theme.background
                            : Color.lerp(
                                theme.textSecondary,
                                accentColor,
                                _glowAnimation.value,
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
}

/// Shop navigation button
class _ShopNavButton extends StatefulWidget {
  final AppThemeData theme;

  const _ShopNavButton({required this.theme});

  @override
  State<_ShopNavButton> createState() => _ShopNavButtonState();
}

class _ShopNavButtonState extends State<_ShopNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
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
    final theme = widget.theme;

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: () {
          SoundService().playClick();
          showUpgradeShopDialog(context);
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: _glowAnimation.value * 0.15),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: _glowAnimation.value > 0
                      ? [
                          BoxShadow(
                            color: theme.primary.withValues(alpha: _glowAnimation.value * 0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storefront,
                      size: 16,
                      color: Color.lerp(theme.textSecondary, theme.primary, _glowAnimation.value),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Shop',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.lerp(theme.textSecondary, theme.primary, _glowAnimation.value),
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
}

/// FinTok navigation button with badge
class _FinTokNavButton extends StatefulWidget {
  final AppThemeData theme;

  const _FinTokNavButton({super.key, required this.theme});

  @override
  State<_FinTokNavButton> createState() => _FinTokNavButtonState();
}

class _FinTokNavButtonState extends State<_FinTokNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
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
    final theme = widget.theme;

    return Consumer<GameService>(
      builder: (context, game, _) {
        final tipCount = game.recentTips.length;

        return MouseRegion(
          onEnter: (_) => _controller.forward(),
          onExit: (_) => _controller.reverse(),
          child: GestureDetector(
            onTap: () {
              SoundService().playClick();
              _showFinTokDialog(context, game);
            },
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.cyan.withValues(alpha: _glowAnimation.value * 0.15),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: _glowAnimation.value > 0
                          ? [
                              BoxShadow(
                                color: theme.cyan.withValues(alpha: _glowAnimation.value * 0.3),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 16,
                          color: Color.lerp(theme.textSecondary, theme.cyan, _glowAnimation.value),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'FinTok',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.lerp(theme.textSecondary, theme.cyan, _glowAnimation.value),
                          ),
                        ),
                        if (tipCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.cyan,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$tipCount',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showFinTokDialog(BuildContext context, GameService game) {
    final theme = widget.theme;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          height: 500,
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

/// Achievements navigation button with badge
class _AchievementsNavButton extends StatefulWidget {
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _AchievementsNavButton({super.key, required this.theme, required this.l10n});

  @override
  State<_AchievementsNavButton> createState() => _AchievementsNavButtonState();
}

class _AchievementsNavButtonState extends State<_AchievementsNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
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
    final theme = widget.theme;

    return Consumer<AchievementService>(
      builder: (context, achievements, _) {
        final unclaimedCount = achievements.unclaimedRewardsCount;

        return MouseRegion(
          onEnter: (_) => _controller.forward(),
          onExit: (_) => _controller.reverse(),
          child: GestureDetector(
            onTap: () {
              SoundService().playClick();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AchievementsPanel(),
                ),
              );
            },
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: _glowAnimation.value * 0.15),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: _glowAnimation.value > 0
                          ? [
                              BoxShadow(
                                color: theme.primary.withValues(alpha: _glowAnimation.value * 0.3),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 16,
                          color: Color.lerp(theme.textSecondary, theme.primary, _glowAnimation.value),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.l10n.achievements,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.lerp(theme.textSecondary, theme.primary, _glowAnimation.value),
                          ),
                        ),
                        if (unclaimedCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.positive,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$unclaimedCount',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

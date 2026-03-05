import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/tutorial_service.dart';
import '../../theme/app_themes.dart';
import '../../l10n/app_localizations.dart';

/// Welcome popup with disclaimer and game introduction
class WelcomePopup extends StatefulWidget {
  const WelcomePopup({super.key});

  @override
  State<WelcomePopup> createState() => _WelcomePopupState();
}

class _WelcomePopupState extends State<WelcomePopup> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Complete welcome and start tutorial
      context.read<TutorialService>().completeWelcome();
      Navigator.of(context).pop();
    }
  }

  void _skipAll() {
    context.read<TutorialService>().skipAll();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watchTheme;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: appTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: appTheme.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: appTheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: appTheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  Icon(
                    _currentPage == 0 ? Icons.rocket_launch : Icons.warning_amber_rounded,
                    color: _currentPage == 0 ? appTheme.primary : appTheme.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _currentPage == 0 ? l10n.welcomeToKandl : l10n.disclaimer,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: appTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page content
            Flexible(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _GameIntroPage(theme: appTheme, l10n: l10n),
                  _DisclaimerPage(theme: appTheme, l10n: l10n),
                ],
              ),
            ),

            // Footer with buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: appTheme.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Column(
                children: [
                  // Page indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PageDot(isActive: _currentPage == 0, theme: appTheme),
                      const SizedBox(width: 8),
                      _PageDot(isActive: _currentPage == 1, theme: appTheme),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Buttons
                  Row(
                    children: [
                      // Skip all tutorials button (only on disclaimer page)
                      if (_currentPage == 1)
                        TextButton(
                          onPressed: _skipAll,
                          child: Text(
                            l10n.skipTutorial,
                            style: TextStyle(
                              color: appTheme.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      const Spacer(),
                      // Continue button
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appTheme.primary,
                          foregroundColor: appTheme.background,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == 1 ? l10n.startPlaying : l10n.continueText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Disclaimer page - WARNING about real stock trading
class _DisclaimerPage extends StatelessWidget {
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _DisclaimerPage({required this.theme, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // THIS IS JUST A GAME - Big prominent text
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primary.withValues(alpha: 0.2),
                    theme.secondary.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.primary, width: 2),
              ),
              child: Text(
                'THIS IS JUST A GAME',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: theme.primary,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Big warning box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.negative.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.negative, width: 2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: theme.negative, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.importantWarning,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.negative,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Highlighted statistic
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.negative.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.negative.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '89%',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: theme.negative,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          l10n.tradersLoseMoney,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Additional warnings
          _WarningItem(
            icon: Icons.casino,
            text: l10n.disclaimerGambling,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _WarningItem(
            icon: Icons.school,
            text: l10n.disclaimerEducational,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _WarningItem(
            icon: Icons.money_off,
            text: l10n.disclaimerNotAdvice,
            theme: theme,
          ),

          const SizedBox(height: 20),

          // Final note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.border),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: theme.orange, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.disclaimerRemember,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final AppThemeData theme;

  const _WarningItem({
    required this.icon,
    required this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.orange, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: theme.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Game introduction page
class _GameIntroPage extends StatelessWidget {
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _GameIntroPage({required this.theme, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game logo/title area
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primary, theme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'KANDL',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Game description
          Text(
            l10n.gameDescription,
            style: TextStyle(
              fontSize: 15,
              color: theme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Features list
          _FeatureItem(
            icon: Icons.show_chart,
            title: l10n.featureTrading,
            description: l10n.featureTradingDesc,
            theme: theme,
            color: theme.positive,
          ),
          const SizedBox(height: 12),
          _FeatureItem(
            icon: Icons.flag,
            title: l10n.featureQuota,
            description: l10n.featureQuotaDesc,
            theme: theme,
            color: theme.orange,
          ),
          const SizedBox(height: 12),
          _FeatureItem(
            icon: Icons.auto_awesome,
            title: l10n.featureUpgrades,
            description: l10n.featureUpgradesDesc,
            theme: theme,
            color: theme.purple,
          ),
          const SizedBox(height: 12),
          _FeatureItem(
            icon: Icons.emoji_events,
            title: l10n.featureAchievements,
            description: l10n.featureAchievementsDesc,
            theme: theme,
            color: theme.cyan,
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final AppThemeData theme;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.theme,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDot extends StatelessWidget {
  final bool isActive;
  final AppThemeData theme;

  const _PageDot({required this.isActive, required this.theme});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? theme.primary : theme.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

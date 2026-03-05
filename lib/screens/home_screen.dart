import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/core.dart';
import '../services/game_service.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';
import '../services/achievement_service.dart';
import '../services/tutorial_service.dart';
import '../models/notification_item.dart';
import '../widgets/hero_cards/metrics_bar.dart';
import '../widgets/stats_bar/stats_bar.dart';
import '../widgets/view_switcher.dart';
import '../widgets/dashboard_view/dashboard_view.dart';
import '../widgets/market_view/market_view.dart';
import '../widgets/trading_view/trading_view.dart';
import '../widgets/positions_view/positions_view.dart';
import '../widgets/robots_view/robots_view.dart';
import '../widgets/info_panel/info_panel.dart';
import '../widgets/info_panel/info_panel_sheet.dart';
import '../widgets/navigation/mobile_bottom_nav.dart';
import '../widgets/upgrade_popup/upgrade_popup.dart';
import '../widgets/news_popup/news_popup.dart';
import '../widgets/news_popup/mid_day_news_popup.dart';
import '../widgets/prestige_shop/prestige_shop.dart';
import '../widgets/active_effects_bar.dart';
import '../widgets/styled_background.dart';
import '../widgets/settings_menu/settings_menu.dart';
import '../widgets/notifications/notifications.dart';
import '../widgets/informant/informant_popup.dart';
import '../widgets/tutorial/welcome_popup.dart';
import '../widgets/tutorial/tutorial_keys.dart';
import '../widgets/tutorial/tutorial_overlay.dart';
import '../widgets/casual_overlays.dart';
import '../services/sound_service.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showNotificationPanel = false;

  @override
  void initState() {
    super.initState();
    // Start game and connect notification callbacks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = context.read<GameService>();
      final notifications = context.read<NotificationService>();

      // Connect price alert callback
      game.onPriceAlert = (stockName, stockId, percentChange) {
        notifications.addPriceAlert(
          stockName: stockName,
          stockId: stockId,
          percentChange: percentChange,
        );
      };

      // Connect news alert callback
      game.onNewsAlert = (headline, isPositive, companyId) {
        notifications.addNewsAlert(
          headline: headline,
          isPositive: isPositive,
          companyId: companyId,
        );
      };

      // Connect warning alert callback
      game.onWarningAlert = (title, message, stockId) {
        notifications.addWarning(
          title: title,
          message: message,
          stockId: stockId,
        );
      };

      // Connect event alert callback
      game.onEventAlert = (eventName, description, isPositive) {
        notifications.addEventAlert(
          eventName: eventName,
          description: description,
          isPositive: isPositive,
        );
      };

      // Connect bonus alert callback
      game.onBonusAlert = (title, amount) {
        notifications.addBonusAlert(
          title: title,
          amount: amount,
        );
      };

      // Connect achievement service for notifications
      final achievements = context.read<AchievementService>();
      achievements.onAchievementUnlocked = (name, icon, reward) {
        notifications.addAchievementAlert(
          achievementName: name,
          achievementIcon: icon,
          reward: reward,
        );
      };

      // Connect game callbacks to achievement service
      game.onTradeCompleted = ({required bool profitable, required double profit}) {
        achievements.recordTrade(profitable: profitable, profit: profit);
      };

      game.onDayEnd = ({
        required double dailyProfit,
        required double portfolioValue,
        required int sectorsInvested,
        required int tradesThisDay,
        required double cashOnHand,
        required int upgradesOwned,
      }) {
        achievements.recordDayEnd(
          dailyProfit: dailyProfit,
          portfolioValue: portfolioValue,
          sectorsInvested: sectorsInvested,
          tradesThisDay: tradesThisDay,
          cashOnHand: cashOnHand,
          upgradesOwned: upgradesOwned,
        );
      };

      game.onYearEnd = () {
        achievements.recordYearEnd();
        notifications.clearAll();
      };

      game.onQuotaMet = () {
        achievements.recordQuotaMet();
        SoundService().playQuotaFanfare();
        ConfettiOverlayState.trigger(intensity: 40);
      };

      game.onPrestige = () {
        achievements.recordPrestige();
      };

      game.onShortOpened = () {
        achievements.recordShortPosition();
      };

      game.onAllInTrade = () {
        achievements.recordAllInTrade();
      };

      game.onInformantTipBought = () {
        achievements.recordInformantTip();
      };

      game.onChallengeCompleted = () {
        achievements.recordChallengeCompleted();
      };

      game.onTokenPlaced = () {
        achievements.recordTokenPlaced();
      };

      game.onDipBuy = () {
        achievements.recordDipBuy();
      };

      game.onSellHigh = () {
        achievements.recordSellHigh();
      };

      game.onMaxPositionsFilled = () {
        achievements.recordMaxPositions();
      };

      // Wire prestige point rewards from achievements to game
      achievements.onPrestigePointsEarned = (points) {
        game.addPrestigePoints(points);
      };

      // Sync meta progression bonuses from achievements to game
      game.applyMetaProgression(achievements.metaProgression);

      // Listen for achievement changes to update meta progression
      achievements.addListener(() {
        game.applyMetaProgression(achievements.metaProgression);
      });

      game.startGame();
    });
  }

  void _toggleNotificationPanel() {
    setState(() {
      _showNotificationPanel = !_showNotificationPanel;
    });
  }

  void _handleNotificationTap(NotificationItem notification) {
    final game = context.read<GameService>();

    switch (notification.actionType) {
      case NotificationAction.navigateStock:
        if (notification.actionData != null) {
          game.selectCompany(notification.actionData!);
          game.setView(ViewType.trading);
        }
        break;
      case NotificationAction.navigateSector:
        if (notification.actionData != null) {
          game.selectSector(notification.actionData!);
        }
        break;
      case NotificationAction.openPositions:
        game.setView(ViewType.portfolio);
        break;
      case NotificationAction.openNews:
        game.setMarketSubTab(2);
        game.setView(ViewType.market);
        break;
      case NotificationAction.openFintok:
        // TODO: Open FinTok feed (Phase 5)
        break;
      case NotificationAction.openAchievements:
        // TODO: Open achievements page (Phase 2)
        break;
      case NotificationAction.claimReward:
        // TODO: Handle reward claiming
        break;
      case NotificationAction.none:
        break;
    }

    setState(() {
      _showNotificationPanel = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        final theme = settings.currentTheme;

        // Sync locale to GameService for localized content (tips, farewells)
        context.read<GameService>().setLocale(settings.currentLocale.languageCode);

        return ResponsiveBuilder(
          builder: (context, screenType, constraints) {
            final isMobile = screenType == ScreenType.mobile;

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: theme.background,
              drawer: const SettingsMenu(),
              bottomNavigationBar: isMobile ? const MobileBottomNav() : null,
              body: Stack(
                children: [
                  // Styled background with grid and glows
                  const StyledBackground(),

                  // Main content
                  SafeArea(
                    bottom: !isMobile, // Let bottom nav handle safe area on mobile
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      child: isMobile
                          ? _buildMobileLayout(theme)
                          : _buildDesktopLayout(theme),
                    ),
                  ),

                  // InfoPanel as bottom sheet on mobile
                  if (isMobile) const InfoPanelSheet(),

                  // News popup overlay (shown at start of each day)
                  const NewsPopup(),

                  // Mid-day news popup overlay (shown halfway through the day)
                  const MidDayNewsPopup(),

                  // Upgrade selection popup overlay (shown at end of each day)
                  const UpgradePopup(),

                  // Prestige shop overlay (shown on quota failure)
                  const PrestigeShop(),

                  // Secret informant popup (random visits)
                  const _InformantPopupWrapper(),

                  // Tutorial welcome popup (first launch)
                  const _WelcomePopupWrapper(),

                  // Contextual tutorial overlay (after welcome)
                  const _ContextualTutorialWrapper(),

                  // Casual overlays
                  const MilestonePopup(),
                  const AthFlash(),
                  const EndOfDayNarrative(),
                  const ConfettiOverlay(),
                  const FloatingTextOverlay(),

                  // Notification toast (top right)
                  NotificationToast(
                    onTap: () => _handleNotificationTap(
                      context.read<NotificationService>().currentToast!,
                    ),
                  ),

                  // Notification panel overlay
                  if (_showNotificationPanel)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => setState(() => _showNotificationPanel = false),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  if (_showNotificationPanel)
                    Positioned(
                      top: isMobile ? 60 : 70,
                      left: isMobile ? 8 : null,
                      right: isMobile ? 8 : 16,
                      child: NotificationPanel(
                        onClose: () => setState(() => _showNotificationPanel = false),
                        onNotificationTap: _handleNotificationTap,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Desktop/Tablet layout with side-by-side InfoPanel
  Widget _buildDesktopLayout(dynamic theme) {
    return Column(
      children: [
        // Top bar with menu button
        Row(
          children: [
            // Menu button
            _MenuButton(
              theme: theme,
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(width: 8),
            // Notification bell
            NotificationBell(onTap: _toggleNotificationPanel),
            const SizedBox(width: 12),
            // Metrics Bar
            Expanded(child: RepaintBoundary(child: MetricsBar(key: TutorialKeys.metricsBar))),
          ],
        ),
        const SizedBox(height: 16),

        // Stats Bar
        StatsBar(key: TutorialKeys.statsBar),
        const SizedBox(height: 8),

        // Active Effects Bar (only shown when effects are active)
        const ActiveEffectsBar(),
        const SizedBox(height: 8),

        // View Switcher
        ViewSwitcher(key: TutorialKeys.viewSwitcher),
        const SizedBox(height: 16),

        // Main Content with Info Panel
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main View
              Expanded(
                flex: 3,
                child: _buildCurrentView(),
              ),
              const SizedBox(width: 16),
              // Info Panel
              const Expanded(
                flex: 1,
                child: InfoPanel(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Mobile layout without InfoPanel (shown as bottom sheet instead)
  Widget _buildMobileLayout(dynamic theme) {
    return Column(
      children: [
        // Top bar with menu button
        Row(
          children: [
            // Menu button
            _MenuButton(
              theme: theme,
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(width: 6),
            // Notification bell
            NotificationBell(onTap: _toggleNotificationPanel, size: 20),
            const SizedBox(width: 6),
            // Metrics Bar (scrollable on mobile)
            const Expanded(child: RepaintBoundary(child: MetricsBar())),
          ],
        ),
        const SizedBox(height: 8),

        // Stats Bar (scrollable on mobile)
        const RepaintBoundary(child: StatsBar()),
        const SizedBox(height: 6),

        // Active Effects Bar
        const RepaintBoundary(child: ActiveEffectsBar()),
        const SizedBox(height: 6),

        // Main Content (full width, no InfoPanel)
        Expanded(
          child: _buildCurrentView(),
        ),
      ],
    );
  }

  Widget _buildCurrentView() {
    return Consumer<GameService>(
      builder: (context, game, _) {
        switch (game.currentView) {
          case ViewType.dashboard:
            return const DashboardView();
          case ViewType.market:
            return const MarketView();
          case ViewType.portfolio:
            return const PositionsView();
          case ViewType.robots:
            return const RobotsView();
          case ViewType.trading:
            return const TradingView();
        }
      },
    );
  }
}

class _MenuButton extends StatelessWidget {
  final dynamic theme;
  final VoidCallback onTap;

  const _MenuButton({required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final size = isMobile ? 40.0 : 44.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.border),
        ),
        child: Icon(
          Icons.menu,
          color: theme.textSecondary,
          size: isMobile ? 20 : 22,
        ),
      ),
    );
  }
}

/// Wrapper to show informant popup when available
class _InformantPopupWrapper extends StatefulWidget {
  const _InformantPopupWrapper();

  @override
  State<_InformantPopupWrapper> createState() => _InformantPopupWrapperState();
}

class _InformantPopupWrapperState extends State<_InformantPopupWrapper> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, game, _) {
        // Show dialog when informant popup flag is true
        if (game.showInformantPopup && !_dialogShown) {
          _dialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const InformantPopup(),
            ).then((_) {
              setState(() {
                _dialogShown = false;
              });
            });
          });
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Wrapper to show welcome/tutorial popup on first launch
class _WelcomePopupWrapper extends StatefulWidget {
  const _WelcomePopupWrapper();

  @override
  State<_WelcomePopupWrapper> createState() => _WelcomePopupWrapperState();
}

class _WelcomePopupWrapperState extends State<_WelcomePopupWrapper> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorialService>(
      builder: (context, tutorial, _) {
        // Show welcome dialog on first launch
        if (tutorial.shouldShowWelcome && !_dialogShown) {
          _dialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const WelcomePopup(),
            ).then((_) {
              setState(() {
                _dialogShown = false;
              });
            });
          });
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Wrapper for contextual tutorial overlays
class _ContextualTutorialWrapper extends StatefulWidget {
  const _ContextualTutorialWrapper();

  @override
  State<_ContextualTutorialWrapper> createState() => _ContextualTutorialWrapperState();
}

class _ContextualTutorialWrapperState extends State<_ContextualTutorialWrapper> {
  ViewType? _lastView;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tutorial = context.watch<TutorialService>();
    final game = context.watch<GameService>();
    final currentView = game.currentView;

    // Auto-advance when view changes and matches expected view
    if (_lastView != currentView) {
      _lastView = currentView;
      // Use post-frame callback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tutorial.onViewChanged(currentView);
      });
    }

    // Only show if tutorial is active and welcome is completed
    if (!tutorial.isActive || !tutorial.welcomeCompleted) {
      return const SizedBox.shrink();
    }

    // Check if current step requires a specific view
    final requiredView = tutorial.requiredViewForCurrentStep;
    if (requiredView != null && currentView != requiredView) {
      return const SizedBox.shrink(); // Wait for user to navigate
    }

    // Get step data for current step
    final stepData = _getStepData(tutorial.currentStep, l10n);
    if (stepData == null) {
      return const SizedBox.shrink();
    }

    // For prompt steps that wait for navigation, don't advance on button click
    final isPromptStep = tutorial.isWaitingForNavigation;

    return TutorialOverlay(
      stepData: stepData,
      onComplete: isPromptStep ? null : () => tutorial.nextStep(),
      onSkip: () => tutorial.skipAll(),
    );
  }

  TutorialStepData? _getStepData(TutorialStep step, AppLocalizations l10n) {
    switch (step) {
      case TutorialStep.dashboardIntro:
        return TutorialStepData(
          title: l10n.tutorialDashboardTitle,
          description: l10n.tutorialDashboardDesc,
          targetKey: null, // No specific target, general intro
          tooltipAlignment: Alignment.center,
        );

      case TutorialStep.metricsBar:
        return TutorialStepData(
          title: l10n.tutorialMetricsTitle,
          description: l10n.tutorialMetricsDesc,
          targetKey: TutorialKeys.metricsBar,
          tooltipAlignment: Alignment.bottomCenter,
        );

      case TutorialStep.statsBar:
        return TutorialStepData(
          title: l10n.tutorialStatsTitle,
          description: l10n.tutorialStatsDesc,
          targetKey: TutorialKeys.statsBar,
          tooltipAlignment: Alignment.bottomCenter,
        );

      case TutorialStep.positionStatistics:
        return TutorialStepData(
          title: l10n.tutorialPositionStatisticsTitle,
          description: l10n.tutorialPositionStatisticsDesc,
          targetKey: TutorialKeys.positionStatistics,
          tooltipAlignment: Alignment.bottomCenter,
        );

      case TutorialStep.tradingPerformance:
        return TutorialStepData(
          title: l10n.tutorialTradingPerformanceTitle,
          description: l10n.tutorialTradingPerformanceDesc,
          targetKey: TutorialKeys.tradingPerformance,
          tooltipAlignment: Alignment.bottomCenter,
        );

      case TutorialStep.riskMetrics:
        return TutorialStepData(
          title: l10n.tutorialRiskMetricsTitle,
          description: l10n.tutorialRiskMetricsDesc,
          targetKey: TutorialKeys.riskMetrics,
          tooltipAlignment: Alignment.bottomCenter,
        );

      case TutorialStep.milestoneProgress:
        return TutorialStepData(
          title: l10n.tutorialMilestoneProgressTitle,
          description: l10n.tutorialMilestoneProgressDesc,
          targetKey: TutorialKeys.milestoneProgress,
          tooltipAlignment: Alignment.bottomCenter,
        );

      case TutorialStep.challengesPanel:
        return TutorialStepData(
          title: l10n.tutorialChallengesPanelTitle,
          description: l10n.tutorialChallengesPanelDesc,
          targetKey: TutorialKeys.challengesPanel,
          tooltipAlignment: Alignment.bottomCenter,
        );

      case TutorialStep.recentTrades:
        return TutorialStepData(
          title: l10n.tutorialRecentTradesTitle,
          description: l10n.tutorialRecentTradesDesc,
          targetKey: TutorialKeys.recentTrades,
          tooltipAlignment: Alignment.topCenter,
        );

      case TutorialStep.positionNews:
        return TutorialStepData(
          title: l10n.tutorialPositionNewsTitle,
          description: l10n.tutorialPositionNewsDesc,
          targetKey: TutorialKeys.positionNews,
          tooltipAlignment: Alignment.topCenter,
        );

      case TutorialStep.sectorsPrompt:
        return TutorialStepData(
          title: l10n.tutorialSectorsTitle,
          description: l10n.tutorialSectorsDesc,
          targetKey: TutorialKeys.sectorsButton,
          tooltipAlignment: Alignment.bottomCenter,
        );

      case TutorialStep.stocksPrompt:
        return TutorialStepData(
          title: l10n.tutorialStocksTitle,
          description: l10n.tutorialStocksDesc,
          targetKey: TutorialKeys.stocksButton,
          tooltipAlignment: Alignment.bottomCenter,
        );

      case TutorialStep.tradingPrompt:
        return TutorialStepData(
          title: l10n.tutorialTradingTitle,
          description: l10n.tutorialTradingDesc,
          targetKey: TutorialKeys.tradingButton,
          tooltipAlignment: Alignment.bottomCenter,
        );

      case TutorialStep.sectorsIntro:
        return TutorialStepData(
          title: l10n.tutorialSectorsIntroTitle,
          description: l10n.tutorialSectorsIntroDesc,
          targetKey: TutorialKeys.firstSectorCard,
          tooltipAlignment: Alignment.bottomCenter,
        );

      case TutorialStep.stocksIntro:
        return TutorialStepData(
          title: l10n.tutorialStocksIntroTitle,
          description: l10n.tutorialStocksIntroDesc,
          targetKey: TutorialKeys.firstStockRow,
          tooltipAlignment: Alignment.bottomCenter,
        );

      case TutorialStep.tradingIntro:
        return TutorialStepData(
          title: l10n.tutorialTradingIntroTitle,
          description: l10n.tutorialTradingIntroDesc,
          targetKey: null,
          tooltipAlignment: Alignment.center,
        );

      case TutorialStep.firstBuyPrompt:
        return TutorialStepData(
          title: l10n.tutorialFirstBuyTitle,
          description: l10n.tutorialFirstBuyDesc,
          targetKey: TutorialKeys.buyButton,
          tooltipAlignment: Alignment.topCenter,
        );

      case TutorialStep.positionsIntro:
        return TutorialStepData(
          title: l10n.tutorialPositionsIntroTitle,
          description: l10n.tutorialPositionsIntroDesc,
          targetKey: TutorialKeys.positionsButton,
          tooltipAlignment: Alignment.bottomCenter,
        );

      case TutorialStep.upgradesIntro:
        return TutorialStepData(
          title: l10n.tutorialUpgradesTitle,
          description: l10n.tutorialUpgradesDesc,
          targetKey: null,
          tooltipAlignment: Alignment.center,
        );

      case TutorialStep.prestigeShopIntro:
        return TutorialStepData(
          title: l10n.tutorialPrestigeTitle,
          description: l10n.tutorialPrestigeDesc,
          targetKey: null,
          tooltipAlignment: Alignment.center,
        );

      case TutorialStep.achievementsIntro:
        return TutorialStepData(
          title: l10n.tutorialAchievementsTitle,
          description: l10n.tutorialAchievementsDesc,
          targetKey: TutorialKeys.achievementsButton,
          tooltipAlignment: Alignment.bottomCenter,
        );

      case TutorialStep.fintokIntro:
        return TutorialStepData(
          title: l10n.tutorialFintokTitle,
          description: l10n.tutorialFintokDesc,
          targetKey: TutorialKeys.finTokButton,
          tooltipAlignment: Alignment.bottomCenter,
        );

      case TutorialStep.informantIntro:
        return TutorialStepData(
          title: l10n.tutorialInformantTitle,
          description: l10n.tutorialInformantDesc,
          targetKey: null,
          tooltipAlignment: Alignment.center,
        );

      case TutorialStep.welcome:
      case TutorialStep.completed:
        return null;
    }
  }
}


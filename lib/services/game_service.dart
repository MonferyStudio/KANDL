import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../data/sectors.dart';
import '../data/companies.dart';
import '../data/upgrades.dart';
import '../data/prestige_upgrades.dart';
import '../data/talent_tree_data.dart';
import '../data/special_events.dart';
import '../data/influencers.dart';
import '../data/informant_data.dart';
import '../data/daily_challenges.dart';
import '../l10n/app_localizations.dart';
import 'news_generator.dart';
import 'analyst_generator.dart';

/// Main game service - handles all game logic
class GameService extends ChangeNotifier {
  @override
  void notifyListeners() {
    _invalidateCache();
    super.notifyListeners();
  }

  // === CONFIGURATION ===
  static const double secondsPerDay = 300.0; // 5 minutes per day (roguelike pacing)
  static const double marketUpdateInterval = 2.0; // Update market every 2 seconds
  static const int daysPerYear = 30; // 30 days per year for roguelike pacing
  static const double startingCash = 1000; // Start with $1,000
  static const double startingQuota = 100; // First quota is $100 (profits only)
  static const double tradingFeePercent = 1.0;
  static const double quotaIncreasePercent = 0.25; // 25% increase per quota period

  // === GAME STATE ===
  int _currentDay = 1;
  int _currentYear = 1;
  double _dayTimer = secondsPerDay;
  double _marketUpdateTimer = 0;
  BigNumber _cash = BigNumber(startingCash);
  BigNumber _quotaTarget = BigNumber(startingQuota);
  BigNumber _quotaProgress = BigNumber.zero;
  int _failedQuotas = 0;
  double _skipQuotaBonusPercent = 0.15; // Base 15% bonus on excess when skipping quota
  double _gameSpeed = 1.0;
  bool _isPaused = true;
  bool _isEndOfDay = false; // True when market closed at 19h, waiting for player to advance
  bool _showUpgradeSelection = false; // True when daily free upgrade popup should be shown
  List<Upgrade> _upgradeChoices = []; // Current daily free upgrade choices (3)
  List<int> _dailyRerollsUsed = [0, 0, 0]; // Rerolls used per daily slot

  // === UPGRADE SHOP (permanent, accessible anytime) ===
  List<Upgrade> _shopUpgrades = []; // 3 upgrades displayed in the shop
  int _shopRollsToday = 0; // Number of rolls done today
  int _freeRollsPerDay = 1; // Free rolls per day (base 1, prestige adds more)
  static const int baseRollCost = 50; // Base cost for first paid roll

  // === UPGRADEABLE SETTINGS ===
  int _daysPerQuota = 3; // Base: 3 days per quota period
  double _feeReduction = 0.0; // Total fee reduction from upgrades
  int _maxPositions = 3; // Maximum positions (default 3)
  double _quotaReduction = 0.0; // Quota reduction from upgrades
  int _extraDaySeconds = 0; // Extra seconds per day from upgrades
  double _passiveIncome = 0.0; // Passive income per day

  // === UNLOCKED CONTENT ===
  final Set<String> _unlockedCompanyIds = {}; // Unlocked company IDs
  final List<AcquiredUpgrade> _acquiredUpgrades = []; // All acquired upgrades

  // === MARKET STATE ===
  final Map<String, StockState> _stockStates = {};
  final Map<String, double> _sectorTrends = {};
  double _marketSentiment = 0.0;

  // === PORTFOLIO STATE ===
  final List<Position> _positions = [];
  BigNumber _totalRealizedPnL = BigNumber.zero;
  int _totalTrades = 0;
  int _winningTrades = 0;

  // === EXPENSE TRACKING (impacts performance) ===
  BigNumber _totalOpeningExpenses = BigNumber.zero; // Shop roll costs
  BigNumber _totalRobotExpenses = BigNumber.zero;   // Robot upgrade costs

  // === NEWS STATE ===
  final List<NewsItem> _newsItems = [];
  static const int maxNewsItems = 50; // Keep only last 50 news items
  bool _showNewsPopup = false; // True when news popup should be shown at day start
  List<NewsItem> _todayNews = []; // Today's news for the popup
  bool _midDayNewsTriggered = false; // Track if mid-day news was already triggered
  bool _showMidDayNewsPopup = false; // True when mid-day news popup should show
  final List<NewsItem> _midDayNews = []; // Mid-day news items

  // === ANALYST DATA ===
  final Map<String, AnalystData> _analystDataCache = {};
  int _lastAnalystUpdateDay = 0;

  // === TRADE HISTORY ===
  final List<TradeRecord> _tradeHistory = [];
  static const int maxTradeHistory = 100;
  int _tradeIdCounter = 0;

  // === MARKET INDICATORS ===
  MarketIndicators? _marketIndicators;

  // === MARKET REGIME ===
  MarketRegimeData _marketRegime = MarketRegimeData(
    currentRegime: MarketRegime.neutral,
    regimeStrength: 0.0,
    daysInCurrentRegime: 0,
    lastRegimeChange: DateTime.now(),
  );

  // === PRESTIGE STATE ===
  int _prestigeLevel = 0;
  BigNumber _lifetimeEarnings = BigNumber.zero;
  int _prestigePoints = 0; // Earned by surviving days (1 per day)
  int _totalPrestigePoints = 0; // Total earned across all runs
  double _startingCashBonus = 0; // Bonus from prestige upgrades
  bool _showPrestigeShop = false; // Show prestige shop on quota fail
  final Set<String> _purchasedTalentNodes = {}; // IDs of purchased talent tree nodes (v2)

  // === TOKEN STATE ===
  final List<Token> _tokens = []; // Owned tokens (dividend, robot)
  int _tokenIdCounter = 0;

  // === ROBOT TRADERS STATE ===
  final List<RobotTrader> _robots = [];
  int _robotIdCounter = 0;
  BigNumber _peakNetWorth = BigNumber.zero; // High-water mark for robot budget cap
  int _maxRobotSlots = 0;
  double _robotSpeedBonus = 0.0; // 0.0 to 0.50, robots trade faster
  // Global robot upgrades (from redesigned Automation branch)
  double _robotUpgradeCostReduction = 0.0; // 0.0 to 0.30
  int _robotStartLevel = 0; // 0-3, all robots start at this level
  int _robotAutoCollect = 0; // 0=none, 1/5/999=auto-collect N robots
  double _robotSeedMoney = 0.0; // starting budget for all robots

  // === ACTIVE GAMEPLAY EFFECTS ===
  double _activeFeeMultiplier = 1.0; // Multiplier for trading fees (1.0 = normal)
  int _feeMultiplierDaysLeft = 0;
  bool _shortSellingBanned = false; // True if short selling is currently banned
  int _shortBanDaysLeft = 0;
  double _activeUpgradeDiscount = 0.0; // Discount on upgrade costs (0.0 to 1.0)
  int _upgradeDiscountDaysLeft = 0;
  bool _circuitBreakerActive = false; // True if trading is halted
  double _circuitBreakerTimer = 0; // Seconds remaining on circuit breaker
  double _activeVolatilityMultiplier = 1.0; // Volatility multiplier
  int _volatilityMultiplierDaysLeft = 0;
  int _activePositionLimit = 0; // 0 = no limit (use _maxPositions), >0 = forced limit
  int _positionLimitDaysLeft = 0;
  bool _signalJammerActive = false; // True = signals are scrambled
  int _signalJammerDaysLeft = 0;
  double _analystPrecision = 0.5; // 0.5 = 50% base accuracy, upgrades add more

  // === SPECIAL EVENTS STATE ===
  EventData? _activeSpecialEvent; // Currently active special event
  int _activeEventDaysLeft = 0; // Days remaining for active event
  final List<String> _recentEventIds = []; // Recent event IDs (for cooldown)
  static const int _maxRecentEvents = 10;

  // === LOCALE ===
  String _locale = 'en';

  // === FINTOK STATE ===
  final List<Influencer> _influencers = []; // All influencers (active and departed)
  final List<InfluencerTip> _tips = []; // All tips
  static const int _maxTips = 30; // Keep last 30 tips
  static const int _baseMaxActiveInfluencers = 6; // Base max active influencers
  int get _maxActiveInfluencers => _baseMaxActiveInfluencers + _extraActiveInfluencers;
  final Set<String> _usedInfluencerTemplateIds = {}; // Templates already used
  final Set<String> _followedInfluencerIds = {}; // Influencers the player follows
  // Scheduled tips: (influencerId, dayProgress at which to fire)
  final List<({String influencerId, double targetProgress})> _scheduledTips = [];

  // === SECRET INFORMANT STATE ===
  InformantState _informantState = InformantState();
  bool _showInformantPopup = false;
  static const int _minDaysBetweenInformantVisits = 3;
  static const double _informantVisitChance = 0.20; // 20% chance per day

  // === DAILY CHALLENGES STATE ===
  DailyChallengeState _challengeState = DailyChallengeState();
  int _dailyTradesCount = 0;       // Trades made today
  double _dailyProfitAmount = 0.0; // Profit made today
  double _dailyVolumeTraded = 0.0; // Total volume traded today
  int _dailyDipBuys = 0;           // Dip buys today
  int _dailySellHighs = 0;         // High sells today
  int _dailyLosingTrades = 0;      // Losing trades today

  // === LEGACY PRESTIGE EFFECTS STATE (kept for old code paths) ===
  int _upgradeRerollsPerDay = 0;
  int _upgradeRerollsUsedToday = 0;
  bool _guaranteedRareFirst = false;
  bool _usedGuaranteedRare = false;
  int _quotaFailFreebies = 0;
  double _keepCashOnFailPercent = 0.0;
  int _extraUpgradeChoices = 0;
  bool _shortBanImmunity = false;
  int _startingUpgrades = 0;
  bool _isStartingUpgradeSelection = false;
  double _prestigePointMultiplier = 0.0;
  double _cashInterestRate = 0.0;
  double _shopRarityBoost = 0.0;
  double _sectorAmplifier = 0.0;

  // === TALENT TREE EFFECT STATE (reset per run, re-applied from purchased nodes) ===
  double _profitMultiplier = 0.0;
  double _signalAccuracy = 0.0;
  double _lossReduction = 0.0;
  double _crashImpactReduction = 0.0;
  double _maxLossPerTrade = 1.0; // 1.0 = no cap
  double _holdBonus = 0.0;
  int _survivesWipeout = 0;
  double _eventLossReduction = 0.0;
  double _keepCapitalOnWipe = 0.0;
  double _robotWinRateBonus = 0.0;
  bool _newsCategoryPreview = false;
  bool _tipExactPercent = false;
  bool _flagBadTips = false;
  bool _priceForesight = false;
  int _freeTipsPerDay = 0;
  double _tipPrecisionMultiplier = 0.0;
  double _tipCostReduction = 0.0;
  double _shortTermProfitBonus = 0.0;
  double _diversificationBonus = 0.0;
  bool _disinfoShield = false;
  int _blockBadEvents = 0;
  int _blockBadEventsUsed = 0; // runtime: how many blocks used this run
  int _freeTipsUsedToday = 0; // runtime: free tips used today
  // Intelligence branch effects
  int _extraActiveInfluencers = 0;
  int _extraNewsPerDay = 0;
  double _fintokAccuracyBonus = 0.0;
  final Map<String, double> _sectorProfitBonuses = {};
  final Map<String, double> _sectorLossShields = {};
  final Map<String, double> _sectorPassiveIncomes = {};
  final Set<String> _sectorCapstones = {};
  final Map<String, int> _sectorTierUnlocks = {};
  // Trader branch effects
  int _extraPositionSlots = 0;
  bool _unlimitedPositions = false;
  bool _stopLossUnlock = false;
  bool _takeProfitUnlock = false;
  bool _trailingStopUnlock = false;
  bool _partialTakeProfitUnlock = false;
  bool _safetyNetUnlock = false;
  double _quickFlipBonus = 0.0;
  bool _scalperNoFees = false;
  double _holdBonus3d = 0.0;
  double _holdBonus5d = 0.0;
  double _holdBonus7d = 0.0;
  bool _limitOrdersUnlock = false;
  bool _smartOrdersUnlock = false;
  double _streakBonusPerWin = 0.0; // % bonus per consecutive winning trade (talent tree)
  int _streakMaxStacks = 0;        // max consecutive wins that count (talent tree)
  bool _streakKeepOnLoss = false;   // halve streak on loss instead of reset (talent tree)
  double _leverageMax = 1.0;
  bool _marginShield = false;
  double _compoundInterestRate = 0.0;
  // Survival branch effects
  int _extraLives = 0;
  int _livesRemaining = 0; // runtime: decremented when used
  int _extraQuotaDays = 0;
  double _survivalQuotaReduction = 0.0; // from talent tree, stacks with upgrade _quotaReduction
  double _skipQuotaBonus = 0.0;
  double _skipStreakBonus = 0.0;
  int _overtimeDays = 0;
  double _secondWindBonus = 0.0;
  int _secondWindDaysLeft = 0; // runtime: days of second wind active
  double _resurrectQuotaReduction = 0.0;
  double _earlyFinishPP = 0.0;
  double _earlyFinishPP2 = 0.0;
  bool _speedrunPPMultiplier = false;
  double _streakProfitBonus = 0.0;
  bool _streakPersists = false;
  int _quotaStreak = 0; // runtime: consecutive quotas met
  int _consecutiveSkips = 0; // runtime: consecutive skip quota count
  bool _allQuotasEarly = true; // runtime: true if every quota was completed early
  int _overtimeDaysLeft = 0; // runtime: emergency extra days remaining on current failed quota
  bool _inOvertime = false; // runtime: currently in overtime period
  // Trader branch tracking (runtime, not saved — resets per run)
  final Map<String, int> _positionOpenDay = {}; // When positions were opened (game day)
  final Map<String, double> _positionLeverage = {}; // Leverage per position
  final Map<String, double> _positionHighPrice = {}; // Trailing stop: highest price since open
  final Set<String> _partialTpTaken = {}; // Positions that already took partial TP
  LimitOrder? _pendingLimitOrder; // Active limit order (1 at a time)
  bool _safetyNetUsed = false; // Safety net: first SL trigger softened (once per run)

  // === TRADING STRATEGY BONUSES ===
  int _consecutiveWins = 0; // Consecutive profitable trades
  double _momentumBonus = 0.0; // Bonus from Momentum Rider (e.g., 0.10 = 10%)
  int _momentumStreak = 0; // Required streak for momentum bonus
  double _contrarianBonus = 0.0; // Bonus from Contrarian (e.g., 0.20 = 20%)
  double _contrarianThreshold = 0.0; // Drop threshold for contrarian (e.g., 0.10 = 10%)
  double _dayTradeBonus = 0.0; // Bonus for same-day trades
  final Set<String> _boughtTodayCompanies = {}; // Companies bought today (for day trader)
  double _lossRecoveryPercent = 0.0; // Tax refund: percent of losses recovered
  double _dailyRealizedLosses = 0.0; // Track daily losses for tax refund
  final Set<String> _contrarianBuys = {}; // Stocks bought at a dip (for contrarian bonus)
  double _upgradeStockBonusRate = 0.0; // Bonus shares from upgrades (within run)
  int _extraMorningNews = 0; // Extra news at morning from upgrades
  int _extraMidDayNews = 0; // Extra news at mid-day from upgrades

  // === REMOVED: short selling now unlocked by default ===

  // === STOP LOSS / TAKE PROFIT ===
  bool _hasStopLoss = false; // Unlocked via upgrade
  bool _hasTakeProfit = false; // Unlocked via upgrade
  double _stopLossPercent = 0.10; // Default 10%, configurable by player
  double _takeProfitPercent = 0.20; // Default 20%, configurable by player
  bool _stopLossEnabled = false; // Player toggle
  bool _takeProfitEnabled = false; // Player toggle
  bool _trailingStopEnabled = false; // Trailing mode toggle (requires _trailingStopUnlock)

  // === META PROGRESSION BONUSES (persistent across runs) ===
  double _metaStockBonusRate = 0.0; // Bonus shares % when buying (0.0 to 0.25)
  double _metaCommissionReduction = 0.0; // Extra commission reduction (0.0 to 0.75)
  double _metaQuotaReduction = 0.0; // Extra quota reduction (0.0 to 0.50)
  double _metaStartingCashBonus = 0.0; // Extra starting cash
  double _metaInformantBonus = 0.0; // Increased informant visit chance (0.0 to 0.50)
  double _metaFintokAccuracyBonus = 0.0; // Increased FinTok accuracy (0.0 to 0.30)
  int _metaLuckyStartingShares = 0; // Free shares at game start
  bool _metaVipStatus = false; // First upgrade of each year is Legendary
  bool _vipUsedThisYear = false; // Tracks if VIP legendary was used this year
  double _metaUpgradeLuck = 0.0; // Upgrade rarity boost from achievements (0.0 to 0.25)
  double _metaInsurance = 0.0; // Loss reduction from achievements (0.0 to 0.30)
  double _metaInterestRate = 0.0; // Daily cash interest from achievements (0.0 to 0.01)
  int _metaExtraRerolls = 0; // Extra free rerolls from achievements

  // === CASUAL FEATURES STATE ===
  // Personal bests (persist across full reset)
  BigNumber _bestNetWorth = BigNumber.zero;
  double _bestDayProfit = 0.0;
  double _bestSingleTrade = 0.0;
  int _bestWinStreak = 0;
  int _mostDaysSurvived = 0;
  bool _isNewPersonalBest = false; // Transient — golden flash on new ATH

  // Net worth milestones
  final Set<int> _reachedMilestones = {};
  int? _pendingMilestone; // Milestone to show popup for
  static const List<int> milestoneValues = [
    2500, 5000, 10000, 25000, 50000,                              // Early game
    100000, 250000, 500000, 1000000,                               // Mid game
    2500000, 5000000, 10000000, 25000000, 50000000, 100000000,     // Late game
    500000000, 1000000000, 10000000000, 100000000000, 1000000000000, // Endgame / idle
  ];

  // Favorite stocks
  final Set<String> _favoriteStockIds = {};

  // Run summary (populated on quota fail)
  Map<String, dynamic>? _runSummary;

  // Local leaderboard (best runs)
  final List<Map<String, dynamic>> _leaderboard = [];
  static const int maxLeaderboardEntries = 20;

  // Encouragement message (set at end of day or after trade)
  String? _encouragementMessage;

  // End-of-day narrative summary
  String? _endOfDayNarrative;

  // Track daily net worth change for end-of-day narrative
  double _dayStartNetWorth = 0.0;

  // Pending floating texts for passive income / robot gains
  final List<MapEntry<String, bool>> _pendingFloatingTexts = []; // value: text, key: isPositive
  List<MapEntry<String, bool>> get pendingFloatingTexts => _pendingFloatingTexts;
  void consumeFloatingTexts() { _pendingFloatingTexts.clear(); }

  // === CURRENT VIEW ===
  ViewType _currentView = ViewType.dashboard;
  int _marketSubTab = 0; // 0=Sectors, 1=Stocks, 2=News
  String? _selectedSectorId;
  String? _selectedCompanyId;

  // === NOTIFICATION CALLBACKS ===
  // Callbacks to send notifications (set by home_screen)
  void Function(String stockName, String stockId, double percentChange)? onPriceAlert;
  void Function(String headline, bool isPositive, String? companyId)? onNewsAlert;
  void Function(String title, String message, String? stockId)? onWarningAlert;
  void Function(String eventName, String description, bool isPositive)? onEventAlert;
  void Function(String title, String amount)? onBonusAlert;

  // Track last notified price for alerts (to avoid spamming)
  final Map<String, double> _lastNotifiedPriceChange = {};
  double _priceAlertThreshold = 10.0; // % change triggers alert (configurable)
  double _priceAlertCooldown = 15.0; // Minimum % change since last alert

  // === ACHIEVEMENT CALLBACKS ===
  void Function({required bool profitable, required double profit})? onTradeCompleted;
  void Function({required double dailyProfit, required double portfolioValue, required int sectorsInvested, required int tradesThisDay, required double cashOnHand, required int upgradesOwned})? onDayEnd;
  void Function()? onYearEnd;
  void Function()? onQuotaMet;
  void Function()? onPrestige;
  void Function()? onShortOpened;
  void Function()? onAllInTrade;
  void Function(double portfolioValue)? onPortfolioValueChanged;
  void Function()? onInformantTipBought;
  void Function()? onChallengeCompleted;
  void Function()? onTokenPlaced;
  void Function()? onDipBuy;
  void Function()? onSellHigh;
  void Function()? onMaxPositionsFilled;

  Timer? _gameTimer;
  final Random _random = Random();

  // === GETTERS ===
  int get currentDay => _currentDay;
  int get currentYear => _currentYear;
  String get dayTimerDisplay => NumberFormatter.formatTime(_dayTimer);
  double get dayProgress => (effectiveDayDuration - _dayTimer) / effectiveDayDuration;

  // Market time display (8:00 - 19:00)
  String get marketTimeDisplay {
    // Progress through the day (0 to 1)
    final progress = (effectiveDayDuration - _dayTimer) / effectiveDayDuration;

    // Market opens at 8:00 and closes at 19:00 (11 hours)
    final marketStartHour = 8;
    final marketDurationHours = 11;

    // Calculate current market time in minutes
    final totalMarketMinutes = marketDurationHours * 60;
    final currentMarketMinutes = (progress * totalMarketMinutes).toInt();

    // Convert to hours and minutes
    final hours = marketStartHour + (currentMarketMinutes ~/ 60);
    final minutes = currentMarketMinutes % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  BigNumber get cash => _cash;
  BigNumber get quotaTarget => _quotaTarget;
  BigNumber get quotaProgress => _quotaProgress;
  double get quotaProgressPercent =>
      effectiveQuotaTarget.isZero ? 0 : (_quotaProgress.toDouble() / effectiveQuotaTarget.toDouble()) * 100;
  int get daysUntilQuota {
    // Quota is evaluated at the end of days 3, 6, 9... (when currentDay % daysPerQuota == 0)
    final remainder = _currentDay % _daysPerQuota;
    if (remainder == 0) return 0; // Today is quota evaluation day
    return _daysPerQuota - remainder;
  }
  int get failedQuotas => _failedQuotas;
  int get daysPerQuota => _daysPerQuota; // Getter for current quota duration
  bool get canSkipQuota => _quotaProgress >= effectiveQuotaTarget && !_showPrestigeShop && !_isEndOfDay;
  double get gameSpeed => _gameSpeed;
  bool get isPaused => _isPaused;
  bool get isEndOfDay => _isEndOfDay;
  bool get showUpgradeSelection => _showUpgradeSelection;
  bool get isStartingUpgradeSelection => _isStartingUpgradeSelection;
  List<Upgrade> get upgradeChoices => List.unmodifiable(_upgradeChoices);
  List<int> get dailyRerollsUsed {
    // Ensure list matches upgrade choices length (handles old saves with fewer slots)
    while (_dailyRerollsUsed.length < _upgradeChoices.length) {
      _dailyRerollsUsed.add(0);
    }
    return List.unmodifiable(_dailyRerollsUsed);
  }

  // Shop getters
  List<Upgrade> get shopUpgrades => List.unmodifiable(_shopUpgrades);
  int get shopRollsToday => _shopRollsToday;
  int get freeRollsPerDay => _freeRollsPerDay + _metaExtraRerolls;
  bool get isShopAvailable => _shopUpgrades.isNotEmpty;
  double get shopRarityBoost => _shopRarityBoost;

  /// Get the effective rarity percentages for shop rolls (accounting for prestige boost)
  Map<UpgradeRarity, double> getShopRarityPercents() {
    const baseWeights = {
      UpgradeRarity.common: 50.0,
      UpgradeRarity.uncommon: 30.0,
      UpgradeRarity.rare: 12.0,
      UpgradeRarity.epic: 5.0,
      UpgradeRarity.legendary: 1.0,
    };

    final adjusted = <UpgradeRarity, double>{};
    for (final entry in baseWeights.entries) {
      double w = entry.value;
      final totalRarityBoost = _shopRarityBoost + _metaUpgradeLuck;
      if (totalRarityBoost > 0) {
        switch (entry.key) {
          case UpgradeRarity.common:
            w *= (1 - totalRarityBoost * 0.4).clamp(0.1, 1.0);
          case UpgradeRarity.uncommon:
            w *= 1.0;
          case UpgradeRarity.rare:
            w *= (1 + totalRarityBoost * 0.6);
          case UpgradeRarity.epic:
            w *= (1 + totalRarityBoost * 0.8);
          case UpgradeRarity.legendary:
            w *= (1 + totalRarityBoost * 1.0);
        }
      }
      adjusted[entry.key] = w;
    }

    final total = adjusted.values.reduce((a, b) => a + b);
    return adjusted.map((k, v) => MapEntry(k, v / total * 100));
  }
  int get prestigeLevel => _prestigeLevel;
  int get prestigePoints => _prestigePoints;
  int get totalPrestigePoints => _totalPrestigePoints;
  double get startingCashBonus => _startingCashBonus;
  bool get showPrestigeShop => _showPrestigeShop;
  Set<String> get purchasedTalentNodes => Set.unmodifiable(_purchasedTalentNodes);
  double get profitMultiplier => _profitMultiplier;
  double get signalAccuracy => _signalAccuracy;
  double get lossReduction => _lossReduction;
  double get crashImpactReduction => _crashImpactReduction;
  double get maxLossPerTrade => _maxLossPerTrade;
  double get holdBonus => _holdBonus;
  int get survivesWipeout => _survivesWipeout;
  double get eventLossReduction => _eventLossReduction;
  double get keepCapitalOnWipe => _keepCapitalOnWipe;
  double get robotWinRateBonus => _robotWinRateBonus;
  double get robotSpeedBonus => _robotSpeedBonus;
  bool get newsCategoryPreview => _newsCategoryPreview;
  bool get tipExactPercent => _tipExactPercent;
  bool get flagBadTips => _flagBadTips;
  bool get priceForesight => _priceForesight;
  int get freeTipsPerDay => _freeTipsPerDay;
  int get freeTipsRemaining => (_freeTipsPerDay - _freeTipsUsedToday).clamp(0, _freeTipsPerDay);
  double get tipPrecisionMultiplier => _tipPrecisionMultiplier;
  double get tipCostReduction => _tipCostReduction;
  double get shortTermProfitBonus => _shortTermProfitBonus;
  double get diversificationBonus => _diversificationBonus;
  bool get disinfoShield => _disinfoShield;
  int get blockBadEvents => _blockBadEvents;
  int get blockBadEventsRemaining => (_blockBadEvents - _blockBadEventsUsed).clamp(0, _blockBadEvents);
  Map<String, double> get sectorProfitBonuses => Map.unmodifiable(_sectorProfitBonuses);
  Map<String, double> get sectorLossShields => Map.unmodifiable(_sectorLossShields);
  Map<String, double> get sectorPassiveIncomes => Map.unmodifiable(_sectorPassiveIncomes);
  Set<String> get sectorCapstones => Set.unmodifiable(_sectorCapstones);
  Map<String, int> get sectorTierUnlocks => Map.unmodifiable(_sectorTierUnlocks);
  // Trader branch getters
  int get extraPositionSlots => _extraPositionSlots;
  bool get unlimitedPositions => _unlimitedPositions;
  bool get stopLossUnlock => _stopLossUnlock;
  bool get takeProfitUnlock => _takeProfitUnlock;
  bool get trailingStopUnlock => _trailingStopUnlock;
  bool get partialTakeProfitUnlock => _partialTakeProfitUnlock;
  bool get safetyNetUnlock => _safetyNetUnlock;
  double get quickFlipBonus => _quickFlipBonus;
  bool get scalperNoFees => _scalperNoFees;
  double get holdBonus3d => _holdBonus3d;
  double get holdBonus5d => _holdBonus5d;
  double get holdBonus7d => _holdBonus7d;
  bool get limitOrdersUnlock => _limitOrdersUnlock;
  bool get smartOrdersUnlock => _smartOrdersUnlock;
  double get streakBonusPerWin => _streakBonusPerWin;
  int get streakMaxStacks => _streakMaxStacks;
  bool get streakKeepOnLoss => _streakKeepOnLoss;
  double get leverageMax => _leverageMax;
  bool get marginShield => _marginShield;
  double get compoundInterestRate => _compoundInterestRate;
  // Survival branch getters
  int get extraLives => _extraLives;
  int get livesRemaining => _livesRemaining;
  int get extraQuotaDays => _extraQuotaDays;
  double get survivalQuotaReduction => _survivalQuotaReduction;
  double get skipQuotaBonus => _skipQuotaBonus;
  double get skipStreakBonus => _skipStreakBonus;
  int get overtimeDays => _overtimeDays;
  double get secondWindBonus => _secondWindBonus;
  int get secondWindDaysLeft => _secondWindDaysLeft;
  double get resurrectQuotaReduction => _resurrectQuotaReduction;
  double get earlyFinishPP => _earlyFinishPP;
  double get earlyFinishPP2 => _earlyFinishPP2;
  bool get speedrunPPMultiplier => _speedrunPPMultiplier;
  double get streakProfitBonus => _streakProfitBonus;
  bool get streakPersists => _streakPersists;
  int get quotaStreak => _quotaStreak;
  // Automation global getters
  double get robotUpgradeCostReduction => _robotUpgradeCostReduction;
  int get robotStartLevel => _robotStartLevel;
  int get robotAutoCollect => _robotAutoCollect;
  double get robotSeedMoney => _robotSeedMoney;
  LimitOrder? get pendingLimitOrder => _pendingLimitOrder;
  Map<String, double> get positionLeverage => Map.unmodifiable(_positionLeverage);
  BigNumber get lifetimeEarnings => _lifetimeEarnings;

  // Meta Progression getters (persistent bonuses across all runs)
  double get metaStockBonusRate => _metaStockBonusRate;
  double get metaCommissionReduction => _metaCommissionReduction;
  double get metaQuotaReduction => _metaQuotaReduction;
  double get metaStartingCashBonus => _metaStartingCashBonus;
  double get metaInformantBonus => _metaInformantBonus;
  double get metaFintokAccuracyBonus => _metaFintokAccuracyBonus;
  int get metaLuckyStartingShares => _metaLuckyStartingShares;
  bool get metaVipStatus => _metaVipStatus;

  // Upgrade-based stock bonus rate (within run only)
  double get upgradeStockBonusRate => _upgradeStockBonusRate;

  // Combined stock bonus rate (meta + upgrades, capped at 25%)
  double get totalStockBonusRate => (_metaStockBonusRate + _upgradeStockBonusRate).clamp(0.0, 0.25);

  // Special event getters
  EventData? get activeSpecialEvent => _activeSpecialEvent;
  int get activeEventDaysLeft => _activeEventDaysLeft;
  bool get hasActiveEvent => _activeSpecialEvent != null && _activeEventDaysLeft > 0;

  // FinTok getters
  List<Influencer> get activeInfluencers => _influencers.where((i) => i.isActive).toList();
  List<Influencer> get allInfluencers => List.unmodifiable(_influencers);
  List<InfluencerTip> get recentTips => List.unmodifiable(_tips);

  /// Get influencer by ID
  Influencer? getInfluencerById(String id) {
    try {
      return _influencers.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Set locale for localized content (tips, bios, farewells)
  void setLocale(String locale) {
    _locale = locale;
  }

  /// Check if following an influencer
  bool isFollowingInfluencer(String id) => _followedInfluencerIds.contains(id);

  /// Toggle follow/unfollow for an influencer
  void toggleFollowInfluencer(String id) {
    if (_followedInfluencerIds.contains(id)) {
      _followedInfluencerIds.remove(id);
    } else {
      _followedInfluencerIds.add(id);
    }
    notifyListeners();
  }

  // Secret Informant getters
  InformantState get informantState => _informantState;
  bool get showInformantPopup => _showInformantPopup;
  bool get isInformantAvailable => _informantState.isAvailable;
  List<InformantTip> get currentInformantTips => _informantState.currentTips;
  List<InformantTip> get purchasedInformantTips => _informantState.purchasedTips;

  // Daily Challenge getters
  DailyChallengeState get challengeState => _challengeState;
  List<DailyChallenge> get activeChallenges => _challengeState.activeChallenges;
  int get completedChallengesCount => _challengeState.completedToday;
  int get totalChallengesCount => _challengeState.totalToday;
  bool get allChallengesComplete => _challengeState.allCompletedToday;
  int get unclaimedChallengeRewards => _challengeState.unclaimedRewards;

  // Token-related getters
  List<Token> get tokens => List.unmodifiable(_tokens);
  List<Token> get unplacedTokens => _tokens.where((t) => !t.isPlaced).toList();
  List<Token> get placedTokens => _tokens.where((t) => t.isPlaced).toList();
  List<Token> get dividendTokens => _tokens.where((t) => t.type == TokenType.dividend).toList();
  List<Token> get robotTokens => _tokens.where((t) => t.type == TokenType.robot).toList();

  /// Get tokens placed on a specific company
  List<Token> getTokensOnCompany(String companyId) {
    return _tokens.where((t) => t.placedOnCompanyId == companyId).toList();
  }

  /// Check if a company has a specific token type
  bool companyHasToken(String companyId, TokenType type) {
    return _tokens.any((t) => t.placedOnCompanyId == companyId && t.type == type);
  }

  // Robot trader getters
  List<RobotTrader> get robots => List.unmodifiable(_robots);
  int get maxRobotSlots => _maxRobotSlots;
  bool get hasRobots => _maxRobotSlots > 0;

  // Upgrade-related getters
  /// Effective fee percent considering upgrades, meta bonuses, AND active gameplay effects
  double get effectiveFeePercent {
    // Combine upgrade fee reduction and meta commission reduction (capped at 90%)
    final totalReduction = (_feeReduction + _metaCommissionReduction).clamp(0.0, 0.9);
    return (tradingFeePercent * (1 - totalReduction) * _activeFeeMultiplier).clamp(0, 10);
  }
  /// Max positions considering active limits
  int get maxPositions {
    if (_unlimitedPositions && _activePositionLimit <= 0) return 999;
    final base = _activePositionLimit > 0 ? _activePositionLimit : _maxPositions;
    return base + _extraPositionSlots;
  }
  double get quotaReduction => _quotaReduction;
  int get extraDaySeconds => _extraDaySeconds;
  double get passiveIncome => _passiveIncome;
  List<AcquiredUpgrade> get acquiredUpgrades => List.unmodifiable(_acquiredUpgrades);
  Set<String> get unlockedCompanyIds => Set.unmodifiable(_unlockedCompanyIds);

  /// Get effective day duration (with upgrades)
  double get effectiveDayDuration => secondsPerDay + _extraDaySeconds;

  /// Get effective quota target (with reductions from upgrades AND meta bonuses)
  BigNumber get effectiveQuotaTarget {
    // Combine upgrade quota reduction and meta quota reduction (capped at 60%)
    final totalReduction = (_quotaReduction + _metaQuotaReduction + _survivalQuotaReduction).clamp(0.0, 0.6);
    return _quotaTarget.multiplyByDouble(1 - totalReduction);
  }

  // New prestige effects getters
  bool get canRerollUpgrades => _upgradeRerollsPerDay > 0 && _upgradeRerollsUsedToday < _upgradeRerollsPerDay;
  int get rerollsRemaining => (_upgradeRerollsPerDay - _upgradeRerollsUsedToday).clamp(0, 99);
  bool get hasSecondChance => _quotaFailFreebies > 0;
  int get upgradeChoiceCount => 3 + _extraUpgradeChoices;
  bool get shortBanImmunity => _shortBanImmunity;

  // Trading strategy getters
  int get consecutiveWins => _consecutiveWins;
  bool get hasMomentumBonus => _momentumBonus > 0 && _consecutiveWins >= _momentumStreak;
  double get currentMomentumBonus => hasMomentumBonus ? _momentumBonus : 0.0;

  /// Short selling is always unlocked (no longer gated by upgrade)
  bool get shortSellingUnlocked => true;

  /// Check if a company is unlocked
  bool isCompanyUnlocked(String companyId) {
    final company = getCompanyById(companyId);
    if (company == null) return false;
    // Starter tier is always unlocked
    if (company.tier == CompanyTier.starter) return true;
    // Otherwise check if specifically unlocked
    return _unlockedCompanyIds.contains(companyId);
  }

  /// Get all unlocked companies
  List<CompanyData> get unlockedCompanies {
    return allCompanies.where((c) => isCompanyUnlocked(c.id)).toList();
  }

  /// Get unlocked companies by sector
  List<CompanyData> getUnlockedCompaniesBySector(String sectorId) {
    return allCompanies.where((c) => c.sectorId == sectorId && isCompanyUnlocked(c.id)).toList();
  }

  ViewType get currentView => _currentView;
  int get marketSubTab => _marketSubTab;
  String? get selectedSectorId => _selectedSectorId;
  String? get selectedCompanyId => _selectedCompanyId;

  List<Position> get positions => List.unmodifiable(_positions);
  int get totalTrades => _totalTrades;
  double get winRate => _totalTrades > 0 ? _winningTrades / _totalTrades : 0;
  BigNumber get totalRealizedPnL => _totalRealizedPnL;
  BigNumber get totalOpeningExpenses => _totalOpeningExpenses;
  BigNumber get totalRobotExpenses => _totalRobotExpenses;
  BigNumber get totalExpenses => _totalOpeningExpenses + _totalRobotExpenses;

  // === CASUAL FEATURE GETTERS ===
  BigNumber get bestNetWorth => _bestNetWorth;
  double get bestDayProfit => _bestDayProfit;
  double get bestSingleTrade => _bestSingleTrade;
  int get bestWinStreak => _bestWinStreak;
  int get mostDaysSurvived => _mostDaysSurvived;
  bool get isNewPersonalBest => _isNewPersonalBest;
  int? get pendingMilestone => _pendingMilestone;
  Set<String> get favoriteStockIds => Set.unmodifiable(_favoriteStockIds);
  Map<String, dynamic>? get runSummary => _runSummary;
  List<Map<String, dynamic>> get leaderboard => List.unmodifiable(_leaderboard);
  String? get encouragementMessage => _encouragementMessage;
  String? get endOfDayNarrative => _endOfDayNarrative;

  void dismissMilestone() { _pendingMilestone = null; notifyListeners(); }
  void dismissPersonalBest() { _isNewPersonalBest = false; notifyListeners(); }

  void toggleFavorite(String companyId) {
    if (_favoriteStockIds.contains(companyId)) {
      _favoriteStockIds.remove(companyId);
    } else {
      _favoriteStockIds.add(companyId);
    }
    notifyListeners();
  }

  bool isFavorite(String companyId) => _favoriteStockIds.contains(companyId);

  /// Player title based on performance (key for l10n lookup)
  String get playerTitle {
    final wr = winRate * 100;
    if (_totalTrades == 0) return 'title_beginner';
    if (_totalTrades < 10) return 'title_novice';
    if (wr >= 70 && _totalTrades >= 50) return 'title_legend';
    if (wr >= 65 && _totalTrades >= 30) return 'title_expert';
    if (wr >= 60 && _totalTrades >= 20) return 'title_veteran';
    if (wr >= 55) return 'title_trader';
    if (_totalTrades >= 15) return 'title_apprentice';
    return 'title_novice';
  }

  /// Daily objective: how much you need to earn per remaining day to meet quota
  double get dailyObjectiveAmount {
    final daysLeft = daysUntilQuota;
    if (daysLeft <= 0) return 0;
    final remaining = effectiveQuotaTarget - _quotaProgress;
    if (remaining <= BigNumber.zero) return 0;
    return remaining.toDouble() / daysLeft;
  }

  /// Prestige preview: how many PP you'd earn if you quit now
  int get prestigePreview => _prestigePoints;

  /// Trade of the day: recommend the stock with best analyst consensus
  String? get tradeOfTheDayId {
    // Don't show until the player has made at least one trade
    if (_totalTrades == 0) return null;
    // Ensure analyst data exists for all unlocked stocks
    for (final companyId in _stockStates.keys) {
      if (isCompanyUnlocked(companyId)) {
        getAnalystData(companyId);
      }
    }
    if (_analystDataCache.isEmpty) return null;
    String? bestId;
    double bestScore = -999;
    for (final entry in _analystDataCache.entries) {
      if (!isCompanyUnlocked(entry.key)) continue;
      final r = entry.value.consensusRating;
      final score = r == AnalystRating.strongBuy ? 2.0
          : r == AnalystRating.buy ? 1.0
          : r == AnalystRating.hold ? 0.0
          : r == AnalystRating.sell ? -1.0
          : -2.0;
      if (score > bestScore) {
        bestScore = score;
        bestId = entry.key;
      }
    }
    return bestScore > 0 ? bestId : null;
  }

  /// Sell all shares of a specific stock (long position)
  bool sellAllOfStock(String companyId) {
    final position = _positions
        .where((p) => p.company.id == companyId && p.type == PositionType.long)
        .firstOrNull;
    if (position == null || !position.hasShares) return false;
    return sell(position.company, position.shares);
  }

  /// Check and update personal bests / milestones after net worth changes
  void _checkPersonalBestsAndMilestones() {
    final nw = netWorth;

    // Check ATH net worth
    if (nw > _bestNetWorth) {
      _bestNetWorth = nw;
      _isNewPersonalBest = true;
    }

    // Check milestones
    for (final milestone in milestoneValues) {
      if (!_reachedMilestones.contains(milestone) && nw.toDouble() >= milestone) {
        _reachedMilestones.add(milestone);
        _pendingMilestone = milestone;
      }
    }

    // Track best win streak
    if (_consecutiveWins > _bestWinStreak) {
      _bestWinStreak = _consecutiveWins;
    }
  }

  /// Generate end-of-day narrative based on today's performance
  void _generateEndOfDayNarrative() {
    final dayChange = netWorth.toDouble() - _dayStartNetWorth;
    final pctChange = _dayStartNetWorth > 0 ? (dayChange / _dayStartNetWorth) * 100 : 0;
    final trades = _dailyTradesCount;

    if (dayChange > 0 && pctChange > 5) {
      _endOfDayNarrative = 'narrative_great_day';
    } else if (dayChange > 0) {
      _endOfDayNarrative = 'narrative_good_day';
    } else if (dayChange < 0 && pctChange < -5) {
      _endOfDayNarrative = 'narrative_tough_day';
    } else if (dayChange < 0) {
      _endOfDayNarrative = 'narrative_small_loss';
    } else {
      _endOfDayNarrative = 'narrative_flat_day';
    }

    // Add encouragement based on context
    if (trades == 0 && _positions.isEmpty) {
      _encouragementMessage = 'hint_invest_cash';
    } else if (_quotaProgress >= effectiveQuotaTarget) {
      _encouragementMessage = 'encourage_quota_met';
    } else if (_consecutiveWins >= 3) {
      _encouragementMessage = 'encourage_hot_streak';
    } else if (dayChange < 0) {
      _encouragementMessage = 'encourage_dont_panic';
    } else if (dayChange > 0 && trades > 0) {
      _encouragementMessage = 'encourage_nice_trades';
    } else {
      _encouragementMessage = null;
    }
  }

  /// Generate run summary when a run ends
  void _generateRunSummary() {
    final losingTrades = _totalTrades - _winningTrades;
    final bestTradeRecord = bestTrade;
    final worstTradeRecord = worstTrade;

    _runSummary = {
      'days': _currentDay,
      'year': _currentYear,
      'totalTrades': _totalTrades,
      'winningTrades': _winningTrades,
      'losingTrades': losingTrades,
      'winRate': winRate,
      'bestTrade': _bestSingleTrade,
      'bestTradeTicker': bestTradeRecord?.company.ticker,
      'worstTrade': worstTradeRecord?.realizedPnL?.toDouble() ?? 0.0,
      'worstTradeTicker': worstTradeRecord?.company.ticker,
      'totalProfit': _totalRealizedPnL.toDouble(),
      'netWorth': netWorth.toDouble(),
      'bestNetWorth': _bestNetWorth.toDouble(),
      'bestStreak': _bestWinStreak,
      'quotasMet': _currentDay ~/ _daysPerQuota - _failedQuotas,
      'ppEarned': _prestigePoints,
      'playerTitle': playerTitle,
      'positions': _positions.length,
    };

    // Add to leaderboard
    _leaderboard.add({
      'days': _currentDay,
      'netWorth': netWorth.toDouble(),
      'totalProfit': _totalRealizedPnL.toDouble(),
      'winRate': winRate,
      'date': DateTime.now().toIso8601String(),
    });
    _leaderboard.sort((a, b) => (b['netWorth'] as double).compareTo(a['netWorth'] as double));
    if (_leaderboard.length > maxLeaderboardEntries) {
      _leaderboard.removeRange(maxLeaderboardEntries, _leaderboard.length);
    }
  }

  // News getters
  List<NewsItem> get recentNews => List.unmodifiable(_newsItems);
  List<NewsItem> getNewsByCategory(NewsCategory category) =>
      _newsItems.where((n) => n.category == category).toList();
  List<NewsItem> getNewsByCompany(String companyId) =>
      _newsItems.where((n) => n.companyId == companyId).toList();
  List<NewsItem> getNewsBySector(String sectorId) =>
      _newsItems.where((n) => n.sectorId == sectorId).toList();

  // News popup state
  bool get showNewsPopup => _showNewsPopup;
  List<NewsItem> get todayNews => List.unmodifiable(_todayNews);
  bool get showMidDayNewsPopup => _showMidDayNewsPopup;
  List<NewsItem> get midDayNews => List.unmodifiable(_midDayNews);

  // Active gameplay effects getters
  double get activeFeeMultiplier => _activeFeeMultiplier;
  int get feeMultiplierDaysLeft => _feeMultiplierDaysLeft;
  bool get shortSellingBanned => _shortSellingBanned;
  int get shortBanDaysLeft => _shortBanDaysLeft;
  double get activeUpgradeDiscount => _activeUpgradeDiscount;
  int get upgradeDiscountDaysLeft => _upgradeDiscountDaysLeft;
  bool get circuitBreakerActive => _circuitBreakerActive;
  double get circuitBreakerTimer => _circuitBreakerTimer;
  double get activeVolatilityMultiplier => _activeVolatilityMultiplier;
  int get volatilityMultiplierDaysLeft => _volatilityMultiplierDaysLeft;
  int get activePositionLimit => _activePositionLimit;
  int get positionLimitDaysLeft => _positionLimitDaysLeft;
  bool get signalJammerActive => _signalJammerActive;
  int get signalJammerDaysLeft => _signalJammerDaysLeft;
  double get analystPrecision => _analystPrecision;

  // Stop loss / Take profit getters
  bool get hasStopLoss => _hasStopLoss;
  bool get hasTakeProfit => _hasTakeProfit;
  double get stopLossPercent => _stopLossPercent;
  double get takeProfitPercent => _takeProfitPercent;
  bool get stopLossEnabled => _stopLossEnabled;
  bool get takeProfitEnabled => _takeProfitEnabled;
  bool get trailingStopEnabled => _trailingStopEnabled;

  void setStopLossPercent(double percent) {
    _stopLossPercent = percent.clamp(0.01, 0.50);
    notifyListeners();
  }

  void setTakeProfitPercent(double percent) {
    _takeProfitPercent = percent.clamp(0.01, 1.0);
    notifyListeners();
  }

  void toggleStopLoss(bool enabled) {
    _stopLossEnabled = enabled;
    notifyListeners();
  }

  void toggleTakeProfit(bool enabled) {
    _takeProfitEnabled = enabled;
    notifyListeners();
  }

  void toggleTrailingStop(bool enabled) {
    _trailingStopEnabled = enabled;
    notifyListeners();
  }

  // Price alert threshold
  double get priceAlertThreshold => _priceAlertThreshold;
  void setPriceAlertThreshold(double value) {
    _priceAlertThreshold = value.clamp(5.0, 50.0);
    _priceAlertCooldown = _priceAlertThreshold * 1.5;
    _lastNotifiedPriceChange.clear();
    notifyListeners();
  }

  /// Check if any gameplay effect is active
  bool get hasActiveEffects =>
      _activeFeeMultiplier != 1.0 ||
      _shortSellingBanned ||
      _activeUpgradeDiscount > 0 ||
      _circuitBreakerActive ||
      _activeVolatilityMultiplier != 1.0 ||
      _activePositionLimit > 0 ||
      _signalJammerActive;

  /// Get list of active effect descriptions for UI (localized)
  List<ActiveEffect> getLocalizedEffects(AppLocalizations l10n) {
    final effects = <ActiveEffect>[];
    if (_activeFeeMultiplier != 1.0) {
      final isPositive = _activeFeeMultiplier < 1.0;
      final percent = ((_activeFeeMultiplier - 1) * 100).abs().toStringAsFixed(0);
      effects.add(ActiveEffect(
        name: isPositive ? l10n.effectReducedFees : l10n.effectIncreasedFees,
        description: isPositive ? l10n.effectFeeDiscount(percent) : l10n.effectFeeSurcharge(percent),
        daysLeft: _feeMultiplierDaysLeft,
        isPositive: isPositive,
        icon: '💰',
      ));
    }
    if (_shortSellingBanned) {
      effects.add(ActiveEffect(
        name: l10n.effectShortBan,
        description: l10n.effectShortBanDesc,
        daysLeft: _shortBanDaysLeft,
        isPositive: false,
        icon: '🚫',
      ));
    }
    if (_activeUpgradeDiscount > 0) {
      final percent = (_activeUpgradeDiscount * 100).toStringAsFixed(0);
      effects.add(ActiveEffect(
        name: l10n.effectUpgradeSale,
        description: l10n.effectUpgradeSaleDesc(percent),
        daysLeft: _upgradeDiscountDaysLeft,
        isPositive: true,
        icon: '🏷️',
      ));
    }
    if (_circuitBreakerActive) {
      effects.add(ActiveEffect(
        name: l10n.effectCircuitBreaker,
        description: l10n.effectCircuitBreakerDesc,
        daysLeft: 0,
        isPositive: false,
        icon: '⚡',
      ));
    }
    if (_activeVolatilityMultiplier != 1.0) {
      final isHigh = _activeVolatilityMultiplier > 1.0;
      final percent = ((_activeVolatilityMultiplier - 1) * 100).abs().toStringAsFixed(0);
      effects.add(ActiveEffect(
        name: isHigh ? l10n.effectHighVolatility : l10n.effectLowVolatility,
        description: l10n.effectVolatilityDesc(percent, isHigh ? l10n.effectVolatilityMore : l10n.effectVolatilityLess),
        daysLeft: _volatilityMultiplierDaysLeft,
        isPositive: !isHigh,
        icon: '📊',
      ));
    }
    if (_activePositionLimit > 0) {
      effects.add(ActiveEffect(
        name: l10n.effectPositionLimit,
        description: l10n.effectPositionLimitDesc(activePositionLimit.toString()),
        daysLeft: _positionLimitDaysLeft,
        isPositive: false,
        icon: '📉',
      ));
    }
    if (_signalJammerActive) {
      effects.add(ActiveEffect(
        name: l10n.effectSignalJammer,
        description: l10n.effectSignalJammerDesc,
        daysLeft: _signalJammerDaysLeft,
        isPositive: false,
        icon: '🔀',
      ));
    }
    return effects;
  }


  // Analyst data getter
  AnalystData? getAnalystData(String companyId) {
    final state = _stockStates[companyId];
    if (state == null) return null;

    // Check if we have cached data
    if (_analystDataCache.containsKey(companyId)) {
      return _analystDataCache[companyId];
    }

    // Generate new analyst data
    final analystData = AnalystGenerator.generateAnalystData(state);
    _analystDataCache[companyId] = analystData;
    return analystData;
  }

  // Trade history getters
  List<TradeRecord> get recentTrades => List.unmodifiable(_tradeHistory);
  List<TradeRecord> getTradesByCompany(String companyId) =>
      _tradeHistory.where((t) => t.company.id == companyId).toList();
  List<TradeRecord> getTradesByType(TradeType type) =>
      _tradeHistory.where((t) => t.type == type).toList();

  // Market indicators getter
  MarketIndicators? get marketIndicators => _marketIndicators;

  // Market regime getter
  MarketRegimeData get marketRegime => _marketRegime;

  // Portfolio breakdown getter
  PortfolioBreakdown? get portfolioBreakdown {
    if (_positions.isEmpty) return null;
    return _calculatePortfolioBreakdown();
  }

  // === EXTENDED TRADING STATISTICS ===

  /// Best trade ever (highest realized P&L)
  TradeRecord? get bestTrade {
    final closingTrades = _tradeHistory.where((t) => t.isClosing && t.realizedPnL != null).toList();
    if (closingTrades.isEmpty) return null;
    return closingTrades.reduce((a, b) =>
        (a.realizedPnL ?? BigNumber.zero) > (b.realizedPnL ?? BigNumber.zero) ? a : b);
  }

  /// Worst trade ever (lowest realized P&L)
  TradeRecord? get worstTrade {
    final closingTrades = _tradeHistory.where((t) => t.isClosing && t.realizedPnL != null).toList();
    if (closingTrades.isEmpty) return null;
    return closingTrades.reduce((a, b) =>
        (a.realizedPnL ?? BigNumber.zero) < (b.realizedPnL ?? BigNumber.zero) ? a : b);
  }

  /// Current winning streak (consecutive profitable trades)
  int get winStreak {
    int streak = 0;
    for (final trade in _tradeHistory) {
      if (!trade.isClosing || trade.realizedPnL == null) continue;
      if (trade.realizedPnL!.isPositive) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Current losing streak (consecutive losing trades)
  int get loseStreak {
    int streak = 0;
    for (final trade in _tradeHistory) {
      if (!trade.isClosing || trade.realizedPnL == null) continue;
      if (trade.realizedPnL!.isNegative) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Number of trades today
  int get tradesToday {
    return _tradeHistory.where((t) => t.dayNumber == _currentDay).length;
  }

  /// Volume traded today
  BigNumber get volumeToday {
    return _tradeHistory
        .where((t) => t.dayNumber == _currentDay)
        .fold(BigNumber.zero, (sum, t) => sum + t.totalValue);
  }

  /// Number of profitable positions
  int get profitablePositions {
    int count = 0;
    for (final position in _positions) {
      final state = _stockStates[position.company.id];
      if (state != null && position.unrealizedPnL(state.currentPrice).isPositive) {
        count++;
      }
    }
    return count;
  }

  /// Number of losing positions
  int get losingPositions {
    int count = 0;
    for (final position in _positions) {
      final state = _stockStates[position.company.id];
      if (state != null && position.unrealizedPnL(state.currentPrice).isNegative) {
        count++;
      }
    }
    return count;
  }

  /// Cash ratio (cash / net worth)
  double get cashRatio {
    final nw = netWorth;
    if (nw.isZero) return 1.0;
    return _cash.toDouble() / nw.toDouble();
  }

  /// Invested ratio (portfolio value / net worth)
  double get investedRatio {
    final nw = netWorth;
    if (nw.isZero) return 0.0;
    return portfolioValue.toDouble() / nw.toDouble();
  }

  /// Quota target (what we need to reach)
  BigNumber get nextMilestone => effectiveQuotaTarget;

  /// Amount remaining to reach quota
  BigNumber get quotaRemaining {
    final remaining = effectiveQuotaTarget - _quotaProgress;
    return remaining.isNegative ? BigNumber.zero : remaining;
  }

  /// Progress towards quota (0-100)
  double get milestoneProgress {
    final target = effectiveQuotaTarget.toDouble();
    if (target <= 0) return 100.0;
    return (_quotaProgress.toDouble() / target * 100).clamp(0.0, 100.0);
  }

  /// Whether quota is already met
  bool get quotaMet => _quotaProgress >= effectiveQuotaTarget;

  /// Get news that affect user's positions
  List<NewsItem> get newsAffectingPositions {
    final positionCompanyIds = _positions.map((p) => p.company.id).toSet();
    final positionSectorIds = _positions.map((p) => p.company.sectorId).toSet();

    return _newsItems.where((news) {
      if (news.companyId != null && positionCompanyIds.contains(news.companyId)) {
        return true;
      }
      if (news.sectorId != null && positionSectorIds.contains(news.sectorId)) {
        return true;
      }
      return false;
    }).toList();
  }

  // === INITIALIZATION ===
  GameService() {
    _initializeMarket();
  }

  /// Reset the entire game to initial state (for new game)
  void reset() {
    // Reset game state
    _currentDay = 1;
    _currentYear = 1;
    _dayTimer = secondsPerDay;
    _marketUpdateTimer = 0;
    _cash = BigNumber(startingCash);
    _quotaTarget = BigNumber(startingQuota);
    _quotaProgress = BigNumber.zero;
    _failedQuotas = 0;
    _gameSpeed = 1.0;
    _isPaused = true;
    _isEndOfDay = false;
    _showUpgradeSelection = false;
    _upgradeChoices.clear();

    // Reset upgradeable settings
    _daysPerQuota = 3;
    _feeReduction = 0.0;
    _maxPositions = 3;
    _quotaReduction = 0.0;
    _skipQuotaBonusPercent = 0.15;
    _extraDaySeconds = 0;
    _passiveIncome = 0.0;

    // Clear unlocked content
    _unlockedCompanyIds.clear();
    _acquiredUpgrades.clear();

    // Clear market state
    _stockStates.clear();
    _sectorTrends.clear();
    _marketSentiment = 0.0;

    // Clear portfolio
    _positions.clear();
    _totalRealizedPnL = BigNumber.zero;
    _totalTrades = 0;
    _winningTrades = 0;
    _totalOpeningExpenses = BigNumber.zero;
    _totalRobotExpenses = BigNumber.zero;

    // Clear news
    _newsItems.clear();
    _showNewsPopup = false;
    _todayNews.clear();
    _midDayNewsTriggered = false;
    _showMidDayNewsPopup = false;
    _midDayNews.clear();

    // Reset analyst data
    _analystDataCache.clear();
    _lastAnalystUpdateDay = 0;

    // Clear trade history
    _tradeHistory.clear();
    _tradeIdCounter = 0;

    // Reset market indicators and regime
    _marketIndicators = null;
    _marketRegime = MarketRegimeData(
      currentRegime: MarketRegime.neutral,
      regimeStrength: 0.0,
      daysInCurrentRegime: 0,
      lastRegimeChange: DateTime.now(),
    );

    // Reset prestige state (but keep meta progression)
    _prestigeLevel = 0;
    _lifetimeEarnings = BigNumber.zero;
    _prestigePoints = 0;
    _totalPrestigePoints = 0;
    _startingCashBonus = 0;
    _showPrestigeShop = false;
    _purchasedTalentNodes.clear();

    // Reset personal bests (casual info bar)
    _bestNetWorth = BigNumber.zero;
    _bestWinStreak = 0;
    _mostDaysSurvived = 0;

    // Clear tokens
    _tokens.clear();
    _tokenIdCounter = 0;

    // Reset active effects
    _activeFeeMultiplier = 1.0;
    _feeMultiplierDaysLeft = 0;
    _shortSellingBanned = false;
    _shortBanDaysLeft = 0;
    _activeUpgradeDiscount = 0.0;
    _upgradeDiscountDaysLeft = 0;
    _circuitBreakerActive = false;
    _circuitBreakerTimer = 0;
    _activeVolatilityMultiplier = 1.0;
    _volatilityMultiplierDaysLeft = 0;
    _activePositionLimit = 0;
    _positionLimitDaysLeft = 0;
    _signalJammerActive = false;
    _signalJammerDaysLeft = 0;

    // Clear special events
    _activeSpecialEvent = null;
    _activeEventDaysLeft = 0;
    _recentEventIds.clear();

    // Clear FinTok
    _influencers.clear();
    _tips.clear();
    _scheduledTips.clear();
    _usedInfluencerTemplateIds.clear();
    _followedInfluencerIds.clear();

    // Reset informant
    _informantState = InformantState();
    _showInformantPopup = false;

    // Reset challenges
    _challengeState = DailyChallengeState();
    _dailyTradesCount = 0;
    _dailyProfitAmount = 0.0;
    _dailyVolumeTraded = 0.0;
    _dailyDipBuys = 0;
    _dailySellHighs = 0;
    _dailyLosingTrades = 0;

    // Reset prestige effects
    _upgradeRerollsPerDay = 0;
    _upgradeRerollsUsedToday = 0;
    _guaranteedRareFirst = false;
    _usedGuaranteedRare = false;
    _quotaFailFreebies = 0;
    _keepCashOnFailPercent = 0.0;
    _extraUpgradeChoices = 0;
    _shortBanImmunity = false;
    _startingUpgrades = 0;
    _isStartingUpgradeSelection = false;
    _prestigePointMultiplier = 0.0;
    _cashInterestRate = 0.0;

    // Reset talent tree effects
    _profitMultiplier = 0.0;
    _signalAccuracy = 0.0;
    _lossReduction = 0.0;
    _crashImpactReduction = 0.0;
    _maxLossPerTrade = 1.0;
    _holdBonus = 0.0;
    _survivesWipeout = 0;
    _eventLossReduction = 0.0;
    _keepCapitalOnWipe = 0.0;
    _robotWinRateBonus = 0.0;
    _robotSpeedBonus = 0.0;
    _robotUpgradeCostReduction = 0.0;
    _robotStartLevel = 0;
    _robotAutoCollect = 0;
    _robotSeedMoney = 0.0;
    _newsCategoryPreview = false;
    _tipExactPercent = false;
    _flagBadTips = false;
    _priceForesight = false;
    _freeTipsPerDay = 0;
    _tipPrecisionMultiplier = 0.0;
    _tipCostReduction = 0.0;
    _shortTermProfitBonus = 0.0;
    _diversificationBonus = 0.0;
    _disinfoShield = false;
    _blockBadEvents = 0;
    _blockBadEventsUsed = 0;
    _freeTipsUsedToday = 0;
    // Intelligence branch
    _extraActiveInfluencers = 0;
    _extraNewsPerDay = 0;
    _fintokAccuracyBonus = 0.0;
    _sectorProfitBonuses.clear();
    _sectorLossShields.clear();
    _sectorPassiveIncomes.clear();
    _sectorCapstones.clear();
    _sectorTierUnlocks.clear();
    // Trader branch
    _extraPositionSlots = 0;
    _unlimitedPositions = false;
    _stopLossUnlock = false;
    _takeProfitUnlock = false;
    _trailingStopUnlock = false;
    _partialTakeProfitUnlock = false;
    _safetyNetUnlock = false;
    _quickFlipBonus = 0.0;
    _scalperNoFees = false;
    _holdBonus3d = 0.0;
    _holdBonus5d = 0.0;
    _holdBonus7d = 0.0;
    _limitOrdersUnlock = false;
    _smartOrdersUnlock = false;
    _streakBonusPerWin = 0.0;
    _streakMaxStacks = 0;
    _streakKeepOnLoss = false;
    _leverageMax = 1.0;
    _marginShield = false;
    _compoundInterestRate = 0.0;
    // Survival branch
    _extraLives = 0;
    _livesRemaining = 0;
    _extraQuotaDays = 0;
    _survivalQuotaReduction = 0.0;
    _skipQuotaBonus = 0.0;
    _skipStreakBonus = 0.0;
    _overtimeDays = 0;
    _secondWindBonus = 0.0;
    _secondWindDaysLeft = 0;
    _resurrectQuotaReduction = 0.0;
    _earlyFinishPP = 0.0;
    _earlyFinishPP2 = 0.0;
    _speedrunPPMultiplier = false;
    _streakProfitBonus = 0.0;
    _streakPersists = false;
    _quotaStreak = 0;
    _consecutiveSkips = 0;
    _allQuotasEarly = true;
    _overtimeDaysLeft = 0;
    _inOvertime = false;

    // Reset stop loss / take profit
    _hasStopLoss = false;
    _hasTakeProfit = false;
    _stopLossEnabled = false;
    _takeProfitEnabled = false;
    _trailingStopEnabled = false;
    _stopLossPercent = 0.10;
    _takeProfitPercent = 0.20;

    // Reset trading strategy bonuses
    _consecutiveWins = 0;
    _momentumBonus = 0.0;
    _momentumStreak = 0;
    _contrarianBonus = 0.0;
    _contrarianThreshold = 0.0;
    _dayTradeBonus = 0.0;
    _boughtTodayCompanies.clear();
    _lossRecoveryPercent = 0.0;
    _dailyRealizedLosses = 0.0;
    _contrarianBuys.clear();
    _upgradeStockBonusRate = 0.0;
    _extraMorningNews = 0;
    _extraMidDayNews = 0;
    _analystPrecision = 0.5;
    _positionOpenDay.clear();
    _positionLeverage.clear();
    _positionHighPrice.clear();
    _partialTpTaken.clear();
    _pendingLimitOrder = null;
    _safetyNetUsed = false;

    // Reset meta progression (full reset)
    _metaStockBonusRate = 0.0;
    _metaCommissionReduction = 0.0;
    _metaQuotaReduction = 0.0;
    _metaStartingCashBonus = 0.0;
    _metaInformantBonus = 0.0;
    _metaFintokAccuracyBonus = 0.0;
    _metaLuckyStartingShares = 0;
    _metaVipStatus = false;
    _vipUsedThisYear = false;
    _metaUpgradeLuck = 0.0;
    _metaInsurance = 0.0;
    _metaInterestRate = 0.0;
    _metaExtraRerolls = 0;

    // Reset robot states (robots persist via prestige, but state resets)
    _peakNetWorth = BigNumber.zero;
    for (int i = 0; i < _robots.length; i++) {
      final robot = _robots[i];
      robot.budget = BigNumber.zero;
      robot.wallet = BigNumber.zero;
      robot.tradeHistory.clear();
      robot.tradesCompletedToday = 0;
      // Global starting levels from talent tree
      robot.precisionLevel = _robotStartLevel;
      robot.efficiencyLevel = _robotStartLevel;
      robot.frequencyLevel = _robotStartLevel;
      robot.riskMgmtLevel = _robotStartLevel;
      robot.capacityLevel = _robotStartLevel;
      // Global starting budget from talent tree
      if (_robotSeedMoney > 0) {
        robot.budget = BigNumber(_robotSeedMoney);
      }
    }
    _maxRobotSlots = 0;

    // Reset view
    _currentView = ViewType.dashboard;
    _marketSubTab = 0;
    _selectedSectorId = null;
    _selectedCompanyId = null;

    // Re-initialize market
    _initializeMarket();

    notifyListeners();
  }

  void _initializeMarket() {
    // Initialize sector trends
    for (final sector in allSectors) {
      _sectorTrends[sector.id] = 0.0;
    }

    // Initialize stock states
    for (final company in allCompanies) {
      _stockStates[company.id] = StockState(company: company);
    }

    _marketSentiment = (_random.nextDouble() - 0.5) * 0.4;

    // Shop starts empty - player presses Roll to open
    _shopUpgrades.clear();
    _shopRollsToday = 0;

    // Generate initial news for Day 1 and show popup
    _generateDailyNewsWithPopup();
  }

  // === UPGRADE SYSTEM ===

  /// Generate daily upgrade choices with boosted rarity
  /// Number of choices = 3 + _extraUpgradeChoices (from Quick Learner prestige)
  void _generateUpgradeChoices() {
    _upgradeChoices.clear();

    final numChoices = upgradeChoiceCount; // 3 + _extraUpgradeChoices
    _dailyRerollsUsed = List.filled(numChoices, 0);
    final selected = <Upgrade>[];

    // VIP Status: First upgrade of each YEAR is guaranteed Legendary
    if (_metaVipStatus && !_vipUsedThisYear) {
      final legendaryPool = allUpgrades.where((u) =>
          u.rarity == UpgradeRarity.legendary).toList();
      if (legendaryPool.isNotEmpty) {
        var guaranteed = legendaryPool[_random.nextInt(legendaryPool.length)];
        if (guaranteed.isSectorSpecific && guaranteed.templateType != 'income_situational') {
          final sectors = SectorType.values;
          guaranteed = guaranteed.withSector(sectors[_random.nextInt(sectors.length)]);
        }
        selected.add(guaranteed);
        _vipUsedThisYear = true;
      }
    }

    // Lucky Start: First upgrade of the run is guaranteed Rare+
    if (_guaranteedRareFirst && !_usedGuaranteedRare) {
      final rarePool = allUpgrades.where((u) =>
          u.rarity == UpgradeRarity.rare ||
          u.rarity == UpgradeRarity.epic ||
          u.rarity == UpgradeRarity.legendary).toList();
      if (rarePool.isNotEmpty) {
        var guaranteed = rarePool[_random.nextInt(rarePool.length)];
        if (guaranteed.isSectorSpecific && guaranteed.templateType != 'income_situational') {
          final sectors = SectorType.values;
          guaranteed = guaranteed.withSector(sectors[_random.nextInt(sectors.length)]);
        }
        selected.add(guaranteed);
        _usedGuaranteedRare = true;
      }
    }

    // Fill remaining slots with boosted rarity (daily = rarityBoost 1.0)
    while (selected.length < numChoices) {
      final excludeIds = selected.map((u) => u.id).toSet();
      selected.add(generateRandomUpgrade(
        random: _random,
        acquiredUpgrades: _acquiredUpgrades,
        rarityBoost: 1.0, // Daily free upgrades have boosted rarity
        excludeIds: excludeIds,
      ));
    }

    _upgradeChoices = selected;
  }

  /// Reroll upgrade choices (uses one reroll for the day)
  void rerollUpgradeChoices() {
    if (!canRerollUpgrades) return;
    _upgradeRerollsUsedToday++;
    _generateUpgradeChoices();
    notifyListeners();
  }

  /// Check if player can afford an upgrade
  bool canAffordUpgrade(int index) {
    if (index < 0 || index >= _upgradeChoices.length) return false;
    final upgrade = _upgradeChoices[index];
    final effectiveCost = getEffectiveUpgradeCost(upgrade);
    return _cash >= BigNumber(effectiveCost);
  }

  /// Select a daily free upgrade from the choices
  void selectUpgrade(int index) {
    if (index < 0 || index >= _upgradeChoices.length) return;
    if (!_showUpgradeSelection) return;

    final upgrade = _upgradeChoices[index];

    // Daily upgrades are FREE (no cost deduction)
    _acquireUpgrade(upgrade);

    _showUpgradeSelection = false;
    _upgradeChoices.clear();
    _dailyRerollsUsed = List.filled(upgradeChoiceCount, 0);

    // Starting upgrade (Market Veteran): don't advance day, just resume
    if (_isStartingUpgradeSelection) {
      _isStartingUpgradeSelection = false;
      notifyListeners();
      return;
    }

    // Advance to next day after upgrade selection
    _finishDayAndAdvance();
  }

  /// Skip upgrade selection (optional)
  void skipUpgradeSelection() {
    _showUpgradeSelection = false;
    _upgradeChoices.clear();

    // Starting upgrade (Market Veteran): just dismiss, don't advance
    if (_isStartingUpgradeSelection) {
      _isStartingUpgradeSelection = false;
      notifyListeners();
      return;
    }

    // Advance to next day after skipping
    _finishDayAndAdvance();
  }

  // ==========================================================
  // UPGRADE SHOP (permanent, accessible anytime during a day)
  // ==========================================================

  /// Generate shop upgrades (3 random options, rarity boosted by prestige)
  void _generateShopUpgrades() {
    _shopUpgrades.clear();
    for (int i = 0; i < 3; i++) {
      final excludeIds = _shopUpgrades.map((u) => u.id).toSet();
      _shopUpgrades.add(generateRandomUpgrade(
        random: _random,
        acquiredUpgrades: _acquiredUpgrades,
        rarityBoost: _shopRarityBoost, // Boosted by Luck Boost prestige
        excludeIds: excludeIds,
      ));
    }
  }

  /// Get the cost for the next shop roll (0 = free)
  int getShopRollCost() {
    if (_shopRollsToday < freeRollsPerDay) return 0; // Free roll
    final paidRolls = _shopRollsToday - freeRollsPerDay;
    // Cost: base * 3^paidRolls => 50, 150, 450, 1350, 4050...
    int multiplier = 1;
    for (int i = 0; i < paidRolls; i++) { multiplier *= 3; }
    return baseRollCost * multiplier;
  }

  /// Whether the next roll is free
  bool get isNextRollFree => _shopRollsToday < freeRollsPerDay;

  /// Roll shop upgrades (player-triggered opening / reroll all)
  bool rollShop() {
    final cost = getShopRollCost();
    if (cost > 0 && _cash < BigNumber(cost.toDouble())) return false;

    // Pay for roll if not free
    if (cost > 0) {
      final costBN = BigNumber(cost.toDouble());
      _cash = _cash - costBN;
      _totalOpeningExpenses = _totalOpeningExpenses + costBN;
      _quotaProgress = _quotaProgress - costBN;
    }

    _shopRollsToday++;
    _generateShopUpgrades();
    notifyListeners();
    return true;
  }

  /// Pick an upgrade from the shop (free pick, clears shop)
  bool pickShopUpgrade(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= _shopUpgrades.length) return false;

    final upgrade = _shopUpgrades[slotIndex];
    _acquireUpgrade(upgrade);

    // Clear shop after picking (player must roll again for new options)
    _shopUpgrades.clear();

    notifyListeners();
    return true;
  }

  /// Get reroll cost for a daily upgrade slot
  int getDailyRerollCost(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= upgradeChoiceCount) return 0;
    final used = _dailyRerollsUsed[slotIndex];
    if (used < freeRollsPerDay) return 0; // Free reroll
    // Daily rerolls after free ones are not available (daily is meant to be quick)
    return -1; // -1 means no more rerolls available
  }

  /// Reroll a specific daily upgrade slot
  bool rerollDailySlot(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= upgradeChoiceCount) return false;
    if (_upgradeChoices.length <= slotIndex) return false;
    if (_dailyRerollsUsed[slotIndex] >= freeRollsPerDay) return false;

    _dailyRerollsUsed[slotIndex]++;

    // Generate new upgrade with boosted rarity for this slot
    _upgradeChoices[slotIndex] = generateRandomUpgrade(
      random: _random,
      acquiredUpgrades: _acquiredUpgrades,
      rarityBoost: 1.0, // Boosted rarity for daily
    );

    notifyListeners();
    return true;
  }

  /// Acquire an upgrade (shared logic for shop + daily)
  void _acquireUpgrade(Upgrade upgrade) {
    // Check for replacement (sector-specific: higher rarity replaces lower)
    final replaced = getReplacedUpgrade(upgrade, _acquiredUpgrades);
    if (replaced != null) {
      // Remove old upgrade effects would need to be un-applied
      // For sector upgrades, effects are looked up dynamically so just remove the record
      _acquiredUpgrades.remove(replaced);
    }

    // Apply effects (for static upgrades that set fields)
    _applyUpgrade(upgrade);

    // Record the acquisition
    final existing = _acquiredUpgrades.where((a) => a.upgradeId == upgrade.id).firstOrNull;
    if (existing != null && upgrade.isRepeatable) {
      existing.stackCount++;
    } else {
      _acquiredUpgrades.add(AcquiredUpgrade(
        upgradeId: upgrade.id,
        dayAcquired: _currentDay,
        yearAcquired: _currentYear,
        templateType: upgrade.templateType,
        sector: upgrade.sector,
        rarity: upgrade.rarity,
      ));
    }
  }

  /// Helper to finish current day and advance to next
  void _finishDayAndAdvance() {
    // Add passive income
    double dailyPassiveTotal = 0;
    if (_passiveIncome > 0) {
      _cash = _cash + BigNumber(_passiveIncome);
      dailyPassiveTotal += _passiveIncome;
    }

    // Compound interest on cash balance (prestige + meta)
    final totalInterestRate = _cashInterestRate + _metaInterestRate + _compoundInterestRate;
    if (totalInterestRate > 0 && _cash.toDouble() > 0) {
      final interest = _cash.toDouble() * totalInterestRate;
      _cash = _cash + BigNumber(interest);
      dailyPassiveTotal += interest;
    }

    // Tax Refund: recover percent of daily losses
    if (_lossRecoveryPercent > 0 && _dailyRealizedLosses > 0) {
      final recovery = _dailyRealizedLosses * _lossRecoveryPercent;
      _cash = _cash + BigNumber(recovery);
      dailyPassiveTotal += recovery;
    }

    // Situational income from upgrades (per stock, per sector, per upgrade, portfolio %)
    final situationalIncome = calculateSituationalIncome();
    if (situationalIncome > 0) {
      _cash = _cash + BigNumber(situationalIncome);
      dailyPassiveTotal += situationalIncome;
    }

    // Sector passive income from talent tree (only if holding stocks in that sector)
    if (_sectorPassiveIncomes.isNotEmpty) {
      final heldSectors = _positions.map((p) => p.company.sectorId).toSet();
      for (final entry in _sectorPassiveIncomes.entries) {
        if (heldSectors.contains(entry.key) && entry.value > 0) {
          _cash = _cash + BigNumber(entry.value);
          dailyPassiveTotal += entry.value;
        }
      }
    }

    // Emit floating text for passive income
    if (dailyPassiveTotal > 0) {
      _pendingFloatingTexts.add(MapEntry(
        '+\$${NumberFormatter.formatCompact(BigNumber(dailyPassiveTotal))}',
        true,
      ));
    }

    // Process token effects at end of day
    _processTokenEffects();

    // Track robot wallets before for floating text
    final robotWalletsBefore = <String, BigNumber>{};
    for (final robot in _robots) {
      if (robot.isActive) {
        robotWalletsBefore[robot.id] = robot.wallet;
      }
    }

    // Process robot trader actions at end of day
    _processRobotTrades();

    // Emit floating text for robot gains (before auto-collect zeroes wallets)
    for (final robot in _robots) {
      final before = robotWalletsBefore[robot.id];
      if (before != null) {
        final gain = robot.wallet - before;
        if (gain > BigNumber.zero) {
          _pendingFloatingTexts.add(MapEntry(
            '+\$${NumberFormatter.formatCompact(gain)}',
            true,
          ));
        }
      }
    }

    // Global auto-collect: collect from first N robots (talent tree)
    if (_robotAutoCollect > 0) {
      final collectCount = _robotAutoCollect >= 999 ? _robots.length : _robotAutoCollect;
      for (int i = 0; i < collectCount && i < _robots.length; i++) {
        final robot = _robots[i];
        if (robot.wallet > BigNumber.zero) {
          _cash = _cash + robot.wallet;
          robot.wallet = BigNumber.zero;
        }
      }
    }

    // Reset daily tracking values
    _resetDailyValues();

    _advanceDay();
    _dayTimer = effectiveDayDuration;
    _marketUpdateTimer = 0;
    _isEndOfDay = false;

    // Dampen sector trends overnight (mean reversion, prevents opening gap)
    for (final sectorId in _sectorTrends.keys.toList()) {
      _sectorTrends[sectorId] = (_sectorTrends[sectorId] ?? 0) * 0.5;
    }

    // Generate and show news for the new day
    _generateDailyNewsWithPopup();
  }

  /// Reset values that track daily activities
  void _resetDailyValues() {
    _upgradeRerollsUsedToday = 0;
    _boughtTodayCompanies.clear();
    _dailyRealizedLosses = 0.0;
    _dayStartNetWorth = netWorth.toDouble();
    _endOfDayNarrative = null;
    _encouragementMessage = null;
    // Note: _contrarianBuys persists across days (can sell dip buy later)

    // Clear shop for new day - player presses Roll to open
    // Note: _shopRollsToday persists across days (cost keeps escalating)
    _shopUpgrades.clear();
  }

  /// Generate daily news and show popup
  void _generateDailyNewsWithPopup() {
    _todayNews.clear();
    _midDayNews.clear();
    _midDayNewsTriggered = false; // Reset mid-day flag for new day
    _generateDailyNews();
    // Copy today's news for the popup (most recent items)
    final maxNewsInPopup = 4 + _extraNewsPerDay + _extraMorningNews;
    _todayNews = _newsItems.take(maxNewsInPopup).toList();
    _showNewsPopup = true;
    _isPaused = true; // Stay paused until news is dismissed
    notifyListeners();
  }

  /// Dismiss news popup and start the day
  void dismissNewsPopup() {
    _showNewsPopup = false;
    _isPaused = true; // Stay paused, player can press play to start
    notifyListeners();
  }

  /// Trigger mid-day news event
  void _triggerMidDayNews() {
    _midDayNewsTriggered = true;
    _midDayNews.clear();

    // Generate 1-2 mid-day news items (+extra from talent tree and upgrades)
    final newsCount = 1 + _random.nextInt(2) + _extraNewsPerDay + _extraMidDayNews;

    for (int i = 0; i < newsCount; i++) {
      final news = _generateMidDayNewsItem();
      if (news != null) {
        _midDayNews.add(news);
        _addNewsItem(news);
        _applyNewsImpact(news);
      }
    }

    if (_midDayNews.isNotEmpty) {
      _showMidDayNewsPopup = true;
      _isPaused = true;
      notifyListeners();
    }
  }

  /// Generate a mid-day news item that may contradict morning news
  /// Select a company for news with tier-based weighting
  /// Elite companies appear ~5x more often than Starter in news
  CompanyData _selectWeightedCompanyForNews(List<CompanyData> companies) {
    if (companies.length <= 1) return companies.first;
    final weights = companies.map((c) => switch (c.tier) {
      CompanyTier.starter => 1.0,
      CompanyTier.standard => 2.0,
      CompanyTier.premium => 3.5,
      CompanyTier.elite => 5.0,
    }).toList();
    final total = weights.reduce((a, b) => a + b);
    var roll = _random.nextDouble() * total;
    for (int i = 0; i < companies.length; i++) {
      roll -= weights[i];
      if (roll <= 0) return companies[i];
    }
    return companies.last;
  }

  NewsItem? _generateMidDayNewsItem() {
    // 40% chance to contradict morning news, 60% chance for new independent news
    final shouldContradict = _random.nextDouble() < 0.4 && _todayNews.isNotEmpty;

    if (shouldContradict) {
      // Pick a morning news to contradict
      final morningNews = _todayNews[_random.nextInt(_todayNews.length)];
      return _generateContradictingNews(morningNews);
    } else {
      // Generate independent news - 25% chance for gameplay news at mid-day
      final isGameplayNews = _random.nextDouble() < 0.25;
      final newsType = isGameplayNews ? 3 : _random.nextInt(3);

      NewsItem? news;
      final companies = unlockedCompanies;
      switch (newsType) {
        case 0:
          if (companies.isNotEmpty) {
            final company = _selectWeightedCompanyForNews(companies);
            news = NewsGenerator.generateCompanyNews(company);
          }
          break;
        case 1:
          if (allSectors.isNotEmpty) {
            final sector = allSectors[_random.nextInt(allSectors.length)];
            news = NewsGenerator.generateSectorNews(sector);
          }
          break;
        case 2:
          news = NewsGenerator.generateMarketNews();
          break;
        case 3:
          news = NewsGenerator.generateGameplayNews();
          break;
      }

      // Fallback: if company news failed, generate sector/market news
      if (news == null && newsType == 0) {
        if (allSectors.isNotEmpty) {
          final sector = allSectors[_random.nextInt(allSectors.length)];
          news = NewsGenerator.generateSectorNews(sector);
        } else {
          news = NewsGenerator.generateMarketNews();
        }
      }

      // Apply gameplay effects if present
      if (news != null && news.hasGameplayEffect) {
        applyGameplayEffect(news);
      }

      return news;
    }
  }

  /// Generate news that contradicts the given morning news
  NewsItem _generateContradictingNews(NewsItem morningNews) {
    // Invert the sentiment
    NewsSentiment invertedSentiment;
    String prefixKey; // Key for localization lookup (update, correction, breaking, reversal, recovery)
    switch (morningNews.sentiment) {
      case NewsSentiment.veryPositive:
        invertedSentiment = NewsSentiment.negative;
        prefixKey = 'update';
        break;
      case NewsSentiment.positive:
        invertedSentiment = NewsSentiment.negative;
        prefixKey = 'correction';
        break;
      case NewsSentiment.neutral:
        invertedSentiment = _random.nextBool() ? NewsSentiment.positive : NewsSentiment.negative;
        prefixKey = 'breaking';
        break;
      case NewsSentiment.negative:
        invertedSentiment = NewsSentiment.positive;
        prefixKey = 'reversal';
        break;
      case NewsSentiment.veryNegative:
        invertedSentiment = NewsSentiment.positive;
        prefixKey = 'recovery';
        break;
    }

    // Determine sentiment type for template key
    final isPositive = invertedSentiment == NewsSentiment.positive || invertedSentiment == NewsSentiment.veryPositive;
    final sentimentSuffix = isPositive ? 'positive' : 'negative';

    if (morningNews.companyId != null) {
      final company = getCompanyById(morningNews.companyId!);
      final companyName = company?.name ?? 'Company';

      // templateKey format: midday_{prefix}:company_{sentiment}
      return NewsItem(
        id: 'news_midday_${DateTime.now().millisecondsSinceEpoch}',
        headline: companyName, // Fallback, UI will use localization
        description: '', // Fallback, UI will use localization
        category: morningNews.category,
        sentiment: invertedSentiment,
        timestamp: DateTime.now(),
        companyId: morningNews.companyId,
        impactMagnitude: morningNews.impactMagnitude * 0.8,
        templateKey: 'midday_$prefixKey:company_$sentimentSuffix',
        companyName: companyName,
      );
    } else if (morningNews.sectorId != null) {
      final sector = getSectorById(morningNews.sectorId!);
      final sectorName = sector?.name ?? 'Sector';

      return NewsItem(
        id: 'news_midday_${DateTime.now().millisecondsSinceEpoch}',
        headline: sectorName, // Fallback
        description: '', // Fallback
        category: morningNews.category,
        sentiment: invertedSentiment,
        timestamp: DateTime.now(),
        sectorId: morningNews.sectorId,
        impactMagnitude: morningNews.impactMagnitude * 0.8,
        templateKey: 'midday_$prefixKey:sector_$sentimentSuffix',
        sectorName: sectorName,
      );
    } else {
      // Market-wide contradiction
      return NewsItem(
        id: 'news_midday_${DateTime.now().millisecondsSinceEpoch}',
        headline: 'Markets', // Fallback
        description: '', // Fallback
        category: NewsCategory.market,
        sentiment: invertedSentiment,
        timestamp: DateTime.now(),
        impactMagnitude: morningNews.impactMagnitude * 0.7,
        templateKey: 'midday_$prefixKey:market_$sentimentSuffix',
      );
    }
  }

  /// Dismiss mid-day news popup and resume trading
  void dismissMidDayNewsPopup() {
    _showMidDayNewsPopup = false;
    _isPaused = false;
    startGame(); // Resume the game
  }

  // === GAMEPLAY EFFECT METHODS ===

  /// Apply a gameplay effect from news
  void applyGameplayEffect(NewsItem news) {
    if (!news.hasGameplayEffect) return;

    // Talent tree: disinfoShield blocks harmful gameplay effects from news
    if (_disinfoShield) {
      const blockedEffects = {
        GameplayEffectType.signalJammer,
        GameplayEffectType.trendReversal,
        GameplayEffectType.marketManipulation,
        GameplayEffectType.shortSellingBan,
      };
      if (blockedEffects.contains(news.effectType)) {
        return; // Silently blocked by disinfo shield
      }
    }

    switch (news.effectType) {
      case GameplayEffectType.feeMultiplier:
        _activeFeeMultiplier = news.effectValue;
        _feeMultiplierDaysLeft = news.effectDurationDays;
        break;
      case GameplayEffectType.shortSellingBan:
        if (_shortBanImmunity) break; // Prestige: Short Immunity
        _shortSellingBanned = true;
        _shortBanDaysLeft = news.effectDurationDays;
        break;
      case GameplayEffectType.cashBonus:
        _cash = _cash + BigNumber(news.effectValue);
        onBonusAlert?.call(news.headline, '+\$${news.effectValue.toStringAsFixed(0)}');
        break;
      case GameplayEffectType.upgradeDiscount:
        _activeUpgradeDiscount = news.effectValue;
        _upgradeDiscountDaysLeft = news.effectDurationDays;
        break;
      case GameplayEffectType.circuitBreaker:
        _circuitBreakerActive = true;
        _circuitBreakerTimer = news.effectValue; // Value is seconds
        _isPaused = true; // Pause trading
        break;
      case GameplayEffectType.volatilitySpike:
        _activeVolatilityMultiplier = news.effectValue;
        _volatilityMultiplierDaysLeft = news.effectDurationDays;
        break;
      case GameplayEffectType.positionLimit:
        _activePositionLimit = news.effectValue.toInt();
        _positionLimitDaysLeft = news.effectDurationDays;
        break;
      case GameplayEffectType.dividendBonus:
        // Handled elsewhere when dividends are calculated
        break;
      case GameplayEffectType.signalJammer:
        _signalJammerActive = true;
        _signalJammerDaysLeft = news.effectDurationDays;
        break;
      case GameplayEffectType.trendReversal:
        // Reverse all sector trends instantly
        for (final key in _sectorTrends.keys.toList()) {
          _sectorTrends[key] = -(_sectorTrends[key] ?? 0.0);
        }
        // Also flip stock trend directions
        for (final state in _stockStates.values) {
          state.trendDirection = -state.trendDirection;
        }
        break;
      case GameplayEffectType.marketManipulation:
        // Pick a random unlocked stock and apply massive impact
        final companies = unlockedCompanies;
        if (companies.isNotEmpty) {
          final target = companies[_random.nextInt(companies.length)];
          final state = _stockStates[target.id];
          if (state != null) {
            final direction = _random.nextBool() ? 1.0 : -1.0;
            final impact = direction * (0.08 + _random.nextDouble() * 0.07); // 8-15%
            state.addPendingImpact(impact);
            state.trendDirection = (state.trendDirection + impact * 3).clamp(-1.0, 1.0);
          }
        }
        break;
      case GameplayEffectType.none:
        break;
    }
    notifyListeners();
  }

  /// Decrement effect durations at the start of a new day
  void _decrementEffectDurations() {
    // Fee multiplier
    if (_feeMultiplierDaysLeft > 0) {
      _feeMultiplierDaysLeft--;
      if (_feeMultiplierDaysLeft <= 0) {
        _activeFeeMultiplier = 1.0;
        _newsItems.removeWhere((n) => n.effectType == GameplayEffectType.feeMultiplier);
      }
    }

    // Short selling ban
    if (_shortBanDaysLeft > 0) {
      _shortBanDaysLeft--;
      if (_shortBanDaysLeft <= 0) {
        _shortSellingBanned = false;
        _newsItems.removeWhere((n) => n.effectType == GameplayEffectType.shortSellingBan);
      }
    }

    // Upgrade discount
    if (_upgradeDiscountDaysLeft > 0) {
      _upgradeDiscountDaysLeft--;
      if (_upgradeDiscountDaysLeft <= 0) {
        _activeUpgradeDiscount = 0.0;
        _newsItems.removeWhere((n) => n.effectType == GameplayEffectType.upgradeDiscount);
      }
    }

    // Volatility multiplier
    if (_volatilityMultiplierDaysLeft > 0) {
      _volatilityMultiplierDaysLeft--;
      if (_volatilityMultiplierDaysLeft <= 0) {
        _activeVolatilityMultiplier = 1.0;
        _newsItems.removeWhere((n) => n.effectType == GameplayEffectType.volatilitySpike);
      }
    }

    // Position limit
    if (_positionLimitDaysLeft > 0) {
      _positionLimitDaysLeft--;
      if (_positionLimitDaysLeft <= 0) {
        _activePositionLimit = 0;
        _newsItems.removeWhere((n) => n.effectType == GameplayEffectType.positionLimit);
      }
    }

    // Signal jammer
    if (_signalJammerDaysLeft > 0) {
      _signalJammerDaysLeft--;
      if (_signalJammerDaysLeft <= 0) {
        _signalJammerActive = false;
        _newsItems.removeWhere((n) => n.effectType == GameplayEffectType.signalJammer);
      }
    }
  }

  /// Update circuit breaker timer (called each frame)
  void _updateCircuitBreaker(double deltaTime) {
    if (_circuitBreakerActive) {
      _circuitBreakerTimer -= deltaTime;
      if (_circuitBreakerTimer <= 0) {
        _circuitBreakerActive = false;
        _circuitBreakerTimer = 0;
        // Don't auto-resume, let the day continue
      }
    }
  }

  /// Check stop loss and take profit for all open positions
  void _checkStopLossTakeProfit() {
    if (_circuitBreakerActive) return;

    // Collect positions to close (can't modify list while iterating)
    final toSell = <(CompanyData, double, bool)>[]; // (company, shares, isStopLoss)

    for (final position in _positions) {
      if (position.type != PositionType.long) continue;

      final state = _stockStates[position.company.id];
      if (state == null) continue;

      final currentPrice = state.currentPrice;
      final curPriceD = currentPrice.toDouble();
      final posKey = '${position.company.id}_long';

      // Trailing stop: track highest price since open
      if (_trailingStopUnlock && _trailingStopEnabled && _hasStopLoss && _stopLossEnabled) {
        final prevHigh = _positionHighPrice[posKey] ?? position.averageCost.toDouble();
        if (curPriceD > prevHigh) {
          _positionHighPrice[posKey] = curPriceD;
        }
      }

      // Stop loss check
      if (_hasStopLoss && _stopLossEnabled) {
        double slPnlPercent;
        if (_trailingStopUnlock && _trailingStopEnabled) {
          // Trailing: SL is relative to the highest price, not entry price
          final highPrice = _positionHighPrice[posKey] ?? position.averageCost.toDouble();
          slPnlPercent = highPrice > 0 ? ((curPriceD - highPrice) / highPrice) * 100 : 0;
        } else {
          slPnlPercent = position.unrealizedPnLPercent(currentPrice);
        }
        if (slPnlPercent <= -(_stopLossPercent * 100)) {
          toSell.add((position.company, position.shares, true));
          continue;
        }
      }

      // Take profit check
      if (_hasTakeProfit && _takeProfitEnabled) {
        final pnlPercent = position.unrealizedPnLPercent(currentPrice);
        if (pnlPercent >= (_takeProfitPercent * 100)) {
          if (_partialTakeProfitUnlock && !_partialTpTaken.contains(posKey) && position.shares > 1) {
            // Partial TP: sell 50% first time, mark as taken
            final halfShares = (position.shares / 2).floorToDouble().clamp(1.0, position.shares - 1);
            toSell.add((position.company, halfShares, false));
            _partialTpTaken.add(posKey);
          } else {
            // Full TP (or second trigger after partial)
            toSell.add((position.company, position.shares, false));
          }
        }
      }
    }

    for (final (company, shares, isStopLoss) in toSell) {
      sell(company, shares, isStopLossTrigger: isStopLoss);
    }
  }

  /// Check leveraged positions for forced liquidation.
  /// Liquidation triggers when effective loss >= 100% of real investment.
  void _checkLeverageLiquidation() {
    if (_leverageMax <= 1.0) return;

    final toLiquidate = <(CompanyData, double, PositionType)>[];

    for (final position in _positions) {
      final typeKey = position.type == PositionType.long ? 'long' : 'short';
      final key = '${position.company.id}_$typeKey';
      final leverage = _positionLeverage[key] ?? 1.0;
      if (leverage <= 1.0) continue;

      final state = _stockStates[position.company.id];
      if (state == null) continue;

      final pnlPercent = position.unrealizedPnLPercent(state.currentPrice);
      // Effective loss = actual loss * leverage
      // Liquidate when effective loss >= 100% (or 110% with margin shield)
      final effectiveLoss = pnlPercent * leverage;
      final liquidationPoint = _marginShield ? -110.0 : -100.0;

      if (effectiveLoss <= liquidationPoint) {
        toLiquidate.add((position.company, position.shares, position.type));
      }
    }

    for (final (company, shares, type) in toLiquidate) {
      if (type == PositionType.long) {
        sell(company, shares);
      } else {
        cover(company, shares);
      }
    }
  }

  /// Check if pending limit order should execute based on current prices.
  void _checkLimitOrders() {
    if (_pendingLimitOrder == null) return;

    final order = _pendingLimitOrder!;
    final state = _stockStates[order.company.id];
    if (state == null) return;

    final currentPrice = state.currentPrice;

    if (order.isBuyOrder) {
      // Buy limit: execute when price drops to or below target
      if (currentPrice <= order.targetPrice) {
        _executeLimitBuy(order);
      }
    } else {
      // Sell limit: execute when price rises to or above target
      if (currentPrice >= order.targetPrice) {
        _executeLimitSell(order);
      }
    }
  }

  void _executeLimitBuy(LimitOrder order) {
    // Refund reserved cash, then buy at market price
    _cash = _cash + order.reservedCash;
    buy(order.company, order.shares);

    // Auto-set SL/TP if configured on the order
    if (order.stopLossPercent != null && _hasStopLoss) {
      _stopLossPercent = order.stopLossPercent!;
      _stopLossEnabled = true;
    }
    if (order.takeProfitPercent != null && _hasTakeProfit) {
      _takeProfitPercent = order.takeProfitPercent!;
      _takeProfitEnabled = true;
    }

    _pendingLimitOrder = null;
    notifyListeners();
  }

  void _executeLimitSell(LimitOrder order) {
    // Find the long position and sell
    final position = _positions
        .where((p) => p.company.id == order.company.id && p.type == PositionType.long)
        .firstOrNull;
    if (position != null) {
      final sharesToSell = order.shares.clamp(0.0, position.shares);
      if (sharesToSell > 0) sell(order.company, sharesToSell);
    }
    _pendingLimitOrder = null;
    notifyListeners();
  }

  /// Place a limit order (1 active at a time). Cash is reserved for buy orders.
  bool placeLimitOrder({
    required CompanyData company,
    required double shares,
    required BigNumber targetPrice,
    required bool isBuyOrder,
    double? stopLossPercent,
    double? takeProfitPercent,
  }) {
    if (!_limitOrdersUnlock) return false;
    if (_pendingLimitOrder != null) return false; // Already have one

    BigNumber reservedCash = BigNumber.zero;

    if (isBuyOrder) {
      // Reserve cash for the buy
      final cost = targetPrice.multiplyByDouble(shares);
      final fee = cost.multiplyByDouble(effectiveFeePercent / 100);
      final totalCost = cost + fee;
      if (_cash < totalCost) return false;
      _cash = _cash - totalCost;
      reservedCash = totalCost;
    } else {
      // Sell limit: verify we have the shares
      final position = _positions
          .where((p) => p.company.id == company.id && p.type == PositionType.long)
          .firstOrNull;
      if (position == null || position.shares < shares) return false;
    }

    _pendingLimitOrder = LimitOrder(
      id: 'limit_${DateTime.now().millisecondsSinceEpoch}',
      company: company,
      shares: shares,
      targetPrice: targetPrice,
      isBuyOrder: isBuyOrder,
      stopLossPercent: _smartOrdersUnlock ? stopLossPercent : null,
      takeProfitPercent: _smartOrdersUnlock ? takeProfitPercent : null,
      reservedCash: reservedCash,
      dayCreated: _currentDay,
    );

    notifyListeners();
    return true;
  }

  /// Cancel the pending limit order and refund reserved cash.
  bool cancelLimitOrder() {
    if (_pendingLimitOrder == null) return false;
    if (_pendingLimitOrder!.isBuyOrder) {
      _cash = _cash + _pendingLimitOrder!.reservedCash;
    }
    _pendingLimitOrder = null;
    notifyListeners();
    return true;
  }

  /// Buy with leverage (multiplied gains AND losses, auto-liquidation at 100% loss).
  bool buyWithLeverage(CompanyData company, double shares, double leverage) {
    if (leverage > _leverageMax || leverage < 1.0) return false;
    if (!buy(company, shares)) return false;
    if (leverage > 1.0) {
      _positionLeverage['${company.id}_long'] = leverage;
    }
    return true;
  }

  /// Short with leverage.
  bool shortWithLeverage(CompanyData company, double shares, double leverage) {
    if (leverage > _leverageMax || leverage < 1.0) return false;
    if (!short(company, shares)) return false;
    if (leverage > 1.0) {
      _positionLeverage['${company.id}_short'] = leverage;
    }
    return true;
  }

  /// Get leverage for a position (1.0 = no leverage).
  double getPositionLeverage(String companyId, PositionType type) {
    final key = '${companyId}_${type == PositionType.long ? 'long' : 'short'}';
    return _positionLeverage[key] ?? 1.0;
  }

  /// Reset all gameplay effects (on new run)
  void _resetGameplayEffects() {
    _activeFeeMultiplier = 1.0;
    _feeMultiplierDaysLeft = 0;
    _shortSellingBanned = false;
    _shortBanDaysLeft = 0;
    _activeUpgradeDiscount = 0.0;
    _upgradeDiscountDaysLeft = 0;
    _circuitBreakerActive = false;
    _circuitBreakerTimer = 0;
    _activeVolatilityMultiplier = 1.0;
    _volatilityMultiplierDaysLeft = 0;
    _activePositionLimit = 0;
    _positionLimitDaysLeft = 0;
    _signalJammerActive = false;
    _signalJammerDaysLeft = 0;
  }

  /// Get effective upgrade cost with active discount
  double getEffectiveUpgradeCost(Upgrade upgrade) {
    return upgrade.cost * (1 - _activeUpgradeDiscount);
  }

  /// Check if trading is allowed (circuit breaker check)
  bool get canTrade => !_circuitBreakerActive;

  /// Apply an upgrade's effects
  void _applyUpgrade(Upgrade upgrade) {
    final effects = upgrade.effects;

    // Quota reduction
    if (effects.containsKey('quotaReduction')) {
      _quotaReduction = (_quotaReduction + (effects['quotaReduction'] as double)).clamp(0.0, 0.5);
    }

    // Extra day seconds
    if (effects.containsKey('extraDaySeconds')) {
      _extraDaySeconds += effects['extraDaySeconds'] as int;
    }

    // Extra quota days
    if (effects.containsKey('extraQuotaDays')) {
      _daysPerQuota += effects['extraQuotaDays'] as int;
    }

    // === TRADING STRATEGY UPGRADES ===

    // Momentum Rider: bonus after consecutive wins
    if (effects.containsKey('momentumBonus')) {
      _momentumBonus = effects['momentumBonus'] as double;
      _momentumStreak = (effects['momentumStreak'] as int?) ?? 3;
    }

    // Contrarian: bonus when buying dropped stocks
    if (effects.containsKey('contrarianBonus')) {
      _contrarianBonus = effects['contrarianBonus'] as double;
      _contrarianThreshold = (effects['contrarianThreshold'] as double?) ?? 0.10;
    }

    // Day Trader: bonus for same-day buy/sell
    if (effects.containsKey('dayTradeBonus')) {
      _dayTradeBonus = effects['dayTradeBonus'] as double;
    }

    // Tax Refund: recover percent of losses
    if (effects.containsKey('lossRecoveryPercent')) {
      _lossRecoveryPercent = effects['lossRecoveryPercent'] as double;
    }

    // Stock Bonus: bonus shares when buying
    if (effects.containsKey('stockBonusRate')) {
      _upgradeStockBonusRate = (_upgradeStockBonusRate + (effects['stockBonusRate'] as double)).clamp(0.0, 0.25);
    }

    // Analyst Precision: improve signal accuracy
    if (effects.containsKey('analystPrecision')) {
      _analystPrecision = (_analystPrecision + (effects['analystPrecision'] as double)).clamp(0.0, 0.95);
    }

    // Extra News: more news items
    if (effects.containsKey('extraMorningNews')) {
      _extraMorningNews += effects['extraMorningNews'] as int;
    }
    if (effects.containsKey('extraMidDayNews')) {
      _extraMidDayNews += effects['extraMidDayNews'] as int;
    }

  }

  /// Get the active Sector Shield loss reduction for a given sector
  double getSectorShieldReduction(SectorType sectorType) {
    double reduction = 0.0;
    for (final acquired in _acquiredUpgrades) {
      if (acquired.templateType == 'sector_shield' && acquired.sector == sectorType) {
        final upgrade = getUpgradeById(acquired.upgradeId);
        if (upgrade != null) {
          final val = upgrade.effects['sectorLossReduction'];
          if (val != null) reduction = (val as double);
        }
      }
    }
    // Apply Sector Amplifier prestige bonus
    if (_sectorAmplifier > 0) {
      reduction *= (1 + _sectorAmplifier);
    }
    return reduction.clamp(0.0, 0.75);
  }

  /// Get the active Sector Edge profit boost for a given sector
  double getSectorEdgeBoost(SectorType sectorType) {
    double boost = 0.0;
    for (final acquired in _acquiredUpgrades) {
      if (acquired.templateType == 'sector_edge' && acquired.sector == sectorType) {
        final upgrade = getUpgradeById(acquired.upgradeId);
        if (upgrade != null) {
          final val = upgrade.effects['sectorProfitBoost'];
          if (val != null) boost = (val as double);
        }
      }
    }
    // Apply Sector Amplifier prestige bonus
    if (_sectorAmplifier > 0) {
      boost *= (1 + _sectorAmplifier);
    }
    return boost.clamp(0.0, 0.75);
  }

  /// Get the Sector Insight news bias for a given sector (0.0 = no bias)
  double getSectorInsightBias(SectorType sectorType) {
    double bias = 0.0;
    for (final acquired in _acquiredUpgrades) {
      if (acquired.templateType == 'sector_insight' && acquired.sector == sectorType) {
        final upgrade = getUpgradeById(acquired.upgradeId);
        if (upgrade != null) {
          final val = upgrade.effects['sectorNewsBias'];
          if (val != null) bias = (val as double);
        }
      }
    }
    return bias;
  }

  /// Check if a sector has news sentiment preview (Sector Insight epic+)
  bool hasSectorNewsPreview(SectorType sectorType) {
    for (final acquired in _acquiredUpgrades) {
      if (acquired.templateType == 'sector_insight' && acquired.sector == sectorType) {
        final upgrade = getUpgradeById(acquired.upgradeId);
        if (upgrade != null) {
          final val = upgrade.effects['sectorNewsPreview'];
          if (val == true) return true;
        }
      }
    }
    return false;
  }

  /// Check if a sector has guaranteed daily news (Sector Insight legendary)
  bool hasSectorGuaranteedNews(SectorType sectorType) {
    for (final acquired in _acquiredUpgrades) {
      if (acquired.templateType == 'sector_insight' && acquired.sector == sectorType) {
        final upgrade = getUpgradeById(acquired.upgradeId);
        if (upgrade != null) {
          final val = upgrade.effects['sectorGuaranteedNews'];
          if (val == true) return true;
        }
      }
    }
    return false;
  }

  /// Get all sectors that have any Sector Insight upgrade
  Map<String, double> getAllSectorInsightBiases() {
    final biases = <String, double>{};
    for (final acquired in _acquiredUpgrades) {
      if (acquired.templateType == 'sector_insight' && acquired.sector != null) {
        final upgrade = getUpgradeById(acquired.upgradeId);
        if (upgrade != null) {
          final val = upgrade.effects['sectorNewsBias'];
          if (val != null) {
            biases[acquired.sector!.name] = val as double;
          }
        }
      }
    }
    return biases;
  }

  /// Get the Sector Dominance bonus per position for a given sector
  double getSectorDominanceBonus(SectorType sectorType) {
    double bonus = 0.0;
    for (final acquired in _acquiredUpgrades) {
      if (acquired.templateType == 'sector_dominance' && acquired.sector == sectorType) {
        final upgrade = getUpgradeById(acquired.upgradeId);
        if (upgrade != null) {
          final val = upgrade.effects['sectorDominanceBonus'];
          if (val != null) bonus = (val as double);
        }
      }
    }
    return bonus;
  }

  /// Get Sector Dominance fee reduction (legendary only)
  double getSectorDominanceFeeReduction(SectorType sectorType) {
    for (final acquired in _acquiredUpgrades) {
      if (acquired.templateType == 'sector_dominance' && acquired.sector == sectorType) {
        final upgrade = getUpgradeById(acquired.upgradeId);
        if (upgrade != null) {
          final val = upgrade.effects['sectorDominanceFeeReduction'];
          if (val != null) return val as double;
        }
      }
    }
    return 0.0;
  }

  /// Get the winning streak bonus from daily upgrade (0.0 if none)
  double getWinStreakUpgradeBonus() {
    for (final acquired in _acquiredUpgrades) {
      if (acquired.templateType == 'winning_streak') {
        final upgrade = getUpgradeById(acquired.upgradeId);
        if (upgrade != null) {
          return (upgrade.effects['winStreakBonus'] as double?) ?? 0.0;
        }
      }
    }
    return 0.0;
  }

  /// Count positions held in a specific sector
  int countPositionsInSector(String sectorId) {
    return _positions.where((p) => p.company.sectorId == sectorId).length;
  }

  /// Calculate situational income at end of day
  double calculateSituationalIncome() {
    double income = 0.0;
    double incomePerStock = 0.0;
    double incomePerSector = 0.0;
    double incomePerUpgrade = 0.0;
    double incomePortfolioPercent = 0.0;

    for (final acquired in _acquiredUpgrades) {
      if (acquired.templateType == 'income_situational') {
        final upgrade = getUpgradeById(acquired.upgradeId);
        if (upgrade == null) continue;
        final effects = upgrade.effects;
        if (effects.containsKey('incomePerStock')) {
          incomePerStock += effects['incomePerStock'] as double;
        }
        if (effects.containsKey('incomePerSector')) {
          incomePerSector += effects['incomePerSector'] as double;
        }
        if (effects.containsKey('incomePerUpgrade')) {
          incomePerUpgrade += effects['incomePerUpgrade'] as double;
        }
        if (effects.containsKey('incomePortfolioPercent')) {
          incomePortfolioPercent += effects['incomePortfolioPercent'] as double;
        }
      }
    }

    // Per stock held
    if (incomePerStock > 0) {
      double totalStocks = 0;
      for (final pos in _positions) {
        totalStocks += pos.shares;
      }
      income += totalStocks * incomePerStock;
    }

    // Per distinct sector
    if (incomePerSector > 0) {
      final sectors = <String>{};
      for (final pos in _positions) {
        sectors.add(pos.company.sectorId);
      }
      income += sectors.length * incomePerSector;
    }

    // Per upgrade owned
    if (incomePerUpgrade > 0) {
      income += _acquiredUpgrades.length * incomePerUpgrade;
    }

    // Portfolio percent
    if (incomePortfolioPercent > 0) {
      double portfolioValue = 0;
      for (final pos in _positions) {
        final state = _stockStates[pos.company.id];
        if (state != null) {
          portfolioValue += state.currentPrice.toDouble() * pos.shares;
        }
      }
      income += portfolioValue * incomePortfolioPercent;
    }

    return income;
  }

  /// Reset game state for new year (after quota failure)
  void _resetForNewYear() {
    // Clear positions and position tracking
    _positions.clear();
    _positionOpenDay.clear();
    _positionLeverage.clear();
    _positionHighPrice.clear();
    _partialTpTaken.clear();
    _safetyNetUsed = false;

    // Cancel pending limit order (refund cash before reset)
    if (_pendingLimitOrder != null) {
      // No need to refund — cash is being reset anyway
      _pendingLimitOrder = null;
    }

    // Reset cash to starting amount + prestige bonus + meta bonus
    _cash = BigNumber(startingCash + _startingCashBonus + _metaStartingCashBonus);

    // Reset quota to starting value (doesn't scale with year anymore)
    // Quota increases progressively WITHIN a run after each successful period
    _quotaTarget = BigNumber(startingQuota);
    _quotaProgress = BigNumber.zero;

    // Reset day
    _currentDay = 1;
    _dayTimer = effectiveDayDuration;

    // Reset upgrades for new run
    _isEndOfDay = false;
    _showUpgradeSelection = false;
    _acquiredUpgrades.clear();

    // Reset shop
    _shopUpgrades.clear();
    _shopRollsToday = 0;
    _dailyRerollsUsed = List.filled(3 + _extraUpgradeChoices, 0);

    // Reset upgradeable settings to defaults
    _daysPerQuota = 3; // Base: 3 days per quota period
    _feeReduction = 0.0;
    _maxPositions = 3;
    _quotaReduction = 0.0;
    _skipQuotaBonusPercent = 0.15;
    _extraDaySeconds = 0;
    _passiveIncome = 0.0;

    // Reset unlocked companies (except starter tier)
    _unlockedCompanyIds.clear();

    // Reset tokens (they're per-run)
    _tokens.clear();

    // Reset gameplay effects
    _resetGameplayEffects();

    // Reset legacy prestige effect values
    _upgradeRerollsPerDay = 0;
    _upgradeRerollsUsedToday = 0;
    _guaranteedRareFirst = false;
    _usedGuaranteedRare = false;
    _vipUsedThisYear = false;
    _quotaFailFreebies = 0;
    _keepCashOnFailPercent = 0.0;
    _extraUpgradeChoices = 0;
    _shortBanImmunity = false;
    _startingUpgrades = 0;
    _isStartingUpgradeSelection = false;
    _prestigePointMultiplier = 0.0;
    _cashInterestRate = 0.0;
    _shopRarityBoost = 0.0;
    _freeRollsPerDay = 1;
    _sectorAmplifier = 0.0;

    // Reset talent tree effects
    _profitMultiplier = 0.0;
    _signalAccuracy = 0.0;
    _lossReduction = 0.0;
    _crashImpactReduction = 0.0;
    _maxLossPerTrade = 1.0;
    _holdBonus = 0.0;
    _survivesWipeout = 0;
    _eventLossReduction = 0.0;
    _keepCapitalOnWipe = 0.0;
    _robotWinRateBonus = 0.0;
    _robotSpeedBonus = 0.0;
    _robotUpgradeCostReduction = 0.0;
    _robotStartLevel = 0;
    _robotAutoCollect = 0;
    _robotSeedMoney = 0.0;
    _maxRobotSlots = 0;
    _newsCategoryPreview = false;
    _tipExactPercent = false;
    _flagBadTips = false;
    _priceForesight = false;
    _freeTipsPerDay = 0;
    _tipPrecisionMultiplier = 0.0;
    _tipCostReduction = 0.0;
    _shortTermProfitBonus = 0.0;
    _diversificationBonus = 0.0;
    _disinfoShield = false;
    _blockBadEvents = 0;
    _blockBadEventsUsed = 0;
    _freeTipsUsedToday = 0;
    // Intelligence branch
    _extraActiveInfluencers = 0;
    _extraNewsPerDay = 0;
    _fintokAccuracyBonus = 0.0;
    _sectorProfitBonuses.clear();
    _sectorLossShields.clear();
    _sectorPassiveIncomes.clear();
    _sectorCapstones.clear();
    _sectorTierUnlocks.clear();
    // Trader branch
    _extraPositionSlots = 0;
    _unlimitedPositions = false;
    _stopLossUnlock = false;
    _takeProfitUnlock = false;
    _trailingStopUnlock = false;
    _partialTakeProfitUnlock = false;
    _safetyNetUnlock = false;
    _quickFlipBonus = 0.0;
    _scalperNoFees = false;
    _holdBonus3d = 0.0;
    _holdBonus5d = 0.0;
    _holdBonus7d = 0.0;
    _limitOrdersUnlock = false;
    _smartOrdersUnlock = false;
    _streakBonusPerWin = 0.0;
    _streakMaxStacks = 0;
    _streakKeepOnLoss = false;
    _leverageMax = 1.0;
    _marginShield = false;
    _compoundInterestRate = 0.0;
    // Survival branch
    _extraLives = 0;
    _livesRemaining = 0;
    _extraQuotaDays = 0;
    _survivalQuotaReduction = 0.0;
    _skipQuotaBonus = 0.0;
    _skipStreakBonus = 0.0;
    _overtimeDays = 0;
    _secondWindBonus = 0.0;
    _secondWindDaysLeft = 0;
    _resurrectQuotaReduction = 0.0;
    _earlyFinishPP = 0.0;
    _earlyFinishPP2 = 0.0;
    _speedrunPPMultiplier = false;
    _streakProfitBonus = 0.0;
    _streakPersists = false;
    _quotaStreak = 0;
    _consecutiveSkips = 0;
    _allQuotasEarly = true;
    _overtimeDaysLeft = 0;
    _inOvertime = false;

    // Reset trading strategy bonuses
    _consecutiveWins = 0;
    _momentumBonus = 0.0;
    _momentumStreak = 0;
    _contrarianBonus = 0.0;
    _contrarianThreshold = 0.0;
    _dayTradeBonus = 0.0;
    _boughtTodayCompanies.clear();
    _lossRecoveryPercent = 0.0;
    _dailyRealizedLosses = 0.0;
    _contrarianBuys.clear();
    _upgradeStockBonusRate = 0.0;
    _extraMorningNews = 0;
    _extraMidDayNews = 0;
    _analystPrecision = 0.5;

    // Reset stop loss / take profit
    _hasStopLoss = false;
    _hasTakeProfit = false;
    _stopLossEnabled = false;
    _takeProfitEnabled = false;
    _trailingStopEnabled = false;
    _stopLossPercent = 0.10;
    _takeProfitPercent = 0.20;

    // Reset trade history for new year
    _tradeHistory.clear();
    _totalTrades = 0;
    _winningTrades = 0;
    _totalRealizedPnL = BigNumber.zero;
    _totalOpeningExpenses = BigNumber.zero;
    _totalRobotExpenses = BigNumber.zero;

    // Reset stock prices to initial
    for (final state in _stockStates.values) {
      state.resetToInitialPrice();
    }

    // Apply prestige effects for the new run
    _applyPrestigeEffectsOnReset();

    notifyListeners();
  }

  // === GAME LOOP ===
  void startGame() {
    _isPaused = false;
    // notifyListeners below auto-invalidates cache
    // Track net worth at day start for end-of-day narrative
    if (_dayStartNetWorth == 0.0) {
      _dayStartNetWorth = netWorth.toDouble();
    }
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), _gameLoop);
    notifyListeners();
  }

  void pauseGame() {
    _isPaused = true;
    _gameTimer?.cancel();
    notifyListeners();
  }

  // === COMPUTED VALUE CACHE ===
  // Invalidated on each market update to avoid recalculating expensive getters
  BigNumber? _cachedNetWorth;
  BigNumber? _cachedPortfolioValue;
  BigNumber? _cachedUnrealizedPnL;
  BigNumber? _cachedLongPortfolioValue;
  BigNumber? _cachedShortPortfolioValue;

  void _invalidateCache() {
    _cachedNetWorth = null;
    _cachedPortfolioValue = null;
    _cachedUnrealizedPnL = null;
    _cachedLongPortfolioValue = null;
    _cachedShortPortfolioValue = null;
  }

  void _gameLoop(Timer timer) {
    if (_isPaused) return;

    final deltaTime = 0.016 * _gameSpeed;

    // Update circuit breaker timer
    _updateCircuitBreaker(deltaTime);

    _dayTimer -= deltaTime;
    _marketUpdateTimer += deltaTime;

    // Check if market day ended (19h)
    if (_dayTimer <= 0) {
      _dayTimer = 0; // Clamp to 0
      _isEndOfDay = true;
      _isPaused = true;
      _gameTimer?.cancel();
      _generateEndOfDayNarrative();
      _checkPersonalBestsAndMilestones();
      // Track most days survived
      if (_currentDay > _mostDaysSurvived) _mostDaysSurvived = _currentDay;
      notifyListeners();
      return;
    }

    // Check for mid-day news (at ~50% of the day, around 13h30)
    final dayProgress = (effectiveDayDuration - _dayTimer) / effectiveDayDuration;
    if (!_midDayNewsTriggered && dayProgress >= 0.5) {
      _triggerMidDayNews();
    }

    // Only update market at specified interval
    bool marketUpdated = false;
    if (_marketUpdateTimer >= marketUpdateInterval) {
      _simulateMarket();
      _marketUpdateTimer = 0;
      marketUpdated = true;

      // Check stop loss / take profit after price update
      _checkStopLossTakeProfit();
      _checkLeverageLiquidation();
      _checkLimitOrders();
    }

    // Throttle UI updates: only notify on market updates (~every 2s)
    // This reduces rebuilds from ~60/sec to ~0.5/sec
    if (marketUpdated) {
      _updatePeakNetWorth();
      notifyListeners();
    }
  }

  /// Skip quota early — pay the quota now and get a bonus on the excess
  void skipQuota() {
    if (!canSkipQuota) return;

    final effectiveTarget = effectiveQuotaTarget;
    _cash = _cash - effectiveTarget;
    if (_cash.isNegative) _cash = BigNumber.zero;

    // Bonus on excess (higher than normal 10% — base 15%, boosted by prestige + talent tree)
    final excess = _quotaProgress - effectiveTarget;
    if (excess.isPositive) {
      final skipBonus = _skipQuotaBonusPercent + _skipQuotaBonus;
      _cash = _cash + excess.multiplyByDouble(skipBonus);
    }

    // Skip streak: consecutive skips compound
    _consecutiveSkips++;
    if (_skipStreakBonus > 0 && _consecutiveSkips > 1) {
      final streakCashBonus = effectiveTarget.multiplyByDouble(_skipStreakBonus * (_consecutiveSkips - 1));
      _cash = _cash + streakCashBonus;
    }

    // Increase quota target for next period
    _quotaTarget = _quotaTarget.multiplyByDouble(1 + quotaIncreasePercent);
    _quotaProgress = BigNumber.zero;

    // Track early finishes for speedrunner
    _quotaStreak++;

    // Early finish PP bonus (skipQuota = always early, since it happens before quota day)
    final daysUntil = daysUntilQuota; // days remaining before quota day
    if (_earlyFinishPP > 0) {
      final bonusPP = (1 + (_earlyFinishPP * 10)).ceil(); // At least 1 PP per early finish
      _prestigePoints += bonusPP;
      _totalPrestigePoints += bonusPP;
    }
    if (daysUntil >= 1 && _earlyFinishPP2 > 0) {
      final bonusPP2 = (1 + (_earlyFinishPP2 * 10)).ceil();
      _prestigePoints += bonusPP2;
      _totalPrestigePoints += bonusPP2;
    }

    onQuotaMet?.call();
    notifyListeners();
  }

  /// Called by player to advance to the next day
  /// Evaluates quota first (if quota day), then shows upgrade selection
  void nextDay() {
    if (!_isEndOfDay) return;

    // Check if TODAY is the end of a quota period
    // Quota is checked at the end of days 3, 6, 9... (when currentDay % daysPerQuota == 0)
    final isQuotaDay = _currentDay % _daysPerQuota == 0;

    // If it's a quota day, evaluate quota BEFORE showing upgrades
    if (isQuotaDay && !_showPrestigeShop) {
      // If returning from overtime, revert the temporary extension
      if (_inOvertime) {
        _daysPerQuota -= _overtimeDays;
        _inOvertime = false;
      }

      final effectiveTarget = effectiveQuotaTarget;

      if (_quotaProgress >= effectiveTarget) {
        // Quota met! Deduct quota from cash, give bonus on excess
        _cash = _cash - effectiveTarget;
        if (_cash.isNegative) { _cash = BigNumber.zero; }
        final excess = _quotaProgress - effectiveTarget;
        if (excess.isPositive) {
          _cash = _cash + excess.multiplyByDouble(0.1); // 10% bonus
        }

        // Not early (evaluated on exact quota day) — mark for speedrunner tracking
        _allQuotasEarly = false;

        _quotaTarget = _quotaTarget.multiplyByDouble(1 + quotaIncreasePercent);
        _quotaProgress = BigNumber.zero;

        // Quota streak: track consecutive successes
        _quotaStreak++;
        _consecutiveSkips = 0; // Reset skip streak on normal success

        // Notify achievement system + fanfare
        onQuotaMet?.call();

        // Continue to upgrade selection
      } else {
        // Quota failed!

        // Overtime: grant emergency extra days before truly failing
        if (_overtimeDays > 0 && _overtimeDaysLeft <= 0) {
          _inOvertime = true;
          _overtimeDaysLeft = _overtimeDays;
          _daysPerQuota += _overtimeDays; // Temporarily extend this quota period
          // Don't fail yet — continue to upgrade selection
        }
        // Second Chance: Use a freebie to survive
        else if (_quotaFailFreebies > 0) {
          _quotaFailFreebies--;
          // Reset quota progress but don't increase target (mercy)
          _quotaProgress = BigNumber.zero;
          _allQuotasEarly = false;
          // Continue to upgrade selection instead of failing
        }
        // Extra Lives: use a life to survive
        else if (_livesRemaining > 0) {
          _livesRemaining--;
          _quotaProgress = BigNumber.zero;

          // Resurrect quota reduction: lower quota target on resurrect
          if (_resurrectQuotaReduction > 0) {
            _quotaTarget = _quotaTarget.multiplyByDouble(1.0 - _resurrectQuotaReduction);
          }

          // Second Wind: profit bonus for X days after using a life
          if (_secondWindBonus > 0) {
            _secondWindDaysLeft = 3;
          }

          // Streak handling: persists through lives if talent purchased
          if (!_streakPersists) {
            _quotaStreak = 0;
          }
          _allQuotasEarly = false;
          // Continue to upgrade selection
        } else {
          // Actually failed - apply Golden Parachute if available
          if (_keepCashOnFailPercent > 0) {
            // Save some cash for next run (stored temporarily)
            _startingCashBonus += _cash.toDouble() * _keepCashOnFailPercent;
          }

          // Speedrunner PP multiplier: x2 PP if every quota was completed early
          if (_speedrunPPMultiplier && _allQuotasEarly && _quotaStreak > 0) {
            final bonusPP = _prestigePoints;
            _prestigePoints += bonusPP;
            _totalPrestigePoints += bonusPP;
          }

          _failedQuotas++;
          _lifetimeEarnings = _lifetimeEarnings + _totalRealizedPnL;
          _generateRunSummary();
          _showPrestigeShop = true;
          _isPaused = true;
          notifyListeners();
          return; // Stop here, prestige shop will handle reset
        }
      }
    }

    // If upgrade selection not shown yet, show it
    if (!_showUpgradeSelection && _upgradeChoices.isEmpty) {
      _generateUpgradeChoices();
      if (_upgradeChoices.isNotEmpty) {
        _showUpgradeSelection = true;
        notifyListeners();
        return; // Wait for upgrade selection (selectUpgrade or skipUpgradeSelection will advance)
      }
    }

    // No upgrades available, just advance directly
    _finishDayAndAdvance();
  }

  void _advanceDay() {
    // Notify achievement system of day end (before incrementing day)
    _notifyDayEnd();

    _currentDay++;
    _freeTipsUsedToday = 0; // Reset free informant tips daily

    // Decrement survival timers
    if (_secondWindDaysLeft > 0) _secondWindDaysLeft--;
    if (_overtimeDaysLeft > 0) _overtimeDaysLeft--;

    // Earn prestige points per day survived (with multiplier from Prestige Accelerator)
    final prestigeEarned = 1 + (_prestigePointMultiplier > 0 ? (_prestigePointMultiplier).ceil() : 0);
    _prestigePoints += prestigeEarned;
    _totalPrestigePoints += prestigeEarned;

    // Apply diversification bonus
    _applyDiversificationBonus();

    // Decrement gameplay effect durations
    _decrementEffectDurations();

    // Remove old news that no longer have active effects
    // Keep only news with active duration-based gameplay effects
    _newsItems.removeWhere((n) =>
        !n.hasGameplayEffect || n.effectDurationDays == 0);

    // Remove old FinTok tips (keep only current day's unresolved tips)
    _tips.removeWhere((t) => t.dayPosted < _currentDay);

    // Generate news for the new day
    _generateDailyNews();

    // Check for special events
    _checkAndTriggerSpecialEvent();

    // Update FinTok influencers
    _updateFinTok();

    // Check for secret informant visit
    _checkInformantVisit();

    // Resolve any pending informant tips
    _resolveInformantTips();

    // Refresh daily challenges
    _refreshDailyChallenges();

    // Update market regime
    _updateMarketRegime();

    // Refresh analyst ratings every 3 days
    if (_currentDay - _lastAnalystUpdateDay >= 3) {
      _refreshAnalystRatings();
      _lastAnalystUpdateDay = _currentDay;
    }

    // Note: Quota is now evaluated in nextDay() BEFORE showing upgrades
    // This ensures failed quota doesn't waste an upgrade selection

    // Check year end
    if (_currentDay > daysPerYear) {
      _advanceYear();
    }

    // Start new day for stocks
    for (final state in _stockStates.values) {
      state.startNewDay(dayNumber: _currentDay);
    }

    // Reset price alert tracking for new day
    _lastNotifiedPriceChange.clear();
  }

  void _refreshAnalystRatings() {
    // Clear cache to force regeneration
    _analystDataCache.clear();
  }

  /// Apply daily diversification bonus based on sector spread
  void _applyDiversificationBonus() {
    if (_positions.isEmpty) return;

    // Count distinct sectors
    final sectorsInvested = _positions
        .map((p) => p.company.sectorId)
        .toSet()
        .length;

    // Bonus tiers:
    // 2 sectors: +$5/day
    // 3 sectors: +$15/day
    // 4 sectors: +$30/day
    // 5 sectors: +$50/day
    // 6+ sectors: +$75/day
    double bonusAmount = 0;
    if (sectorsInvested >= 6) {
      bonusAmount = 75;
    } else if (sectorsInvested >= 5) {
      bonusAmount = 50;
    } else if (sectorsInvested >= 4) {
      bonusAmount = 30;
    } else if (sectorsInvested >= 3) {
      bonusAmount = 15;
    } else if (sectorsInvested >= 2) {
      bonusAmount = 5;
    }

    if (bonusAmount > 0) {
      _cash = _cash + BigNumber(bonusAmount);

      // Notify bonus (optional - can be used for notification)
      // onDiversificationBonus?.call(sectorsInvested, bonusAmount);
    }
  }

  /// Get profit multiplier based on portfolio diversification
  /// Returns bonus percentage (e.g., 0.05 = +5%)
  double _getDiversificationMultiplier() {
    if (_positions.isEmpty) return 0;

    final sectorsInvested = _positions
        .map((p) => p.company.sectorId)
        .toSet()
        .length;

    // Multiplier tiers:
    // 2 sectors: +2%
    // 3 sectors: +4%
    // 4 sectors: +6%
    // 5 sectors: +8%
    // 6+ sectors: +10%
    if (sectorsInvested >= 6) return 0.10;
    if (sectorsInvested >= 5) return 0.08;
    if (sectorsInvested >= 4) return 0.06;
    if (sectorsInvested >= 3) return 0.04;
    if (sectorsInvested >= 2) return 0.02;
    return 0;
  }

  /// Check and potentially trigger a special market event
  void _checkAndTriggerSpecialEvent() {
    // Decrement active event duration
    if (_activeEventDaysLeft > 0) {
      _activeEventDaysLeft--;
      if (_activeEventDaysLeft <= 0) {
        _activeSpecialEvent = null;
      }
    }

    // Try to trigger a new event (only if no active event)
    if (_activeSpecialEvent == null) {
      final event = getRandomEvent(_recentEventIds, _currentDay);
      if (event != null) {
        // Talent tree: blockBadEvents can cancel negative events
        final isNegative = event.impact == EventImpact.negative || event.impact == EventImpact.veryNegative;
        if (isNegative && _blockBadEvents > 0 && _blockBadEventsUsed < _blockBadEvents) {
          _blockBadEventsUsed++;
          // Event is blocked — still add to cooldown so it doesn't retry immediately
          _recentEventIds.add(event.id);
          if (_recentEventIds.length > _maxRecentEvents) {
            _recentEventIds.removeAt(0);
          }
          onEventAlert?.call(
            '🛡️ Event Blocked!',
            '${event.title} was neutralized by your intelligence network.',
            true,
          );
        } else {
          _triggerSpecialEvent(event);
        }
      }
    }
  }

  /// Trigger a special event
  void _triggerSpecialEvent(EventData event) {
    _activeSpecialEvent = event;
    _activeEventDaysLeft = event.durationDays;

    // Track for cooldown
    _recentEventIds.add(event.id);
    if (_recentEventIds.length > _maxRecentEvents) {
      _recentEventIds.removeAt(0);
    }

    // Apply immediate price impact
    _applyEventPriceImpact(event);

    // Notify via callback
    onEventAlert?.call(
      event.title,
      event.description,
      event.impact == EventImpact.positive || event.impact == EventImpact.veryPositive,
    );
  }

  /// Apply price impact from an event
  void _applyEventPriceImpact(EventData event) {
    final impactPercent = event.getRandomImpact();

    // Talent tree: reduce negative event impact on player-held stocks (Defense branch)
    final heldCompanyIds = _positions.map((p) => p.company.id).toSet();

    if (event.isMarketWide) {
      // Apply to all stocks
      for (final entry in _stockStates.entries) {
        double adjusted = impactPercent;
        if (adjusted < 0 && _crashImpactReduction > 0 && heldCompanyIds.contains(entry.key)) {
          adjusted *= (1.0 - _crashImpactReduction);
        }
        final multiplier = 1.0 + (adjusted / 100);
        final newPrice = entry.value.currentPrice.multiplyByDouble(multiplier);
        entry.value.updatePrice(newPrice);
        entry.value.currentVolatility *= event.volatilityMultiplier;
      }
    } else if (event.isSectorWide) {
      // Apply to affected sectors
      for (final entry in _stockStates.entries) {
        final company = allCompanies.firstWhere((c) => c.id == entry.key);
        if (event.affectedSectorIds.contains(company.sectorId)) {
          double adjusted = impactPercent;
          if (adjusted < 0 && _crashImpactReduction > 0 && heldCompanyIds.contains(entry.key)) {
            adjusted *= (1.0 - _crashImpactReduction);
          }
          final multiplier = 1.0 + (adjusted / 100);
          final newPrice = entry.value.currentPrice.multiplyByDouble(multiplier);
          entry.value.updatePrice(newPrice);
          entry.value.currentVolatility *= event.volatilityMultiplier;
        }
      }
    } else if (event.isCompanySpecific) {
      // Apply to specific companies
      for (final companyId in event.affectedCompanyIds) {
        final state = _stockStates[companyId];
        if (state != null) {
          double adjusted = impactPercent;
          if (adjusted < 0 && _crashImpactReduction > 0 && heldCompanyIds.contains(companyId)) {
            adjusted *= (1.0 - _crashImpactReduction);
          }
          final multiplier = 1.0 + (adjusted / 100);
          final newPrice = state.currentPrice.multiplyByDouble(multiplier);
          state.updatePrice(newPrice);
          state.currentVolatility *= event.volatilityMultiplier;
        }
      }
    }
  }

  /// Get current event volatility multiplier for a stock
  double getEventVolatilityMultiplier(String companyId) {
    if (_activeSpecialEvent == null) return 1.0;

    final event = _activeSpecialEvent!;
    final company = allCompanies.firstWhere((c) => c.id == companyId);

    if (event.isMarketWide) {
      return event.volatilityMultiplier;
    } else if (event.isSectorWide && event.affectedSectorIds.contains(company.sectorId)) {
      return event.volatilityMultiplier;
    } else if (event.isCompanySpecific && event.affectedCompanyIds.contains(companyId)) {
      return event.volatilityMultiplier;
    }

    return 1.0;
  }

  // === FINTOK METHODS ===

  /// Check for new influencer arrivals and departures at day start
  void _updateFinTok() {
    // Check for departures
    for (final influencer in _influencers.where((i) => i.isActive).toList()) {
      if (influencer.shouldDepart(_currentDay)) {
        _influencerDeparts(influencer);
      }
    }

    // Check for new arrivals (random chance if below max)
    if (activeInfluencers.length < _maxActiveInfluencers) {
      // 40% chance each day to get a new influencer
      if (_random.nextDouble() < 0.40) {
        _spawnNewInfluencer();
      }
    }

    // Schedule tips throughout the day instead of generating all at once
    _scheduledTips.clear();
    for (final influencer in activeInfluencers) {
      if (_random.nextDouble() < 0.60) {
        // Schedule at random point between 5% and 85% of the day
        final targetProgress = 0.05 + _random.nextDouble() * 0.80;
        _scheduledTips.add((influencerId: influencer.id, targetProgress: targetProgress));
      }
    }
    // Sort by time so we can check in order
    _scheduledTips.sort((a, b) => a.targetProgress.compareTo(b.targetProgress));

    // Resolve old tips (after 3 days)
    _resolvePendingTips();
  }

  /// Spawn a new influencer from templates
  void _spawnNewInfluencer() {
    // Import needed at top, we reference data
    final availableTemplates = influencerTemplates
        .where((t) => !_usedInfluencerTemplateIds.contains(t['id']))
        .toList();

    if (availableTemplates.isEmpty) {
      // Reset if all used
      _usedInfluencerTemplateIds.clear();
      return;
    }

    final template = availableTemplates[_random.nextInt(availableTemplates.length)];
    final influencer = createInfluencerFromTemplate(template, _currentDay, locale: _locale);

    _influencers.add(influencer);
    _usedInfluencerTemplateIds.add(influencer.id);

    // Notify
    onEventAlert?.call(
      '${influencer.avatar} ${influencer.name} ${_locale == 'fr' ? 'a rejoint FinTok !' : 'joined FinTok!'}',
      influencer.bio,
      true,
    );
  }

  /// Handle influencer departure
  void _influencerDeparts(Influencer influencer) {
    influencer.isActive = false;
    influencer.dayDeparted = _currentDay;
    influencer.farewellMessage = getFarewellMessage(influencer.displayedAccuracy, locale: _locale);

    // Notify
    onEventAlert?.call(
      '${influencer.avatar} ${influencer.name} ${_locale == 'fr' ? 'a quitte FinTok' : 'left FinTok'}',
      influencer.farewellMessage ?? (_locale == 'fr' ? 'Au revoir !' : 'Goodbye!'),
      false,
    );
  }

  /// Generate a tip from an influencer
  void _generateInfluencerTip(Influencer influencer) {
    // Pick a random stock
    final availableStocks = _stockStates.entries.toList();
    if (availableStocks.isEmpty) return;

    // Sector experts prefer their specialty
    List<MapEntry<String, StockState>> candidates;
    if (influencer.type == InfluencerType.sectorExpert && influencer.specialtySector != null) {
      candidates = availableStocks.where((e) {
        final company = allCompanies.firstWhere((c) => c.id == e.key);
        return company.sectorId == influencer.specialtySector!.name;
      }).toList();
      if (candidates.isEmpty) candidates = availableStocks;
    } else {
      candidates = availableStocks;
    }

    final stockEntry = candidates[_random.nextInt(candidates.length)];
    final company = allCompanies.firstWhere((c) => c.id == stockEntry.key);

    // Determine if bullish or bearish based on influencer type
    bool isBullish;
    switch (influencer.type) {
      case InfluencerType.bullish:
        isBullish = true;
        break;
      case InfluencerType.bearish:
        isBullish = false;
        break;
      default:
        // Others: slight bias toward recent momentum
        final recentChange = stockEntry.value.dayChangePercent;
        isBullish = recentChange > 0 ? _random.nextDouble() > 0.3 : _random.nextDouble() > 0.7;
    }

    // Viral chance: 8% base, meme traders 15%
    final viralChance = influencer.type == InfluencerType.memeTrader ? 0.15 : 0.08;
    final isViral = _random.nextDouble() < viralChance;

    // Generate message (use locale-aware phrases from template data)
    final phrases = getInfluencerPhrases(influencer.id, isBullish, _locale);
    final fallbackPhrases = isBullish ? influencer.bullishPhrases : influencer.bearishPhrases;
    final effectivePhrases = phrases.isNotEmpty ? phrases : fallbackPhrases;
    String message;
    if (effectivePhrases.isNotEmpty) {
      message = '\$${company.ticker} ${effectivePhrases[_random.nextInt(effectivePhrases.length)]}';
    } else {
      message = '\$${company.ticker} ${isBullish ? "looks bullish!" : "looks bearish!"}';
    }

    // Add catchphrase sometimes (locale-aware)
    final catchphrases = getInfluencerCatchphrases(influencer.id, _locale);
    final effectiveCatchphrases = catchphrases.isNotEmpty ? catchphrases : influencer.catchphrases;
    if (effectiveCatchphrases.isNotEmpty && _random.nextDouble() < 0.3) {
      message += ' ${effectiveCatchphrases[_random.nextInt(effectiveCatchphrases.length)]}';
    }

    final tip = InfluencerTip(
      id: 'tip_${_currentDay}_${influencer.id}_${_random.nextInt(1000)}',
      influencerId: influencer.id,
      stockId: company.id,
      stockName: company.ticker,
      isBullish: isBullish,
      isViral: isViral,
      message: message,
      dayPosted: _currentDay,
      priceAtPost: stockEntry.value.currentPrice.toDouble(),
    );

    _tips.insert(0, tip);

    // Trim old tips
    while (_tips.length > _maxTips) {
      _tips.removeLast();
    }

    // Apply price impact from tip (small pump/dump)
    _applyTipPriceImpact(tip, influencer);
  }

  /// Apply a small price impact from an influencer tip
  void _applyTipPriceImpact(InfluencerTip tip, Influencer influencer) {
    final state = _stockStates[tip.stockId];
    if (state == null) return;

    // Base impact: scaled by follower count (more followers = bigger impact)
    // Normal tip: ±0.5% to ±1.5% based on followers
    // Viral tip: 3x multiplier
    final followerScale = (influencer.followers / 5000).clamp(0.2, 1.0);
    double baseImpact = 0.005 + followerScale * 0.01; // 0.5% to 1.5%

    if (tip.isViral) {
      baseImpact *= 3.0; // Viral = 1.5% to 4.5%
      // Viral tips also boost influencer followers
      influencer.followers = (influencer.followers * 1.15).round();
    }

    // Apply direction
    final impact = tip.isBullish ? baseImpact : -baseImpact;

    // Add as pending impact (gradual application like news but smaller)
    state.addPendingImpact(impact);

    // Slight trend nudge
    state.trendDirection = (state.trendDirection + impact * 2).clamp(-1.0, 1.0);
  }

  /// Resolve tips that are 3+ days old
  void _resolvePendingTips() {
    for (final tip in _tips.where((t) => t.wasAccurate == null)) {
      if (_currentDay - tip.dayPosted >= 3) {
        final state = _stockStates[tip.stockId];
        if (state != null) {
          final currentPrice = state.currentPrice.toDouble();
          final priceChange = (currentPrice - tip.priceAtPost) / tip.priceAtPost;

          // Tip was accurate if:
          // - Bullish and price went up 2%+
          // - Bearish and price went down 2%+
          var wasAccurate = tip.isBullish ? priceChange >= 0.02 : priceChange <= -0.02;

          // FinTok accuracy bonus: meta progression + talent tree
          // (influencer got lucky / market moved in their favor later)
          final totalFintokBonus = _metaFintokAccuracyBonus + _fintokAccuracyBonus;
          if (!wasAccurate && totalFintokBonus > 0) {
            if (_random.nextDouble() < totalFintokBonus) {
              wasAccurate = true;
            }
          }

          tip.wasAccurate = wasAccurate;
          tip.priceAtResolution = currentPrice;

          // Update influencer stats
          final influencer = getInfluencerById(tip.influencerId);
          influencer?.recordTipOutcome(wasAccurate);
        }
      }
    }
  }

  // === SECRET INFORMANT METHODS ===

  /// Check for informant visit at day start
  void _checkInformantVisit() {
    // Check if enough days have passed since last visit
    final daysSinceLastVisit = _currentDay - _informantState.lastVisitDay;
    if (daysSinceLastVisit < _minDaysBetweenInformantVisits) {
      return;
    }

    // Random chance for informant to appear (base + meta bonus)
    final effectiveInformantChance = (_informantVisitChance + _metaInformantBonus).clamp(0.0, 0.75);
    if (_random.nextDouble() < effectiveInformantChance) {
      _triggerInformantVisit();
    }
  }

  /// Trigger an informant visit
  void _triggerInformantVisit() {
    _informantState.isAvailable = true;
    _informantState.lastVisitDay = _currentDay;
    _informantState.visitsThisRun++;
    _informantState.currentTips.clear();

    // Generate 2-4 tips
    final tipCount = 2 + _random.nextInt(3);
    for (int i = 0; i < tipCount; i++) {
      _generateInformantTip();
    }

    _showInformantPopup = true;

    // Notify
    onEventAlert?.call(
      '🕵️ Secret Informant',
      'Someone wants to share information with you...',
      true,
    );

    notifyListeners();
  }

  /// Generate a single informant tip
  void _generateInformantTip() {
    // Pick random stock — only from unlocked companies
    final availableStocks = _stockStates.entries
        .where((e) => isCompanyUnlocked(e.key))
        .toList();
    if (availableStocks.isEmpty) return;

    final stockEntry = availableStocks[_random.nextInt(availableStocks.length)];
    final company = allCompanies.firstWhere((c) => c.id == stockEntry.key);

    // Pick random tip type
    final tipTypes = InformantTipType.values;
    final tipType = tipTypes[_random.nextInt(tipTypes.length)];

    // Pick reliability (weighted toward lower quality)
    final reliabilities = InformantReliability.values;
    final reliabilityIndex = _random.nextInt(100) < 50 ? 0 : (_random.nextInt(100) < 75 ? 1 : (_random.nextInt(100) < 90 ? 2 : 3));
    final reliability = reliabilities[reliabilityIndex];

    // Determine if bullish or bearish
    final isBullish = _random.nextBool();

    // Get teaser message
    final teasers = teaserMessages[tipType] ?? ['I have information about {stock}...'];
    var teaser = teasers[_random.nextInt(teasers.length)];
    teaser = teaser.replaceAll('{stock}', company.ticker);
    teaser = teaser.replaceAll('{sector}', company.sectorId);

    // Get secret message
    final secrets = isBullish ? bullishSecrets[tipType] : bearishSecrets[tipType];
    var secret = (secrets ?? ['Big move coming for {stock}.'])[_random.nextInt((secrets ?? ['']).length)];
    secret = secret.replaceAll('{stock}', company.ticker);
    secret = secret.replaceAll('{sector}', company.sectorId);

    // Calculate price (talent tree: tipCostReduction lowers cost)
    var price = getTipPrice(reliability, _currentDay);
    if (_tipCostReduction > 0) {
      price *= (1.0 - _tipCostReduction.clamp(0.0, 0.9)); // cap at 90% reduction
    }

    // Calculate actual accuracy (base + meta bonus, capped at 99%)
    var baseAccuracy = switch (reliability) {
      InformantReliability.questionable => 0.50 + (_random.nextDouble() * 0.10),
      InformantReliability.decent => 0.60 + (_random.nextDouble() * 0.15),
      InformantReliability.reliable => 0.75 + (_random.nextDouble() * 0.15),
      InformantReliability.impeccable => 0.90 + (_random.nextDouble() * 0.09),
    } + _metaFintokAccuracyBonus + _fintokAccuracyBonus; // Meta + talent tree bonus
    // Talent tree: tipPrecisionMultiplier boosts accuracy
    if (_tipPrecisionMultiplier > 0) {
      baseAccuracy *= (1.0 + _tipPrecisionMultiplier);
    }
    final actualAccuracy = baseAccuracy.clamp(0.0, 0.99);

    final tip = InformantTip(
      id: 'informant_tip_${_currentDay}_${_random.nextInt(10000)}',
      type: tipType,
      stockId: company.id,
      stockName: company.ticker,
      sectorId: company.sectorId,
      isBullish: isBullish,
      message: teaser,
      secretMessage: secret,
      price: price,
      reliability: reliability,
      actualAccuracy: actualAccuracy,
      expiresDay: _currentDay + 5,
    );

    _informantState.currentTips.add(tip);
  }

  /// Purchase an informant tip
  bool purchaseInformantTip(String tipId) {
    final tipIndex = _informantState.currentTips.indexWhere((t) => t.id == tipId);
    if (tipIndex == -1) return false;

    final tip = _informantState.currentTips[tipIndex];
    if (tip.purchased) return false;

    // Talent tree: freeTipsPerDay grants free tips
    final isFree = _freeTipsPerDay > 0 && _freeTipsUsedToday < _freeTipsPerDay;

    if (!isFree) {
      // Check if player can afford
      if (_cash.toDouble() < tip.price) return false;
      // Deduct cost
      _cash = _cash - BigNumber(tip.price);
    } else {
      _freeTipsUsedToday++;
    }

    // Mark as purchased and revealed
    tip.purchased = true;
    tip.revealed = true;

    // Move to purchased tips
    _informantState.purchasedTips.add(tip);

    // Add informant purchase to news feed
    _addNewsItem(NewsItem(
      id: 'informant_${tip.id}',
      headline: '\u{1F575}\uFE0F ${tip.stockName}: ${tip.isBullish ? "Bullish" : "Bearish"} tip acquired',
      description: tip.message,
      category: NewsCategory.informant,
      sentiment: tip.isBullish ? NewsSentiment.positive : NewsSentiment.negative,
      timestamp: DateTime.now(),
      companyId: tip.stockId,
      impactMagnitude: 0.0,
      templateKey: 'informant_tip',
      companyName: tip.stockName,
    ));

    onInformantTipBought?.call();

    notifyListeners();
    return true;
  }

  /// Dismiss the informant (they leave)
  void dismissInformant() {
    _showInformantPopup = false;
    _informantState.isAvailable = false;
    _informantState.currentTips.clear();
    notifyListeners();
  }

  /// Resolve purchased informant tips (check if predictions were accurate)
  void _resolveInformantTips() {
    for (final tip in _informantState.purchasedTips.where((t) => t.wasAccurate == null)) {
      if (_currentDay >= tip.expiresDay) {
        final state = _stockStates[tip.stockId];
        if (state != null) {
          // Determine if tip was accurate based on actual accuracy
          final wasAccurate = _random.nextDouble() < tip.actualAccuracy;
          tip.wasAccurate = wasAccurate;
        }
      }
    }
  }

  // === DAILY CHALLENGES METHODS ===

  /// Generate new daily challenges at start of day
  void _refreshDailyChallenges() {
    // Check if we already have challenges for today
    if (_challengeState.lastRefreshDay == _currentDay) {
      return;
    }

    // Check if all challenges were completed yesterday (for streak)
    if (_challengeState.lastRefreshDay == _currentDay - 1 && _challengeState.allCompletedToday) {
      _challengeState.consecutiveDaysCompleted++;
    } else if (_challengeState.lastRefreshDay < _currentDay - 1) {
      // Missed a day, reset streak
      _challengeState.consecutiveDaysCompleted = 0;
    }

    // Generate new challenges
    _challengeState.activeChallenges = generateDailyChallenges(_currentDay, _random);
    _challengeState.lastRefreshDay = _currentDay;

    // Reset daily tracking
    _dailyTradesCount = 0;
    _dailyProfitAmount = 0.0;
    _dailyVolumeTraded = 0.0;
    _dailyDipBuys = 0;
    _dailySellHighs = 0;
    _dailyLosingTrades = 0;
  }

  /// Track a trade for challenge progress
  void _trackTradeForChallenges({
    required String companyId,
    required bool isBuy,
    required double amount,
    required double profit,
    required bool isProfitable,
    required double stockChangePercent,
  }) {
    _dailyTradesCount++;
    _dailyVolumeTraded += amount;

    if (profit > 0) {
      _dailyProfitAmount += profit;
    }

    if (!isProfitable && !isBuy) {
      _dailyLosingTrades++;
    }

    // Track dip buys (buying a stock that's down 5%+)
    if (isBuy && stockChangePercent <= -5.0) {
      _dailyDipBuys++;
      onDipBuy?.call();
    }

    // Track high sells (selling a stock that's up 10%+)
    if (!isBuy && stockChangePercent >= 10.0) {
      _dailySellHighs++;
      onSellHigh?.call();
    }

    // Update challenge progress
    _updateChallengeProgress();
  }

  /// Update progress on all active challenges
  void _updateChallengeProgress() {
    for (final challenge in _challengeState.activeChallenges) {
      if (challenge.isCompleted) continue;

      switch (challenge.type) {
        case ChallengeType.makeTrades:
          challenge.updateProgress(_dailyTradesCount);
          break;
        case ChallengeType.profitAmount:
          challenge.updateProgress(_dailyProfitAmount.round());
          break;
        case ChallengeType.volumeTrader:
          challenge.updateProgress(_dailyVolumeTraded.round());
          break;
        case ChallengeType.buyDip:
          challenge.updateProgress(_dailyDipBuys);
          break;
        case ChallengeType.sellHigh:
          challenge.updateProgress(_dailySellHighs);
          break;
        case ChallengeType.diversify:
          // Count unique sectors in positions
          final uniqueSectors = _positions.map((p) => p.company.sectorId).toSet().length;
          challenge.updateProgress(uniqueSectors);
          break;
        case ChallengeType.noLosses:
          // Only complete if we have enough trades AND no losses
          if (_dailyTradesCount >= challenge.targetValue && _dailyLosingTrades == 0) {
            challenge.updateProgress(challenge.targetValue);
          } else {
            challenge.updateProgress(0);
          }
          break;
        case ChallengeType.tradeSector:
        case ChallengeType.dayTrader:
        case ChallengeType.perfectTiming:
        case ChallengeType.contrarianPlay:
        case ChallengeType.holdAndProfit:
          // These need special tracking - simplified for now
          break;
      }
    }

    notifyListeners();
  }

  /// Claim reward for a completed challenge
  bool claimChallengeReward(String challengeId) {
    final challenge = _challengeState.activeChallenges.firstWhere(
      (c) => c.id == challengeId,
      orElse: () => throw Exception('Challenge not found'),
    );

    if (!challenge.isCompleted || challenge.rewardClaimed) {
      return false;
    }

    // Add cash reward (proportional to net worth, with floor)
    final reward = challenge.computeReward(netWorth.toDouble());
    _cash = _cash + BigNumber(reward);
    challenge.rewardClaimed = true;
    _challengeState.totalChallengesCompleted++;

    onChallengeCompleted?.call();

    // Notify
    onEventAlert?.call(
      '🏆 Challenge Complete!',
      '${challenge.title}: +\$${reward.toStringAsFixed(0)}',
      true,
    );

    notifyListeners();
    return true;
  }

  /// Claim all unclaimed challenge rewards
  int claimAllChallengeRewards() {
    int claimed = 0;
    final nw = netWorth.toDouble();
    for (final challenge in _challengeState.activeChallenges) {
      if (challenge.isCompleted && !challenge.rewardClaimed) {
        final reward = challenge.computeReward(nw);
        _cash = _cash + BigNumber(reward);
        challenge.rewardClaimed = true;
        _challengeState.totalChallengesCompleted++;
        claimed++;
      }
    }

    if (claimed > 0) {
      notifyListeners();
    }

    return claimed;
  }

  /// Notify achievement system of day end
  void _notifyDayEnd() {
    if (onDayEnd == null) return;

    // Calculate daily profit (difference from day start)
    // For simplicity, we use the daily P&L from positions
    double dailyProfit = 0;
    for (final trade in _tradeHistory) {
      if (trade.dayNumber == _currentDay && trade.realizedPnL != null) {
        dailyProfit += trade.realizedPnL!.toDouble();
      }
    }

    // Count distinct sectors in portfolio
    final sectorsInvested = _positions
        .map((p) => p.company.sectorId)
        .toSet()
        .length;

    onDayEnd!(
      dailyProfit: dailyProfit,
      portfolioValue: portfolioValue.toDouble(),
      sectorsInvested: sectorsInvested,
      tradesThisDay: _dailyTradesCount,
      cashOnHand: _cash.toDouble(),
      upgradesOwned: _acquiredUpgrades.length,
    );
  }

  void _recordTrade({
    required CompanyData company,
    required TradeType type,
    required double shares,
    required BigNumber pricePerShare,
    required BigNumber totalValue,
    required BigNumber fees,
    BigNumber? realizedPnL,
    double bonusShares = 0,
  }) {
    final trade = TradeRecord(
      id: 'trade_${_tradeIdCounter++}',
      company: company,
      type: type,
      shares: shares,
      pricePerShare: pricePerShare,
      totalValue: totalValue,
      fees: fees,
      realizedPnL: realizedPnL,
      timestamp: DateTime.now(),
      dayNumber: _currentDay,
      bonusShares: bonusShares,
    );

    _tradeHistory.insert(0, trade); // Add to front (most recent)

    // Keep only last N trades
    if (_tradeHistory.length > maxTradeHistory) {
      _tradeHistory.removeRange(maxTradeHistory, _tradeHistory.length);
    }

    // Notify achievement system of completed trade
    if (realizedPnL != null) {
      final profit = realizedPnL.toDouble();
      onTradeCompleted?.call(
        profitable: profit > 0,
        profit: profit,
      );
    }

    // Track for daily challenges
    final stockState = _stockStates[company.id];
    final stockChangePercent = stockState?.dayChangePercent ?? 0.0;
    final isBuy = type == TradeType.buy || type == TradeType.short;
    final isProfitable = realizedPnL != null && realizedPnL.toDouble() > 0;

    _trackTradeForChallenges(
      companyId: company.id,
      isBuy: isBuy,
      amount: totalValue.toDouble(),
      profit: realizedPnL?.toDouble() ?? 0.0,
      isProfitable: isProfitable,
      stockChangePercent: stockChangePercent,
    );
  }

  void _advanceYear() {
    // Notify achievement system of year end
    onYearEnd?.call();

    _currentYear++;
    _currentDay = 1;
    _prestigeLevel++;
    _vipUsedThisYear = false; // Reset VIP status for new year

    // Clear all news for the new year
    _newsItems.clear();

    // Reset active multi-day events
    _activeSpecialEvent = null;
    _activeEventDaysLeft = 0;
    _recentEventIds.clear();

    // Reset short selling ban (event-based)
    _shortSellingBanned = false;

    // Reset influencers and FinTok tips
    _influencers.clear();
    _tips.clear();
    _scheduledTips.clear();
    _usedInfluencerTemplateIds.clear();
    _followedInfluencerIds.clear();

    // Reset price alert tracking
    _lastNotifiedPriceChange.clear();
  }

  /// Player voluntarily abandons the current run
  /// Goes directly to the prestige shop (same as quota failure)
  void giveUp() {
    // Apply Golden Parachute if available
    if (_keepCashOnFailPercent > 0) {
      _startingCashBonus += _cash.toDouble() * _keepCashOnFailPercent;
    }

    _failedQuotas++;
    _lifetimeEarnings = _lifetimeEarnings + _totalRealizedPnL;
    _showPrestigeShop = true;
    _isPaused = true;
    notifyListeners();
  }

  /// Called after prestige shop is closed (purchased or skipped)
  void closePrestigeShopAndReset() {
    _showPrestigeShop = false;
    _currentYear++;
    _prestigeLevel++;

    // Notify achievement system of prestige
    onPrestige?.call();

    _resetForNewYear();

    // Generate news and show popup for the new run
    _generateDailyNewsWithPopup();
  }

  /// Get talent nodes available for purchase (parent bought, not yet purchased)
  List<TalentNode> get availableTalentNodes {
    return getAvailableTalentNodes(_purchasedTalentNodes);
  }

  /// Check if a talent node can be purchased
  bool canPurchaseTalentNode(String nodeId) {
    final node = getTalentNodeById(nodeId);
    if (node == null) return false;
    if (_purchasedTalentNodes.contains(nodeId)) return false;
    if (_prestigePoints < node.cost) return false;
    return isNodeUnlockable(nodeId, _purchasedTalentNodes);
  }

  /// Purchase a talent tree node
  bool purchaseTalentNode(String nodeId) {
    if (!canPurchaseTalentNode(nodeId)) return false;

    final node = getTalentNodeById(nodeId)!;
    _prestigePoints -= node.cost;
    _purchasedTalentNodes.add(nodeId);

    // Apply immediate effects (startingCashBonus only)
    final effects = node.effects;
    if (effects.containsKey('startingCashBonus')) {
      _startingCashBonus += effects['startingCashBonus'] as double;
    }

    notifyListeners();
    return true;
  }

  /// Apply all talent tree effects when starting a new run
  void _applyPrestigeEffectsOnReset() {
    for (final nodeId in _purchasedTalentNodes) {
      final node = getTalentNodeById(nodeId);
      if (node == null) continue;

      final effects = node.effects;
      for (final entry in effects.entries) {
        final key = entry.key;
        final value = entry.value;

        // === TRADER EFFECTS ===
        if (key == 'profitMultiplier') { _profitMultiplier += value as double; }
        else if (key == 'signalAccuracy') { _signalAccuracy += value as double; }
        else if (key == 'startingFeeReduction') { _feeReduction += value as double; }
        else if (key == 'shortTermProfitBonus') { _shortTermProfitBonus += value as double; }
        // Trader branch — position slots
        else if (key == 'extraPositionSlots') { _extraPositionSlots += value as int; }
        else if (key == 'unlimitedPositions') { _unlimitedPositions = value as bool; }
        // Trader branch — stop loss / take profit
        else if (key == 'stopLossUnlock') { _stopLossUnlock = value as bool; }
        else if (key == 'takeProfitUnlock') { _takeProfitUnlock = value as bool; }
        else if (key == 'trailingStopUnlock') { _trailingStopUnlock = value as bool; }
        else if (key == 'partialTakeProfitUnlock') { _partialTakeProfitUnlock = value as bool; }
        else if (key == 'safetyNetUnlock') { _safetyNetUnlock = value as bool; }
        // Trader branch — tempo trading
        else if (key == 'quickFlipBonus') { _quickFlipBonus += value as double; }
        else if (key == 'scalperNoFees') { _scalperNoFees = value as bool; }
        else if (key == 'holdBonus3d') { _holdBonus3d += value as double; }
        else if (key == 'holdBonus5d') { _holdBonus5d += value as double; }
        else if (key == 'holdBonus7d') { _holdBonus7d += value as double; }
        // Trader branch — limit orders (simplified)
        else if (key == 'limitOrdersUnlock') { _limitOrdersUnlock = value as bool; }
        else if (key == 'smartOrdersUnlock') { _smartOrdersUnlock = value as bool; }
        else if (key == 'fullComboOrder') { /* removed, ignored for old saves */ }
        else if (key == 'streakBonusPerWin') { _streakBonusPerWin = (value as num).toDouble(); }
        else if (key == 'streakMaxStacks') { _streakMaxStacks = value as int; }
        else if (key == 'streakKeepOnLoss') { _streakKeepOnLoss = value as bool; }
        // Legacy limit order keys (old saves)
        else if (key == 'limitBuyUnlock' || key == 'limitSellUnlock') { _limitOrdersUnlock = true; }
        else if (key == 'limitOrderSL' || key == 'limitOrderTP') { _smartOrdersUnlock = true; }
        else if (key == 'slTpFineTuning') { /* removed, ignored for old saves */ }
        // Trader branch — leverage
        else if (key == 'leverageMax') { final v = value as double; if (v > _leverageMax) _leverageMax = v; }
        else if (key == 'marginShield') { _marginShield = value as bool; }
        // Trader branch — compound interest
        else if (key == 'compoundInterestRate') { _compoundInterestRate += value as double; }

        // === SURVIVAL EFFECTS ===
        else if (key == 'extraLives') { _extraLives += value as int; }
        else if (key == 'extraQuotaDays') { _extraQuotaDays += value as int; }
        else if (key == 'survivalQuotaReduction') { _survivalQuotaReduction += value as double; }
        else if (key == 'skipQuotaBonus') { _skipQuotaBonus += value as double; }
        else if (key == 'skipStreakBonus') { _skipStreakBonus += value as double; }
        else if (key == 'lossRecoveryPercent') { _lossRecoveryPercent += value as double; }
        else if (key == 'overtimeDays') { _overtimeDays += value as int; }
        else if (key == 'secondWindBonus') { _secondWindBonus += value as double; }
        else if (key == 'resurrectQuotaReduction') { _resurrectQuotaReduction += value as double; }
        else if (key == 'ppMultiplier') { _prestigePointMultiplier += value as double; }
        else if (key == 'earlyFinishPP') { _earlyFinishPP += value as double; }
        else if (key == 'earlyFinishPP2') { _earlyFinishPP2 += value as double; }
        else if (key == 'speedrunPPMultiplier') { _speedrunPPMultiplier = value as bool; }
        else if (key == 'streakProfitBonus') { _streakProfitBonus += value as double; }
        else if (key == 'streakPersists') { _streakPersists = value as bool; }
        // Legacy defense effects (kept for old saves)
        else if (key == 'lossReduction') { _lossReduction += value as double; }
        else if (key == 'crashImpactReduction') { _crashImpactReduction += value as double; }
        else if (key == 'maxLossPerTrade') { _maxLossPerTrade = (value as double).clamp(0.0, 1.0); }
        else if (key == 'holdBonus') { _holdBonus += value as double; }
        else if (key == 'survivesWipeout') { _survivesWipeout += value as int; }
        else if (key == 'eventLossReduction') { _eventLossReduction += value as double; }
        else if (key == 'keepCapitalOnWipe') { _keepCapitalOnWipe += value as double; }
        else if (key == 'diversificationBonus') { _diversificationBonus += value as double; }

        // === AUTOMATION EFFECTS ===
        else if (key == 'robotSlots') { _maxRobotSlots += value as int; }
        else if (key == 'robotWinRateBonus') { _robotWinRateBonus += value as double; }
        else if (key == 'robotSpeedBonus') { _robotSpeedBonus += value as double; }
        else if (key == 'robotUpgradeCostReduction') { _robotUpgradeCostReduction += value as double; }
        else if (key == 'robotStartLevel') { final v = value as int; if (v > _robotStartLevel) _robotStartLevel = v; }
        else if (key == 'robotAutoCollect') { final v = value as int; if (v > _robotAutoCollect) _robotAutoCollect = v; }
        else if (key == 'robotSeedMoney') { _robotSeedMoney += value as double; }

        // === INTELLIGENCE EFFECTS ===
        else if (key == 'tipCostReduction') { _tipCostReduction += value as double; }
        else if (key == 'newsCategoryPreview') { _newsCategoryPreview = value as bool; }
        else if (key == 'tipExactPercent') { _tipExactPercent = value as bool; }
        else if (key == 'freeTipsPerDay') { _freeTipsPerDay += value as int; }
        else if (key == 'flagBadTips') { _flagBadTips = value as bool; }
        else if (key == 'tipPrecisionMultiplier') { _tipPrecisionMultiplier += value as double; }
        else if (key == 'priceForesight') { _priceForesight = value as bool; }
        else if (key == 'blockBadEvents') { _blockBadEvents += value as int; }
        else if (key == 'disinfoShield') { _disinfoShield = value as bool; }
        else if (key == 'extraActiveInfluencers') { _extraActiveInfluencers += value as int; }
        else if (key == 'extraNewsPerDay') { _extraNewsPerDay += value as int; }
        else if (key == 'fintokAccuracyBonus') { _fintokAccuracyBonus += value as double; }

        // === UPGRADE/SHOP EFFECTS (from intelligence spine) ===
        else if (key == 'extraFreeRerolls') { _freeRollsPerDay += value as int; }
        else if (key == 'shopRarityBoost') { _shopRarityBoost += value as double; }
        else if (key == 'extraUpgradeChoices') { _extraUpgradeChoices += value as int; }
        else if (key == 'startingUpgrades') { _startingUpgrades += value as int; }
        else if (key == 'guaranteedRareFirst') { _guaranteedRareFirst = value as bool; }

        // === SECTOR DYNAMIC EFFECTS (prefix-based) ===
        else if (key.startsWith('unlockSectorTier_')) {
          final sectorId = key.replaceFirst('unlockSectorTier_', '');
          final tier = value as int;
          final current = _sectorTierUnlocks[sectorId] ?? 0;
          if (tier > current) _sectorTierUnlocks[sectorId] = tier;
          // Unlock companies of that tier
          CompanyTier? companyTier;
          if (tier == 1) companyTier = CompanyTier.standard;
          if (tier == 2) companyTier = CompanyTier.premium;
          if (tier == 3) companyTier = CompanyTier.elite;
          if (companyTier != null) {
            for (final company in getCompaniesBySector(sectorId).where((c) => c.tier == companyTier)) {
              _unlockedCompanyIds.add(company.id);
            }
          }
        }
        else if (key.startsWith('sectorProfitBonus_')) {
          final sectorId = key.replaceFirst('sectorProfitBonus_', '');
          _sectorProfitBonuses[sectorId] = (_sectorProfitBonuses[sectorId] ?? 0) + (value as double);
        }
        else if (key.startsWith('sectorLossShield_')) {
          final sectorId = key.replaceFirst('sectorLossShield_', '');
          _sectorLossShields[sectorId] = (_sectorLossShields[sectorId] ?? 0) + (value as double);
        }
        else if (key.startsWith('sectorPassiveIncome_')) {
          final sectorId = key.replaceFirst('sectorPassiveIncome_', '');
          _sectorPassiveIncomes[sectorId] = (_sectorPassiveIncomes[sectorId] ?? 0) + (value as double);
        }
        else if (key.startsWith('sectorCapstone_')) {
          final sectorId = key.replaceFirst('sectorCapstone_', '');
          _sectorCapstones.add(sectorId);
        }
      }
    }

    // Capstone doubling: double all bonuses for sectors with capstone
    for (final sectorId in _sectorCapstones) {
      if (_sectorProfitBonuses.containsKey(sectorId)) {
        _sectorProfitBonuses[sectorId] = _sectorProfitBonuses[sectorId]! * 2;
      }
      if (_sectorLossShields.containsKey(sectorId)) {
        _sectorLossShields[sectorId] = _sectorLossShields[sectorId]! * 2;
      }
      if (_sectorPassiveIncomes.containsKey(sectorId)) {
        _sectorPassiveIncomes[sectorId] = _sectorPassiveIncomes[sectorId]! * 2;
      }
    }

    // Trim excess robots (if prestige changed and slots reduced)
    while (_robots.length > _maxRobotSlots) {
      _robots.removeLast();
    }
    // Create robots if needed
    while (_robots.length < _maxRobotSlots) {
      _robots.add(RobotTrader.create('robot_${_robotIdCounter++}', _robots.length));
    }

    // Clamp additive values to sane limits
    _feeReduction = _feeReduction.clamp(0.0, 0.95);
    _lossReduction = _lossReduction.clamp(0.0, 0.50);
    _crashImpactReduction = _crashImpactReduction.clamp(0.0, 0.90);
    _robotUpgradeCostReduction = _robotUpgradeCostReduction.clamp(0.0, 0.30);
    _lossRecoveryPercent = _lossRecoveryPercent.clamp(0.0, 0.15);

    // Survival: init lives for this run
    _livesRemaining = _extraLives;
    // Survival: apply extra quota days from talent tree
    _daysPerQuota += _extraQuotaDays;

    // Wire talent tree SL/TP unlocks to the actual system
    // When unlocked, auto-enable with default percentages
    if (_stopLossUnlock) { _hasStopLoss = true; _stopLossEnabled = true; }
    if (_takeProfitUnlock) { _hasTakeProfit = true; _takeProfitEnabled = true; }

    // Grant lucky starting shares from meta progression
    _grantLuckyStartingShares();

    // Grant starting daily upgrades (market veteran)
    _grantStartingUpgrades();

    // Seed peak net worth so robot upgrade costs aren't $0 at start
    _updatePeakNetWorth();
  }

  /// Apply meta progression bonuses (called from outside, e.g., from main.dart or home_screen)
  /// These bonuses are permanent across all runs and come from achievements
  void applyMetaProgression(MetaProgression meta) {
    _metaStockBonusRate = meta.stockBonusRate;
    _metaCommissionReduction = meta.commissionReduction;
    _metaQuotaReduction = meta.quotaReduction;
    _metaStartingCashBonus = meta.startingCashBonus;
    _metaInformantBonus = meta.informantVisitBonus;
    _metaFintokAccuracyBonus = meta.fintokAccuracyBonus;
    _metaLuckyStartingShares = meta.luckyStartingShares;
    _metaVipStatus = meta.hasVipStatus;
    _metaUpgradeLuck = meta.upgradeLuck;
    _metaInsurance = meta.insurance;
    _metaInterestRate = meta.interestRate;
    _metaExtraRerolls = meta.extraRerolls;
    notifyListeners();
  }

  /// Add prestige points from achievement rewards
  void addPrestigePoints(int points) {
    _prestigePoints += points;
    _totalPrestigePoints += points;
    notifyListeners();
  }

  /// Grant starting daily upgrades from prestige (Market Veteran)
  /// Shows an upgrade selection popup instead of auto-applying
  void _grantStartingUpgrades() {
    if (_startingUpgrades <= 0) return;

    // Generate upgrade choices for the player to pick from (free)
    _generateUpgradeChoices();
    if (_upgradeChoices.isNotEmpty) {
      _isStartingUpgradeSelection = true;
      _showUpgradeSelection = true;
      _isPaused = true;
    }
  }

  /// Grant lucky starting shares from meta progression
  void _grantLuckyStartingShares() {
    if (_metaLuckyStartingShares <= 0) return;

    final unlockedCompanies = _unlockedCompanyIds.toList();
    if (unlockedCompanies.isEmpty) return;

    // Distribute shares among random unlocked companies
    var remainingShares = _metaLuckyStartingShares;
    while (remainingShares > 0) {
      final companyId = unlockedCompanies[_random.nextInt(unlockedCompanies.length)];
      final company = getCompanyById(companyId);
      if (company == null) continue;

      // Grant 1-3 shares per company
      final sharesToGrant = (remainingShares >= 3) ? (1 + _random.nextInt(3)) : remainingShares;
      remainingShares -= sharesToGrant;

      // Get or create position
      Position? position = _positions.where((p) => p.company.id == companyId).firstOrNull;
      if (position == null) {
        position = Position(company: company);
        _positions.add(position);
      }

      // Add shares at current price (free!)
      final state = _stockStates[companyId];
      if (state != null) {
        position.buy(sharesToGrant.toDouble(), state.currentPrice, BigNumber.zero);
      }
    }
  }

  // === TOKEN SYSTEM ===

  /// Add a new token to the player's inventory
  void addToken(TokenType type) {
    _tokens.add(Token(
      id: 'token_${_tokenIdCounter++}',
      type: type,
    ));
    notifyListeners();
  }

  /// Place a token on a company
  bool placeToken(String tokenId, String companyId) {
    final token = _tokens.where((t) => t.id == tokenId).firstOrNull;
    if (token == null) return false;

    // Check if company is unlocked
    if (!isCompanyUnlocked(companyId)) return false;

    // Place the token
    token.placedOnCompanyId = companyId;

    onTokenPlaced?.call();

    notifyListeners();
    return true;
  }

  /// Remove a token from a company (back to inventory)
  bool removeToken(String tokenId) {
    final token = _tokens.where((t) => t.id == tokenId).firstOrNull;
    if (token == null) return false;

    token.placedOnCompanyId = null;
    notifyListeners();
    return true;
  }

  /// Process token effects at end of day
  void _processTokenEffects() {
    for (final token in _tokens) {
      if (!token.isPlaced) continue;

      final state = _stockStates[token.placedOnCompanyId];
      if (state == null) continue;

      switch (token.type) {
        case TokenType.dividend:
          // Dividend token: Earn income based on stock's daily gain
          // If stock went up, earn 5% of that gain
          final dayChange = state.dayChangePercent;
          if (dayChange > 0) {
            final dividendIncome = state.currentPrice.toDouble() * (dayChange / 100) * 0.05;
            _cash = _cash + BigNumber(dividendIncome);
          }
          break;

        case TokenType.robot:
          // Robot token: Automatically buy low / sell high
          _processRobotToken(token, state);
          break;
      }
    }
  }

  /// Process robot token trading logic
  void _processRobotToken(Token token, StockState state) {
    final companyId = token.placedOnCompanyId;
    if (companyId == null) return;

    final company = getCompanyById(companyId);
    if (company == null) return;

    final dayChange = state.dayChangePercent;

    // Check if we have a position in this stock
    final position = _positions.where((p) => p.company.id == companyId).firstOrNull;

    if (position == null) {
      // No position: Buy if price dropped significantly (>3%)
      if (dayChange < -3.0) {
        // Buy small amount (5% of cash, max $100)
        final buyAmount = (_cash.toDouble() * 0.05).clamp(0, 100);
        if (buyAmount > 10) {
          final shares = buyAmount / state.currentPrice.toDouble();
          if (shares > 0.01) {
            buy(company, shares);
          }
        }
      }
    } else {
      // Have position: Sell if price rose significantly (>5%)
      if (dayChange > 5.0) {
        // Sell 50% of position
        final sharesToSell = position.shares * 0.5;
        if (sharesToSell > 0.01) {
          sell(company, sharesToSell);
        }
      }
    }
  }

  // === ROBOT TRADER LOGIC ===

  void _processRobotTrades() {
    final companies = unlockedCompanies;
    if (companies.isEmpty) return;

    for (final robot in _robots) {
      if (!robot.isActive) continue;

      final baseTrades = robot.tradesPerDay;
      final trades = _robotSpeedBonus > 0
          ? (baseTrades * (1.0 + _robotSpeedBonus)).round().clamp(baseTrades, baseTrades * 3)
          : baseTrades;
      robot.tradesCompletedToday = 0;

      for (int i = 0; i < trades; i++) {
        if (robot.budget <= BigNumber.zero) break;

        // Pick a random unlocked company each trade
        final company = companies[_random.nextInt(companies.length)];

        final tierGainMult = switch (company.tier) {
          CompanyTier.starter => 0.5,
          CompanyTier.standard => 1.0,
          CompanyTier.premium => 2.0,
          CompanyTier.elite => 3.5,
        };
        final tierLossMult = switch (company.tier) {
          CompanyTier.starter => 0.3,
          CompanyTier.standard => 1.0,
          CompanyTier.premium => 1.8,
          CompanyTier.elite => 3.0,
        };

        final roll = _random.nextDouble();
        if (roll < (robot.precisionPercent + _robotWinRateBonus).clamp(0.0, 0.95)) {
          // Successful trade
          final variance = 0.5 + _random.nextDouble();
          final gain = robot.budget.multiplyByDouble(
            robot.efficiencyPercent * tierGainMult * variance,
          );
          robot.wallet = robot.wallet + gain;
          robot.addTrade(RobotTrade(
            companyName: company.name,
            companyTicker: company.ticker,
            amount: gain,
            isWin: true,
            day: _currentDay,
          ));
        } else {
          // Failed trade
          final variance = 0.5 + _random.nextDouble();
          final loss = robot.budget.multiplyByDouble(
            0.015 * tierLossMult * (1.0 - robot.lossReductionPercent) * variance,
          );
          robot.budget = robot.budget - loss;
          robot.addTrade(RobotTrade(
            companyName: company.name,
            companyTicker: company.ticker,
            amount: loss,
            isWin: false,
            day: _currentDay,
          ));

          if (robot.budget <= BigNumber.zero) {
            robot.budget = BigNumber.zero;
          }
        }
        robot.tradesCompletedToday++;
      }
    }
  }

  void fundRobot(String robotId, BigNumber amount) {
    if (amount <= BigNumber.zero || amount > _cash) return;

    final robot = _robots.firstWhere((r) => r.id == robotId);
    final maxBudget = robotMaxBudgetFor(robot);
    final headroom = maxBudget - robot.budget;
    if (headroom <= BigNumber.zero) return;

    final actual = amount > headroom ? headroom : amount;
    robot.budget = robot.budget + actual;
    _cash = _cash - actual;
    notifyListeners();
  }

  /// Updates peak net worth (call on market updates)
  void _updatePeakNetWorth() {
    final current = netWorth;
    if (current > _peakNetWorth) {
      _peakNetWorth = current;
    }
  }

  /// Max budget for a specific robot, based on its capacity level.
  BigNumber robotMaxBudgetFor(RobotTrader robot) {
    final base = robot.capacityMultiplier;
    return BigNumber(base);
  }

  /// Global max (for display when no specific robot is specified)
  BigNumber robotMaxBudget() {
    if (_robots.isEmpty) return BigNumber(100);
    return robotMaxBudgetFor(_robots.first);
  }

  void withdrawRobotBudget(String robotId) {
    final robot = _robots.firstWhere((r) => r.id == robotId);
    if (robot.budget <= BigNumber.zero) return;

    _cash = _cash + robot.budget;
    robot.budget = BigNumber.zero;
    notifyListeners();
  }

  void collectRobotWallet(String robotId) {
    final robot = _robots.firstWhere((r) => r.id == robotId);
    if (robot.wallet <= BigNumber.zero) return;

    _cash = _cash + robot.wallet;
    robot.wallet = BigNumber.zero;
    notifyListeners();
  }

  /// Robot upgrade cost scales exponentially by level AND by robot index.
  /// Stats (capped at lv9): 2% of peak net worth * 1.5^level * robotMult
  /// Capacity (infinite): flat $50 * 2^level * robotMult
  /// Robot multiplier: 1st=1x, 2nd=2.5x, 3rd=6x, 4th=15x, 5th=35x
  BigNumber _robotUpgradeCost(RobotTrader robot, String stat, int currentLevel) {
    final robotIndex = _robots.indexOf(robot);
    const robotMultipliers = [1.0, 2.5, 6.0, 15.0, 35.0];
    final robotMult = robotIndex < robotMultipliers.length
        ? robotMultipliers[robotIndex]
        : robotMultipliers.last * (robotIndex - robotMultipliers.length + 2);

    // Global robot upgrade cost reduction from talent tree
    final discount = 1.0 - _robotUpgradeCostReduction;

    if (stat == 'capacity') {
      // Capacity: flat dollar cost, doubles each level
      // Lv0→1: $50, Lv1→2: $100, Lv5→6: $1600, Lv10→11: $51K
      final cost = 50.0 * _pow(2.0, currentLevel) * robotMult * discount;
      return BigNumber(cost);
    }

    // Other stats: % of peak net worth, capped at lv9
    if (currentLevel >= 9) return BigNumber.zero;
    final basePct = 0.02 * _pow(1.5, currentLevel);
    return _peakNetWorth.multiplyByDouble(basePct * robotMult * discount);
  }

  static double _pow(double base, int exp) {
    double result = 1.0;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  void upgradeRobotStat(String robotId, String stat) {
    final robot = _robots.firstWhere((r) => r.id == robotId);

    int currentLevel = switch (stat) {
      'precision' => robot.precisionLevel,
      'efficiency' => robot.efficiencyLevel,
      'frequency' => robot.frequencyLevel,
      'riskMgmt' => robot.riskMgmtLevel,
      'capacity' => robot.safeCapacityLevel,
      _ => -1,
    };

    if (currentLevel < 0) return;
    // Cap at 9 for non-capacity stats
    if (stat != 'capacity' && currentLevel >= 9) return;

    final cost = _robotUpgradeCost(robot, stat, currentLevel);
    if (cost > _cash) return;

    _cash = _cash - cost;
    _totalRobotExpenses = _totalRobotExpenses + cost;
    _quotaProgress = _quotaProgress - cost;

    switch (stat) {
      case 'precision':
        robot.precisionLevel++;
      case 'efficiency':
        robot.efficiencyLevel++;
      case 'frequency':
        robot.frequencyLevel++;
      case 'riskMgmt':
        robot.riskMgmtLevel++;
      case 'capacity':
        robot.capacityLevel = robot.safeCapacityLevel + 1;
      default:
        _cash = _cash + cost;
        _totalRobotExpenses = _totalRobotExpenses - cost;
        _quotaProgress = _quotaProgress + cost;
        return;
    }

    notifyListeners();
  }

  BigNumber getRobotUpgradeCost(String robotId, String stat) {
    final robot = _robots.firstWhere((r) => r.id == robotId);
    final currentLevel = getRobotStatLevel(robotId, stat);
    if (stat != 'capacity' && currentLevel >= 9) return BigNumber.zero;
    return _robotUpgradeCost(robot, stat, currentLevel);
  }

  int getRobotStatLevel(String robotId, String stat) {
    final robot = _robots.firstWhere((r) => r.id == robotId);
    return switch (stat) {
      'precision' => robot.precisionLevel,
      'efficiency' => robot.efficiencyLevel,
      'frequency' => robot.frequencyLevel,
      'riskMgmt' => robot.riskMgmtLevel,
      'capacity' => robot.safeCapacityLevel,
      _ => 0,
    };
  }

  bool isRobotStatMaxed(String stat, int level) {
    if (stat == 'capacity') return false; // Infinite
    return level >= 9;
  }

  // === MARKET SIMULATION ===
  void _simulateMarket() {
    // Update sector trends (slower, more gradual changes)
    for (final sector in allSectors) {
      double trend = _sectorTrends[sector.id] ?? 0;
      // Reduced noise for smoother sector movement
      double noise = _randomGaussian() * 0.015; // Reduced from 0.05
      // Stronger mean reversion to prevent extreme sector moves
      double reversion = -trend * 0.15; // Increased from 0.1
      double sentiment = _marketSentiment * sector.marketCorrelation * 0.01; // Reduced from 0.02

      trend = (trend + noise + reversion + sentiment).clamp(-0.5, 0.5); // Tighter clamp
      _sectorTrends[sector.id] = trend;
    }

    // Day progress (0 = market open, 1 = market close)
    final dayProgress = (effectiveDayDuration - _dayTimer) / effectiveDayDuration;

    // Fire any scheduled influencer tips whose time has come
    while (_scheduledTips.isNotEmpty && dayProgress >= _scheduledTips.first.targetProgress) {
      final scheduled = _scheduledTips.removeAt(0);
      final influencer = _influencers.where((i) => i.id == scheduled.influencerId && i.isActive).firstOrNull;
      if (influencer != null) {
        _generateInfluencerTip(influencer);
      }
    }

    // Update each stock
    for (final state in _stockStates.values) {
      _updateStockPrice(state, dayProgress);
    }

    // Update market indicators
    _updateMarketIndicators();
  }

  void _updateMarketIndicators() {
    if (_stockStates.isEmpty) return;

    int advancing = 0;
    int declining = 0;
    int unchanged = 0;
    int newHighs = 0;
    int newLows = 0;
    double totalVolatility = 0.0;

    // Analyze each stock
    for (final state in _stockStates.values) {
      final change = state.dayChangePercent;

      // Count advancing/declining
      if (change > 0.1) {
        advancing++;
      } else if (change < -0.1) {
        declining++;
      } else {
        unchanged++;
      }

      // Check for new highs/lows (within 2% of 52-week range)
      final distanceFromHigh = state.distanceFrom52WeekHigh;
      final distanceFromLow = state.distanceFrom52WeekLow;

      if (distanceFromHigh >= -2.0) {
        newHighs++;
      }
      if (distanceFromLow <= 2.0) {
        newLows++;
      }

      totalVolatility += state.currentVolatility;
    }

    final totalStocks = _stockStates.length;
    final avgVolatility = totalStocks > 0 ? totalVolatility / totalStocks : 0.0;

    // Calculate market breadth (-1 to 1)
    final marketBreadth = totalStocks > 0
        ? (advancing - declining) / totalStocks
        : 0.0;

    // Calculate Fear & Greed Index (0-100)
    // Based on: market breadth, volatility, new highs vs lows, market sentiment
    double fearGreed = 50.0; // Start neutral

    // Market breadth component (±20)
    fearGreed += marketBreadth * 20;

    // Volatility component (±15, inverse - high vol = fear)
    final volScore = (1.0 - (avgVolatility.clamp(0, 2) / 2)) * 15;
    fearGreed += volScore;

    // New highs vs lows component (±10)
    final totalExtremes = newHighs + newLows;
    if (totalExtremes > 0) {
      final highLowRatio = (newHighs - newLows) / totalExtremes;
      fearGreed += highLowRatio * 10;
    }

    // Market sentiment component (±5)
    fearGreed += _marketSentiment * 5;

    fearGreed = fearGreed.clamp(0, 100);

    // Calculate sector rotation
    final sectorRotation = <String, double>{};
    for (final sector in allSectors) {
      final performance = getSectorPerformance(sector.id);
      sectorRotation[sector.name] = performance;
    }

    // Volatility index (VIX-like, 0-100 scale)
    final volatilityIndex = (avgVolatility * 30).clamp(0.0, 100.0);

    _marketIndicators = MarketIndicators(
      fearGreedIndex: fearGreed,
      marketBreadth: marketBreadth,
      advancingStocks: advancing,
      decliningStocks: declining,
      unchangedStocks: unchanged,
      newHighs: newHighs,
      newLows: newLows,
      volatilityIndex: volatilityIndex,
      sectorRotation: sectorRotation,
      timestamp: DateTime.now(),
    );
  }

  void _updateStockPrice(StockState state, double dayProgress) {
    final company = state.company;
    final sector = getSectorById(company.sectorId);
    final sectorTrend = _sectorTrends[company.sectorId] ?? 0;
    final currentPrice = state.currentPrice.toDouble();

    // ============================================
    // 1. TIME-OF-DAY VOLATILITY PATTERN
    // ============================================
    // U-shaped: high at open and close, low at midday
    // Smooth ramp-up at open to prevent overnight gap jumps
    final distFromMid = (dayProgress - 0.5).abs(); // 0.5 at edges, 0 at midday
    double timeOfDayMultiplier = 0.6 + distFromMid * 0.8; // Range: 0.6 (midday) to 1.0 (open/close)
    // Gentle ramp-up in first 5% of day (opening auction period)
    if (dayProgress < 0.05) {
      timeOfDayMultiplier *= 0.3 + (dayProgress / 0.05) * 0.7; // 30%→100% over first 5%
    }

    // ============================================
    // 2. BASE VOLATILITY
    // ============================================
    double baseVolatility = 0.003 * company.volatility;
    if (sector != null) baseVolatility *= sector.volatilityMultiplier;
    baseVolatility *= timeOfDayMultiplier;
    baseVolatility *= _marketRegime.volatilityMultiplier;

    // ============================================
    // 3. SUPPORT / RESISTANCE INTERACTION
    // ============================================
    final support = state.supportLevel;
    final resistance = state.resistanceLevel;
    final srRange = resistance - support;
    final distToSupport = currentPrice - support;
    final distToResistance = resistance - currentPrice;

    // How close to S/R levels (0 = at level, 1 = at midpoint)
    final proximityToSupport = srRange > 0 ? (distToSupport / srRange).clamp(0.0, 1.0) : 0.5;
    final proximityToResistance = srRange > 0 ? (distToResistance / srRange).clamp(0.0, 1.0) : 0.5;

    // S/R dampening: reduce volatility near S/R (price "sticks")
    double srDampening = 1.0;
    double srBias = 0.0; // Directional bias from S/R

    if (proximityToSupport < 0.15) {
      // Near support: reduce downward movement, add upward bias (bounce)
      srDampening = 0.4 + proximityToSupport * 4.0; // 0.4 at support, 1.0 at 15%
      srBias = 0.3 * (1.0 - proximityToSupport / 0.15); // Push up
    } else if (proximityToResistance < 0.15) {
      // Near resistance: reduce upward movement, add downward bias (rejection)
      srDampening = 0.4 + proximityToResistance * 4.0;
      srBias = -0.3 * (1.0 - proximityToResistance / 0.15); // Push down
    }

    // S/R BREAKOUT: prolonged time near S/R increases breakout probability
    double breakoutChance = 0.05; // Base 5%
    bool isBreakoutFromSR = false;
    double breakoutDirection = 0.0;

    if (state.ticksNearSupport > 5) {
      // Tested support many times - either bounce hard or break down
      breakoutChance = min(0.25, 0.05 + state.ticksNearSupport * 0.03);
    }
    if (state.ticksNearResistance > 5) {
      breakoutChance = min(0.25, 0.05 + state.ticksNearResistance * 0.03);
    }

    if (_random.nextDouble() < breakoutChance) {
      isBreakoutFromSR = true;
      if (state.ticksNearResistance > state.ticksNearSupport) {
        breakoutDirection = 1.0; // Break above resistance
      } else if (state.ticksNearSupport > state.ticksNearResistance) {
        breakoutDirection = -1.0; // Break below support
      } else {
        breakoutDirection = _random.nextBool() ? 1.0 : -1.0;
      }
    }

    // ============================================
    // 4. MOMENTUM (autocorrelation)
    // ============================================
    // If recent ticks were mostly bullish, next tick has higher chance of being bullish
    final momentumBias = state.momentum * 0.4; // ±0.4 max directional bias

    // ============================================
    // 5. COMPUTE PRICE CHANGE
    // ============================================
    double volatility;
    double trendChange;

    if (isBreakoutFromSR) {
      // S/R Breakout: strong directional move, high volatility
      volatility = baseVolatility * 3.5;
      trendChange = breakoutDirection * volatility * 2.0;
      // Override S/R dampening during breakout
      srDampening = 1.5;
      srBias = 0.0;
    } else {
      // Normal tick
      volatility = baseVolatility * srDampening;

      // Trend component
      final regimeBias = _marketRegime.regimeStrength * 0.15;
      trendChange = (sectorTrend * company.sectorCorrelation * 0.4 +
              _marketSentiment * 0.2 +
              state.trendDirection * 0.15 +
              regimeBias +
              momentumBias +
              srBias) *
          volatility;

      // Apply regime influence
      trendChange *= (1.0 + (_marketRegime.priceInfluence - 1.0) * 0.5);
    }

    // Random component (Gaussian)
    double randomChange = _randomGaussian() * volatility;

    // MEAN REVERSION toward day open (soft, prevents extreme drift)
    final dayOpenPrice = state.dayOpen.toDouble();
    if (dayOpenPrice > 0) {
      final deviation = (currentPrice - dayOpenPrice) / dayOpenPrice;
      if (deviation.abs() > 0.06) {
        final reversionStrength = (deviation.abs() - 0.06) * 0.015;
        trendChange -= deviation.sign * reversionStrength;
      }
    }

    // ROUND NUMBER MAGNETISM
    // Prices gravitate slightly toward round numbers
    final roundLevel = _nearestRoundNumber(currentPrice);
    if (roundLevel > 0) {
      final distToRound = (roundLevel - currentPrice) / currentPrice;
      if (distToRound.abs() < 0.01) {
        // Within 1% of round number: gentle pull
        trendChange += distToRound * 0.05;
      }
    }

    // Total organic change (clamped, tighter at open to prevent gap)
    final maxChange = dayProgress < 0.05 ? 0.01 : 0.03;
    double totalChange = (randomChange + trendChange).clamp(-maxChange, maxChange);

    // ============================================
    // 6. NEWS IMPACT (preserved, applied on top)
    // ============================================
    // News impact bypasses S/R dampening - strong news breaks through levels
    if (state.hasPendingImpact) {
      final newsImpact = state.applyPendingImpact(applicationRate: 0.15);
      totalChange += newsImpact;
    }

    // ============================================
    // 7. APPLY PRICE CHANGE
    // ============================================
    BigNumber newPrice = state.currentPrice.applyPercent(totalChange * 100);

    if (newPrice.toDouble() < 0.01) {
      newPrice = BigNumber(0.01);
    }

    // Simulate market volume (random fraction of average volume per tick)
    final simulatedVolume = state.averageVolume.multiplyByDouble(
      (0.005 + _random.nextDouble() * 0.015) * (1.0 + totalChange.abs() * 20),
    );
    state.addVolume(simulatedVolume);

    state.updatePrice(newPrice);

    // Record change for momentum tracking
    state.recordPriceChange(totalChange);

    // Update dynamic S/R levels
    state.updateSupportResistance();

    // Check for price alert
    _checkPriceAlert(company, state);

    // Update trend direction (slower momentum building)
    double priceChange = state.dayChangePercent;
    state.trendDirection = state.trendDirection * 0.95 +
        (priceChange.sign * min(priceChange.abs() / 8, 0.5)) * 0.05;
  }

  /// Find nearest psychologically significant round number
  double _nearestRoundNumber(double price) {
    if (price >= 500) {
      return (price / 100).round() * 100.0;
    } else if (price >= 50) {
      return (price / 50).round() * 50.0;
    } else if (price >= 10) {
      return (price / 10).round() * 10.0;
    } else if (price >= 1) {
      return (price / 1).round() * 1.0;
    }
    return (price / 0.1).round() * 0.1;
  }

  /// Check if a price alert should be triggered for a stock
  void _checkPriceAlert(CompanyData company, StockState state) {
    if (onPriceAlert == null) return;

    // Don't alert for companies the player hasn't unlocked yet
    if (!isCompanyUnlocked(company.id)) return;

    final priceChange = state.dayChangePercent;

    // Only alert if change exceeds threshold
    if (priceChange.abs() < _priceAlertThreshold) return;

    // Check cooldown - only alert if significant change since last notification
    final lastNotified = _lastNotifiedPriceChange[company.id] ?? 0.0;
    final changeSinceLastAlert = (priceChange - lastNotified).abs();

    if (changeSinceLastAlert < _priceAlertCooldown) return;

    // Trigger alert
    _lastNotifiedPriceChange[company.id] = priceChange;
    onPriceAlert!(company.name, company.id, priceChange);
  }

  PortfolioBreakdown _calculatePortfolioBreakdown() {
    final totalValue = portfolioValue;
    if (totalValue.isZero) {
      return PortfolioBreakdown(
        sectorAllocation: {},
        sectorValues: {},
        longPercentage: 0,
        shortPercentage: 0,
        longValue: BigNumber.zero,
        shortValue: BigNumber.zero,
        totalPositions: 0,
        distinctSectors: 0,
        concentrationRisk: 0,
        largestPositionValue: BigNumber.zero,
        portfolioVolatility: 0,
        avgPositionSize: 0,
      );
    }

    // Calculate sector allocation
    final sectorValues = <String, BigNumber>{};
    final sectorAllocation = <String, double>{};
    final positionVolatilities = <double>[];
    final positionWeights = <double>[];

    BigNumber largestValue = BigNumber.zero;
    String? largestTicker;

    for (final position in _positions) {
      final state = _stockStates[position.company.id];
      if (state == null) continue;

      final positionValue = position.currentValue(state.currentPrice);
      final sector = getSectorById(position.company.sectorId);
      final sectorName = sector?.name ?? 'Unknown';

      // Accumulate sector values
      sectorValues[sectorName] = (sectorValues[sectorName] ?? BigNumber.zero) + positionValue;

      // Track largest position
      if (positionValue > largestValue) {
        largestValue = positionValue;
        largestTicker = position.company.ticker;
      }

      // Collect volatility and weight for portfolio calculations
      final weight = positionValue.toDouble() / totalValue.toDouble();
      positionWeights.add(weight);
      positionVolatilities.add(state.currentVolatility);
    }

    // Calculate sector percentages
    sectorValues.forEach((sector, value) {
      sectorAllocation[sector] = (value.toDouble() / totalValue.toDouble()) * 100;
    });

    // Calculate concentration risk (Herfindahl index)
    double concentrationRisk = 0.0;
    for (final weight in positionWeights) {
      concentrationRisk += weight * weight;
    }

    // Calculate weighted average volatility
    double portfolioVolatility = 0.0;
    for (int i = 0; i < positionWeights.length; i++) {
      portfolioVolatility += positionWeights[i] * positionVolatilities[i];
    }

    // Long/Short breakdown
    final longVal = longPortfolioValue;
    final shortVal = shortPortfolioValue;
    final longPct = totalValue.isZero ? 0.0 : (longVal.toDouble() / totalValue.toDouble()) * 100;
    final shortPct = totalValue.isZero ? 0.0 : (shortVal.toDouble() / totalValue.toDouble()) * 100;

    return PortfolioBreakdown(
      sectorAllocation: sectorAllocation,
      sectorValues: sectorValues,
      longPercentage: longPct,
      shortPercentage: shortPct,
      longValue: longVal,
      shortValue: shortVal,
      totalPositions: _positions.length,
      distinctSectors: sectorValues.length,
      concentrationRisk: concentrationRisk,
      largestPositionValue: largestValue,
      largestPositionTicker: largestTicker,
      portfolioVolatility: portfolioVolatility,
      avgPositionSize: _positions.isEmpty ? 0.0 : 100.0 / _positions.length,
    );
  }

  void _updateMarketRegime() {
    // Calculate regime strength based on market indicators
    double strength = 0.0;

    // Factor 1: Market breadth (±0.3)
    if (_marketIndicators != null) {
      strength += _marketIndicators!.marketBreadth * 0.3;

      // Factor 2: Fear & Greed Index (±0.25)
      final fearGreed = (_marketIndicators!.fearGreedIndex - 50) / 50; // Normalize to -1 to 1
      strength += fearGreed * 0.25;

      // Factor 3: New highs vs lows (±0.2)
      final totalExtremes = _marketIndicators!.newHighs + _marketIndicators!.newLows;
      if (totalExtremes > 0) {
        final highLowRatio = (_marketIndicators!.newHighs - _marketIndicators!.newLows) / totalExtremes;
        strength += highLowRatio * 0.2;
      }

      // Factor 4: Volatility (inverse, ±0.15)
      final volScore = 1.0 - (_marketIndicators!.volatilityIndex / 100);
      strength += (volScore - 0.5) * 0.15;
    }

    // Factor 5: Market sentiment (±0.1)
    strength += _marketSentiment * 0.1;

    // Add some momentum - regimes tend to persist
    strength = (strength * 0.7) + (_marketRegime.regimeStrength * 0.3);

    // Clamp to -1 to 1
    strength = strength.clamp(-1.0, 1.0);

    // Determine regime based on strength
    MarketRegime newRegime;
    if (strength >= 0.6) {
      newRegime = MarketRegime.strongBull;
    } else if (strength >= 0.2) {
      newRegime = MarketRegime.bull;
    } else if (strength > -0.2) {
      newRegime = MarketRegime.neutral;
    } else if (strength > -0.6) {
      newRegime = MarketRegime.bear;
    } else {
      newRegime = MarketRegime.strongBear;
    }

    // Update regime
    final previousRegime = _marketRegime.currentRegime;
    final daysInRegime = newRegime == previousRegime
        ? _marketRegime.daysInCurrentRegime + 1
        : 1;

    _marketRegime = MarketRegimeData(
      currentRegime: newRegime,
      regimeStrength: strength,
      daysInCurrentRegime: daysInRegime,
      lastRegimeChange: newRegime != previousRegime ? DateTime.now() : _marketRegime.lastRegimeChange,
      previousRegime: newRegime != previousRegime ? previousRegime : _marketRegime.previousRegime,
    );
  }

  double _randomGaussian() {
    double u1 = 1 - _random.nextDouble();
    double u2 = 1 - _random.nextDouble();
    return sqrt(-2 * log(u1)) * sin(2 * pi * u2);
  }

  // === NEWS GENERATION ===
  void _generateDailyNews() {
    // Generate 2-4 news items per day (+extra from intelligence/upgrades)
    final newsCount = 2 + _random.nextInt(3) + _extraNewsPerDay + _extraMorningNews;

    // Collect sector insight biases for news targeting
    final sectorBiases = getAllSectorInsightBiases();

    // Sector Insight (legendary): generate guaranteed sector news first
    for (final acquired in _acquiredUpgrades) {
      if (acquired.templateType == 'sector_insight' && acquired.sector != null) {
        final upgrade = getUpgradeById(acquired.upgradeId);
        if (upgrade != null && upgrade.effects['sectorGuaranteedNews'] == true) {
          final sectorId = acquired.sector!.name;
          final sector = getSectorById(sectorId);
          if (sector != null) {
            final news = NewsGenerator.generateSectorNews(sector);
            _addNewsItem(news);
            _applyNewsImpact(news);
            if (news.hasGameplayEffect) applyGameplayEffect(news);
          }
        }
      }
    }

    for (int i = 0; i < newsCount; i++) {
      // Gameplay news chance scales with day progression
      // No gameplay effects on Day 1 (avoid free cash/restrictions before playing)
      final gameplayChance = _currentDay <= 1 ? 0.0
          : _currentDay <= 5 ? 0.20
          : _currentDay <= 10 ? 0.25
          : 0.30;
      final isGameplayNews = _random.nextDouble() < gameplayChance;
      final newsType = isGameplayNews ? 3 : _random.nextInt(3);

      NewsItem? news;
      final companies = unlockedCompanies;

      // Sector Insight: bias news toward upgraded sectors
      bool usedBias = false;
      if (sectorBiases.isNotEmpty && (newsType == 0 || newsType == 1)) {
        // Check each biased sector for a chance to override
        for (final entry in sectorBiases.entries) {
          if (_random.nextDouble() < entry.value) {
            final sector = getSectorById(entry.key);
            if (sector != null) {
              if (newsType == 0 && companies.isNotEmpty) {
                // Company news: pick from biased sector
                final sectorCompanies = companies.where((c) => c.sectorId == entry.key).toList();
                if (sectorCompanies.isNotEmpty) {
                  final company = _selectWeightedCompanyForNews(sectorCompanies);
                  news = NewsGenerator.generateCompanyNews(company);
                  usedBias = true;
                }
              } else {
                // Sector news: use biased sector directly
                news = NewsGenerator.generateSectorNews(sector);
                usedBias = true;
              }
            }
            if (usedBias) break;
          }
        }
      }

      if (!usedBias) {
        switch (newsType) {
          case 0: // Company news (only unlocked companies)
            if (companies.isNotEmpty) {
              final company = _selectWeightedCompanyForNews(companies);
              news = NewsGenerator.generateCompanyNews(company);
            }
            break;
          case 1: // Sector news
            if (allSectors.isNotEmpty) {
              final sector = allSectors[_random.nextInt(allSectors.length)];
              news = NewsGenerator.generateSectorNews(sector);
            }
            break;
          case 2: // Market news
            news = NewsGenerator.generateMarketNews();
            break;
          case 3: // Gameplay news (platform, bonus, restriction, event)
            news = NewsGenerator.generateGameplayNews();
            break;
        }
      }

      // Fallback: if company news failed (no unlocked companies), generate sector/market news
      if (news == null && newsType == 0) {
        if (allSectors.isNotEmpty) {
          final sector = allSectors[_random.nextInt(allSectors.length)];
          news = NewsGenerator.generateSectorNews(sector);
        } else {
          news = NewsGenerator.generateMarketNews();
        }
      }

      if (news != null) {
        _addNewsItem(news);
        _applyNewsImpact(news);
        // Apply gameplay effects if present
        if (news.hasGameplayEffect) {
          applyGameplayEffect(news);
        }
      }
    }
  }

  void _addNewsItem(NewsItem news) {
    _newsItems.insert(0, news); // Add to front (most recent)

    // Keep only the last N news items
    if (_newsItems.length > maxNewsItems) {
      _newsItems.removeRange(maxNewsItems, _newsItems.length);
    }
  }

  // News blocking removed (prestige_news_filter removed)

  void _applyNewsImpact(NewsItem news) {
    // Apply news impact GRADUALLY over time via pending impact
    // NEWS IS THE MAIN DRIVER OF SIGNIFICANT PRICE MOVEMENTS
    final impactMultiplier = news.impactMagnitude;
    double sentimentImpact = 0.0;

    // Impact values - news drives major price moves (can trap signal-based traders)
    switch (news.sentiment) {
      case NewsSentiment.veryPositive:
        sentimentImpact = 0.15 * impactMultiplier; // +15% max
        break;
      case NewsSentiment.positive:
        sentimentImpact = 0.08 * impactMultiplier; // +8% max
        break;
      case NewsSentiment.neutral:
        sentimentImpact = (_random.nextDouble() - 0.5) * 0.02; // Small random ±1%
        break;
      case NewsSentiment.negative:
        sentimentImpact = -0.08 * impactMultiplier; // -8% max
        break;
      case NewsSentiment.veryNegative:
        sentimentImpact = -0.15 * impactMultiplier; // -15% max
        break;
    }

    // Apply impact based on news type
    final companyId = news.companyId;
    final sectorId = news.sectorId;

    if (companyId != null) {
      // Company-specific news - add to pending impact for gradual application
      final state = _stockStates[companyId];
      if (state != null) {
        // Add to pending impact instead of immediate price change
        state.addPendingImpact(sentimentImpact);

        // Set trend direction immediately (market sentiment indicator)
        state.trendDirection = (state.trendDirection + sentimentImpact * 3).clamp(-1.0, 1.0);
      }
    } else if (sectorId != null) {
      // Sector-wide news - affects all stocks in sector
      final currentTrend = _sectorTrends[sectorId] ?? 0.0;
      _sectorTrends[sectorId] = (currentTrend + sentimentImpact * 2).clamp(-0.5, 0.5);

      // Add pending impact to all stocks in the sector
      for (final state in _stockStates.values) {
        if (state.company.sectorId == sectorId) {
          final sectorImpact = sentimentImpact * 0.5; // 50% of full impact
          state.addPendingImpact(sectorImpact);
        }
      }
    } else {
      // Market-wide news - affects all stocks slightly
      _marketSentiment = (_marketSentiment + sentimentImpact).clamp(-1.0, 1.0);

      // Add small pending impact to all stocks
      for (final state in _stockStates.values) {
        final marketImpact = sentimentImpact * 0.3; // 30% of full impact
        state.addPendingImpact(marketImpact);
      }
    }
  }

  // === TRADING ===
  bool canBuy(CompanyData company, double shares) {
    final state = _stockStates[company.id];
    if (state == null) return false;

    BigNumber cost = state.currentPrice.multiplyByDouble(shares);
    // Sector Dominance (legendary): fee reduction on this sector
    var feePercent = effectiveFeePercent;
    final canBuySector = getSectorById(company.sectorId);
    if (canBuySector != null) {
      final feeReduc = getSectorDominanceFeeReduction(canBuySector.type);
      if (feeReduc > 0) feePercent = (feePercent * (1.0 - feeReduc)).clamp(0.0, feePercent);
    }
    BigNumber fee = cost.multiplyByDouble(feePercent / 100);
    BigNumber totalCost = cost + fee;

    return _cash >= totalCost;
  }

  bool buy(CompanyData company, double shares) {
    if (!canBuy(company, shares)) return false;

    final state = _stockStates[company.id]!;
    BigNumber price = state.currentPrice;
    BigNumber cost = price.multiplyByDouble(shares);
    // Sector Dominance (legendary): fee reduction on this sector
    var feePercent = effectiveFeePercent;
    final buySector = getSectorById(company.sectorId);
    if (buySector != null) {
      final feeReduc = getSectorDominanceFeeReduction(buySector.type);
      if (feeReduc > 0) feePercent = (feePercent * (1.0 - feeReduc)).clamp(0.0, feePercent);
    }
    BigNumber fee = cost.multiplyByDouble(feePercent / 100);
    BigNumber totalCost = cost + fee;

    // Check for all-in trade (90%+ of cash)
    if (totalCost.toDouble() >= _cash.toDouble() * 0.9) {
      onAllInTrade?.call();
    }

    // Deduct cash
    _cash = _cash - totalCost;

    // Update or create LONG position
    Position? position = _positions
        .where((p) => p.company.id == company.id && p.type == PositionType.long)
        .firstOrNull;

    if (position == null) {
      position = Position(company: company);
      _positions.add(position);
    }

    // Calculate bonus shares from meta progression + upgrades (free shares!)
    // Combined rate is capped at 25%
    final combinedBonusRate = (_metaStockBonusRate + _upgradeStockBonusRate).clamp(0.0, 0.25);
    double bonusShares = 0;
    if (combinedBonusRate > 0) {
      bonusShares = (shares * combinedBonusRate).floorToDouble();
    }
    final totalShares = shares + bonusShares;

    position.buy(totalShares, price, cost, fees: fee); // Buy total shares but only pay for original
    state.addVolume(cost);

    // Track for Day Trader bonus
    _boughtTodayCompanies.add(company.id);

    // Track position open day for hold bonus
    _positionOpenDay.putIfAbsent('${company.id}_long', () => _currentDay);

    // Track for Contrarian bonus (bought a stock that's down significantly)
    if (_contrarianBonus > 0 && state.dayChangePercent <= -(_contrarianThreshold * 100)) {
      _contrarianBuys.add(company.id);
    }

    // Record trade (include bonus shares info)
    _recordTrade(
      company: company,
      type: TradeType.buy,
      shares: totalShares,
      pricePerShare: price,
      totalValue: cost,
      fees: fee,
      bonusShares: bonusShares,
    );

    // Check if all position slots are filled
    if (_positions.length >= maxPositions) {
      onMaxPositionsFilled?.call();
    }

    notifyListeners();
    return true;
  }

  bool canSell(CompanyData company, double shares) {
    final position = _positions
        .where((p) => p.company.id == company.id && p.type == PositionType.long)
        .firstOrNull;
    return position != null && position.shares >= shares;
  }

  bool sell(CompanyData company, double shares, {bool isStopLossTrigger = false}) {
    final position = _positions
        .where((p) => p.company.id == company.id && p.type == PositionType.long)
        .firstOrNull;
    if (position == null || position.shares < shares) return false;

    final state = _stockStates[company.id]!;
    BigNumber price = state.currentPrice;
    BigNumber saleValue = price.multiplyByDouble(shares);
    BigNumber netProceeds = saleValue;

    // Pre-calculate scalper fee refund BEFORE sell modifies position
    BigNumber scalperFeeRefund = BigNumber.zero;
    if (_scalperNoFees && _boughtTodayCompanies.contains(company.id) && position.totalFeesPaid.isPositive) {
      final proportion = position.shares > 0 ? shares / position.shares : 1.0;
      scalperFeeRefund = position.totalFeesPaid.multiplyByDouble(proportion);
    }

    // Execute sale (fees only on entry, not on exit)
    BigNumber realizedPnL = position.sell(shares, price);

    // Apply leverage multiplier (before other bonuses — leverage amplifies base PnL)
    final posLeverage = _positionLeverage['${company.id}_long'] ?? 1.0;
    if (posLeverage > 1.0) {
      final leverageExtra = realizedPnL.multiplyByDouble(posLeverage - 1.0);
      realizedPnL = realizedPnL + leverageExtra;
      netProceeds = netProceeds + leverageExtra;
    }

    // === APPLY TRADING BONUSES (additive on base PnL) ===
    final BigNumber basePnL = realizedPnL;

    if (basePnL.isPositive) {
      BigNumber totalBonus = BigNumber.zero;

      // Sector Edge: +X% profit on winning trades for this sector (daily upgrade)
      final sector = getSectorById(company.sectorId);
      if (sector != null) {
        final sectorBoost = getSectorEdgeBoost(sector.type);
        if (sectorBoost > 0) {
          totalBonus = totalBonus + basePnL.multiplyByDouble(sectorBoost);
        }
      }

      // Talent tree: general profit multiplier (Trader branch)
      if (_profitMultiplier > 0) {
        totalBonus = totalBonus + basePnL.multiplyByDouble(_profitMultiplier);
      }

      // Talent tree: per-sector profit boost (Sectors branch)
      final sectorProfitBoost = _sectorProfitBonuses[company.sectorId] ?? 0.0;
      if (sectorProfitBoost > 0) {
        totalBonus = totalBonus + basePnL.multiplyByDouble(sectorProfitBoost);
      }

      // Sector Dominance: +X% per position held in this sector (daily upgrade)
      if (sector != null) {
        final dominancePerPos = getSectorDominanceBonus(sector.type);
        if (dominancePerPos > 0) {
          final posCount = countPositionsInSector(company.sectorId);
          final dominanceBonus = dominancePerPos * posCount;
          totalBonus = totalBonus + basePnL.multiplyByDouble(dominanceBonus.clamp(0.0, 1.0));
        }
      }

      // Survival branch: Second Wind — profit bonus after using a life
      if (_secondWindDaysLeft > 0 && _secondWindBonus > 0) {
        totalBonus = totalBonus + basePnL.multiplyByDouble(_secondWindBonus);
      }

      // Survival branch: Quota Streak — bonus per consecutive quota met
      if (_quotaStreak > 0 && _streakProfitBonus > 0) {
        totalBonus = totalBonus + basePnL.multiplyByDouble(_streakProfitBonus * _quotaStreak);
      }

      realizedPnL = realizedPnL + totalBonus;
      netProceeds = netProceeds + totalBonus;
    }

    // Combined loss reduction: talent tree general + talent tree sector + daily sector shield
    // Hard-capped at 50% to keep losses meaningful
    if (realizedPnL.isNegative) {
      double totalReduction = _lossReduction; // talent tree general (Defense branch)

      // Talent tree per-sector shield
      final talentSectorShield = _sectorLossShields[company.sectorId] ?? 0.0;
      totalReduction += talentSectorShield;

      // Daily upgrade sector shield
      final sector = getSectorById(company.sectorId);
      if (sector != null) {
        totalReduction += getSectorShieldReduction(sector.type);
      }

      // Cap total loss reduction at 50%
      if (totalReduction > 0.50) totalReduction = 0.50;

      if (totalReduction > 0) {
        final reduction = realizedPnL.multiplyByDouble(-totalReduction);
        realizedPnL = realizedPnL + reduction;
        netProceeds = netProceeds + reduction;
      }
    }

    // Insurance: meta-progression loss reduction (from achievements)
    if (realizedPnL.isNegative && _metaInsurance > 0) {
      final reduction = realizedPnL.multiplyByDouble(-_metaInsurance);
      realizedPnL = realizedPnL + reduction;
      netProceeds = netProceeds + reduction;
    }

    // Talent tree: cap maximum loss per trade (Defense branch)
    if (realizedPnL.isNegative && _maxLossPerTrade < 1.0) {
      final costBasis = position.averageCost.multiplyByDouble(shares);
      final maxLoss = -costBasis.multiplyByDouble(_maxLossPerTrade);
      if (realizedPnL < maxLoss) {
        final recovery = maxLoss - realizedPnL;
        realizedPnL = maxLoss;
        netProceeds = netProceeds + recovery;
      }
    }

    // Momentum Rider bonus: +X% after consecutive wins
    if (realizedPnL.isPositive && hasMomentumBonus) {
      final bonus = realizedPnL.multiplyByDouble(_momentumBonus);
      realizedPnL = realizedPnL + bonus;
      netProceeds = netProceeds + bonus;
    }

    // Winning Streak bonus: +X% per consecutive win (talent tree + daily upgrade)
    if (realizedPnL.isPositive && _consecutiveWins > 0) {
      final talentBonus = _streakBonusPerWin;
      final upgradeBonus = getWinStreakUpgradeBonus();
      final totalPerWin = talentBonus + upgradeBonus;
      if (totalPerWin > 0) {
        final stacks = _streakMaxStacks > 0
            ? _consecutiveWins.clamp(0, _streakMaxStacks)
            : _consecutiveWins;
        final bonus = realizedPnL.multiplyByDouble(totalPerWin * stacks);
        realizedPnL = realizedPnL + bonus;
        netProceeds = netProceeds + bonus;
      }
    }

    // Day Trader bonus: +X% when selling stock bought today
    if (realizedPnL.isPositive && _dayTradeBonus > 0 && _boughtTodayCompanies.contains(company.id)) {
      final bonus = realizedPnL.multiplyByDouble(_dayTradeBonus);
      realizedPnL = realizedPnL + bonus;
      netProceeds = netProceeds + bonus;
    }

    // Contrarian bonus: +X% when selling stock bought at a dip
    if (realizedPnL.isPositive && _contrarianBonus > 0 && _contrarianBuys.contains(company.id)) {
      final bonus = realizedPnL.multiplyByDouble(_contrarianBonus);
      realizedPnL = realizedPnL + bonus;
      netProceeds = netProceeds + bonus;
      _contrarianBuys.remove(company.id); // Used the bonus
    }

    // Diversification bonus: +X% based on number of sectors in portfolio
    if (realizedPnL.isPositive) {
      final diversificationMultiplier = _getDiversificationMultiplier();
      if (diversificationMultiplier > 0) {
        final bonus = realizedPnL.multiplyByDouble(diversificationMultiplier);
        realizedPnL = realizedPnL + bonus;
        netProceeds = netProceeds + bonus;
      }
    }

    // Trader branch: Quick Flip bonus (+X% on same-day profitable trades)
    if (realizedPnL.isPositive && _quickFlipBonus > 0 && _boughtTodayCompanies.contains(company.id)) {
      final bonus = realizedPnL.multiplyByDouble(_quickFlipBonus);
      realizedPnL = realizedPnL + bonus;
      netProceeds = netProceeds + bonus;
    }

    // Trader branch: Hold bonuses (+X% when holding positions for N days)
    final posKey = '${company.id}_long';
    final daysHeld = _currentDay - (_positionOpenDay[posKey] ?? _currentDay);
    if (realizedPnL.isPositive && daysHeld > 0) {
      double holdBonusPercent = 0;
      if (daysHeld >= 7 && _holdBonus7d > 0) {
        holdBonusPercent = _holdBonus7d;
      } else if (daysHeld >= 5 && _holdBonus5d > 0) {
        holdBonusPercent = _holdBonus5d;
      } else if (daysHeld >= 3 && _holdBonus3d > 0) {
        holdBonusPercent = _holdBonus3d;
      }
      if (holdBonusPercent > 0) {
        final bonus = realizedPnL.multiplyByDouble(holdBonusPercent);
        realizedPnL = realizedPnL + bonus;
        netProceeds = netProceeds + bonus;
      }
    }

    // Trader branch: Scalper no-fees (refund entry fees on same-day trades)
    if (scalperFeeRefund.isPositive) {
      realizedPnL = realizedPnL + scalperFeeRefund;
      netProceeds = netProceeds + scalperFeeRefund;
    }

    // Trader branch: Safety Net (first SL trigger softened — 50% less loss, once per run)
    if (isStopLossTrigger && _safetyNetUnlock && !_safetyNetUsed && realizedPnL.isNegative) {
      final recovery = realizedPnL.multiplyByDouble(-0.50);
      realizedPnL = realizedPnL + recovery;
      netProceeds = netProceeds + recovery;
      _safetyNetUsed = true;
    }

    // Add cash
    _cash = _cash + netProceeds;

    // Track consecutive wins for Momentum
    _quotaProgress = _quotaProgress + realizedPnL;
    if (realizedPnL.isPositive) {
      _consecutiveWins++;
      _lifetimeEarnings = _lifetimeEarnings + realizedPnL;
      _winningTrades++;
    } else {
      _consecutiveWins = _streakKeepOnLoss
          ? (_consecutiveWins ~/ 2) // Resilient: halve streak instead of full reset
          : 0;
      // Track daily losses for Tax Refund
      _dailyRealizedLosses += realizedPnL.toDouble().abs();
    }

    _totalRealizedPnL = _totalRealizedPnL + realizedPnL;
    _totalTrades++;
    state.addVolume(saleValue);

    // Track best single trade
    final tradeProfit = realizedPnL.toDouble();
    if (tradeProfit > _bestSingleTrade) _bestSingleTrade = tradeProfit;

    // Track best day profit
    if (_dailyProfitAmount > _bestDayProfit) _bestDayProfit = _dailyProfitAmount;

    // Check milestones and personal bests
    _checkPersonalBestsAndMilestones();

    // Record trade
    _recordTrade(
      company: company,
      type: TradeType.sell,
      shares: shares,
      pricePerShare: price,
      totalValue: saleValue,
      fees: BigNumber.zero,
      realizedPnL: realizedPnL,
    );

    // Remove empty position
    if (!position.hasShares) {
      _positions.remove(position);
      _positionOpenDay.remove('${company.id}_long');
      _positionLeverage.remove('${company.id}_long');
      _positionHighPrice.remove('${company.id}_long');
      _partialTpTaken.remove('${company.id}_long');
    }

    notifyListeners();
    return true;
  }

  // === SHORT SELLING ===
  bool canShort(CompanyData company, double shares) {
    // Check if short selling is banned by event
    if (_shortSellingBanned) return false;

    final state = _stockStates[company.id];
    if (state == null) return false;

    // Shorting requires cash for full position cost + fees (like buying)
    BigNumber cost = state.currentPrice.multiplyByDouble(shares);
    BigNumber fee = cost.multiplyByDouble(effectiveFeePercent / 100);
    BigNumber totalCost = cost + fee;

    return _cash >= totalCost;
  }

  bool short(CompanyData company, double shares) {
    if (!canShort(company, shares)) return false;

    final state = _stockStates[company.id]!;
    BigNumber price = state.currentPrice;
    BigNumber cost = price.multiplyByDouble(shares);
    BigNumber fee = cost.multiplyByDouble(effectiveFeePercent / 100);
    BigNumber totalCost = cost + fee;

    // SHORT = Pay cash to open position (bet on price going down)
    // Just like buying, opening a short costs money
    _cash = _cash - totalCost;

    // Update or create SHORT position
    Position? position = _positions
        .where((p) => p.company.id == company.id && p.type == PositionType.short)
        .firstOrNull;

    if (position == null) {
      position = Position(company: company, type: PositionType.short);
      _positions.add(position);

      // Notify achievement system of new short position
      onShortOpened?.call();
    }

    position.short(shares, price, cost, fees: fee);
    state.addVolume(cost);

    // Record trade
    _recordTrade(
      company: company,
      type: TradeType.short,
      shares: shares,
      pricePerShare: price,
      totalValue: cost,
      fees: fee,
    );

    notifyListeners();
    return true;
  }

  bool canCover(CompanyData company, double shares) {
    final position = _positions
        .where((p) => p.company.id == company.id && p.type == PositionType.short)
        .firstOrNull;

    if (position == null || position.shares < shares) return false;

    final state = _stockStates[company.id];
    if (state == null) return false;

    // No exit fee - covering just closes the position
    return true;
  }

  bool cover(CompanyData company, double shares) {
    final position = _positions
        .where((p) => p.company.id == company.id && p.type == PositionType.short)
        .firstOrNull;

    if (position == null || position.shares < shares) return false;
    if (!canCover(company, shares)) return false;

    final state = _stockStates[company.id]!;
    BigNumber currentPrice = state.currentPrice;
    BigNumber entryPrice = position.averageCost;

    // Calculate what we get back: original investment + price P&L (no exit fee)
    BigNumber originalInvestment = entryPrice.multiplyByDouble(shares);
    BigNumber pricePnL = (entryPrice - currentPrice).multiplyByDouble(shares);

    // Apply leverage multiplier to short P&L
    final shortLeverage = _positionLeverage['${company.id}_short'] ?? 1.0;
    if (shortLeverage > 1.0) {
      pricePnL = pricePnL.multiplyByDouble(shortLeverage);
    }

    BigNumber returnAmount = originalInvestment + pricePnL;

    // COVER = Get cash back (like selling)
    _cash = _cash + returnAmount;

    // Update position tracking (includes entry fees in realized P&L)
    BigNumber realizedPnL = position.cover(shares, currentPrice);
    if (shortLeverage > 1.0) {
      final leverageExtra = realizedPnL.multiplyByDouble(shortLeverage - 1.0);
      realizedPnL = realizedPnL + leverageExtra;
    }

    // Track quota (losses reduce progress too)
    _quotaProgress = _quotaProgress + realizedPnL;
    if (realizedPnL.isPositive) {
      _lifetimeEarnings = _lifetimeEarnings + realizedPnL;
      _winningTrades++;
    }

    _totalRealizedPnL = _totalRealizedPnL + realizedPnL;
    _totalTrades++;
    state.addVolume(originalInvestment);

    // Track best single trade
    final tradeProfit = realizedPnL.toDouble();
    if (tradeProfit > _bestSingleTrade) _bestSingleTrade = tradeProfit;
    if (_dailyProfitAmount > _bestDayProfit) _bestDayProfit = _dailyProfitAmount;
    _checkPersonalBestsAndMilestones();

    // Record trade
    _recordTrade(
      company: company,
      type: TradeType.cover,
      shares: shares,
      pricePerShare: currentPrice,
      totalValue: returnAmount,
      fees: BigNumber.zero,
      realizedPnL: realizedPnL,
    );

    // Remove empty position
    if (!position.hasShares) {
      _positions.remove(position);
      _positionLeverage.remove('${company.id}_short');
    }

    notifyListeners();
    return true;
  }

  /// Close all positions (sell all longs, cover all shorts)
  int closeAllPositions() {
    int closed = 0;
    // Copy list to avoid modification during iteration
    final positionsToClose = List<Position>.from(_positions);
    for (final position in positionsToClose) {
      if (position.type == PositionType.long) {
        if (sell(position.company, position.shares)) closed++;
      } else {
        if (cover(position.company, position.shares)) closed++;
      }
    }
    return closed;
  }

  // === PORTFOLIO ===

  // Position filters
  List<Position> get longPositions =>
      _positions.where((p) => p.type == PositionType.long).toList();

  List<Position> get shortPositions =>
      _positions.where((p) => p.type == PositionType.short).toList();

  // Long portfolio value (cached)
  BigNumber get longPortfolioValue {
    if (_cachedLongPortfolioValue != null) return _cachedLongPortfolioValue!;
    BigNumber total = BigNumber.zero;
    for (final position in longPositions) {
      final state = _stockStates[position.company.id];
      if (state != null) {
        total = total + position.currentValue(state.currentPrice);
      }
    }
    _cachedLongPortfolioValue = total;
    return total;
  }

  // Short portfolio value (cached)
  BigNumber get shortPortfolioValue {
    if (_cachedShortPortfolioValue != null) return _cachedShortPortfolioValue!;
    BigNumber total = BigNumber.zero;
    for (final position in shortPositions) {
      final state = _stockStates[position.company.id];
      if (state != null) {
        total = total + position.currentValue(state.currentPrice);
      }
    }
    _cachedShortPortfolioValue = total;
    return total;
  }

  // Total portfolio value (cached)
  BigNumber get portfolioValue {
    if (_cachedPortfolioValue != null) return _cachedPortfolioValue!;
    _cachedPortfolioValue = longPortfolioValue + shortPortfolioValue;
    return _cachedPortfolioValue!;
  }

  BigNumber get netWorth {
    if (_cachedNetWorth != null) return _cachedNetWorth!;
    _cachedNetWorth = _cash + portfolioValue;
    return _cachedNetWorth!;
  }

  // Unrealized P&L for long positions
  BigNumber get unrealizedPnLLong {
    BigNumber total = BigNumber.zero;
    for (final position in longPositions) {
      final state = _stockStates[position.company.id];
      if (state != null) {
        total = total + position.unrealizedPnL(state.currentPrice);
      }
    }
    return total;
  }

  // Unrealized P&L for short positions
  BigNumber get unrealizedPnLShort {
    BigNumber total = BigNumber.zero;
    for (final position in shortPositions) {
      final state = _stockStates[position.company.id];
      if (state != null) {
        total = total + position.unrealizedPnL(state.currentPrice);
      }
    }
    return total;
  }

  // Total unrealized P&L (cached)
  BigNumber get unrealizedPnL {
    if (_cachedUnrealizedPnL != null) return _cachedUnrealizedPnL!;
    _cachedUnrealizedPnL = unrealizedPnLLong + unrealizedPnLShort;
    return _cachedUnrealizedPnL!;
  }

  // === DATA ACCESS ===
  StockState? getStockState(String companyId) => _stockStates[companyId];

  List<StockState> getStocksBySector(String sectorId) {
    return _stockStates.values
        .where((s) => s.company.sectorId == sectorId && isCompanyUnlocked(s.company.id))
        .toList();
  }

  double getSectorPerformance(String sectorId) {
    final stocks = getStocksBySector(sectorId);
    if (stocks.isEmpty) return 0;
    return stocks.map((s) => s.dayChangePercent).reduce((a, b) => a + b) / stocks.length;
  }

  List<StockState> getTopMovers({int count = 5, bool gainers = true}) {
    final unlocked = _stockStates.values
        .where((s) => isCompanyUnlocked(s.company.id))
        .toList();
    unlocked.sort((a, b) => gainers
        ? b.dayChangePercent.compareTo(a.dayChangePercent)
        : a.dayChangePercent.compareTo(b.dayChangePercent));
    return unlocked.take(count).toList();
  }

  // === NAVIGATION ===
  void setView(ViewType view) {
    _currentView = view;
    notifyListeners();
  }

  void setMarketSubTab(int tab) {
    _marketSubTab = tab;
    if (tab == 0) _selectedSectorId = null;
    notifyListeners();
  }

  void selectSector(String sectorId) {
    _selectedSectorId = sectorId;
    _currentView = ViewType.market;
    _marketSubTab = 1; // Switch to Stocks sub-tab
    notifyListeners();
  }

  void selectCompany(String companyId) {
    _selectedCompanyId = companyId;
    _currentView = ViewType.trading;
    notifyListeners();
  }

  void goBack() {
    switch (_currentView) {
      case ViewType.dashboard:
        break;
      case ViewType.trading:
        _currentView = ViewType.market;
        _selectedCompanyId = null;
        break;
      case ViewType.market:
        if (_selectedSectorId != null) {
          _selectedSectorId = null;
        } else {
          _currentView = ViewType.dashboard;
        }
        break;
      case ViewType.portfolio:
        break;
      case ViewType.robots:
        break;
    }
    notifyListeners();
  }

  // === SETTINGS ===
  void setGameSpeed(double speed) {
    _gameSpeed = speed.clamp(0.5, 5.0);
    notifyListeners();
  }

  void setDaysPerQuota(int days) {
    _daysPerQuota = days.clamp(1, 30);
    notifyListeners();
  }

  // === SAVE/LOAD ===

  /// Convert game state to JSON for saving
  Map<String, dynamic> toJson() {
    return {
      'version': '1.0',
      'savedAt': DateTime.now().toIso8601String(),
      'gameState': {
        // Basic game state
        'currentDay': _currentDay,
        'currentYear': _currentYear,
        'dayTimer': _dayTimer,
        'cash': _cash.toJson(),
        'quotaTarget': _quotaTarget.toJson(),
        'quotaProgress': _quotaProgress.toJson(),
        'failedQuotas': _failedQuotas,
        'gameSpeed': _gameSpeed,

        // Upgradeable settings
        'daysPerQuota': _daysPerQuota,
        'feeReduction': _feeReduction,
        'maxPositions': _maxPositions,
        'quotaReduction': _quotaReduction,
        'skipQuotaBonusPercent': _skipQuotaBonusPercent,
        'extraDaySeconds': _extraDaySeconds,
        'extraMorningNews': _extraMorningNews,
        'extraMidDayNews': _extraMidDayNews,
        'passiveIncome': _passiveIncome,

        // Unlocked content
        'unlockedCompanyIds': _unlockedCompanyIds.toList(),
        'acquiredUpgrades': _acquiredUpgrades.map((u) => u.toJson()).toList(),

        // Shop state
        'shopUpgrades': _shopUpgrades.map((u) => {
          'id': u.id,
          if (u.sector != null) 'sector': u.sector!.index,
        }).toList(),
        'shopRollsToday': _shopRollsToday,
        'dailyRerollsUsed': _dailyRerollsUsed,
        'dailyTradesCount': _dailyTradesCount,
        'dailyProfitAmount': _dailyProfitAmount,
        'dailyVolumeTraded': _dailyVolumeTraded,
        'dailyDipBuys': _dailyDipBuys,
        'dailySellHighs': _dailySellHighs,
        'dailyLosingTrades': _dailyLosingTrades,

        // Portfolio
        'positions': _positions.map((p) => p.toJson()).toList(),
        'totalRealizedPnL': _totalRealizedPnL.toJson(),
        'totalTrades': _totalTrades,
        'winningTrades': _winningTrades,
        'totalOpeningExpenses': _totalOpeningExpenses.toJson(),
        'totalRobotExpenses': _totalRobotExpenses.toJson(),

        // Trade history
        'tradeHistory': _tradeHistory.map((t) => t.toJson()).toList(),
        'tradeIdCounter': _tradeIdCounter,

        // Tokens
        'tokens': _tokens.map((t) => t.toJson()).toList(),
        'tokenIdCounter': _tokenIdCounter,

        // Robots
        'robots': _robots.map((r) => r.toJson()).toList(),
        'robotIdCounter': _robotIdCounter,
        'peakNetWorth': _peakNetWorth.toJson(),

        // Stock states (only save essential data)
        'stockStates': _stockStates.map((k, v) => MapEntry(k, v.toJson())),

        // Active effects
        'activeFeeMultiplier': _activeFeeMultiplier,
        'feeMultiplierDaysLeft': _feeMultiplierDaysLeft,
        'shortSellingBanned': _shortSellingBanned,
        'shortBanDaysLeft': _shortBanDaysLeft,
        'activeUpgradeDiscount': _activeUpgradeDiscount,
        'upgradeDiscountDaysLeft': _upgradeDiscountDaysLeft,
        'activeVolatilityMultiplier': _activeVolatilityMultiplier,
        'volatilityMultiplierDaysLeft': _volatilityMultiplierDaysLeft,
        'activePositionLimit': _activePositionLimit,
        'positionLimitDaysLeft': _positionLimitDaysLeft,
        'signalJammerActive': _signalJammerActive,
        'signalJammerDaysLeft': _signalJammerDaysLeft,
        'analystPrecision': _analystPrecision,
      },
      'prestigeState': {
        'version': 2,
        'prestigeLevel': _prestigeLevel,
        'lifetimeEarnings': _lifetimeEarnings.toJson(),
        'prestigePoints': _prestigePoints,
        'totalPrestigePoints': _totalPrestigePoints,
        'startingCashBonus': _startingCashBonus,
        'purchasedTalentNodes': _purchasedTalentNodes.toList(),
        'blockBadEventsUsed': _blockBadEventsUsed,
        'livesRemaining': _livesRemaining,
        'secondWindDaysLeft': _secondWindDaysLeft,
        'quotaStreak': _quotaStreak,
        'consecutiveSkips': _consecutiveSkips,
        'allQuotasEarly': _allQuotasEarly,
        'overtimeDaysLeft': _overtimeDaysLeft,
        'inOvertime': _inOvertime,

        // Legacy prestige effects (still used by gameplay code)
        'upgradeRerollsPerDay': _upgradeRerollsPerDay,
        'guaranteedRareFirst': _guaranteedRareFirst,
        'usedGuaranteedRare': _usedGuaranteedRare,
        'quotaFailFreebies': _quotaFailFreebies,
        'keepCashOnFailPercent': _keepCashOnFailPercent,
        'extraUpgradeChoices': _extraUpgradeChoices,
        'shortBanImmunity': _shortBanImmunity,
        'startingUpgrades': _startingUpgrades,
        'prestigePointMultiplier': _prestigePointMultiplier,
        'cashInterestRate': _cashInterestRate,
        'shopRarityBoost': _shopRarityBoost,
        'freeRollsPerDay': _freeRollsPerDay,
        'sectorAmplifier': _sectorAmplifier,

        // Robot prestige
        'maxRobotSlots': _maxRobotSlots,
        'robotSpeedBonus': _robotSpeedBonus,
        // Per-robot upgrades are stored in purchasedTalentNodes

        // Trading strategy bonuses
        'consecutiveWins': _consecutiveWins,
        'momentumBonus': _momentumBonus,
        'momentumStreak': _momentumStreak,
        'contrarianBonus': _contrarianBonus,
        'contrarianThreshold': _contrarianThreshold,
        'dayTradeBonus': _dayTradeBonus,
        'lossRecoveryPercent': _lossRecoveryPercent,
        'hasStopLoss': _hasStopLoss,
        'hasTakeProfit': _hasTakeProfit,
        'stopLossPercent': _stopLossPercent,
        'takeProfitPercent': _takeProfitPercent,
        'stopLossEnabled': _stopLossEnabled,
        'takeProfitEnabled': _takeProfitEnabled,
        'trailingStopEnabled': _trailingStopEnabled,
        'priceAlertThreshold': _priceAlertThreshold,
      },
      'finTokState': {
        'influencers': _influencers.map((i) => i.toJson()).toList(),
        'tips': _tips.map((t) => t.toJson()).toList(),
        'usedInfluencerTemplateIds': _usedInfluencerTemplateIds.toList(),
        'followedInfluencerIds': _followedInfluencerIds.toList(),
      },
      'informantState': _informantState.toJson(),
      'challengeState': _challengeState.toJson(),
      'casualState': {
        'bestNetWorth': _bestNetWorth.toJson(),
        'bestDayProfit': _bestDayProfit,
        'bestSingleTrade': _bestSingleTrade,
        'bestWinStreak': _bestWinStreak,
        'mostDaysSurvived': _mostDaysSurvived,
        'reachedMilestones': _reachedMilestones.toList(),
        'favoriteStockIds': _favoriteStockIds.toList(),
        'leaderboard': _leaderboard,
      },
    };
  }

  /// Load game state from JSON
  void loadFromJson(Map<String, dynamic> json) {
    // Stop any running game
    _gameTimer?.cancel();
    _isPaused = true;

    final gameState = json['gameState'] as Map<String, dynamic>? ?? {};
    final prestigeState = json['prestigeState'] as Map<String, dynamic>? ?? {};

    // Basic game state
    _currentDay = gameState['currentDay'] ?? 1;
    _currentYear = gameState['currentYear'] ?? 1;
    _dayTimer = (gameState['dayTimer'] ?? secondsPerDay).toDouble();
    _cash = gameState['cash'] != null
        ? BigNumber.fromJson(gameState['cash'])
        : BigNumber(startingCash);
    _quotaTarget = gameState['quotaTarget'] != null
        ? BigNumber.fromJson(gameState['quotaTarget'])
        : BigNumber(startingQuota);
    _quotaProgress = gameState['quotaProgress'] != null
        ? BigNumber.fromJson(gameState['quotaProgress'])
        : BigNumber.zero;
    _failedQuotas = gameState['failedQuotas'] ?? 0;
    _gameSpeed = (gameState['gameSpeed'] ?? 1.0).toDouble();

    // Upgradeable settings
    _daysPerQuota = gameState['daysPerQuota'] ?? 3;
    _feeReduction = (gameState['feeReduction'] ?? 0.0).toDouble();
    _maxPositions = gameState['maxPositions'] ?? 3;
    _quotaReduction = (gameState['quotaReduction'] ?? 0.0).toDouble();
    _skipQuotaBonusPercent = (gameState['skipQuotaBonusPercent'] ?? 0.15).toDouble();
    _extraDaySeconds = gameState['extraDaySeconds'] ?? 0;
    _extraMorningNews = gameState['extraMorningNews'] ?? 0;
    _extraMidDayNews = gameState['extraMidDayNews'] ?? 0;
    _passiveIncome = (gameState['passiveIncome'] ?? 0.0).toDouble();

    // Unlocked content
    _unlockedCompanyIds.clear();
    final unlockedIds = gameState['unlockedCompanyIds'] as List<dynamic>? ?? [];
    _unlockedCompanyIds.addAll(unlockedIds.cast<String>());

    _acquiredUpgrades.clear();
    final upgrades = gameState['acquiredUpgrades'] as List<dynamic>? ?? [];
    for (final u in upgrades) {
      if (u is Map<String, dynamic>) {
        _acquiredUpgrades.add(AcquiredUpgrade.fromJson(u));
      }
    }

    // Shop state
    _shopUpgrades.clear();
    final savedShop = gameState['shopUpgrades'] as List<dynamic>? ?? [];
    for (final item in savedShop) {
      if (item is Map<String, dynamic>) {
        final id = item['id'] as String?;
        if (id != null) {
          var upgrade = getUpgradeById(id);
          if (upgrade != null) {
            if (item['sector'] != null) {
              upgrade = upgrade.withSector(SectorType.values[item['sector'] as int]);
            }
            _shopUpgrades.add(upgrade);
          }
        }
      }
    }
    _shopRollsToday = gameState['shopRollsToday'] ?? 0;
    _dailyRerollsUsed = (gameState['dailyRerollsUsed'] as List<dynamic>?)
        ?.map((e) => (e as int))
        .toList() ?? [0, 0, 0];
    _dailyTradesCount = gameState['dailyTradesCount'] ?? 0;
    _dailyProfitAmount = (gameState['dailyProfitAmount'] ?? 0.0).toDouble();
    _dailyVolumeTraded = (gameState['dailyVolumeTraded'] ?? 0.0).toDouble();
    _dailyDipBuys = gameState['dailyDipBuys'] ?? 0;
    _dailySellHighs = gameState['dailySellHighs'] ?? 0;
    _dailyLosingTrades = gameState['dailyLosingTrades'] ?? 0;

    // Portfolio
    _positions.clear();
    final positions = gameState['positions'] as List<dynamic>? ?? [];
    for (final p in positions) {
      if (p is Map<String, dynamic>) {
        _positions.add(_positionFromJson(p));
      }
    }
    _totalRealizedPnL = gameState['totalRealizedPnL'] != null
        ? BigNumber.fromJson(gameState['totalRealizedPnL'])
        : BigNumber.zero;
    _totalTrades = gameState['totalTrades'] ?? 0;
    _winningTrades = gameState['winningTrades'] ?? 0;
    _totalOpeningExpenses = gameState['totalOpeningExpenses'] != null
        ? BigNumber.fromJson(gameState['totalOpeningExpenses'])
        : BigNumber.zero;
    _totalRobotExpenses = gameState['totalRobotExpenses'] != null
        ? BigNumber.fromJson(gameState['totalRobotExpenses'])
        : BigNumber.zero;

    // Trade history
    _tradeHistory.clear();
    final trades = gameState['tradeHistory'] as List<dynamic>? ?? [];
    for (final t in trades) {
      if (t is Map<String, dynamic>) {
        _tradeHistory.add(_tradeRecordFromJson(t));
      }
    }
    _tradeIdCounter = gameState['tradeIdCounter'] ?? 0;

    // Tokens
    _tokens.clear();
    final tokens = gameState['tokens'] as List<dynamic>? ?? [];
    for (final t in tokens) {
      if (t is Map<String, dynamic>) {
        _tokens.add(Token.fromJson(t));
      }
    }
    _tokenIdCounter = gameState['tokenIdCounter'] ?? 0;

    // Robots
    _robots.clear();
    final robotsJson = gameState['robots'] as List<dynamic>? ?? [];
    for (final r in robotsJson) {
      if (r is Map<String, dynamic>) {
        _robots.add(RobotTrader.fromJson(r));
      }
    }
    _robotIdCounter = gameState['robotIdCounter'] ?? 0;
    _peakNetWorth = gameState['peakNetWorth'] != null
        ? BigNumber.fromJson(gameState['peakNetWorth'] as Map<String, dynamic>)
        : netWorth;

    // Stock states
    final stockStates = gameState['stockStates'] as Map<String, dynamic>? ?? {};
    for (final entry in stockStates.entries) {
      if (_stockStates.containsKey(entry.key) && entry.value is Map<String, dynamic>) {
        _stockStates[entry.key]!.loadFromJson(entry.value as Map<String, dynamic>);
      }
    }

    // Active effects
    _activeFeeMultiplier = (gameState['activeFeeMultiplier'] ?? 1.0).toDouble();
    _feeMultiplierDaysLeft = gameState['feeMultiplierDaysLeft'] ?? 0;
    _shortSellingBanned = gameState['shortSellingBanned'] ?? false;
    _shortBanDaysLeft = gameState['shortBanDaysLeft'] ?? 0;
    _activeUpgradeDiscount = (gameState['activeUpgradeDiscount'] ?? 0.0).toDouble();
    _upgradeDiscountDaysLeft = gameState['upgradeDiscountDaysLeft'] ?? 0;
    _activeVolatilityMultiplier = (gameState['activeVolatilityMultiplier'] ?? 1.0).toDouble();
    _volatilityMultiplierDaysLeft = gameState['volatilityMultiplierDaysLeft'] ?? 0;
    _activePositionLimit = gameState['activePositionLimit'] ?? 0;
    _positionLimitDaysLeft = gameState['positionLimitDaysLeft'] ?? 0;
    _signalJammerActive = gameState['signalJammerActive'] ?? false;
    _signalJammerDaysLeft = gameState['signalJammerDaysLeft'] ?? 0;
    _analystPrecision = (gameState['analystPrecision'] ?? 0.5).toDouble();

    // Prestige state
    _prestigeLevel = prestigeState['prestigeLevel'] ?? 0;
    _lifetimeEarnings = prestigeState['lifetimeEarnings'] != null
        ? BigNumber.fromJson(prestigeState['lifetimeEarnings'])
        : BigNumber.zero;
    _totalPrestigePoints = prestigeState['totalPrestigePoints'] ?? 0;
    _startingCashBonus = (prestigeState['startingCashBonus'] ?? 0.0).toDouble();

    // Save format converter: v1 (flat prestige) → v2 (talent tree)
    final saveVersion = prestigeState['version'] ?? 1;
    _purchasedTalentNodes.clear();
    if (saveVersion == 1) {
      // OLD FORMAT: refund all spent PP, start with clean tree
      final oldPurchased = prestigeState['purchasedPrestigeUpgrades'] as List<dynamic>? ?? [];
      int refund = 0;
      for (final id in oldPurchased) {
        final old = getPrestigeUpgradeById(id as String);
        if (old != null) refund += old.cost;
      }
      _prestigePoints = (prestigeState['prestigePoints'] ?? 0) + refund;
    } else {
      // V2 FORMAT: load talent nodes normally
      _prestigePoints = prestigeState['prestigePoints'] ?? 0;
      final nodes = prestigeState['purchasedTalentNodes'] as List<dynamic>? ?? [];
      // Migrate old sector node IDs to new canonical IDs
      const sectorIdMigration = {
        'technology': 'tech',
        'consumerGoods': 'consumer',
        'realEstate': 'realestate',
        'telecommunications': 'telecom',
      };
      for (final raw in nodes) {
        var id = raw as String;
        for (final entry in sectorIdMigration.entries) {
          if (id.startsWith('${entry.key}_')) {
            id = id.replaceFirst(entry.key, entry.value);
            break;
          }
        }
        _purchasedTalentNodes.add(id);
      }
      _blockBadEventsUsed = prestigeState['blockBadEventsUsed'] ?? 0;
      _livesRemaining = prestigeState['livesRemaining'] ?? 0;
      _secondWindDaysLeft = prestigeState['secondWindDaysLeft'] ?? 0;
      _quotaStreak = prestigeState['quotaStreak'] ?? 0;
      _consecutiveSkips = prestigeState['consecutiveSkips'] ?? 0;
      _allQuotasEarly = prestigeState['allQuotasEarly'] ?? true;
      _overtimeDaysLeft = prestigeState['overtimeDaysLeft'] ?? 0;
      _inOvertime = prestigeState['inOvertime'] ?? false;
    }

    // Legacy prestige effects (still read by gameplay code)
    _upgradeRerollsPerDay = prestigeState['upgradeRerollsPerDay'] ?? 0;
    _guaranteedRareFirst = prestigeState['guaranteedRareFirst'] ?? false;
    _usedGuaranteedRare = prestigeState['usedGuaranteedRare'] ?? false;
    _quotaFailFreebies = prestigeState['quotaFailFreebies'] ?? 0;
    _keepCashOnFailPercent = (prestigeState['keepCashOnFailPercent'] ?? 0.0).toDouble();
    _extraUpgradeChoices = prestigeState['extraUpgradeChoices'] ?? 0;
    _shortBanImmunity = prestigeState['shortBanImmunity'] ?? false;
    _startingUpgrades = prestigeState['startingUpgrades'] ?? 0;
    _prestigePointMultiplier = (prestigeState['prestigePointMultiplier'] ?? 0.0).toDouble();
    _cashInterestRate = (prestigeState['cashInterestRate'] ?? 0.0).toDouble();
    _shopRarityBoost = (prestigeState['shopRarityBoost'] ?? 0.0).toDouble();
    _freeRollsPerDay = prestigeState['freeRollsPerDay'] ?? 1;
    _sectorAmplifier = (prestigeState['sectorAmplifier'] ?? 0.0).toDouble();

    // Robot prestige
    _maxRobotSlots = prestigeState['maxRobotSlots'] ?? 0;
    _robotSpeedBonus = (prestigeState['robotSpeedBonus'] ?? 0.0).toDouble();
    // Per-robot upgrades are stored in purchasedTalentNodes (loaded above)

    // Validate robot count matches slots (trim excess from corrupted saves)
    while (_robots.length > _maxRobotSlots) {
      _robots.removeLast();
    }

    // Trading strategy bonuses
    _consecutiveWins = prestigeState['consecutiveWins'] ?? 0;
    _momentumBonus = (prestigeState['momentumBonus'] ?? 0.0).toDouble();
    _momentumStreak = prestigeState['momentumStreak'] ?? 0;
    _contrarianBonus = (prestigeState['contrarianBonus'] ?? 0.0).toDouble();
    _contrarianThreshold = (prestigeState['contrarianThreshold'] ?? 0.0).toDouble();
    _dayTradeBonus = (prestigeState['dayTradeBonus'] ?? 0.0).toDouble();
    _lossRecoveryPercent = (prestigeState['lossRecoveryPercent'] ?? 0.0).toDouble();

    // Stop loss / Take profit
    _hasStopLoss = prestigeState['hasStopLoss'] ?? false;
    _hasTakeProfit = prestigeState['hasTakeProfit'] ?? false;
    _stopLossPercent = (prestigeState['stopLossPercent'] ?? 0.10).toDouble();
    _takeProfitPercent = (prestigeState['takeProfitPercent'] ?? 0.20).toDouble();
    _stopLossEnabled = prestigeState['stopLossEnabled'] ?? false;
    _takeProfitEnabled = prestigeState['takeProfitEnabled'] ?? false;
    _trailingStopEnabled = prestigeState['trailingStopEnabled'] ?? false;
    _priceAlertThreshold = (prestigeState['priceAlertThreshold'] ?? 10.0).toDouble();
    _priceAlertCooldown = _priceAlertThreshold * 1.5;

    // FinTok state
    final finTokState = json['finTokState'] as Map<String, dynamic>? ?? {};
    _influencers.clear();
    if (finTokState['influencers'] != null) {
      for (final i in finTokState['influencers'] as List) {
        _influencers.add(Influencer.fromJson(i as Map<String, dynamic>));
      }
    }
    _tips.clear();
    _scheduledTips.clear();
    if (finTokState['tips'] != null) {
      for (final t in finTokState['tips'] as List) {
        _tips.add(InfluencerTip.fromJson(t as Map<String, dynamic>));
      }
    }
    _usedInfluencerTemplateIds.clear();
    if (finTokState['usedInfluencerTemplateIds'] != null) {
      _usedInfluencerTemplateIds.addAll(
        (finTokState['usedInfluencerTemplateIds'] as List).cast<String>(),
      );
    }
    _followedInfluencerIds.clear();
    if (finTokState['followedInfluencerIds'] != null) {
      _followedInfluencerIds.addAll(
        (finTokState['followedInfluencerIds'] as List).cast<String>(),
      );
    }

    // Informant state
    if (json['informantState'] != null) {
      _informantState = InformantState.fromJson(json['informantState'] as Map<String, dynamic>);
    } else {
      _informantState = InformantState();
    }
    _showInformantPopup = false;

    // Challenge state
    if (json['challengeState'] != null) {
      _challengeState = DailyChallengeState.fromJson(json['challengeState'] as Map<String, dynamic>);
    } else {
      _challengeState = DailyChallengeState();
    }

    // Casual features state
    final casualState = json['casualState'] as Map<String, dynamic>? ?? {};
    _bestNetWorth = casualState['bestNetWorth'] != null
        ? BigNumber.fromJson(casualState['bestNetWorth'])
        : BigNumber.zero;
    _bestDayProfit = (casualState['bestDayProfit'] ?? 0.0).toDouble();
    _bestSingleTrade = (casualState['bestSingleTrade'] ?? 0.0).toDouble();
    _bestWinStreak = casualState['bestWinStreak'] ?? 0;
    _mostDaysSurvived = casualState['mostDaysSurvived'] ?? 0;
    _reachedMilestones.clear();
    final milestones = casualState['reachedMilestones'] as List<dynamic>? ?? [];
    _reachedMilestones.addAll(milestones.cast<int>());
    _favoriteStockIds.clear();
    final favorites = casualState['favoriteStockIds'] as List<dynamic>? ?? [];
    _favoriteStockIds.addAll(favorites.cast<String>());
    _leaderboard.clear();
    final lb = casualState['leaderboard'] as List<dynamic>? ?? [];
    for (final entry in lb) {
      if (entry is Map<String, dynamic>) {
        _leaderboard.add(Map<String, dynamic>.from(entry));
      }
    }

    // Reset view state
    _currentView = ViewType.dashboard;
    _marketSubTab = 0;
    _selectedSectorId = null;
    _selectedCompanyId = null;
    _isEndOfDay = false;
    _showUpgradeSelection = false;
    _showNewsPopup = false;
    _showMidDayNewsPopup = false;
    _showPrestigeShop = false;

    notifyListeners();
  }

  /// Helper to create Position from JSON
  Position _positionFromJson(Map<String, dynamic> json) {
    final companyId = json['companyId'] as String;
    final company = allCompanies.firstWhere(
      (c) => c.id == companyId,
      orElse: () => allCompanies.first,
    );

    final position = Position(
      company: company,
      type: json['type'] == 1 ? PositionType.short : PositionType.long,
    );

    // Set the values directly
    position.shares = (json['shares'] ?? 0).toDouble();
    position.averageCost = json['averageCost'] != null
        ? BigNumber.fromJson(json['averageCost'])
        : BigNumber.zero;
    position.totalInvested = json['totalInvested'] != null
        ? BigNumber.fromJson(json['totalInvested'])
        : BigNumber.zero;
    position.totalFeesPaid = json['totalFeesPaid'] != null
        ? BigNumber.fromJson(json['totalFeesPaid'])
        : BigNumber.zero;

    return position;
  }

  /// Helper to create TradeRecord from JSON
  TradeRecord _tradeRecordFromJson(Map<String, dynamic> json) {
    final companyId = json['companyId'] as String;
    final company = allCompanies.firstWhere(
      (c) => c.id == companyId,
      orElse: () => allCompanies.first,
    );

    return TradeRecord(
      id: json['id']?.toString() ?? '0',
      company: company,
      type: TradeType.values[json['type'] ?? 0],
      shares: (json['shares'] ?? 0).toDouble(),
      pricePerShare: json['pricePerShare'] != null
          ? BigNumber.fromJson(json['pricePerShare'])
          : BigNumber.zero,
      totalValue: json['totalValue'] != null
          ? BigNumber.fromJson(json['totalValue'])
          : BigNumber.zero,
      fees: json['fees'] != null
          ? BigNumber.fromJson(json['fees'])
          : BigNumber.zero,
      realizedPnL: json['realizedPnL'] != null
          ? BigNumber.fromJson(json['realizedPnL'])
          : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      dayNumber: json['dayNumber'] ?? 1,
    );
  }

  // === DEBUG METHODS (only called from debug panel) ===

  void debugGiveCash(double amount) {
    _cash = _cash + BigNumber(amount);
    notifyListeners();
  }

  void debugGivePrestigePoints(int amount) {
    _prestigePoints += amount;
    notifyListeners();
  }

  void debugAdvanceDays(int days) {
    for (int i = 0; i < days; i++) {
      _currentDay++;
    }
    notifyListeners();
  }

  void debugUnlockAllCompanies() {
    for (final company in allCompanies) {
      _unlockedCompanyIds.add(company.id);
    }
    notifyListeners();
  }

  void debugSetQuotaProgress(double percent) {
    _quotaProgress = effectiveQuotaTarget.multiplyByDouble(percent / 100);
    notifyListeners();
  }

  void debugMaxRobots() {
    for (final robot in _robots) {
      robot.precisionLevel = 9;
      robot.efficiencyLevel = 9;
      robot.frequencyLevel = 9;
      robot.riskMgmtLevel = 9;
    }
    notifyListeners();
  }

  /// Simulate a trade and return itemized breakdown of all bonuses applied.
  /// [sectorId] is the sector to simulate in, [basePnL] is the raw profit/loss.
  List<(String label, double value)> debugSimulateTrade(String sectorId, double basePnL) {
    final breakdown = <(String, double)>[];
    double pnl = basePnL;
    breakdown.add(('Base P&L', pnl));

    final sector = getSectorById(sectorId);

    // All profit bonuses are additive on the base PnL
    if (pnl > 0) {
      double totalBonus = 0;

      // Sector Edge (daily upgrade)
      if (sector != null) {
        final boost = getSectorEdgeBoost(sector.type);
        if (boost > 0) {
          final bonus = basePnL * boost;
          totalBonus += bonus;
          breakdown.add(('Upgrade: Sector Edge (${(boost * 100).toStringAsFixed(0)}%)', bonus));
        }
      }

      // Talent tree: profit multiplier
      if (_profitMultiplier > 0) {
        final bonus = basePnL * _profitMultiplier;
        totalBonus += bonus;
        breakdown.add(('Talent: Profit Mult (${(_profitMultiplier * 100).toStringAsFixed(0)}%)', bonus));
      }

      // Talent tree: sector profit boost
      final sectorBoost = _sectorProfitBonuses[sectorId] ?? 0.0;
      if (sectorBoost > 0) {
        final bonus = basePnL * sectorBoost;
        totalBonus += bonus;
        breakdown.add(('Talent: Sector Profit (${(sectorBoost * 100).toStringAsFixed(0)}%)', bonus));
      }

      pnl += totalBonus;
    }

    // Loss reduction (talent general + talent sector + daily shield), capped at 50%
    if (pnl < 0) {
      double totalReduction = _lossReduction;
      final talentSectorShield = _sectorLossShields[sectorId] ?? 0.0;
      totalReduction += talentSectorShield;
      if (sector != null) {
        totalReduction += getSectorShieldReduction(sector.type);
      }
      if (totalReduction > 0.50) totalReduction = 0.50;
      if (totalReduction > 0) {
        final reduction = pnl * -totalReduction;
        pnl += reduction;
        breakdown.add(('Loss Reduction (${(totalReduction * 100).toStringAsFixed(0)}%, cap 50%)', reduction));
      }
    }

    // Insurance
    if (pnl < 0 && _metaInsurance > 0) {
      final reduction = pnl * -_metaInsurance;
      pnl += reduction;
      breakdown.add(('Insurance (${(_metaInsurance * 100).toStringAsFixed(0)}%)', reduction));
    }

    // Max loss per trade
    if (pnl < 0 && _maxLossPerTrade < 1.0) {
      final maxLoss = -basePnL.abs() * _maxLossPerTrade;
      if (pnl < maxLoss) {
        final recovery = maxLoss - pnl;
        pnl = maxLoss;
        breakdown.add(('Max Loss Cap (${(_maxLossPerTrade * 100).toStringAsFixed(0)}%)', recovery));
      }
    }

    // Sector passive income
    final passiveIncome = _sectorPassiveIncomes[sectorId] ?? 0.0;
    if (passiveIncome > 0) {
      breakdown.add(('Passive Income/day', passiveIncome));
    }

    // Capstone info
    if (_sectorCapstones.contains(sectorId)) {
      breakdown.add(('Capstone 2x', 0));
    }

    breakdown.add(('═ Final P&L', pnl));
    return breakdown;
  }

  /// Debug: give the player a specific upgrade with a specific sector.
  /// [upgradeId] is the base template id (e.g. 'sector_edge_legendary').
  /// [sectorType] is the sector to assign (for template upgrades).
  void debugGiveUpgrade(String upgradeId, {SectorType? sectorType}) {
    final base = getUpgradeById(upgradeId);
    if (base == null) return;
    final upgrade = sectorType != null ? base.withSector(sectorType) : base;
    _acquireUpgrade(upgrade);
    notifyListeners();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}

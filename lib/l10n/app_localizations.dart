import 'package:flutter/material.dart';

/// Simple localization system
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
  ];

  /// Get translation
  String get(String key) {
    return _translations[locale.languageCode]?[key] ??
        _translations['en']?[key] ??
        key;
  }

  // Convenience getters for common strings
  String get settings => get('settings');
  String get theme => get('theme');
  String get language => get('language');
  String get darkThemes => get('dark_themes');
  String get lightThemes => get('light_themes');
  String get save => get('save');
  String get load => get('load');
  String get exportSave => get('export_save');
  String get importSave => get('import_save');
  String get exportSuccess => get('export_success');
  String get importSuccess => get('import_success');
  String get importError => get('import_error');
  String get cancel => get('cancel');
  String get confirm => get('confirm');
  String get warning => get('warning');
  String get close => get('close');
  String get back => get('back');

  // Game strings
  String get day => get('day');
  String get year => get('year');
  String get cash => get('cash');
  String get portfolio => get('portfolio');
  String get netWorth => get('net_worth');
  String get quota => get('quota');
  String get quotaTarget => get('quota_target');
  String get quotaProgress => get('quota_progress');
  String get daysLeft => get('days_left');
  String get buy => get('buy');
  String get sell => get('sell');
  String get sectors => get('sectors');
  String get stocks => get('stocks');
  String get trading => get('trading');
  String get positions => get('positions');
  String get positionsFull => get('positions_full');
  String get market => get('market');
  String get robots => get('robots');
  String get robotsBay => get('robots_bay');
  String get robotFund => get('robot_fund');
  String get robotWithdraw => get('robot_withdraw');
  String get robotCollect => get('robot_collect');
  String get robotUpgrade => get('robot_upgrade');
  String get robotBudget => get('robot_budget');
  String get robotWallet => get('robot_wallet');
  String get robotPrecision => get('robot_precision');
  String get robotEfficiency => get('robot_efficiency');
  String get robotFrequency => get('robot_frequency');
  String get robotRiskMgmt => get('robot_risk_mgmt');
  String get robotCapacity => get('robot_capacity');
  String get robotTotalEarnings => get('robot_total_earnings');
  String get robotNoSlots => get('robot_no_slots');
  String get robotBudgetDepleted => get('robot_budget_depleted');
  String get robotActive => get('robot_active');
  String get dashboard => get('dashboard');
  String get upgrades => get('upgrades');
  String get chooseUpgrade => get('choose_upgrade');
  String get skip => get('skip');
  String get reroll => get('reroll');
  String get prestige => get('prestige');
  String get prestigePoints => get('prestige_points');
  String get newRun => get('new_run');
  String get gameOver => get('game_over');
  String get quotaFailed => get('quota_failed');

  // Additional game strings
  String get pnl => get('pnl');
  String get winRate => get('win_rate');
  String get totalTrades => get('total_trades');
  String get marketNews => get('market_news');
  String get continueText => get('continue');
  String get longPosition => get('long');
  String get shortPosition => get('short');
  String get cover => get('cover');
  String get shares => get('shares');
  String get price => get('price');
  String get total => get('total');
  String get fees => get('fees');
  String get value => get('value');
  String get change => get('change');
  String get volume => get('volume');
  String get marketCap => get('market_cap');
  String get high => get('high');
  String get low => get('low');
  String get open => get('open');
  String get analyst => get('analyst');
  String get news => get('news');
  String get allSectors => get('all_sectors');
  String get performance => get('performance');
  String get progress => get('progress');
  String get startGame => get('start_game');
  String get pause => get('pause');
  String get play => get('play');

  // Trading view strings
  String get realizedPnL => get('realized_pnl');
  String get expenses => get('expenses');
  String get openingCosts => get('opening_costs');
  String get robotCosts => get('robot_costs');
  String get quotaDeducted => get('quota_deducted');
  String get afterQuota => get('after_quota');
  String get topGainer => get('top_gainer');
  String get topLoser => get('top_loser');
  String get selectStockToTrade => get('select_stock_to_trade');
  String get stockNotFound => get('stock_not_found');
  String get placeOrder => get('place_order');
  String get subtotal => get('subtotal');
  String get yourPositions => get('your_positions');
  String get viewAll => get('view_all');
  String get insufficientFunds => get('insufficient_funds');
  String get insufficientFundsForShort => get('insufficient_funds_for_short');
  String get max => get('max');
  String get long => get('long');
  String get short => get('short');
  String get avgCostLabel => get('avg_cost');
  String get currentPrice => get('current_price');
  String get marketValue => get('market_value');
  String get unrealizedPnL => get('unrealized_pnl');
  String get noPositions => get('no_positions');
  String get longPositions => get('long_positions');
  String get shortPositions => get('short_positions');
  String get totalValue => get('total_value');
  String get holdings => get('holdings');
  String get profit => get('profit');
  String get loss => get('loss');
  String get trades => get('trades');
  String get closed => get('closed');
  String get nextDayBtn => get('next_day');

  // News popup strings
  String get startTrading => get('start_trading');
  String get breakingNewsUpdate => get('breaking_news_update');
  String get newsUpdateHint => get('news_update_hint');
  String get midDayUpdate => get('mid_day_update');
  String get highImpact => get('high_impact');
  String get mediumImpact => get('medium_impact');
  String get lowImpact => get('low_impact');
  String get companySpecific => get('company_specific');
  String get sectorWide => get('sector_wide');
  String get contradictsEarlierReport => get('contradicts_earlier_report');
  String get continueTrading => get('continue_trading');

  // Mid-day contradiction news prefixes
  String get middayPrefixUpdate => get('midday_prefix_update');
  String get middayPrefixCorrection => get('midday_prefix_correction');
  String get middayPrefixBreaking => get('midday_prefix_breaking');
  String get middayPrefixReversal => get('midday_prefix_reversal');
  String get middayPrefixRecovery => get('midday_prefix_recovery');

  // Dashboard strings
  String get sectorAllocation => get('sector_allocation');
  String get longShort => get('long_short');
  String get positionStatistics => get('position_statistics');
  String get profitable => get('profitable');
  String get losing => get('losing');
  String get bestPosition => get('best_position');
  String get worstPosition => get('worst_position');
  String get tradingPerformance => get('trading_performance');
  String get winStreak => get('win_streak');
  String get loseStreak => get('lose_streak');
  String get tradesToday => get('trades_today');
  String get bestTradeEver => get('best_trade_ever');
  String get worstTradeEver => get('worst_trade_ever');
  String get riskMetrics => get('risk_metrics');
  String get diversification => get('diversification');
  String get riskLevel => get('risk_level');
  String get concentration => get('concentration');
  String get largestPosition => get('largest_position');
  String get capitalAllocation => get('capital_allocation');
  String get invested => get('invested');
  String get quotaMet => get('quota_met');
  String get recentTrades => get('recent_trades');
  String get noTradesYet => get('no_trades_yet');
  String get newsAffectingPositions => get('news_affecting_positions');
  String get noRelevantNews => get('no_relevant_news');
  String get acquiredUpgrades => get('acquired_upgrades');
  String get earned => get('earned');
  String get bonus => get('bonus');
  String get need => get('need');

  // Info panel strings
  String get information => get('information');
  String get marketOverview => get('market_overview');
  String get sectorDetails => get('sector_details');
  String get companyInfo => get('company_info');
  String get portfolioAnalysis => get('portfolio_analysis');
  String get recentNews => get('recent_news');
  String get noNewsYet => get('no_news_yet');

  // Active effects
  String get effectActive => get('effect_active');
  String get effectReducedFees => get('effect_reduced_fees');
  String get effectIncreasedFees => get('effect_increased_fees');
  String effectFeeDiscount(String percent) => get('effect_fee_discount').replaceAll('{percent}', percent);
  String effectFeeSurcharge(String percent) => get('effect_fee_surcharge').replaceAll('{percent}', percent);
  String get effectShortBan => get('effect_short_ban');
  String get effectShortBanDesc => get('effect_short_ban_desc');
  String get effectUpgradeSale => get('effect_upgrade_sale');
  String effectUpgradeSaleDesc(String percent) => get('effect_upgrade_sale_desc').replaceAll('{percent}', percent);
  String get effectCircuitBreaker => get('effect_circuit_breaker');
  String get effectCircuitBreakerDesc => get('effect_circuit_breaker_desc');
  String get effectHighVolatility => get('effect_high_volatility');
  String get effectLowVolatility => get('effect_low_volatility');
  String effectVolatilityDesc(String percent, String direction) => get('effect_volatility_desc').replaceAll('{percent}', percent).replaceAll('{direction}', direction);
  String get effectVolatilityMore => get('effect_volatility_more');
  String get effectVolatilityLess => get('effect_volatility_less');
  String get effectPositionLimit => get('effect_position_limit');
  String effectPositionLimitDesc(String max) => get('effect_position_limit_desc').replaceAll('{max}', max);
  String get effectSignalJammer => get('effect_signal_jammer');
  String get effectSignalJammerDesc => get('effect_signal_jammer_desc');
  String effectDaysRemaining(String days) => get('effect_days_remaining').replaceAll('{days}', days);
  String get effectToday => get('effect_today');
  String effectDayRemaining(String days) => get('effect_day_remaining').replaceAll('{days}', days);

  String get marketHealth => get('market_health');
  String get fearGreed => get('fear_greed');
  String get marketBreadthLabel => get('market_breadth');
  String get volatility => get('volatility');
  String get sectorLeaders => get('sector_leaders');
  String get best => get('best');
  String get worst => get('worst');
  String get selectSectorToSeeDetails => get('select_sector_to_see_details');
  String get sectorNews => get('sector_news');
  String get sectorOverview => get('sector_overview');
  String get name => get('name');
  String get type => get('type');
  String get region => get('region');
  String get characteristics => get('characteristics');
  String get marketCorrelation => get('market_correlation');
  String get fedSensitivity => get('fed_sensitivity');
  String get yourHoldings => get('your_holdings');
  String get totalShares => get('total_shares');
  String get selectStockToSeeDetails => get('select_stock_to_see_details');
  String get ticker => get('ticker');
  String get sector => get('sector');
  String get peRatio => get('pe_ratio');
  String get tradingStats => get('trading_stats');
  String get dayOpen => get('day_open');
  String get dayHigh => get('day_high');
  String get dayLow => get('day_low');
  String get analystRatings => get('analyst_ratings');
  String get technicalAnalysis => get('technical_analysis');
  String get historicalPerformance => get('historical_performance');
  String get weekRange52 => get('week_range_52');
  String get fromHigh => get('from_high');
  String get fromLow => get('from_low');
  String get blueChip => get('blue_chip');
  String get pennyStock => get('penny_stock');
  String get yes => get('yes');
  String get no => get('no');
  String get yourPosition => get('your_position');
  String get recentActivity => get('recent_activity');
  String get portfolioSummary => get('portfolio_summary');
  String get totalPositions => get('total_positions');
  String get portfolioValueLabel => get('portfolio_value');
  String get bestPerformer => get('best_performer');
  String get stock => get('stock');
  String get noAnalystData => get('no_analyst_data');
  String get consensus => get('consensus');
  String get analysts => get('analysts');
  String get hold => get('hold');
  String get priceTarget => get('price_target');
  String get ptHigh => get('pt_high');
  String get ptLow => get('pt_low');
  String get upside => get('upside');
  String get rsi14 => get('rsi_14');
  String get oversold => get('oversold');
  String get overbought => get('overbought');
  String get neutral => get('neutral');
  String get ma50 => get('ma_50');
  String get ma200 => get('ma_200');
  String get volumeRatio => get('volume_ratio');
  String get daysInRegime => get('days_in_regime');
  String get strength => get('strength');
  String get marketIndicators => get('market_indicators');
  String get advancing => get('advancing');
  String get declining => get('declining');
  String get unchanged => get('unchanged');
  String get newHighs => get('new_highs');
  String get newLows => get('new_lows');
  String get leadingSector => get('leading_sector');
  String get laggingSector => get('lagging_sector');
  String get portfolioBreakdown => get('portfolio_breakdown');
  String get distinctSectors => get('distinct_sectors');
  String get avgPositionSize => get('avg_position_size');
  String get portfolioVol => get('portfolio_vol');
  String get largestValue => get('largest_value');
  String get positionTypes => get('position_types');
  String get unknown => get('unknown');

  // Achievements
  String get achievements => get('achievements');
  String get completed => get('completed');
  String get unclaimedRewards => get('unclaimed_rewards');
  String get tapToClaim => get('tap_to_claim');
  String get rewardsClaimed => get('rewards_claimed');
  String get ok => get('ok');
  String get noAchievementsYet => get('no_achievements_yet');
  String get completedOn => get('completed_on');
  String get achievementCategoryTrading => get('achievement_category_trading');
  String get achievementCategoryProfit => get('achievement_category_profit');
  String get achievementCategoryPortfolio => get('achievement_category_portfolio');
  String get achievementCategoryMilestone => get('achievement_category_milestone');
  String get achievementCategoryRisk => get('achievement_category_risk');
  String get achievementCategoryMarket => get('achievement_category_market');
  String get achievementCategorySecret => get('achievement_category_secret');

  // Tutorial strings
  String get disclaimer => get('disclaimer');
  String get welcomeToKandl => get('welcome_to_kandl');
  String get skipTutorial => get('skip_tutorial');
  String get startPlaying => get('start_playing');
  String get importantWarning => get('important_warning');
  String get tradersLoseMoney => get('traders_lose_money');
  String get disclaimerGambling => get('disclaimer_gambling');
  String get disclaimerEducational => get('disclaimer_educational');
  String get disclaimerNotAdvice => get('disclaimer_not_advice');
  String get disclaimerRemember => get('disclaimer_remember');
  String get gameDescription => get('game_description');
  String get featureTrading => get('feature_trading');
  String get featureTradingDesc => get('feature_trading_desc');
  String get featureQuota => get('feature_quota');
  String get featureQuotaDesc => get('feature_quota_desc');
  String get featureUpgrades => get('feature_upgrades');
  String get featureUpgradesDesc => get('feature_upgrades_desc');
  String get featureAchievements => get('feature_achievements');
  String get featureAchievementsDesc => get('feature_achievements_desc');
  String get tutorialNext => get('tutorial_next');
  String get tutorialGotIt => get('tutorial_got_it');
  String get tutorialSkip => get('tutorial_skip');
  String get restartTutorial => get('restart_tutorial');

  // Tutorial step titles and descriptions
  String get tutorialDashboardTitle => get('tutorial_dashboard_title');
  String get tutorialDashboardDesc => get('tutorial_dashboard_desc');
  String get tutorialMetricsTitle => get('tutorial_metrics_title');
  String get tutorialMetricsDesc => get('tutorial_metrics_desc');
  String get tutorialStatsTitle => get('tutorial_stats_title');
  String get tutorialStatsDesc => get('tutorial_stats_desc');

  // Dashboard widget tutorials
  String get tutorialPositionStatisticsTitle => get('tutorial_position_statistics_title');
  String get tutorialPositionStatisticsDesc => get('tutorial_position_statistics_desc');
  String get tutorialTradingPerformanceTitle => get('tutorial_trading_performance_title');
  String get tutorialTradingPerformanceDesc => get('tutorial_trading_performance_desc');
  String get tutorialRiskMetricsTitle => get('tutorial_risk_metrics_title');
  String get tutorialRiskMetricsDesc => get('tutorial_risk_metrics_desc');
  String get tutorialMilestoneProgressTitle => get('tutorial_milestone_progress_title');
  String get tutorialMilestoneProgressDesc => get('tutorial_milestone_progress_desc');
  String get tutorialChallengesPanelTitle => get('tutorial_challenges_panel_title');
  String get tutorialChallengesPanelDesc => get('tutorial_challenges_panel_desc');
  String get tutorialRecentTradesTitle => get('tutorial_recent_trades_title');
  String get tutorialRecentTradesDesc => get('tutorial_recent_trades_desc');
  String get tutorialPositionNewsTitle => get('tutorial_position_news_title');
  String get tutorialPositionNewsDesc => get('tutorial_position_news_desc');

  String get tutorialSectorsTitle => get('tutorial_sectors_title');
  String get tutorialSectorsDesc => get('tutorial_sectors_desc');
  String get tutorialSectorsIntroTitle => get('tutorial_sectors_intro_title');
  String get tutorialSectorsIntroDesc => get('tutorial_sectors_intro_desc');
  String get tutorialStocksTitle => get('tutorial_stocks_title');
  String get tutorialStocksDesc => get('tutorial_stocks_desc');
  String get tutorialStocksIntroTitle => get('tutorial_stocks_intro_title');
  String get tutorialStocksIntroDesc => get('tutorial_stocks_intro_desc');
  String get tutorialTradingTitle => get('tutorial_trading_title');
  String get tutorialTradingDesc => get('tutorial_trading_desc');
  String get tutorialTradingIntroTitle => get('tutorial_trading_intro_title');
  String get tutorialTradingIntroDesc => get('tutorial_trading_intro_desc');
  String get tutorialFirstBuyTitle => get('tutorial_first_buy_title');
  String get tutorialFirstBuyDesc => get('tutorial_first_buy_desc');
  String get tutorialPositionsTitle => get('tutorial_positions_title');
  String get tutorialPositionsDesc => get('tutorial_positions_desc');
  String get tutorialPositionsIntroTitle => get('tutorial_positions_intro_title');
  String get tutorialPositionsIntroDesc => get('tutorial_positions_intro_desc');
  String get tutorialUpgradesTitle => get('tutorial_upgrades_title');
  String get tutorialUpgradesDesc => get('tutorial_upgrades_desc');
  String get tutorialPrestigeTitle => get('tutorial_prestige_title');
  String get tutorialPrestigeDesc => get('tutorial_prestige_desc');
  String get tutorialAchievementsTitle => get('tutorial_achievements_title');
  String get tutorialAchievementsDesc => get('tutorial_achievements_desc');
  String get tutorialFintokTitle => get('tutorial_fintok_title');
  String get tutorialFintokDesc => get('tutorial_fintok_desc');

  // FinTok UI strings
  String get fintokActive => get('fintok_active');
  String get fintokNoTips => get('fintok_no_tips');
  String get fintokNoInfluencers => get('fintok_no_influencers');
  String get fintokAppearSoon => get('fintok_appear_soon');
  String get fintokFollowers => get('fintok_followers');
  String get fintokTipsGiven => get('fintok_tips_given');
  String get fintokAccuracy => get('fintok_accuracy');
  String get fintokReputation => get('fintok_reputation');
  String get fintokUnknown => get('fintok_unknown');
  String get fintokFollow => get('fintok_follow');
  String get fintokUnfollow => get('fintok_unfollow');
  String get fintokFollowing => get('fintok_following');
  String get fintokBuy => get('fintok_buy');
  String get fintokSell => get('fintok_sell');
  String get fintokAccurate => get('fintok_accurate');
  String get fintokWrong => get('fintok_wrong');
  String get fintokViral => get('fintok_viral');
  String get fintokExcellent => get('fintok_excellent');
  String get fintokGood => get('fintok_good');
  String get fintokAverage => get('fintok_average');
  String get fintokPoor => get('fintok_poor');
  String get fintokTerrible => get('fintok_terrible');
  String get fintokJoined => get('fintok_joined');
  String get fintokLeft => get('fintok_left');

  // Stock signals
  String get signalOnSale => get('signal_on_sale');
  String get signalGoodDeal => get('signal_good_deal');
  String get signalRising => get('signal_rising');
  String get signalFalling => get('signal_falling');
  String get signalPricey => get('signal_pricey');
  String get signalOverheated => get('signal_overheated');

  String get tutorialInformantTitle => get('tutorial_informant_title');
  String get tutorialInformantDesc => get('tutorial_informant_desc');

  // Sector names
  String get sectorTech => get('sector_tech');
  String get sectorHealthcare => get('sector_healthcare');
  String get sectorFinance => get('sector_finance');
  String get sectorEnergy => get('sector_energy');
  String get sectorConsumer => get('sector_consumer');
  String get sectorIndustrial => get('sector_industrial');
  String get sectorRealEstate => get('sector_realestate');
  String get sectorTelecom => get('sector_telecom');
  String get sectorGaming => get('sector_gaming');
  String get sectorCrypto => get('sector_crypto');
  String get sectorAerospace => get('sector_aerospace');
  String get sectorMaterials => get('sector_materials');
  String get sectorUtilities => get('sector_utilities');
  String get sectorCommodities => get('sector_commodities');
  String get sectorForex => get('sector_forex');
  String get sectorIndices => get('sector_indices');

  // Sector descriptions
  String get sectorDescTech => get('sector_desc_tech');
  String get sectorDescHealthcare => get('sector_desc_healthcare');
  String get sectorDescFinance => get('sector_desc_finance');
  String get sectorDescEnergy => get('sector_desc_energy');
  String get sectorDescConsumer => get('sector_desc_consumer');
  String get sectorDescIndustrial => get('sector_desc_industrial');
  String get sectorDescRealEstate => get('sector_desc_realestate');
  String get sectorDescTelecom => get('sector_desc_telecom');
  String get sectorDescGaming => get('sector_desc_gaming');
  String get sectorDescCrypto => get('sector_desc_crypto');
  String get sectorDescAerospace => get('sector_desc_aerospace');
  String get sectorDescMaterials => get('sector_desc_materials');
  String get sectorDescUtilities => get('sector_desc_utilities');
  String get sectorDescCommodities => get('sector_desc_commodities');
  String get sectorDescForex => get('sector_desc_forex');
  String get sectorDescIndices => get('sector_desc_indices');

  /// Get localized sector name by ID
  String sectorName(String sectorId) {
    switch (sectorId) {
      case 'tech': return sectorTech;
      case 'healthcare': return sectorHealthcare;
      case 'finance': return sectorFinance;
      case 'energy': return sectorEnergy;
      case 'consumer': return sectorConsumer;
      case 'industrial': return sectorIndustrial;
      case 'realestate': return sectorRealEstate;
      case 'telecom': return sectorTelecom;
      case 'gaming': return sectorGaming;
      case 'crypto': return sectorCrypto;
      case 'aerospace': return sectorAerospace;
      case 'materials': return sectorMaterials;
      case 'utilities': return sectorUtilities;
      case 'commodities': return sectorCommodities;
      case 'forex': return sectorForex;
      case 'indices': return sectorIndices;
      default: return sectorId;
    }
  }

  /// Get localized sector description by ID
  String sectorDescription(String sectorId) {
    switch (sectorId) {
      case 'tech': return sectorDescTech;
      case 'healthcare': return sectorDescHealthcare;
      case 'finance': return sectorDescFinance;
      case 'energy': return sectorDescEnergy;
      case 'consumer': return sectorDescConsumer;
      case 'industrial': return sectorDescIndustrial;
      case 'realestate': return sectorDescRealEstate;
      case 'telecom': return sectorDescTelecom;
      case 'gaming': return sectorDescGaming;
      case 'crypto': return sectorDescCrypto;
      case 'aerospace': return sectorDescAerospace;
      case 'materials': return sectorDescMaterials;
      case 'utilities': return sectorDescUtilities;
      case 'commodities': return sectorDescCommodities;
      case 'forex': return sectorDescForex;
      case 'indices': return sectorDescIndices;
      default: return '';
    }
  }

  // Methods with parameters
  String dayNumber(int day) => get('day_number').replaceAll('{day}', day.toString());
  String daysLeftCount(int days) => get('days_left_count').replaceAll('{days}', days.toString());
  String feePercent(String percent) => get('fee_percent').replaceAll('{percent}', percent);
  String buyLongTicker(String ticker) => get('buy_long_ticker').replaceAll('{ticker}', ticker);
  String sellShortTicker(String ticker) => get('sell_short_ticker').replaceAll('{ticker}', ticker);
  String sharesCount(String count) => get('shares_count').replaceAll('{count}', count);
  String avgCost(String cost) => get('avg_cost_value').replaceAll('{cost}', cost);
  String boughtSharesLong(String shares, String ticker) =>
      get('bought_shares_long').replaceAll('{shares}', shares).replaceAll('{ticker}', ticker);
  String shortedShares(String shares, String ticker) =>
      get('shorted_shares').replaceAll('{shares}', shares).replaceAll('{ticker}', ticker);
  String coveredShares(String shares, String ticker) =>
      get('covered_shares').replaceAll('{shares}', shares).replaceAll('{ticker}', ticker);
  String soldShares(String shares, String ticker) =>
      get('sold_shares').replaceAll('{shares}', shares).replaceAll('{ticker}', ticker);
  String get autoOrders => get('auto_orders');
  String get stopLoss => get('stop_loss');
  String get takeProfit => get('take_profit');
  String stopLossDesc(String percent) => get('stop_loss_desc').replaceAll('{percent}', percent);
  String takeProfitDesc(String percent) => get('take_profit_desc').replaceAll('{percent}', percent);
  String get requiresUpgrade => get('requires_upgrade');
  String dayYearHeader(int day, int year) =>
      get('day_year_header').replaceAll('{day}', day.toString()).replaceAll('{year}', year.toString());
  String midDayHeader(int day, int year) =>
      get('mid_day_header').replaceAll('{day}', day.toString()).replaceAll('{year}', year.toString());
  String upgradesCount(int count) => get('upgrades_count').replaceAll('{count}', count.toString());
  String daysLeftLabel(int days) => days == 1
      ? get('days_left_singular').replaceAll('{days}', days.toString())
      : get('days_left_plural').replaceAll('{days}', days.toString());
  String stocksCountRegion(int count, String region) =>
      get('stocks_count_region').replaceAll('{count}', count.toString()).replaceAll('{region}', region);

  // Sorting labels
  String get sortBy => get('sort_by');
  String get avgChange => get('avg_change');

  // Prestige shop strings
  String get prestigeShopTitle => get('prestige_shop_title');
  String get allUpgradesPurchased => get('all_upgrades_purchased');
  String get startNewRun => get('start_new_run');
  String get treeHint => get('tree_hint');
  String get prestigeLevel => get('prestige_level');
  String get totalPointsEarned => get('total_points_earned');
  String get lifetimeEarnings => get('lifetime_earnings');
  String survivedDaysYear(int days, int year) =>
      get('survived_days_year').replaceAll('{days}', days.toString()).replaceAll('{year}', year.toString());
  String pointsSavedForFuture(int points) =>
      get('points_saved_for_future').replaceAll('{points}', points.toString());

  // Upgrade shop UI strings
  String get upgradeShopTitle => get('upgrade_shop_title');
  String get shopSubtitle => get('shop_subtitle');
  String get collection => get('collection');
  String get roll => get('roll');
  String get free => get('free');
  String get rerollAll => get('reroll_all');
  String get pick => get('pick');
  String get dropRates => get('drop_rates');
  String freeRollsRemaining(int count) =>
      get('free_rolls_remaining').replaceAll('{count}', count.toString());
  String get resetsDaily => get('resets_daily');
  String discovered(int owned, int total) =>
      get('discovered').replaceAll('{owned}', owned.toString()).replaceAll('{total}', total.toString());
  String get sectorShields => get('sector_shields');
  String get sectorEdges => get('sector_edges');
  String get sectorInsights => get('sector_insights');
  String get sectorDominances => get('sector_dominances');
  String get winningStreaks => get('winning_streaks');

  // Rarity labels
  String get rarityCommon => get('rarity_common');
  String get rarityUncommon => get('rarity_uncommon');
  String get rarityRare => get('rarity_rare');
  String get rarityEpic => get('rarity_epic');
  String get rarityLegendary => get('rarity_legendary');

  /// Get localized rarity name
  String rarityName(String rarity) => get('rarity_$rarity');

  // Category labels
  String get categoryTrading => get('category_trading');
  String get categoryInformation => get('category_information');
  String get categoryPortfolio => get('category_portfolio');
  String get categoryUnlock => get('category_unlock');
  String get categoryRisk => get('category_risk');
  String get categoryIncome => get('category_income');
  String get categoryTime => get('category_time');
  String get categoryQuota => get('category_quota');

  /// Get localized category name
  String categoryName(String category) => get('category_$category');

  /// Get localized sector name by SectorType enum
  String sectorTypeName(String sectorType) => get('sector_type_$sectorType');

  /// Get localized upgrade name by ID
  String upgradeName(String upgradeId) => get('upgrade_${upgradeId}_name');

  /// Get localized upgrade description by ID
  String upgradeDescription(String upgradeId) => get('upgrade_${upgradeId}_desc');

  /// Get localized news headline by template key
  String newsHeadline(String key, {String? company, String? sector, String? quarter}) {
    String result = get('news_${key}_headline');
    if (company != null) result = result.replaceAll('{company}', company);
    if (sector != null) result = result.replaceAll('{sector}', sector);
    if (quarter != null) result = result.replaceAll('{quarter}', quarter);
    return result;
  }

  /// Get localized news description by template key
  String newsDescription(String key) => get('news_${key}_desc');

  /// Get localized news category label
  String newsCategoryLabel(String category) => get('news_category_$category');

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // Settings
      'settings': 'Settings',
      'game': 'Game',
      'theme': 'Theme',
      'language': 'Language',
      'dark_themes': 'Dark Themes',
      'light_themes': 'Light Themes',
      'display': 'Display',
      'fullscreen': 'Fullscreen',
      'sound': 'Sound Effects',
      'save': 'Save',
      'load': 'Load',
      'export_save': 'Export Save',
      'import_save': 'Import Save',
      'reset_save': 'Reset Game',
      'reset_save_warning': 'This will permanently delete all your progress and start a new game. This cannot be undone!',
      'reset_save_success': 'Game reset successfully!',
      'export_success': 'Save exported successfully!',
      'import_success': 'Save imported successfully!',
      'import_error': 'Error importing save. Invalid file.',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'warning': 'Warning',
      'close': 'Close',
      'back': 'Back',
      // Portfolio & positions
      'close_all_positions': 'Close All Positions',
      'close_all_confirm': 'Are you sure you want to close all {count} positions at market price?',
      'closed_all_positions': 'Closed {count} positions.',
      'close_all': 'Close All',
      // Informant
      'secret_informant': 'Secret Informant',
      'send_away': 'Send Away',
      'purchased': 'Purchased',
      'sentiment_bullish': 'BULLISH',
      'sentiment_bearish': 'BEARISH',
      // Trading
      'bonus_shares': 'Bonus shares',
      'total_shares_label': 'Total shares',

      // Notifications
      'notifications': 'Notifications',
      'new': 'new',
      'mark_all_read': 'Mark all as read',
      'clear_all': 'Clear all',
      'no_notifications': 'No notifications',
      'no_notifications_desc': 'You\'re all caught up!',
      'price_alert': 'Price Alert',
      'breaking_news': 'Breaking News',
      'achievement_unlocked': 'Achievement Unlocked!',
      'warning_alert': 'Warning',
      'bonus_received': 'Bonus Received',
      'special_event': 'Special Event',

      // Achievements
      'achievements': 'Achievements',
      'completed': 'completed',
      'unclaimed_rewards': 'unclaimed rewards',
      'tap_to_claim': 'Tap to claim',
      'rewards_claimed': 'Rewards Claimed!',
      'ok': 'OK',
      'no_achievements_yet': 'No achievements discovered yet',
      'completed_on': 'Completed on',
      'achievement_category_trading': 'Trading',
      'achievement_category_profit': 'Profit',
      'achievement_category_portfolio': 'Portfolio',
      'achievement_category_milestone': 'Milestones',
      'achievement_category_risk': 'Risk',
      'achievement_category_market': 'Market',
      'achievement_category_secret': 'Secret',

      // Game
      'day': 'Day',
      'year': 'Year',
      'cash': 'Cash',
      'portfolio': 'Fortune',
      'net_worth': 'Net Worth',
      'quota': 'Quota',
      'quota_target': 'Objective',
      'quota_progress': 'Quota Progress',
      'days_left': 'days left',
      'buy': 'Buy',
      'sell': 'Sell',
      'sectors': 'Sectors',
      'stocks': 'Stocks',
      'trading': 'Trading',
      'positions': 'Positions',
      'positions_full': 'FULL',
      'market': 'Market',
      'robots': 'Robots',
      'robots_bay': 'Robots Bay',
      'robot_fund': 'Fund',
      'robot_withdraw': 'Withdraw',
      'robot_collect': 'Collect',
      'robot_upgrade': 'Upgrade',
      'robot_budget': 'Budget',
      'robot_wallet': 'Earnings',
      'robot_precision': 'Precision',
      'robot_efficiency': 'Efficiency',
      'robot_frequency': 'Frequency',
      'robot_risk_mgmt': 'Risk Mgmt',
      'robot_capacity': 'Budget Capacity',
      'robot_total_earnings': 'Total Robot Earnings',
      'robot_overview': 'Overview',
      'robot_total_budget': 'Budget Invested',
      'robot_total_wallet': 'Earnings Ready',
      'robot_total_trades': 'Total Trades',
      'robot_upgrade_costs': 'Upgrade Costs',
      'robot_daily_log': 'Daily Performance',
      'robot_no_trades': 'No trades yet.',
      'robot_no_slots': 'No robots yet. Unlock in Prestige Shop!',
      'robot_budget_depleted': 'ran out of budget and deactivated.',
      'robot_active': 'Active',
      'robot_next_trade': 'Next trades',
      'robot_trades_today': 'trades',
      'robot_trade_history': 'Recent trades',
      'dashboard': 'Dashboard',
      'upgrades': 'Upgrades',
      'choose_upgrade': 'Choose Your Upgrade',
      'skip': 'Skip',
      'reroll': 'Reroll',
      'prestige': 'Prestige',
      'prestige_points': 'Prestige Points',
      'new_run': 'New Run',
      'game_over': 'Game Over',
      'quota_failed': 'Run Over',

      // Additional game strings
      'pnl': 'Gains',
      'win_rate': 'Success Rate',
      'total_trades': 'Total Trades',
      'market_news': 'Market News',
      'continue': 'Continue',
      'long': 'Bet Up',
      'short': 'Bet Down',
      'cover': 'Cover',
      'shares': 'Shares',
      'price': 'Price',
      'total': 'Total',
      'fees': 'Fees',
      'value': 'Value',
      'change': 'Change',
      'volume': 'Volume',
      'market_cap': 'Market Cap',
      'high': 'High',
      'low': 'Low',
      'open': 'Open',
      'analyst': 'Analyst',
      'news': 'News',
      'all_sectors': 'All Sectors',
      'performance': 'Performance',
      'progress': 'Progress',
      'start_game': 'Start',
      'pause': 'Pause',
      'play': 'Play',

      // Trading view
      'realized_pnl': 'Realized Gains',
      'expenses': 'Expenses',
      'opening_costs': 'Openings',
      'robot_costs': 'Robots',
      'quota_deducted': 'Quota deducted',
      'after_quota': 'After quota',
      'top_gainer': 'Top Gainer',
      'top_loser': 'Top Loser',
      'select_stock_to_trade': 'Select a stock to trade',
      'stock_not_found': 'Stock not found',
      'place_order': 'Invest',
      'subtotal': 'Subtotal',
      'your_positions': 'Your Positions',
      'view_all': 'View All',
      'insufficient_funds': 'Insufficient funds',
      'insufficient_funds_for_short': 'Insufficient funds for short',
      'short_selling_banned': 'Short selling is currently banned',
      'give_up': 'Give Up',
      'give_up_confirm_title': 'Abandon Run?',
      'give_up_confirm_message': 'You will lose your current progress and go to the prestige shop. Your prestige points are kept.',
      'give_up_confirm': 'Give Up',
      'max': 'Max',
      'quantity_hint': 'Tap to add, hold to subtract',
      'avg_cost': 'Buy Price',
      'current_price': 'Current Price',
      'market_value': 'Current Value',
      'unrealized_pnl': 'Current Gains',
      'no_positions': 'No positions yet',
      'long_positions': 'Long Positions',
      'short_positions': 'Short Positions',
      'total_value': 'Total Value',
      'fee_percent': 'Fee ({percent}%)',
      'buy_long_ticker': 'BUY {ticker} 📈',
      'sell_short_ticker': 'SHORT {ticker} 📉',
      'shares_count': '{count} shares',
      'avg_cost_value': 'Avg: {cost}',
      'bought_shares_long': 'Bought {shares} {ticker} shares (long)',
      'shorted_shares': 'Shorted {shares} {ticker} shares',
      'covered_shares': 'Covered {count} {ticker} shares',
      'sold_shares': 'Sold {count} {ticker} shares',
      'failed_to_sell': 'Failed to sell position',
      'insufficient_funds_cover': 'Insufficient funds to cover position',

      // Stop loss / Take profit
      'auto_orders': 'Auto Trading',
      'auto_orders_desc': 'Set rules to auto-sell your positions',
      'stop_loss': 'Loss Protection',
      'take_profit': 'Profit Target',
      'stop_loss_desc': 'Auto-sell if your investment drops by {percent}%',
      'take_profit_desc': 'Auto-sell if your investment gains {percent}%',
      'requires_upgrade': 'Requires upgrade',

      // Positions view
      'start_trading_hint': 'Start trading to build your portfolio',
      'total_pnl': 'Total Gains',
      'long_value': 'Long Value',
      'short_value': 'Short Value',
      'long_pnl': 'Long Gains',
      'short_pnl': 'Short Gains',
      'current': 'Current',
      'pnl_percent': 'Gain %',
      'close_position_title': '{action} Position',
      'close_position_prompt': 'How many shares do you want to {action}?',
      'max_shares': 'Max: {count} shares',

      // Hero cards
      'holdings': 'Holdings',
      'profit': 'Profit',
      'loss': 'Loss',
      'trades': 'Trades',
      'closed': 'Closed',
      'next_day': 'Next Day',
      'day_number': 'DAY {day}',
      'days_left_count': '{days}d left',

      // News popup
      'start_trading': 'Start Trading',
      'breaking_news_update': 'Breaking News Update',
      'news_update_hint': 'New developments may confirm or contradict earlier reports',
      'mid_day_update': 'Mid-Day Update',
      'high_impact': 'High Impact',
      'medium_impact': 'Medium Impact',
      'low_impact': 'Low Impact',
      'company_specific': 'Company-specific',
      'sector_wide': 'Sector-wide',
      'contradicts_earlier_report': 'Contradicts Earlier Report',
      'continue_trading': 'Continue Trading',
      'day_year_header': 'DAY {day}, YEAR {year}',
      'mid_day_header': 'Day {day}, Year {year} - 13:30',

      // Dashboard
      'sector_allocation': 'Sector Allocation',
      'long_short': 'Long / Short',
      'position_statistics': 'Position Statistics',
      'profitable': 'Profitable',
      'losing': 'Losing',
      'best_position': 'Best Position',
      'worst_position': 'Worst Position',
      'trading_performance': 'Trading Performance',
      'win_streak': 'Win Streak',
      'lose_streak': 'Lose Streak',
      'trades_today': 'Trades Today',
      'best_trade_ever': 'Best Trade Ever',
      'worst_trade_ever': 'Worst Trade Ever',
      'risk_metrics': 'Risk Overview',
      'diversification': 'Diversification',
      'risk_level': 'Risk Level',
      'concentration': 'Concentration',
      'largest_position': 'Largest Position',
      'capital_allocation': 'Your Money',
      'invested': 'Invested',
      'quota_met': 'Objective Met!',
      'recent_trades': 'Recent Trades',
      'no_trades_yet': 'No trades yet',
      'news_affecting_positions': 'News Affecting Your Positions',
      'no_relevant_news': 'No relevant news',
      'acquired_upgrades': 'Acquired Upgrades',
      'upgrades_count': '{count} upgrades',
      'earned': 'Earned',
      'bonus': 'Bonus',
      'need': 'Need',
      'days_left_singular': '{days} day left',
      'days_left_plural': '{days} days left',

      // Info panel
      'information': 'Information',
      'market_overview': 'Market Overview',
      'sector_details': 'Sector Details',
      'company_info': 'Company Info',
      'portfolio_analysis': 'My Portfolio',
      'recent_news': 'Recent News',
      'no_news_yet': 'No news yet',

      // Chart position display
      'position_averaged': 'AVG',
      'position_individual': 'EACH',

      // Active effects
      'effect_active': 'ACTIVE',
      'effect_reduced_fees': 'Reduced Fees',
      'effect_increased_fees': 'Increased Fees',
      'effect_fee_discount': '{percent}% discount',
      'effect_fee_surcharge': '{percent}% surcharge',
      'effect_short_ban': 'Short Selling Ban',
      'effect_short_ban_desc': 'Short selling disabled',
      'effect_upgrade_sale': 'Upgrade Sale',
      'effect_upgrade_sale_desc': '{percent}% off upgrades',
      'effect_circuit_breaker': 'Circuit Breaker',
      'effect_circuit_breaker_desc': 'Trading halted',
      'effect_high_volatility': 'High Volatility',
      'effect_low_volatility': 'Low Volatility',
      'effect_volatility_desc': '{percent}% {direction} volatile',
      'effect_volatility_more': 'more',
      'effect_volatility_less': 'less',
      'effect_position_limit': 'Position Limit',
      'effect_position_limit_desc': 'Max {max} shares per trade',
      'effect_signal_jammer': 'Signal Interference',
      'effect_signal_jammer_desc': 'Trading signals are unreliable',
      'effect_days_remaining': '{days} days remaining',
      'effect_today': 'Today',
      'effect_day_remaining': '{days} day remaining',

      'market_health': 'Market Health',
      'fear_greed': 'Fear & Greed',
      'fear_greed_extreme_greed': 'Extreme Greed',
      'fear_greed_greed': 'Greed',
      'fear_greed_neutral': 'Neutral',
      'fear_greed_fear': 'Fear',
      'fear_greed_extreme_fear': 'Extreme Fear',
      'fear_greed_tip_extreme_greed': 'Careful, sell before the crash!',
      'fear_greed_tip_greed': 'Good time to take profits',
      'fear_greed_tip_neutral': 'Market is calm, watch for signals',
      'fear_greed_tip_fear': 'Good deals possible, buy low!',
      'fear_greed_tip_extreme_fear': 'Everything is on sale, big opportunity!',
      'market_breadth': 'Market Breadth',
      'volatility': 'Volatility',
      'sector_leaders': 'Sector Leaders',
      'best': 'Best',
      'worst': 'Worst',
      'select_sector_to_see_details': 'Select a sector to see details',
      'sector_news': 'Sector News',
      'sector_overview': 'Sector Overview',
      'name': 'Name',
      'type': 'Type',
      'region': 'Region',
      'characteristics': 'Characteristics',
      'market_correlation': 'Market Correlation',
      'fed_sensitivity': 'Fed Sensitivity',
      'your_holdings': 'Your Holdings',
      'total_shares': 'Total Shares',
      'select_stock_to_see_details': 'Select a stock to see details',
      'ticker': 'Ticker',
      'sector': 'Sector',
      'pe_ratio': 'P/E Ratio',
      'trading_stats': 'Trading Stats',
      'day_open': 'Day Open',
      'day_high': 'Day High',
      'day_low': 'Day Low',
      'analyst_ratings': 'Analyst Ratings',
      'technical_analysis': 'Technical Analysis',
      'historical_performance': 'Historical Performance',
      'week_range_52': '52-Week Range',
      'from_high': 'From High',
      'from_low': 'From Low',
      'blue_chip': 'Blue Chip',
      'penny_stock': 'Penny Stock',
      'yes': 'Yes',
      'no': 'No',
      'your_position': 'Your Position',
      'recent_activity': 'Recent Activity',
      'portfolio_summary': 'Summary',
      'total_positions': 'Total Positions',
      'portfolio_value': 'Portfolio Value',
      'best_performer': 'Best Performer',
      'stock': 'Stock',
      'no_analyst_data': 'No analyst data',
      'consensus': 'Consensus',
      'analysts': 'Analysts',
      'hold': 'Hold',
      'strong_buy': 'Strong Buy',
      'strong_sell': 'Strong Sell',
      'price_target': 'Price Target',
      'pt_high': 'PT High',
      'pt_low': 'PT Low',
      'upside': 'Upside',
      'rsi_14': 'RSI (14)',
      'oversold': 'Oversold',
      'overbought': 'Overbought',
      'neutral': 'Neutral',
      'ma_50': 'MA 50',
      'ma_200': 'MA 200',
      'volume_ratio': 'Volume Ratio',
      'regime_strong_bull': 'Strong Bull',
      'regime_bull': 'Bull Market',
      'regime_neutral': 'Neutral',
      'regime_bear': 'Bear Market',
      'regime_strong_bear': 'Strong Bear',
      'regime_desc_strong_bull': 'Extreme optimism. Buy everything!',
      'regime_desc_bull': 'Positive sentiment. Good time to buy.',
      'regime_desc_neutral': 'Mixed signals. Watch for opportunities.',
      'regime_desc_bear': 'Negative sentiment. Be careful with your trades.',
      'regime_desc_strong_bear': 'Extreme pessimism. Wait or short sell!',
      'days_in_regime': 'Days in regime',
      'strength': 'Strength',
      'market_indicators': 'Market Indicators',
      'advancing': 'Advancing',
      'declining': 'Declining',
      'unchanged': 'Unchanged',
      'new_highs': 'New Highs',
      'new_lows': 'New Lows',
      'leading_sector': 'Leading Sector',
      'lagging_sector': 'Lagging Sector',
      'portfolio_breakdown': 'Portfolio Details',
      'distinct_sectors': 'Distinct Sectors',
      'avg_position_size': 'Avg Position Size',
      'portfolio_vol': 'Portfolio Vol',
      'largest_value': 'Largest Value',
      'position_types': 'Position Types',
      'unknown': 'Unknown',

      // Sorting and misc
      'sort_by': 'Sort by:',
      'avg_change': 'Avg Change',
      'stocks_count_region': '{count} stocks • {region}',
      'all_stocks': 'All Stocks',
      'trade': 'Trade',

      // Sector names
      'sector_tech': 'Technology',
      'sector_healthcare': 'Healthcare',
      'sector_finance': 'Finance',
      'sector_energy': 'Energy',
      'sector_consumer': 'Consumer',
      'sector_industrial': 'Industrial',
      'sector_realestate': 'Real Estate',
      'sector_telecom': 'Telecom',
      'sector_gaming': 'Gaming',
      'sector_crypto': 'Crypto',
      'sector_aerospace': 'Aerospace',
      'sector_materials': 'Materials',
      'sector_utilities': 'Utilities',
      'sector_commodities': 'Commodities',
      'sector_forex': 'Forex',
      'sector_indices': 'Indices',

      // Sector descriptions
      'sector_desc_tech': 'Software, hardware, and internet companies',
      'sector_desc_healthcare': 'Pharmaceuticals, biotech, and medical devices',
      'sector_desc_finance': 'Banks, insurance, and financial services',
      'sector_desc_energy': 'Oil, gas, and renewable energy',
      'sector_desc_consumer': 'Retail, food, and consumer products',
      'sector_desc_industrial': 'Manufacturing, aerospace, and construction',
      'sector_desc_realestate': 'REITs and property developers',
      'sector_desc_telecom': 'Telecommunications and media',
      'sector_desc_gaming': 'Video games, esports, and entertainment',
      'sector_desc_crypto': 'Cryptocurrency, blockchain, and DeFi',
      'sector_desc_aerospace': 'Space exploration and defense contractors',
      'sector_desc_materials': 'Steel, copper, lithium, and rare earth minerals',
      'sector_desc_utilities': 'Water, electricity, and gas providers',
      'sector_desc_commodities': 'Gold, oil, silver, and natural gas',
      'sector_desc_forex': 'Currency pairs and foreign exchange',
      'sector_desc_indices': 'Market indices tracking overall performance',

      // Upgrade names and descriptions
      // — Trading
      'upgrade_fee_reduction_1_name': 'Discount Broker',
      'upgrade_fee_reduction_1_desc': 'Reduce trading fees by 5%',
      'upgrade_fee_reduction_2_name': 'Premium Broker',
      'upgrade_fee_reduction_2_desc': 'Reduce trading fees by 10%',
      'upgrade_fee_reduction_3_name': 'VIP Trading',
      'upgrade_fee_reduction_3_desc': 'Reduce trading fees by 20%',
      'upgrade_zero_fees_name': 'Zero Commission',
      'upgrade_zero_fees_desc': 'Eliminate all trading fees',
      'upgrade_margin_1_name': 'Margin Account',
      'upgrade_margin_1_desc': 'Unlock 1.5x margin trading',
      'upgrade_margin_2_name': 'Advanced Margin',
      'upgrade_margin_2_desc': 'Unlock 2x margin trading',
      'upgrade_margin_3_name': 'Pro Leverage',
      'upgrade_margin_3_desc': 'Unlock 3x margin trading',
      'upgrade_short_selling_name': 'Short Selling',
      'upgrade_short_selling_desc': 'Unlock ability to short stocks',
      'upgrade_momentum_rider_name': 'Momentum Rider',
      'upgrade_momentum_rider_desc': '+10% profit on your next trade after 3 consecutive wins.',
      'upgrade_contrarian_name': 'Contrarian',
      'upgrade_contrarian_desc': '+20% profit when buying a stock that dropped >10% today.',
      'upgrade_day_trader_name': 'Day Trader',
      'upgrade_day_trader_desc': '+5% bonus when you buy and sell the same stock in one day.',
      'upgrade_stock_bonus_1_name': 'Loyalty Rewards',
      'upgrade_stock_bonus_1_desc': 'Receive 2% bonus shares on every purchase.',
      'upgrade_stock_bonus_2_name': 'Premium Rewards',
      'upgrade_stock_bonus_2_desc': 'Receive 5% bonus shares on every purchase.',
      'upgrade_stock_bonus_3_name': 'VIP Rewards',
      'upgrade_stock_bonus_3_desc': 'Receive 8% bonus shares on every purchase.',
      'upgrade_stock_bonus_max_name': 'Whale Rewards',
      'upgrade_stock_bonus_max_desc': 'Receive 12% bonus shares on every purchase.',
      'upgrade_analyst_1_name': 'Junior Analyst',
      'upgrade_analyst_1_desc': 'Trading signals are 60% accurate (base: 50%).',
      'upgrade_analyst_2_name': 'Senior Analyst',
      'upgrade_analyst_2_desc': 'Trading signals are 75% accurate.',
      'upgrade_analyst_3_name': 'Expert Analyst',
      'upgrade_analyst_3_desc': 'Trading signals are 90% accurate.',
      'upgrade_robot_token_1_name': 'Trading Bot',
      'upgrade_robot_token_1_desc': 'Get a robot that auto-trades a stock. Place it to buy low and sell high automatically.',
      'upgrade_robot_token_2_name': 'Advanced Bot',
      'upgrade_robot_token_2_desc': 'Get another trading bot for more automated gains.',
      // — Information
      'upgrade_earnings_preview_name': 'Earnings Calendar',
      'upgrade_earnings_preview_desc': 'See which companies will have news tomorrow.',
      'upgrade_volume_sight_name': 'Volume Indicator',
      'upgrade_volume_sight_desc': 'See trading volume activity on each stock.',
      // — Portfolio
      'upgrade_position_slot_1_name': 'Portfolio Expansion',
      'upgrade_position_slot_1_desc': 'Hold +1 additional position',
      'upgrade_position_slot_2_name': 'Large Portfolio',
      'upgrade_position_slot_2_desc': 'Hold +2 additional positions',
      'upgrade_position_slot_3_name': 'Hedge Fund',
      'upgrade_position_slot_3_desc': 'Hold +3 additional positions',
      // — Unlock
      'upgrade_unlock_companies_1_name': 'Market Access',
      'upgrade_unlock_companies_1_desc': 'Unlock 3 random locked companies',
      'upgrade_unlock_companies_2_name': 'Premium Access',
      'upgrade_unlock_companies_2_desc': 'Unlock 5 random locked companies',
      'upgrade_unlock_companies_3_name': 'Full Access',
      'upgrade_unlock_companies_3_desc': 'Unlock 8 random locked companies',
      // — Risk
      'upgrade_crash_protection_name': 'Crash Shield',
      'upgrade_crash_protection_desc': 'Reduce losses by 20% on all losing trades',
      'upgrade_diamond_hands_name': 'Diamond Hands',
      'upgrade_diamond_hands_desc': '+50% profit on all winning trades',
      // — Income
      'upgrade_passive_income_1_name': 'Interest Income',
      'upgrade_passive_income_1_desc': 'Earn \$25 passive income per day',
      'upgrade_passive_income_2_name': 'Savings Account',
      'upgrade_passive_income_2_desc': 'Earn \$50 passive income per day',
      'upgrade_passive_income_3_name': 'Trust Fund',
      'upgrade_passive_income_3_desc': 'Earn \$100 passive income per day',
      'upgrade_tax_refund_name': 'Tax Refund',
      'upgrade_tax_refund_desc': 'Recover 10% of your realized losses as cash at end of day.',
      'upgrade_dividend_boost_name': 'Dividend King',
      'upgrade_dividend_boost_desc': 'Dividend tokens earn 50% more income',
      'upgrade_market_maker_name': 'Market Maker',
      'upgrade_market_maker_desc': 'Earn \$50 bonus cash on every trade you make',
      'upgrade_dividend_token_1_name': 'Dividend Token',
      'upgrade_dividend_token_1_desc': "Get a token that earns passive income from a stock's gains. Place it on any stock.",
      'upgrade_dividend_token_2_name': 'Premium Dividend',
      'upgrade_dividend_token_2_desc': 'Get another dividend token for double passive income.',
      'upgrade_compound_interest_name': 'Compound Interest',
      'upgrade_compound_interest_desc': 'Earn 1% of your portfolio value as cash daily',
      // — Time
      'upgrade_longer_day_1_name': 'Extended Hours',
      'upgrade_longer_day_1_desc': 'Trading day is 10 seconds longer',
      'upgrade_longer_day_2_name': 'Night Trading',
      'upgrade_longer_day_2_desc': 'Trading day is 20 seconds longer',
      'upgrade_quantum_trader_name': 'Quantum Trader',
      'upgrade_quantum_trader_desc': 'Trading day is 60 seconds longer',
      // — Quota
      'upgrade_quota_reduction_1_name': 'Lenient Boss',
      'upgrade_quota_reduction_1_desc': 'Quota reduced by 10%',
      'upgrade_quota_reduction_2_name': 'Easy Mode',
      'upgrade_quota_reduction_2_desc': 'Quota reduced by 20%',
      'upgrade_extra_day_name': 'Deadline Extension',
      'upgrade_extra_day_desc': '+1 day to meet quota',
      // — Sector Shield
      'upgrade_sector_shield_common_name': 'Sector Shield',
      'upgrade_sector_shield_common_desc': 'Reduce losses by 3% on {sector} stocks',
      'upgrade_sector_shield_uncommon_name': 'Sector Shield',
      'upgrade_sector_shield_uncommon_desc': 'Reduce losses by 7% on {sector} stocks',
      'upgrade_sector_shield_rare_name': 'Sector Shield',
      'upgrade_sector_shield_rare_desc': 'Reduce losses by 15% on {sector} stocks',
      'upgrade_sector_shield_epic_name': 'Sector Shield',
      'upgrade_sector_shield_epic_desc': 'Reduce losses by 22% on {sector} stocks',
      'upgrade_sector_shield_legendary_name': 'Sector Shield',
      'upgrade_sector_shield_legendary_desc': 'Reduce losses by 30% on {sector} stocks',
      // — Sector Edge
      'upgrade_sector_edge_common_name': 'Sector Edge',
      'upgrade_sector_edge_common_desc': 'Boost profits by 3% on {sector} stocks',
      'upgrade_sector_edge_uncommon_name': 'Sector Edge',
      'upgrade_sector_edge_uncommon_desc': 'Boost profits by 7% on {sector} stocks',
      'upgrade_sector_edge_rare_name': 'Sector Edge',
      'upgrade_sector_edge_rare_desc': 'Boost profits by 15% on {sector} stocks',
      'upgrade_sector_edge_epic_name': 'Sector Edge',
      'upgrade_sector_edge_epic_desc': 'Boost profits by 22% on {sector} stocks',
      'upgrade_sector_edge_legendary_name': 'Sector Edge',
      'upgrade_sector_edge_legendary_desc': 'Boost profits by 30% on {sector} stocks',
      // — Income Situational
      'upgrade_income_per_stock_name': 'Stock Dividend',
      'upgrade_income_per_stock_desc': 'Earn \$1 per stock held at end of day',
      'upgrade_income_per_sector_name': 'Sector Diversification',
      'upgrade_income_per_sector_desc': 'Earn \$10 per distinct sector in your portfolio',
      'upgrade_income_per_upgrade_name': 'Knowledge Pays',
      'upgrade_income_per_upgrade_desc': 'Earn \$5 per upgrade owned at end of day',
      'upgrade_income_portfolio_percent_name': 'Portfolio Interest',
      'upgrade_income_portfolio_percent_desc': 'Earn 1% of portfolio value as cash daily',
      'upgrade_income_combo_name': 'Wealth Engine',
      'upgrade_income_combo_desc': 'Earn \$2/stock + \$15/sector + 0.5% portfolio value daily',
      // — News upgrades
      'upgrade_morning_edition_name': 'Morning Edition',
      'upgrade_morning_edition_desc': '+1 extra news at the start of each day',
      'upgrade_evening_edition_name': 'Evening Edition',
      'upgrade_evening_edition_desc': '+1 extra news at mid-day',
      'upgrade_news_cycle_24h_name': '24h News Cycle',
      'upgrade_news_cycle_24h_desc': '+1 news at morning AND mid-day',
      // — Sector Insight templates
      'upgrade_sector_insight_common_name': 'Sector Insight',
      'upgrade_sector_insight_common_desc': '+20% chance news targets {sector}',
      'upgrade_sector_insight_uncommon_name': 'Sector Insight',
      'upgrade_sector_insight_uncommon_desc': '+35% chance news targets {sector}',
      'upgrade_sector_insight_rare_name': 'Sector Insight',
      'upgrade_sector_insight_rare_desc': '+50% chance news targets {sector}',
      'upgrade_sector_insight_epic_name': 'Sector Insight',
      'upgrade_sector_insight_epic_desc': '+70% chance news targets {sector} + sentiment preview',
      'upgrade_sector_insight_legendary_name': 'Sector Insight',
      'upgrade_sector_insight_legendary_desc': '1 guaranteed {sector} news/day + sentiment preview',
      // — Sector Dominance templates
      'upgrade_sector_dominance_common_name': 'Sector Dominance',
      'upgrade_sector_dominance_common_desc': '+2% profit per {sector} position held',
      'upgrade_sector_dominance_uncommon_name': 'Sector Dominance',
      'upgrade_sector_dominance_uncommon_desc': '+4% profit per {sector} position held',
      'upgrade_sector_dominance_rare_name': 'Sector Dominance',
      'upgrade_sector_dominance_rare_desc': '+7% profit per {sector} position held',
      'upgrade_sector_dominance_epic_name': 'Sector Dominance',
      'upgrade_sector_dominance_epic_desc': '+10% profit per {sector} position held',
      'upgrade_sector_dominance_legendary_name': 'Sector Dominance',
      'upgrade_sector_dominance_legendary_desc': '+15% profit per {sector} position + -5% fees',
      // — Winning Streak (global template, 5 rarities)
      'upgrade_winning_streak_common_name': 'Hot Streak',
      'upgrade_winning_streak_common_desc': '+2% profit per consecutive winning trade',
      'upgrade_winning_streak_uncommon_name': 'Hot Streak',
      'upgrade_winning_streak_uncommon_desc': '+4% profit per consecutive winning trade',
      'upgrade_winning_streak_rare_name': 'Hot Streak',
      'upgrade_winning_streak_rare_desc': '+8% profit per consecutive winning trade',
      'upgrade_winning_streak_epic_name': 'Hot Streak',
      'upgrade_winning_streak_epic_desc': '+15% profit per consecutive winning trade',
      'upgrade_winning_streak_legendary_name': 'Hot Streak',
      'upgrade_winning_streak_legendary_desc': '+25% profit per consecutive winning trade',
      // — Prestige (kept for prestige shop)
      'upgrade_prestige_stop_loss_name': 'Stop Loss',
      'upgrade_prestige_stop_loss_desc': 'Unlock stop loss orders. Auto-sell when positions drop below your threshold.',
      'upgrade_prestige_take_profit_name': 'Take Profit',
      'upgrade_prestige_take_profit_desc': 'Unlock take profit orders. Auto-sell when positions reach your target gain.',

      // Prestige shop UI
      'prestige_shop_title': 'TALENT TREE',
      'survived_days_year': 'You survived {days} days in Year {year}',
      'all_upgrades_purchased': 'All upgrades purchased!',
      'points_saved_for_future': 'You have {points} points saved for future upgrades.',
      'start_new_run': 'START NEW RUN',
      'tree_hint': 'Pinch to zoom \u2022 Drag to explore',
      'prestige_level': 'PRESTIGE LEVEL',
      'total_points_earned': 'TOTAL POINTS EARNED',
      'lifetime_earnings': 'LIFETIME EARNINGS',

      // Prestige upgrade names and descriptions
      // — Starting Cash (10 tiers)
      'upgrade_prestige_starting_cash_1_name': 'Seed Money I',
      'upgrade_prestige_starting_cash_1_desc': 'Start each run with +\$200 bonus cash.',
      'upgrade_prestige_starting_cash_2_name': 'Seed Money II',
      'upgrade_prestige_starting_cash_2_desc': 'Start each run with +\$500 bonus cash.',
      'upgrade_prestige_starting_cash_3_name': 'Seed Money III',
      'upgrade_prestige_starting_cash_3_desc': 'Start each run with +\$1,000 bonus cash.',
      'upgrade_prestige_starting_cash_4_name': 'Silver Spoon',
      'upgrade_prestige_starting_cash_4_desc': 'Start each run with +\$2,500 bonus cash.',
      'upgrade_prestige_starting_cash_5_name': 'Trust Fund',
      'upgrade_prestige_starting_cash_5_desc': 'Start each run with +\$5,000 bonus cash.',
      'upgrade_prestige_starting_cash_6_name': 'Angel Investor',
      'upgrade_prestige_starting_cash_6_desc': 'Start each run with +\$10,000 bonus cash.',
      'upgrade_prestige_starting_cash_7_name': 'Venture Capital',
      'upgrade_prestige_starting_cash_7_desc': 'Start each run with +\$25,000 bonus cash.',
      'upgrade_prestige_starting_cash_8_name': 'Hedge Fund',
      'upgrade_prestige_starting_cash_8_desc': 'Start each run with +\$50,000 bonus cash.',
      'upgrade_prestige_starting_cash_9_name': 'Dynasty Wealth',
      'upgrade_prestige_starting_cash_9_desc': 'Start each run with +\$100,000 bonus cash.',
      'upgrade_prestige_starting_cash_10_name': 'Infinite Money',
      'upgrade_prestige_starting_cash_10_desc': 'Start each run with +\$250,000 bonus cash.',
      // — Fee Reduction (5 tiers)
      'upgrade_prestige_fee_reduction_name': 'Broker Connections',
      'upgrade_prestige_fee_reduction_desc': 'Reduce trading fees by 15%.',
      'upgrade_prestige_fee_reduction_2_name': 'Wall Street Insider',
      'upgrade_prestige_fee_reduction_2_desc': 'Reduce trading fees by an additional 15%.',
      'upgrade_prestige_fee_reduction_3_name': 'VIP Trading',
      'upgrade_prestige_fee_reduction_3_desc': 'Reduce trading fees by an additional 10%.',
      'upgrade_prestige_fee_reduction_4_name': 'Market Maker',
      'upgrade_prestige_fee_reduction_4_desc': 'Reduce trading fees by an additional 10%.',
      'upgrade_prestige_fee_reduction_5_name': 'Zero Commission',
      'upgrade_prestige_fee_reduction_5_desc': 'Reduce trading fees by an additional 10%.',
      // — Extra Positions (6 tiers)
      'upgrade_prestige_extra_position_name': 'Extended Desk',
      'upgrade_prestige_extra_position_desc': 'Start each run with +2 max position slots.',
      'upgrade_prestige_extra_position_2_name': 'Diversified Portfolio',
      'upgrade_prestige_extra_position_2_desc': 'Start each run with +2 max position slots.',
      'upgrade_prestige_extra_position_3_name': 'Trading Floor',
      'upgrade_prestige_extra_position_3_desc': 'Start each run with +2 max position slots.',
      'upgrade_prestige_extra_position_4_name': 'Multi-Desk Trader',
      'upgrade_prestige_extra_position_4_desc': 'Start each run with +3 max position slots.',
      'upgrade_prestige_extra_position_5_name': 'Institutional Scale',
      'upgrade_prestige_extra_position_5_desc': 'Start each run with +3 max position slots.',
      'upgrade_prestige_extra_position_6_name': 'Market Domination',
      'upgrade_prestige_extra_position_6_desc': 'Start each run with +4 max position slots.',
      // — Unlock Random Sector Tier (3 tiers)
      'upgrade_prestige_unlock_tier_name': 'Insider Access',
      'upgrade_prestige_unlock_tier_desc': 'Start each run with the standard tier of a random sector unlocked.',
      'upgrade_prestige_unlock_tier_2_name': 'Elite Network',
      'upgrade_prestige_unlock_tier_2_desc': 'Start each run with the premium tier of a random sector unlocked.',
      'upgrade_prestige_unlock_tier_3_name': 'Market Titan',
      'upgrade_prestige_unlock_tier_3_desc': 'Start each run with the elite tier of a random sector unlocked.',
      // — Quota Reduction (5 tiers)
      'upgrade_prestige_quota_reduction_name': 'Relaxed Targets',
      'upgrade_prestige_quota_reduction_desc': 'Reduce quota targets by 10%.',
      'upgrade_prestige_quota_reduction_2_name': 'Sympathetic Manager',
      'upgrade_prestige_quota_reduction_2_desc': 'Reduce quota targets by an additional 10%.',
      'upgrade_prestige_quota_reduction_3_name': 'Lenient Board',
      'upgrade_prestige_quota_reduction_3_desc': 'Reduce quota targets by an additional 8%.',
      'upgrade_prestige_quota_reduction_4_name': 'Flexible Goals',
      'upgrade_prestige_quota_reduction_4_desc': 'Reduce quota targets by an additional 7%.',
      'upgrade_prestige_quota_reduction_5_name': 'Rubber Stamp',
      'upgrade_prestige_quota_reduction_5_desc': 'Reduce quota targets by an additional 5%.',
      // — Extra Time (5 tiers)
      'upgrade_prestige_extra_time_name': 'Early Bird',
      'upgrade_prestige_extra_time_desc': 'Start each day with +30 seconds.',
      'upgrade_prestige_extra_time_2_name': 'Time Lord',
      'upgrade_prestige_extra_time_2_desc': 'Start each day with +30 seconds.',
      'upgrade_prestige_extra_time_3_name': 'Extended Hours',
      'upgrade_prestige_extra_time_3_desc': 'Start each day with +30 seconds.',
      'upgrade_prestige_extra_time_4_name': 'After Hours',
      'upgrade_prestige_extra_time_4_desc': 'Start each day with +45 seconds.',
      'upgrade_prestige_extra_time_5_name': 'Time Dilation',
      'upgrade_prestige_extra_time_5_desc': 'Start each day with +60 seconds.',
      // — Passive Income (8 tiers)
      'upgrade_prestige_passive_income_name': 'Side Hustle',
      'upgrade_prestige_passive_income_desc': 'Earn \$20 passive income at the end of each day.',
      'upgrade_prestige_passive_income_2_name': 'Investment Portfolio',
      'upgrade_prestige_passive_income_2_desc': 'Earn +\$30 passive income at the end of each day.',
      'upgrade_prestige_passive_income_3_name': 'Rental Empire',
      'upgrade_prestige_passive_income_3_desc': 'Earn +\$50 passive income at the end of each day.',
      'upgrade_prestige_passive_income_4_name': 'Dividend King',
      'upgrade_prestige_passive_income_4_desc': 'Earn +\$80 passive income at the end of each day.',
      'upgrade_prestige_passive_income_5_name': 'Revenue Stream',
      'upgrade_prestige_passive_income_5_desc': 'Earn +\$150 passive income at the end of each day.',
      'upgrade_prestige_passive_income_6_name': 'Cash Machine',
      'upgrade_prestige_passive_income_6_desc': 'Earn +\$300 passive income at the end of each day.',
      'upgrade_prestige_passive_income_7_name': 'Money Printer',
      'upgrade_prestige_passive_income_7_desc': 'Earn +\$500 passive income at the end of each day.',
      'upgrade_prestige_passive_income_8_name': 'Infinite Wealth',
      'upgrade_prestige_passive_income_8_desc': 'Earn +\$1,000 passive income at the end of each day.',
      // — Compound Interest (5 tiers)
      'upgrade_prestige_compound_interest_name': 'Compound Interest',
      'upgrade_prestige_compound_interest_desc': 'Earn 2% interest on your cash balance at the end of each day.',
      'upgrade_prestige_compound_interest_2_name': 'Savings Account',
      'upgrade_prestige_compound_interest_2_desc': 'Earn +1% interest on your cash balance at the end of each day.',
      'upgrade_prestige_compound_interest_3_name': 'High Yield Fund',
      'upgrade_prestige_compound_interest_3_desc': 'Earn +1% interest on your cash balance at the end of each day.',
      'upgrade_prestige_compound_interest_4_name': 'Investment Bank',
      'upgrade_prestige_compound_interest_4_desc': 'Earn +1% interest on your cash balance at the end of each day.',
      'upgrade_prestige_compound_interest_5_name': 'Central Bank Access',
      'upgrade_prestige_compound_interest_5_desc': 'Earn +1% interest on your cash balance at the end of each day.',
      // — Prestige Accelerator (5 tiers)
      'upgrade_prestige_accelerator_name': 'Prestige Accelerator',
      'upgrade_prestige_accelerator_desc': 'Earn 50% more prestige points each run.',
      'upgrade_prestige_accelerator_2_name': 'Prestige Turbo',
      'upgrade_prestige_accelerator_2_desc': 'Earn +50% more prestige points each run.',
      'upgrade_prestige_accelerator_3_name': 'Prestige Overdrive',
      'upgrade_prestige_accelerator_3_desc': 'Earn +50% more prestige points each run.',
      'upgrade_prestige_accelerator_4_name': 'Prestige Singularity',
      'upgrade_prestige_accelerator_4_desc': 'Earn +50% more prestige points each run.',
      'upgrade_prestige_accelerator_5_name': 'Prestige Ascension',
      'upgrade_prestige_accelerator_5_desc': 'Earn +100% more prestige points each run.',
      // — Unique upgrades
      'upgrade_prestige_reroll_name': 'Reroll Master',
      'upgrade_prestige_reroll_desc': 'Reroll your upgrade choices once per day.',
      'upgrade_prestige_lucky_start_name': 'Lucky Start',
      'upgrade_prestige_lucky_start_desc': 'Your first upgrade each run is guaranteed to be Rare or better.',
      'upgrade_prestige_second_chance_name': 'Second Chance',
      'upgrade_prestige_second_chance_desc': 'Once per run, survive a failed quota and continue playing.',
      'upgrade_prestige_golden_parachute_name': 'Golden Parachute',
      'upgrade_prestige_golden_parachute_desc': 'Keep 25% of your cash when a run ends from failed quota.',
      'upgrade_prestige_quick_learner_name': 'Quick Learner',
      'upgrade_prestige_quick_learner_desc': 'Get 4 upgrade choices instead of 3 each day.',
      'upgrade_prestige_market_veteran_name': 'Market Veteran',
      'upgrade_prestige_market_veteran_desc': 'Choose a free daily upgrade at the start of each run.',
      // — Short Immunity
      'upgrade_prestige_short_immunity_name': 'Short Immunity',
      'upgrade_prestige_short_immunity_desc': 'Short selling bans from events don\'t affect you.',
      // — Luck Boost (3 tiers)
      'upgrade_prestige_luck_boost_name': 'Lucky Charm',
      'upgrade_prestige_luck_boost_desc': 'Slightly increase rare+ upgrade chance in shop.',
      'upgrade_prestige_luck_boost_2_name': 'Fortune Favored',
      'upgrade_prestige_luck_boost_2_desc': 'Further increase rare+ upgrade chance in shop.',
      'upgrade_prestige_luck_boost_3_name': 'Golden Touch',
      'upgrade_prestige_luck_boost_3_desc': 'Greatly increase rare+ upgrade chance in shop.',
      // — Reroll Boost (3 tiers)
      'upgrade_prestige_reroll_boost_name': 'Second Look',
      'upgrade_prestige_reroll_boost_desc': '+1 free roll per day (shop & daily).',
      'upgrade_prestige_reroll_boost_2_name': 'Fresh Options',
      'upgrade_prestige_reroll_boost_2_desc': '+1 free roll per day (shop & daily).',
      'upgrade_prestige_reroll_boost_3_name': 'Infinite Browsing',
      'upgrade_prestige_reroll_boost_3_desc': '+1 free roll per day (shop & daily).',
      // — Sector Amplifier
      'upgrade_prestige_sector_amplifier_name': 'Sector Amplifier',
      'upgrade_prestige_sector_amplifier_desc': 'Sector Shield and Sector Edge upgrades are 25% more effective.',

      // — Robot Traders
      'upgrade_robot_slot_1_name': 'Robot Bay',
      'upgrade_robot_slot_1_desc': 'Unlock robot traders and gain your first trading bot.',
      'upgrade_robot_slot_2_name': 'Robot Slot II',
      'upgrade_robot_slot_2_desc': 'Unlock a second trading bot.',
      'upgrade_robot_slot_3_name': 'Robot Slot III',
      'upgrade_robot_slot_3_desc': 'Unlock a third trading bot.',
      'upgrade_robot_slot_4_name': 'Robot Slot IV',
      'upgrade_robot_slot_4_desc': 'Unlock a fourth trading bot.',
      'upgrade_robot_slot_5_name': 'Robot Slot V',
      'upgrade_robot_slot_5_desc': 'Unlock a fifth trading bot.',
      'upgrade_robot_blueprint_name': 'Blueprint Memory',
      'upgrade_robot_blueprint_desc': 'Robots keep 50% of their upgrade levels between runs.',
      'upgrade_robot_overclock_name': 'Overclock',
      'upgrade_robot_overclock_desc': '+1 trade per day for all robots.',
      'upgrade_robot_deep_pockets_name': 'Deep Pockets',
      'upgrade_robot_deep_pockets_desc': '+30% maximum budget allocable to each robot.',

      // Upgrade shop & collection UI
      'upgrade_shop_title': 'UPGRADE SHOP',
      'shop_subtitle': 'Pick free \u2022 Reroll for cash',
      'collection': 'Collection',
      'roll': 'ROLL',
      'free': 'FREE',
      'reroll_all': 'REROLL ALL',
      'pick': 'PICK',
      'drop_rates': 'DROP RATES',
      'free_rolls_remaining': '{count} free roll(s) remaining today',
      'resets_daily': 'Resets daily \u2022 Cost doubles per roll',
      'discovered': '{owned} / {total} discovered',
      'sector_shields': 'SECTOR SHIELDS',
      'sector_edges': 'SECTOR EDGES',
      'sector_insights': 'SECTOR INSIGHTS',
      'sector_dominances': 'SECTOR DOMINANCE',
      'winning_streaks': 'WINNING STREAK',

      // Rarity labels
      'rarity_common': 'Common',
      'rarity_uncommon': 'Uncommon',
      'rarity_rare': 'Rare',
      'rarity_epic': 'Epic',
      'rarity_legendary': 'Legendary',

      // Category labels
      'category_trading': 'TRADING',
      'category_information': 'INFORMATION',
      'category_portfolio': 'PORTFOLIO',
      'category_unlock': 'UNLOCK',
      'category_risk': 'RISK',
      'category_income': 'INCOME',
      'category_time': 'TIME',
      'category_quota': 'QUOTA',

      // Sector type names (for shop/collection cards)
      'sector_type_technology': 'Technology',
      'sector_type_healthcare': 'Healthcare',
      'sector_type_finance': 'Finance',
      'sector_type_energy': 'Energy',
      'sector_type_consumerGoods': 'Consumer',
      'sector_type_industrial': 'Industrial',
      'sector_type_realEstate': 'Real Estate',
      'sector_type_telecommunications': 'Telecom',
      'sector_type_materials': 'Materials',
      'sector_type_utilities': 'Utilities',
      'sector_type_gaming': 'Gaming',
      'sector_type_crypto': 'Crypto',
      'sector_type_aerospace': 'Aerospace',
      'sector_type_commodities': 'Commodities',
      'sector_type_forex': 'Forex',
      'sector_type_indices': 'Indices',

      // News headlines and descriptions
      'news_earnings_beat_headline': '{company} beats earnings expectations',
      'news_earnings_beat_desc': 'Analysts who predicted doom are "re-evaluating their models." Translation: they were wrong. Again.',
      'news_earnings_miss_headline': '{company} misses Q{quarter} earnings targets',
      'news_earnings_miss_desc': 'CEO blames "macroeconomic headwinds" instead of admitting the yacht budget got out of hand.',
      'news_earnings_record_headline': '{company} reports record profits',
      'news_earnings_record_desc': 'Board celebrates by voting themselves bonuses. Workers get a pizza party. Stocks go brrr.',
      'news_product_launch_headline': '{company} launches revolutionary new product',
      'news_product_launch_desc': 'It\'s basically the same thing with a new color. Investors call it "disruptive innovation."',
      'news_product_delay_headline': '{company} delays major product release',
      'news_product_delay_desc': 'Turns out "move fast and break things" has consequences. Who knew?',
      'news_product_recall_headline': '{company} product faces safety recall',
      'news_product_recall_desc': '"We take customer safety seriously" says company that clearly didn\'t until now.',
      'news_merger_announce_headline': '{company} announces major acquisition',
      'news_merger_announce_desc': 'Two mediocre companies become one big mediocre company. Synergy!',
      'news_merger_collapse_headline': '{company} merger talks collapse',
      'news_merger_collapse_desc': 'Both CEOs wanted the corner office. No one considered a coin flip.',
      'news_regulation_negative_headline': 'New regulations impact {sector} sector',
      'news_regulation_negative_desc': 'Government finally noticed the loopholes. Lobbyists are working overtime.',
      'news_regulation_positive_headline': '{sector} sector receives regulatory approval',
      'news_regulation_positive_desc': 'Regulators approve thing they clearly don\'t understand. Business as usual.',
      'news_market_rally_headline': 'Market rallies on strong economic data',
      'news_market_rally_desc': 'Number go up. Experts pretend they predicted this. Twitter traders claim genius status.',
      'news_market_volatility_headline': 'Market volatility spikes amid uncertainty',
      'news_market_volatility_desc': 'Algorithms fighting algorithms while humans panic. Peak capitalism.',
      'news_market_bull_headline': 'Bull market continues record run',
      'news_market_bull_desc': 'Everyone\'s a genius in a bull market. Your cousin\'s crypto tips suddenly seem reasonable.',
      'news_sector_growth_headline': '{sector} sector sees strong growth',
      'news_sector_growth_desc': 'Executives congratulate themselves. Workers wonder where their raise went.',
      'news_sector_headwinds_headline': '{sector} faces headwinds',
      'news_sector_headwinds_desc': '"Headwinds" is corporate speak for "we messed up but it\'s not our fault somehow."',
      'news_economy_fed_headline': 'Fed signals interest rate changes',
      'news_economy_fed_desc': 'Jerome Powell says words. Markets have existential crisis. Rinse, repeat.',
      'news_economy_gdp_headline': 'GDP growth exceeds expectations',
      'news_economy_gdp_desc': 'Economy strong if you ignore everyone who isn\'t a shareholder.',
      'news_economy_inflation_headline': 'Inflation concerns mount',
      'news_economy_inflation_desc': 'Your money buys less but CEOs still got their bonuses. The system works!',
      'news_platform_free_trading_headline': 'Broker announces commission-free trading day!',
      'news_platform_free_trading_desc': 'They\'ll make it back selling your data anyway. YOLO responsibly!',
      'news_platform_fee_reduction_headline': 'Trading platform reduces fees by 50%',
      'news_platform_fee_reduction_desc': 'Competition works! Until they merge and jack prices back up.',
      'news_platform_fee_increase_headline': 'Platform maintenance fees increased',
      'news_platform_fee_increase_desc': 'Servers don\'t pay for themselves. Neither do CEO beach houses.',
      'news_platform_surcharge_headline': 'High volume surcharge applied to all trades',
      'news_platform_surcharge_desc': 'Too many people making money? Time to add fees. Can\'t have that.',
      'news_bonus_loyalty_headline': 'Broker loyalty bonus credited to your account!',
      'news_bonus_loyalty_desc': 'Here\'s a tiny fraction of what we made off you. Don\'t spend it all in one trade.',
      'news_bonus_rebate_headline': 'Trading volume rebate received',
      'news_bonus_rebate_desc': 'You traded so much we felt guilty. Just kidding, it\'s a marketing expense.',
      'news_bonus_promo_headline': 'New user promotion bonus!',
      'news_bonus_promo_desc': 'Free money to get you hooked. First taste is always free.',
      'news_bonus_compensation_headline': 'System glitch compensation credited',
      'news_bonus_compensation_desc': 'Oops, we broke something. Here\'s hush money. Please don\'t tweet about it.',
      'news_restriction_short_ban_headline': 'SEC temporarily bans short selling',
      'news_restriction_short_ban_desc': 'Hedge funds complained their shorts weren\'t working. Retail: "First time?"',
      'news_restriction_short_emergency_headline': 'Emergency short selling restrictions enacted',
      'news_restriction_short_emergency_desc': 'When rich people lose money, suddenly shorting is a problem. Curious.',
      'news_restriction_position_limit_headline': 'Position limits temporarily enforced',
      'news_restriction_position_limit_desc': 'Too many apes buying? Better limit their fun. The house always wins.',
      'news_restriction_short_lifted_headline': 'Short selling ban lifted early!',
      'news_restriction_short_lifted_desc': 'Hedge funds lobbied successfully. Democracy in action. 🎉',
      'news_event_flash_sale_headline': 'Flash sale: 50% off all upgrades today!',
      'news_event_flash_sale_desc': 'Consume! Upgrade! The market demands it. Your wallet weeps.',
      'news_event_clearance_headline': 'Upgrade clearance sale: 30% off',
      'news_event_clearance_desc': 'We need to hit quarterly numbers. Help a corporation out?',
      'news_event_circuit_breaker_headline': 'Market circuit breaker triggered!',
      'news_event_circuit_breaker_desc': 'Markets too crazy even for Wall Street. Everyone take a breather.',
      'news_event_flash_crash_headline': 'Flash crash warning: extreme volatility ahead',
      'news_event_flash_crash_desc': 'Robots fighting robots. Humans just along for the ride. Welcome to 2024.',
      'news_event_stabilize_headline': 'Market stabilizes: volatility decreases',
      'news_event_stabilize_desc': 'Money printer goes brrr. Crisis averted. Until next week.',
      'news_event_data_glitch_headline': 'Market data feed corrupted!',
      'news_event_data_glitch_desc': 'Your fancy indicators are showing the opposite of reality. Good luck out there.',
      'news_event_algo_confusion_headline': 'Algorithm chaos: Trading bots go haywire',
      'news_event_algo_confusion_desc': 'The robots are confused. The humans were already confused. It\'s confusion all the way down.',
      'news_event_sector_rotation_headline': 'Massive sector rotation shocks markets!',
      'news_event_sector_rotation_desc': 'What was hot is now cold. What was cold is now hot. Welcome to the stock market roulette.',
      'news_event_whale_activity_headline': 'Whale alert: Massive position detected',
      'news_event_whale_activity_desc': 'Someone with more money than sense just moved the market. You\'re along for the ride.',
      'news_generic_company_headline': '{company} makes headlines',
      'news_generic_company_desc': 'CEO said something on Twitter. Stock reacts accordingly.',
      'news_generic_sector_headline': '{sector} sector update',
      'news_generic_sector_desc': 'Analysts publish reports no one reads. Stocks do whatever they want anyway.',
      'news_generic_market_headline': 'Market update',
      'news_generic_market_desc': 'Stocks went up, down, or sideways. Experts explain why after the fact.',

      // Mid-day contradiction news
      'midday_prefix_update': 'UPDATE: ',
      'midday_prefix_correction': 'CORRECTION: ',
      'midday_prefix_breaking': 'BREAKING: ',
      'midday_prefix_reversal': 'REVERSAL: ',
      'midday_prefix_recovery': 'RECOVERY: ',
      'news_midday_company_positive_headline': '{company} recovers, analysts upgrade outlook',
      'news_midday_company_positive_desc': 'Earlier concerns prove unfounded as new data emerges. Shorts are panicking. You love to see it.',
      'news_midday_company_negative_headline': '{company} faces unexpected challenges',
      'news_midday_company_negative_desc': 'Initial optimism fades as analysts revise projections. Morning bulls now pretend they were cautious all along.',
      'news_midday_sector_positive_headline': '{sector} sector rebounds on new developments',
      'news_midday_sector_positive_desc': 'Market sentiment shifts as conditions improve. Paper hands in shambles.',
      'news_midday_sector_negative_headline': '{sector} sector reverses gains',
      'news_midday_sector_negative_desc': 'Morning optimism gives way to afternoon selling. "Diamond hands" tested once again.',
      'news_midday_market_positive_headline': 'Markets recover from morning losses',
      'news_midday_market_positive_desc': 'Investors find buying opportunities after early sell-off. The dip was bought. The prophecy fulfilled.',
      'news_midday_market_negative_headline': 'Markets give back morning gains',
      'news_midday_market_negative_desc': 'Profit-taking and new concerns weigh on indices. Turns out green mornings are not a guarantee.',

      // News category labels
      'news_category_earnings': 'Earnings',
      'news_category_market': 'Market',
      'news_category_sector': 'Sector',
      'news_category_company': 'Company',
      'news_category_economy': 'Economy',
      'news_category_regulation': 'Regulation',
      'news_category_merger': 'M&A',
      'news_category_product': 'Product',
      'news_category_platform': 'Platform',
      'news_category_bonus': 'Bonus',
      'news_category_restriction': 'Restriction',
      'news_category_event': 'Event',
      'news_category_informant': 'Informant',

      // Informant news
      'news_informant_tip_headline': '\u{1F575}\uFE0F {company}: Tip acquired',
      'news_informant_tip_desc': 'A secret tip has been purchased from the informant.',

      // Skip quota
      'skip_quota': 'SKIP QUOTA',

      // Position cap restriction
      'news_restriction_position_cap_headline': 'Position sizing rules enforced',
      'news_restriction_position_cap_desc': 'Trade sizes are temporarily capped for risk management.',

      // Tutorial
      'disclaimer': 'Important Disclaimer',
      'welcome_to_kandl': 'Welcome to KANDL',
      'skip_tutorial': 'Skip Tutorial',
      'start_playing': 'Start Playing',
      'important_warning': 'Important Warning',
      'traders_lose_money': 'of retail investors lose money when trading stocks and derivatives. Most day traders fail to profit over time.',
      'disclaimer_gambling': 'Stock trading can be as addictive as gambling. Never trade with money you cannot afford to lose.',
      'disclaimer_educational': 'This game is for entertainment and educational purposes only. It does not reflect real market conditions.',
      'disclaimer_not_advice': 'Nothing in this game constitutes financial advice. Always consult a professional before investing real money.',
      'disclaimer_remember': 'Remember: This is just a game. Real markets are far more complex and unpredictable.',
      'game_description': 'Trade stocks, meet quotas, unlock upgrades, and build your trading empire in this idle stock trading simulator!',
      'feature_trading': 'Buy & Sell Stocks',
      'feature_trading_desc': 'Trade across multiple sectors with long and short positions',
      'feature_quota': 'Meet Your Quota',
      'feature_quota_desc': 'Reach your profit target before time runs out',
      'feature_upgrades': 'Unlock Upgrades',
      'feature_upgrades_desc': 'Earn powerful bonuses to boost your trading',
      'feature_achievements': 'Earn Achievements',
      'feature_achievements_desc': 'Complete challenges for permanent rewards',
      'tutorial_next': 'Next',
      'tutorial_got_it': 'Got it!',
      'tutorial_skip': 'Skip',
      'restart_tutorial': 'Restart Tutorial',
      'tutorial_dashboard_title': 'Dashboard',
      'tutorial_dashboard_desc': 'Your command center! Track your overall progress, see market trends, and monitor your portfolio performance.',
      'tutorial_metrics_title': 'Key Metrics',
      'tutorial_metrics_desc': 'Watch your Cash, Portfolio Value, and Quota progress. Meet your quota before the deadline!',
      'tutorial_stats_title': 'Market Stats',
      'tutorial_stats_desc': 'Track the current day, time, and market status. The market moves fast - watch the clock!',
      'tutorial_position_statistics_title': 'Position Statistics',
      'tutorial_position_statistics_desc': 'See how many positions are profitable vs losing, and identify your best and worst performers at a glance.',
      'tutorial_trading_performance_title': 'Trading Performance',
      'tutorial_trading_performance_desc': 'Track your win rate, total P&L, and trading streaks. See your best and worst trades ever!',
      'tutorial_risk_metrics_title': 'Risk Metrics',
      'tutorial_risk_metrics_desc': 'Monitor your portfolio diversification and risk level. A well-diversified portfolio is more resilient!',
      'tutorial_milestone_progress_title': 'Quota Target',
      'tutorial_milestone_progress_desc': 'Your main objective! Earn enough profit to meet the quota before time runs out. Bonuses for exceeding it!',
      'tutorial_challenges_panel_title': 'Daily Challenges',
      'tutorial_challenges_panel_desc': 'Complete daily challenges for bonus rewards. New challenges appear each day - don\'t miss out!',
      'tutorial_recent_trades_title': 'Recent Trades',
      'tutorial_recent_trades_desc': 'View your latest trading activity. Click any trade to jump to that stock\'s trading view.',
      'tutorial_position_news_title': 'News Affecting Positions',
      'tutorial_position_news_desc': 'Stay informed! See news that impacts your current holdings. React quickly to maximize profits.',
      'tutorial_sectors_title': 'Sectors',
      'tutorial_sectors_desc': 'Explore different market sectors. Each has unique characteristics and stocks to trade.',
      'tutorial_stocks_title': 'Stocks',
      'tutorial_stocks_desc': 'Browse all available stocks. Check prices, trends, and analyst ratings before trading.',
      'tutorial_trading_title': 'Trading',
      'tutorial_trading_desc': 'Buy and sell stocks here. Go Long to bet on price increases, or Short to profit from declines.',
      'tutorial_positions_title': 'Positions',
      'tutorial_positions_desc': 'View your open trades and track your profits. Close positions to realize gains or cut losses.',
      'tutorial_upgrades_title': 'Upgrades',
      'tutorial_upgrades_desc': 'At the end of each day, choose an upgrade to boost your trading abilities!',
      'tutorial_prestige_title': 'Prestige Shop',
      'tutorial_prestige_desc': 'If you fail to meet quota, spend Prestige Points for permanent bonuses that persist across runs.',
      'tutorial_achievements_title': 'Achievements',
      'tutorial_achievements_desc': 'Complete challenges to earn permanent rewards that carry over to all your future games!',
      'tutorial_fintok_title': 'FinTok',
      'tutorial_fintok_desc': 'Get hot stock tips from social media influencers. But be careful - not all tips are reliable!',

      // FinTok UI
      'fintok_active': 'active',
      'fintok_no_tips': 'No tips yet...',
      'fintok_no_influencers': 'No influencers active yet',
      'fintok_appear_soon': 'They\'ll appear as you play!',
      'fintok_followers': 'Followers',
      'fintok_tips_given': 'Tips Given',
      'fintok_accuracy': 'Accuracy',
      'fintok_reputation': 'Reputation',
      'fintok_unknown': 'Unknown',
      'fintok_follow': 'Follow',
      'fintok_unfollow': 'Unfollow',
      'fintok_following': 'Following',
      'fintok_buy': 'BUY',
      'fintok_sell': 'SELL',
      'fintok_accurate': 'Accurate!',
      'fintok_wrong': 'Wrong!',
      'fintok_viral': 'VIRAL',
      'fintok_unreliable': 'UNRELIABLE',
      'fintok_excellent': 'Excellent',
      'fintok_good': 'Good',
      'fintok_average': 'Average',
      'fintok_poor': 'Poor',
      'fintok_terrible': 'Terrible',
      'fintok_joined': 'joined FinTok!',
      'fintok_left': 'left FinTok',

      // Stock signals
      'signal_on_sale': 'On Sale!',
      'signal_good_deal': 'Good Price',
      'signal_rising': 'Rising',
      'signal_falling': 'Falling',
      'signal_pricey': 'Pricey',
      'signal_overheated': 'Overheated!',

      'tutorial_sectors_intro_title': 'Welcome to Sectors!',
      'tutorial_sectors_intro_desc': 'Here you can see all market sectors. Click on a sector to see its stocks. Each sector reacts differently to market events!',
      'tutorial_stocks_intro_title': 'Stock List',
      'tutorial_stocks_intro_desc': 'This is your stock browser. Watch the price changes, check analyst ratings, and click Trade to open a position.',
      'tutorial_trading_intro_title': 'Ready to Trade!',
      'tutorial_trading_intro_desc': 'Select a stock and choose your position size. Go LONG if you think price will rise, or SHORT to profit from declines.',
      'tutorial_first_buy_title': 'Make Your First Trade!',
      'tutorial_first_buy_desc': 'Time to buy your first stock! Select shares and click BUY to open a long position. Good luck!',
      'tutorial_positions_intro_title': 'Your Positions',
      'tutorial_positions_intro_desc': 'Great job! Here you can see all your open trades. Watch your P&L and close positions when you want to take profits.',
      'tutorial_informant_title': 'The Informant',
      'tutorial_informant_desc': 'A mysterious insider just appeared! They offer valuable market intel - but it comes at a price. Choose wisely!',
      'tutorial_click_button': 'Click the button above',

      // Expert mode
      'expert_mode': 'Expert Mode',
      'expert_mode_desc': 'Show advanced trading indicators',

      // Notifications settings
      'price_alert_threshold': 'Price alert threshold',
      'price_alert_threshold_desc': 'Alert when a stock moves more than this %',

      // Leverage
      'leverage': 'Leverage',
      'leverage_desc': 'Multiply your gains and losses',
      'leverage_warning': 'Risk amplified',

      // Trailing stop
      'trailing_stop': 'Smart trailing (SL follows gains)',

      // Limit orders
      'limit_orders': 'Limit Orders',
      'limit_buy': 'Limit Buy',
      'limit_sell': 'Limit Sell',
      'target_price': 'Target Price',
      'waiting_for_price': 'Waiting for price to reach target...',
      'place_limit_buy': 'Place Buy Order',
      'place_limit_sell': 'Place Sell Order',
      'limit_order_placed': 'Limit order placed!',
      'limit_order_failed': 'Could not place order',

      // Player titles
      'title_beginner': 'Beginner',
      'title_novice': 'Novice',
      'title_apprentice': 'Apprentice',
      'title_trader': 'Trader',
      'title_veteran': 'Veteran',
      'title_expert': 'Expert',
      'title_legend': 'Legend',

      // Milestones
      'milestone_reached': 'Milestone Reached!',
      'milestone_1000': 'First Thousand',
      'milestone_2500': 'Getting Started',
      'milestone_5000': 'Halfway There',
      'milestone_10000': 'Five Figures!',
      'milestone_25000': 'Big League',
      'milestone_50000': 'Fortune Builder',
      'milestone_100000': 'Six Figures!',
      'milestone_250000': 'Quarter Million',
      'milestone_500000': 'Half Millionaire',
      'milestone_1000000': 'MILLIONAIRE!',
      'milestone_2500000': 'Multi-Millionaire',
      'milestone_5000000': 'High Roller',
      'milestone_10000000': 'Eight Figures!',
      'milestone_25000000': 'Tycoon',
      'milestone_50000000': 'Mogul',
      'milestone_100000000': 'Centimillionaire!',
      'milestone_500000000': 'Half Billionaire',
      'milestone_1000000000': 'BILLIONAIRE!',
      'milestone_10000000000': 'Mega Billionaire',
      'milestone_100000000000': 'Hectobillionaire',
      'milestone_1000000000000': 'TRILLIONAIRE!',

      // Personal bests
      'new_record': 'New Record!',
      'personal_best': 'Personal Best',
      'best_net_worth': 'Best Fortune',
      'best_day_profit': 'Best Day',
      'best_single_trade': 'Best Trade',
      'best_win_streak': 'Best Streak',
      'most_days_survived': 'Most Days',

      // End-of-day narratives
      'narrative_great_day': 'What an incredible day! Your portfolio soared!',
      'narrative_good_day': 'A solid day of gains. Keep it up!',
      'narrative_tough_day': 'Tough day on the market. Tomorrow is a new chance.',
      'narrative_small_loss': 'A small dip today. Nothing to worry about.',
      'narrative_flat_day': 'A quiet day on the market. Sometimes that\'s okay.',

      // Encouragement messages
      'hint_invest_cash': 'You have cash sitting idle — invest it!',
      'encourage_quota_met': 'Quota met! You\'re crushing it!',
      'encourage_hot_streak': 'You\'re on fire! Keep the streak going!',
      'encourage_dont_panic': 'Don\'t panic! The market always comes back.',
      'encourage_nice_trades': 'Nice trades today! Well played.',

      // Daily objective
      'daily_objective': 'Daily Goal',
      'earn_today': 'Earn {amount} today',
      'objective_met': 'On track!',

      // Trade of the day
      'trade_of_the_day': 'Trade of the Day',
      'analysts_recommend': 'Analysts recommend',

      // Favorites
      'favorites': 'Favorites',
      'add_to_favorites': 'Add to favorites',
      'remove_from_favorites': 'Remove from favorites',

      // Run summary
      'run_summary': 'Run Summary',
      'run_over_title': 'Run Over!',
      'days_survived': 'Days Survived',
      'winning_trades': 'Winning',
      'losing_trades': 'Losing',
      'total_profit': 'Total Profit',
      'best_trade_label': 'Best Trade',
      'worst_trade_label': 'Worst Trade',
      'best_streak': 'Best Streak',
      'quotas_met': 'Quotas Met',
      'final_fortune': 'Final Fortune',
      'peak_fortune': 'Peak Fortune',
      'pp_earned': 'PP Earned',
      'continue_to_tree': 'SPEND PRESTIGE POINTS',

      // Prestige preview
      'prestige_preview': 'Prestige Points earned',

      // Sell all
      'sell_all': 'SELL ALL',
      'sell_all_confirm': 'Sell all shares?',

      // Fun risk names
      'risk_low': 'Zen',
      'risk_medium': 'Bold',
      'risk_high': 'YOLO',
      'risk_very_high': 'Daredevil',

      // Tooltips
      'tooltip_fortune': 'Your total wealth including cash and investments',
      'tooltip_gains': 'How much profit you\'ve locked in by selling',
      'tooltip_current_gains': 'How much your open positions are worth right now',
      'tooltip_quota': 'The amount you need to earn before the deadline',
      'tooltip_win_rate': 'Percentage of trades that made money',
      'tooltip_diversification': 'How spread out your investments are',

      // Leaderboard
      'leaderboard': 'Best Runs',
      'no_runs_yet': 'No completed runs yet',
      'run_number': 'Run #{number}',

      // ── Talent Tree UI keys ──
      'talent_buy': 'BUY',
      'node_locked': 'LOCKED',
      'node_purchased': 'PURCHASED',
      'not_enough_pp': 'NOT ENOUGH PP',

      // ── Roots ──
      'upgrade_root_name': 'Starting Capital',
      'upgrade_root_desc': 'Your first step into the prestige tree',
      'upgrade_general_root_name': 'Starting Capital',
      'upgrade_general_root_desc': 'Your first step into the prestige tree',
      'upgrade_sector_root_name': 'Sector Mastery',
      'upgrade_sector_root_desc': 'Specialize in market sectors',

      // ══════════ TRADER branch ══════════
      // Spine
      'upgrade_tr_seed1_name': 'Seed Money I',
      'upgrade_tr_seed1_desc': 'Your first trading capital',
      'upgrade_tr_slot1_name': 'Extra Slot I',
      'upgrade_tr_slot1_desc': 'Expand your portfolio',
      'upgrade_tr_seed2_name': 'Seed Money II',
      'upgrade_tr_seed2_desc': 'Growing your seed fund',
      'upgrade_tr_slot2_name': 'Extra Slot II',
      'upgrade_tr_slot2_desc': 'More room to trade',
      'upgrade_tr_seed3_name': 'Seed Money III',
      'upgrade_tr_seed3_desc': 'Serious starting capital',
      'upgrade_tr_slot3_name': 'Extra Slot III',
      'upgrade_tr_slot3_desc': 'Diversify further',
      'upgrade_tr_slot4_name': 'Extra Slot IV',
      'upgrade_tr_slot4_desc': 'Portfolio expansion',
      'upgrade_tr_slot5_name': 'Extra Slot V',
      'upgrade_tr_slot5_desc': 'Major portfolio growth',
      'upgrade_tr_slot6_name': 'Extra Slot VI',
      'upgrade_tr_slot6_desc': 'Maximum capacity',
      'upgrade_tr_cap_name': 'Infinite Trader',
      'upgrade_tr_cap_desc': 'No limits on your portfolio',
      // Stop Loss / Take Profit
      'upgrade_tr_sl_name': 'Stop Loss',
      'upgrade_tr_sl_desc': 'Auto-sell when losses hit your threshold',
      'upgrade_tr_tp_name': 'Take Profit',
      'upgrade_tr_tp_desc': 'Auto-sell when gains hit your target',
      'upgrade_tr_trailing_name': 'Trailing Stop',
      'upgrade_tr_trailing_desc': 'Stop loss follows price upward automatically',
      'upgrade_tr_partial_tp_name': 'Partial Take Profit',
      'upgrade_tr_partial_tp_desc': 'Sell half at target, let the rest ride',
      'upgrade_tr_safety_name': 'Safety Net',
      'upgrade_tr_safety_desc': 'Your first stop loss trigger is softened',
      // Winning Streak
      'upgrade_tr_streak_name': 'Winning Streak',
      'upgrade_tr_streak_desc': 'Each consecutive win boosts the next',
      'upgrade_tr_hot_hand_name': 'Hot Hand',
      'upgrade_tr_hot_hand_desc': 'Your luck compounds the longer you ride it',
      'upgrade_tr_resilient_name': 'Resilient',
      'upgrade_tr_resilient_desc': 'A bad trade slows you down, not stops you',
      // Tempo Trading
      'upgrade_tr_qf1_name': 'Quick Flip I',
      'upgrade_tr_qf1_desc': 'Day trading pays a premium',
      'upgrade_tr_qf2_name': 'Quick Flip II',
      'upgrade_tr_qf2_desc': 'Sharper reflexes, bigger rewards',
      'upgrade_tr_scalper_name': 'Scalper',
      'upgrade_tr_scalper_desc': 'In and out with zero friction',
      'upgrade_tr_patient1_name': 'Patient Trader I',
      'upgrade_tr_patient1_desc': 'Good things come to those who wait',
      'upgrade_tr_patient2_name': 'Patient Trader II',
      'upgrade_tr_patient2_desc': 'Patience is a virtue',
      'upgrade_tr_diamond_name': 'Diamond Hands',
      'upgrade_tr_diamond_desc': 'Never let go of a winner',
      // Limit Orders
      'upgrade_tr_limit_orders_name': 'Limit Orders',
      'upgrade_tr_limit_orders_desc': 'Set a target price for auto buy or sell',
      'upgrade_tr_smart_orders_name': 'Smart Orders',
      'upgrade_tr_smart_orders_desc': 'Auto-attach stop loss and take profit to orders',
      // Profit Multipliers
      'upgrade_tr_profit1_name': 'Sharp Eye I',
      'upgrade_tr_profit1_desc': 'Spot opportunities others miss',
      'upgrade_tr_profit2_name': 'Sharp Eye II',
      'upgrade_tr_profit2_desc': 'Market patterns become clear',
      'upgrade_tr_profit3_name': 'Sharp Eye III',
      'upgrade_tr_profit3_desc': 'You see the matrix',
      'upgrade_tr_eagle_name': 'Eagle Eye',
      'upgrade_tr_eagle_desc': 'Nothing escapes your gaze',
      // Leverage
      'upgrade_tr_margin_name': 'Margin Account',
      'upgrade_tr_margin_desc': 'Access to borrowed capital',
      'upgrade_tr_lev15_name': 'Leverage x1.5',
      'upgrade_tr_lev15_desc': 'Increase your buying power',
      'upgrade_tr_lev2_name': 'Leverage x2',
      'upgrade_tr_lev2_desc': 'Double the stakes',
      'upgrade_tr_margin_shield_name': 'Margin Shield',
      'upgrade_tr_margin_shield_desc': 'Soften the blow of liquidation',
      'upgrade_tr_lev3_name': 'Leverage x3',
      'upgrade_tr_lev3_desc': 'Maximum risk, maximum reward',
      // Compound Interest
      'upgrade_tr_interest1_name': 'Interest I',
      'upgrade_tr_interest1_desc': 'Your cash starts working for you',
      'upgrade_tr_interest2_name': 'Interest II',
      'upgrade_tr_interest2_desc': 'Better rates, bigger returns',
      'upgrade_tr_interest3_name': 'Interest III',
      'upgrade_tr_interest3_desc': 'Premium banking privileges',

      // ══════════ SURVIVAL branch ══════════
      // Spine
      'upgrade_sv_day1_name': 'Extra Day I',
      'upgrade_sv_day1_desc': 'More time to meet your quota',
      'upgrade_sv_life1_name': 'Extra Life I',
      'upgrade_sv_life1_desc': 'Survive a failed quota',
      'upgrade_sv_day2_name': 'Extra Day II',
      'upgrade_sv_day2_desc': 'Extended trading window',
      'upgrade_sv_quota1_name': 'Quota Relief I',
      'upgrade_sv_quota1_desc': 'Lower the bar slightly',
      'upgrade_sv_life2_name': 'Extra Life II',
      'upgrade_sv_life2_desc': 'Another chance to recover',
      'upgrade_sv_quota2_name': 'Quota Relief II',
      'upgrade_sv_quota2_desc': 'More breathing room on targets',
      'upgrade_sv_day3_name': 'Extra Day III',
      'upgrade_sv_day3_desc': 'Maximum trading time',
      'upgrade_sv_cap_name': 'Last Stand',
      'upgrade_sv_cap_desc': 'Your final safety net',
      // Skip Boost
      'upgrade_sv_skip1_name': 'Skip Bonus I',
      'upgrade_sv_skip1_desc': 'More reward for skipping a quota',
      'upgrade_sv_skip2_name': 'Skip Bonus II',
      'upgrade_sv_skip2_desc': 'Bigger skip rewards',
      'upgrade_sv_skip3_name': 'Skip Streak',
      'upgrade_sv_skip3_desc': 'Consecutive skips compound',
      // Loss Recovery
      'upgrade_sv_recov1_name': 'Loss Recovery I',
      'upgrade_sv_recov1_desc': 'Recover a fraction of your losses',
      'upgrade_sv_recov2_name': 'Loss Recovery II',
      'upgrade_sv_recov2_desc': 'Better loss mitigation',
      'upgrade_sv_recov3_name': 'Loss Recovery III',
      'upgrade_sv_recov3_desc': 'Significant loss cushion',
      // Overtime
      'upgrade_sv_grace1_name': 'Overtime I',
      'upgrade_sv_grace1_desc': 'Emergency extra day on failed quota',
      'upgrade_sv_grace2_name': 'Overtime II',
      'upgrade_sv_grace2_desc': 'More time under pressure',
      'upgrade_sv_second_wind_name': 'Second Wind',
      'upgrade_sv_second_wind_desc': 'Bounce back stronger after using a life',
      // PP Boost
      'upgrade_sv_pp1_name': 'PP Boost I',
      'upgrade_sv_pp1_desc': 'Earn more prestige points',
      'upgrade_sv_pp2_name': 'PP Boost II',
      'upgrade_sv_pp2_desc': 'Greater prestige gains',
      'upgrade_sv_pp3_name': 'PP Boost III',
      'upgrade_sv_pp3_desc': 'Maximum prestige efficiency',
      // Early Finish
      'upgrade_sv_early1_name': 'Early Bird I',
      'upgrade_sv_early1_desc': 'Bonus PP for finishing quota early',
      'upgrade_sv_early2_name': 'Early Bird II',
      'upgrade_sv_early2_desc': 'Bigger early finish rewards',
      'upgrade_sv_speedrun_name': 'Speedrunner',
      'upgrade_sv_speedrun_desc': 'The ultimate time challenge reward',
      // Momentum
      'upgrade_sv_streak1_name': 'Hot Streak I',
      'upgrade_sv_streak1_desc': 'Consecutive quotas build momentum',
      'upgrade_sv_streak2_name': 'Hot Streak II',
      'upgrade_sv_streak2_desc': 'Stronger streak bonuses',
      'upgrade_sv_streak3_name': 'Unbreakable',
      'upgrade_sv_streak3_desc': 'Your streak persists even after using a life',

      // ══════════ AUTOMATION branch ══════════
      'upgrade_bt_hub_name': 'Automation',
      'upgrade_bt_hub_desc': 'Improve your trading robots',
      // Spine
      'upgrade_bt_1_name': 'Bot Boost I',
      'upgrade_bt_1_desc': 'Basic robot improvement',
      'upgrade_bt_2_name': 'Cheap Upgrades',
      'upgrade_bt_2_desc': 'Reduce robot upgrade costs',
      'upgrade_bt_3_name': 'Deep Pockets',
      'upgrade_bt_3_desc': 'Bigger robot budgets',
      'upgrade_bt_4_name': 'Bot Boost II',
      'upgrade_bt_4_desc': 'Advanced robot improvement',
      'upgrade_bt_5_name': 'Robot Slot',
      'upgrade_bt_5_desc': 'Unlock an extra slot',
      'upgrade_bt_6_name': 'AI Trading',
      'upgrade_bt_6_desc': 'Advanced robot features',
      'upgrade_bt_7_name': 'Quantum Bot',
      'upgrade_bt_7_desc': 'Ultimate automation',
      // Side branches
      'upgrade_bt_s1a_name': 'Auto-Sell',
      'upgrade_bt_s1a_desc': 'Auto TP/SL for bots',
      'upgrade_bt_s1b_name': 'Smart Exit',
      'upgrade_bt_s1b_desc': 'Bots exit on bad news',
      'upgrade_bt_s2a_name': 'Multi-Sector',
      'upgrade_bt_s2a_desc': 'Bots trade any sector',
      'upgrade_bt_s2b_name': 'Portfolio Bot',
      'upgrade_bt_s2b_desc': 'Bots balance portfolio',
      'upgrade_bt_s3a_name': 'Risk Bot',
      'upgrade_bt_s3a_desc': 'Bots avoid crash sectors',
      'upgrade_bt_s3b_name': 'Hedge Bot',
      'upgrade_bt_s3b_desc': 'Bots hedge positions',

      // ══════════ INTELLIGENCE branch ══════════
      'upgrade_in_hub_name': 'Intelligence',
      'upgrade_in_hub_desc': 'Information is power',
      // Spine
      'upgrade_in_1_name': 'News Radar',
      'upgrade_in_1_desc': "Preview tomorrow's news",
      'upgrade_in_2_name': 'Crystal Ball',
      'upgrade_in_2_desc': 'Precise tip values',
      'upgrade_in_3_name': 'Insider Access',
      'upgrade_in_3_desc': 'Free daily tip',
      'upgrade_in_4_name': 'FinTok Filter',
      'upgrade_in_4_desc': 'Spot unreliable advice',
      'upgrade_in_5_name': 'Deep Research',
      'upgrade_in_5_desc': 'More precise intel',
      'upgrade_in_6_name': 'Omniscience',
      'upgrade_in_6_desc': 'See the near future',
      // Side branches
      'upgrade_in_s1a_name': 'Analyst Network',
      'upgrade_in_s1a_desc': 'More analyst contacts',
      'upgrade_in_s1b_name': 'Insider Ring',
      'upgrade_in_s1b_desc': 'Tips from multiple sectors',
      'upgrade_in_s2a_name': 'Pattern Reader',
      'upgrade_in_s2a_desc': 'Identify chart patterns',
      'upgrade_in_s2b_name': 'Trend Spotter',
      'upgrade_in_s2b_desc': 'Identify trends early',
      'upgrade_in_s3a_name': 'Data Mining',
      'upgrade_in_s3a_desc': 'Auto-collect market data',
      'upgrade_in_s3b_name': 'Counter Intel',
      'upgrade_in_s3b_desc': 'Block bad news',
      'upgrade_in_s4a_name': 'Rumor Mill',
      'upgrade_in_s4a_desc': 'Spread rumors to move prices',
      'upgrade_in_s4b_name': 'Disinfo Shield',
      'upgrade_in_s4b_desc': 'Immune to fake news',

      // ══════════ SECTORS branch ══════════
      'upgrade_sc_hub_name': 'Sectors',
      'upgrade_sc_hub_desc': 'Unlock sector specializations',

      // ── Technology ──
      'upgrade_technology_t1_name': 'Tech T1',
      'upgrade_technology_t1_desc': 'Enter Tech sector & unlock Tier 1',
      'upgrade_technology_t2_name': 'Tech T2',
      'upgrade_technology_t2_desc': 'Unlock Tier 2 for Tech',
      'upgrade_technology_t3_name': 'Tech T3',
      'upgrade_technology_t3_desc': 'Unlock Tier 3 for Tech',
      'upgrade_technology_t1_profit_name': 'Tech Boost 1',
      'upgrade_technology_t1_profit_desc': '+15% profits in Tech',
      'upgrade_technology_t1_shield_name': 'Tech Shield 1',
      'upgrade_technology_t1_shield_desc': '-15% losses in Tech',
      'upgrade_technology_t1_income_name': 'Tech Income 1',
      'upgrade_technology_t1_income_desc': '+\$20/day from Tech',
      'upgrade_technology_t2_profit_name': 'Tech Boost 2',
      'upgrade_technology_t2_profit_desc': '+20% profits in Tech',
      'upgrade_technology_t2_shield_name': 'Tech Shield 2',
      'upgrade_technology_t2_shield_desc': '-20% losses in Tech',
      'upgrade_technology_t2_income_name': 'Tech Income 2',
      'upgrade_technology_t2_income_desc': '+\$40/day from Tech',
      'upgrade_technology_t3_profit_name': 'Tech Boost 3',
      'upgrade_technology_t3_profit_desc': '+25% profits in Tech',
      'upgrade_technology_t3_shield_name': 'Tech Shield 3',
      'upgrade_technology_t3_shield_desc': '-25% losses in Tech',
      'upgrade_technology_t3_income_name': 'Tech Income 3',
      'upgrade_technology_t3_income_desc': '+\$60/day from Tech',
      'upgrade_technology_cap_name': 'Tech Mastery',
      'upgrade_technology_cap_desc': 'Ultimate Tech specialization',

      // ── Healthcare ──
      'upgrade_healthcare_t1_name': 'Health T1',
      'upgrade_healthcare_t1_desc': 'Enter Health sector & unlock Tier 1',
      'upgrade_healthcare_t2_name': 'Health T2',
      'upgrade_healthcare_t2_desc': 'Unlock Tier 2 for Health',
      'upgrade_healthcare_t3_name': 'Health T3',
      'upgrade_healthcare_t3_desc': 'Unlock Tier 3 for Health',
      'upgrade_healthcare_t1_profit_name': 'Health Boost 1',
      'upgrade_healthcare_t1_profit_desc': '+15% profits in Health',
      'upgrade_healthcare_t1_shield_name': 'Health Shield 1',
      'upgrade_healthcare_t1_shield_desc': '-15% losses in Health',
      'upgrade_healthcare_t1_income_name': 'Health Income 1',
      'upgrade_healthcare_t1_income_desc': '+\$20/day from Health',
      'upgrade_healthcare_t2_profit_name': 'Health Boost 2',
      'upgrade_healthcare_t2_profit_desc': '+20% profits in Health',
      'upgrade_healthcare_t2_shield_name': 'Health Shield 2',
      'upgrade_healthcare_t2_shield_desc': '-20% losses in Health',
      'upgrade_healthcare_t2_income_name': 'Health Income 2',
      'upgrade_healthcare_t2_income_desc': '+\$40/day from Health',
      'upgrade_healthcare_t3_profit_name': 'Health Boost 3',
      'upgrade_healthcare_t3_profit_desc': '+25% profits in Health',
      'upgrade_healthcare_t3_shield_name': 'Health Shield 3',
      'upgrade_healthcare_t3_shield_desc': '-25% losses in Health',
      'upgrade_healthcare_t3_income_name': 'Health Income 3',
      'upgrade_healthcare_t3_income_desc': '+\$60/day from Health',
      'upgrade_healthcare_cap_name': 'Health Mastery',
      'upgrade_healthcare_cap_desc': 'Ultimate Health specialization',

      // ── Finance ──
      'upgrade_finance_t1_name': 'Finance T1',
      'upgrade_finance_t1_desc': 'Enter Finance sector & unlock Tier 1',
      'upgrade_finance_t2_name': 'Finance T2',
      'upgrade_finance_t2_desc': 'Unlock Tier 2 for Finance',
      'upgrade_finance_t3_name': 'Finance T3',
      'upgrade_finance_t3_desc': 'Unlock Tier 3 for Finance',
      'upgrade_finance_t1_profit_name': 'Finance Boost 1',
      'upgrade_finance_t1_profit_desc': '+15% profits in Finance',
      'upgrade_finance_t1_shield_name': 'Finance Shield 1',
      'upgrade_finance_t1_shield_desc': '-15% losses in Finance',
      'upgrade_finance_t1_income_name': 'Finance Income 1',
      'upgrade_finance_t1_income_desc': '+\$20/day from Finance',
      'upgrade_finance_t2_profit_name': 'Finance Boost 2',
      'upgrade_finance_t2_profit_desc': '+20% profits in Finance',
      'upgrade_finance_t2_shield_name': 'Finance Shield 2',
      'upgrade_finance_t2_shield_desc': '-20% losses in Finance',
      'upgrade_finance_t2_income_name': 'Finance Income 2',
      'upgrade_finance_t2_income_desc': '+\$40/day from Finance',
      'upgrade_finance_t3_profit_name': 'Finance Boost 3',
      'upgrade_finance_t3_profit_desc': '+25% profits in Finance',
      'upgrade_finance_t3_shield_name': 'Finance Shield 3',
      'upgrade_finance_t3_shield_desc': '-25% losses in Finance',
      'upgrade_finance_t3_income_name': 'Finance Income 3',
      'upgrade_finance_t3_income_desc': '+\$60/day from Finance',
      'upgrade_finance_cap_name': 'Finance Mastery',
      'upgrade_finance_cap_desc': 'Ultimate Finance specialization',

      // ── Energy ──
      'upgrade_energy_t1_name': 'Energy T1',
      'upgrade_energy_t1_desc': 'Enter Energy sector & unlock Tier 1',
      'upgrade_energy_t2_name': 'Energy T2',
      'upgrade_energy_t2_desc': 'Unlock Tier 2 for Energy',
      'upgrade_energy_t3_name': 'Energy T3',
      'upgrade_energy_t3_desc': 'Unlock Tier 3 for Energy',
      'upgrade_energy_t1_profit_name': 'Energy Boost 1',
      'upgrade_energy_t1_profit_desc': '+15% profits in Energy',
      'upgrade_energy_t1_shield_name': 'Energy Shield 1',
      'upgrade_energy_t1_shield_desc': '-15% losses in Energy',
      'upgrade_energy_t1_income_name': 'Energy Income 1',
      'upgrade_energy_t1_income_desc': '+\$20/day from Energy',
      'upgrade_energy_t2_profit_name': 'Energy Boost 2',
      'upgrade_energy_t2_profit_desc': '+20% profits in Energy',
      'upgrade_energy_t2_shield_name': 'Energy Shield 2',
      'upgrade_energy_t2_shield_desc': '-20% losses in Energy',
      'upgrade_energy_t2_income_name': 'Energy Income 2',
      'upgrade_energy_t2_income_desc': '+\$40/day from Energy',
      'upgrade_energy_t3_profit_name': 'Energy Boost 3',
      'upgrade_energy_t3_profit_desc': '+25% profits in Energy',
      'upgrade_energy_t3_shield_name': 'Energy Shield 3',
      'upgrade_energy_t3_shield_desc': '-25% losses in Energy',
      'upgrade_energy_t3_income_name': 'Energy Income 3',
      'upgrade_energy_t3_income_desc': '+\$60/day from Energy',
      'upgrade_energy_cap_name': 'Energy Mastery',
      'upgrade_energy_cap_desc': 'Ultimate Energy specialization',

      // ── Consumer Goods ──
      'upgrade_consumerGoods_t1_name': 'Consumer T1',
      'upgrade_consumerGoods_t1_desc': 'Enter Consumer sector & unlock Tier 1',
      'upgrade_consumerGoods_t2_name': 'Consumer T2',
      'upgrade_consumerGoods_t2_desc': 'Unlock Tier 2 for Consumer',
      'upgrade_consumerGoods_t3_name': 'Consumer T3',
      'upgrade_consumerGoods_t3_desc': 'Unlock Tier 3 for Consumer',
      'upgrade_consumerGoods_t1_profit_name': 'Consumer Boost 1',
      'upgrade_consumerGoods_t1_profit_desc': '+15% profits in Consumer',
      'upgrade_consumerGoods_t1_shield_name': 'Consumer Shield 1',
      'upgrade_consumerGoods_t1_shield_desc': '-15% losses in Consumer',
      'upgrade_consumerGoods_t1_income_name': 'Consumer Income 1',
      'upgrade_consumerGoods_t1_income_desc': '+\$20/day from Consumer',
      'upgrade_consumerGoods_t2_profit_name': 'Consumer Boost 2',
      'upgrade_consumerGoods_t2_profit_desc': '+20% profits in Consumer',
      'upgrade_consumerGoods_t2_shield_name': 'Consumer Shield 2',
      'upgrade_consumerGoods_t2_shield_desc': '-20% losses in Consumer',
      'upgrade_consumerGoods_t2_income_name': 'Consumer Income 2',
      'upgrade_consumerGoods_t2_income_desc': '+\$40/day from Consumer',
      'upgrade_consumerGoods_t3_profit_name': 'Consumer Boost 3',
      'upgrade_consumerGoods_t3_profit_desc': '+25% profits in Consumer',
      'upgrade_consumerGoods_t3_shield_name': 'Consumer Shield 3',
      'upgrade_consumerGoods_t3_shield_desc': '-25% losses in Consumer',
      'upgrade_consumerGoods_t3_income_name': 'Consumer Income 3',
      'upgrade_consumerGoods_t3_income_desc': '+\$60/day from Consumer',
      'upgrade_consumerGoods_cap_name': 'Consumer Mastery',
      'upgrade_consumerGoods_cap_desc': 'Ultimate Consumer specialization',

      // ── Industrial ──
      'upgrade_industrial_t1_name': 'Industry T1',
      'upgrade_industrial_t1_desc': 'Enter Industry sector & unlock Tier 1',
      'upgrade_industrial_t2_name': 'Industry T2',
      'upgrade_industrial_t2_desc': 'Unlock Tier 2 for Industry',
      'upgrade_industrial_t3_name': 'Industry T3',
      'upgrade_industrial_t3_desc': 'Unlock Tier 3 for Industry',
      'upgrade_industrial_t1_profit_name': 'Industry Boost 1',
      'upgrade_industrial_t1_profit_desc': '+15% profits in Industry',
      'upgrade_industrial_t1_shield_name': 'Industry Shield 1',
      'upgrade_industrial_t1_shield_desc': '-15% losses in Industry',
      'upgrade_industrial_t1_income_name': 'Industry Income 1',
      'upgrade_industrial_t1_income_desc': '+\$20/day from Industry',
      'upgrade_industrial_t2_profit_name': 'Industry Boost 2',
      'upgrade_industrial_t2_profit_desc': '+20% profits in Industry',
      'upgrade_industrial_t2_shield_name': 'Industry Shield 2',
      'upgrade_industrial_t2_shield_desc': '-20% losses in Industry',
      'upgrade_industrial_t2_income_name': 'Industry Income 2',
      'upgrade_industrial_t2_income_desc': '+\$40/day from Industry',
      'upgrade_industrial_t3_profit_name': 'Industry Boost 3',
      'upgrade_industrial_t3_profit_desc': '+25% profits in Industry',
      'upgrade_industrial_t3_shield_name': 'Industry Shield 3',
      'upgrade_industrial_t3_shield_desc': '-25% losses in Industry',
      'upgrade_industrial_t3_income_name': 'Industry Income 3',
      'upgrade_industrial_t3_income_desc': '+\$60/day from Industry',
      'upgrade_industrial_cap_name': 'Industry Mastery',
      'upgrade_industrial_cap_desc': 'Ultimate Industry specialization',

      // ── Real Estate ──
      'upgrade_realEstate_t1_name': 'Real Est. T1',
      'upgrade_realEstate_t1_desc': 'Enter Real Est. sector & unlock Tier 1',
      'upgrade_realEstate_t2_name': 'Real Est. T2',
      'upgrade_realEstate_t2_desc': 'Unlock Tier 2 for Real Est.',
      'upgrade_realEstate_t3_name': 'Real Est. T3',
      'upgrade_realEstate_t3_desc': 'Unlock Tier 3 for Real Est.',
      'upgrade_realEstate_t1_profit_name': 'Real Est. Boost 1',
      'upgrade_realEstate_t1_profit_desc': '+15% profits in Real Est.',
      'upgrade_realEstate_t1_shield_name': 'Real Est. Shield 1',
      'upgrade_realEstate_t1_shield_desc': '-15% losses in Real Est.',
      'upgrade_realEstate_t1_income_name': 'Real Est. Income 1',
      'upgrade_realEstate_t1_income_desc': '+\$20/day from Real Est.',
      'upgrade_realEstate_t2_profit_name': 'Real Est. Boost 2',
      'upgrade_realEstate_t2_profit_desc': '+20% profits in Real Est.',
      'upgrade_realEstate_t2_shield_name': 'Real Est. Shield 2',
      'upgrade_realEstate_t2_shield_desc': '-20% losses in Real Est.',
      'upgrade_realEstate_t2_income_name': 'Real Est. Income 2',
      'upgrade_realEstate_t2_income_desc': '+\$40/day from Real Est.',
      'upgrade_realEstate_t3_profit_name': 'Real Est. Boost 3',
      'upgrade_realEstate_t3_profit_desc': '+25% profits in Real Est.',
      'upgrade_realEstate_t3_shield_name': 'Real Est. Shield 3',
      'upgrade_realEstate_t3_shield_desc': '-25% losses in Real Est.',
      'upgrade_realEstate_t3_income_name': 'Real Est. Income 3',
      'upgrade_realEstate_t3_income_desc': '+\$60/day from Real Est.',
      'upgrade_realEstate_cap_name': 'Real Est. Mastery',
      'upgrade_realEstate_cap_desc': 'Ultimate Real Est. specialization',

      // ── Telecommunications ──
      'upgrade_telecommunications_t1_name': 'Telecom T1',
      'upgrade_telecommunications_t1_desc': 'Enter Telecom sector & unlock Tier 1',
      'upgrade_telecommunications_t2_name': 'Telecom T2',
      'upgrade_telecommunications_t2_desc': 'Unlock Tier 2 for Telecom',
      'upgrade_telecommunications_t3_name': 'Telecom T3',
      'upgrade_telecommunications_t3_desc': 'Unlock Tier 3 for Telecom',
      'upgrade_telecommunications_t1_profit_name': 'Telecom Boost 1',
      'upgrade_telecommunications_t1_profit_desc': '+15% profits in Telecom',
      'upgrade_telecommunications_t1_shield_name': 'Telecom Shield 1',
      'upgrade_telecommunications_t1_shield_desc': '-15% losses in Telecom',
      'upgrade_telecommunications_t1_income_name': 'Telecom Income 1',
      'upgrade_telecommunications_t1_income_desc': '+\$20/day from Telecom',
      'upgrade_telecommunications_t2_profit_name': 'Telecom Boost 2',
      'upgrade_telecommunications_t2_profit_desc': '+20% profits in Telecom',
      'upgrade_telecommunications_t2_shield_name': 'Telecom Shield 2',
      'upgrade_telecommunications_t2_shield_desc': '-20% losses in Telecom',
      'upgrade_telecommunications_t2_income_name': 'Telecom Income 2',
      'upgrade_telecommunications_t2_income_desc': '+\$40/day from Telecom',
      'upgrade_telecommunications_t3_profit_name': 'Telecom Boost 3',
      'upgrade_telecommunications_t3_profit_desc': '+25% profits in Telecom',
      'upgrade_telecommunications_t3_shield_name': 'Telecom Shield 3',
      'upgrade_telecommunications_t3_shield_desc': '-25% losses in Telecom',
      'upgrade_telecommunications_t3_income_name': 'Telecom Income 3',
      'upgrade_telecommunications_t3_income_desc': '+\$60/day from Telecom',
      'upgrade_telecommunications_cap_name': 'Telecom Mastery',
      'upgrade_telecommunications_cap_desc': 'Ultimate Telecom specialization',

      // ── Materials ──
      'upgrade_materials_t1_name': 'Materials T1',
      'upgrade_materials_t1_desc': 'Enter Materials sector & unlock Tier 1',
      'upgrade_materials_t2_name': 'Materials T2',
      'upgrade_materials_t2_desc': 'Unlock Tier 2 for Materials',
      'upgrade_materials_t3_name': 'Materials T3',
      'upgrade_materials_t3_desc': 'Unlock Tier 3 for Materials',
      'upgrade_materials_t1_profit_name': 'Materials Boost 1',
      'upgrade_materials_t1_profit_desc': '+15% profits in Materials',
      'upgrade_materials_t1_shield_name': 'Materials Shield 1',
      'upgrade_materials_t1_shield_desc': '-15% losses in Materials',
      'upgrade_materials_t1_income_name': 'Materials Income 1',
      'upgrade_materials_t1_income_desc': '+\$20/day from Materials',
      'upgrade_materials_t2_profit_name': 'Materials Boost 2',
      'upgrade_materials_t2_profit_desc': '+20% profits in Materials',
      'upgrade_materials_t2_shield_name': 'Materials Shield 2',
      'upgrade_materials_t2_shield_desc': '-20% losses in Materials',
      'upgrade_materials_t2_income_name': 'Materials Income 2',
      'upgrade_materials_t2_income_desc': '+\$40/day from Materials',
      'upgrade_materials_t3_profit_name': 'Materials Boost 3',
      'upgrade_materials_t3_profit_desc': '+25% profits in Materials',
      'upgrade_materials_t3_shield_name': 'Materials Shield 3',
      'upgrade_materials_t3_shield_desc': '-25% losses in Materials',
      'upgrade_materials_t3_income_name': 'Materials Income 3',
      'upgrade_materials_t3_income_desc': '+\$60/day from Materials',
      'upgrade_materials_cap_name': 'Materials Mastery',
      'upgrade_materials_cap_desc': 'Ultimate Materials specialization',

      // ── Utilities ──
      'upgrade_utilities_t1_name': 'Utilities T1',
      'upgrade_utilities_t1_desc': 'Enter Utilities sector & unlock Tier 1',
      'upgrade_utilities_t2_name': 'Utilities T2',
      'upgrade_utilities_t2_desc': 'Unlock Tier 2 for Utilities',
      'upgrade_utilities_t3_name': 'Utilities T3',
      'upgrade_utilities_t3_desc': 'Unlock Tier 3 for Utilities',
      'upgrade_utilities_t1_profit_name': 'Utilities Boost 1',
      'upgrade_utilities_t1_profit_desc': '+15% profits in Utilities',
      'upgrade_utilities_t1_shield_name': 'Utilities Shield 1',
      'upgrade_utilities_t1_shield_desc': '-15% losses in Utilities',
      'upgrade_utilities_t1_income_name': 'Utilities Income 1',
      'upgrade_utilities_t1_income_desc': '+\$20/day from Utilities',
      'upgrade_utilities_t2_profit_name': 'Utilities Boost 2',
      'upgrade_utilities_t2_profit_desc': '+20% profits in Utilities',
      'upgrade_utilities_t2_shield_name': 'Utilities Shield 2',
      'upgrade_utilities_t2_shield_desc': '-20% losses in Utilities',
      'upgrade_utilities_t2_income_name': 'Utilities Income 2',
      'upgrade_utilities_t2_income_desc': '+\$40/day from Utilities',
      'upgrade_utilities_t3_profit_name': 'Utilities Boost 3',
      'upgrade_utilities_t3_profit_desc': '+25% profits in Utilities',
      'upgrade_utilities_t3_shield_name': 'Utilities Shield 3',
      'upgrade_utilities_t3_shield_desc': '-25% losses in Utilities',
      'upgrade_utilities_t3_income_name': 'Utilities Income 3',
      'upgrade_utilities_t3_income_desc': '+\$60/day from Utilities',
      'upgrade_utilities_cap_name': 'Utilities Mastery',
      'upgrade_utilities_cap_desc': 'Ultimate Utilities specialization',

      // ── Gaming ──
      'upgrade_gaming_t1_name': 'Gaming T1',
      'upgrade_gaming_t1_desc': 'Enter Gaming sector & unlock Tier 1',
      'upgrade_gaming_t2_name': 'Gaming T2',
      'upgrade_gaming_t2_desc': 'Unlock Tier 2 for Gaming',
      'upgrade_gaming_t3_name': 'Gaming T3',
      'upgrade_gaming_t3_desc': 'Unlock Tier 3 for Gaming',
      'upgrade_gaming_t1_profit_name': 'Gaming Boost 1',
      'upgrade_gaming_t1_profit_desc': '+15% profits in Gaming',
      'upgrade_gaming_t1_shield_name': 'Gaming Shield 1',
      'upgrade_gaming_t1_shield_desc': '-15% losses in Gaming',
      'upgrade_gaming_t1_income_name': 'Gaming Income 1',
      'upgrade_gaming_t1_income_desc': '+\$20/day from Gaming',
      'upgrade_gaming_t2_profit_name': 'Gaming Boost 2',
      'upgrade_gaming_t2_profit_desc': '+20% profits in Gaming',
      'upgrade_gaming_t2_shield_name': 'Gaming Shield 2',
      'upgrade_gaming_t2_shield_desc': '-20% losses in Gaming',
      'upgrade_gaming_t2_income_name': 'Gaming Income 2',
      'upgrade_gaming_t2_income_desc': '+\$40/day from Gaming',
      'upgrade_gaming_t3_profit_name': 'Gaming Boost 3',
      'upgrade_gaming_t3_profit_desc': '+25% profits in Gaming',
      'upgrade_gaming_t3_shield_name': 'Gaming Shield 3',
      'upgrade_gaming_t3_shield_desc': '-25% losses in Gaming',
      'upgrade_gaming_t3_income_name': 'Gaming Income 3',
      'upgrade_gaming_t3_income_desc': '+\$60/day from Gaming',
      'upgrade_gaming_cap_name': 'Gaming Mastery',
      'upgrade_gaming_cap_desc': 'Ultimate Gaming specialization',

      // ── Crypto ──
      'upgrade_crypto_t1_name': 'Crypto T1',
      'upgrade_crypto_t1_desc': 'Enter Crypto sector & unlock Tier 1',
      'upgrade_crypto_t2_name': 'Crypto T2',
      'upgrade_crypto_t2_desc': 'Unlock Tier 2 for Crypto',
      'upgrade_crypto_t3_name': 'Crypto T3',
      'upgrade_crypto_t3_desc': 'Unlock Tier 3 for Crypto',
      'upgrade_crypto_t1_profit_name': 'Crypto Boost 1',
      'upgrade_crypto_t1_profit_desc': '+15% profits in Crypto',
      'upgrade_crypto_t1_shield_name': 'Crypto Shield 1',
      'upgrade_crypto_t1_shield_desc': '-15% losses in Crypto',
      'upgrade_crypto_t1_income_name': 'Crypto Income 1',
      'upgrade_crypto_t1_income_desc': '+\$20/day from Crypto',
      'upgrade_crypto_t2_profit_name': 'Crypto Boost 2',
      'upgrade_crypto_t2_profit_desc': '+20% profits in Crypto',
      'upgrade_crypto_t2_shield_name': 'Crypto Shield 2',
      'upgrade_crypto_t2_shield_desc': '-20% losses in Crypto',
      'upgrade_crypto_t2_income_name': 'Crypto Income 2',
      'upgrade_crypto_t2_income_desc': '+\$40/day from Crypto',
      'upgrade_crypto_t3_profit_name': 'Crypto Boost 3',
      'upgrade_crypto_t3_profit_desc': '+25% profits in Crypto',
      'upgrade_crypto_t3_shield_name': 'Crypto Shield 3',
      'upgrade_crypto_t3_shield_desc': '-25% losses in Crypto',
      'upgrade_crypto_t3_income_name': 'Crypto Income 3',
      'upgrade_crypto_t3_income_desc': '+\$60/day from Crypto',
      'upgrade_crypto_cap_name': 'Crypto Mastery',
      'upgrade_crypto_cap_desc': 'Ultimate Crypto specialization',

      // ── Aerospace ──
      'upgrade_aerospace_t1_name': 'Aero T1',
      'upgrade_aerospace_t1_desc': 'Enter Aero sector & unlock Tier 1',
      'upgrade_aerospace_t2_name': 'Aero T2',
      'upgrade_aerospace_t2_desc': 'Unlock Tier 2 for Aero',
      'upgrade_aerospace_t3_name': 'Aero T3',
      'upgrade_aerospace_t3_desc': 'Unlock Tier 3 for Aero',
      'upgrade_aerospace_t1_profit_name': 'Aero Boost 1',
      'upgrade_aerospace_t1_profit_desc': '+15% profits in Aero',
      'upgrade_aerospace_t1_shield_name': 'Aero Shield 1',
      'upgrade_aerospace_t1_shield_desc': '-15% losses in Aero',
      'upgrade_aerospace_t1_income_name': 'Aero Income 1',
      'upgrade_aerospace_t1_income_desc': '+\$20/day from Aero',
      'upgrade_aerospace_t2_profit_name': 'Aero Boost 2',
      'upgrade_aerospace_t2_profit_desc': '+20% profits in Aero',
      'upgrade_aerospace_t2_shield_name': 'Aero Shield 2',
      'upgrade_aerospace_t2_shield_desc': '-20% losses in Aero',
      'upgrade_aerospace_t2_income_name': 'Aero Income 2',
      'upgrade_aerospace_t2_income_desc': '+\$40/day from Aero',
      'upgrade_aerospace_t3_profit_name': 'Aero Boost 3',
      'upgrade_aerospace_t3_profit_desc': '+25% profits in Aero',
      'upgrade_aerospace_t3_shield_name': 'Aero Shield 3',
      'upgrade_aerospace_t3_shield_desc': '-25% losses in Aero',
      'upgrade_aerospace_t3_income_name': 'Aero Income 3',
      'upgrade_aerospace_t3_income_desc': '+\$60/day from Aero',
      'upgrade_aerospace_cap_name': 'Aero Mastery',
      'upgrade_aerospace_cap_desc': 'Ultimate Aero specialization',

      // ── Commodities ──
      'upgrade_commodities_t1_name': 'Commod. T1',
      'upgrade_commodities_t1_desc': 'Enter Commod. sector & unlock Tier 1',
      'upgrade_commodities_t2_name': 'Commod. T2',
      'upgrade_commodities_t2_desc': 'Unlock Tier 2 for Commod.',
      'upgrade_commodities_t3_name': 'Commod. T3',
      'upgrade_commodities_t3_desc': 'Unlock Tier 3 for Commod.',
      'upgrade_commodities_t1_profit_name': 'Commod. Boost 1',
      'upgrade_commodities_t1_profit_desc': '+15% profits in Commod.',
      'upgrade_commodities_t1_shield_name': 'Commod. Shield 1',
      'upgrade_commodities_t1_shield_desc': '-15% losses in Commod.',
      'upgrade_commodities_t1_income_name': 'Commod. Income 1',
      'upgrade_commodities_t1_income_desc': '+\$20/day from Commod.',
      'upgrade_commodities_t2_profit_name': 'Commod. Boost 2',
      'upgrade_commodities_t2_profit_desc': '+20% profits in Commod.',
      'upgrade_commodities_t2_shield_name': 'Commod. Shield 2',
      'upgrade_commodities_t2_shield_desc': '-20% losses in Commod.',
      'upgrade_commodities_t2_income_name': 'Commod. Income 2',
      'upgrade_commodities_t2_income_desc': '+\$40/day from Commod.',
      'upgrade_commodities_t3_profit_name': 'Commod. Boost 3',
      'upgrade_commodities_t3_profit_desc': '+25% profits in Commod.',
      'upgrade_commodities_t3_shield_name': 'Commod. Shield 3',
      'upgrade_commodities_t3_shield_desc': '-25% losses in Commod.',
      'upgrade_commodities_t3_income_name': 'Commod. Income 3',
      'upgrade_commodities_t3_income_desc': '+\$60/day from Commod.',
      'upgrade_commodities_cap_name': 'Commod. Mastery',
      'upgrade_commodities_cap_desc': 'Ultimate Commod. specialization',

      // ── Forex ──
      'upgrade_forex_t1_name': 'Forex T1',
      'upgrade_forex_t1_desc': 'Enter Forex sector & unlock Tier 1',
      'upgrade_forex_t2_name': 'Forex T2',
      'upgrade_forex_t2_desc': 'Unlock Tier 2 for Forex',
      'upgrade_forex_t3_name': 'Forex T3',
      'upgrade_forex_t3_desc': 'Unlock Tier 3 for Forex',
      'upgrade_forex_t1_profit_name': 'Forex Boost 1',
      'upgrade_forex_t1_profit_desc': '+15% profits in Forex',
      'upgrade_forex_t1_shield_name': 'Forex Shield 1',
      'upgrade_forex_t1_shield_desc': '-15% losses in Forex',
      'upgrade_forex_t1_income_name': 'Forex Income 1',
      'upgrade_forex_t1_income_desc': '+\$20/day from Forex',
      'upgrade_forex_t2_profit_name': 'Forex Boost 2',
      'upgrade_forex_t2_profit_desc': '+20% profits in Forex',
      'upgrade_forex_t2_shield_name': 'Forex Shield 2',
      'upgrade_forex_t2_shield_desc': '-20% losses in Forex',
      'upgrade_forex_t2_income_name': 'Forex Income 2',
      'upgrade_forex_t2_income_desc': '+\$40/day from Forex',
      'upgrade_forex_t3_profit_name': 'Forex Boost 3',
      'upgrade_forex_t3_profit_desc': '+25% profits in Forex',
      'upgrade_forex_t3_shield_name': 'Forex Shield 3',
      'upgrade_forex_t3_shield_desc': '-25% losses in Forex',
      'upgrade_forex_t3_income_name': 'Forex Income 3',
      'upgrade_forex_t3_income_desc': '+\$60/day from Forex',
      'upgrade_forex_cap_name': 'Forex Mastery',
      'upgrade_forex_cap_desc': 'Ultimate Forex specialization',

      // ── Indices ──
      'upgrade_indices_t1_name': 'Indices T1',
      'upgrade_indices_t1_desc': 'Enter Indices sector & unlock Tier 1',
      'upgrade_indices_t2_name': 'Indices T2',
      'upgrade_indices_t2_desc': 'Unlock Tier 2 for Indices',
      'upgrade_indices_t3_name': 'Indices T3',
      'upgrade_indices_t3_desc': 'Unlock Tier 3 for Indices',
      'upgrade_indices_t1_profit_name': 'Indices Boost 1',
      'upgrade_indices_t1_profit_desc': '+15% profits in Indices',
      'upgrade_indices_t1_shield_name': 'Indices Shield 1',
      'upgrade_indices_t1_shield_desc': '-15% losses in Indices',
      'upgrade_indices_t1_income_name': 'Indices Income 1',
      'upgrade_indices_t1_income_desc': '+\$20/day from Indices',
      'upgrade_indices_t2_profit_name': 'Indices Boost 2',
      'upgrade_indices_t2_profit_desc': '+20% profits in Indices',
      'upgrade_indices_t2_shield_name': 'Indices Shield 2',
      'upgrade_indices_t2_shield_desc': '-20% losses in Indices',
      'upgrade_indices_t2_income_name': 'Indices Income 2',
      'upgrade_indices_t2_income_desc': '+\$40/day from Indices',
      'upgrade_indices_t3_profit_name': 'Indices Boost 3',
      'upgrade_indices_t3_profit_desc': '+25% profits in Indices',
      'upgrade_indices_t3_shield_name': 'Indices Shield 3',
      'upgrade_indices_t3_shield_desc': '-25% losses in Indices',
      'upgrade_indices_t3_income_name': 'Indices Income 3',
      'upgrade_indices_t3_income_desc': '+\$60/day from Indices',
      'upgrade_indices_cap_name': 'Indices Mastery',
      'upgrade_indices_cap_desc': 'Ultimate Indices specialization',

      // ── Automation branch: robot slots ──
      'upgrade_auto_slot_1_name': 'Robot Alpha',
      'upgrade_auto_slot_1_desc': 'Unlock robot trading slot 1',
      'upgrade_auto_slot_2_name': 'Robot Beta',
      'upgrade_auto_slot_2_desc': 'Unlock robot trading slot 2',
      'upgrade_auto_slot_3_name': 'Robot Gamma',
      'upgrade_auto_slot_3_desc': 'Unlock robot trading slot 3',
      'upgrade_auto_slot_4_name': 'Robot Delta',
      'upgrade_auto_slot_4_desc': 'Unlock robot trading slot 4',
      'upgrade_auto_slot_5_name': 'Robot Epsilon',
      'upgrade_auto_slot_5_desc': 'Unlock robot trading slot 5',
      'upgrade_auto_slot_6_name': 'Robot Zeta',
      'upgrade_auto_slot_6_desc': 'Unlock robot trading slot 6',
      'upgrade_auto_slot_7_name': 'Robot Eta',
      'upgrade_auto_slot_7_desc': 'Unlock robot trading slot 7',
      'upgrade_auto_slot_8_name': 'Robot Theta',
      'upgrade_auto_slot_8_desc': 'Unlock robot trading slot 8',
      'upgrade_auto_slot_9_name': 'Robot Iota',
      'upgrade_auto_slot_9_desc': 'Unlock robot trading slot 9',
      'upgrade_auto_slot_10_name': 'Robot Kappa',
      'upgrade_auto_slot_10_desc': 'Unlock robot trading slot 10',
      // ── Global automation branches ──
      'upgrade_auto_disc1_name': 'Bulk Discount I',
      'upgrade_auto_disc1_desc': 'Negotiate better rates for all robots',
      'upgrade_auto_disc2_name': 'Bulk Discount II',
      'upgrade_auto_disc2_desc': 'Volume discounts on robot upgrades',
      'upgrade_auto_disc3_name': 'Bulk Discount III',
      'upgrade_auto_disc3_desc': 'Maximum cost efficiency',
      'upgrade_auto_lvl1_name': 'Boot Camp I',
      'upgrade_auto_lvl1_desc': 'All robots start pre-trained',
      'upgrade_auto_lvl2_name': 'Boot Camp II',
      'upgrade_auto_lvl2_desc': 'Advanced robot training program',
      'upgrade_auto_lvl3_name': 'Boot Camp III',
      'upgrade_auto_lvl3_desc': 'Elite robot training',
      'upgrade_auto_collect_name': 'Auto-Collect',
      'upgrade_auto_collect_desc': 'Automatically collect all robot wallets',
      'upgrade_auto_seed1_name': 'Startup Fund I',
      'upgrade_auto_seed1_desc': 'Give robots a head start',
      'upgrade_auto_seed2_name': 'Startup Fund II',
      'upgrade_auto_seed2_desc': 'Bigger robot budgets',
      'upgrade_auto_seed3_name': 'Startup Fund III',
      'upgrade_auto_seed3_desc': 'Serious robot capital',
      'upgrade_auto_wr1_name': 'Calibration I',
      'upgrade_auto_wr1_desc': 'Better algorithms for all robots',
      'upgrade_auto_wr2_name': 'Calibration II',
      'upgrade_auto_wr2_desc': 'Fine-tuned decision engines',
      'upgrade_auto_wr3_name': 'Calibration III',
      'upgrade_auto_wr3_desc': 'State-of-the-art trading AI',
      'upgrade_auto_speed1_name': 'Overclock I',
      'upgrade_auto_speed1_desc': 'Robots execute trades faster',
      'upgrade_auto_speed2_name': 'Overclock II',
      'upgrade_auto_speed2_desc': 'Maximum robot throughput',

      // ═══ Intelligence Branch ═══
      // Spine
      'upgrade_in_reroll1_name': 'Free Reroll I',
      'upgrade_in_reroll1_desc': 'Better options at no cost',
      'upgrade_in_luck1_name': 'Lucky Charm',
      'upgrade_in_luck1_desc': 'Fortune smiles upon your shop',
      'upgrade_in_reroll2_name': 'Free Reroll II',
      'upgrade_in_reroll2_desc': 'Even more free rerolls',
      'upgrade_in_choice_name': 'Quick Learner',
      'upgrade_in_choice_desc': 'See more upgrade options each day',
      'upgrade_in_luck2_name': 'Fortune Favored',
      'upgrade_in_luck2_desc': 'Rare upgrades appear more often',
      'upgrade_in_reroll3_name': 'Free Reroll III',
      'upgrade_in_reroll3_desc': 'Maximum free rerolls',
      'upgrade_in_luck3_name': 'Golden Touch',
      'upgrade_in_luck3_desc': 'Greatly increased rare upgrade chance',
      'upgrade_in_cap_name': 'Market Veteran',
      'upgrade_in_cap_desc': 'Free upgrade at start + guaranteed rare',
      // Secret Informant
      'upgrade_in_tip_free1_name': 'Free Intel I',
      'upgrade_in_tip_free1_desc': 'One tip on the house each day',
      'upgrade_in_tip_free2_name': 'Free Intel II',
      'upgrade_in_tip_free2_desc': 'Another free daily tip',
      'upgrade_in_tip_disc1_name': 'Discount I',
      'upgrade_in_tip_disc1_desc': 'Cheaper intel from your sources',
      'upgrade_in_tip_disc2_name': 'Discount II',
      'upgrade_in_tip_disc2_desc': 'Deep discounts on all tips',
      'upgrade_in_tip_exact_name': 'Exact Intel',
      'upgrade_in_tip_exact_desc': 'Tips reveal the precise percentage',
      // FintTok
      'upgrade_in_ftk_acc1_name': 'Better Sources I',
      'upgrade_in_ftk_acc1_desc': 'Influencers are slightly more reliable',
      'upgrade_in_ftk_acc2_name': 'Better Sources II',
      'upgrade_in_ftk_acc2_desc': 'Even more trustworthy content',
      'upgrade_in_ftk_slot1_name': 'Extra Influencer I',
      'upgrade_in_ftk_slot1_desc': 'Room for one more voice in your feed',
      'upgrade_in_ftk_slot2_name': 'Extra Influencer II',
      'upgrade_in_ftk_slot2_desc': 'An even bigger FintTok feed',
      'upgrade_in_ftk_flag_name': 'Flag Bad Tips',
      'upgrade_in_ftk_flag_desc': 'Unreliable tips are marked with a warning',
      // News & Events
      'upgrade_in_news1_name': 'Extra News I',
      'upgrade_in_news1_desc': 'More daily market news',
      'upgrade_in_news2_name': 'Extra News II',
      'upgrade_in_news2_desc': 'Even more market coverage',
      'upgrade_in_block1_name': 'Block Event',
      'upgrade_in_block1_desc': 'Cancel one negative event per run',
      'upgrade_in_disinfo_name': 'Disinfo Shield',
      'upgrade_in_disinfo_desc': 'Immune to false news and market manipulation',
      // Advanced Informant
      'upgrade_in_tip_prec1_name': 'Precision I',
      'upgrade_in_tip_prec1_desc': 'More accurate intel from your sources',
      'upgrade_in_tip_prec2_name': 'Precision II',
      'upgrade_in_tip_prec2_desc': 'Near-perfect market intelligence',
      'upgrade_in_tip_free3_name': 'Free Intel III',
      'upgrade_in_tip_free3_desc': 'Maximum free daily intelligence',
    },

    'fr': {
      // Paramètres
      'settings': 'Paramètres',
      'game': 'Jeu',
      'theme': 'Thème',
      'language': 'Langue',
      'dark_themes': 'Thèmes Sombres',
      'light_themes': 'Thèmes Clairs',
      'display': 'Affichage',
      'fullscreen': 'Plein écran',
      'sound': 'Effets sonores',
      'save': 'Sauvegarder',
      'load': 'Charger',
      'export_save': 'Exporter la sauvegarde',
      'import_save': 'Importer une sauvegarde',
      'reset_save': 'Réinitialiser le jeu',
      'reset_save_warning': 'Cela supprimera définitivement toute votre progression et démarrera une nouvelle partie. Cette action est irréversible !',
      'reset_save_success': 'Jeu réinitialisé avec succès !',
      'export_success': 'Sauvegarde exportée avec succès !',
      'import_success': 'Sauvegarde importée avec succès !',
      'import_error': 'Erreur lors de l\'import. Fichier invalide.',
      'cancel': 'Annuler',
      'confirm': 'Confirmer',
      'warning': 'Attention',
      'close': 'Fermer',
      'back': 'Retour',
      // Portfolio & positions
      'close_all_positions': 'Tout Liquider',
      'close_all_confirm': 'Voulez-vous vraiment fermer les {count} positions au prix du marché ?',
      'closed_all_positions': '{count} positions fermées.',
      'close_all': 'Tout Fermer',
      // Informant
      'secret_informant': 'Informateur Secret',
      'send_away': 'Renvoyer',
      'purchased': 'Acheté',
      'sentiment_bullish': 'HAUSSIER',
      'sentiment_bearish': 'BAISSIER',
      // Trading
      'bonus_shares': 'Actions bonus',
      'total_shares_label': 'Total actions',

      // Notifications
      'notifications': 'Notifications',
      'new': 'nouveau',
      'mark_all_read': 'Tout marquer comme lu',
      'clear_all': 'Tout effacer',
      'no_notifications': 'Aucune notification',
      'no_notifications_desc': 'Vous êtes à jour !',
      'price_alert': 'Alerte Prix',
      'breaking_news': 'Flash Info',
      'achievement_unlocked': 'Succès Débloqué !',
      'warning_alert': 'Attention',
      'bonus_received': 'Bonus Reçu',
      'special_event': 'Événement Spécial',

      // Succès
      'achievements': 'Succès',
      'completed': 'complété',
      'unclaimed_rewards': 'récompenses non réclamées',
      'tap_to_claim': 'Appuyez pour réclamer',
      'rewards_claimed': 'Récompenses Réclamées !',
      'ok': 'OK',
      'no_achievements_yet': 'Aucun succès découvert',
      'completed_on': 'Complété le',
      'achievement_category_trading': 'Trading',
      'achievement_category_profit': 'Profits',
      'achievement_category_portfolio': 'Portfolio',
      'achievement_category_milestone': 'Étapes',
      'achievement_category_risk': 'Risque',
      'achievement_category_market': 'Marché',
      'achievement_category_secret': 'Secret',

      // Jeu
      'day': 'Jour',
      'year': 'Année',
      'cash': 'Cash',
      'portfolio': 'Fortune',
      'net_worth': 'Fortune',
      'quota': 'Quota',
      'quota_target': 'Objectif',
      'quota_progress': 'Progression',
      'days_left': 'jours restants',
      'buy': 'Acheter',
      'sell': 'Vendre',
      'sectors': 'Secteurs',
      'stocks': 'Actions',
      'trading': 'Trading',
      'positions': 'Positions',
      'positions_full': 'PLEIN',
      'market': 'Marché',
      'robots': 'Robots',
      'robots_bay': 'Baie des Robots',
      'robot_fund': 'Financer',
      'robot_withdraw': 'Retirer',
      'robot_collect': 'Collecter',
      'robot_upgrade': 'Améliorer',
      'robot_budget': 'Budget',
      'robot_wallet': 'Gains',
      'robot_precision': 'Précision',
      'robot_efficiency': 'Efficacité',
      'robot_frequency': 'Fréquence',
      'robot_risk_mgmt': 'Gestion risque',
      'robot_capacity': 'Capacité budget',
      'robot_total_earnings': 'Gains totaux des robots',
      'robot_overview': 'Aperçu',
      'robot_total_budget': 'Budget investi',
      'robot_total_wallet': 'Gains à collecter',
      'robot_total_trades': 'Total des trades',
      'robot_upgrade_costs': 'Coûts d\'amélioration',
      'robot_daily_log': 'Performance journalière',
      'robot_no_trades': 'Aucun trade pour le moment.',
      'robot_no_slots': 'Pas encore de robots. Débloquez dans la Boutique Prestige !',
      'robot_budget_depleted': 'a épuisé son budget et a été désactivé.',
      'robot_active': 'Actif',
      'robot_next_trade': 'Prochains trades',
      'robot_trades_today': 'trades',
      'robot_trade_history': 'Trades récents',
      'dashboard': 'Tableau de bord',
      'upgrades': 'Améliorations',
      'choose_upgrade': 'Choisissez votre amélioration',
      'skip': 'Passer',
      'reroll': 'Relancer',
      'prestige': 'Prestige',
      'prestige_points': 'Points de prestige',
      'new_run': 'Nouvelle partie',
      'game_over': 'Fin de partie',
      'quota_failed': 'Partie terminée',

      // Chaînes de jeu additionnelles
      'pnl': 'Gains',
      'win_rate': 'Taux de réussite',
      'total_trades': 'Total des trades',
      'market_news': 'Actualités du marché',
      'continue': 'Continuer',
      'long': 'Pari hausse',
      'short': 'Pari baisse',
      'cover': 'Couvrir',
      'shares': 'Actions',
      'price': 'Prix',
      'total': 'Total',
      'fees': 'Frais',
      'value': 'Valeur',
      'change': 'Variation',
      'volume': 'Volume',
      'market_cap': 'Capitalisation',
      'high': 'Haut',
      'low': 'Bas',
      'open': 'Ouverture',
      'analyst': 'Analyste',
      'news': 'News',
      'all_sectors': 'Tous les secteurs',
      'performance': 'Performance',
      'progress': 'Progression',
      'start_game': 'Démarrer',
      'pause': 'Pause',
      'play': 'Jouer',

      // Vue trading
      'realized_pnl': 'Gains encaissés',
      'expenses': 'Dépenses',
      'opening_costs': 'Openings',
      'robot_costs': 'Robots',
      'quota_deducted': 'Quota déduit',
      'after_quota': 'Après quota',
      'top_gainer': 'Meilleure hausse',
      'top_loser': 'Pire baisse',
      'select_stock_to_trade': 'Sélectionnez une action',
      'stock_not_found': 'Action non trouvée',
      'place_order': 'Investir',
      'subtotal': 'Sous-total',
      'your_positions': 'Vos Positions',
      'view_all': 'Voir tout',
      'insufficient_funds': 'Fonds insuffisants',
      'insufficient_funds_for_short': 'Fonds insuffisants pour la vente à découvert',
      'short_selling_banned': 'La vente à découvert est actuellement interdite',
      'give_up': 'Abandonner',
      'give_up_confirm_title': 'Abandonner la partie ?',
      'give_up_confirm_message': 'Vous perdrez votre progression actuelle et irez à la boutique prestige. Vos points de prestige sont conservés.',
      'give_up_confirm': 'Abandonner',
      'max': 'Max',
      'quantity_hint': 'Appuyez pour ajouter, maintenez pour soustraire',
      'avg_cost': 'Prix d\'achat',
      'current_price': 'Prix actuel',
      'market_value': 'Valeur actuelle',
      'unrealized_pnl': 'Gains en cours',
      'no_positions': 'Aucune position',
      'long_positions': 'Positions Long',
      'short_positions': 'Positions Short',
      'total_value': 'Valeur totale',
      'fee_percent': 'Frais ({percent}%)',
      'buy_long_ticker': 'ACHETER {ticker} 📈',
      'sell_short_ticker': 'SHORTER {ticker} 📉',
      'shares_count': '{count} actions',
      'avg_cost_value': 'Moy: {cost}',
      'bought_shares_long': 'Acheté {shares} actions {ticker} (long)',
      'shorted_shares': 'Vendu à découvert {shares} actions {ticker}',
      'covered_shares': 'Couvert {count} actions {ticker}',
      'sold_shares': 'Vendu {count} actions {ticker}',
      'failed_to_sell': 'Échec de la vente',
      'insufficient_funds_cover': 'Fonds insuffisants pour couvrir la position',

      // Stop loss / Take profit
      'auto_orders': 'Trading auto',
      'auto_orders_desc': 'Posez des règles pour vendre automatiquement',
      'stop_loss': 'Protection perte',
      'take_profit': 'Objectif de gain',
      'stop_loss_desc': 'Vente auto si l\'investissement baisse de {percent}%',
      'take_profit_desc': 'Vente auto si l\'investissement gagne {percent}%',
      'requires_upgrade': 'Nécessite une amélioration',

      // Positions view
      'start_trading_hint': 'Commencez à trader pour construire votre portefeuille',
      'total_pnl': 'Gains totaux',
      'long_value': 'Valeur Long',
      'short_value': 'Valeur Short',
      'long_pnl': 'Gains Long',
      'short_pnl': 'Gains Short',
      'current': 'Actuel',
      'pnl_percent': '% Gain',
      'close_position_title': '{action} Position',
      'close_position_prompt': 'Combien d\'actions voulez-vous {action}?',
      'max_shares': 'Max: {count} actions',

      // Hero cards
      'holdings': 'Titres',
      'profit': 'Profit',
      'loss': 'Perte',
      'trades': 'Trades',
      'closed': 'Fermé',
      'next_day': 'Jour suivant',
      'day_number': 'JOUR {day}',
      'days_left_count': '{days}j restants',

      // News popup
      'start_trading': 'Commencer le trading',
      'breaking_news_update': 'Dernières nouvelles',
      'news_update_hint': 'De nouveaux développements peuvent confirmer ou contredire les rapports précédents',
      'mid_day_update': 'Mise à jour de mi-journée',
      'high_impact': 'Impact élevé',
      'medium_impact': 'Impact moyen',
      'low_impact': 'Faible impact',
      'company_specific': 'Spécifique à l\'entreprise',
      'sector_wide': 'Tout le secteur',
      'contradicts_earlier_report': 'Contredit le rapport précédent',
      'continue_trading': 'Continuer le trading',
      'day_year_header': 'JOUR {day}, ANNÉE {year}',
      'mid_day_header': 'Jour {day}, Année {year} - 13h30',

      // Dashboard
      'sector_allocation': 'Répartition sectorielle',
      'long_short': 'Long / Short',
      'position_statistics': 'Statistiques des positions',
      'profitable': 'Rentable',
      'losing': 'En perte',
      'best_position': 'Meilleure position',
      'worst_position': 'Pire position',
      'trading_performance': 'Performance de trading',
      'win_streak': 'Série de gains',
      'lose_streak': 'Série de pertes',
      'trades_today': 'Trades aujourd\'hui',
      'best_trade_ever': 'Meilleur trade',
      'worst_trade_ever': 'Pire trade',
      'risk_metrics': 'Aperçu des risques',
      'diversification': 'Diversification',
      'risk_level': 'Niveau de risque',
      'concentration': 'Concentration',
      'largest_position': 'Position la plus grande',
      'capital_allocation': 'Votre argent',
      'invested': 'Investi',
      'quota_met': 'Objectif atteint !',
      'recent_trades': 'Trades récents',
      'no_trades_yet': 'Aucun trade',
      'news_affecting_positions': 'Actualités affectant vos positions',
      'no_relevant_news': 'Aucune actualité pertinente',
      'acquired_upgrades': 'Améliorations acquises',
      'upgrades_count': '{count} améliorations',
      'earned': 'Gagné',
      'bonus': 'Bonus',
      'need': 'Besoin',
      'days_left_singular': '{days} jour restant',
      'days_left_plural': '{days} jours restants',

      // Info panel
      'information': 'Information',
      'market_overview': 'Aperçu du marché',
      'sector_details': 'Détails du secteur',
      'company_info': 'Info entreprise',
      'portfolio_analysis': 'Mon Portfolio',
      'recent_news': 'Actualités récentes',
      'no_news_yet': 'Aucune actualité',

      // Chart position display
      'position_averaged': 'MOY',
      'position_individual': 'DETAIL',

      // Active effects
      'effect_active': 'ACTIF',
      'effect_reduced_fees': 'Frais réduits',
      'effect_increased_fees': 'Frais augmentés',
      'effect_fee_discount': 'Réduction de {percent}%',
      'effect_fee_surcharge': 'Surcharge de {percent}%',
      'effect_short_ban': 'Vente à découvert interdite',
      'effect_short_ban_desc': 'Vente à découvert désactivée',
      'effect_upgrade_sale': 'Promo améliorations',
      'effect_upgrade_sale_desc': '-{percent}% sur les améliorations',
      'effect_circuit_breaker': 'Coupe-circuit',
      'effect_circuit_breaker_desc': 'Trading suspendu',
      'effect_high_volatility': 'Haute volatilité',
      'effect_low_volatility': 'Faible volatilité',
      'effect_volatility_desc': '{percent}% {direction} volatile',
      'effect_volatility_more': 'plus',
      'effect_volatility_less': 'moins',
      'effect_position_limit': 'Limite de position',
      'effect_position_limit_desc': 'Max {max} actions par trade',
      'effect_signal_jammer': 'Interférence signal',
      'effect_signal_jammer_desc': 'Les signaux de trading ne sont pas fiables',
      'effect_days_remaining': '{days} jours restants',
      'effect_today': "Aujourd'hui",
      'effect_day_remaining': '{days} jour restant',

      'market_health': 'Santé du marché',
      'fear_greed': 'Peur & Avidité',
      'fear_greed_extreme_greed': 'Avidité extrême',
      'fear_greed_greed': 'Avidité',
      'fear_greed_neutral': 'Neutre',
      'fear_greed_fear': 'Peur',
      'fear_greed_extreme_fear': 'Peur extrême',
      'fear_greed_tip_extreme_greed': 'Attention, vendez avant le crash !',
      'fear_greed_tip_greed': 'Bon moment pour prendre des profits',
      'fear_greed_tip_neutral': 'Marché calme, surveillez les signaux',
      'fear_greed_tip_fear': 'Bonnes affaires possibles, achetez bas !',
      'fear_greed_tip_extreme_fear': 'Tout est en solde, grosse opportunité !',
      'market_breadth': 'Largeur du marché',
      'volatility': 'Volatilité',
      'sector_leaders': 'Leaders sectoriels',
      'best': 'Meilleur',
      'worst': 'Pire',
      'select_sector_to_see_details': 'Sélectionnez un secteur pour voir les détails',
      'sector_news': 'Actualités du secteur',
      'sector_overview': 'Aperçu du secteur',
      'name': 'Nom',
      'type': 'Type',
      'region': 'Région',
      'characteristics': 'Caractéristiques',
      'market_correlation': 'Corrélation au marché',
      'fed_sensitivity': 'Sensibilité Fed',
      'your_holdings': 'Vos avoirs',
      'total_shares': 'Total actions',
      'select_stock_to_see_details': 'Sélectionnez une action pour voir les détails',
      'ticker': 'Symbole',
      'sector': 'Secteur',
      'pe_ratio': 'Ratio P/E',
      'trading_stats': 'Stats de trading',
      'day_open': 'Ouverture',
      'day_high': 'Plus haut',
      'day_low': 'Plus bas',
      'analyst_ratings': 'Notes des analystes',
      'technical_analysis': 'Analyse technique',
      'historical_performance': 'Performance historique',
      'week_range_52': 'Fourchette 52 semaines',
      'from_high': 'Du plus haut',
      'from_low': 'Du plus bas',
      'blue_chip': 'Blue Chip',
      'penny_stock': 'Penny Stock',
      'yes': 'Oui',
      'no': 'Non',
      'your_position': 'Votre position',
      'recent_activity': 'Activité récente',
      'portfolio_summary': 'Résumé',
      'total_positions': 'Total positions',
      'portfolio_value': 'Valeur du portfolio',
      'best_performer': 'Meilleur performer',
      'stock': 'Action',
      'no_analyst_data': 'Aucune donnée analyste',
      'consensus': 'Consensus',
      'analysts': 'Analystes',
      'hold': 'Conserver',
      'strong_buy': 'Achat fort',
      'strong_sell': 'Vente forte',
      'price_target': 'Objectif de prix',
      'pt_high': 'Obj. haut',
      'pt_low': 'Obj. bas',
      'upside': 'Potentiel',
      'rsi_14': 'RSI (14)',
      'oversold': 'Survendu',
      'overbought': 'Suracheté',
      'neutral': 'Neutre',
      'ma_50': 'MM 50',
      'ma_200': 'MM 200',
      'volume_ratio': 'Ratio de volume',
      'regime_strong_bull': 'Bull fort',
      'regime_bull': 'Marché haussier',
      'regime_neutral': 'Neutre',
      'regime_bear': 'Marché baissier',
      'regime_strong_bear': 'Bear fort',
      'regime_desc_strong_bull': 'Optimisme extrême. Achetez tout !',
      'regime_desc_bull': 'Sentiment positif. Bon moment pour acheter.',
      'regime_desc_neutral': 'Signaux mixtes. Surveillez les opportunités.',
      'regime_desc_bear': 'Sentiment négatif. Soyez prudent avec vos trades.',
      'regime_desc_strong_bear': 'Pessimisme extrême. Attendez ou vendez à découvert !',
      'days_in_regime': 'Jours dans ce régime',
      'strength': 'Force',
      'market_indicators': 'Indicateurs de marché',
      'advancing': 'En hausse',
      'declining': 'En baisse',
      'unchanged': 'Inchangés',
      'new_highs': 'Nouveaux sommets',
      'new_lows': 'Nouveaux creux',
      'leading_sector': 'Secteur leader',
      'lagging_sector': 'Secteur retardataire',
      'portfolio_breakdown': 'Détails du portfolio',
      'distinct_sectors': 'Secteurs distincts',
      'avg_position_size': 'Taille moy. position',
      'portfolio_vol': 'Vol. du portfolio',
      'largest_value': 'Plus grande valeur',
      'position_types': 'Types de positions',
      'unknown': 'Inconnu',

      // Sorting and misc
      'sort_by': 'Trier par :',
      'avg_change': 'Var. moy.',
      'stocks_count_region': '{count} actions • {region}',
      'all_stocks': 'Toutes les actions',
      'trade': 'Trader',

      // Sector names
      'sector_tech': 'Technologie',
      'sector_healthcare': 'Santé',
      'sector_finance': 'Finance',
      'sector_energy': 'Énergie',
      'sector_consumer': 'Consommation',
      'sector_industrial': 'Industrie',
      'sector_realestate': 'Immobilier',
      'sector_telecom': 'Télécoms',
      'sector_gaming': 'Jeux vidéo',
      'sector_crypto': 'Crypto',
      'sector_aerospace': 'Aérospatial',
      'sector_materials': 'Matériaux',
      'sector_utilities': 'Services publics',
      'sector_commodities': 'Matières premières',
      'sector_forex': 'Devises',
      'sector_indices': 'Indices',

      // Sector descriptions
      'sector_desc_tech': 'Logiciels, matériel et entreprises internet',
      'sector_desc_healthcare': 'Pharmaceutique, biotechnologie et dispositifs médicaux',
      'sector_desc_finance': 'Banques, assurances et services financiers',
      'sector_desc_energy': 'Pétrole, gaz et énergies renouvelables',
      'sector_desc_consumer': 'Commerce de détail, alimentation et produits de consommation',
      'sector_desc_industrial': 'Fabrication, aérospatiale et construction',
      'sector_desc_realestate': 'Foncières et promoteurs immobiliers',
      'sector_desc_telecom': 'Télécommunications et médias',
      'sector_desc_gaming': 'Jeux vidéo, esport et divertissement',
      'sector_desc_crypto': 'Cryptomonnaie, blockchain et DeFi',
      'sector_desc_aerospace': 'Exploration spatiale et entreprises de défense',
      'sector_desc_materials': 'Acier, cuivre, lithium et minéraux de terres rares',
      'sector_desc_utilities': 'Fournisseurs d\'eau, d\'électricité et de gaz',
      'sector_desc_commodities': 'Or, pétrole, argent et gaz naturel',
      'sector_desc_forex': 'Paires de devises et marché des changes',
      'sector_desc_indices': 'Indices boursiers suivant la performance globale',

      // Upgrade names and descriptions
      // — Trading
      'upgrade_fee_reduction_1_name': 'Courtier économique',
      'upgrade_fee_reduction_1_desc': 'Réduire les frais de trading de 5%',
      'upgrade_fee_reduction_2_name': 'Courtier premium',
      'upgrade_fee_reduction_2_desc': 'Réduire les frais de trading de 10%',
      'upgrade_fee_reduction_3_name': 'Trading VIP',
      'upgrade_fee_reduction_3_desc': 'Réduire les frais de trading de 20%',
      'upgrade_zero_fees_name': 'Zéro commission',
      'upgrade_zero_fees_desc': 'Éliminer tous les frais de trading',
      'upgrade_margin_1_name': 'Compte sur marge',
      'upgrade_margin_1_desc': 'Débloquer le trading sur marge x1.5',
      'upgrade_margin_2_name': 'Marge avancée',
      'upgrade_margin_2_desc': 'Débloquer le trading sur marge x2',
      'upgrade_margin_3_name': 'Levier pro',
      'upgrade_margin_3_desc': 'Débloquer le trading sur marge x3',
      'upgrade_short_selling_name': 'Vente à découvert',
      'upgrade_short_selling_desc': 'Débloquer la possibilité de shorter des actions',
      'upgrade_momentum_rider_name': 'Surfeur de momentum',
      'upgrade_momentum_rider_desc': '+10% profit sur le prochain trade après 3 gains consécutifs.',
      'upgrade_contrarian_name': 'Contrarien',
      'upgrade_contrarian_desc': "+20% profit à l'achat d'une action ayant baissé de >10% aujourd'hui.",
      'upgrade_day_trader_name': 'Day Trader',
      'upgrade_day_trader_desc': '+5% bonus quand vous achetez et vendez la même action en un jour.',
      'upgrade_stock_bonus_1_name': 'Récompenses fidélité',
      'upgrade_stock_bonus_1_desc': 'Recevoir 2% d\'actions bonus à chaque achat.',
      'upgrade_stock_bonus_2_name': 'Récompenses premium',
      'upgrade_stock_bonus_2_desc': 'Recevoir 5% d\'actions bonus à chaque achat.',
      'upgrade_stock_bonus_3_name': 'Récompenses VIP',
      'upgrade_stock_bonus_3_desc': 'Recevoir 8% d\'actions bonus à chaque achat.',
      'upgrade_stock_bonus_max_name': 'Récompenses baleine',
      'upgrade_stock_bonus_max_desc': 'Recevoir 12% d\'actions bonus à chaque achat.',
      'upgrade_analyst_1_name': 'Analyste junior',
      'upgrade_analyst_1_desc': 'Les signaux de trading sont précis à 60% (base : 50%).',
      'upgrade_analyst_2_name': 'Analyste senior',
      'upgrade_analyst_2_desc': 'Les signaux de trading sont précis à 75%.',
      'upgrade_analyst_3_name': 'Analyste expert',
      'upgrade_analyst_3_desc': 'Les signaux de trading sont précis à 90%.',
      'upgrade_robot_token_1_name': 'Robot de trading',
      'upgrade_robot_token_1_desc': "Obtenir un robot qui trade automatiquement. Placez-le pour acheter bas et vendre haut automatiquement.",
      'upgrade_robot_token_2_name': 'Robot avancé',
      'upgrade_robot_token_2_desc': 'Obtenir un autre robot de trading pour plus de gains automatisés.',
      // — Information
      'upgrade_earnings_preview_name': 'Calendrier des résultats',
      'upgrade_earnings_preview_desc': 'Voir quelles entreprises auront des nouvelles demain.',
      'upgrade_volume_sight_name': 'Indicateur de volume',
      'upgrade_volume_sight_desc': "Voir l'activité de volume de trading sur chaque action.",
      // — Portfolio
      'upgrade_position_slot_1_name': 'Expansion du portfolio',
      'upgrade_position_slot_1_desc': 'Détenir +1 position supplémentaire',
      'upgrade_position_slot_2_name': 'Grand portfolio',
      'upgrade_position_slot_2_desc': 'Détenir +2 positions supplémentaires',
      'upgrade_position_slot_3_name': 'Hedge Fund',
      'upgrade_position_slot_3_desc': 'Détenir +3 positions supplémentaires',
      // — Unlock
      'upgrade_unlock_companies_1_name': 'Accès au marché',
      'upgrade_unlock_companies_1_desc': 'Débloquer 3 entreprises verrouillées aléatoires',
      'upgrade_unlock_companies_2_name': 'Accès premium',
      'upgrade_unlock_companies_2_desc': 'Débloquer 5 entreprises verrouillées aléatoires',
      'upgrade_unlock_companies_3_name': 'Accès total',
      'upgrade_unlock_companies_3_desc': 'Débloquer 8 entreprises verrouillées aléatoires',
      // — Risk
      'upgrade_crash_protection_name': 'Bouclier anti-crash',
      'upgrade_crash_protection_desc': 'Réduire les pertes de 20% sur tous les trades perdants',
      'upgrade_diamond_hands_name': 'Mains de diamant',
      'upgrade_diamond_hands_desc': '+50% de profit sur tous les trades gagnants',
      // — Income
      'upgrade_passive_income_1_name': 'Revenu d\'intérêts',
      'upgrade_passive_income_1_desc': 'Gagner 25\$ de revenu passif par jour',
      'upgrade_passive_income_2_name': 'Compte épargne',
      'upgrade_passive_income_2_desc': 'Gagner 50\$ de revenu passif par jour',
      'upgrade_passive_income_3_name': 'Fonds fiduciaire',
      'upgrade_passive_income_3_desc': 'Gagner 100\$ de revenu passif par jour',
      'upgrade_tax_refund_name': 'Remboursement fiscal',
      'upgrade_tax_refund_desc': 'Récupérer 10% de vos pertes réalisées en cash en fin de journée.',
      'upgrade_dividend_boost_name': 'Roi des dividendes',
      'upgrade_dividend_boost_desc': 'Les jetons dividende rapportent 50% de plus',
      'upgrade_market_maker_name': 'Teneur de marché',
      'upgrade_market_maker_desc': 'Gagner 50\$ de bonus à chaque trade effectué',
      'upgrade_dividend_token_1_name': 'Jeton dividende',
      'upgrade_dividend_token_1_desc': "Obtenir un jeton qui génère des revenus passifs sur les gains d'une action. Placez-le sur n'importe quelle action.",
      'upgrade_dividend_token_2_name': 'Dividende premium',
      'upgrade_dividend_token_2_desc': 'Obtenir un autre jeton dividende pour doubler les revenus passifs.',
      'upgrade_compound_interest_name': 'Intérêts composés',
      'upgrade_compound_interest_desc': 'Gagner 1% de la valeur du portfolio en cash quotidiennement',
      // — Time
      'upgrade_longer_day_1_name': 'Horaires étendus',
      'upgrade_longer_day_1_desc': 'La journée de trading dure 10 secondes de plus',
      'upgrade_longer_day_2_name': 'Trading nocturne',
      'upgrade_longer_day_2_desc': 'La journée de trading dure 20 secondes de plus',
      'upgrade_quantum_trader_name': 'Trader quantique',
      'upgrade_quantum_trader_desc': 'La journée de trading dure 60 secondes de plus',
      // — Quota
      'upgrade_quota_reduction_1_name': 'Patron indulgent',
      'upgrade_quota_reduction_1_desc': 'Quota réduit de 10%',
      'upgrade_quota_reduction_2_name': 'Mode facile',
      'upgrade_quota_reduction_2_desc': 'Quota réduit de 20%',
      'upgrade_extra_day_name': 'Extension de délai',
      'upgrade_extra_day_desc': '+1 jour pour atteindre le quota',
      // — Bouclier secteur
      'upgrade_sector_shield_common_name': 'Bouclier secteur',
      'upgrade_sector_shield_common_desc': 'Réduit les pertes de 3% sur les actions {sector}',
      'upgrade_sector_shield_uncommon_name': 'Bouclier secteur',
      'upgrade_sector_shield_uncommon_desc': 'Réduit les pertes de 7% sur les actions {sector}',
      'upgrade_sector_shield_rare_name': 'Bouclier secteur',
      'upgrade_sector_shield_rare_desc': 'Réduit les pertes de 15% sur les actions {sector}',
      'upgrade_sector_shield_epic_name': 'Bouclier secteur',
      'upgrade_sector_shield_epic_desc': 'Réduit les pertes de 22% sur les actions {sector}',
      'upgrade_sector_shield_legendary_name': 'Bouclier secteur',
      'upgrade_sector_shield_legendary_desc': 'Réduit les pertes de 30% sur les actions {sector}',
      // — Avantage secteur
      'upgrade_sector_edge_common_name': 'Avantage secteur',
      'upgrade_sector_edge_common_desc': 'Boost les profits de 3% sur les actions {sector}',
      'upgrade_sector_edge_uncommon_name': 'Avantage secteur',
      'upgrade_sector_edge_uncommon_desc': 'Boost les profits de 7% sur les actions {sector}',
      'upgrade_sector_edge_rare_name': 'Avantage secteur',
      'upgrade_sector_edge_rare_desc': 'Boost les profits de 15% sur les actions {sector}',
      'upgrade_sector_edge_epic_name': 'Avantage secteur',
      'upgrade_sector_edge_epic_desc': 'Boost les profits de 22% sur les actions {sector}',
      'upgrade_sector_edge_legendary_name': 'Avantage secteur',
      'upgrade_sector_edge_legendary_desc': 'Boost les profits de 30% sur les actions {sector}',
      // — Revenu situationnel
      'upgrade_income_per_stock_name': 'Dividende par action',
      'upgrade_income_per_stock_desc': 'Gagne 1\$ par action détenue en fin de journée',
      'upgrade_income_per_sector_name': 'Diversification sectorielle',
      'upgrade_income_per_sector_desc': 'Gagne 10\$ par secteur distinct dans votre portefeuille',
      'upgrade_income_per_upgrade_name': 'Le savoir paie',
      'upgrade_income_per_upgrade_desc': 'Gagne 5\$ par amélioration possédée en fin de journée',
      'upgrade_income_portfolio_percent_name': 'Intérêts du portefeuille',
      'upgrade_income_portfolio_percent_desc': 'Gagne 1% de la valeur du portefeuille en cash chaque jour',
      'upgrade_income_combo_name': 'Machine à richesse',
      'upgrade_income_combo_desc': 'Gagne 2\$/action + 15\$/secteur + 0.5% valeur portefeuille/jour',
      // — News upgrades
      'upgrade_morning_edition_name': 'Édition du matin',
      'upgrade_morning_edition_desc': '+1 news en début de journée',
      'upgrade_evening_edition_name': 'Édition du soir',
      'upgrade_evening_edition_desc': '+1 news en milieu de journée',
      'upgrade_news_cycle_24h_name': 'News en continu',
      'upgrade_news_cycle_24h_desc': '+1 news le matin ET en milieu de journée',
      // — Sector Insight templates
      'upgrade_sector_insight_common_name': 'Vision sectorielle',
      'upgrade_sector_insight_common_desc': '+20% de chance qu\'une news concerne {sector}',
      'upgrade_sector_insight_uncommon_name': 'Vision sectorielle',
      'upgrade_sector_insight_uncommon_desc': '+35% de chance qu\'une news concerne {sector}',
      'upgrade_sector_insight_rare_name': 'Vision sectorielle',
      'upgrade_sector_insight_rare_desc': '+50% de chance qu\'une news concerne {sector}',
      'upgrade_sector_insight_epic_name': 'Vision sectorielle',
      'upgrade_sector_insight_epic_desc': '+70% de chance qu\'une news concerne {sector} + aperçu du sentiment',
      'upgrade_sector_insight_legendary_name': 'Vision sectorielle',
      'upgrade_sector_insight_legendary_desc': '1 news garantie/jour sur {sector} + aperçu du sentiment',
      // — Sector Dominance templates
      'upgrade_sector_dominance_common_name': 'Domination sectorielle',
      'upgrade_sector_dominance_common_desc': '+2% profit par position {sector} détenue',
      'upgrade_sector_dominance_uncommon_name': 'Domination sectorielle',
      'upgrade_sector_dominance_uncommon_desc': '+4% profit par position {sector} détenue',
      'upgrade_sector_dominance_rare_name': 'Domination sectorielle',
      'upgrade_sector_dominance_rare_desc': '+7% profit par position {sector} détenue',
      'upgrade_sector_dominance_epic_name': 'Domination sectorielle',
      'upgrade_sector_dominance_epic_desc': '+10% profit par position {sector} détenue',
      'upgrade_sector_dominance_legendary_name': 'Domination sectorielle',
      'upgrade_sector_dominance_legendary_desc': '+15% profit par position {sector} + -5% frais',
      // — Winning Streak (global template, 5 rarities)
      'upgrade_winning_streak_common_name': 'Série en feu',
      'upgrade_winning_streak_common_desc': '+2% profit par trade gagnant consécutif',
      'upgrade_winning_streak_uncommon_name': 'Série en feu',
      'upgrade_winning_streak_uncommon_desc': '+4% profit par trade gagnant consécutif',
      'upgrade_winning_streak_rare_name': 'Série en feu',
      'upgrade_winning_streak_rare_desc': '+8% profit par trade gagnant consécutif',
      'upgrade_winning_streak_epic_name': 'Série en feu',
      'upgrade_winning_streak_epic_desc': '+15% profit par trade gagnant consécutif',
      'upgrade_winning_streak_legendary_name': 'Série en feu',
      'upgrade_winning_streak_legendary_desc': '+25% profit par trade gagnant consécutif',
      // — Prestige (kept for prestige shop)
      'upgrade_prestige_stop_loss_name': 'Stop Loss',
      'upgrade_prestige_stop_loss_desc': 'Débloquer les ordres stop loss. Vente auto quand vos positions chutent sous votre seuil.',
      'upgrade_prestige_take_profit_name': 'Take Profit',
      'upgrade_prestige_take_profit_desc': 'Débloquer les ordres take profit. Vente auto quand vos positions atteignent votre objectif de gain.',

      // Prestige shop UI
      'prestige_shop_title': 'ARBRE DE TALENTS',
      'survived_days_year': 'Vous avez survécu {days} jours en Année {year}',
      'all_upgrades_purchased': 'Toutes les améliorations achetées !',
      'points_saved_for_future': 'Vous avez {points} points pour de futures améliorations.',
      'start_new_run': 'NOUVELLE PARTIE',
      'tree_hint': 'Pincez pour zoomer \u2022 Glissez pour explorer',
      'prestige_level': 'NIVEAU PRESTIGE',
      'total_points_earned': 'POINTS TOTAUX GAGNÉS',
      'lifetime_earnings': 'GAINS TOTAUX',

      // Prestige upgrade names and descriptions
      // — Capital Initial (10 tiers)
      'upgrade_prestige_starting_cash_1_name': 'Capital Initial I',
      'upgrade_prestige_starting_cash_1_desc': 'Commencer chaque partie avec +200\$ de bonus.',
      'upgrade_prestige_starting_cash_2_name': 'Capital Initial II',
      'upgrade_prestige_starting_cash_2_desc': 'Commencer chaque partie avec +500\$ de bonus.',
      'upgrade_prestige_starting_cash_3_name': 'Capital Initial III',
      'upgrade_prestige_starting_cash_3_desc': 'Commencer chaque partie avec +1 000\$ de bonus.',
      'upgrade_prestige_starting_cash_4_name': 'Cuillère d\'Argent',
      'upgrade_prestige_starting_cash_4_desc': 'Commencer chaque partie avec +2 500\$ de bonus.',
      'upgrade_prestige_starting_cash_5_name': 'Fonds Fiduciaire',
      'upgrade_prestige_starting_cash_5_desc': 'Commencer chaque partie avec +5 000\$ de bonus.',
      'upgrade_prestige_starting_cash_6_name': 'Business Angel',
      'upgrade_prestige_starting_cash_6_desc': 'Commencer chaque partie avec +10 000\$ de bonus.',
      'upgrade_prestige_starting_cash_7_name': 'Capital-Risque',
      'upgrade_prestige_starting_cash_7_desc': 'Commencer chaque partie avec +25 000\$ de bonus.',
      'upgrade_prestige_starting_cash_8_name': 'Fonds Spéculatif',
      'upgrade_prestige_starting_cash_8_desc': 'Commencer chaque partie avec +50 000\$ de bonus.',
      'upgrade_prestige_starting_cash_9_name': 'Fortune Dynastique',
      'upgrade_prestige_starting_cash_9_desc': 'Commencer chaque partie avec +100 000\$ de bonus.',
      'upgrade_prestige_starting_cash_10_name': 'Argent Infini',
      'upgrade_prestige_starting_cash_10_desc': 'Commencer chaque partie avec +250 000\$ de bonus.',
      // — Réduction de frais (5 tiers)
      'upgrade_prestige_fee_reduction_name': 'Contacts Courtiers',
      'upgrade_prestige_fee_reduction_desc': 'Réduire les frais de trading de 15%.',
      'upgrade_prestige_fee_reduction_2_name': 'Initié de Wall Street',
      'upgrade_prestige_fee_reduction_2_desc': 'Réduire les frais de trading de 15% supplémentaires.',
      'upgrade_prestige_fee_reduction_3_name': 'Trading VIP',
      'upgrade_prestige_fee_reduction_3_desc': 'Réduire les frais de trading de 10% supplémentaires.',
      'upgrade_prestige_fee_reduction_4_name': 'Teneur de Marché',
      'upgrade_prestige_fee_reduction_4_desc': 'Réduire les frais de trading de 10% supplémentaires.',
      'upgrade_prestige_fee_reduction_5_name': 'Zéro Commission',
      'upgrade_prestige_fee_reduction_5_desc': 'Réduire les frais de trading de 10% supplémentaires.',
      // — Positions supplémentaires (6 tiers)
      'upgrade_prestige_extra_position_name': 'Bureau Étendu',
      'upgrade_prestige_extra_position_desc': 'Commencer chaque partie avec +2 slots de position.',
      'upgrade_prestige_extra_position_2_name': 'Portfolio Diversifié',
      'upgrade_prestige_extra_position_2_desc': 'Commencer chaque partie avec +2 slots de position.',
      'upgrade_prestige_extra_position_3_name': 'Salle des Marchés',
      'upgrade_prestige_extra_position_3_desc': 'Commencer chaque partie avec +2 slots de position.',
      'upgrade_prestige_extra_position_4_name': 'Trader Multi-Bureau',
      'upgrade_prestige_extra_position_4_desc': 'Commencer chaque partie avec +3 slots de position.',
      'upgrade_prestige_extra_position_5_name': 'Échelle Institutionnelle',
      'upgrade_prestige_extra_position_5_desc': 'Commencer chaque partie avec +3 slots de position.',
      'upgrade_prestige_extra_position_6_name': 'Domination du Marché',
      'upgrade_prestige_extra_position_6_desc': 'Commencer chaque partie avec +4 slots de position.',
      // — Upgrades trading uniques
      'upgrade_prestige_short_immunity_name': 'Immunité Short',
      'upgrade_prestige_short_immunity_desc': 'Les interdictions de vente à découvert ne vous affectent pas.',
      // — Déblocage Secteur Aléatoire (3 tiers)
      'upgrade_prestige_unlock_tier_name': 'Accès Initié',
      'upgrade_prestige_unlock_tier_desc': 'Commencer chaque partie avec le tier standard d\'un secteur aléatoire débloqué.',
      'upgrade_prestige_unlock_tier_2_name': 'Réseau Élite',
      'upgrade_prestige_unlock_tier_2_desc': 'Commencer chaque partie avec le tier premium d\'un secteur aléatoire débloqué.',
      'upgrade_prestige_unlock_tier_3_name': 'Titan du Marché',
      'upgrade_prestige_unlock_tier_3_desc': 'Commencer chaque partie avec le tier élite d\'un secteur aléatoire débloqué.',
      // — Réduction de quota (5 tiers)
      'upgrade_prestige_quota_reduction_name': 'Objectifs Relâchés',
      'upgrade_prestige_quota_reduction_desc': 'Réduire les objectifs de quota de 10%.',
      'upgrade_prestige_quota_reduction_2_name': 'Manager Compréhensif',
      'upgrade_prestige_quota_reduction_2_desc': 'Réduire les objectifs de quota de 10% supplémentaires.',
      'upgrade_prestige_quota_reduction_3_name': 'Conseil Indulgent',
      'upgrade_prestige_quota_reduction_3_desc': 'Réduire les objectifs de quota de 8% supplémentaires.',
      'upgrade_prestige_quota_reduction_4_name': 'Objectifs Flexibles',
      'upgrade_prestige_quota_reduction_4_desc': 'Réduire les objectifs de quota de 7% supplémentaires.',
      'upgrade_prestige_quota_reduction_5_name': 'Tampon Automatique',
      'upgrade_prestige_quota_reduction_5_desc': 'Réduire les objectifs de quota de 5% supplémentaires.',
      // — Temps supplémentaire (5 tiers)
      'upgrade_prestige_extra_time_name': 'Lève-tôt',
      'upgrade_prestige_extra_time_desc': 'Commencer chaque jour avec +30 secondes.',
      'upgrade_prestige_extra_time_2_name': 'Maître du Temps',
      'upgrade_prestige_extra_time_2_desc': 'Commencer chaque jour avec +30 secondes.',
      'upgrade_prestige_extra_time_3_name': 'Horaires Étendus',
      'upgrade_prestige_extra_time_3_desc': 'Commencer chaque jour avec +30 secondes.',
      'upgrade_prestige_extra_time_4_name': 'After Hours',
      'upgrade_prestige_extra_time_4_desc': 'Commencer chaque jour avec +45 secondes.',
      'upgrade_prestige_extra_time_5_name': 'Dilatation Temporelle',
      'upgrade_prestige_extra_time_5_desc': 'Commencer chaque jour avec +60 secondes.',
      // — Revenu passif (8 tiers)
      'upgrade_prestige_passive_income_name': 'Activité Secondaire',
      'upgrade_prestige_passive_income_desc': 'Gagner 20\$ de revenu passif à la fin de chaque jour.',
      'upgrade_prestige_passive_income_2_name': 'Portfolio d\'Investissement',
      'upgrade_prestige_passive_income_2_desc': 'Gagner +30\$ de revenu passif à la fin de chaque jour.',
      'upgrade_prestige_passive_income_3_name': 'Empire Locatif',
      'upgrade_prestige_passive_income_3_desc': 'Gagner +50\$ de revenu passif à la fin de chaque jour.',
      'upgrade_prestige_passive_income_4_name': 'Roi des Dividendes',
      'upgrade_prestige_passive_income_4_desc': 'Gagner +80\$ de revenu passif à la fin de chaque jour.',
      'upgrade_prestige_passive_income_5_name': 'Flux de Revenus',
      'upgrade_prestige_passive_income_5_desc': 'Gagner +150\$ de revenu passif à la fin de chaque jour.',
      'upgrade_prestige_passive_income_6_name': 'Machine à Cash',
      'upgrade_prestige_passive_income_6_desc': 'Gagner +300\$ de revenu passif à la fin de chaque jour.',
      'upgrade_prestige_passive_income_7_name': 'Planche à Billets',
      'upgrade_prestige_passive_income_7_desc': 'Gagner +500\$ de revenu passif à la fin de chaque jour.',
      'upgrade_prestige_passive_income_8_name': 'Richesse Infinie',
      'upgrade_prestige_passive_income_8_desc': 'Gagner +1 000\$ de revenu passif à la fin de chaque jour.',
      // — Intérêts composés (5 tiers)
      'upgrade_prestige_compound_interest_name': 'Intérêts Composés',
      'upgrade_prestige_compound_interest_desc': 'Gagner 2% d\'intérêts sur votre solde cash à la fin de chaque jour.',
      'upgrade_prestige_compound_interest_2_name': 'Compte Épargne',
      'upgrade_prestige_compound_interest_2_desc': 'Gagner +1% d\'intérêts sur votre solde cash à la fin de chaque jour.',
      'upgrade_prestige_compound_interest_3_name': 'Fonds à Haut Rendement',
      'upgrade_prestige_compound_interest_3_desc': 'Gagner +1% d\'intérêts sur votre solde cash à la fin de chaque jour.',
      'upgrade_prestige_compound_interest_4_name': 'Banque d\'Investissement',
      'upgrade_prestige_compound_interest_4_desc': 'Gagner +1% d\'intérêts sur votre solde cash à la fin de chaque jour.',
      'upgrade_prestige_compound_interest_5_name': 'Accès Banque Centrale',
      'upgrade_prestige_compound_interest_5_desc': 'Gagner +1% d\'intérêts sur votre solde cash à la fin de chaque jour.',
      // — Accélérateur Prestige (5 tiers)
      'upgrade_prestige_accelerator_name': 'Accélérateur Prestige',
      'upgrade_prestige_accelerator_desc': 'Gagner 50% de points de prestige en plus chaque partie.',
      'upgrade_prestige_accelerator_2_name': 'Prestige Turbo',
      'upgrade_prestige_accelerator_2_desc': 'Gagner +50% de points de prestige en plus chaque partie.',
      'upgrade_prestige_accelerator_3_name': 'Prestige Overdrive',
      'upgrade_prestige_accelerator_3_desc': 'Gagner +50% de points de prestige en plus chaque partie.',
      'upgrade_prestige_accelerator_4_name': 'Prestige Singularité',
      'upgrade_prestige_accelerator_4_desc': 'Gagner +50% de points de prestige en plus chaque partie.',
      'upgrade_prestige_accelerator_5_name': 'Prestige Ascension',
      'upgrade_prestige_accelerator_5_desc': 'Gagner +100% de points de prestige en plus chaque partie.',
      // — Upgrades uniques
      'upgrade_prestige_reroll_name': 'Maître du Relancer',
      'upgrade_prestige_reroll_desc': 'Relancer vos choix d\'amélioration une fois par jour.',
      'upgrade_prestige_lucky_start_name': 'Départ Chanceux',
      'upgrade_prestige_lucky_start_desc': 'Votre première amélioration est garantie Rare ou mieux.',
      'upgrade_prestige_second_chance_name': 'Seconde Chance',
      'upgrade_prestige_second_chance_desc': 'Une fois par partie, survivre à un quota raté et continuer à jouer.',
      'upgrade_prestige_golden_parachute_name': 'Parachute Doré',
      'upgrade_prestige_golden_parachute_desc': 'Garder 25% de votre cash quand une partie se termine par quota raté.',
      'upgrade_prestige_quick_learner_name': 'Apprentissage Rapide',
      'upgrade_prestige_quick_learner_desc': 'Obtenir 4 choix d\'amélioration au lieu de 3 chaque jour.',
      'upgrade_prestige_market_veteran_name': 'Vétéran du Marché',
      'upgrade_prestige_market_veteran_desc': 'Choisir une amélioration quotidienne gratuite au début de chaque partie.',
      // — Luck Boost (3 tiers)
      'upgrade_prestige_luck_boost_name': 'Porte-Bonheur',
      'upgrade_prestige_luck_boost_desc': 'Augmente légèrement la chance d\'obtenir des améliorations rares+ en boutique.',
      'upgrade_prestige_luck_boost_2_name': 'Fortune Souriante',
      'upgrade_prestige_luck_boost_2_desc': 'Augmente davantage la chance d\'obtenir des améliorations rares+ en boutique.',
      'upgrade_prestige_luck_boost_3_name': 'Main en Or',
      'upgrade_prestige_luck_boost_3_desc': 'Augmente grandement la chance d\'obtenir des améliorations rares+ en boutique.',
      // — Reroll Boost (3 tiers)
      'upgrade_prestige_reroll_boost_name': 'Second Regard',
      'upgrade_prestige_reroll_boost_desc': '+1 lancer gratuit par jour (boutique & quotidien).',
      'upgrade_prestige_reroll_boost_2_name': 'Options Fraîches',
      'upgrade_prestige_reroll_boost_2_desc': '+1 lancer gratuit par jour (boutique & quotidien).',
      'upgrade_prestige_reroll_boost_3_name': 'Navigation Infinie',
      'upgrade_prestige_reroll_boost_3_desc': '+1 lancer gratuit par jour (boutique & quotidien).',
      // — Sector Amplifier
      'upgrade_prestige_sector_amplifier_name': 'Amplificateur Sectoriel',
      'upgrade_prestige_sector_amplifier_desc': 'Les améliorations Bouclier et Avantage Sectoriel sont 25% plus efficaces.',

      // — Robot Traders
      'upgrade_robot_slot_1_name': 'Baie Robotique',
      'upgrade_robot_slot_1_desc': 'Débloque les robots traders et obtiens ton premier bot.',
      'upgrade_robot_slot_2_name': 'Slot Robot II',
      'upgrade_robot_slot_2_desc': 'Débloque un deuxième bot de trading.',
      'upgrade_robot_slot_3_name': 'Slot Robot III',
      'upgrade_robot_slot_3_desc': 'Débloque un troisième bot de trading.',
      'upgrade_robot_slot_4_name': 'Slot Robot IV',
      'upgrade_robot_slot_4_desc': 'Débloque un quatrième bot de trading.',
      'upgrade_robot_slot_5_name': 'Slot Robot V',
      'upgrade_robot_slot_5_desc': 'Débloque un cinquième bot de trading.',
      'upgrade_robot_blueprint_name': 'Mémoire de Plans',
      'upgrade_robot_blueprint_desc': 'Les robots conservent 50% de leurs niveaux entre les parties.',
      'upgrade_robot_overclock_name': 'Overclock',
      'upgrade_robot_overclock_desc': '+1 trade par jour pour tous les robots.',
      'upgrade_robot_deep_pockets_name': 'Poches Profondes',
      'upgrade_robot_deep_pockets_desc': '+30% de budget maximum allouable à chaque robot.',

      // Upgrade shop & collection UI
      'upgrade_shop_title': 'BOUTIQUE',
      'shop_subtitle': 'Choix gratuit \u2022 Relance payante',
      'collection': 'Collection',
      'roll': 'LANCER',
      'free': 'GRATUIT',
      'reroll_all': 'TOUT RELANCER',
      'pick': 'CHOISIR',
      'drop_rates': 'TAUX DE DROP',
      'free_rolls_remaining': '{count} lancer(s) gratuit(s) restant(s)',
      'resets_daily': 'Réinitialisation quotidienne \u2022 Coût doublé par lancer',
      'discovered': '{owned} / {total} découvert(s)',
      'sector_shields': 'BOUCLIERS SECTORIELS',
      'sector_edges': 'AVANTAGES SECTORIELS',
      'sector_insights': 'VISIONS SECTORIELLES',
      'sector_dominances': 'DOMINATION SECTORIELLE',
      'winning_streaks': 'SÉRIE GAGNANTE',

      // Rarity labels
      'rarity_common': 'Commun',
      'rarity_uncommon': 'Peu commun',
      'rarity_rare': 'Rare',
      'rarity_epic': 'Épique',
      'rarity_legendary': 'Légendaire',

      // Category labels
      'category_trading': 'TRADING',
      'category_information': 'INFORMATION',
      'category_portfolio': 'PORTFOLIO',
      'category_unlock': 'DÉBLOCAGE',
      'category_risk': 'RISQUE',
      'category_income': 'REVENU',
      'category_time': 'TEMPS',
      'category_quota': 'QUOTA',

      // Sector type names (for shop/collection cards)
      'sector_type_technology': 'Technologie',
      'sector_type_healthcare': 'Santé',
      'sector_type_finance': 'Finance',
      'sector_type_energy': 'Énergie',
      'sector_type_consumerGoods': 'Consommation',
      'sector_type_industrial': 'Industrie',
      'sector_type_realEstate': 'Immobilier',
      'sector_type_telecommunications': 'Télécom',
      'sector_type_materials': 'Matériaux',
      'sector_type_utilities': 'Services publics',
      'sector_type_gaming': 'Jeux vidéo',
      'sector_type_crypto': 'Crypto',
      'sector_type_aerospace': 'Aérospatial',
      'sector_type_commodities': 'Matières premières',
      'sector_type_forex': 'Forex',
      'sector_type_indices': 'Indices',

      // News headlines and descriptions
      'news_earnings_beat_headline': '{company} dépasse les attentes de bénéfices',
      'news_earnings_beat_desc': 'Les analystes qui prédisaient le pire "réévaluent leurs modèles." Traduction : ils avaient tort. Encore.',
      'news_earnings_miss_headline': '{company} manque les objectifs du T{quarter}',
      'news_earnings_miss_desc': 'Le PDG accuse "les vents contraires macroéconomiques" au lieu d\'admettre que le budget yacht a dérapé.',
      'news_earnings_record_headline': '{company} annonce des profits records',
      'news_earnings_record_desc': 'Le conseil se vote des bonus. Les employés ont droit à une pizza party. L\'action s\'envole.',
      'news_product_launch_headline': '{company} lance un nouveau produit révolutionnaire',
      'news_product_launch_desc': 'C\'est le même produit avec une nouvelle couleur. Les investisseurs appellent ça "l\'innovation disruptive."',
      'news_product_delay_headline': '{company} retarde la sortie d\'un produit majeur',
      'news_product_delay_desc': 'Il paraît que "aller vite et casser des trucs" a des conséquences. Qui l\'eût cru ?',
      'news_product_recall_headline': '{company} fait face à un rappel de produit',
      'news_product_recall_desc': '"La sécurité client est notre priorité" dit l\'entreprise qui visiblement s\'en fichait jusqu\'ici.',
      'news_merger_announce_headline': '{company} annonce une acquisition majeure',
      'news_merger_announce_desc': 'Deux entreprises médiocres fusionnent pour n\'en former qu\'une grosse médiocre. Synergie !',
      'news_merger_collapse_headline': '{company} : les négociations de fusion échouent',
      'news_merger_collapse_desc': 'Les deux PDG voulaient le bureau d\'angle. Personne n\'a pensé à tirer à pile ou face.',
      'news_regulation_negative_headline': 'De nouvelles réglementations impactent le secteur {sector}',
      'news_regulation_negative_desc': 'Le gouvernement a enfin remarqué les failles. Les lobbyistes font des heures sup.',
      'news_regulation_positive_headline': 'Le secteur {sector} reçoit une approbation réglementaire',
      'news_regulation_positive_desc': 'Les régulateurs approuvent un truc qu\'ils ne comprennent clairement pas. Business as usual.',
      'news_market_rally_headline': 'Le marché rebondit sur de solides données économiques',
      'news_market_rally_desc': 'Ligne verte monte. Les experts prétendent avoir prédit ça. Les traders Twitter se croient génies.',
      'news_market_volatility_headline': 'La volatilité du marché explose dans l\'incertitude',
      'news_market_volatility_desc': 'Des algos qui se battent contre des algos pendant que les humains paniquent. Capitalisme de pointe.',
      'news_market_bull_headline': 'Le marché haussier poursuit sa série record',
      'news_market_bull_desc': 'Tout le monde est un génie en bull market. Les conseils crypto de ton cousin semblent presque sensés.',
      'news_sector_growth_headline': 'Le secteur {sector} connaît une forte croissance',
      'news_sector_growth_desc': 'Les dirigeants se félicitent. Les employés se demandent où est passée leur augmentation.',
      'news_sector_headwinds_headline': 'Le secteur {sector} fait face à des vents contraires',
      'news_sector_headwinds_desc': '"Vents contraires" c\'est le jargon corporate pour "on a merdé mais c\'est pas notre faute".',
      'news_economy_fed_headline': 'La Fed signale des changements de taux d\'intérêt',
      'news_economy_fed_desc': 'Jerome Powell dit des mots. Les marchés font une crise existentielle. Rincer, répéter.',
      'news_economy_gdp_headline': 'La croissance du PIB dépasse les attentes',
      'news_economy_gdp_desc': 'L\'économie va bien si on ignore tous ceux qui ne sont pas actionnaires.',
      'news_economy_inflation_headline': 'Les inquiétudes sur l\'inflation augmentent',
      'news_economy_inflation_desc': 'Votre argent vaut moins mais les PDG ont eu leurs bonus. Le système fonctionne !',
      'news_platform_free_trading_headline': 'Le courtier annonce une journée de trading sans commission !',
      'news_platform_free_trading_desc': 'Ils se rattraperont en vendant vos données de toute façon. YOLO responsable !',
      'news_platform_fee_reduction_headline': 'La plateforme de trading réduit les frais de 50%',
      'news_platform_fee_reduction_desc': 'La concurrence fonctionne ! Jusqu\'à ce qu\'ils fusionnent et remontent les prix.',
      'news_platform_fee_increase_headline': 'Frais de maintenance de la plateforme augmentés',
      'news_platform_fee_increase_desc': 'Les serveurs ne se paient pas tout seuls. Les maisons de plage des PDG non plus.',
      'news_platform_surcharge_headline': 'Surcharge pour volume élevé appliquée à tous les trades',
      'news_platform_surcharge_desc': 'Trop de gens qui gagnent de l\'argent ? Ajoutons des frais. Ça ne va pas le faire.',
      'news_bonus_loyalty_headline': 'Bonus de fidélité courtier crédité sur votre compte !',
      'news_bonus_loyalty_desc': 'Voici une infime fraction de ce qu\'on a gagné sur vous. Ne dépensez pas tout d\'un coup.',
      'news_bonus_rebate_headline': 'Remise sur volume de trading reçue',
      'news_bonus_rebate_desc': 'Vous avez tellement tradé qu\'on a eu des remords. Non je déconne, c\'est une dépense marketing.',
      'news_bonus_promo_headline': 'Bonus promotionnel nouvel utilisateur !',
      'news_bonus_promo_desc': 'De l\'argent gratuit pour vous rendre accro. La première dose est toujours gratuite.',
      'news_bonus_compensation_headline': 'Compensation pour bug système créditée',
      'news_bonus_compensation_desc': 'Oups, on a cassé un truc. Voilà de l\'argent pour acheter votre silence. SVP ne tweetez pas.',
      'news_restriction_short_ban_headline': 'La SEC interdit temporairement la vente à découvert',
      'news_restriction_short_ban_desc': 'Les hedge funds se plaignent que leurs shorts ne marchent pas. Les particuliers : "Première fois ?"',
      'news_restriction_short_emergency_headline': 'Restrictions d\'urgence sur la vente à découvert',
      'news_restriction_short_emergency_desc': 'Quand les riches perdent de l\'argent, subitement le short selling devient un problème. Curieux.',
      'news_restriction_position_limit_headline': 'Limites de position temporairement appliquées',
      'news_restriction_position_limit_desc': 'Trop de singes qui achètent ? Limitons leur fun. La maison gagne toujours.',
      'news_restriction_short_lifted_headline': 'Interdiction de vente à découvert levée en avance !',
      'news_restriction_short_lifted_desc': 'Les hedge funds ont bien lobbié. La démocratie en action. 🎉',
      'news_event_flash_sale_headline': 'Vente flash : 50% sur toutes les améliorations !',
      'news_event_flash_sale_desc': 'Consommez ! Améliorez ! Le marché l\'exige. Votre portefeuille pleure.',
      'news_event_clearance_headline': 'Soldes améliorations : 30% de réduction',
      'news_event_clearance_desc': 'On doit atteindre nos objectifs trimestriels. Aidez une corporation ?',
      'news_event_circuit_breaker_headline': 'Coupe-circuit du marché déclenché !',
      'news_event_circuit_breaker_desc': 'Les marchés sont trop fous même pour Wall Street. Tout le monde respire un coup.',
      'news_event_flash_crash_headline': 'Alerte flash crash : volatilité extrême à venir',
      'news_event_flash_crash_desc': 'Des robots qui se battent contre des robots. Les humains ne sont que passagers. Bienvenue en 2024.',
      'news_event_stabilize_headline': 'Le marché se stabilise : la volatilité diminue',
      'news_event_stabilize_desc': 'L\'imprimante à billets fait brrr. Crise évitée. Jusqu\'à la semaine prochaine.',
      'news_event_data_glitch_headline': 'Flux de données corrompus !',
      'news_event_data_glitch_desc': 'Vos indicateurs affichent l\'inverse de la réalité. Bonne chance.',
      'news_event_algo_confusion_headline': 'Chaos algorithmique : les bots de trading déraillent',
      'news_event_algo_confusion_desc': 'Les robots sont perdus. Les humains l\'étaient déjà. C\'est la confusion à tous les étages.',
      'news_event_sector_rotation_headline': 'Rotation sectorielle massive !',
      'news_event_sector_rotation_desc': 'Ce qui montait descend. Ce qui descendait monte. Bienvenue à la roulette boursière.',
      'news_event_whale_activity_headline': 'Alerte baleine : position massive détectée',
      'news_event_whale_activity_desc': 'Quelqu\'un avec plus d\'argent que de bon sens vient de bouger le marché. Accrochez-vous.',
      'news_generic_company_headline': '{company} fait les gros titres',
      'news_generic_company_desc': 'Le PDG a dit un truc sur Twitter. L\'action réagit en conséquence.',
      'news_generic_sector_headline': 'Mise à jour du secteur {sector}',
      'news_generic_sector_desc': 'Les analystes publient des rapports que personne ne lit. Les actions font ce qu\'elles veulent.',
      'news_generic_market_headline': 'Mise à jour du marché',
      'news_generic_market_desc': 'Les actions ont monté, baissé, ou stagné. Les experts expliquent pourquoi après coup.',

      // Mid-day contradiction news
      'midday_prefix_update': 'MISE À JOUR : ',
      'midday_prefix_correction': 'CORRECTION : ',
      'midday_prefix_breaking': 'FLASH : ',
      'midday_prefix_reversal': 'RETOURNEMENT : ',
      'midday_prefix_recovery': 'REBOND : ',
      'news_midday_company_positive_headline': '{company} se reprend, les analystes relèvent leurs prévisions',
      'news_midday_company_positive_desc': 'Les inquiétudes précédentes se révèlent infondées. Les vendeurs à découvert paniquent. Ça fait plaisir à voir.',
      'news_midday_company_negative_headline': '{company} fait face à des défis inattendus',
      'news_midday_company_negative_desc': 'L\'optimisme initial s\'estompe alors que les analystes révisent leurs projections. Les bulls du matin font comme s\'ils avaient été prudents depuis le début.',
      'news_midday_sector_positive_headline': 'Le secteur {sector} rebondit sur de nouveaux développements',
      'news_midday_sector_positive_desc': 'Le sentiment du marché évolue alors que les conditions s\'améliorent. Les mains de papier en sueur.',
      'news_midday_sector_negative_headline': 'Le secteur {sector} efface ses gains',
      'news_midday_sector_negative_desc': 'L\'optimisme matinal cède la place aux ventes de l\'après-midi. Les "mains de diamant" mises à l\'épreuve une fois de plus.',
      'news_midday_market_positive_headline': 'Les marchés se reprennent après les pertes matinales',
      'news_midday_market_positive_desc': 'Les investisseurs trouvent des opportunités d\'achat après la vente initiale. Le creux a été acheté. La prophétie s\'accomplit.',
      'news_midday_market_negative_headline': 'Les marchés effacent les gains matinaux',
      'news_midday_market_negative_desc': 'Les prises de bénéfices et de nouvelles inquiétudes pèsent sur les indices. Il s\'avère qu\'un matin vert n\'est pas une garantie.',

      // News category labels
      'news_category_earnings': 'Résultats',
      'news_category_market': 'Marché',
      'news_category_sector': 'Secteur',
      'news_category_company': 'Entreprise',
      'news_category_economy': 'Économie',
      'news_category_regulation': 'Régulation',
      'news_category_merger': 'F&A',
      'news_category_product': 'Produit',
      'news_category_platform': 'Plateforme',
      'news_category_bonus': 'Bonus',
      'news_category_restriction': 'Restriction',
      'news_category_event': 'Événement',
      'news_category_informant': 'Informateur',

      // News informateur
      'news_informant_tip_headline': '\u{1F575}\uFE0F {company} : Tip acquis',
      'news_informant_tip_desc': 'Un tip secret a été acheté auprès de l\'informateur.',

      // Skip quota
      'skip_quota': 'PASSER LE QUOTA',

      // Restriction position cap
      'news_restriction_position_cap_headline': 'Règles de taille de position appliquées',
      'news_restriction_position_cap_desc': 'Les tailles de trades sont temporairement plafonnées pour la gestion des risques.',

      // Tutoriel
      'disclaimer': 'Avertissement Important',
      'welcome_to_kandl': 'Bienvenue sur KANDL',
      'skip_tutorial': 'Passer le tutoriel',
      'start_playing': 'Commencer à jouer',
      'important_warning': 'Avertissement Important',
      'traders_lose_money': 'des investisseurs particuliers perdent de l\'argent en négociant des actions et produits dérivés. La plupart des day traders échouent à générer des profits.',
      'disclaimer_gambling': 'Le trading peut être aussi addictif que les jeux d\'argent. N\'investissez jamais d\'argent que vous ne pouvez pas vous permettre de perdre.',
      'disclaimer_educational': 'Ce jeu est uniquement à des fins de divertissement et d\'éducation. Il ne reflète pas les conditions réelles du marché.',
      'disclaimer_not_advice': 'Rien dans ce jeu ne constitue un conseil financier. Consultez toujours un professionnel avant d\'investir de l\'argent réel.',
      'disclaimer_remember': 'N\'oubliez pas : Ce n\'est qu\'un jeu. Les vrais marchés sont bien plus complexes et imprévisibles.',
      'game_description': 'Tradez des actions, atteignez vos quotas, débloquez des améliorations et construisez votre empire de trading dans ce simulateur idle !',
      'feature_trading': 'Achat & Vente d\'Actions',
      'feature_trading_desc': 'Tradez sur plusieurs secteurs avec des positions longues et courtes',
      'feature_quota': 'Atteignez votre Quota',
      'feature_quota_desc': 'Atteignez votre objectif de profit avant la fin du temps imparti',
      'feature_upgrades': 'Débloquez des Améliorations',
      'feature_upgrades_desc': 'Gagnez des bonus puissants pour booster votre trading',
      'feature_achievements': 'Gagnez des Succès',
      'feature_achievements_desc': 'Complétez des défis pour des récompenses permanentes',
      'tutorial_next': 'Suivant',
      'tutorial_got_it': 'Compris !',
      'tutorial_skip': 'Passer',
      'restart_tutorial': 'Relancer le tutoriel',
      'tutorial_dashboard_title': 'Tableau de bord',
      'tutorial_dashboard_desc': 'Votre centre de commande ! Suivez votre progression, les tendances du marché et la performance de votre portefeuille.',
      'tutorial_metrics_title': 'Métriques Clés',
      'tutorial_metrics_desc': 'Surveillez votre Cash, la Valeur du Portefeuille et votre Quota. Atteignez votre quota avant la date limite !',
      'tutorial_stats_title': 'Stats du Marché',
      'tutorial_stats_desc': 'Suivez le jour actuel, l\'heure et le statut du marché. Le marché bouge vite - surveillez l\'horloge !',
      'tutorial_position_statistics_title': 'Statistiques des Positions',
      'tutorial_position_statistics_desc': 'Voyez combien de positions sont rentables ou perdantes, et identifiez vos meilleures et pires performances.',
      'tutorial_trading_performance_title': 'Performance de Trading',
      'tutorial_trading_performance_desc': 'Suivez votre taux de réussite, P&L total et séries de trades. Découvrez vos meilleurs et pires trades !',
      'tutorial_risk_metrics_title': 'Métriques de Risque',
      'tutorial_risk_metrics_desc': 'Surveillez la diversification et le niveau de risque de votre portefeuille. Un portefeuille diversifié est plus résilient !',
      'tutorial_milestone_progress_title': 'Objectif de Quota',
      'tutorial_milestone_progress_desc': 'Votre objectif principal ! Gagnez assez de profit pour atteindre le quota avant la fin du temps. Bonus si vous le dépassez !',
      'tutorial_challenges_panel_title': 'Défis Quotidiens',
      'tutorial_challenges_panel_desc': 'Complétez les défis quotidiens pour des récompenses bonus. De nouveaux défis apparaissent chaque jour !',
      'tutorial_recent_trades_title': 'Trades Récents',
      'tutorial_recent_trades_desc': 'Consultez votre activité de trading récente. Cliquez sur un trade pour accéder à la vue trading de cette action.',
      'tutorial_position_news_title': 'Actualités des Positions',
      'tutorial_position_news_desc': 'Restez informé ! Voyez les actualités qui impactent vos positions actuelles. Réagissez vite pour maximiser vos profits.',
      'tutorial_sectors_title': 'Secteurs',
      'tutorial_sectors_desc': 'Explorez différents secteurs du marché. Chacun a des caractéristiques uniques et des actions à trader.',
      'tutorial_stocks_title': 'Actions',
      'tutorial_stocks_desc': 'Parcourez toutes les actions disponibles. Vérifiez les prix, tendances et notes des analystes avant de trader.',
      'tutorial_trading_title': 'Trading',
      'tutorial_trading_desc': 'Achetez et vendez des actions ici. Allez Long pour parier sur la hausse, ou Short pour profiter des baisses.',
      'tutorial_positions_title': 'Positions',
      'tutorial_positions_desc': 'Visualisez vos trades ouverts et suivez vos profits. Fermez des positions pour réaliser des gains ou limiter les pertes.',
      'tutorial_upgrades_title': 'Améliorations',
      'tutorial_upgrades_desc': 'À la fin de chaque jour, choisissez une amélioration pour booster vos capacités de trading !',
      'tutorial_prestige_title': 'Boutique Prestige',
      'tutorial_prestige_desc': 'Si vous échouez à atteindre le quota, dépensez des Points Prestige pour des bonus permanents qui persistent entre les parties.',
      'tutorial_achievements_title': 'Succès',
      'tutorial_achievements_desc': 'Complétez des défis pour gagner des récompenses permanentes qui s\'appliquent à toutes vos futures parties !',
      'tutorial_fintok_title': 'FinTok',
      'tutorial_fintok_desc': 'Obtenez des conseils boursiers d\'influenceurs sur les réseaux sociaux. Mais attention - tous les conseils ne sont pas fiables !',

      // FinTok UI
      'fintok_active': 'actifs',
      'fintok_no_tips': 'Aucun conseil pour le moment...',
      'fintok_no_influencers': 'Aucun influenceur actif',
      'fintok_appear_soon': 'Ils apparaitront au fil du jeu !',
      'fintok_followers': 'Abonnes',
      'fintok_tips_given': 'Conseils donnes',
      'fintok_accuracy': 'Precision',
      'fintok_reputation': 'Reputation',
      'fintok_unknown': 'Inconnue',
      'fintok_follow': 'Suivre',
      'fintok_unfollow': 'Ne plus suivre',
      'fintok_following': 'Suivi',
      'fintok_buy': 'ACHAT',
      'fintok_sell': 'VENTE',
      'fintok_accurate': 'Correct !',
      'fintok_wrong': 'Faux !',
      'fintok_viral': 'VIRAL',
      'fintok_unreliable': 'PEU FIABLE',
      'fintok_excellent': 'Excellent',
      'fintok_good': 'Bon',
      'fintok_average': 'Moyen',
      'fintok_poor': 'Mauvais',
      'fintok_terrible': 'Terrible',
      'fintok_joined': 'a rejoint FinTok !',
      'fintok_left': 'a quitte FinTok',

      // Stock signals
      'signal_on_sale': 'En Solde !',
      'signal_good_deal': 'Bon Prix',
      'signal_rising': 'En Hausse',
      'signal_falling': 'En Baisse',
      'signal_pricey': 'Cher',
      'signal_overheated': 'Surchauffé !',

      'tutorial_sectors_intro_title': 'Bienvenue dans les Secteurs !',
      'tutorial_sectors_intro_desc': 'Ici vous pouvez voir tous les secteurs du marché. Cliquez sur un secteur pour voir ses actions. Chaque secteur réagit différemment aux événements !',
      'tutorial_stocks_intro_title': 'Liste des Actions',
      'tutorial_stocks_intro_desc': 'Voici votre navigateur d\'actions. Observez les variations de prix, consultez les notes des analystes, et cliquez Trade pour ouvrir une position.',
      'tutorial_trading_intro_title': 'Prêt à Trader !',
      'tutorial_trading_intro_desc': 'Sélectionnez une action et choisissez la taille de votre position. Allez LONG si vous pensez que le prix va monter, ou SHORT pour profiter des baisses.',
      'tutorial_first_buy_title': 'Faites Votre Premier Trade !',
      'tutorial_first_buy_desc': 'C\'est le moment d\'acheter votre première action ! Sélectionnez les parts et cliquez ACHETER pour ouvrir une position long. Bonne chance !',
      'tutorial_positions_intro_title': 'Vos Positions',
      'tutorial_positions_intro_desc': 'Bravo ! Ici vous pouvez voir tous vos trades ouverts. Surveillez votre P&L et fermez vos positions quand vous voulez prendre vos bénéfices.',
      'tutorial_informant_title': 'L\'Informateur',
      'tutorial_informant_desc': 'Un mystérieux initié vient d\'apparaître ! Il offre des infos précieuses sur le marché - mais ça a un prix. Choisissez sagement !',
      'tutorial_click_button': 'Cliquez sur le bouton ci-dessus',

      // Mode expert
      'expert_mode': 'Mode Expert',
      'expert_mode_desc': 'Afficher les indicateurs avancés',

      // Paramètres notifications
      'price_alert_threshold': 'Seuil d\'alerte prix',
      'price_alert_threshold_desc': 'Alerte quand un titre bouge de plus de ce %',

      // Levier
      'leverage': 'Levier',
      'leverage_desc': 'Multipliez vos gains et vos pertes',
      'leverage_warning': 'Risque amplifié',

      // Trailing stop
      'trailing_stop': 'SL intelligent (suit les gains)',

      // Ordres limites
      'limit_orders': 'Ordres Limites',
      'limit_buy': 'Achat Limite',
      'limit_sell': 'Vente Limite',
      'target_price': 'Prix cible',
      'waiting_for_price': 'En attente du prix cible...',
      'place_limit_buy': 'Placer ordre d\'achat',
      'place_limit_sell': 'Placer ordre de vente',
      'limit_order_placed': 'Ordre limite placé !',
      'limit_order_failed': 'Impossible de placer l\'ordre',

      // Titres joueur
      'title_beginner': 'Débutant',
      'title_novice': 'Novice',
      'title_apprentice': 'Apprenti',
      'title_trader': 'Trader',
      'title_veteran': 'Vétéran',
      'title_expert': 'Expert',
      'title_legend': 'Légende',

      // Jalons
      'milestone_reached': 'Jalon atteint !',
      'milestone_1000': 'Premier millier',
      'milestone_2500': 'Bon début',
      'milestone_5000': 'À mi-chemin',
      'milestone_10000': 'Cinq chiffres !',
      'milestone_25000': 'Ligue majeure',
      'milestone_50000': 'Bâtisseur de fortune',
      'milestone_100000': 'Six chiffres !',
      'milestone_250000': 'Quart de million',
      'milestone_500000': 'Demi-millionnaire',
      'milestone_1000000': 'MILLIONNAIRE !',
      'milestone_2500000': 'Multi-millionnaire',
      'milestone_5000000': 'Flambeur',
      'milestone_10000000': 'Huit chiffres !',
      'milestone_25000000': 'Magnat',
      'milestone_50000000': 'Mogol',
      'milestone_100000000': 'Centimillionnaire !',
      'milestone_500000000': 'Demi-milliardaire',
      'milestone_1000000000': 'MILLIARDAIRE !',
      'milestone_10000000000': 'Mega milliardaire',
      'milestone_100000000000': 'Hectomilliardaire',
      'milestone_1000000000000': 'BILLIONNAIRE !',

      // Records personnels
      'new_record': 'Nouveau record !',
      'personal_best': 'Record personnel',
      'best_net_worth': 'Meilleure fortune',
      'best_day_profit': 'Meilleur jour',
      'best_single_trade': 'Meilleur trade',
      'best_win_streak': 'Meilleure série',
      'most_days_survived': 'Plus de jours',

      // Résumés de fin de journée
      'narrative_great_day': 'Quelle journée incroyable ! Ton portfolio a explosé !',
      'narrative_good_day': 'Une bonne journée de gains. Continue comme ça !',
      'narrative_tough_day': 'Journée difficile. Demain est un nouveau jour.',
      'narrative_small_loss': 'Petite baisse aujourd\'hui. Rien de grave.',
      'narrative_flat_day': 'Journée calme sur le marché. C\'est pas toujours mal.',

      // Messages d\'encouragement
      'hint_invest_cash': 'Tu as du cash qui dort — investis-le !',
      'encourage_quota_met': 'Objectif atteint ! Tu gères !',
      'encourage_hot_streak': 'Tu es en feu ! Continue sur ta lancée !',
      'encourage_dont_panic': 'Pas de panique ! Le marché remonte toujours.',
      'encourage_nice_trades': 'Bons trades aujourd\'hui ! Bien joué.',

      // Objectif quotidien
      'daily_objective': 'Objectif du jour',
      'earn_today': 'Gagne {amount} aujourd\'hui',
      'objective_met': 'En bonne voie !',

      // Trade du jour
      'trade_of_the_day': 'Trade du jour',
      'analysts_recommend': 'Les analystes recommandent',

      // Favoris
      'favorites': 'Favoris',
      'add_to_favorites': 'Ajouter aux favoris',
      'remove_from_favorites': 'Retirer des favoris',

      // Résumé de la run
      'run_summary': 'Résumé de la run',
      'run_over_title': 'Partie terminée !',
      'days_survived': 'Jours survécus',
      'winning_trades': 'Gagnants',
      'losing_trades': 'Perdants',
      'total_profit': 'Profit total',
      'best_trade_label': 'Meilleur trade',
      'worst_trade_label': 'Pire trade',
      'best_streak': 'Meilleure série',
      'quotas_met': 'Objectifs atteints',
      'final_fortune': 'Fortune finale',
      'peak_fortune': 'Fortune max',
      'pp_earned': 'PP gagnés',
      'continue_to_tree': 'DÉPENSER LES POINTS DE PRESTIGE',

      // Aperçu prestige
      'prestige_preview': 'Points de prestige gagnés',

      // Tout vendre
      'sell_all': 'TOUT VENDRE',
      'sell_all_confirm': 'Vendre toutes les parts ?',

      // Noms de risque fun
      'risk_low': 'Zen',
      'risk_medium': 'Audacieux',
      'risk_high': 'YOLO',
      'risk_very_high': 'Casse-cou',

      // Infobulles
      'tooltip_fortune': 'Votre richesse totale incluant cash et investissements',
      'tooltip_gains': 'Combien de profit vous avez encaissé en vendant',
      'tooltip_current_gains': 'Combien valent vos positions ouvertes maintenant',
      'tooltip_quota': 'Le montant à gagner avant la date limite',
      'tooltip_win_rate': 'Pourcentage de trades gagnants',
      'tooltip_diversification': 'À quel point vos investissements sont diversifiés',

      // Classement
      'leaderboard': 'Meilleures runs',
      'no_runs_yet': 'Aucune run terminée',
      'run_number': 'Run n°{number}',

      // ── Clefs UI Talent Tree ──
      'talent_buy': 'ACHETER',
      'node_locked': 'VERROUILLÉ',
      'node_purchased': 'ACHETÉ',
      'not_enough_pp': 'PAS ASSEZ DE PP',

      // ── Racines ──
      'upgrade_root_name': 'Capital Initial',
      'upgrade_root_desc': 'Votre premier pas dans l\u2019arbre de prestige',
      'upgrade_general_root_name': 'Capital Initial',
      'upgrade_general_root_desc': 'Votre premier pas dans l\u2019arbre de prestige',
      'upgrade_sector_root_name': 'Maîtrise Sectorielle',
      'upgrade_sector_root_desc': 'Spécialisez-vous dans les secteurs du marché',

      // ══════════ Branche TRADER ══════════
      // Colonne principale
      'upgrade_tr_seed1_name': 'Capital I',
      'upgrade_tr_seed1_desc': 'Votre premier capital de trading',
      'upgrade_tr_slot1_name': 'Slot Suppl. I',
      'upgrade_tr_slot1_desc': 'Élargissez votre portefeuille',
      'upgrade_tr_seed2_name': 'Capital II',
      'upgrade_tr_seed2_desc': 'Augmenter votre capital de départ',
      'upgrade_tr_slot2_name': 'Slot Suppl. II',
      'upgrade_tr_slot2_desc': 'Plus de place pour trader',
      'upgrade_tr_seed3_name': 'Capital III',
      'upgrade_tr_seed3_desc': 'Capital de départ sérieux',
      'upgrade_tr_slot3_name': 'Slot Suppl. III',
      'upgrade_tr_slot3_desc': 'Diversifiez davantage',
      'upgrade_tr_slot4_name': 'Slot Suppl. IV',
      'upgrade_tr_slot4_desc': 'Expansion du portefeuille',
      'upgrade_tr_slot5_name': 'Slot Suppl. V',
      'upgrade_tr_slot5_desc': 'Croissance majeure du portefeuille',
      'upgrade_tr_slot6_name': 'Slot Suppl. VI',
      'upgrade_tr_slot6_desc': 'Capacité maximale',
      'upgrade_tr_cap_name': 'Trader Infini',
      'upgrade_tr_cap_desc': 'Aucune limite sur votre portefeuille',
      // Stop Loss / Take Profit
      'upgrade_tr_sl_name': 'Stop Loss',
      'upgrade_tr_sl_desc': 'Vente auto quand les pertes atteignent votre seuil',
      'upgrade_tr_tp_name': 'Take Profit',
      'upgrade_tr_tp_desc': 'Vente auto quand les gains atteignent votre objectif',
      'upgrade_tr_trailing_name': 'Trailing Stop',
      'upgrade_tr_trailing_desc': 'Le stop loss suit le prix à la hausse automatiquement',
      'upgrade_tr_partial_tp_name': 'Take Profit Partiel',
      'upgrade_tr_partial_tp_desc': 'Vendre la moitié à l\u2019objectif, laisser le reste',
      'upgrade_tr_safety_name': 'Filet de Sécurité',
      'upgrade_tr_safety_desc': 'Votre premier stop loss est atténué',
      // Winning Streak
      'upgrade_tr_streak_name': 'Série Gagnante',
      'upgrade_tr_streak_desc': 'Chaque victoire consécutive booste la suivante',
      'upgrade_tr_hot_hand_name': 'Main Chaude',
      'upgrade_tr_hot_hand_desc': 'Votre chance se cumule tant que vous gagnez',
      'upgrade_tr_resilient_name': 'Résilient',
      'upgrade_tr_resilient_desc': 'Un mauvais trade vous ralentit, sans vous arrêter',
      // Tempo Trading
      'upgrade_tr_qf1_name': 'Quick Flip I',
      'upgrade_tr_qf1_desc': 'Le day trading paie une prime',
      'upgrade_tr_qf2_name': 'Quick Flip II',
      'upgrade_tr_qf2_desc': 'Réflexes affûtés, meilleures récompenses',
      'upgrade_tr_scalper_name': 'Scalper',
      'upgrade_tr_scalper_desc': 'Entrée-sortie sans friction',
      'upgrade_tr_patient1_name': 'Trader Patient I',
      'upgrade_tr_patient1_desc': 'Tout vient à point à qui sait attendre',
      'upgrade_tr_patient2_name': 'Trader Patient II',
      'upgrade_tr_patient2_desc': 'La patience est une vertu',
      'upgrade_tr_diamond_name': 'Mains de Diamant',
      'upgrade_tr_diamond_desc': 'Ne jamais lâcher un gagnant',
      // Limit Orders
      'upgrade_tr_limit_orders_name': 'Ordres Limites',
      'upgrade_tr_limit_orders_desc': 'Définir un prix cible pour l\u2019achat ou la vente auto',
      'upgrade_tr_smart_orders_name': 'Ordres Intelligents',
      'upgrade_tr_smart_orders_desc': 'Attacher auto le SL et TP aux ordres limites',
      // Multiplicateurs de Profit
      'upgrade_tr_profit1_name': '\u0152il Vif I',
      'upgrade_tr_profit1_desc': 'Repérer les opportunités que d\u2019autres manquent',
      'upgrade_tr_profit2_name': '\u0152il Vif II',
      'upgrade_tr_profit2_desc': 'Les tendances du marché deviennent claires',
      'upgrade_tr_profit3_name': '\u0152il Vif III',
      'upgrade_tr_profit3_desc': 'Vous voyez la matrice',
      'upgrade_tr_eagle_name': '\u0152il d\u2019Aigle',
      'upgrade_tr_eagle_desc': 'Rien n\u2019échappe à votre regard',
      // Effet de Levier
      'upgrade_tr_margin_name': 'Compte Marge',
      'upgrade_tr_margin_desc': 'Accès au capital emprunté',
      'upgrade_tr_lev15_name': 'Levier x1.5',
      'upgrade_tr_lev15_desc': 'Augmenter votre pouvoir d\u2019achat',
      'upgrade_tr_lev2_name': 'Levier x2',
      'upgrade_tr_lev2_desc': 'Doubler la mise',
      'upgrade_tr_margin_shield_name': 'Bouclier Marge',
      'upgrade_tr_margin_shield_desc': 'Atténuer le choc de la liquidation',
      'upgrade_tr_lev3_name': 'Levier x3',
      'upgrade_tr_lev3_desc': 'Risque maximum, récompense maximum',
      // Intérêts Composés
      'upgrade_tr_interest1_name': 'Intérêts I',
      'upgrade_tr_interest1_desc': 'Votre cash commence à travailler pour vous',
      'upgrade_tr_interest2_name': 'Intérêts II',
      'upgrade_tr_interest2_desc': 'Meilleurs taux, meilleurs rendements',
      'upgrade_tr_interest3_name': 'Intérêts III',
      'upgrade_tr_interest3_desc': 'Privilèges bancaires premium',

      // ══════════ Branche SURVIE ══════════
      // Colonne principale
      'upgrade_sv_day1_name': 'Jour Extra I',
      'upgrade_sv_day1_desc': 'Plus de temps pour atteindre votre quota',
      'upgrade_sv_life1_name': 'Vie Extra I',
      'upgrade_sv_life1_desc': 'Survivre à un quota raté',
      'upgrade_sv_day2_name': 'Jour Extra II',
      'upgrade_sv_day2_desc': 'Fenêtre de trading étendue',
      'upgrade_sv_quota1_name': 'Allègement I',
      'upgrade_sv_quota1_desc': 'Baisser un peu la barre',
      'upgrade_sv_life2_name': 'Vie Extra II',
      'upgrade_sv_life2_desc': 'Une chance de plus pour se rattraper',
      'upgrade_sv_quota2_name': 'Allègement II',
      'upgrade_sv_quota2_desc': 'Plus de marge sur les objectifs',
      'upgrade_sv_day3_name': 'Jour Extra III',
      'upgrade_sv_day3_desc': 'Temps de trading maximum',
      'upgrade_sv_cap_name': 'Dernier Rempart',
      'upgrade_sv_cap_desc': 'Votre filet de sécurité ultime',
      // Bonus de skip
      'upgrade_sv_skip1_name': 'Bonus Skip I',
      'upgrade_sv_skip1_desc': 'Plus de récompense en sautant un quota',
      'upgrade_sv_skip2_name': 'Bonus Skip II',
      'upgrade_sv_skip2_desc': 'Récompenses de skip plus généreuses',
      'upgrade_sv_skip3_name': 'Série de Skips',
      'upgrade_sv_skip3_desc': 'Les skips consécutifs se cumulent',
      // Récupération de pertes
      'upgrade_sv_recov1_name': 'Récupération I',
      'upgrade_sv_recov1_desc': 'Récupérer une fraction de vos pertes',
      'upgrade_sv_recov2_name': 'Récupération II',
      'upgrade_sv_recov2_desc': 'Meilleure absorption des pertes',
      'upgrade_sv_recov3_name': 'Récupération III',
      'upgrade_sv_recov3_desc': 'Coussin de pertes significatif',
      // Heures sup
      'upgrade_sv_grace1_name': 'Heures Sup I',
      'upgrade_sv_grace1_desc': 'Jour d\'urgence supplémentaire sur quota raté',
      'upgrade_sv_grace2_name': 'Heures Sup II',
      'upgrade_sv_grace2_desc': 'Plus de temps sous pression',
      'upgrade_sv_second_wind_name': 'Second Souffle',
      'upgrade_sv_second_wind_desc': 'Rebondir plus fort après utilisation d\'une vie',
      // Boost PP
      'upgrade_sv_pp1_name': 'Boost PP I',
      'upgrade_sv_pp1_desc': 'Gagner plus de points prestige',
      'upgrade_sv_pp2_name': 'Boost PP II',
      'upgrade_sv_pp2_desc': 'Gains de prestige accrus',
      'upgrade_sv_pp3_name': 'Boost PP III',
      'upgrade_sv_pp3_desc': 'Efficacité prestige maximale',
      // Finish anticipé
      'upgrade_sv_early1_name': 'Lève-Tôt I',
      'upgrade_sv_early1_desc': 'Bonus PP si quota atteint en avance',
      'upgrade_sv_early2_name': 'Lève-Tôt II',
      'upgrade_sv_early2_desc': 'Récompenses de finish anticipé améliorées',
      'upgrade_sv_speedrun_name': 'Speedrunner',
      'upgrade_sv_speedrun_desc': 'Le défi ultime contre la montre',
      // Momentum
      'upgrade_sv_streak1_name': 'Série Gagnante I',
      'upgrade_sv_streak1_desc': 'Les quotas consécutifs créent du momentum',
      'upgrade_sv_streak2_name': 'Série Gagnante II',
      'upgrade_sv_streak2_desc': 'Bonus de série renforcés',
      'upgrade_sv_streak3_name': 'Incassable',
      'upgrade_sv_streak3_desc': 'Votre série persiste même après utilisation d\'une vie',

      // ══════════ Branche AUTOMATISATION ══════════
      'upgrade_bt_hub_name': 'Automatisation',
      'upgrade_bt_hub_desc': 'Améliorer vos robots de trading',

      // ══════════ Branche RENSEIGNEMENT ══════════
      'upgrade_in_hub_name': 'Renseignement',
      'upgrade_in_hub_desc': 'L\u2019information est le pouvoir',
      // Colonne principale
      'upgrade_in_1_name': 'Radar Info',
      'upgrade_in_1_desc': 'Aperçu des nouvelles de demain',
      'upgrade_in_2_name': 'Boule de Cristal',
      'upgrade_in_2_desc': 'Valeurs précises des tuyaux',
      'upgrade_in_3_name': 'Accès Privilégié',
      'upgrade_in_3_desc': 'Tuyau gratuit quotidien',
      'upgrade_in_4_name': 'Filtre FinTok',
      'upgrade_in_4_desc': 'Détecter les conseils douteux',
      'upgrade_in_5_name': 'Recherche Approfondie',
      'upgrade_in_5_desc': 'Renseignements plus précis',
      'upgrade_in_6_name': 'Omniscience',
      'upgrade_in_6_desc': 'Voir le futur proche',
      // Branches latérales
      'upgrade_in_s1a_name': 'Réseau d\u2019Analystes',
      'upgrade_in_s1a_desc': 'Plus de contacts analystes',
      'upgrade_in_s1b_name': 'Cercle d\u2019Initiés',
      'upgrade_in_s1b_desc': 'Tuyaux de plusieurs secteurs',
      'upgrade_in_s2a_name': 'Lecteur de Patterns',
      'upgrade_in_s2a_desc': 'Identifier les figures chartistes',
      'upgrade_in_s2b_name': 'Détecteur de Tendances',
      'upgrade_in_s2b_desc': 'Identifier les tendances tôt',
      'upgrade_in_s3a_name': 'Exploration de Données',
      'upgrade_in_s3a_desc': 'Collecte automatique de données marché',
      'upgrade_in_s3b_name': 'Contre-Espionnage',
      'upgrade_in_s3b_desc': 'Bloquer les mauvaises nouvelles',
      'upgrade_in_s4a_name': 'Moulin à Rumeurs',
      'upgrade_in_s4a_desc': 'Répandre des rumeurs pour influencer les prix',
      'upgrade_in_s4b_name': 'Bouclier Désinfo',
      'upgrade_in_s4b_desc': 'Immunité aux fausses nouvelles',

      // ══════════ Branche SECTEURS ══════════
      'upgrade_sc_hub_name': 'Secteurs',
      'upgrade_sc_hub_desc': 'Débloquer les spécialisations sectorielles',

      // ── Technologie ──
      'upgrade_technology_t1_name': 'Initié Tech',
      'upgrade_technology_t1_desc': 'Entrer dans le secteur Tech & débloquer le Tier 1',
      'upgrade_technology_t2_name': 'Expert Tech',
      'upgrade_technology_t2_desc': 'Débloquer le Tier 2 pour Tech',
      'upgrade_technology_t3_name': 'Maître Tech',
      'upgrade_technology_t3_desc': 'Débloquer le Tier 3 pour Tech',
      'upgrade_technology_t1_profit_name': 'Boost Tech 1',
      'upgrade_technology_t1_profit_desc': '+15% de profits en Tech',
      'upgrade_technology_t1_shield_name': 'Bouclier Tech 1',
      'upgrade_technology_t1_shield_desc': '-15% de pertes en Tech',
      'upgrade_technology_t1_income_name': 'Revenu Tech 1',
      'upgrade_technology_t1_income_desc': '+20\$/jour en Tech',
      'upgrade_technology_t2_profit_name': 'Boost Tech 2',
      'upgrade_technology_t2_profit_desc': '+20% de profits en Tech',
      'upgrade_technology_t2_shield_name': 'Bouclier Tech 2',
      'upgrade_technology_t2_shield_desc': '-20% de pertes en Tech',
      'upgrade_technology_t2_income_name': 'Revenu Tech 2',
      'upgrade_technology_t2_income_desc': '+40\$/jour en Tech',
      'upgrade_technology_t3_profit_name': 'Boost Tech 3',
      'upgrade_technology_t3_profit_desc': '+25% de profits en Tech',
      'upgrade_technology_t3_shield_name': 'Bouclier Tech 3',
      'upgrade_technology_t3_shield_desc': '-25% de pertes en Tech',
      'upgrade_technology_t3_income_name': 'Revenu Tech 3',
      'upgrade_technology_t3_income_desc': '+60\$/jour en Tech',
      'upgrade_technology_cap_name': 'Magnat Tech',
      'upgrade_technology_cap_desc': 'Spécialisation ultime en Tech',

      // ── Santé ──
      'upgrade_healthcare_t1_name': 'Initié Santé',
      'upgrade_healthcare_t1_desc': 'Entrer dans le secteur Santé & débloquer le Tier 1',
      'upgrade_healthcare_t2_name': 'Expert Santé',
      'upgrade_healthcare_t2_desc': 'Débloquer le Tier 2 pour Santé',
      'upgrade_healthcare_t3_name': 'Maître Santé',
      'upgrade_healthcare_t3_desc': 'Débloquer le Tier 3 pour Santé',
      'upgrade_healthcare_t1_profit_name': 'Boost Santé 1',
      'upgrade_healthcare_t1_profit_desc': '+15% de profits en Santé',
      'upgrade_healthcare_t1_shield_name': 'Bouclier Santé 1',
      'upgrade_healthcare_t1_shield_desc': '-15% de pertes en Santé',
      'upgrade_healthcare_t1_income_name': 'Revenu Santé 1',
      'upgrade_healthcare_t1_income_desc': '+20\$/jour en Santé',
      'upgrade_healthcare_t2_profit_name': 'Boost Santé 2',
      'upgrade_healthcare_t2_profit_desc': '+20% de profits en Santé',
      'upgrade_healthcare_t2_shield_name': 'Bouclier Santé 2',
      'upgrade_healthcare_t2_shield_desc': '-20% de pertes en Santé',
      'upgrade_healthcare_t2_income_name': 'Revenu Santé 2',
      'upgrade_healthcare_t2_income_desc': '+40\$/jour en Santé',
      'upgrade_healthcare_t3_profit_name': 'Boost Santé 3',
      'upgrade_healthcare_t3_profit_desc': '+25% de profits en Santé',
      'upgrade_healthcare_t3_shield_name': 'Bouclier Santé 3',
      'upgrade_healthcare_t3_shield_desc': '-25% de pertes en Santé',
      'upgrade_healthcare_t3_income_name': 'Revenu Santé 3',
      'upgrade_healthcare_t3_income_desc': '+60\$/jour en Santé',
      'upgrade_healthcare_cap_name': 'Magnat Santé',
      'upgrade_healthcare_cap_desc': 'Spécialisation ultime en Santé',

      // ── Finance ──
      'upgrade_finance_t1_name': 'Initié Finance',
      'upgrade_finance_t1_desc': 'Entrer dans le secteur Finance & débloquer le Tier 1',
      'upgrade_finance_t2_name': 'Expert Finance',
      'upgrade_finance_t2_desc': 'Débloquer le Tier 2 pour Finance',
      'upgrade_finance_t3_name': 'Maître Finance',
      'upgrade_finance_t3_desc': 'Débloquer le Tier 3 pour Finance',
      'upgrade_finance_t1_profit_name': 'Boost Finance 1',
      'upgrade_finance_t1_profit_desc': '+15% de profits en Finance',
      'upgrade_finance_t1_shield_name': 'Bouclier Finance 1',
      'upgrade_finance_t1_shield_desc': '-15% de pertes en Finance',
      'upgrade_finance_t1_income_name': 'Revenu Finance 1',
      'upgrade_finance_t1_income_desc': '+20\$/jour en Finance',
      'upgrade_finance_t2_profit_name': 'Boost Finance 2',
      'upgrade_finance_t2_profit_desc': '+20% de profits en Finance',
      'upgrade_finance_t2_shield_name': 'Bouclier Finance 2',
      'upgrade_finance_t2_shield_desc': '-20% de pertes en Finance',
      'upgrade_finance_t2_income_name': 'Revenu Finance 2',
      'upgrade_finance_t2_income_desc': '+40\$/jour en Finance',
      'upgrade_finance_t3_profit_name': 'Boost Finance 3',
      'upgrade_finance_t3_profit_desc': '+25% de profits en Finance',
      'upgrade_finance_t3_shield_name': 'Bouclier Finance 3',
      'upgrade_finance_t3_shield_desc': '-25% de pertes en Finance',
      'upgrade_finance_t3_income_name': 'Revenu Finance 3',
      'upgrade_finance_t3_income_desc': '+60\$/jour en Finance',
      'upgrade_finance_cap_name': 'Magnat Finance',
      'upgrade_finance_cap_desc': 'Spécialisation ultime en Finance',

      // ── Énergie ──
      'upgrade_energy_t1_name': 'Initié Énergie',
      'upgrade_energy_t1_desc': 'Entrer dans le secteur Énergie & débloquer le Tier 1',
      'upgrade_energy_t2_name': 'Expert Énergie',
      'upgrade_energy_t2_desc': 'Débloquer le Tier 2 pour Énergie',
      'upgrade_energy_t3_name': 'Maître Énergie',
      'upgrade_energy_t3_desc': 'Débloquer le Tier 3 pour Énergie',
      'upgrade_energy_t1_profit_name': 'Boost Énergie 1',
      'upgrade_energy_t1_profit_desc': '+15% de profits en Énergie',
      'upgrade_energy_t1_shield_name': 'Bouclier Énergie 1',
      'upgrade_energy_t1_shield_desc': '-15% de pertes en Énergie',
      'upgrade_energy_t1_income_name': 'Revenu Énergie 1',
      'upgrade_energy_t1_income_desc': '+20\$/jour en Énergie',
      'upgrade_energy_t2_profit_name': 'Boost Énergie 2',
      'upgrade_energy_t2_profit_desc': '+20% de profits en Énergie',
      'upgrade_energy_t2_shield_name': 'Bouclier Énergie 2',
      'upgrade_energy_t2_shield_desc': '-20% de pertes en Énergie',
      'upgrade_energy_t2_income_name': 'Revenu Énergie 2',
      'upgrade_energy_t2_income_desc': '+40\$/jour en Énergie',
      'upgrade_energy_t3_profit_name': 'Boost Énergie 3',
      'upgrade_energy_t3_profit_desc': '+25% de profits en Énergie',
      'upgrade_energy_t3_shield_name': 'Bouclier Énergie 3',
      'upgrade_energy_t3_shield_desc': '-25% de pertes en Énergie',
      'upgrade_energy_t3_income_name': 'Revenu Énergie 3',
      'upgrade_energy_t3_income_desc': '+60\$/jour en Énergie',
      'upgrade_energy_cap_name': 'Magnat Énergie',
      'upgrade_energy_cap_desc': 'Spécialisation ultime en Énergie',

      // ── Biens de Consommation ──
      'upgrade_consumerGoods_t1_name': 'Initié Conso',
      'upgrade_consumerGoods_t1_desc': 'Entrer dans le secteur Conso & débloquer le Tier 1',
      'upgrade_consumerGoods_t2_name': 'Expert Conso',
      'upgrade_consumerGoods_t2_desc': 'Débloquer le Tier 2 pour Conso',
      'upgrade_consumerGoods_t3_name': 'Maître Conso',
      'upgrade_consumerGoods_t3_desc': 'Débloquer le Tier 3 pour Conso',
      'upgrade_consumerGoods_t1_profit_name': 'Boost Conso 1',
      'upgrade_consumerGoods_t1_profit_desc': '+15% de profits en Conso',
      'upgrade_consumerGoods_t1_shield_name': 'Bouclier Conso 1',
      'upgrade_consumerGoods_t1_shield_desc': '-15% de pertes en Conso',
      'upgrade_consumerGoods_t1_income_name': 'Revenu Conso 1',
      'upgrade_consumerGoods_t1_income_desc': '+20\$/jour en Conso',
      'upgrade_consumerGoods_t2_profit_name': 'Boost Conso 2',
      'upgrade_consumerGoods_t2_profit_desc': '+20% de profits en Conso',
      'upgrade_consumerGoods_t2_shield_name': 'Bouclier Conso 2',
      'upgrade_consumerGoods_t2_shield_desc': '-20% de pertes en Conso',
      'upgrade_consumerGoods_t2_income_name': 'Revenu Conso 2',
      'upgrade_consumerGoods_t2_income_desc': '+40\$/jour en Conso',
      'upgrade_consumerGoods_t3_profit_name': 'Boost Conso 3',
      'upgrade_consumerGoods_t3_profit_desc': '+25% de profits en Conso',
      'upgrade_consumerGoods_t3_shield_name': 'Bouclier Conso 3',
      'upgrade_consumerGoods_t3_shield_desc': '-25% de pertes en Conso',
      'upgrade_consumerGoods_t3_income_name': 'Revenu Conso 3',
      'upgrade_consumerGoods_t3_income_desc': '+60\$/jour en Conso',
      'upgrade_consumerGoods_cap_name': 'Magnat Conso',
      'upgrade_consumerGoods_cap_desc': 'Spécialisation ultime en Conso',

      // ── Industrie ──
      'upgrade_industrial_t1_name': 'Initié Industrie',
      'upgrade_industrial_t1_desc': 'Entrer dans le secteur Industrie & débloquer le Tier 1',
      'upgrade_industrial_t2_name': 'Expert Industrie',
      'upgrade_industrial_t2_desc': 'Débloquer le Tier 2 pour Industrie',
      'upgrade_industrial_t3_name': 'Maître Industrie',
      'upgrade_industrial_t3_desc': 'Débloquer le Tier 3 pour Industrie',
      'upgrade_industrial_t1_profit_name': 'Boost Industrie 1',
      'upgrade_industrial_t1_profit_desc': '+15% de profits en Industrie',
      'upgrade_industrial_t1_shield_name': 'Bouclier Industrie 1',
      'upgrade_industrial_t1_shield_desc': '-15% de pertes en Industrie',
      'upgrade_industrial_t1_income_name': 'Revenu Industrie 1',
      'upgrade_industrial_t1_income_desc': '+20\$/jour en Industrie',
      'upgrade_industrial_t2_profit_name': 'Boost Industrie 2',
      'upgrade_industrial_t2_profit_desc': '+20% de profits en Industrie',
      'upgrade_industrial_t2_shield_name': 'Bouclier Industrie 2',
      'upgrade_industrial_t2_shield_desc': '-20% de pertes en Industrie',
      'upgrade_industrial_t2_income_name': 'Revenu Industrie 2',
      'upgrade_industrial_t2_income_desc': '+40\$/jour en Industrie',
      'upgrade_industrial_t3_profit_name': 'Boost Industrie 3',
      'upgrade_industrial_t3_profit_desc': '+25% de profits en Industrie',
      'upgrade_industrial_t3_shield_name': 'Bouclier Industrie 3',
      'upgrade_industrial_t3_shield_desc': '-25% de pertes en Industrie',
      'upgrade_industrial_t3_income_name': 'Revenu Industrie 3',
      'upgrade_industrial_t3_income_desc': '+60\$/jour en Industrie',
      'upgrade_industrial_cap_name': 'Magnat Industrie',
      'upgrade_industrial_cap_desc': 'Spécialisation ultime en Industrie',

      // ── Immobilier ──
      'upgrade_realEstate_t1_name': 'Initié Immo',
      'upgrade_realEstate_t1_desc': 'Entrer dans le secteur Immo & débloquer le Tier 1',
      'upgrade_realEstate_t2_name': 'Expert Immo',
      'upgrade_realEstate_t2_desc': 'Débloquer le Tier 2 pour Immo',
      'upgrade_realEstate_t3_name': 'Maître Immo',
      'upgrade_realEstate_t3_desc': 'Débloquer le Tier 3 pour Immo',
      'upgrade_realEstate_t1_profit_name': 'Boost Immo 1',
      'upgrade_realEstate_t1_profit_desc': '+15% de profits en Immo',
      'upgrade_realEstate_t1_shield_name': 'Bouclier Immo 1',
      'upgrade_realEstate_t1_shield_desc': '-15% de pertes en Immo',
      'upgrade_realEstate_t1_income_name': 'Revenu Immo 1',
      'upgrade_realEstate_t1_income_desc': '+20\$/jour en Immo',
      'upgrade_realEstate_t2_profit_name': 'Boost Immo 2',
      'upgrade_realEstate_t2_profit_desc': '+20% de profits en Immo',
      'upgrade_realEstate_t2_shield_name': 'Bouclier Immo 2',
      'upgrade_realEstate_t2_shield_desc': '-20% de pertes en Immo',
      'upgrade_realEstate_t2_income_name': 'Revenu Immo 2',
      'upgrade_realEstate_t2_income_desc': '+40\$/jour en Immo',
      'upgrade_realEstate_t3_profit_name': 'Boost Immo 3',
      'upgrade_realEstate_t3_profit_desc': '+25% de profits en Immo',
      'upgrade_realEstate_t3_shield_name': 'Bouclier Immo 3',
      'upgrade_realEstate_t3_shield_desc': '-25% de pertes en Immo',
      'upgrade_realEstate_t3_income_name': 'Revenu Immo 3',
      'upgrade_realEstate_t3_income_desc': '+60\$/jour en Immo',
      'upgrade_realEstate_cap_name': 'Magnat Immo',
      'upgrade_realEstate_cap_desc': 'Spécialisation ultime en Immo',

      // ── Télécommunications ──
      'upgrade_telecommunications_t1_name': 'Initié Télécom',
      'upgrade_telecommunications_t1_desc': 'Entrer dans le secteur Télécom & débloquer le Tier 1',
      'upgrade_telecommunications_t2_name': 'Expert Télécom',
      'upgrade_telecommunications_t2_desc': 'Débloquer le Tier 2 pour Télécom',
      'upgrade_telecommunications_t3_name': 'Maître Télécom',
      'upgrade_telecommunications_t3_desc': 'Débloquer le Tier 3 pour Télécom',
      'upgrade_telecommunications_t1_profit_name': 'Boost Télécom 1',
      'upgrade_telecommunications_t1_profit_desc': '+15% de profits en Télécom',
      'upgrade_telecommunications_t1_shield_name': 'Bouclier Télécom 1',
      'upgrade_telecommunications_t1_shield_desc': '-15% de pertes en Télécom',
      'upgrade_telecommunications_t1_income_name': 'Revenu Télécom 1',
      'upgrade_telecommunications_t1_income_desc': '+20\$/jour en Télécom',
      'upgrade_telecommunications_t2_profit_name': 'Boost Télécom 2',
      'upgrade_telecommunications_t2_profit_desc': '+20% de profits en Télécom',
      'upgrade_telecommunications_t2_shield_name': 'Bouclier Télécom 2',
      'upgrade_telecommunications_t2_shield_desc': '-20% de pertes en Télécom',
      'upgrade_telecommunications_t2_income_name': 'Revenu Télécom 2',
      'upgrade_telecommunications_t2_income_desc': '+40\$/jour en Télécom',
      'upgrade_telecommunications_t3_profit_name': 'Boost Télécom 3',
      'upgrade_telecommunications_t3_profit_desc': '+25% de profits en Télécom',
      'upgrade_telecommunications_t3_shield_name': 'Bouclier Télécom 3',
      'upgrade_telecommunications_t3_shield_desc': '-25% de pertes en Télécom',
      'upgrade_telecommunications_t3_income_name': 'Revenu Télécom 3',
      'upgrade_telecommunications_t3_income_desc': '+60\$/jour en Télécom',
      'upgrade_telecommunications_cap_name': 'Magnat Télécom',
      'upgrade_telecommunications_cap_desc': 'Spécialisation ultime en Télécom',

      // ── Matériaux ──
      'upgrade_materials_t1_name': 'Initié Matériaux',
      'upgrade_materials_t1_desc': 'Entrer dans le secteur Matériaux & débloquer le Tier 1',
      'upgrade_materials_t2_name': 'Expert Matériaux',
      'upgrade_materials_t2_desc': 'Débloquer le Tier 2 pour Matériaux',
      'upgrade_materials_t3_name': 'Maître Matériaux',
      'upgrade_materials_t3_desc': 'Débloquer le Tier 3 pour Matériaux',
      'upgrade_materials_t1_profit_name': 'Boost Matériaux 1',
      'upgrade_materials_t1_profit_desc': '+15% de profits en Matériaux',
      'upgrade_materials_t1_shield_name': 'Bouclier Matériaux 1',
      'upgrade_materials_t1_shield_desc': '-15% de pertes en Matériaux',
      'upgrade_materials_t1_income_name': 'Revenu Matériaux 1',
      'upgrade_materials_t1_income_desc': '+20\$/jour en Matériaux',
      'upgrade_materials_t2_profit_name': 'Boost Matériaux 2',
      'upgrade_materials_t2_profit_desc': '+20% de profits en Matériaux',
      'upgrade_materials_t2_shield_name': 'Bouclier Matériaux 2',
      'upgrade_materials_t2_shield_desc': '-20% de pertes en Matériaux',
      'upgrade_materials_t2_income_name': 'Revenu Matériaux 2',
      'upgrade_materials_t2_income_desc': '+40\$/jour en Matériaux',
      'upgrade_materials_t3_profit_name': 'Boost Matériaux 3',
      'upgrade_materials_t3_profit_desc': '+25% de profits en Matériaux',
      'upgrade_materials_t3_shield_name': 'Bouclier Matériaux 3',
      'upgrade_materials_t3_shield_desc': '-25% de pertes en Matériaux',
      'upgrade_materials_t3_income_name': 'Revenu Matériaux 3',
      'upgrade_materials_t3_income_desc': '+60\$/jour en Matériaux',
      'upgrade_materials_cap_name': 'Magnat Matériaux',
      'upgrade_materials_cap_desc': 'Spécialisation ultime en Matériaux',

      // ── Services Publics ──
      'upgrade_utilities_t1_name': 'Initié Services',
      'upgrade_utilities_t1_desc': 'Entrer dans le secteur Services & débloquer le Tier 1',
      'upgrade_utilities_t2_name': 'Expert Services',
      'upgrade_utilities_t2_desc': 'Débloquer le Tier 2 pour Services',
      'upgrade_utilities_t3_name': 'Maître Services',
      'upgrade_utilities_t3_desc': 'Débloquer le Tier 3 pour Services',
      'upgrade_utilities_t1_profit_name': 'Boost Services 1',
      'upgrade_utilities_t1_profit_desc': '+15% de profits en Services',
      'upgrade_utilities_t1_shield_name': 'Bouclier Services 1',
      'upgrade_utilities_t1_shield_desc': '-15% de pertes en Services',
      'upgrade_utilities_t1_income_name': 'Revenu Services 1',
      'upgrade_utilities_t1_income_desc': '+20\$/jour en Services',
      'upgrade_utilities_t2_profit_name': 'Boost Services 2',
      'upgrade_utilities_t2_profit_desc': '+20% de profits en Services',
      'upgrade_utilities_t2_shield_name': 'Bouclier Services 2',
      'upgrade_utilities_t2_shield_desc': '-20% de pertes en Services',
      'upgrade_utilities_t2_income_name': 'Revenu Services 2',
      'upgrade_utilities_t2_income_desc': '+40\$/jour en Services',
      'upgrade_utilities_t3_profit_name': 'Boost Services 3',
      'upgrade_utilities_t3_profit_desc': '+25% de profits en Services',
      'upgrade_utilities_t3_shield_name': 'Bouclier Services 3',
      'upgrade_utilities_t3_shield_desc': '-25% de pertes en Services',
      'upgrade_utilities_t3_income_name': 'Revenu Services 3',
      'upgrade_utilities_t3_income_desc': '+60\$/jour en Services',
      'upgrade_utilities_cap_name': 'Magnat Services',
      'upgrade_utilities_cap_desc': 'Spécialisation ultime en Services',

      // ── Jeux Vidéo ──
      'upgrade_gaming_t1_name': 'Initié Gaming',
      'upgrade_gaming_t1_desc': 'Entrer dans le secteur Gaming & débloquer le Tier 1',
      'upgrade_gaming_t2_name': 'Expert Gaming',
      'upgrade_gaming_t2_desc': 'Débloquer le Tier 2 pour Gaming',
      'upgrade_gaming_t3_name': 'Maître Gaming',
      'upgrade_gaming_t3_desc': 'Débloquer le Tier 3 pour Gaming',
      'upgrade_gaming_t1_profit_name': 'Boost Gaming 1',
      'upgrade_gaming_t1_profit_desc': '+15% de profits en Gaming',
      'upgrade_gaming_t1_shield_name': 'Bouclier Gaming 1',
      'upgrade_gaming_t1_shield_desc': '-15% de pertes en Gaming',
      'upgrade_gaming_t1_income_name': 'Revenu Gaming 1',
      'upgrade_gaming_t1_income_desc': '+20\$/jour en Gaming',
      'upgrade_gaming_t2_profit_name': 'Boost Gaming 2',
      'upgrade_gaming_t2_profit_desc': '+20% de profits en Gaming',
      'upgrade_gaming_t2_shield_name': 'Bouclier Gaming 2',
      'upgrade_gaming_t2_shield_desc': '-20% de pertes en Gaming',
      'upgrade_gaming_t2_income_name': 'Revenu Gaming 2',
      'upgrade_gaming_t2_income_desc': '+40\$/jour en Gaming',
      'upgrade_gaming_t3_profit_name': 'Boost Gaming 3',
      'upgrade_gaming_t3_profit_desc': '+25% de profits en Gaming',
      'upgrade_gaming_t3_shield_name': 'Bouclier Gaming 3',
      'upgrade_gaming_t3_shield_desc': '-25% de pertes en Gaming',
      'upgrade_gaming_t3_income_name': 'Revenu Gaming 3',
      'upgrade_gaming_t3_income_desc': '+60\$/jour en Gaming',
      'upgrade_gaming_cap_name': 'Magnat Gaming',
      'upgrade_gaming_cap_desc': 'Spécialisation ultime en Gaming',

      // ── Crypto ──
      'upgrade_crypto_t1_name': 'Initié Crypto',
      'upgrade_crypto_t1_desc': 'Entrer dans le secteur Crypto & débloquer le Tier 1',
      'upgrade_crypto_t2_name': 'Expert Crypto',
      'upgrade_crypto_t2_desc': 'Débloquer le Tier 2 pour Crypto',
      'upgrade_crypto_t3_name': 'Maître Crypto',
      'upgrade_crypto_t3_desc': 'Débloquer le Tier 3 pour Crypto',
      'upgrade_crypto_t1_profit_name': 'Boost Crypto 1',
      'upgrade_crypto_t1_profit_desc': '+15% de profits en Crypto',
      'upgrade_crypto_t1_shield_name': 'Bouclier Crypto 1',
      'upgrade_crypto_t1_shield_desc': '-15% de pertes en Crypto',
      'upgrade_crypto_t1_income_name': 'Revenu Crypto 1',
      'upgrade_crypto_t1_income_desc': '+20\$/jour en Crypto',
      'upgrade_crypto_t2_profit_name': 'Boost Crypto 2',
      'upgrade_crypto_t2_profit_desc': '+20% de profits en Crypto',
      'upgrade_crypto_t2_shield_name': 'Bouclier Crypto 2',
      'upgrade_crypto_t2_shield_desc': '-20% de pertes en Crypto',
      'upgrade_crypto_t2_income_name': 'Revenu Crypto 2',
      'upgrade_crypto_t2_income_desc': '+40\$/jour en Crypto',
      'upgrade_crypto_t3_profit_name': 'Boost Crypto 3',
      'upgrade_crypto_t3_profit_desc': '+25% de profits en Crypto',
      'upgrade_crypto_t3_shield_name': 'Bouclier Crypto 3',
      'upgrade_crypto_t3_shield_desc': '-25% de pertes en Crypto',
      'upgrade_crypto_t3_income_name': 'Revenu Crypto 3',
      'upgrade_crypto_t3_income_desc': '+60\$/jour en Crypto',
      'upgrade_crypto_cap_name': 'Magnat Crypto',
      'upgrade_crypto_cap_desc': 'Spécialisation ultime en Crypto',

      // ── Aérospatiale ──
      'upgrade_aerospace_t1_name': 'Initié Aéro',
      'upgrade_aerospace_t1_desc': 'Entrer dans le secteur Aéro & débloquer le Tier 1',
      'upgrade_aerospace_t2_name': 'Expert Aéro',
      'upgrade_aerospace_t2_desc': 'Débloquer le Tier 2 pour Aéro',
      'upgrade_aerospace_t3_name': 'Maître Aéro',
      'upgrade_aerospace_t3_desc': 'Débloquer le Tier 3 pour Aéro',
      'upgrade_aerospace_t1_profit_name': 'Boost Aéro 1',
      'upgrade_aerospace_t1_profit_desc': '+15% de profits en Aéro',
      'upgrade_aerospace_t1_shield_name': 'Bouclier Aéro 1',
      'upgrade_aerospace_t1_shield_desc': '-15% de pertes en Aéro',
      'upgrade_aerospace_t1_income_name': 'Revenu Aéro 1',
      'upgrade_aerospace_t1_income_desc': '+20\$/jour en Aéro',
      'upgrade_aerospace_t2_profit_name': 'Boost Aéro 2',
      'upgrade_aerospace_t2_profit_desc': '+20% de profits en Aéro',
      'upgrade_aerospace_t2_shield_name': 'Bouclier Aéro 2',
      'upgrade_aerospace_t2_shield_desc': '-20% de pertes en Aéro',
      'upgrade_aerospace_t2_income_name': 'Revenu Aéro 2',
      'upgrade_aerospace_t2_income_desc': '+40\$/jour en Aéro',
      'upgrade_aerospace_t3_profit_name': 'Boost Aéro 3',
      'upgrade_aerospace_t3_profit_desc': '+25% de profits en Aéro',
      'upgrade_aerospace_t3_shield_name': 'Bouclier Aéro 3',
      'upgrade_aerospace_t3_shield_desc': '-25% de pertes en Aéro',
      'upgrade_aerospace_t3_income_name': 'Revenu Aéro 3',
      'upgrade_aerospace_t3_income_desc': '+60\$/jour en Aéro',
      'upgrade_aerospace_cap_name': 'Magnat Aéro',
      'upgrade_aerospace_cap_desc': 'Spécialisation ultime en Aéro',

      // ── Matières Premières ──
      'upgrade_commodities_t1_name': 'Initié Matières',
      'upgrade_commodities_t1_desc': 'Entrer dans le secteur Matières & débloquer le Tier 1',
      'upgrade_commodities_t2_name': 'Expert Matières',
      'upgrade_commodities_t2_desc': 'Débloquer le Tier 2 pour Matières',
      'upgrade_commodities_t3_name': 'Maître Matières',
      'upgrade_commodities_t3_desc': 'Débloquer le Tier 3 pour Matières',
      'upgrade_commodities_t1_profit_name': 'Boost Matières 1',
      'upgrade_commodities_t1_profit_desc': '+15% de profits en Matières',
      'upgrade_commodities_t1_shield_name': 'Bouclier Matières 1',
      'upgrade_commodities_t1_shield_desc': '-15% de pertes en Matières',
      'upgrade_commodities_t1_income_name': 'Revenu Matières 1',
      'upgrade_commodities_t1_income_desc': '+20\$/jour en Matières',
      'upgrade_commodities_t2_profit_name': 'Boost Matières 2',
      'upgrade_commodities_t2_profit_desc': '+20% de profits en Matières',
      'upgrade_commodities_t2_shield_name': 'Bouclier Matières 2',
      'upgrade_commodities_t2_shield_desc': '-20% de pertes en Matières',
      'upgrade_commodities_t2_income_name': 'Revenu Matières 2',
      'upgrade_commodities_t2_income_desc': '+40\$/jour en Matières',
      'upgrade_commodities_t3_profit_name': 'Boost Matières 3',
      'upgrade_commodities_t3_profit_desc': '+25% de profits en Matières',
      'upgrade_commodities_t3_shield_name': 'Bouclier Matières 3',
      'upgrade_commodities_t3_shield_desc': '-25% de pertes en Matières',
      'upgrade_commodities_t3_income_name': 'Revenu Matières 3',
      'upgrade_commodities_t3_income_desc': '+60\$/jour en Matières',
      'upgrade_commodities_cap_name': 'Magnat Matières',
      'upgrade_commodities_cap_desc': 'Spécialisation ultime en Matières',

      // ── Forex ──
      'upgrade_forex_t1_name': 'Initié Forex',
      'upgrade_forex_t1_desc': 'Entrer dans le secteur Forex & débloquer le Tier 1',
      'upgrade_forex_t2_name': 'Expert Forex',
      'upgrade_forex_t2_desc': 'Débloquer le Tier 2 pour Forex',
      'upgrade_forex_t3_name': 'Maître Forex',
      'upgrade_forex_t3_desc': 'Débloquer le Tier 3 pour Forex',
      'upgrade_forex_t1_profit_name': 'Boost Forex 1',
      'upgrade_forex_t1_profit_desc': '+15% de profits en Forex',
      'upgrade_forex_t1_shield_name': 'Bouclier Forex 1',
      'upgrade_forex_t1_shield_desc': '-15% de pertes en Forex',
      'upgrade_forex_t1_income_name': 'Revenu Forex 1',
      'upgrade_forex_t1_income_desc': '+20\$/jour en Forex',
      'upgrade_forex_t2_profit_name': 'Boost Forex 2',
      'upgrade_forex_t2_profit_desc': '+20% de profits en Forex',
      'upgrade_forex_t2_shield_name': 'Bouclier Forex 2',
      'upgrade_forex_t2_shield_desc': '-20% de pertes en Forex',
      'upgrade_forex_t2_income_name': 'Revenu Forex 2',
      'upgrade_forex_t2_income_desc': '+40\$/jour en Forex',
      'upgrade_forex_t3_profit_name': 'Boost Forex 3',
      'upgrade_forex_t3_profit_desc': '+25% de profits en Forex',
      'upgrade_forex_t3_shield_name': 'Bouclier Forex 3',
      'upgrade_forex_t3_shield_desc': '-25% de pertes en Forex',
      'upgrade_forex_t3_income_name': 'Revenu Forex 3',
      'upgrade_forex_t3_income_desc': '+60\$/jour en Forex',
      'upgrade_forex_cap_name': 'Magnat Forex',
      'upgrade_forex_cap_desc': 'Spécialisation ultime en Forex',

      // ── Indices ──
      'upgrade_indices_t1_name': 'Initié Indices',
      'upgrade_indices_t1_desc': 'Entrer dans le secteur Indices & débloquer le Tier 1',
      'upgrade_indices_t2_name': 'Expert Indices',
      'upgrade_indices_t2_desc': 'Débloquer le Tier 2 pour Indices',
      'upgrade_indices_t3_name': 'Maître Indices',
      'upgrade_indices_t3_desc': 'Débloquer le Tier 3 pour Indices',
      'upgrade_indices_t1_profit_name': 'Boost Indices 1',
      'upgrade_indices_t1_profit_desc': '+15% de profits en Indices',
      'upgrade_indices_t1_shield_name': 'Bouclier Indices 1',
      'upgrade_indices_t1_shield_desc': '-15% de pertes en Indices',
      'upgrade_indices_t1_income_name': 'Revenu Indices 1',
      'upgrade_indices_t1_income_desc': '+20\$/jour en Indices',
      'upgrade_indices_t2_profit_name': 'Boost Indices 2',
      'upgrade_indices_t2_profit_desc': '+20% de profits en Indices',
      'upgrade_indices_t2_shield_name': 'Bouclier Indices 2',
      'upgrade_indices_t2_shield_desc': '-20% de pertes en Indices',
      'upgrade_indices_t2_income_name': 'Revenu Indices 2',
      'upgrade_indices_t2_income_desc': '+40\$/jour en Indices',
      'upgrade_indices_t3_profit_name': 'Boost Indices 3',
      'upgrade_indices_t3_profit_desc': '+25% de profits en Indices',
      'upgrade_indices_t3_shield_name': 'Bouclier Indices 3',
      'upgrade_indices_t3_shield_desc': '-25% de pertes en Indices',
      'upgrade_indices_t3_income_name': 'Revenu Indices 3',
      'upgrade_indices_t3_income_desc': '+60\$/jour en Indices',
      'upgrade_indices_cap_name': 'Magnat Indices',
      'upgrade_indices_cap_desc': 'Spécialisation ultime en Indices',

      // ── Branche Automation: emplacements robots ──
      'upgrade_auto_slot_1_name': 'Robot Alpha',
      'upgrade_auto_slot_1_desc': 'Débloque l\'emplacement robot 1',
      'upgrade_auto_slot_2_name': 'Robot Beta',
      'upgrade_auto_slot_2_desc': 'Débloque l\'emplacement robot 2',
      'upgrade_auto_slot_3_name': 'Robot Gamma',
      'upgrade_auto_slot_3_desc': 'Débloque l\'emplacement robot 3',
      'upgrade_auto_slot_4_name': 'Robot Delta',
      'upgrade_auto_slot_4_desc': 'Débloque l\'emplacement robot 4',
      'upgrade_auto_slot_5_name': 'Robot Epsilon',
      'upgrade_auto_slot_5_desc': 'Débloque l\'emplacement robot 5',
      'upgrade_auto_slot_6_name': 'Robot Zeta',
      'upgrade_auto_slot_6_desc': 'Débloque l\'emplacement robot 6',
      'upgrade_auto_slot_7_name': 'Robot Eta',
      'upgrade_auto_slot_7_desc': 'Débloque l\'emplacement robot 7',
      'upgrade_auto_slot_8_name': 'Robot Theta',
      'upgrade_auto_slot_8_desc': 'Débloque l\'emplacement robot 8',
      'upgrade_auto_slot_9_name': 'Robot Iota',
      'upgrade_auto_slot_9_desc': 'Débloque l\'emplacement robot 9',
      'upgrade_auto_slot_10_name': 'Robot Kappa',
      'upgrade_auto_slot_10_desc': 'Débloque l\'emplacement robot 10',
      // ── Branches globales d'automatisation ──
      'upgrade_auto_disc1_name': 'Réduction Groupe I',
      'upgrade_auto_disc1_desc': 'Négocier de meilleurs tarifs pour tous les robots',
      'upgrade_auto_disc2_name': 'Réduction Groupe II',
      'upgrade_auto_disc2_desc': 'Remises volume sur les upgrades robot',
      'upgrade_auto_disc3_name': 'Réduction Groupe III',
      'upgrade_auto_disc3_desc': 'Efficacité maximale des coûts',
      'upgrade_auto_lvl1_name': 'Entraînement I',
      'upgrade_auto_lvl1_desc': 'Tous les robots démarrent pré-entraînés',
      'upgrade_auto_lvl2_name': 'Entraînement II',
      'upgrade_auto_lvl2_desc': 'Programme d\'entraînement avancé',
      'upgrade_auto_lvl3_name': 'Entraînement III',
      'upgrade_auto_lvl3_desc': 'Formation d\'élite des robots',
      'upgrade_auto_collect_name': 'Auto-Collecte',
      'upgrade_auto_collect_desc': 'Collecte automatique de tous les portefeuilles robots',
      'upgrade_auto_seed1_name': 'Fonds Initial I',
      'upgrade_auto_seed1_desc': 'Donner une avance aux robots',
      'upgrade_auto_seed2_name': 'Fonds Initial II',
      'upgrade_auto_seed2_desc': 'Budgets robots plus élevés',
      'upgrade_auto_seed3_name': 'Fonds Initial III',
      'upgrade_auto_seed3_desc': 'Capital robot sérieux',
      'upgrade_auto_wr1_name': 'Calibration I',
      'upgrade_auto_wr1_desc': 'Meilleurs algorithmes pour tous les robots',
      'upgrade_auto_wr2_name': 'Calibration II',
      'upgrade_auto_wr2_desc': 'Moteurs de décision affinés',
      'upgrade_auto_wr3_name': 'Calibration III',
      'upgrade_auto_wr3_desc': 'IA de trading dernier cri',
      'upgrade_auto_speed1_name': 'Overclock I',
      'upgrade_auto_speed1_desc': 'Les robots tradent plus vite',
      'upgrade_auto_speed2_name': 'Overclock II',
      'upgrade_auto_speed2_desc': 'Débit maximum des robots',

      // ═══ Branche Intelligence ═══
      // Colonne vertébrale
      'upgrade_in_reroll1_name': 'Reroll Gratuit I',
      'upgrade_in_reroll1_desc': 'De meilleures options sans frais',
      'upgrade_in_luck1_name': 'Porte-Bonheur',
      'upgrade_in_luck1_desc': 'La fortune sourit à votre boutique',
      'upgrade_in_reroll2_name': 'Reroll Gratuit II',
      'upgrade_in_reroll2_desc': 'Encore plus de rerolls gratuits',
      'upgrade_in_choice_name': 'Apprentissage Rapide',
      'upgrade_in_choice_desc': 'Plus de choix d\'améliorations chaque jour',
      'upgrade_in_luck2_name': 'Fortune Favorisée',
      'upgrade_in_luck2_desc': 'Les améliorations rares apparaissent plus souvent',
      'upgrade_in_reroll3_name': 'Reroll Gratuit III',
      'upgrade_in_reroll3_desc': 'Maximum de rerolls gratuits',
      'upgrade_in_luck3_name': 'Main Dorée',
      'upgrade_in_luck3_desc': 'Chance d\'amélioration rare grandement augmentée',
      'upgrade_in_cap_name': 'Vétéran du Marché',
      'upgrade_in_cap_desc': 'Amélioration gratuite au début + rare garantie',
      // Informateur Secret
      'upgrade_in_tip_free1_name': 'Intel Gratuit I',
      'upgrade_in_tip_free1_desc': 'Un tip offert chaque jour',
      'upgrade_in_tip_free2_name': 'Intel Gratuit II',
      'upgrade_in_tip_free2_desc': 'Un autre tip quotidien gratuit',
      'upgrade_in_tip_disc1_name': 'Réduction I',
      'upgrade_in_tip_disc1_desc': 'Intel moins cher de vos sources',
      'upgrade_in_tip_disc2_name': 'Réduction II',
      'upgrade_in_tip_disc2_desc': 'Grosses réductions sur tous les tips',
      'upgrade_in_tip_exact_name': 'Intel Exact',
      'upgrade_in_tip_exact_desc': 'Les tips révèlent le pourcentage précis',
      // FintTok
      'upgrade_in_ftk_acc1_name': 'Meilleures Sources I',
      'upgrade_in_ftk_acc1_desc': 'Les influenceurs sont légèrement plus fiables',
      'upgrade_in_ftk_acc2_name': 'Meilleures Sources II',
      'upgrade_in_ftk_acc2_desc': 'Contenu encore plus digne de confiance',
      'upgrade_in_ftk_slot1_name': 'Influenceur Extra I',
      'upgrade_in_ftk_slot1_desc': 'Une voix de plus dans votre feed',
      'upgrade_in_ftk_slot2_name': 'Influenceur Extra II',
      'upgrade_in_ftk_slot2_desc': 'Un feed FintTok encore plus grand',
      'upgrade_in_ftk_flag_name': 'Signaler les Mauvais Tips',
      'upgrade_in_ftk_flag_desc': 'Les tips peu fiables sont signalés',
      // News & Events
      'upgrade_in_news1_name': 'News Extra I',
      'upgrade_in_news1_desc': 'Plus de news quotidiennes',
      'upgrade_in_news2_name': 'News Extra II',
      'upgrade_in_news2_desc': 'Couverture médiatique étendue',
      'upgrade_in_block1_name': 'Bloquer Événement',
      'upgrade_in_block1_desc': 'Annuler un événement négatif par run',
      'upgrade_in_disinfo_name': 'Bouclier Désinfo',
      'upgrade_in_disinfo_desc': 'Immunité aux fausses news et manipulations',
      // Informateur Avancé
      'upgrade_in_tip_prec1_name': 'Précision I',
      'upgrade_in_tip_prec1_desc': 'Intel plus précis de vos sources',
      'upgrade_in_tip_prec2_name': 'Précision II',
      'upgrade_in_tip_prec2_desc': 'Intelligence de marché quasi parfaite',
      'upgrade_in_tip_free3_name': 'Intel Gratuit III',
      'upgrade_in_tip_free3_desc': 'Maximum d\'intel quotidien gratuit',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

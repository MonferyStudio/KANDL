import 'package:flutter/material.dart';

/// Global keys for tutorial targeting
/// These keys are used to highlight specific UI elements during the tutorial
class TutorialKeys {
  TutorialKeys._();

  // Top bar elements
  static final metricsBar = GlobalKey(debugLabel: 'tutorial_metricsBar');
  static final statsBar = GlobalKey(debugLabel: 'tutorial_statsBar');

  // View switcher buttons
  static final viewSwitcher = GlobalKey(debugLabel: 'tutorial_viewSwitcher');
  static final sectorsButton = GlobalKey(debugLabel: 'tutorial_sectorsButton');
  static final stocksButton = GlobalKey(debugLabel: 'tutorial_stocksButton');
  static final tradingButton = GlobalKey(debugLabel: 'tutorial_tradingButton');
  static final positionsButton = GlobalKey(debugLabel: 'tutorial_positionsButton');

  // Special features
  static final finTokButton = GlobalKey(debugLabel: 'tutorial_finTokButton');
  static final achievementsButton = GlobalKey(debugLabel: 'tutorial_achievementsButton');

  // Sectors view elements
  static final firstSectorCard = GlobalKey(debugLabel: 'tutorial_firstSectorCard');

  // Stocks view elements
  static final firstStockRow = GlobalKey(debugLabel: 'tutorial_firstStockRow');

  // Trading view elements
  static final buyButton = GlobalKey(debugLabel: 'tutorial_buyButton');
  static final sellButton = GlobalKey(debugLabel: 'tutorial_sellButton');
  static final chartArea = GlobalKey(debugLabel: 'tutorial_chartArea');

  // Info panel
  static final infoPanel = GlobalKey(debugLabel: 'tutorial_infoPanel');

  // Dashboard widgets
  static final positionStatistics = GlobalKey(debugLabel: 'tutorial_positionStatistics');
  static final tradingPerformance = GlobalKey(debugLabel: 'tutorial_tradingPerformance');
  static final riskMetrics = GlobalKey(debugLabel: 'tutorial_riskMetrics');
  static final milestoneProgress = GlobalKey(debugLabel: 'tutorial_milestoneProgress');
  static final challengesPanel = GlobalKey(debugLabel: 'tutorial_challengesPanel');
  static final recentTrades = GlobalKey(debugLabel: 'tutorial_recentTrades');
  static final positionNews = GlobalKey(debugLabel: 'tutorial_positionNews');
}

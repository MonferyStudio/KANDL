/// All shared enums for KANDL
library;

enum SectorType {
  technology,
  healthcare,
  finance,
  energy,
  consumerGoods,
  industrial,
  realEstate,
  telecommunications,
  materials,      // Steel, copper, lithium, rare earth
  utilities,      // Water, electricity, gas
  gaming,         // Video games and esports
  crypto,         // Cryptocurrency and blockchain
  aerospace,      // Space and defense
  commodities,    // Gold, oil, silver, natural gas
  forex,          // Currency pairs
  indices,        // Market indices
}

enum RegionType {
  us,
  eu,
  asia,
}

enum EventType {
  earnings,
  fedDecision,
  productLaunch,
  scandal,
  merger,
  regulation,
  marketCrash,
  bullRun,
  supplyShock,
  innovation,
  bankruptcy,
  dividendAnnouncement,
}

enum EventImpact {
  veryPositive,
  positive,
  neutral,
  negative,
  veryNegative,
  volatile,
}

enum BotType {
  dca,
  gridTrader,
  momentumTrader,
  dipBuyer,
  scalper,
  holder,
}

enum UpgradeCategory {
  trading,      // Fees, margin, order types
  information,  // Market insights, predictions
  portfolio,    // More positions, diversification
  unlock,       // New companies, sectors
  risk,         // Stop-loss, protection
  income,       // Passive gains, dividends
  time,         // Longer days, slower market
  quota,        // Easier quotas
}

enum UpgradeRarity {
  common,       // 45% - Gray
  uncommon,     // 30% - Green
  rare,         // 15% - Blue
  epic,         // 8%  - Purple
  legendary,    // 2%  - Gold
}

enum CompanyTier {
  starter,      // Stable, low volatility, rare news - unlocked from start
  standard,     // Moderate volatility, normal news - unlock via upgrade
  premium,      // High volatility, frequent news - unlock via upgrade
  elite,        // Extreme volatility, constant news - prestige only
}

enum OrderType {
  marketBuy,
  marketSell,
  limitBuy,
  limitSell,
  marketShort,
  marketCover,
}

enum PositionType {
  long,
  short,
}

enum TimeFrame {
  thirtyMinutes, // 30 min in-game
  oneHour, // 1h in-game
  twoHours, // 2h in-game
  fourHours, // 4h in-game
}

enum ViewType {
  dashboard,
  market,      // Sectors + Stocks + News (sub-tabs)
  portfolio,   // Positions
  robots,      // Robot traders (unlocked via prestige)
  trading,     // Dedicated view (no tab), opened via selectCompany
}

// ─── Talent Tree (Prestige v2) ───

enum TalentBranch {
  root,
  trader,
  survival,
  automation,
  intelligence,
  sectors,
}

enum TalentNodeSize { lg, md, sm, xs, xxs }

/// Simple trading signals visible on stock cards
/// Designed to be intuitive for players who've never traded
enum StockSignal {
  onSale,      // Strong buy - RSI very low, big dip
  goodDeal,    // Buy signal - RSI low or near support
  rising,      // Upward momentum - trending up
  none,        // No clear signal
  falling,     // Downward momentum - trending down
  pricey,      // Sell signal - RSI high or near resistance
  overheated;  // Strong sell - RSI very high, overstretched

  /// Returns a random misleading signal (used by Signal Jammer effect).
  /// Uses [seed] for determinism (stable per stock per day, no flickering).
  /// If original signal is none, stays none.
  static StockSignal scrambled(int seed) {
    const signals = [
      StockSignal.onSale,
      StockSignal.goodDeal,
      StockSignal.rising,
      StockSignal.falling,
      StockSignal.pricey,
      StockSignal.overheated,
    ];
    return signals[seed.abs() % signals.length];
  }
}

import 'dart:math' as math;

import '../core/core.dart';
import 'company_data.dart';
import 'event_data.dart';
import 'chart_data.dart';

/// Runtime state of a stock (current price, history, etc.)
class StockState {
  final CompanyData company;

  BigNumber currentPrice;
  BigNumber previousClose;
  BigNumber dayOpen;
  BigNumber dayHigh;
  BigNumber dayLow;
  BigNumber volume;
  BigNumber averageVolume;

  List<PricePoint> priceHistory = [];
  static const int maxHistoryPoints = 500;

  // Daily price snapshots for longer-term performance tracking
  List<DailySnapshot> dailySnapshots = [];
  static const int maxDailySnapshots = 365; // Keep 1 year of daily data

  List<ActiveEvent> activeEvents = [];

  double currentVolatility;
  double trendDirection;

  // Pending news impact to be applied gradually over time
  // Stored as a percentage change (e.g., 0.05 = 5% pending increase)
  double pendingNewsImpact = 0.0;

  // === SUPPORT / RESISTANCE ===
  double supportLevel = 0.0; // Dynamic support price
  double resistanceLevel = 0.0; // Dynamic resistance price
  int ticksNearSupport = 0; // How long price has tested support
  int ticksNearResistance = 0; // How long price has tested resistance

  // === MOMENTUM ===
  List<double> recentChanges = []; // Last N price changes for momentum
  static const int momentumWindow = 15; // Track last 15 ticks
  double momentum = 0.0; // Running momentum score (-1 to 1)

  // Candle cache for chart rendering
  Map<TimeFrame, List<CandleData>> candleCache = {};

  StockState({required this.company})
      : currentPrice = company.initialPriceBN,
        previousClose = company.initialPriceBN,
        dayOpen = company.initialPriceBN,
        dayHigh = company.initialPriceBN,
        dayLow = company.initialPriceBN,
        volume = BigNumber.zero,
        averageVolume = BigNumber(1000000),
        currentVolatility = company.volatility,
        trendDirection = 0.0 {
    // Initialize S/R levels around initial price
    final price = company.initialPriceBN.toDouble();
    supportLevel = price * 0.98;
    resistanceLevel = price * 1.02;
    _generateInitialHistory();
  }

  /// Generate initial price history for charts
  /// Simulates realistic S/R patterns with consolidation and breakouts
  void _generateInitialHistory() {
    final now = DateTime.now();
    final random = math.Random();
    var price = currentPrice.toDouble();

    // 30m in-game candle = ~14 real seconds (smallest timeframe)
    // Generate ~50 candles worth of history for 30m view
    const candleSecondsReal = 14;
    const totalCandles = 50;

    // Simulated S/R for history generation
    double histSupport = price * 0.97;
    double histResistance = price * 1.03;
    double histMomentum = 0.0;

    for (int candleIndex = totalCandles; candleIndex > 0; candleIndex--) {
      final candleStartTime =
          now.subtract(Duration(seconds: candleIndex * candleSecondsReal));

      // Determine phase: consolidation (85%) vs breakout (15%)
      final isBreakout = random.nextDouble() < 0.12;

      // S/R proximity effects
      final distToSupport = (price - histSupport) / price;
      final distToResistance = (histResistance - price) / price;

      double candleDirection;
      double candleMagnitude;

      if (isBreakout) {
        // Breakout candle: strong directional move
        candleMagnitude = currentVolatility * 0.015 * (0.8 + random.nextDouble());
        candleDirection = random.nextBool() ? 1.0 : -1.0;

        // Update S/R after breakout
        if (candleDirection > 0) {
          histSupport = histResistance;
          histResistance = price * (1.02 + random.nextDouble() * 0.02);
        } else {
          histResistance = histSupport;
          histSupport = price * (0.96 + random.nextDouble() * 0.02);
        }
      } else {
        // Consolidation: range-bound between S/R
        candleMagnitude = currentVolatility * 0.006 * (0.3 + random.nextDouble());

        // Bias toward S/R bounce
        if (distToSupport < 0.01) {
          candleDirection = 0.3 + random.nextDouble() * 0.7; // Bounce up
        } else if (distToResistance < 0.01) {
          candleDirection = -(0.3 + random.nextDouble() * 0.7); // Reject down
        } else {
          candleDirection = (random.nextDouble() - 0.5) * 2.0 + histMomentum * 0.3;
        }
      }

      // Generate 3-5 ticks within each candle
      final tickCount = 3 + random.nextInt(3);
      final tickInterval = math.max(1, candleSecondsReal ~/ tickCount);

      for (int tick = 0; tick < tickCount; tick++) {
        final tickTime =
            candleStartTime.add(Duration(seconds: tick * tickInterval));

        double tickChange;
        if (tick < tickCount - 1) {
          // Intra-candle noise
          tickChange = (random.nextDouble() - 0.5) * candleMagnitude * 1.2;
        } else {
          // Final tick: close in intended direction
          tickChange = candleDirection * candleMagnitude;
        }

        price *= (1.0 + tickChange);
        if (price <= 0) price = currentPrice.toDouble() * 0.1;

        priceHistory.add(PricePoint(
          price: BigNumber(price),
          timestamp: tickTime,
          volume: averageVolume
              .multiplyByDouble((0.1 + random.nextDouble() * 0.3) / tickCount),
        ));
      }

      // Update simulated momentum
      histMomentum = histMomentum * 0.8 + candleDirection * 0.2;

      // Gradually tighten range (compression)
      histSupport += (price - histSupport) * 0.01;
      histResistance -= (histResistance - price) * 0.01;
    }

    // Sync currentPrice with the simulated history end price
    // This prevents a gap between the last history point and the actual game price
    currentPrice = BigNumber(price);
    previousClose = currentPrice;
    dayOpen = currentPrice;
    dayHigh = currentPrice;
    dayLow = currentPrice;

    // Update S/R levels to match the simulated price
    supportLevel = price * 0.98;
    resistanceLevel = price * 1.02;

    // Add current price as last point
    priceHistory.add(PricePoint(
      price: currentPrice,
      timestamp: now,
      volume: volume,
    ));
  }

  double get dayChangePercent =>
      previousClose.isZero ? 0 : previousClose.percentageChange(currentPrice);

  BigNumber get marketCap =>
      currentPrice.multiplyByDouble(company.sharesOutstanding);

  void updatePrice(BigNumber newPrice) {
    currentPrice = newPrice;

    if (newPrice > dayHigh) dayHigh = newPrice;
    if (newPrice < dayLow) dayLow = newPrice;

    priceHistory.add(PricePoint(
      price: newPrice,
      timestamp: DateTime.now(),
      volume: volume,
    ));

    while (priceHistory.length > maxHistoryPoints) {
      priceHistory.removeAt(0);
    }

    // Invalidate candle cache when price updates
    candleCache.clear();
  }

  void startNewDay({int? dayNumber}) {
    // Save snapshot of previous day
    if (dayNumber != null) {
      dailySnapshots.add(DailySnapshot(
        closePrice: currentPrice,
        volume: volume,
        date: DateTime.now(),
        dayNumber: dayNumber,
      ));

      // Keep only last year of snapshots
      if (dailySnapshots.length > maxDailySnapshots) {
        dailySnapshots.removeAt(0);
      }
    }

    previousClose = currentPrice;
    dayOpen = currentPrice;
    dayHigh = currentPrice;
    dayLow = currentPrice;
    volume = BigNumber.zero;

    // Reset S/R to previous close as starting reference
    final price = currentPrice.toDouble();
    supportLevel = price * 0.98; // 2% below open
    resistanceLevel = price * 1.02; // 2% above open
    ticksNearSupport = 0;
    ticksNearResistance = 0;
    recentChanges.clear();
    momentum = 0.0;
  }

  /// Reset stock to initial price (for new year/prestige)
  void resetToInitialPrice() {
    currentPrice = company.initialPriceBN;
    previousClose = company.initialPriceBN;
    dayOpen = company.initialPriceBN;
    dayHigh = company.initialPriceBN;
    dayLow = company.initialPriceBN;
    volume = BigNumber.zero;
    priceHistory.clear();
    dailySnapshots.clear();
    candleCache.clear();
    currentVolatility = company.volatility;
    trendDirection = 0.0;
    pendingNewsImpact = 0.0;
    final price = company.initialPriceBN.toDouble();
    supportLevel = price * 0.98;
    resistanceLevel = price * 1.02;
    ticksNearSupport = 0;
    ticksNearResistance = 0;
    recentChanges.clear();
    momentum = 0.0;
    _generateInitialHistory();
  }

  void addVolume(BigNumber amount) {
    volume = volume + amount;
  }

  /// Add pending news impact that will be applied gradually
  void addPendingImpact(double impactPercent) {
    pendingNewsImpact += impactPercent;
  }

  /// Apply a portion of pending news impact
  /// Returns the portion that was applied (as percentage)
  double applyPendingImpact({double applicationRate = 0.15}) {
    if (pendingNewsImpact.abs() < 0.0001) {
      pendingNewsImpact = 0.0;
      return 0.0;
    }

    // Apply a portion of the pending impact
    final impactToApply = pendingNewsImpact * applicationRate;

    // Reduce the pending impact
    pendingNewsImpact -= impactToApply;

    // If the remaining is negligible, apply it all
    if (pendingNewsImpact.abs() < 0.001) {
      final remaining = pendingNewsImpact;
      pendingNewsImpact = 0.0;
      return impactToApply + remaining;
    }

    return impactToApply;
  }

  /// Check if there's significant pending impact
  bool get hasPendingImpact => pendingNewsImpact.abs() > 0.0001;

  /// Record a price change tick for momentum tracking
  void recordPriceChange(double changePercent) {
    recentChanges.add(changePercent);
    if (recentChanges.length > momentumWindow) {
      recentChanges.removeAt(0);
    }
    // Update momentum: weighted average of recent changes (more recent = more weight)
    if (recentChanges.isNotEmpty) {
      double weightedSum = 0;
      double totalWeight = 0;
      for (int i = 0; i < recentChanges.length; i++) {
        final weight = (i + 1).toDouble(); // Linear weight
        weightedSum += recentChanges[i].sign * weight;
        totalWeight += weight;
      }
      momentum = (weightedSum / totalWeight).clamp(-1.0, 1.0);
    }
  }

  /// Update support/resistance levels dynamically
  void updateSupportResistance() {
    final price = currentPrice.toDouble();
    final threshold = price * 0.003; // 0.3% proximity = "near" a level

    // Track time near S/R levels
    if ((price - supportLevel).abs() < threshold) {
      ticksNearSupport++;
    } else {
      ticksNearSupport = math.max(0, ticksNearSupport - 1);
    }

    if ((price - resistanceLevel).abs() < threshold) {
      ticksNearResistance++;
    } else {
      ticksNearResistance = math.max(0, ticksNearResistance - 1);
    }

    // If price breaks through resistance, resistance becomes new support
    if (price > resistanceLevel + threshold) {
      supportLevel = resistanceLevel;
      resistanceLevel = price * 1.015; // New resistance 1.5% above
      ticksNearResistance = 0;
      ticksNearSupport = 0;
    }

    // If price breaks through support, support becomes new resistance
    if (price < supportLevel - threshold) {
      resistanceLevel = supportLevel;
      supportLevel = price * 0.985; // New support 1.5% below
      ticksNearResistance = 0;
      ticksNearSupport = 0;
    }

    // Gradually tighten S/R toward price (range compression over time)
    final range = resistanceLevel - supportLevel;
    final minRange = price * 0.01; // Minimum 1% range
    if (range > minRange) {
      // Slowly compress the range (creates pressure for breakout)
      supportLevel += (price - supportLevel) * 0.002;
      resistanceLevel -= (resistanceLevel - price) * 0.002;
    }
  }

  // === TRADING SIGNALS ===

  /// Compute a simple, intuitive trading signal for the player
  StockSignal get currentSignal {
    final currentRsi = rsi;
    final price = currentPrice.toDouble();
    final threshold = price * 0.005; // 0.5% proximity to S/R

    // Priority 1: Extreme RSI → strongest signals
    if (currentRsi < 25) return StockSignal.onSale;
    if (currentRsi > 75) return StockSignal.overheated;

    // Priority 2: RSI + S/R combo
    final nearSupport = (price - supportLevel).abs() < threshold;
    final nearResistance = (resistanceLevel - price).abs() < threshold;

    if (currentRsi < 38 || nearSupport) return StockSignal.goodDeal;
    if (currentRsi > 62 || nearResistance) return StockSignal.pricey;

    // Priority 3: Strong momentum
    if (momentum > 0.4) return StockSignal.rising;
    if (momentum < -0.4) return StockSignal.falling;

    return StockSignal.none;
  }

  // === ANALYTICS CALCULATIONS ===

  /// Get 52-week high (or max available history)
  BigNumber get fiftyTwoWeekHigh {
    if (priceHistory.isEmpty) return currentPrice;
    return priceHistory
        .map((p) => p.price)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Get 52-week low (or min available history)
  BigNumber get fiftyTwoWeekLow {
    if (priceHistory.isEmpty) return currentPrice;
    return priceHistory
        .map((p) => p.price)
        .reduce((a, b) => a < b ? a : b);
  }

  /// Calculate RSI (Relative Strength Index) - 14 period
  double get rsi {
    if (priceHistory.length < 15) return 50.0; // Neutral if not enough data

    final period = 14;
    final recentPrices = priceHistory.sublist(priceHistory.length - period - 1);

    double gains = 0.0;
    double losses = 0.0;

    for (int i = 1; i < recentPrices.length; i++) {
      final change = recentPrices[i].price.toDouble() - recentPrices[i - 1].price.toDouble();
      if (change > 0) {
        gains += change;
      } else {
        losses += change.abs();
      }
    }

    final avgGain = gains / period;
    final avgLoss = losses / period;

    if (avgLoss == 0) return 100.0;

    final rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }

  /// Calculate Simple Moving Average
  BigNumber getMovingAverage(int periods) {
    if (priceHistory.length < periods) {
      return currentPrice;
    }

    final recentPrices = priceHistory.sublist(priceHistory.length - periods);
    final sum = recentPrices.fold<double>(
      0.0,
      (sum, point) => sum + point.price.toDouble(),
    );

    return BigNumber(sum / periods);
  }

  /// 50-period moving average
  BigNumber get ma50 => getMovingAverage(50);

  /// 200-period moving average
  BigNumber get ma200 => getMovingAverage(200);

  /// Volume ratio (current volume vs average)
  double get volumeRatio {
    if (averageVolume.isZero) return 1.0;
    return volume.toDouble() / averageVolume.toDouble();
  }

  /// Price change over last N periods
  double getPriceChangePercent(int periods) {
    if (priceHistory.length <= periods) return 0.0;

    final oldPrice = priceHistory[priceHistory.length - periods - 1].price;
    if (oldPrice.isZero) return 0.0;

    return ((currentPrice.toDouble() - oldPrice.toDouble()) / oldPrice.toDouble()) * 100;
  }

  /// Distance from 52-week high (as percentage)
  double get distanceFrom52WeekHigh {
    final high = fiftyTwoWeekHigh;
    if (high.isZero) return 0.0;
    return ((currentPrice.toDouble() - high.toDouble()) / high.toDouble()) * 100;
  }

  /// Distance from 52-week low (as percentage)
  double get distanceFrom52WeekLow {
    final low = fiftyTwoWeekLow;
    if (low.isZero) return 0.0;
    return ((currentPrice.toDouble() - low.toDouble()) / low.toDouble()) * 100;
  }

  // === HISTORICAL PERFORMANCE ===

  /// Get snapshot from N in-game days ago
  /// Returns null if not enough in-game days have elapsed
  DailySnapshot? getSnapshotDaysAgo(int daysAgo) {
    if (dailySnapshots.isEmpty) return null;
    if (daysAgo <= 0) return dailySnapshots.last;

    // Find snapshot that's closest to daysAgo
    final targetDay = dailySnapshots.last.dayNumber - daysAgo;

    // If we don't have data going back that far, return null
    if (targetDay < dailySnapshots.first.dayNumber) return null;

    // Search backwards for closest match
    for (int i = dailySnapshots.length - 1; i >= 0; i--) {
      if (dailySnapshots[i].dayNumber <= targetDay) {
        return dailySnapshots[i];
      }
    }

    return null;
  }

  /// Calculate performance over a period (in days)
  double? getPerformanceOverDays(int days) {
    final snapshot = getSnapshotDaysAgo(days);
    if (snapshot == null || snapshot.closePrice.isZero) return null;

    final oldPrice = snapshot.closePrice.toDouble();
    final newPrice = currentPrice.toDouble();

    return ((newPrice - oldPrice) / oldPrice) * 100;
  }

  /// 1-day performance
  double? get performance1D => getPerformanceOverDays(1);

  /// 1-week performance
  double? get performance1W => getPerformanceOverDays(7);

  /// 1-month performance
  double? get performance1M => getPerformanceOverDays(30);

  /// 3-month performance
  double? get performance3M => getPerformanceOverDays(90);

  /// Year-to-date performance (since start of current in-game year)
  /// In-game years are daysPerYear (30) days long
  double? getPerformanceYTD(int currentDay, int daysPerYear) {
    if (dailySnapshots.isEmpty) return null;

    // Find the first day of the current in-game year
    // Years: 1-30 = year 1, 31-60 = year 2, etc.
    final yearStartDay = ((currentDay - 1) ~/ daysPerYear) * daysPerYear + 1;

    // Find first snapshot at or after yearStartDay
    DailySnapshot? yearStart;
    for (final snapshot in dailySnapshots) {
      if (snapshot.dayNumber >= yearStartDay) {
        yearStart = snapshot;
        break;
      }
    }

    if (yearStart == null || yearStart.closePrice.isZero) return null;

    // If the year just started (only snapshot is today), no meaningful YTD
    if (yearStart.dayNumber == dailySnapshots.last.dayNumber) return null;

    final oldPrice = yearStart.closePrice.toDouble();
    final newPrice = currentPrice.toDouble();

    return ((newPrice - oldPrice) / oldPrice) * 100;
  }

  /// 1-year performance
  double? get performance1Y => getPerformanceOverDays(365);

  /// Get best performing period
  String getBestPerformingPeriod({int currentDay = 1, int daysPerYear = 30}) {
    final performances = {
      '1D': performance1D,
      '1W': performance1W,
      '1M': performance1M,
      '3M': performance3M,
      'YTD': getPerformanceYTD(currentDay, daysPerYear),
      '1Y': performance1Y,
    };

    String bestPeriod = '1D';
    double bestPerf = performance1D ?? 0.0;

    performances.forEach((period, perf) {
      if (perf != null && perf > bestPerf) {
        bestPerf = perf;
        bestPeriod = period;
      }
    });

    return bestPeriod;
  }

  /// Aggregates price history into candles for the specified timeframe
  List<CandleData> getCandles(TimeFrame timeframe) {
    // Check cache first
    if (candleCache.containsKey(timeframe) &&
        candleCache[timeframe]!.isNotEmpty) {
      return candleCache[timeframe]!;
    }

    final config = TimeframeConfig.configs[timeframe]!;
    final candles = <CandleData>[];

    if (priceHistory.isEmpty) return candles;

    // Group price points by time buckets
    final buckets = <DateTime, List<PricePoint>>{};

    for (final point in priceHistory) {
      final bucketTime = _getBucketTime(point.timestamp, config.secondsPerCandle);
      buckets.putIfAbsent(bucketTime, () => []).add(point);
    }

    // Convert buckets to candles
    final sortedTimes = buckets.keys.toList()..sort();
    BigNumber? previousClose;

    for (final time in sortedTimes) {
      final points = buckets[time]!;
      if (points.isEmpty) continue;

      // Open = previous candle's close (ensures continuity, no gaps)
      final open = previousClose ?? points.first.price;
      final close = points.last.price;
      var high = open;
      var low = open;
      var volumeSum = BigNumber.zero;

      // Include open in high/low calculation
      for (final point in points) {
        if (point.price > high) high = point.price;
        if (point.price < low) low = point.price;
        volumeSum = volumeSum + point.volume;
      }
      // Also check open against high/low
      if (open > high) high = open;
      if (open < low) low = open;

      candles.add(CandleData(
        timestamp: time,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volumeSum,
      ));

      previousClose = close;
    }

    // Cache the result
    candleCache[timeframe] = candles;

    // Limit to max candles
    if (candles.length > config.maxCandles) {
      final limited = candles.sublist(candles.length - config.maxCandles);
      candleCache[timeframe] = limited;
      return limited;
    }

    return candles;
  }

  DateTime _getBucketTime(DateTime timestamp, int secondsPerCandle) {
    final epochSeconds = timestamp.millisecondsSinceEpoch ~/ 1000;
    final bucketSeconds = (epochSeconds ~/ secondsPerCandle) * secondsPerCandle;
    return DateTime.fromMillisecondsSinceEpoch(bucketSeconds * 1000);
  }

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'companyId': company.id,
        'currentPrice': currentPrice.toJson(),
        'previousClose': previousClose.toJson(),
        'currentVolatility': currentVolatility,
        'trendDirection': trendDirection,
        'pendingNewsImpact': pendingNewsImpact,
      };

  // Load from JSON
  void loadFromJson(Map<String, dynamic> json) {
    if (json['currentPrice'] != null) {
      currentPrice = BigNumber.fromJson(json['currentPrice']);
    }
    if (json['previousClose'] != null) {
      previousClose = BigNumber.fromJson(json['previousClose']);
    }
    currentVolatility = (json['currentVolatility'] ?? company.volatility).toDouble();
    trendDirection = (json['trendDirection'] ?? 0.0).toDouble();
    pendingNewsImpact = (json['pendingNewsImpact'] ?? 0.0).toDouble();

    // Update day tracking to match loaded price
    dayOpen = currentPrice;
    dayHigh = currentPrice;
    dayLow = currentPrice;

    // Clear cache
    candleCache.clear();
  }
}

class PricePoint {
  final BigNumber price;
  final DateTime timestamp;
  final BigNumber volume;

  PricePoint({
    required this.price,
    required this.timestamp,
    required this.volume,
  });
}

class ActiveEvent {
  final EventData eventData;
  int remainingDays;
  final double actualImpact;
  final DateTime startTime;

  ActiveEvent({
    required this.eventData,
    required this.remainingDays,
    required this.actualImpact,
    required this.startTime,
  });

  String get timeRemainingText {
    if (remainingDays <= 0) return 'Ending';
    if (remainingDays == 1) return '1 day left';
    return '$remainingDays days left';
  }
}

class DailySnapshot {
  final BigNumber closePrice;
  final BigNumber volume;
  final DateTime date;
  final int dayNumber;

  DailySnapshot({
    required this.closePrice,
    required this.volume,
    required this.date,
    required this.dayNumber,
  });
}

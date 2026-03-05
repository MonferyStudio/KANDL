import '../core/enums.dart';

/// Type of influencer personality
enum InfluencerType {
  bullish,      // Always optimistic
  bearish,      // Always pessimistic
  sectorExpert, // Focuses on one sector
  memeTrader,   // Chaotic, unpredictable
  technicalGuru,// Claims to read charts
  insiderTipper,// Pretends to have inside info
}

/// Quality of an influencer's tips
enum TipQuality {
  excellent,  // 70%+ accuracy
  good,       // 50-70% accuracy
  average,    // 30-50% accuracy
  poor,       // 10-30% accuracy
  terrible,   // <10% accuracy
}

/// A single tip/post from an influencer
class InfluencerTip {
  final String id;
  final String influencerId;
  final String stockId;
  final String stockName;
  final bool isBullish; // Buy recommendation vs sell
  final bool isViral; // Viral tip = bigger price impact
  final String message;
  final int dayPosted;
  final double priceAtPost;
  bool? wasAccurate; // null until resolved
  double? priceAtResolution;

  InfluencerTip({
    required this.id,
    required this.influencerId,
    required this.stockId,
    required this.stockName,
    required this.isBullish,
    this.isViral = false,
    required this.message,
    required this.dayPosted,
    required this.priceAtPost,
    this.wasAccurate,
    this.priceAtResolution,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'influencerId': influencerId,
    'stockId': stockId,
    'stockName': stockName,
    'isBullish': isBullish,
    'isViral': isViral,
    'message': message,
    'dayPosted': dayPosted,
    'priceAtPost': priceAtPost,
    'wasAccurate': wasAccurate,
    'priceAtResolution': priceAtResolution,
  };

  factory InfluencerTip.fromJson(Map<String, dynamic> json) => InfluencerTip(
    id: json['id'],
    influencerId: json['influencerId'],
    stockId: json['stockId'],
    stockName: json['stockName'],
    isBullish: json['isBullish'],
    isViral: json['isViral'] ?? false,
    message: json['message'],
    dayPosted: json['dayPosted'],
    priceAtPost: (json['priceAtPost'] as num).toDouble(),
    wasAccurate: json['wasAccurate'],
    priceAtResolution: json['priceAtResolution'] != null
        ? (json['priceAtResolution'] as num).toDouble()
        : null,
  );
}

/// An influencer on FinTok
class Influencer {
  final String id;
  final String name;
  final String handle; // @handle
  final String avatar; // Emoji
  final String bio;
  final InfluencerType type;
  final SectorType? specialtySector; // For sector experts
  final double baseAccuracy; // 0.0-1.0, their actual prediction accuracy

  int followers;
  int totalTips;
  int accurateTips;
  int dayArrived;
  int? dayDeparted;
  String? farewellMessage;
  bool isActive;

  // Personality traits for message generation
  final List<String> bullishPhrases;
  final List<String> bearishPhrases;
  final List<String> catchphrases;

  Influencer({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatar,
    required this.bio,
    required this.type,
    this.specialtySector,
    required this.baseAccuracy,
    this.followers = 1000,
    this.totalTips = 0,
    this.accurateTips = 0,
    this.dayArrived = 0,
    this.dayDeparted,
    this.farewellMessage,
    this.isActive = true,
    this.bullishPhrases = const [],
    this.bearishPhrases = const [],
    this.catchphrases = const [],
  });

  /// Calculate displayed accuracy (can be misleading!)
  double get displayedAccuracy {
    if (totalTips == 0) return 0.5; // Unknown
    return accurateTips / totalTips;
  }

  /// Get tip quality based on accuracy
  TipQuality get tipQuality {
    final acc = displayedAccuracy;
    if (acc >= 0.7) return TipQuality.excellent;
    if (acc >= 0.5) return TipQuality.good;
    if (acc >= 0.3) return TipQuality.average;
    if (acc >= 0.1) return TipQuality.poor;
    return TipQuality.terrible;
  }

  /// Follower count formatted
  String get followerCount {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    }
    if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }

  /// Record a tip outcome
  void recordTipOutcome(bool wasAccurate) {
    totalTips++;
    if (wasAccurate) {
      accurateTips++;
      // Gain followers on accurate tips
      followers = (followers * 1.05).round();
    } else {
      // Lose followers on bad tips
      followers = (followers * 0.95).round();
      if (followers < 100) followers = 100;
    }
  }

  /// Check if influencer should depart
  bool shouldDepart(int currentDay) {
    if (!isActive) return false;

    // Been around for a while with poor performance
    final daysActive = currentDay - dayArrived;
    if (daysActive >= 30 && displayedAccuracy < 0.25) {
      return true; // Embarrassed departure
    }

    // Random departure chance after 60 days
    if (daysActive >= 60) {
      return true; // "Moving on to other opportunities"
    }

    return false;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'handle': handle,
    'avatar': avatar,
    'bio': bio,
    'type': type.index,
    'specialtySector': specialtySector?.index,
    'baseAccuracy': baseAccuracy,
    'followers': followers,
    'totalTips': totalTips,
    'accurateTips': accurateTips,
    'dayArrived': dayArrived,
    'dayDeparted': dayDeparted,
    'farewellMessage': farewellMessage,
    'isActive': isActive,
    'bullishPhrases': bullishPhrases,
    'bearishPhrases': bearishPhrases,
    'catchphrases': catchphrases,
  };

  factory Influencer.fromJson(Map<String, dynamic> json) => Influencer(
    id: json['id'],
    name: json['name'],
    handle: json['handle'],
    avatar: json['avatar'],
    bio: json['bio'],
    type: InfluencerType.values[json['type']],
    specialtySector: json['specialtySector'] != null
        ? SectorType.values[json['specialtySector']]
        : null,
    baseAccuracy: (json['baseAccuracy'] as num).toDouble(),
    followers: json['followers'] ?? 1000,
    totalTips: json['totalTips'] ?? 0,
    accurateTips: json['accurateTips'] ?? 0,
    dayArrived: json['dayArrived'] ?? 0,
    dayDeparted: json['dayDeparted'],
    farewellMessage: json['farewellMessage'],
    isActive: json['isActive'] ?? true,
    bullishPhrases: List<String>.from(json['bullishPhrases'] ?? []),
    bearishPhrases: List<String>.from(json['bearishPhrases'] ?? []),
    catchphrases: List<String>.from(json['catchphrases'] ?? []),
  );

  /// Create a copy with modifications
  Influencer copyWith({
    int? followers,
    int? totalTips,
    int? accurateTips,
    int? dayDeparted,
    String? farewellMessage,
    bool? isActive,
  }) {
    return Influencer(
      id: id,
      name: name,
      handle: handle,
      avatar: avatar,
      bio: bio,
      type: type,
      specialtySector: specialtySector,
      baseAccuracy: baseAccuracy,
      followers: followers ?? this.followers,
      totalTips: totalTips ?? this.totalTips,
      accurateTips: accurateTips ?? this.accurateTips,
      dayArrived: dayArrived,
      dayDeparted: dayDeparted ?? this.dayDeparted,
      farewellMessage: farewellMessage ?? this.farewellMessage,
      isActive: isActive ?? this.isActive,
      bullishPhrases: bullishPhrases,
      bearishPhrases: bearishPhrases,
      catchphrases: catchphrases,
    );
  }
}

/// Type of information the informant can sell
enum InformantTipType {
  stockDirection,    // Will stock go up or down?
  earningsPreview,   // Earnings will beat/miss
  insiderActivity,   // Insiders buying/selling
  mergerRumor,       // Potential acquisition
  sectorOutlook,     // Sector will perform well/badly
}

/// Quality/reliability of the informant's tip
enum InformantReliability {
  questionable,  // 50-60% accurate
  decent,        // 60-75% accurate
  reliable,      // 75-90% accurate
  impeccable,    // 90-99% accurate
}

/// A tip offered by the informant
class InformantTip {
  final String id;
  final InformantTipType type;
  final String stockId;
  final String stockName;
  final String? sectorId;
  final bool isBullish;
  final String message;
  final String secretMessage; // Revealed after purchase
  final double price; // Cost to buy this tip
  final InformantReliability reliability;
  final double actualAccuracy; // Hidden - true accuracy
  final int expiresDay; // Tip expires after this day
  bool purchased;
  bool revealed;
  bool? wasAccurate; // Set after resolution

  InformantTip({
    required this.id,
    required this.type,
    required this.stockId,
    required this.stockName,
    this.sectorId,
    required this.isBullish,
    required this.message,
    required this.secretMessage,
    required this.price,
    required this.reliability,
    required this.actualAccuracy,
    required this.expiresDay,
    this.purchased = false,
    this.revealed = false,
    this.wasAccurate,
  });

  bool get isExpired => false; // Checked against current day in GameService

  String get reliabilityLabel {
    switch (reliability) {
      case InformantReliability.questionable:
        return 'Questionable';
      case InformantReliability.decent:
        return 'Decent';
      case InformantReliability.reliable:
        return 'Reliable';
      case InformantReliability.impeccable:
        return 'Impeccable';
    }
  }

  String get typeLabel {
    switch (type) {
      case InformantTipType.stockDirection:
        return 'Price Prediction';
      case InformantTipType.earningsPreview:
        return 'Earnings Preview';
      case InformantTipType.insiderActivity:
        return 'Insider Activity';
      case InformantTipType.mergerRumor:
        return 'Merger Rumor';
      case InformantTipType.sectorOutlook:
        return 'Sector Outlook';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'stockId': stockId,
    'stockName': stockName,
    'sectorId': sectorId,
    'isBullish': isBullish,
    'message': message,
    'secretMessage': secretMessage,
    'price': price,
    'reliability': reliability.index,
    'actualAccuracy': actualAccuracy,
    'expiresDay': expiresDay,
    'purchased': purchased,
    'revealed': revealed,
    'wasAccurate': wasAccurate,
  };

  factory InformantTip.fromJson(Map<String, dynamic> json) => InformantTip(
    id: json['id'],
    type: InformantTipType.values[json['type']],
    stockId: json['stockId'],
    stockName: json['stockName'],
    sectorId: json['sectorId'],
    isBullish: json['isBullish'],
    message: json['message'],
    secretMessage: json['secretMessage'],
    price: (json['price'] as num).toDouble(),
    reliability: InformantReliability.values[json['reliability']],
    actualAccuracy: (json['actualAccuracy'] as num).toDouble(),
    expiresDay: json['expiresDay'],
    purchased: json['purchased'] ?? false,
    revealed: json['revealed'] ?? false,
    wasAccurate: json['wasAccurate'],
  );
}

/// State of the secret informant
class InformantState {
  bool isAvailable;
  int lastVisitDay;
  int visitsThisRun;
  List<InformantTip> currentTips;
  List<InformantTip> purchasedTips;

  InformantState({
    this.isAvailable = false,
    this.lastVisitDay = 0,
    this.visitsThisRun = 0,
    List<InformantTip>? currentTips,
    List<InformantTip>? purchasedTips,
  }) : currentTips = currentTips ?? [],
       purchasedTips = purchasedTips ?? [];

  Map<String, dynamic> toJson() => {
    'isAvailable': isAvailable,
    'lastVisitDay': lastVisitDay,
    'visitsThisRun': visitsThisRun,
    'currentTips': currentTips.map((t) => t.toJson()).toList(),
    'purchasedTips': purchasedTips.map((t) => t.toJson()).toList(),
  };

  factory InformantState.fromJson(Map<String, dynamic> json) => InformantState(
    isAvailable: json['isAvailable'] ?? false,
    lastVisitDay: json['lastVisitDay'] ?? 0,
    visitsThisRun: json['visitsThisRun'] ?? 0,
    currentTips: json['currentTips'] != null
        ? (json['currentTips'] as List)
            .map((t) => InformantTip.fromJson(t as Map<String, dynamic>))
            .toList()
        : [],
    purchasedTips: json['purchasedTips'] != null
        ? (json['purchasedTips'] as List)
            .map((t) => InformantTip.fromJson(t as Map<String, dynamic>))
            .toList()
        : [],
  );
}

import '../models/informant.dart';

/// Teaser messages for different tip types (shown before purchase)
const Map<InformantTipType, List<String>> teaserMessages = {
  InformantTipType.stockDirection: [
    'I know where {stock} is headed next week...',
    'Got insider info on {stock}\'s price movement...',
    'Trust me on {stock}, I\'ve seen the order flow...',
    '{stock} is about to make a big move, I guarantee it...',
  ],
  InformantTipType.earningsPreview: [
    'I\'ve seen {stock}\'s earnings numbers before release...',
    'Got a friend in {stock}\'s accounting department...',
    '{stock}\'s quarterly report will shock everyone...',
    'The street has it wrong on {stock}\'s earnings...',
  ],
  InformantTipType.insiderActivity: [
    'Executives at {stock} are making moves...',
    'Noticed some unusual insider trading at {stock}...',
    'The CEO of {stock} just did something interesting...',
    'Board members at {stock} know something we don\'t...',
  ],
  InformantTipType.mergerRumor: [
    'Heard whispers about {stock} and a potential deal...',
    '{stock} might not be independent much longer...',
    'Big players are circling {stock}...',
    'There\'s M&A activity brewing around {stock}...',
  ],
  InformantTipType.sectorOutlook: [
    'The {sector} sector is about to shift dramatically...',
    'Big institutional money is moving in {sector}...',
    'Policy changes will affect {sector} soon...',
    'I know what\'s coming for {sector} stocks...',
  ],
};

/// Secret messages revealed after purchase (bullish)
const Map<InformantTipType, List<String>> bullishSecrets = {
  InformantTipType.stockDirection: [
    '{stock} will surge 10-20% within days. Large buy orders incoming.',
    'Algorithms are set to pump {stock}. Get in before the wave.',
    'Short squeeze imminent on {stock}. Shorts are trapped.',
    'Smart money is accumulating {stock} quietly. Follow them.',
  ],
  InformantTipType.earningsPreview: [
    '{stock} will CRUSH earnings. Revenue up 30%+. Buy before announcement.',
    'Earnings beat guaranteed. {stock}\'s new product is a hit.',
    '{stock} sandbagged guidance. Real numbers are way better.',
    'Positive earnings surprise incoming. Analysts are way too low.',
  ],
  InformantTipType.insiderActivity: [
    'CEO just bought \$5M of {stock}. He knows something.',
    'Multiple insiders loading up on {stock}. Bullish signal.',
    'CFO exercised options and held. They believe in the company.',
    'Board member increased stake by 50%. Big news coming.',
  ],
  InformantTipType.mergerRumor: [
    '{stock} is acquisition target. Premium of 40%+ expected.',
    'Tech giant in talks to acquire {stock}. Deal imminent.',
    'Private equity circling {stock}. Buyout price will be generous.',
    'Merger announcement within weeks. {stock} shareholders will profit.',
  ],
  InformantTipType.sectorOutlook: [
    '{sector} about to boom. Government contracts incoming.',
    'Major fund rotating into {sector}. Momentum building.',
    'Regulatory tailwinds for {sector}. Buy the whole sector.',
    '{sector} is the next big trade. Get positioned now.',
  ],
};

/// Secret messages revealed after purchase (bearish)
const Map<InformantTipType, List<String>> bearishSecrets = {
  InformantTipType.stockDirection: [
    '{stock} about to crater 15-25%. Sell or short immediately.',
    'Large block sales scheduled for {stock}. Price will dump.',
    'Weak hands about to panic sell {stock}. Exit now.',
    'Algorithms will dump {stock}. Don\'t be left holding bags.',
  ],
  InformantTipType.earningsPreview: [
    '{stock} will miss badly. Revenue down 20%. Sell before report.',
    'Earnings disaster incoming. {stock}\'s main product is failing.',
    '{stock} cooked the books last quarter. Truth comes out soon.',
    'Analysts are way too optimistic on {stock}. Disappointment guaranteed.',
  ],
  InformantTipType.insiderActivity: [
    'CEO dumped \$10M of {stock}. He\'s heading for the exit.',
    'Mass insider selling at {stock}. Rats leaving sinking ship.',
    'CFO just sold everything. Company in trouble.',
    'Executives exercising and selling. They see problems ahead.',
  ],
  InformantTipType.mergerRumor: [
    '{stock} merger fell through. Stock will drop on news.',
    'Acquisition talks collapsed. No premium coming.',
    'Deal with {stock} is dead. Expect 20% drop.',
    'Regulatory blocked the merger. {stock} standalone is weak.',
  ],
  InformantTipType.sectorOutlook: [
    '{sector} facing major headwinds. Exit all positions.',
    'Institutions dumping {sector}. Rotation out accelerating.',
    'Regulatory crackdown on {sector} imminent. Sell everything.',
    '{sector} bubble about to pop. Get out while you can.',
  ],
};

/// Informant greeting messages
const List<String> informantGreetings = [
  'Psst... over here. I\'ve got something you might want to hear.',
  'You look like someone who appreciates good information.',
  'Keep this between us, but I know things...',
  'I don\'t normally do this, but you seem trustworthy.',
  'Got some hot tips. Interested?',
  'The market has secrets. I know some of them.',
  'Information is power. Want some?',
];

/// Informant farewell messages
const List<String> informantFarewells = [
  'I\'ll be back when I have more intel. Stay sharp.',
  'Remember, you didn\'t hear this from me.',
  'Good luck out there. Use the info wisely.',
  'I\'ve got other clients to see. Until next time.',
  'The market waits for no one. Neither do I.',
];

/// Informant messages when player can't afford
const List<String> cantAffordMessages = [
  'Come back when you\'ve got the cash.',
  'Information ain\'t free, friend.',
  'I don\'t do charity. Get some money first.',
  'Quality intel costs. Save up.',
];

/// Price ranges based on reliability
double getTipPrice(InformantReliability reliability, int currentDay) {
  final basePrice = switch (reliability) {
    InformantReliability.questionable => 25.0,
    InformantReliability.decent => 75.0,
    InformantReliability.reliable => 200.0,
    InformantReliability.impeccable => 500.0,
  };

  // Price scales with game progress
  final dayMultiplier = 1.0 + (currentDay / 30) * 0.5;
  return basePrice * dayMultiplier;
}

/// Accuracy ranges based on reliability
double getActualAccuracy(InformantReliability reliability) {
  return switch (reliability) {
    InformantReliability.questionable => 0.50 + (0.10 * _randomFactor()),
    InformantReliability.decent => 0.60 + (0.15 * _randomFactor()),
    InformantReliability.reliable => 0.75 + (0.15 * _randomFactor()),
    InformantReliability.impeccable => 0.90 + (0.09 * _randomFactor()),
  };
}

double _randomFactor() {
  // Simple pseudo-random for consistency (real random in GameService)
  return 0.5; // Will be replaced with actual random in GameService
}

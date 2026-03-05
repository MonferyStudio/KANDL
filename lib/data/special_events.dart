import 'package:flutter/material.dart';
import '../models/event_data.dart';
import '../core/enums.dart';

/// All special market events that can occur randomly
const List<EventData> allSpecialEvents = [
  // === MARKET-WIDE EVENTS ===

  // Positive market events
  EventData(
    id: 'fed_rate_cut',
    title: 'Fed Announces Rate Cut',
    description: 'The Federal Reserve has cut interest rates, boosting market confidence.',
    icon: '🏛️',
    type: EventType.fedDecision,
    impact: EventImpact.positive,
    priceImpactPercent: 5.0,
    impactVariance: 2.0,
    durationDays: 3,
    volatilityMultiplier: 1.3,
    baseChancePercent: 3.0,
    cooldownDays: 10,
    color: Colors.green,
  ),
  EventData(
    id: 'bull_run',
    title: 'Bull Market Rally',
    description: 'Investor optimism is at an all-time high. Markets are surging!',
    icon: '🐂',
    type: EventType.bullRun,
    impact: EventImpact.veryPositive,
    priceImpactPercent: 8.0,
    impactVariance: 3.0,
    durationDays: 5,
    volatilityMultiplier: 1.2,
    baseChancePercent: 2.0,
    cooldownDays: 15,
    color: Colors.green,
  ),
  EventData(
    id: 'economic_boom',
    title: 'Economic Boom',
    description: 'Strong GDP growth and low unemployment fuel market gains.',
    icon: '📈',
    type: EventType.bullRun,
    impact: EventImpact.positive,
    priceImpactPercent: 4.0,
    impactVariance: 2.0,
    durationDays: 4,
    volatilityMultiplier: 1.1,
    baseChancePercent: 3.0,
    cooldownDays: 12,
    color: Colors.green,
  ),

  // Negative market events
  EventData(
    id: 'fed_rate_hike',
    title: 'Fed Raises Interest Rates',
    description: 'The Federal Reserve has raised rates to combat inflation.',
    icon: '🏛️',
    type: EventType.fedDecision,
    impact: EventImpact.negative,
    priceImpactPercent: -4.0,
    impactVariance: 2.0,
    durationDays: 3,
    volatilityMultiplier: 1.4,
    baseChancePercent: 4.0,
    cooldownDays: 10,
    color: Colors.red,
  ),
  EventData(
    id: 'market_crash',
    title: 'Market Crash',
    description: 'Panic selling sweeps across all markets. Brace for impact!',
    icon: '💥',
    type: EventType.marketCrash,
    impact: EventImpact.veryNegative,
    priceImpactPercent: -12.0,
    impactVariance: 5.0,
    durationDays: 3,
    volatilityMultiplier: 2.5,
    baseChancePercent: 1.0,
    cooldownDays: 20,
    color: Colors.red,
  ),
  EventData(
    id: 'recession_fears',
    title: 'Recession Fears Mount',
    description: 'Economic indicators point to a potential recession.',
    icon: '📉',
    type: EventType.marketCrash,
    impact: EventImpact.negative,
    priceImpactPercent: -5.0,
    impactVariance: 2.0,
    durationDays: 4,
    volatilityMultiplier: 1.6,
    baseChancePercent: 3.0,
    cooldownDays: 14,
    color: Colors.orange,
  ),

  // Volatile events
  EventData(
    id: 'flash_crash',
    title: 'Flash Crash',
    description: 'Algorithmic trading causes rapid price swings.',
    icon: '⚡',
    type: EventType.marketCrash,
    impact: EventImpact.volatile,
    priceImpactPercent: 0.0,
    impactVariance: 8.0,
    durationDays: 1,
    volatilityMultiplier: 3.0,
    baseChancePercent: 2.0,
    cooldownDays: 7,
    color: Colors.purple,
  ),
  EventData(
    id: 'geopolitical_tension',
    title: 'Geopolitical Tensions',
    description: 'International conflicts create market uncertainty.',
    icon: '🌍',
    type: EventType.regulation,
    impact: EventImpact.volatile,
    priceImpactPercent: -2.0,
    impactVariance: 6.0,
    durationDays: 3,
    volatilityMultiplier: 2.0,
    baseChancePercent: 3.0,
    cooldownDays: 10,
    color: Colors.orange,
  ),

  // === SECTOR-SPECIFIC EVENTS ===

  // Tech sector
  EventData(
    id: 'tech_breakthrough',
    title: 'Major Tech Breakthrough',
    description: 'Revolutionary technology announced, tech stocks soar!',
    icon: '🚀',
    type: EventType.innovation,
    impact: EventImpact.veryPositive,
    affectedSectorIds: ['tech'],
    priceImpactPercent: 10.0,
    impactVariance: 3.0,
    durationDays: 4,
    volatilityMultiplier: 1.5,
    baseChancePercent: 2.0,
    cooldownDays: 12,
    color: Colors.blue,
  ),
  EventData(
    id: 'tech_regulation',
    title: 'Tech Antitrust Investigation',
    description: 'Government launches investigation into big tech.',
    icon: '⚖️',
    type: EventType.regulation,
    impact: EventImpact.negative,
    affectedSectorIds: ['tech'],
    priceImpactPercent: -6.0,
    impactVariance: 2.0,
    durationDays: 3,
    volatilityMultiplier: 1.4,
    baseChancePercent: 3.0,
    cooldownDays: 15,
    color: Colors.red,
  ),

  // Healthcare sector
  EventData(
    id: 'drug_approval',
    title: 'Major Drug Approval',
    description: 'FDA approves breakthrough treatment, healthcare rallies!',
    icon: '💊',
    type: EventType.productLaunch,
    impact: EventImpact.positive,
    affectedSectorIds: ['healthcare'],
    priceImpactPercent: 7.0,
    impactVariance: 3.0,
    durationDays: 3,
    volatilityMultiplier: 1.3,
    baseChancePercent: 3.0,
    cooldownDays: 10,
    color: Colors.green,
  ),
  EventData(
    id: 'healthcare_crisis',
    title: 'Healthcare Crisis',
    description: 'Public health emergency impacts healthcare stocks.',
    icon: '🏥',
    type: EventType.supplyShock,
    impact: EventImpact.volatile,
    affectedSectorIds: ['healthcare'],
    priceImpactPercent: 3.0,
    impactVariance: 8.0,
    durationDays: 5,
    volatilityMultiplier: 2.0,
    baseChancePercent: 2.0,
    cooldownDays: 14,
    color: Colors.orange,
  ),

  // Energy sector
  EventData(
    id: 'oil_price_surge',
    title: 'Oil Prices Surge',
    description: 'Supply constraints push oil prices to new highs.',
    icon: '🛢️',
    type: EventType.supplyShock,
    impact: EventImpact.positive,
    affectedSectorIds: ['energy'],
    priceImpactPercent: 8.0,
    impactVariance: 3.0,
    durationDays: 4,
    volatilityMultiplier: 1.5,
    baseChancePercent: 3.0,
    cooldownDays: 10,
    color: Colors.green,
  ),
  EventData(
    id: 'renewable_push',
    title: 'Green Energy Initiative',
    description: 'Government announces major renewable energy subsidies.',
    icon: '🌱',
    type: EventType.regulation,
    impact: EventImpact.volatile,
    affectedSectorIds: ['energy'],
    priceImpactPercent: 0.0,
    impactVariance: 6.0,
    durationDays: 3,
    volatilityMultiplier: 1.8,
    baseChancePercent: 3.0,
    cooldownDays: 12,
    color: Colors.teal,
  ),

  // Finance sector
  EventData(
    id: 'banking_crisis',
    title: 'Banking Sector Crisis',
    description: 'Major bank failures shake the financial sector.',
    icon: '🏦',
    type: EventType.scandal,
    impact: EventImpact.veryNegative,
    affectedSectorIds: ['finance'],
    priceImpactPercent: -10.0,
    impactVariance: 4.0,
    durationDays: 5,
    volatilityMultiplier: 2.2,
    baseChancePercent: 1.5,
    cooldownDays: 20,
    color: Colors.red,
  ),
  EventData(
    id: 'fintech_boom',
    title: 'Fintech Revolution',
    description: 'Digital payment adoption accelerates, finance stocks rally.',
    icon: '💳',
    type: EventType.innovation,
    impact: EventImpact.positive,
    affectedSectorIds: ['finance'],
    priceImpactPercent: 6.0,
    impactVariance: 2.0,
    durationDays: 3,
    volatilityMultiplier: 1.3,
    baseChancePercent: 3.0,
    cooldownDays: 12,
    color: Colors.green,
  ),

  // Consumer sector
  EventData(
    id: 'holiday_sales_boom',
    title: 'Record Holiday Sales',
    description: 'Consumer spending exceeds all expectations!',
    icon: '🛍️',
    type: EventType.earnings,
    impact: EventImpact.positive,
    affectedSectorIds: ['consumer'],
    priceImpactPercent: 5.0,
    impactVariance: 2.0,
    durationDays: 3,
    volatilityMultiplier: 1.2,
    baseChancePercent: 3.0,
    cooldownDays: 10,
    color: Colors.green,
  ),
  EventData(
    id: 'supply_chain_crisis',
    title: 'Supply Chain Disruption',
    description: 'Global supply chain issues hit consumer goods.',
    icon: '📦',
    type: EventType.supplyShock,
    impact: EventImpact.negative,
    affectedSectorIds: ['consumer', 'industrial'],
    priceImpactPercent: -5.0,
    impactVariance: 2.0,
    durationDays: 4,
    volatilityMultiplier: 1.5,
    baseChancePercent: 3.0,
    cooldownDays: 14,
    color: Colors.red,
  ),

  // Gaming sector
  EventData(
    id: 'gaming_boom',
    title: 'Gaming Industry Boom',
    description: 'New console releases drive gaming stocks higher!',
    icon: '🎮',
    type: EventType.productLaunch,
    impact: EventImpact.positive,
    affectedSectorIds: ['gaming'],
    priceImpactPercent: 8.0,
    impactVariance: 3.0,
    durationDays: 4,
    volatilityMultiplier: 1.4,
    baseChancePercent: 3.0,
    cooldownDays: 12,
    color: Colors.purple,
  ),

  // Crypto sector
  EventData(
    id: 'crypto_rally',
    title: 'Crypto Market Rally',
    description: 'Bitcoin hits new all-time high, crypto stocks surge!',
    icon: '₿',
    type: EventType.bullRun,
    impact: EventImpact.veryPositive,
    affectedSectorIds: ['crypto'],
    priceImpactPercent: 15.0,
    impactVariance: 5.0,
    durationDays: 3,
    volatilityMultiplier: 2.0,
    baseChancePercent: 2.0,
    cooldownDays: 10,
    color: Colors.orange,
  ),
  EventData(
    id: 'crypto_crash',
    title: 'Crypto Market Crash',
    description: 'Major exchange collapse triggers crypto sell-off.',
    icon: '💔',
    type: EventType.marketCrash,
    impact: EventImpact.veryNegative,
    affectedSectorIds: ['crypto'],
    priceImpactPercent: -20.0,
    impactVariance: 5.0,
    durationDays: 3,
    volatilityMultiplier: 2.5,
    baseChancePercent: 2.0,
    cooldownDays: 14,
    color: Colors.red,
  ),

  // Aerospace sector
  EventData(
    id: 'space_success',
    title: 'Historic Space Mission',
    description: 'Successful space mission boosts aerospace confidence!',
    icon: '🚀',
    type: EventType.productLaunch,
    impact: EventImpact.positive,
    affectedSectorIds: ['aerospace'],
    priceImpactPercent: 7.0,
    impactVariance: 2.0,
    durationDays: 3,
    volatilityMultiplier: 1.3,
    baseChancePercent: 2.0,
    cooldownDays: 15,
    color: Colors.blue,
  ),
  EventData(
    id: 'defense_contract',
    title: 'Major Defense Contract',
    description: 'Government awards massive defense spending contract.',
    icon: '🛡️',
    type: EventType.earnings,
    impact: EventImpact.positive,
    affectedSectorIds: ['aerospace'],
    priceImpactPercent: 6.0,
    impactVariance: 2.0,
    durationDays: 3,
    volatilityMultiplier: 1.2,
    baseChancePercent: 3.0,
    cooldownDays: 12,
    color: Colors.green,
  ),
];

/// Get a random event based on chance
EventData? getRandomEvent(List<String> recentEventIds, int currentDay) {
  // Filter out events on cooldown
  final availableEvents = allSpecialEvents.where((event) {
    if (!event.isRepeatable && recentEventIds.contains(event.id)) {
      return false;
    }
    return true;
  }).toList();

  if (availableEvents.isEmpty) return null;

  // Calculate total chance
  double totalChance = availableEvents.fold(
    0.0,
    (sum, event) => sum + event.baseChancePercent,
  );

  // Random roll
  final roll = (DateTime.now().millisecondsSinceEpoch % 1000) / 10.0;

  // Check if any event triggers (total ~25% chance per day)
  if (roll > totalChance * 0.8) return null;

  // Weighted random selection
  double cumulative = 0;
  final normalizedRoll = roll / (totalChance * 0.8) * totalChance;

  for (final event in availableEvents) {
    cumulative += event.baseChancePercent;
    if (normalizedRoll <= cumulative) {
      return event;
    }
  }

  return availableEvents.last;
}

/// Get events by sector
List<EventData> getEventsBySector(String sectorId) {
  return allSpecialEvents.where((e) => e.affectedSectorIds.contains(sectorId)).toList();
}

/// Get market-wide events only
List<EventData> getMarketWideEvents() {
  return allSpecialEvents.where((e) => e.isMarketWide).toList();
}

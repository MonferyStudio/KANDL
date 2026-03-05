import 'dart:math';
import '../models/news_item.dart';
import '../models/company_data.dart';
import '../models/sector_data.dart';

class NewsGenerator {
  static final Random _random = Random();
  static int _newsIdCounter = 0;

  /// Rarity-based impact magnitude roll.
  /// 50% low (0.1-0.3), 30% medium (0.3-0.5), 15% high (0.5-0.7), 5% very high (0.7-1.0)
  static double _rollImpactMagnitude() {
    final roll = _random.nextDouble();
    if (roll < 0.50) return _random.nextDouble() * 0.2 + 0.1;
    if (roll < 0.80) return _random.nextDouble() * 0.2 + 0.3;
    if (roll < 0.95) return _random.nextDouble() * 0.2 + 0.5;
    return _random.nextDouble() * 0.3 + 0.7;
  }

  // News templates for different categories
  static final Map<NewsCategory, List<NewsTemplate>> _templates = {
    NewsCategory.earnings: [
      NewsTemplate(
        key: 'earnings_beat',
        headlines: [
          '{company} beats earnings expectations',
          '{company} crushes Q{quarter} earnings estimates',
          '{company} surprises Wall Street with stellar Q{quarter}',
          'Analysts stunned as {company} smashes targets',
          '{ticker} posts blowout quarter',
        ],
        descriptions: [
          'Analysts who predicted doom are "re-evaluating their models." Translation: they were wrong. Again.',
          'CFO tries to look humble during earnings call. Fails spectacularly.',
          'Wall Street upgrades stock after pretending they saw this coming.',
          'Executives congratulate each other. Workers get a thank-you email.',
          'Short sellers in shambles. Reddit rejoices.',
        ],
        sentiment: NewsSentiment.veryPositive,
      ),
      NewsTemplate(
        key: 'earnings_miss',
        headlines: [
          '{company} misses Q{quarter} earnings targets',
          '{company} reports disappointing Q{quarter} results',
          '{ticker} falls short of analyst expectations',
          'Weak Q{quarter} results send {company} tumbling',
          '{company} earnings disappoint investors',
        ],
        descriptions: [
          'CEO blames "macroeconomic headwinds" instead of admitting the yacht budget got out of hand.',
          'Conference call features creative excuses and awkward silences.',
          'Board schedules emergency meeting at a "resort" in the Bahamas.',
          '"One-time charges" cited. Third quarter in a row.',
          'CFO reading prepared statement sounds suspiciously rehearsed.',
        ],
        sentiment: NewsSentiment.negative,
      ),
      NewsTemplate(
        key: 'earnings_record',
        headlines: [
          '{company} reports record profits',
          '{company} shatters all-time earnings record',
          'Historic quarter: {company} breaks revenue records',
          '{ticker} achieves best quarter in company history',
          '{company} posts unprecedented profit margins',
        ],
        descriptions: [
          'Board celebrates by voting themselves bonuses. Workers get a pizza party. Stocks go brrr.',
          'CEO announces record profits while explaining why raises aren\'t possible.',
          'Shareholders pop champagne. Employees get expired snacks from the break room.',
          'Record profits announced. Layoffs scheduled for next week. Coincidence, surely.',
          'Company "couldn\'t have done it without the team." Team gets 2% raise, maybe.',
        ],
        sentiment: NewsSentiment.veryPositive,
      ),
    ],
    NewsCategory.product: [
      NewsTemplate(
        key: 'product_launch',
        headlines: [
          '{company} launches revolutionary new product',
          '{company} unveils next-generation offering',
          'Breaking: {company} announces game-changing product',
          '{company} enters new market with innovative launch',
          '{ticker} stock soars on product announcement',
        ],
        descriptions: [
          'It\'s basically the same thing with a new color. Investors call it "disruptive innovation."',
          'Marketing department worked overtime on buzzwords. Engineering worked overtime on bugs.',
          'Pre-orders crash the website. IT department seen crying in server room.',
          'Influencers already calling it "life-changing." They got it for free.',
          'CEO demos product live. It only crashes twice. Success!',
        ],
        sentiment: NewsSentiment.positive,
      ),
      NewsTemplate(
        key: 'product_delay',
        headlines: [
          '{company} delays major product release',
          '{company} pushes back launch date amid setbacks',
          '{ticker} drops as {company} announces delays',
          '{company} product launch postponed indefinitely',
          'Supply chain woes force {company} to delay release',
        ],
        descriptions: [
          'Turns out "move fast and break things" has consequences. Who knew?',
          'Engineers need "a few more weeks." Translation: several months.',
          'Quality issues discovered. Better now than after launch, probably.',
          'PR team crafts statement blaming everything except actual management.',
          'Investors told to "think long-term." They sell immediately.',
        ],
        sentiment: NewsSentiment.negative,
      ),
      NewsTemplate(
        key: 'product_recall',
        headlines: [
          '{company} product faces safety recall',
          '{company} issues urgent product recall',
          'Safety concerns prompt {company} recall',
          '{company} recalls millions of units',
          'Breaking: {company} announces massive recall',
        ],
        descriptions: [
          '"We take customer safety seriously" says company that clearly didn\'t until now.',
          'Legal team working overtime. Coffee machine working even more overtime.',
          'Testing department silently updates their resumes.',
          'CEO assures public the issue is "isolated." Definition of isolated: unclear.',
          'Customer service lines experiencing "higher than normal call volume." Forever.',
        ],
        sentiment: NewsSentiment.veryNegative,
      ),
    ],
    NewsCategory.merger: [
      NewsTemplate(
        key: 'merger_announce',
        headlines: [
          '{company} announces major acquisition',
          '{company} to acquire competitor in blockbuster deal',
          'Breaking: {company} in merger talks',
          '{company} expands empire with strategic acquisition',
          '{ticker} surges on acquisition news',
        ],
        descriptions: [
          'Two mediocre companies become one big mediocre company. Synergy!',
          '"Strategic fit" means they ran out of ideas independently.',
          'Executives promise no layoffs. HR already drafting layoff memos.',
          'Investment bankers celebrate. Everyone else updates LinkedIn.',
          'Regulatory approval expected. Antitrust lawyers booking vacation homes.',
        ],
        sentiment: NewsSentiment.positive,
      ),
      NewsTemplate(
        key: 'merger_collapse',
        headlines: [
          '{company} merger talks collapse',
          '{company} acquisition deal falls through',
          'Regulatory concerns tank {company} merger',
          '{company} walks away from acquisition talks',
          'Breaking: {company} deal off the table',
        ],
        descriptions: [
          'Both CEOs wanted the corner office. No one considered a coin flip.',
          'Due diligence revealed things. Embarrassing things.',
          'Regulators said no. CEOs pretend they planned this all along.',
          '"Cultural differences" cited. Translation: egos too big.',
          'Deal dies. Investment bankers still get paid. Capitalism.',
        ],
        sentiment: NewsSentiment.negative,
      ),
    ],
    NewsCategory.regulation: [
      NewsTemplate(
        key: 'regulation_negative',
        headlines: [
          'New regulations impact {sector} sector',
          'Government tightens rules on {sector}',
          '{sector} faces stricter oversight',
          'Regulatory crackdown hits {sector}',
          'Lawmakers target {sector} with new rules',
        ],
        descriptions: [
          'Government finally noticed the loopholes. Lobbyists are working overtime.',
          'Compliance costs up. Executive bonuses unaffected. Priorities.',
          'Politicians discover industry exists. Industry discovers politicians exist.',
          'Regulatory filings now require actual reading. Chaos ensues.',
          'Legal budgets quadruple. Legal departments rejoice.',
        ],
        sentiment: NewsSentiment.negative,
      ),
      NewsTemplate(
        key: 'regulation_positive',
        headlines: [
          '{sector} sector receives regulatory approval',
          'Government eases restrictions on {sector}',
          '{sector} wins favorable ruling',
          'Deregulation boost for {sector}',
          'Lawmakers give {sector} green light',
        ],
        descriptions: [
          'Regulators approve thing they clearly don\'t understand. Business as usual.',
          'Lobbying budget pays off. Democracy in action.',
          'Red tape cut. Compliance officers nervously update resumes.',
          'Government says yes. Industry promises to behave. Pinky swear.',
          'Regulatory approval granted. Terms and conditions apply. Many conditions.',
        ],
        sentiment: NewsSentiment.positive,
      ),
    ],
    NewsCategory.market: [
      NewsTemplate(
        key: 'market_rally',
        headlines: [
          'Market rallies on strong economic data',
          'Stocks surge amid positive outlook',
          'Bull run continues as markets hit highs',
          'Investors cheer as indices climb',
          'Market optimism drives broad gains',
        ],
        descriptions: [
          'Number go up. Experts pretend they predicted this. Twitter traders claim genius status.',
          'Everyone\'s portfolio is up. Time to give unsolicited advice.',
          'CNBC anchors smiling. A rare sighting.',
          'Retirement accounts looking healthy. Time to buy more dips.',
          'Green across the board. Bear market officially cancelled. For now.',
        ],
        sentiment: NewsSentiment.positive,
      ),
      NewsTemplate(
        key: 'market_volatility',
        headlines: [
          'Market volatility spikes amid uncertainty',
          'Wild swings rock stock market',
          'Investors brace for turbulent trading',
          'Market whipsaws on mixed signals',
          'Volatility index surges to yearly high',
        ],
        descriptions: [
          'Algorithms fighting algorithms while humans panic. Peak capitalism.',
          'Portfolio up 5% then down 7% in same hour. Normal day.',
          'Trading halts. Coffee consumption spikes. Analysts update resumes.',
          'Your stop losses triggered. Then it rallied. Of course.',
          'Market makes no sense. Experts explain it anyway. Confidently.',
        ],
        sentiment: NewsSentiment.negative,
      ),
      NewsTemplate(
        key: 'market_bull',
        headlines: [
          'Bull market continues record run',
          'Stocks extend gains in historic rally',
          'Markets reach new all-time highs',
          'Unstoppable: Bull market defies gravity',
          'Investors ride longest bull run in decades',
        ],
        descriptions: [
          'Everyone\'s a genius in a bull market. Your cousin\'s crypto tips suddenly seem reasonable.',
          'Bears capitulate. Bulls celebrate. Cycle continues.',
          'New all-time high. Time to worry about the next crash.',
          'Stonks only go up. This time is different. (It\'s not.)',
          'FOMO kicks in. Everyone becomes a day trader. What could go wrong?',
        ],
        sentiment: NewsSentiment.veryPositive,
      ),
    ],
    NewsCategory.sector: [
      NewsTemplate(
        key: 'sector_growth',
        headlines: [
          '{sector} sector sees strong growth',
          '{sector} leads market gains',
          'Investors pile into {sector}',
          '{sector} outperforms broader market',
          'Strong quarter for {sector} stocks',
        ],
        descriptions: [
          'Executives congratulate themselves. Workers wonder where their raise went.',
          'Sector rotation in full swing. Analysts pretend they called it.',
          'Everyone wants exposure now. Where were they six months ago?',
          'Growth stocks doing growth stock things.',
          'Rising tide lifts all boats. Some boats more than others.',
        ],
        sentiment: NewsSentiment.positive,
      ),
      NewsTemplate(
        key: 'sector_headwinds',
        headlines: [
          '{sector} faces headwinds',
          '{sector} sector under pressure',
          'Challenging times ahead for {sector}',
          '{sector} stocks slump on concerns',
          'Investors flee {sector} amid uncertainty',
        ],
        descriptions: [
          '"Headwinds" is corporate speak for "we messed up but it\'s not our fault somehow."',
          'Sector rotation out in full swing. Where\'s everyone going?',
          'Analysts downgrade everything. Cover themselves for the next year.',
          'Bad quarter blamed on externalities. Never internal issues.',
          'Investors discover risk exists. Shocked. Absolutely shocked.',
        ],
        sentiment: NewsSentiment.negative,
      ),
    ],
    NewsCategory.economy: [
      NewsTemplate(
        key: 'economy_fed',
        headlines: [
          'Fed signals interest rate changes',
          'Central bank hints at policy shift',
          'Fed Chair speaks, markets listen',
          'Interest rate decision looms',
          'Fed meeting minutes reveal surprises',
        ],
        descriptions: [
          'Jerome Powell says words. Markets have existential crisis. Rinse, repeat.',
          'Every word analyzed. Every pause dissected. Tea leaves consulted.',
          'Fed does exactly what everyone expected. Markets still surprised.',
          'Interest rates to do something. Or not. Very clear guidance.',
          'Dot plot reveals nothing. Everyone pretends to understand it anyway.',
        ],
        sentiment: NewsSentiment.neutral,
      ),
      NewsTemplate(
        key: 'economy_gdp',
        headlines: [
          'GDP growth exceeds expectations',
          'Economy stronger than forecast',
          'Robust growth figures released',
          'Economic expansion continues',
          'Strong GDP numbers boost confidence',
        ],
        descriptions: [
          'Economy strong if you ignore everyone who isn\'t a shareholder.',
          'GDP up. Wages flat. Housing unaffordable. Everything is fine.',
          'Economists surprised by good news. For once.',
          'Growth attributed to consumer spending. Consumers attributed to debt.',
          'Soft landing achieved. Or delayed. Depends who you ask.',
        ],
        sentiment: NewsSentiment.positive,
      ),
      NewsTemplate(
        key: 'economy_inflation',
        headlines: [
          'Inflation concerns mount',
          'Consumer prices rise faster than expected',
          'Inflation hits multi-year high',
          'Price pressures persist',
          'Cost of living continues to climb',
        ],
        descriptions: [
          'Your money buys less but CEOs still got their bonuses. The system works!',
          '"Transitory" redefined. Again.',
          'Shrinkflation strikes. Same price, smaller everything.',
          'Real wages negative. But hey, employment is strong!',
          'Eggs expensive. Avocado toast blamed. Millennials confused.',
        ],
        sentiment: NewsSentiment.negative,
      ),
    ],
    // === GAMEPLAY-AFFECTING NEWS ===
    NewsCategory.platform: [
      // Fee changes
      NewsTemplate(
        key: 'platform_free_trading',
        headlines: [
          'Broker announces commission-free trading day!',
          'Zero fees! Platform offers free trades today',
          'Special promotion: Trade without commissions',
          'Free trading event announced',
          'Platform waives all fees for 24 hours',
        ],
        descriptions: [
          'They\'ll make it back selling your data anyway. YOLO responsibly!',
          'Free trading means more trading. Platform knows this. You should too.',
          'Zero commission day. Hidden costs remain. Read the fine print.',
          'Marketing department\'s idea. Finance department cries.',
          'Trade free today. Lose money for free. Efficiency!',
        ],
        sentiment: NewsSentiment.veryPositive,
        effectType: GameplayEffectType.feeMultiplier,
        effectValue: 0.0, // 0% fees
        effectDurationDays: 1,
      ),
      NewsTemplate(
        key: 'platform_fee_reduction',
        headlines: [
          'Trading platform reduces fees by 50%',
          'Half-price trading: Fees slashed',
          'Platform announces fee reduction',
          'Competitive pressure drives fees down',
          'Broker cuts commission rates',
        ],
        descriptions: [
          'Competition works! Until they merge and jack prices back up.',
          'Fees reduced. Volume increased. Net effect: probably the same for them.',
          'Cheaper to trade. Cheaper to lose money. Progress!',
          'Fee war benefits traders. Temporarily.',
          'Lower fees announced. Spread widened. Net neutral. Classic.',
        ],
        sentiment: NewsSentiment.positive,
        effectType: GameplayEffectType.feeMultiplier,
        effectValue: 0.5, // 50% of normal fees
        effectDurationDays: 2,
      ),
      NewsTemplate(
        key: 'platform_fee_increase',
        headlines: [
          'Platform maintenance fees increased',
          'Trading costs rise as fees go up',
          'Broker raises commission rates',
          'Fee hikes hit traders',
          'Platform announces higher charges',
        ],
        descriptions: [
          'Servers don\'t pay for themselves. Neither do CEO beach houses.',
          '"Market conditions" blamed. Profit margins unaffected.',
          'Fees up. Service unchanged. Customer appreciation event planned.',
          'Higher fees for "enhanced experience." Experience unchanged.',
          'Cost of doing business. Business of costing you more.',
        ],
        sentiment: NewsSentiment.negative,
        effectType: GameplayEffectType.feeMultiplier,
        effectValue: 2.0, // 200% fees
        effectDurationDays: 1,
      ),
      NewsTemplate(
        key: 'platform_surcharge',
        headlines: [
          'High volume surcharge applied to all trades',
          'Trading surcharge announced',
          'Platform adds temporary fee',
          'Extra charges during high activity',
          'Surcharge hits all transactions',
        ],
        descriptions: [
          'Too many people making money? Time to add fees. Can\'t have that.',
          'Volume-based pricing. Sounds fair until you do the math.',
          'Surge pricing for stocks. Uber would be proud.',
          'High demand = higher fees. Supply and demand, but annoying.',
          'Temporary surcharge. Definition of temporary: unclear.',
        ],
        sentiment: NewsSentiment.negative,
        effectType: GameplayEffectType.feeMultiplier,
        effectValue: 1.5, // 150% fees
        effectDurationDays: 1,
      ),
    ],
    NewsCategory.bonus: [
      // Cash bonuses
      NewsTemplate(
        key: 'bonus_loyalty',
        headlines: [
          'Broker loyalty bonus credited to your account!',
          'Thank you bonus: Cash reward deposited',
          'Loyalty rewards program payout',
          'Trading milestone bonus received',
          'Platform rewards active traders',
        ],
        descriptions: [
          'Here\'s a tiny fraction of what we made off you. Don\'t spend it all in one trade.',
          'Loyalty rewarded. After calculating how much they made from you.',
          'Free money! Terms and conditions apply. So many conditions.',
          'Account credited. Tax implications not included.',
          'Bonus deposited. Now trade more so we make it back!',
        ],
        sentiment: NewsSentiment.veryPositive,
        effectType: GameplayEffectType.cashBonus,
        effectValue: 100.0, // $100 bonus
        effectDurationDays: 0, // Instant
      ),
      NewsTemplate(
        key: 'bonus_rebate',
        headlines: [
          'Trading volume rebate received',
          'Commission rebate credited',
          'Cashback on trading fees',
          'Volume discount applied',
          'Fee rebate bonus deposited',
        ],
        descriptions: [
          'You traded so much we felt guilty. Just kidding, it\'s a marketing expense.',
          'Rebate received. Please continue trading. Excessively.',
          'Some of your fees returned. Most kept. Fair trade.',
          'Volume rewards in action. Trade more, save more, lose more.',
          'Cashback credited. Immediately reinvest for maximum broker profit.',
        ],
        sentiment: NewsSentiment.positive,
        effectType: GameplayEffectType.cashBonus,
        effectValue: 50.0, // $50 bonus
        effectDurationDays: 0,
      ),
      NewsTemplate(
        key: 'bonus_promo',
        headlines: [
          'New user promotion bonus!',
          'Welcome bonus credited',
          'Promotional cash reward',
          'Special offer: Free trading credits',
          'Limited time bonus deposited',
        ],
        descriptions: [
          'Free money to get you hooked. First taste is always free.',
          'Promotion credited. Now they have your data forever.',
          'Welcome aboard! Here\'s some cash. Trading addiction not included.',
          'New trader bonus. Experienced trader PTSD not included.',
          'Free money with strings attached. So many strings.',
        ],
        sentiment: NewsSentiment.positive,
        effectType: GameplayEffectType.cashBonus,
        effectValue: 75.0, // $75 bonus
        effectDurationDays: 0,
      ),
      NewsTemplate(
        key: 'bonus_compensation',
        headlines: [
          'System glitch compensation credited',
          'Outage compensation deposited',
          'Technical issue refund received',
          'Platform error compensation',
          'Service disruption credit applied',
        ],
        descriptions: [
          'Oops, we broke something. Here\'s hush money. Please don\'t tweet about it.',
          'Compensation for downtime. Doesn\'t cover your missed gains. Sorry.',
          'Glitch compensation. They still made money. You didn\'t.',
          'Technical issue resolved. Trust partially restored. Maybe.',
          'Here\'s something for the inconvenience. And the lawyers.',
        ],
        sentiment: NewsSentiment.positive,
        effectType: GameplayEffectType.cashBonus,
        effectValue: 150.0, // $150 bonus
        effectDurationDays: 0,
      ),
    ],
    NewsCategory.restriction: [
      // Trading restrictions
      NewsTemplate(
        key: 'restriction_short_ban',
        headlines: [
          'SEC temporarily bans short selling',
          'Short selling suspended',
          'Regulators halt short positions',
          'Emergency short sale restrictions',
          'Short selling freeze announced',
        ],
        descriptions: [
          'Hedge funds complained their shorts weren\'t working. Retail: "First time?"',
          'Can\'t bet against stocks. Only bet for them. Very free market.',
          'Shorts banned. Longs only. Bears hibernate.',
          'Short selling suspended. Market manipulation concerns. Ironic.',
          'No shorting allowed. Bulls suddenly very brave.',
        ],
        sentiment: NewsSentiment.negative,
        effectType: GameplayEffectType.shortSellingBan,
        effectValue: 1.0, // Flag value
        effectDurationDays: 2,
      ),
      NewsTemplate(
        key: 'restriction_short_emergency',
        headlines: [
          'Emergency short selling restrictions enacted',
          'Urgent: Short sales halted',
          'Crisis response: Shorts banned',
          'Immediate short selling freeze',
          'Regulators impose emergency restrictions',
        ],
        descriptions: [
          'When rich people lose money, suddenly shorting is a problem. Curious.',
          'Emergency measures. Because free markets need saving from themselves.',
          'Shorts banned immediately. No warning. Very orderly markets.',
          'Crisis mode activated. Short sellers cry. Everyone else confused.',
          'Emergency restriction. Definition of emergency: people with power losing.',
        ],
        sentiment: NewsSentiment.negative,
        effectType: GameplayEffectType.shortSellingBan,
        effectValue: 1.0,
        effectDurationDays: 1,
      ),
      NewsTemplate(
        key: 'restriction_position_limit',
        headlines: [
          'Position limits temporarily enforced',
          'Trading caps implemented',
          'Maximum position sizes restricted',
          'Size limits on all trades',
          'Position limit rules activated',
        ],
        descriptions: [
          'Too many apes buying? Better limit their fun. The house always wins.',
          'Position limits for your protection. Whose protection unclear.',
          'Can\'t buy too much. Can\'t sell too much. Can still lose, though.',
          'Limits imposed. Whales unaffected. Retail notices.',
          'Trading capped. For orderly markets. Order defined by others.',
        ],
        sentiment: NewsSentiment.negative,
        effectType: GameplayEffectType.positionLimit,
        effectValue: 50.0, // Max 50 shares per trade
        effectDurationDays: 1,
      ),
      NewsTemplate(
        key: 'restriction_position_cap',
        headlines: [
          'Platform implements position sizing rules',
          'Risk management: Trade sizes capped',
          'New position sizing guidelines active',
          'Platform enforces prudent position limits',
          'Trade size restrictions for market stability',
        ],
        descriptions: [
          'Risk management kicks in. Your portfolio thanks you later. Maybe.',
          'Position sizes capped. The platform cares about you. Allegedly.',
          'Sizing rules enforced. Can\'t YOLO as hard today. Sad.',
          'Trade caps active. Responsible investing mandated. Fun reduced.',
          'Position limits engaged. For orderly markets and boring portfolios.',
        ],
        sentiment: NewsSentiment.neutral,
        effectType: GameplayEffectType.positionLimit,
        effectValue: 100.0,
        effectDurationDays: 2,
      ),
      NewsTemplate(
        key: 'restriction_short_lifted',
        headlines: [
          'Short selling ban lifted early!',
          'Restrictions removed: Shorts allowed',
          'Short selling resumes',
          'Ban lifted: Bears return',
          'Short sale restrictions ended',
        ],
        descriptions: [
          'Hedge funds lobbied successfully. Democracy in action.',
          'Shorts allowed again. Market about to get interesting.',
          'Restrictions lifted. Let the games begin.',
          'Bears unleashed. Bulls nervous. Volatility incoming.',
          'Short selling back. Balance restored. Chaos continues.',
        ],
        sentiment: NewsSentiment.positive,
        // This one doesn't have an effect - it's just flavor text
      ),
    ],
    NewsCategory.event: [
      // Special events
      NewsTemplate(
        key: 'event_flash_sale',
        headlines: [
          'Flash sale: 50% off all upgrades today!',
          'Mega sale: Half-price upgrades',
          'Limited time: Massive upgrade discount',
          'Flash deal: Upgrades at 50% off',
          'Today only: Upgrade fire sale',
        ],
        descriptions: [
          'Consume! Upgrade! The market demands it. Your wallet weeps.',
          'Black Friday came early. Or late. Time is meaningless in markets.',
          'Flash sale! Impulse buy now, regret never. Maybe.',
          'Half price upgrades. Full price FOMO.',
          'Sale ends soon. Buy now, think later. Standard protocol.',
        ],
        sentiment: NewsSentiment.veryPositive,
        effectType: GameplayEffectType.upgradeDiscount,
        effectValue: 0.5, // 50% discount
        effectDurationDays: 1,
      ),
      NewsTemplate(
        key: 'event_clearance',
        headlines: [
          'Upgrade clearance sale: 30% off',
          'Clearance event: Discounted upgrades',
          'End of quarter sale: 30% discount',
          'Clearance pricing on all upgrades',
          'Sale: Upgrades marked down',
        ],
        descriptions: [
          'We need to hit quarterly numbers. Help a corporation out?',
          'Clearance sale. Making room for new stuff to sell you.',
          'Discount event. Still profitable for them. Less painful for you.',
          'Quarter ending. Targets unmet. Sales ahoy!',
          'Upgrades on sale. Original price debatable.',
        ],
        sentiment: NewsSentiment.positive,
        effectType: GameplayEffectType.upgradeDiscount,
        effectValue: 0.3, // 30% discount
        effectDurationDays: 1,
      ),
      NewsTemplate(
        key: 'event_circuit_breaker',
        headlines: [
          'Market circuit breaker triggered!',
          'Trading halted: Circuit breaker activated',
          'Emergency stop: Markets paused',
          'Circuit breaker kicks in',
          'Trading suspended: Volatility too high',
        ],
        descriptions: [
          'Markets too crazy even for Wall Street. Everyone take a breather.',
          'Circuit breaker activated. Time to panic more organized-ly.',
          'Trading halted. Twitter not halted. Chaos continues.',
          'Forced break. Use it wisely. Or doom scroll.',
          'Markets paused. Your anxiety isn\'t. Deep breaths.',
        ],
        sentiment: NewsSentiment.veryNegative,
        effectType: GameplayEffectType.circuitBreaker,
        effectValue: 30.0, // 30 seconds halt
        effectDurationDays: 0,
      ),
      NewsTemplate(
        key: 'event_flash_crash',
        headlines: [
          'Flash crash warning: extreme volatility ahead',
          'Volatility alert: Turbulent trading expected',
          'Warning: High volatility conditions',
          'Market turbulence incoming',
          'Volatility spike detected',
        ],
        descriptions: [
          'Robots fighting robots. Humans just along for the ride. Welcome to modern markets.',
          'Volatility incoming. Stop losses about to trigger. Then reverse. Classic.',
          'Buckle up. This is not a drill. Or maybe it is. Who knows.',
          'High volatility ahead. Perfect for day trading. And losing money quickly.',
          'Flash crash territory. Diamond hands tested. Paper hands folded.',
        ],
        sentiment: NewsSentiment.negative,
        effectType: GameplayEffectType.volatilitySpike,
        effectValue: 2.0, // 2x volatility
        effectDurationDays: 1,
      ),
      NewsTemplate(
        key: 'event_stabilize',
        headlines: [
          'Market stabilizes: volatility decreases',
          'Calm returns to markets',
          'Volatility drops as stability returns',
          'Markets find footing',
          'Smooth sailing ahead: Low volatility',
        ],
        descriptions: [
          'Money printer goes brrr. Crisis averted. Until next week.',
          'Markets calm. Boring. Perfect for actual investing.',
          'Volatility down. Day traders sad. Long-term investors shrug.',
          'Stability returns. Enjoy it while it lasts.',
          'Calm markets. Time to be greedy? Or still fearful? Magic 8-ball says: unclear.',
        ],
        sentiment: NewsSentiment.positive,
        effectType: GameplayEffectType.volatilitySpike,
        effectValue: 0.5, // 0.5x volatility (calmer)
        effectDurationDays: 1,
      ),
      // Signal disruption events
      NewsTemplate(
        key: 'event_data_glitch',
        headlines: [
          'Market data feed corrupted!',
          'Technical glitch scrambles market indicators',
          'Data provider reports system malfunction',
          'Warning: Market signals unreliable',
          'System error affects trading analytics',
        ],
        descriptions: [
          'Your fancy indicators are showing the opposite of reality. Good luck out there.',
          'Garbage in, garbage out. Today it\'s ALL garbage. Trust nothing.',
          'Data feed went haywire. Algorithms confused. Humans even more confused.',
          'Technical issue makes all signals questionable. Trade at your own risk.',
          'Market data corrupted. Every indicator is lying to you. Or is it telling the truth? Who knows.',
        ],
        sentiment: NewsSentiment.negative,
        effectType: GameplayEffectType.signalJammer,
        effectValue: 1.0,
        effectDurationDays: 1,
      ),
      NewsTemplate(
        key: 'event_algo_confusion',
        headlines: [
          'Algorithm chaos: Trading bots go haywire',
          'AI trading systems produce conflicting signals',
          'Quant models break down amid market anomaly',
          'Trading algorithms clash: Signals reversed',
          'Machine learning models fail spectacularly',
        ],
        descriptions: [
          'The robots are confused. The humans were already confused. It\'s confusion all the way down.',
          'AI said buy. Other AI said sell. Both were wrong. Classic.',
          'Quant funds losing money on opposite signals. Irony at its finest.',
          'Every indicator is showing the exact opposite. Or is this the new normal?',
          'Algorithms fighting each other. Your signals caught in the crossfire.',
        ],
        sentiment: NewsSentiment.negative,
        effectType: GameplayEffectType.signalJammer,
        effectValue: 1.0,
        effectDurationDays: 2,
      ),
      NewsTemplate(
        key: 'event_sector_rotation',
        headlines: [
          'Massive sector rotation shocks markets!',
          'Institutional investors flip positions overnight',
          'Sector rotation: Winners become losers',
          'Market regime change catches traders off guard',
          'Trend reversal: Everything you knew is wrong',
        ],
        descriptions: [
          'What was hot is now cold. What was cold is now hot. Welcome to the stock market roulette.',
          'Big money moved overnight. Your analysis from yesterday? Worthless.',
          'Sector rotation so fast it gave analysts whiplash. Chiropractors rejoice.',
          'Every trend just reversed. If you were winning, you\'re not anymore. If you were losing... also still losing.',
          'Institutional money flipped. Retail left holding the bag. As is tradition.',
        ],
        sentiment: NewsSentiment.negative,
        effectType: GameplayEffectType.trendReversal,
        effectValue: 1.0,
        effectDurationDays: 0,
      ),
      NewsTemplate(
        key: 'event_whale_activity',
        headlines: [
          'Whale alert: Massive position detected',
          'Dark pool activity spikes on mystery stock',
          'Institutional whale moves market',
          'Unusual trading volume: Big player detected',
          'Market maker manipulation suspected',
        ],
        descriptions: [
          'Someone with more money than sense just moved the market. You\'re along for the ride.',
          'A whale just did... something. To some stock. Details unclear. Price very clear.',
          'Dark pool trade so big it moved the entire market. Normal day in capitalism.',
          'Mysterious buyer/seller shakes up a random stock. Conspiracy theorists activate.',
          'When you have billions, the market is your playground. And you\'re the toy.',
        ],
        sentiment: NewsSentiment.neutral,
        effectType: GameplayEffectType.marketManipulation,
        effectValue: 1.0,
        effectDurationDays: 0,
      ),
    ],
  };

  /// Generate random news for a company
  static NewsItem generateCompanyNews(CompanyData company) {
    final categories = [
      NewsCategory.earnings,
      NewsCategory.product,
      NewsCategory.merger,
      NewsCategory.company,
    ];

    final category = categories[_random.nextInt(categories.length)];
    final templates = _templates[category] ?? [];

    if (templates.isEmpty) {
      return _generateGenericCompanyNews(company);
    }

    final template = templates[_random.nextInt(templates.length)];
    final quarter = _random.nextInt(4) + 1;

    return NewsItem(
      id: 'news_${_newsIdCounter++}',
      headline: template.getRandomHeadline(_random)
          .replaceAll('{company}', company.name)
          .replaceAll('{ticker}', company.ticker)
          .replaceAll('{quarter}', quarter.toString()),
      description: template.getRandomDescription(_random),
      category: category,
      sentiment: template.sentiment,
      timestamp: DateTime.now(),
      companyId: company.id,
      impactMagnitude: _rollImpactMagnitude(),
      templateKey: template.key,
      companyName: company.name,
      quarter: quarter,
    );
  }

  /// Generate random news for a sector
  static NewsItem generateSectorNews(SectorData sector) {
    final categories = [
      NewsCategory.sector,
      NewsCategory.regulation,
    ];

    final category = categories[_random.nextInt(categories.length)];
    final templates = _templates[category] ?? [];

    if (templates.isEmpty) {
      return _generateGenericSectorNews(sector);
    }

    final template = templates[_random.nextInt(templates.length)];

    return NewsItem(
      id: 'news_${_newsIdCounter++}',
      headline: template.getRandomHeadline(_random)
          .replaceAll('{sector}', sector.name),
      description: template.getRandomDescription(_random),
      category: category,
      sentiment: template.sentiment,
      timestamp: DateTime.now(),
      sectorId: sector.id,
      impactMagnitude: _rollImpactMagnitude(),
      templateKey: template.key,
      sectorName: sector.name,
    );
  }

  /// Generate general market news
  static NewsItem generateMarketNews() {
    final categories = [
      NewsCategory.market,
      NewsCategory.economy,
    ];

    final category = categories[_random.nextInt(categories.length)];
    final templates = _templates[category] ?? [];

    if (templates.isEmpty) {
      return _generateGenericMarketNews();
    }

    final template = templates[_random.nextInt(templates.length)];

    return NewsItem(
      id: 'news_${_newsIdCounter++}',
      headline: template.getRandomHeadline(_random),
      description: template.getRandomDescription(_random),
      category: category,
      sentiment: template.sentiment,
      timestamp: DateTime.now(),
      impactMagnitude: _rollImpactMagnitude(),
      templateKey: template.key,
    );
  }

  /// Generate gameplay-affecting news (platform, bonus, restriction, event)
  static NewsItem? generateGameplayNews() {
    final categories = [
      NewsCategory.platform,
      NewsCategory.bonus,
      NewsCategory.restriction,
      NewsCategory.event,
    ];

    final category = categories[_random.nextInt(categories.length)];
    final templates = _templates[category] ?? [];

    if (templates.isEmpty) {
      return null;
    }

    final template = templates[_random.nextInt(templates.length)];

    // Vary effect values slightly for some effects
    double effectValue = template.effectValue;
    if (template.effectType == GameplayEffectType.cashBonus) {
      // Randomize cash bonus a bit (+/- 25%)
      effectValue = effectValue * (0.75 + _random.nextDouble() * 0.5);
    }

    return NewsItem(
      id: 'news_${_newsIdCounter++}',
      headline: template.getRandomHeadline(_random),
      description: template.getRandomDescription(_random),
      category: category,
      sentiment: template.sentiment,
      timestamp: DateTime.now(),
      impactMagnitude: 0.8, // High impact for gameplay news
      effectType: template.effectType,
      effectValue: effectValue,
      effectDurationDays: template.effectDurationDays,
      templateKey: template.key,
    );
  }

  /// Generate a specific type of gameplay news
  static NewsItem? generateSpecificGameplayNews(NewsCategory category) {
    final templates = _templates[category] ?? [];

    if (templates.isEmpty) {
      return null;
    }

    final template = templates[_random.nextInt(templates.length)];

    double effectValue = template.effectValue;
    if (template.effectType == GameplayEffectType.cashBonus) {
      effectValue = effectValue * (0.75 + _random.nextDouble() * 0.5);
    }

    return NewsItem(
      id: 'news_${_newsIdCounter++}',
      headline: template.getRandomHeadline(_random),
      description: template.getRandomDescription(_random),
      category: category,
      sentiment: template.sentiment,
      timestamp: DateTime.now(),
      impactMagnitude: 0.8,
      effectType: template.effectType,
      effectValue: effectValue,
      effectDurationDays: template.effectDurationDays,
      templateKey: template.key,
    );
  }

  static NewsItem _generateGenericCompanyNews(CompanyData company) {
    final headlines = [
      '${company.name} makes headlines',
      '${company.ticker} in the news today',
      'Breaking: ${company.name} update',
      '${company.name} stock moves on news',
    ];
    final descriptions = [
      'CEO said something on Twitter. Stock reacts accordingly.',
      'Press release issued. Market interprets it however it wants.',
      'News from ${company.name}. Analysts scramble to form opinions.',
      'Something happened at ${company.name}. Details sketchy. Trades continue.',
    ];

    return NewsItem(
      id: 'news_${_newsIdCounter++}',
      headline: headlines[_random.nextInt(headlines.length)],
      description: descriptions[_random.nextInt(descriptions.length)],
      category: NewsCategory.company,
      sentiment: NewsSentiment.neutral,
      timestamp: DateTime.now(),
      companyId: company.id,
      templateKey: 'generic_company',
      companyName: company.name,
    );
  }

  static NewsItem _generateGenericSectorNews(SectorData sector) {
    final headlines = [
      '${sector.name} sector update',
      '${sector.name} in focus today',
      'Market eyes ${sector.name} sector',
      '${sector.name} sector developments',
    ];
    final descriptions = [
      'Analysts publish reports no one reads. Stocks do whatever they want anyway.',
      'Sector analysis released. Conclusions: it depends.',
      '${sector.name} doing ${sector.name} things. More at 11.',
      'Industry experts weigh in. Markets ignore them. Standard procedure.',
    ];

    return NewsItem(
      id: 'news_${_newsIdCounter++}',
      headline: headlines[_random.nextInt(headlines.length)],
      description: descriptions[_random.nextInt(descriptions.length)],
      category: NewsCategory.sector,
      sentiment: NewsSentiment.neutral,
      timestamp: DateTime.now(),
      sectorId: sector.id,
      templateKey: 'generic_sector',
      sectorName: sector.name,
    );
  }

  static NewsItem _generateGenericMarketNews() {
    final headlines = [
      'Market update',
      'Markets mixed today',
      'Trading session underway',
      'Market activity continues',
    ];
    final descriptions = [
      'Stocks went up, down, or sideways. Experts explain why after the fact.',
      'Markets doing market things. Volume normal. Chaos contained.',
      'Another day of trading. Winners and losers. Mostly losers.',
      'Markets open. Opinions differ. Coffee consumed.',
    ];

    return NewsItem(
      id: 'news_${_newsIdCounter++}',
      headline: headlines[_random.nextInt(headlines.length)],
      description: descriptions[_random.nextInt(descriptions.length)],
      category: NewsCategory.market,
      sentiment: NewsSentiment.neutral,
      timestamp: DateTime.now(),
      templateKey: 'generic_market',
    );
  }
}

class NewsTemplate {
  final String key; // Template key for localization lookup
  final List<String> headlines;
  final List<String> descriptions;
  final NewsSentiment sentiment;
  final GameplayEffectType effectType;
  final double effectValue;
  final int effectDurationDays;

  const NewsTemplate({
    required this.key,
    required this.headlines,
    required this.descriptions,
    required this.sentiment,
    this.effectType = GameplayEffectType.none,
    this.effectValue = 0.0,
    this.effectDurationDays = 0,
  });

  /// Get a random headline from the list
  String getRandomHeadline(Random random) {
    return headlines[random.nextInt(headlines.length)];
  }

  /// Get a random description from the list
  String getRandomDescription(Random random) {
    return descriptions[random.nextInt(descriptions.length)];
  }
}

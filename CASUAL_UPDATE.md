# KANDL - Casual Update

**Date:** 2026-02-11
**Version:** 0.13

---

## The Casual Update

Based on player feedback that the game felt more like a trading platform than a game, I've made a big pass to simplify the interface and make everything more approachable.

*Note: Most of this update was already in the works before launch, which is why it's coming so soon after release. Don't expect this pace to be the norm!*

---

## Simplified Vocabulary

The game now speaks your language! I've replaced confusing finance jargon with clear, friendly terms:

- **Portfolio** is now **Fortune**
- **P&L** is now **Gains**
- **Unrealized P&L** is now **Current Gains**
- **Place Order** is now **Invest**
- **Stop Loss** is now **Loss Protection**
- **Take Profit** is now **Profit Target**
- **Avg Cost** is now **Buy Price**
- **Market Value** is now **Current Value**
- **Capital Allocation** is now **Your Money**
- **Risk Metrics** is now **Risk Overview**
- **Quota Failed** is now **Run Over**
- **Quota Met** is now **Objective Met!**
- Buy/Short buttons now simply say **BUY** and **SHORT** (no more "BUY LONG" / "SELL SHORT")

All changes are reflected in both English and French.

---

## Expert Mode

A new toggle in Settings lets you switch between casual and expert views:

- **Casual mode (default):** Clean, simplified interface showing only what matters
- **Expert mode:** Full trading platform experience with all indicators

### What Expert Mode reveals:
- **Trading screen:** Fee breakdown (subtotal + fee rows)
- **Stock info:** Market Cap, P/E Ratio, Trading Stats (Open/High/Low/Volume), Analyst Ratings, Technical Analysis (RSI, MA50, MA200), Historical Performance, 52-Week Range, Characteristics
- **Positions:** Average cost and market value columns
- **Dashboard:** Concentration risk, largest position details
- **Sector info:** Volatility, market correlation, Fed sensitivity
- **Portfolio panel:** Trading stats breakdown, portfolio breakdown details

---

## Visual Improvements

- **Streak banners:** When you hit a 3+ win streak, a glowing green banner with fire emojis appears in your dashboard. Lose streaks of 3+ get a skull banner too
- **Cleaner position cards:** Casual mode shows just shares, current price, gains, and gain % — no clutter

---

## Localized Market Indicators

All market indicators are now fully translated (EN + FR) instead of being hardcoded in English:

- **Market Regime:** Strong Bull / Bull / Neutral / Bear / Strong Bear labels and descriptions (e.g. "Extreme optimism — buy everything!" / "Optimisme extrême — achetez tout !")
- **Fear & Greed Index:** 5 tiers (Extreme Greed, Greed, Neutral, Fear, Extreme Fear) with actionable tips per tier
- **Analyst Ratings:** Strong Buy / Strong Sell consensus labels
- **Midday News:** Prefixes (Update, Correction, Breaking, Reversal, Recovery) now localized

---

## Informant Tips in News Feed

When you purchase an informant tip, it now appears as a news item in your feed:
- Distinct purple badge to distinguish from market/company news
- Shows the stock name and bullish/bearish direction
- No impact on price — purely informational for your records

---

## Prestige Point Rebalance

Achievement PP rewards have been slowed down to make daily PP earnings feel more meaningful:

| Tier | Before | After |
|------|--------|-------|
| Bronze 1-2 | 1, 2 | 1, 1 |
| Silver 3-4 | 3, 5 | 2, 3 |
| Gold 5-6 | 8, 12 | 5, 8 |
| Platinum 7-8 | 20, 30 | 15, 25 |
| Diamond 9-10 | 50, 100 | 40, 75 |

Total from achievements: ~5,095 PP (down from ~6,730, ~24% reduction). Early tiers hit hardest so the first upgrades require more gameplay to unlock.

---

## Robot Trader Improvements

### Removed Stock Assignment
Robots no longer need to be assigned to a specific stock. Each trade, the robot automatically picks a random unlocked company — simpler and better diversified.

### New Fund Dialog
Replaced the old percentage-based funding with a manual amount input:
- **Text field** for typing any amount
- **Quick-add buttons:** +$100, +$500, +$1K, +$5K, MAX
- Shows current budget, max budget, and available cash
- Amount is clamped to what you can actually fund

### UI Cleanup
- Robot cards show **Active** (green badge) or sleeping status instead of company name
- Removed assign button entirely — one less step to get your robot running

---

## Skip Quota

You can now pay your quota early! When your progress meets the target:
- A pulsing **SKIP** button appears on the day/progress cards
- Pays the quota immediately and restarts the cycle
- Bonus: 15% on excess (vs 10% at end of cycle) — rewarding proactive play
- Two new prestige upgrades boost the skip bonus further (Early Bird Bonus, Overachiever)

---

## Game Speed Control

A speed button next to play/pause lets you control game pace:
- Cycles through **1x → 2x → 3x** on tap
- Visible on both the progress card and day card
- Hidden when market is closed (end of day)

---

## Quality of Life

- All French translations updated to match the new casual vocabulary
- Settings toggle persists between sessions
- Expert mode can be toggled at any time without losing data

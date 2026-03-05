# KANDL - Hotfix 2

**Date:** 2026-02-10
**Version:** 0.12

---

## Bug Fixes

### Robots
- Fixed a bug where buying one robot slot prestige upgrade would unlock all slots at once
- Starter companies now correctly appear in the robot assignment list
- Robots assigned to a company that becomes locked after a new year are now automatically unassigned
- Robot assignment now properly checks that the target company is unlocked
- Fixed an issue where upgrading a robot stat could deduct cash without applying the upgrade
- Fixed "Deep Pockets" prestige bonus not stacking correctly across multiple purchases

### Sound
- Fixed sound effects not playing reliably on Android when tapping rapidly

### Achievements
- Fixed achievements not being saved between sessions, allowing players to re-earn the same achievements and farm prestige points
- Achievement progress now persists across app restarts
- Achievements are only reset when the full save is deleted

---

## New Features

### Skip Quota Early
- A new "SKIP QUOTA" button appears when your quota progress reaches the target
- Pay the quota early and receive a 15% bonus on the excess amount (instead of 10% at period end)
- Two new prestige upgrades increase this bonus: "Early Bird Bonus" (+10%) and "Overachiever" (+15%), up to 40% total

### Game Speed
- New speed button next to play/pause: tap to cycle through 1x, 2x, and 3x speed
- Hidden when the market is closed

### News Rebalance
- News events now have variable impact strength instead of always being high
- Most news will have a mild effect on prices, with only rare news causing major swings
- Gameplay-affecting events (trading bans, bonuses, etc.) keep their full impact

### Position Sizing Restrictions
- A new market event can temporarily limit trades to 100 shares for 2 days
- Market events become slightly more frequent as you progress through the run

### Informant Tips in News Feed
- Buying a tip from the secret informant now adds a visible entry in the news feed
- Informant news appears in a distinct purple color
- Shows the company name, direction (bullish/bearish), and the tip message

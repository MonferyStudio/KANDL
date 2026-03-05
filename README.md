# KANDL

A roguelike stock trading idle game built with Flutter.

## About

KANDL is a single-player incremental game where you trade stocks across 16 market sectors, manage a growing portfolio, and progress through prestige cycles with escalating financial targets. Values scale from humble dollars to absurdly large numbers using a custom BigNumber system.

## Features

- **192 companies** across 16 sectors (Tech, Healthcare, Energy, Finance, etc.), each with realistic names and pricing
- **4-tier volatility system** — Starter, Standard, Premium, Elite — affecting price swings and news frequency
- **Real-time trading** — buy/sell stocks, track positions, monitor P&L
- **News system** — dynamic market events that impact stock prices, weighted by company tier
- **Upgrade system** — 29 upgrades (static + sector-specific templates) with rarity tiers, daily popup picks and a permanent shop
- **Prestige mechanic** — reset your run with prestige points to unlock permanent bonuses (Luck Boost, Reroll Boost, Sector Amplifier, Market Titan, etc.)
- **Daily challenges** — randomized objectives with portfolio-proportional rewards
- **296 achievements** across multiple categories
- **FinTok feed** — in-game social media parody with trading tips
- **Informant system** — contextual hints and market insights
- **Responsive UI** — works on mobile, tablet and desktop with adaptive navigation
- **Localization** — English and French
- **Web build** — deployable to itch.io with custom post-processing for asset compatibility

## Tech Stack

- **Framework**: Flutter / Dart
- **State Management**: Provider (ChangeNotifier)
- **Architecture**: Service-based (GameService, TutorialService, AchievementService, SettingsService, SaveService)
- **Financial Values**: Custom `BigNumber` class for arbitrarily large numbers
- **Platforms**: Web, Android, Windows,

## License

This project is proprietary. All rights reserved.

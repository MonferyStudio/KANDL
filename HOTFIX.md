# KANDL - Hotfix Notes

**Date:** 2026-02-10
**Version:** 1.0.2

---

## Bug Fixes

### Navigation - Back button in stocks section
- Fixed the back button in the market/stocks view not returning to the sector list
- Navigation flow: Dashboard > Sectors > Stocks > Trading (back steps through each level)

### Secret Informant - Showing locked companies
- The informant was giving tips about companies the player hadn't unlocked yet
- Now only unlocked companies are eligible for informant tips

### Tablet/Portrait display - Cropped popups
- All popup dialogs (news, upgrades, prestige shop, informant, mid-day news) now use responsive constraints based on screen size
- Popups scale down properly on smaller screens and tablets in portrait mode instead of being cropped

### Short position cost preview
- Fixed the order preview for short positions: fees were being subtracted from the total instead of added
- Short and long positions now both correctly show `cost + fees` as the total

### Long/Short same position conflict
- `buy()`, `sell()`, and `canSell()` now correctly filter by `PositionType.long`, matching how `short()` and `cover()` already filter by `PositionType.short`
- Players can now hold both a long and short position on the same company without interference

### Duplicate upgrades in rolls
- Daily upgrade popup and permanent shop no longer show the same upgrade twice in the same roll
- Added `excludeIds` parameter to `generateRandomUpgrade()` to prevent duplicates within a generation set

### Comma to period conversion
- Typing a comma in the share quantity input now auto-converts it to a period (decimal separator)
- Fixes input issues for users with European keyboard layouts

---

## New Features

### Prestige tier unlock redesign
- "Insider Access" now unlocks the standard tier of a **random sector** (instead of all standard companies)
- "Elite Network" now unlocks the premium tier of a **random sector**
- "Market Titan" (new tier 3) unlocks the elite tier of a **random sector**
- Removed "Global Trader" upgrade (redundant with new system)
- Each run picks a different random sector, adding roguelike variety

### Sell/Cover button on trading positions
- Added a direct sell (long) or cover (short) button next to each active position in the trading view
- Opens a quick close dialog with share input and confirmation
- No longer necessary to navigate to the portfolio view to close a position

### Sell All button on portfolio
- Added "Close All Positions" button in the portfolio summary card
- Confirmation dialog before executing
- Closes all long and short positions at market price in one action

### Company/Sector badges in news
- News items now display a colored badge showing the affected company name or sector icon
- Company-specific news shows the company name in a colored chip
- Sector-wide news shows the sector emoji + name with the sector's color

### Sound effects system
- Added `SoundService` with 5 sound effects: click, buy, sell, money, notification
- Sound toggle available in the settings menu
- Sounds wired to key game actions:
  - **Click** sound: satisfying pop effect (next day, upgrade selection, shop pick, news continue)
  - **Buy** sound: opening a long position
  - **Sell** sound: ascending 3-note chime (opening a short, selling/covering a position)
  - **Money** sound: prestige upgrade purchase
  - **Notification** sound: all in-game notifications (price alerts, news, achievements, etc.)

### Year transition resets
- All news items cleared when advancing to a new year
- Multi-day events reset between years (no carryover)
- Short selling bans reset between years
- All FinTok influencers and tips reset between years
- All notifications cleared on year transition

### Missing translations (EN + FR)
- Portfolio: close_all_positions, close_all_confirm, closed_all_positions, close_all
- Informant: secret_informant, send_away, purchased, sentiment_bullish, sentiment_bearish
- Trading: bonus_shares, total_shares_label
- Prestige: unlock_tier_3 (Market Titan / Titan du Marche)
- News events: data_glitch, algo_confusion, sector_rotation, whale_activity (FR)
- Sound settings label (FR)
- Replaced hardcoded strings in informant_popup.dart, trading_view.dart, info_panel.dart

---

## Files Modified

- `lib/services/game_service.dart` - Back button fix, informant filter, long/short position dissociation, closeAllPositions(), year reset logic, prestige tier effects, duplicate upgrade prevention
- `lib/services/notification_service.dart` - Notification sound integration
- `lib/services/sound_service.dart` - **NEW** Sound effects service
- `lib/data/prestige_upgrades.dart` - Tier unlock redesign (random sector), removed Global Trader
- `lib/data/upgrades.dart` - excludeIds parameter for duplicate prevention
- `lib/widgets/trading_view/trading_view.dart` - Sell/cover button, short fee fix, comma conversion, buy/sell sounds, translation fixes
- `lib/widgets/positions_view/positions_view.dart` - Sell all button + confirmation dialog, sell sound on close
- `lib/widgets/news_popup/news_popup.dart` - Company/sector badges, responsive + click sound
- `lib/widgets/news_popup/mid_day_news_popup.dart` - Company/sector badges, responsive
- `lib/widgets/informant/informant_popup.dart` - Responsive + localized hardcoded strings
- `lib/widgets/info_panel/info_panel.dart` - Localized BEST and Days labels
- `lib/widgets/upgrade_popup/upgrade_popup.dart` - Responsive + click sound
- `lib/widgets/upgrade_shop/upgrade_shop.dart` - Click sound on pick
- `lib/widgets/prestige_shop/prestige_shop.dart` - Responsive + money sound
- `lib/widgets/hero_cards/day_card.dart` - Click sound on next day
- `lib/widgets/hero_cards/progress_card.dart` - Click sound on next day
- `lib/widgets/settings_menu/settings_menu.dart` - Sound toggle
- `lib/screens/home_screen.dart` - Clear notifications on year end
- `lib/l10n/app_localizations.dart` - New translation keys (EN + FR)
- `lib/main.dart` - SoundService provider
- `pubspec.yaml` - audioplayers dependency + sound assets
- `assets/sounds/` - **NEW** 5 WAV sound files (click, buy, sell, money, notification)

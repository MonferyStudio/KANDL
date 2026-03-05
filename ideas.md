# KANDL — Ideas Bank

> Brainstorm ideas for future features. Nothing here is committed to implementation.
> Status: `idea` | `exploring` | `planned` | `shelved`

---

## 1. Mailbox / Inbox System — `exploring`

### Concept

Replace the current "secret informant" with a full inbox system. The player receives
various types of emails throughout the game. The mailbox becomes the central
communication hub — every game event that needs the player's attention goes through it.

### UI Design

**Main screen:** Envelope icon in the top bar with unread count badge (red dot + number).

**Inbox view:** Full-screen overlay or slide-in panel.
- List of emails sorted by date (newest first)
- Each row: sender icon/avatar, sender name, subject line, age ("2d ago"), unread dot
- Swipe left to delete/archive, tap to open
- Filter tabs at top: All | Urgent | Tips | Official

**Email detail view:**
- Header: sender name + icon, subject, date
- Body: 2-4 lines of text (keep it short, this is a game not Outlook)
- Action buttons at bottom (context-dependent): "Invest Now", "Pay Tax", "Ignore", "Report Scam"
- Some mails auto-expire (visual timer bar at top of the mail)

**Mobile:** Full-screen views with back navigation.
**Desktop:** Slide-in panel from right side (doesn't cover the whole game).

### Mail Types — Detailed

#### A. Market Tips (replaces Secret Informant)

The informant becomes an anonymous sender ("???", "Deep Throat", "The Insider").

| Quality | Description | Accuracy | Frequency |
|---------|-------------|----------|-----------|
| Vague | "A sector might move soon..." | ~50% | Common |
| Decent | "Tech looks bullish this week" | ~70% | Regular |
| Precise | "Energy will crash tomorrow, -15%" | ~90% | Rare |
| Perfect | "BUY [Company] NOW. Trust me." | 100% | Very rare, late game |

- Quality depends on: prestige nodes, upgrades, game progression
- Tip mails expire after X days (the info becomes stale)
- Action button: "View Sector" (jumps to that sector's stocks)

#### B. Scam Emails

Look similar to tips but are traps. The player must learn to spot them.

**Red flags the player learns to recognize:**
- Sender name is slightly off ("The Insidder", "D33p Throat")
- Too-good-to-be-true promises ("GUARANTEED 500% RETURN")
- Urgent pressure ("ACT NOW OR LOSE EVERYTHING")
- Asking for money upfront ("Send $500 processing fee to unlock insider trade")
- Bad grammar / weird formatting

**Consequences of falling for a scam:**
- Lose a flat amount ($100-$1000 depending on game stage)
- Or: a position gets auto-bought at a bad price
- Or: nothing happens but you wasted an action/day

**Progression:** Early game has obvious scams. Late game scams are subtle and harder to spot.

**Prestige node "Spam Filter":** Auto-marks obvious scams with a warning banner.
**Upgrade "Scam Detector Lv1-3":** Progressively highlights more subtle red flags.

#### C. Tax Notices (ties into Tax System, see #2)

Official-looking mails from "KANDL Revenue Service" or "KRS".
- Subject: "Tax Notice — Q1 Assessment: $X,XXX due"
- Body: breakdown of taxable amount, rate applied, deadline
- Action button: "Pay Now" (if you have the cash) or "View Details"
- Deadline countdown visible in the mail
- Reminder mails sent at 7 days, 3 days, 1 day before deadline
- After deadline: penalty notice mail arrives

#### D. Opportunities

Limited-time investment offers that create urgency.

- **IPO Invitation:** "New company [X] launching in sector [Y]. Buy shares at $Z before public listing." — Timer, potential big gain or loss
- **Fire Sale:** "Trader liquidating portfolio. [Sector] stocks at 30% discount for 2 days." — Guaranteed discount
- **Insider Deal:** "Quiet merger happening. Company [X] about to double." — High risk, high reward, might be real or scam
- **Flash Crash Recovery:** "Market overcorrected. [Sector] is undervalued." — Usually accurate

Opportunities expire. Missing them has no penalty, but catching good ones gives an edge.

#### E. News Alerts

Market-moving events delivered as breaking news emails.

- "BREAKING: Regulatory crackdown on Crypto sector"
- "MARKET ALERT: Bull run detected in Technology"
- "WARNING: Economic downturn indicators rising"

These replace or supplement the current event system. The difference from tips:
news is always true but by the time you read it, the market may have already moved.
Tips predict the future; news reports the present.

#### F. Ransom / Threat Mails (absorbs Hacking concept)

Instead of a mini-game, hacking becomes a mail-based choice:

- "We have access to your portfolio. Pay $2,000 or we sell your [Sector] positions."
- Choice: **Pay** (lose cash, guaranteed safe) or **Ignore** (70% nothing happens, 30% they actually do it)
- Frequency scales with portfolio size (big target = more threats)
- Prestige node "Firewall": reduces frequency. "Insurance": recover losses if hacked.

### Mail Generation Rules

- **Max 3-5 unread mails at a time.** If inbox is full, no new non-urgent mails generate.
- **Tax mails bypass the cap** (always delivered).
- **1-2 mails per in-game day** on average. Not every day.
- **Scam ratio:** starts at 10% of mails, increases to 30% as portfolio grows.
- **Tip quality:** base 50% vague, improved by upgrades/prestige.

### Upgrades (in-run, buyable with cash)

| Upgrade | Effect | Cost scaling |
|---------|--------|-------------|
| Scam Detector I | Highlights 1 red flag per scam mail | $ |
| Scam Detector II | Highlights all red flags | $$ |
| Scam Detector III | Auto-deletes obvious scams | $$$ |
| Priority Inbox | Moves high-value tips to top | $$ |
| Fast Reader | Mail actions cost 0 days (normally 1?) | $$$ |
| Tip Network | +1 tip mail per day | $$ |

### Prestige Nodes (talent tree — new "Intelligence" branch)

| Node | Effect | PP Cost |
|------|--------|---------|
| Spam Filter | Auto-flags 50% of scams | 3 |
| Deep Network | Tips are 1 tier more accurate | 5 |
| Verified Sources | Scam rate -50% | 8 |
| Insider Access | 1 guaranteed "Precise" tip per run | 12 |
| Information Broker | Can sell bad tips for cash | 6 |
| Counter-Intel | Ransom threats have 0% success rate | 10 |
| Priority Clearance | Tax deadline extended +5 days | 8 |

### Data Model Sketch

```
Mail {
  id: String
  type: MailType (tip, scam, tax, opportunity, news, threat)
  sender: String
  senderIcon: String (emoji)
  subject: String
  body: String
  receivedDay: int (game day)
  expiresDay: int? (null = no expiry)
  isRead: bool
  isActioned: bool
  isScam: bool (hidden from player unless detected)
  actions: List<MailAction> (label + callback key)
  metadata: Map<String, dynamic> (sector, amount, deadline, etc.)
}
```

### Save/Load

```json
"mailbox": {
  "mails": [...],
  "totalReceived": 42,
  "scamsFallenFor": 3,
  "scamsDetected": 7
}
```

---

## 2. Tax System — `exploring`

### Concept

The player must pay taxes on their trading profits. Tax notices arrive via the
mailbox with a deadline. This adds economic pressure and prevents infinite cash
hoarding. Taxes scale with progression — trivial early, significant late game.

### Core Mechanics

#### Tax Schedule

Taxes are assessed **quarterly** (every 90 in-game days):
- Q1: Day 90 — covers days 1-90
- Q2: Day 180 — covers days 91-180
- Q3: Day 270 — covers days 181-270
- Q4: Day 360 — covers days 271-360 (end of year/run)

**Timeline per tax cycle:**
1. Day X: Tax notice arrives in mailbox (assessment)
2. Days X to X+14: Payment window (14 days to pay)
3. Day X+14: Deadline. Unpaid = penalties begin.

#### Tax Calculation

```
Taxable Amount = Total realized profit this quarter
               - Realized losses (deductible)
               - Deductions (from upgrades/prestige)

Tax Owed = Taxable Amount * Tax Rate
```

**Progressive tax brackets:**

| Quarterly Profit | Rate | Example |
|-----------------|------|---------|
| $0 - $500 | 0% | Grace bracket, beginners pay nothing |
| $501 - $2,000 | 10% | Early game, light pressure |
| $2,001 - $10,000 | 20% | Mid game, meaningful cost |
| $10,001 - $50,000 | 30% | Late game, strategic planning needed |
| $50,001+ | 40% | Endgame, serious drain |

**First run:** No taxes at all (tutorial grace). Taxes start from run 2+.
**First quarter of each run:** Reduced rate (50% off) as a warmup.

#### Payment

- "Pay Now" button in the tax mail. Deducts cash instantly.
- Can also pay from the main portfolio screen (tax widget visible during payment window).
- **Partial payment:** allowed. Pay what you can, remaining accrues penalty.
- **Overpayment:** not possible (exact amount only).

#### Failure to Pay — Graduated Consequences

| Days Late | Consequence |
|-----------|-------------|
| 1-7 | **Interest:** +5% per day on unpaid amount |
| 8-14 | **Asset Freeze:** Can't buy new stocks (can still sell) |
| 15-21 | **Forced Liquidation:** Game auto-sells cheapest positions to cover debt |
| 22+ | **Audit:** All profits reduced by 50% for rest of quarter |

The player is NEVER game-over'd by taxes alone. The penalties are painful but
survivable. The pressure comes from wanting to avoid them.

#### Tax Events (random, arrive via mailbox)

| Event | Effect | Frequency |
|-------|--------|-----------|
| Tax Amnesty | Skip one tax payment entirely | Very rare (1 per 3-4 runs) |
| Audit Notice | Next tax is calculated on gross (no loss deduction) | Rare |
| Tax Holiday | One sector is tax-exempt this quarter | Occasional |
| Double Tax | Tax rate +10% this quarter (regulatory change) | Rare |
| Rebate | Get back 20% of last tax paid | Occasional |

### Deductions & Optimization

The player can strategically reduce their tax burden:

**Automatic deductions:**
- Trading losses offset gains (already in formula)
- Robot operating costs are deductible (upgrade costs paid this quarter)

**Upgrade-based deductions:**

| Upgrade | Effect | Cost |
|---------|--------|------|
| Tax Accountant I | -5% tax rate | $$ |
| Tax Accountant II | -10% tax rate | $$$ |
| Tax Accountant III | -15% tax rate | $$$$ |
| Loss Harvesting | Can deduct unrealized losses too | $$$ |
| Expense Account | Robot costs count as 2x deduction | $$ |

**Prestige nodes:**

| Node | Effect | PP |
|------|--------|----|
| Tax Attorney | -10% base tax rate | 5 |
| Offshore Account | Payment deadline +7 days | 4 |
| Creative Accounting | Losses count as 1.5x deduction | 8 |
| Tax Shelter | First $1000 profit is always tax-free | 6 |
| IRS Insider | See next quarter's tax events in advance | 10 |
| Diplomatic Immunity | 1 free tax skip per run | 15 |

### Strategic Depth

Taxes create interesting decisions:

1. **Spend before tax day:** Buy upgrades/robots before the quarter ends to reduce
   taxable profit (upgrade costs = deductions). This naturally encourages reinvestment.

2. **Time your sells:** Sell losing positions before quarter end to offset gains.
   Classic tax-loss harvesting — a real financial concept made into gameplay.

3. **Sector tax holidays:** When a sector is tax-exempt, pivot hard into it.
   Ties into the sector mastery prestige tree.

4. **Cash reserves:** Keep enough cash to pay taxes. If you're fully invested,
   you might need to sell at a loss to cover the bill.

5. **Risk vs. safety:** Big gains = big taxes. Sometimes moderate gains are
   more efficient than huge swings.

### UI Elements

**In mailbox:** Tax notice with breakdown, Pay button, countdown timer.

**On main screen (during payment window):**
- Small tax banner at top: "TAX DUE: $X,XXX — Y days remaining"
- Color coding: green (>7 days), yellow (3-7 days), red (<3 days)
- Tap banner to jump to tax mail

**Tax history (optional, in settings/stats):**
- Total taxes paid this run
- Total penalties paid
- Deductions used
- Effective tax rate

### Data Model Sketch

```
TaxAssessment {
  quarter: int (1-4)
  assessedDay: int
  deadlineDay: int
  grossProfit: BigNumber
  deductions: BigNumber
  taxableAmount: BigNumber
  taxRate: double
  taxOwed: BigNumber
  amountPaid: BigNumber
  isPaid: bool
  isOverdue: bool
  penalties: BigNumber
}
```

### Save/Load

```json
"taxes": {
  "currentAssessment": {...},
  "history": [...],
  "totalTaxesPaid": 15000,
  "totalPenalties": 500,
  "taxFreeBracketUsed": false
}
```

---

## 3. Fictitious Leaderboard — `idea` (later)

**Concept:** A fake global leaderboard showing the player among ~20-50 AI-generated
"traders" on the KANDL platform. Player starts at the very bottom.

**Core mechanics:**
- Each fake trader has: username, avatar/icon, net worth, rank, optional badge
- AI traders' wealth evolves over time (some grow, some crash, some stay flat)
- Player climbs the leaderboard as their portfolio grows
- Milestones: top 50, top 20, top 10, podium

**Influencer system:**
- Some traders have an "influencer" badge
- Can affect market sentiment, player can follow/interact via mailbox

**Personalities (examples):**
- "CryptoKing420" — Volatile, huge swings, always in crypto
- "SteadyEddie" — Slow and steady, diversified, hard to overtake
- "WallStreetWolf" — Aggressive, high risk, occasionally crashes
- "GreenEnergy_Sarah" — All-in on energy/utilities
- "BotTrader9000" — Suspiciously consistent gains

**Deferred:** Build mailbox + taxes first, then add leaderboard as a content update.
Leaderboard NPCs will naturally use the mailbox to send DMs, trash talk, offers.

---

## ~~4. Hacking / Cybersecurity Mini-game~~ — `shelved`

> **Decision:** Absorbed into the mailbox system as "threat/ransom mails" (see Mail
> Type F above). No separate mini-game — it breaks the trading flow. The tension of
> "pay or risk it" works better as a simple choice in a mail than as an interactive
> puzzle.

---

## Mailbox + Taxes — How They Work Together

### Timeline of a Typical Quarter

```
Day 1-89:  Trading as usual. Tips, scams, opportunities arrive via mail.
Day 85:    [MAIL] "Q1 Tax Estimate: Based on current profits, expect ~$X,XXX"
Day 90:    [MAIL] "Q1 Tax Assessment: $X,XXX due. Deadline: Day 104."
Day 90-97: Player has 7+ days. Banner is green. Can keep trading.
Day 97:    [MAIL] Reminder: "7 days until tax deadline"
Day 100:   Maybe a tax event mail arrives: "Tax Holiday on Energy sector!"
Day 101:   [MAIL] Reminder: "3 days left. You have $Y,YYY in cash."
Day 103:   [MAIL] URGENT: "1 day left! Pay $X,XXX now or face penalties."
Day 104:   Deadline. Auto-check: paid? If not, penalties begin.
Day 105+:  [MAIL] "OVERDUE: Interest accruing. Pay immediately."
Day 111:   [MAIL] "FINAL WARNING: Asset freeze in 3 days."
Day 114:   Asset freeze kicks in. Can't buy. Forced sells start day 119.
```

### Shared Prestige Branch: "Intelligence"

Both systems feed into the same prestige branch:

```
Intelligence Root
├── Spam Filter (scam detection)
├── Deep Network (better tips)
│   ├── Verified Sources (-50% scams)
│   └── Insider Access (1 precise tip/run)
├── Tax Attorney (-10% tax rate)
│   ├── Offshore Account (+7 days deadline)
│   ├── Creative Accounting (1.5x loss deduction)
│   └── Diplomatic Immunity (1 free skip/run)
├── Counter-Intel (ransom immune)
└── Information Broker (sell bad tips)
```

### Shared Upgrades (in-run)

Some upgrades benefit both systems:

| Upgrade | Mailbox Effect | Tax Effect |
|---------|---------------|------------|
| Financial Advisor | Tips +1 quality tier | Tax deductions +10% |
| Accountant | Scam detection hints | Tax calculated accurately (see true rate) |
| Lawyer | Can "contest" 1 scam/run (get money back) | Can appeal 1 tax penalty/run |

---

## Implementation Priority

### Wave 1: Mailbox + Taxes (tightly coupled)
1. **Mail data model** + basic inbox UI (list + detail view)
2. **Tip mails** (replace informant)
3. **Scam mails** (basic, obvious ones first)
4. **Tax calculation engine** (quarterly, brackets, deductions)
5. **Tax notice mails** (generation + payment flow)
6. **Penalty system** (graduated consequences)
7. **In-run upgrades** (scam detector, tax accountant)
8. **Prestige nodes** (Intelligence branch in talent tree)
9. **Tax events** (amnesty, audit, holiday)
10. **Advanced scams** (subtle late-game ones)

### Wave 2: Leaderboard (standalone content)
- NPC traders + personalities
- Leaderboard UI
- NPC interaction via mailbox
- Influencer system

---

*Last updated: 2026-02-12*

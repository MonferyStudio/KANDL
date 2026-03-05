import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/informant.dart';
import '../../services/game_service.dart';
import '../../theme/app_themes.dart';
import '../../data/informant_data.dart';
import '../../l10n/app_localizations.dart';

/// Popup dialog when the secret informant visits
class InformantPopup extends StatelessWidget {
  const InformantPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);

    return Consumer<GameService>(
      builder: (context, game, _) {
        final tips = game.currentInformantTips;
        final greeting = informantGreetings[game.currentDay % informantGreetings.length];

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: (MediaQuery.of(context).size.width - 48).clamp(0, 420),
            constraints: BoxConstraints(
              maxHeight: (MediaQuery.of(context).size.height - 80).clamp(0, 550),
            ),
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.purple.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.purple.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.purple.withValues(alpha: 0.2),
                          border: Border.all(
                            color: theme.purple,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text('🕵️', style: TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.get('secret_informant'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.purple,
                              ),
                            ),
                            Text(
                              greeting,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Tips list
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: tips.length,
                    itemBuilder: (context, index) {
                      final isFree = game.freeTipsRemaining > 0 && !tips[index].purchased;
                      return _TipCard(
                        tip: tips[index],
                        canAfford: isFree || game.cash.toDouble() >= tips[index].price,
                        isFree: isFree,
                        showExactPercent: game.tipExactPercent,
                        onPurchase: () {
                          game.purchaseInformantTip(tips[index].id);
                        },
                      );
                    },
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Cash: \$${game.cash.toDouble().toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.positive,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          game.dismissInformant();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          l10n.get('send_away'),
                          style: TextStyle(color: theme.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TipCard extends StatelessWidget {
  final InformantTip tip;
  final bool canAfford;
  final bool isFree;
  final bool showExactPercent;
  final VoidCallback onPurchase;

  const _TipCard({
    required this.tip,
    required this.canAfford,
    required this.onPurchase,
    this.isFree = false,
    this.showExactPercent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final reliabilityColor = _getReliabilityColor(tip.reliability, theme);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: tip.purchased
              ? theme.positive.withValues(alpha: 0.5)
              : theme.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: reliabilityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  showExactPercent
                      ? '${(tip.actualAccuracy * 100).toStringAsFixed(0)}%'
                      : tip.reliabilityLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: reliabilityColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.cyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tip.typeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.cyan,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                tip.stockName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.accent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Message
          Text(
            tip.purchased ? tip.secretMessage : tip.message,
            style: TextStyle(
              fontSize: 13,
              color: tip.purchased ? theme.textPrimary : theme.textSecondary,
              fontStyle: tip.purchased ? FontStyle.normal : FontStyle.italic,
            ),
          ),

          const SizedBox(height: 12),

          // Purchase button or purchased indicator
          if (tip.purchased)
            Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: theme.positive),
                const SizedBox(width: 6),
                Text(
                  l10n.get('purchased'),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.positive,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tip.isBullish
                        ? theme.positive.withValues(alpha: 0.2)
                        : theme.negative.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tip.isBullish ? '📈 ${l10n.get('sentiment_bullish')}' : '📉 ${l10n.get('sentiment_bearish')}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: tip.isBullish ? theme.positive : theme.negative,
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                if (isFree)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.positive.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'FREE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.positive,
                      ),
                    ),
                  )
                else
                  Text(
                    '\$${tip.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: canAfford ? theme.positive : theme.negative,
                    ),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: canAfford ? onPurchase : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFree ? theme.positive : theme.purple,
                    disabledBackgroundColor: theme.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    canAfford ? (isFree ? 'Claim Free' : 'Buy Info') : 'Can\'t Afford',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: canAfford ? Colors.white : theme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Color _getReliabilityColor(InformantReliability reliability, AppThemeData theme) {
    switch (reliability) {
      case InformantReliability.questionable:
        return theme.textMuted;
      case InformantReliability.decent:
        return theme.cyan;
      case InformantReliability.reliable:
        return theme.positive;
      case InformantReliability.impeccable:
        return theme.purple;
    }
  }
}

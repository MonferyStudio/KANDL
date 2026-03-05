import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/influencers.dart';
import '../../l10n/app_localizations.dart';
import '../../models/influencer.dart';
import '../../services/game_service.dart';
import '../../theme/app_themes.dart';

/// Main FinTok panel showing influencers and their tips
class FinTokPanel extends StatelessWidget {
  const FinTokPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);

    return Consumer<GameService>(
      builder: (context, game, _) {
        final influencers = game.activeInfluencers;
        final tips = game.recentTips;

        if (influencers.isEmpty && tips.isEmpty) {
          return _EmptyState(theme: theme, l10n: l10n);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(
                    'FinTok',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.positive.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${influencers.length} ${l10n.fintokActive}',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.positive,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Influencer avatars row
            if (influencers.isNotEmpty)
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: influencers.length,
                  itemBuilder: (context, index) {
                    final inf = influencers[index];
                    return _InfluencerAvatar(
                      influencer: inf,
                      isFollowed: game.isFollowingInfluencer(inf.id),
                      onTap: () => _showInfluencerProfile(context, inf, game),
                    );
                  },
                ),
              ),

            const Divider(height: 1),

            // Tips feed
            Expanded(
              child: tips.isEmpty
                  ? Center(
                      child: Text(
                        l10n.fintokNoTips,
                        style: TextStyle(
                          color: theme.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: tips.length,
                      itemBuilder: (context, index) {
                        return _TipCard(
                          tip: tips[index],
                          influencer: game.getInfluencerById(tips[index].influencerId),
                          l10n: l10n,
                          flagBadTips: game.flagBadTips,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showInfluencerProfile(BuildContext context, Influencer influencer, GameService game) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final followed = game.isFollowingInfluencer(influencer.id);
          return AlertDialog(
            backgroundColor: theme.card,
            title: Row(
              children: [
                Text(
                  influencer.avatar,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        influencer.name,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        influencer.handle,
                        style: TextStyle(
                          color: theme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getInfluencerBio(influencer.id, l10n.locale.languageCode).isNotEmpty
                      ? getInfluencerBio(influencer.id, l10n.locale.languageCode)
                      : influencer.bio,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                _ProfileStat(
                  label: l10n.fintokFollowers,
                  value: influencer.followerCount,
                  theme: theme,
                ),
                _ProfileStat(
                  label: l10n.fintokTipsGiven,
                  value: influencer.totalTips.toString(),
                  theme: theme,
                ),
                _ProfileStat(
                  label: l10n.fintokAccuracy,
                  value: influencer.totalTips > 0
                      ? '${(influencer.displayedAccuracy * 100).toStringAsFixed(0)}%'
                      : l10n.fintokUnknown,
                  valueColor: _getAccuracyColor(influencer.displayedAccuracy, theme),
                  theme: theme,
                ),
                _ProfileStat(
                  label: l10n.fintokReputation,
                  value: _getTipQualityLabel(influencer.tipQuality, l10n),
                  valueColor: _getQualityColor(influencer.tipQuality, theme),
                  theme: theme,
                ),
                if (followed)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 14, color: theme.cyan),
                        const SizedBox(width: 4),
                        Text(
                          l10n.fintokFollowing,
                          style: TextStyle(color: theme.cyan, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  game.toggleFollowInfluencer(influencer.id);
                  setDialogState(() {});
                },
                child: Text(
                  followed ? l10n.fintokUnfollow : l10n.fintokFollow,
                  style: TextStyle(color: followed ? theme.negative : theme.cyan),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.close,
                  style: TextStyle(color: theme.accent),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getAccuracyColor(double accuracy, AppThemeData theme) {
    if (accuracy >= 0.6) return theme.positive;
    if (accuracy >= 0.4) return theme.orange;
    return theme.negative;
  }

  Color _getQualityColor(TipQuality quality, AppThemeData theme) {
    switch (quality) {
      case TipQuality.excellent:
        return theme.positive;
      case TipQuality.good:
        return theme.cyan;
      case TipQuality.average:
        return theme.orange;
      case TipQuality.poor:
        return theme.negative;
      case TipQuality.terrible:
        return theme.negative;
    }
  }

  String _getTipQualityLabel(TipQuality quality, AppLocalizations l10n) {
    switch (quality) {
      case TipQuality.excellent:
        return l10n.fintokExcellent;
      case TipQuality.good:
        return l10n.fintokGood;
      case TipQuality.average:
        return l10n.fintokAverage;
      case TipQuality.poor:
        return l10n.fintokPoor;
      case TipQuality.terrible:
        return l10n.fintokTerrible;
    }
  }
}

class _EmptyState extends StatelessWidget {
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _EmptyState({required this.theme, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '📱',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            'FinTok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.fintokNoInfluencers,
            style: TextStyle(
              color: theme.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.fintokAppearSoon,
            style: TextStyle(
              color: theme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfluencerAvatar extends StatelessWidget {
  final Influencer influencer;
  final bool isFollowed;
  final VoidCallback onTap;

  const _InfluencerAvatar({
    required this.influencer,
    required this.isFollowed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final accuracyColor = influencer.totalTips > 0
        ? (influencer.displayedAccuracy >= 0.5 ? theme.positive : theme.negative)
        : theme.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: 8),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.surface,
                    border: Border.all(
                      color: accuracyColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      influencer.avatar,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                if (isFollowed)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.cyan,
                        border: Border.all(color: theme.surface, width: 1.5),
                      ),
                      child: const Icon(Icons.star, size: 8, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              influencer.name,
              style: TextStyle(
                fontSize: 9,
                color: theme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final InfluencerTip tip;
  final Influencer? influencer;
  final AppLocalizations l10n;
  final bool flagBadTips;

  const _TipCard({
    required this.tip,
    required this.influencer,
    required this.l10n,
    this.flagBadTips = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final game = context.read<GameService>();
    final tipColor = tip.isBullish ? theme.positive : theme.negative;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
      onTap: () => game.selectCompany(tip.stockId),
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: tipColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              if (influencer != null) ...[
                Text(
                  influencer!.avatar,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  influencer!.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  influencer!.handle,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.textMuted,
                  ),
                ),
              ],
              const Spacer(),
              // Talent tree: flag unreliable influencers
              if (flagBadTips && influencer != null && influencer!.totalTips >= 3 && influencer!.displayedAccuracy < 0.4)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: theme.negative.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 10, color: theme.negative),
                      const SizedBox(width: 2),
                      Text(
                        l10n.get('fintok_unreliable'),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: theme.negative,
                        ),
                      ),
                    ],
                  ),
                ),
              if (tip.isViral)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: theme.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n.fintokViral,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: theme.purple,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tipColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tip.isBullish ? l10n.fintokBuy : l10n.fintokSell,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: tipColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Stock and message
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tip.stockName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.accent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            tip.message,
            style: TextStyle(
              fontSize: 12,
              color: theme.textSecondary,
            ),
          ),

          // Outcome indicator
          if (tip.wasAccurate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  tip.wasAccurate! ? Icons.check_circle : Icons.cancel,
                  size: 14,
                  color: tip.wasAccurate! ? theme.positive : theme.negative,
                ),
                const SizedBox(width: 4),
                Text(
                  tip.wasAccurate! ? l10n.fintokAccurate : l10n.fintokWrong,
                  style: TextStyle(
                    fontSize: 10,
                    color: tip.wasAccurate! ? theme.positive : theme.negative,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final AppThemeData theme;

  const _ProfileStat({
    required this.label,
    required this.value,
    this.valueColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.textMuted,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? theme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

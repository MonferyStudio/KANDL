import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../theme/app_themes.dart';
import '../../services/game_service.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';

class NewsView extends StatelessWidget {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;

    return Consumer<GameService>(
      builder: (context, game, _) {
        final allNews = game.recentNews;

        if (allNews.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.newspaper_outlined, size: 48, color: theme.textMuted),
                const SizedBox(height: 12),
                Text(
                  l10n.noNewsYet,
                  style: TextStyle(fontSize: 14, color: theme.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.only(
            left: isMobile ? 8 : 12,
            right: isMobile ? 8 : 12,
            top: 8,
            bottom: isMobile ? 80 : 12,
          ),
          itemCount: allNews.length,
          itemBuilder: (context, index) {
            return _NewsCard(
              news: allNews[index],
              theme: theme,
              l10n: l10n,
            );
          },
        );
      },
    );
  }
}

class _NewsCard extends StatefulWidget {
  final NewsItem news;
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _NewsCard({
    required this.news,
    required this.theme,
    required this.l10n,
  });

  @override
  State<_NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<_NewsCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final news = widget.news;
    final theme = widget.theme;
    final l10n = widget.l10n;

    // Sentiment color
    Color sentimentColor;
    String sentimentIcon;
    switch (news.sentiment) {
      case NewsSentiment.veryPositive:
        sentimentColor = theme.positive;
        sentimentIcon = '🚀';
        break;
      case NewsSentiment.positive:
        sentimentColor = theme.positive;
        sentimentIcon = '📈';
        break;
      case NewsSentiment.negative:
        sentimentColor = theme.negative;
        sentimentIcon = '📉';
        break;
      case NewsSentiment.veryNegative:
        sentimentColor = theme.negative;
        sentimentIcon = '💥';
        break;
      case NewsSentiment.neutral:
        sentimentColor = theme.textSecondary;
        sentimentIcon = '➡️';
        break;
    }

    // Localized text
    String headline = news.headline;
    String description = news.description;

    if (news.templateKey != null) {
      String? localizedSector;
      if (news.sectorId != null) {
        localizedSector = l10n.sectorName(news.sectorId!);
      } else if (news.sectorName != null) {
        localizedSector = news.sectorName;
      }

      if (news.templateKey!.startsWith('midday_')) {
        final parts = news.templateKey!.split(':');
        if (parts.length == 2) {
          final prefixPart = parts[0];
          final templatePart = parts[1];

          String prefix = '';
          if (prefixPart.contains('update')) {
            prefix = l10n.middayPrefixUpdate;
          } else if (prefixPart.contains('correction')) {
            prefix = l10n.middayPrefixCorrection;
          } else if (prefixPart.contains('breaking')) {
            prefix = l10n.middayPrefixBreaking;
          } else if (prefixPart.contains('reversal')) {
            prefix = l10n.middayPrefixReversal;
          } else if (prefixPart.contains('recovery')) {
            prefix = l10n.middayPrefixRecovery;
          }

          headline = '$prefix${l10n.newsHeadline(
            'midday_$templatePart',
            company: news.companyName,
            sector: localizedSector,
          )}';
          description = l10n.newsDescription('midday_$templatePart');
        }
      } else {
        headline = l10n.newsHeadline(
          news.templateKey!,
          company: news.companyName,
          sector: localizedSector,
          quarter: news.quarter?.toString(),
        );
        description = l10n.newsDescription(news.templateKey!);
      }
    }
    final category = l10n.newsCategoryLabel(news.category.name);

    final game = context.read<GameService>();
    final isNavigable = (news.companyId != null && game.isCompanyUnlocked(news.companyId!)) ||
        (news.sectorId != null && news.companyId == null);

    // Impact badge
    String? impactLabel;
    Color? impactColor;
    if (news.impactMagnitude >= 0.7) {
      impactLabel = 'HIGH';
      impactColor = theme.negative;
    } else if (news.impactMagnitude >= 0.4) {
      impactLabel = 'MED';
      impactColor = theme.orange;
    }

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _isHovered && isNavigable
            ? theme.surface.withValues(alpha: 0.8)
            : theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: _isHovered && isNavigable
                ? sentimentColor
                : sentimentColor.withValues(alpha: 0.7),
            width: _isHovered && isNavigable ? 4 : 3,
          ),
        ),
        boxShadow: _isHovered && isNavigable
            ? [
                BoxShadow(
                  color: sentimentColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: sentiment icon + category + impact + time + chevron
            Row(
              children: [
                Text(sentimentIcon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: sentimentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: sentimentColor,
                    ),
                  ),
                ),
                if (impactLabel != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: impactColor!.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      impactLabel,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: impactColor,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  news.timeAgo,
                  style: TextStyle(fontSize: 10, color: theme.textMuted),
                ),
                if (isNavigable) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16, color: theme.textMuted),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // Headline
            Text(
              headline,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: theme.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Target info (company or sector name)
            if (isNavigable) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    news.companyId != null ? Icons.business : Icons.category,
                    size: 12,
                    color: theme.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    news.companyId != null
                        ? (news.companyName ?? news.companyId!)
                        : l10n.sectorName(news.sectorId!),
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.primary.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );

    if (!isNavigable) return card;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          final game = context.read<GameService>();
          if (news.companyId != null) {
            game.selectCompany(news.companyId!);
          } else if (news.sectorId != null) {
            game.selectSector(news.sectorId!);
          }
        },
        child: card,
      ),
    );
  }
}

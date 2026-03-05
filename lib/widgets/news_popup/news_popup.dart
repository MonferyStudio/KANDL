import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/news_item.dart';
import '../../data/sectors.dart';
import '../../services/game_service.dart';
import '../../services/sound_service.dart';
import '../../services/tutorial_service.dart';
import '../../theme/app_themes.dart';

/// Popup dialog showing daily news at the start of each day
class NewsPopup extends StatelessWidget {
  const NewsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    return Consumer<GameService>(
      builder: (context, game, _) {
        if (!game.showNewsPopup || game.todayNews.isEmpty) {
          return const SizedBox.shrink();
        }

        return Material(
          color: Colors.black.withValues(alpha: 0.9),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: (MediaQuery.of(context).size.width - 32).clamp(0, 700),
                maxHeight: (MediaQuery.of(context).size.height - 48).clamp(0, 650),
              ),
              margin: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  _Header(day: game.currentDay, year: game.currentYear),
                  const SizedBox(height: 20),

                  // Subtitle
                  Text(
                    l10n.marketNews.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // News cards
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (int i = 0; i < game.todayNews.length; i++) ...[
                            if (i > 0) const SizedBox(height: 12),
                            _NewsCard(news: game.todayNews[i]),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Continue button
                  _ContinueButton(onPressed: () {
                    SoundService().playClick();
                    game.dismissNewsPopup();
                    // Start contextual tutorial after first news popup
                    context.read<TutorialService>().startContextualTutorials();
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final int day;
  final int year;

  const _Header({required this.day, required this.year});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '📰',
              style: TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.dayYearHeader(day, year),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.orange,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: 120,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.orange.withValues(alpha: 0),
                theme.orange,
                theme.orange.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem news;

  const _NewsCard({required this.news});

  Color _getSentimentColor(AppThemeData theme) {
    switch (news.sentiment) {
      case NewsSentiment.veryPositive:
        return theme.positive;
      case NewsSentiment.positive:
        return theme.positive.withValues(alpha: 0.7);
      case NewsSentiment.neutral:
        return theme.textMuted;
      case NewsSentiment.negative:
        return theme.negative.withValues(alpha: 0.7);
      case NewsSentiment.veryNegative:
        return theme.negative;
    }
  }

  String get _sentimentIcon {
    switch (news.sentiment) {
      case NewsSentiment.veryPositive:
        return '🚀';
      case NewsSentiment.positive:
        return '📈';
      case NewsSentiment.neutral:
        return '➡️';
      case NewsSentiment.negative:
        return '📉';
      case NewsSentiment.veryNegative:
        return '💥';
    }
  }

  String _getImpactLabel(AppLocalizations l10n) {
    final impact = news.impactMagnitude;
    if (impact >= 0.7) return l10n.highImpact.toUpperCase();
    if (impact >= 0.4) return l10n.mediumImpact.toUpperCase();
    return l10n.lowImpact.toUpperCase();
  }

  String _getLocalizedHeadline(AppLocalizations l10n) {
    if (news.templateKey == null) return news.headline;
    // Get localized sector name if sectorId is present
    String? localizedSector;
    if (news.sectorId != null) {
      localizedSector = l10n.sectorName(news.sectorId!);
    } else if (news.sectorName != null) {
      localizedSector = news.sectorName;
    }
    return l10n.newsHeadline(
      news.templateKey!,
      company: news.companyName,
      sector: localizedSector,
      quarter: news.quarter?.toString(),
    );
  }

  String _getLocalizedDescription(AppLocalizations l10n) {
    if (news.templateKey == null) return news.description;
    return l10n.newsDescription(news.templateKey!);
  }

  String _getLocalizedCategory(AppLocalizations l10n) {
    return l10n.newsCategoryLabel(news.category.name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final sentimentColor = _getSentimentColor(theme);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: sentimentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Sentiment icon
              Text(
                _sentimentIcon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),

              // Headline
              Expanded(
                child: Text(
                  _getLocalizedHeadline(l10n),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
              ),

              // Impact badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: sentimentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: sentimentColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getImpactLabel(l10n),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: sentimentColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            _getLocalizedDescription(l10n),
            style: TextStyle(
              fontSize: 13,
              color: theme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),

          // Category and target
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getLocalizedCategory(l10n),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (news.companyId != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: sentimentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: sentimentColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    news.companyName ?? news.companyId!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: sentimentColor,
                    ),
                  ),
                ),
              ] else if (news.sectorId != null) ...[
                const SizedBox(width: 8),
                Builder(builder: (context) {
                  final sector = getSectorById(news.sectorId!);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (sector?.color ?? sentimentColor).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: (sector?.color ?? sentimentColor).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      sector != null ? '${sector.icon} ${l10n.sectorName(news.sectorId!)}' : l10n.sectorWide,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: sector?.color ?? sentimentColor,
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ContinueButton({required this.onPressed});

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          decoration: BoxDecoration(
            color: _isHovered ? theme.cyan : theme.cyan.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.cyan,
              width: 2,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: theme.cyan.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Text(
            l10n.startTrading.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _isHovered ? theme.background : theme.cyan,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

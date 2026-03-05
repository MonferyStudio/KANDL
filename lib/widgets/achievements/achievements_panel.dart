import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/achievement.dart';
import '../../services/achievement_service.dart';
import '../../theme/app_themes.dart';
import '../../l10n/app_localizations.dart';

/// Full-screen achievements panel showing all achievements and progress
class AchievementsPanel extends StatefulWidget {
  final VoidCallback? onClose;

  const AchievementsPanel({super.key, this.onClose});

  @override
  State<AchievementsPanel> createState() => _AchievementsPanelState();
}

class _AchievementsPanelState extends State<AchievementsPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<AchievementCategory> _categories = [
    AchievementCategory.trading,
    AchievementCategory.profit,
    AchievementCategory.portfolio,
    AchievementCategory.milestone,
    AchievementCategory.risk,
    AchievementCategory.secret,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getCategoryName(AchievementCategory category, AppLocalizations l10n) {
    switch (category) {
      case AchievementCategory.trading:
        return l10n.achievementCategoryTrading;
      case AchievementCategory.profit:
        return l10n.achievementCategoryProfit;
      case AchievementCategory.portfolio:
        return l10n.achievementCategoryPortfolio;
      case AchievementCategory.milestone:
        return l10n.achievementCategoryMilestone;
      case AchievementCategory.risk:
        return l10n.achievementCategoryRisk;
      case AchievementCategory.market:
        return l10n.achievementCategoryMarket;
      case AchievementCategory.secret:
        return l10n.achievementCategorySecret;
    }
  }

  String _getCategoryIcon(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.trading:
        return '📊';
      case AchievementCategory.profit:
        return '💰';
      case AchievementCategory.portfolio:
        return '📁';
      case AchievementCategory.milestone:
        return '🏆';
      case AchievementCategory.risk:
        return '🎰';
      case AchievementCategory.market:
        return '📈';
      case AchievementCategory.secret:
        return '🔮';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: theme.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(theme, l10n),

            // Category tabs
            _buildCategoryTabs(theme, l10n),

            // Achievement list
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((category) {
                  return _AchievementList(category: category);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeData theme, AppLocalizations l10n) {
    return Consumer<AchievementService>(
      builder: (context, achievements, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.card,
            border: Border(
              bottom: BorderSide(color: theme.border),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: widget.onClose ?? () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: theme.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.achievements,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                          ),
                        ),
                        Text(
                          '${achievements.completedCount}/${achievements.totalCount} ${l10n.completed}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress circle
                  _buildProgressCircle(theme, achievements.completionPercent),
                ],
              ),

              // Unclaimed rewards banner
              if (achievements.hasUnclaimedRewards) ...[
                const SizedBox(height: 12),
                _buildUnclaimedBanner(theme, l10n, achievements),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressCircle(AppThemeData theme, double percent) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percent / 100,
            strokeWidth: 4,
            backgroundColor: theme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(theme.positive),
          ),
          Text(
            '${percent.toInt()}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnclaimedBanner(
    AppThemeData theme,
    AppLocalizations l10n,
    AchievementService achievements,
  ) {
    return GestureDetector(
      onTap: () {
        final rewards = achievements.claimAllRewards();
        if (rewards.isNotEmpty) {
          _showRewardsDialog(context, theme, l10n, rewards);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.positive.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.positive.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎁', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              '${achievements.unclaimedRewardsCount} ${l10n.unclaimedRewards}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.positive,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.tapToClaim,
              style: TextStyle(
                fontSize: 12,
                color: theme.positive.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRewardsDialog(
    BuildContext context,
    AppThemeData theme,
    AppLocalizations l10n,
    List<AchievementReward> rewards,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.card,
        title: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              l10n.rewardsClaimed,
              style: TextStyle(color: theme.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rewards.map((reward) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Text('✓ ', style: TextStyle(color: Colors.green)),
                  Text(
                    reward.description,
                    style: TextStyle(color: theme.textSecondary),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.ok,
              style: TextStyle(color: theme.cyan),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(AppThemeData theme, AppLocalizations l10n) {
    return Container(
      color: theme.card,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: theme.cyan,
        unselectedLabelColor: theme.textMuted,
        indicatorColor: theme.cyan,
        dividerColor: theme.border,
        tabs: _categories.map((category) {
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_getCategoryIcon(category)),
                const SizedBox(width: 6),
                Text(_getCategoryName(category, l10n)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AchievementList extends StatelessWidget {
  final AchievementCategory category;

  const _AchievementList({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);

    return Consumer<AchievementService>(
      builder: (context, achievements, _) {
        final items = achievements.getByCategory(category);

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🔒', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  l10n.noAchievementsYet,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textMuted,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final (achievement, progress) = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AchievementCard(
                achievement: achievement,
                progress: progress,
              ),
            );
          },
        );
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementDefinition achievement;
  final AchievementProgress progress;

  const _AchievementCard({
    required this.achievement,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isCompleted = progress.isCompleted;
    final tierColor = Color(achievement.tierColorValue);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? tierColor.withValues(alpha: 0.1)
            : theme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? tierColor.withValues(alpha: 0.5)
              : theme.border,
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? tierColor.withValues(alpha: 0.2)
                      : theme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  achievement.icon,
                  style: TextStyle(
                    fontSize: 24,
                    color: isCompleted ? null : theme.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and tier
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? tierColor
                                  : theme.textPrimary,
                            ),
                          ),
                        ),
                        _buildTierBadge(theme, tierColor),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Completed checkmark
              if (isCompleted)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.positive,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          if (!isCompleted) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.getProgressPercent(achievement.targetValue) / 100,
                backgroundColor: theme.surface,
                valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.currentValue.toInt()} / ${achievement.targetValue.toInt()}',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textMuted,
                  ),
                ),
                Text(
                  '${progress.getProgressPercent(achievement.targetValue).toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tierColor,
                  ),
                ),
              ],
            ),
          ],

          // Rewards
          const SizedBox(height: 8),
          _buildRewards(theme, achievement, progress),

          // Completed date
          if (isCompleted && progress.completedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.completedOn} ${_formatDate(progress.completedAt!)}',
              style: TextStyle(
                fontSize: 10,
                color: theme.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRewards(AppThemeData theme, AchievementDefinition achievement, AchievementProgress progress) {
    final rewards = Achievements.computeRewards(achievement);
    final isCompleted = progress.isCompleted;
    final claimed = isCompleted && progress.rewardClaimed;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: rewards.map((reward) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: claimed
                ? theme.positive.withValues(alpha: 0.15)
                : theme.surface,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                claimed ? '✓ ' : '🎁 ',
                style: const TextStyle(fontSize: 10),
              ),
              Text(
                reward.description,
                style: TextStyle(
                  fontSize: 10,
                  color: claimed
                      ? theme.positive
                      : theme.textMuted,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTierBadge(AppThemeData theme, Color tierColor) {
    final tierName = achievement.tier.name.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tierColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: tierColor.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        tierName,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: tierColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

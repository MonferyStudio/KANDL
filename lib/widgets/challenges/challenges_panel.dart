import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/daily_challenge.dart';
import '../../services/game_service.dart';
import '../../theme/app_themes.dart';

/// Panel showing daily challenges
class ChallengesPanel extends StatelessWidget {
  const ChallengesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return Consumer<GameService>(
      builder: (context, game, _) {
        final challenges = game.activeChallenges;

        if (challenges.isEmpty) {
          return _EmptyState(theme: theme);
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    '🎯 Daily Challenges',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: game.allChallengesComplete
                          ? theme.positive.withValues(alpha: 0.2)
                          : theme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${game.completedChallengesCount}/${game.totalChallengesCount}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: game.allChallengesComplete
                            ? theme.positive
                            : theme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Challenges list
              ...challenges.map((challenge) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ChallengeCard(
                  challenge: challenge,
                  netWorth: game.netWorth.toDouble(),
                  onClaim: challenge.isCompleted && !challenge.rewardClaimed
                      ? () => game.claimChallengeReward(challenge.id)
                      : null,
                ),
              )),

              // Claim all button
              if (game.unclaimedChallengeRewards > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => game.claimAllChallengeRewards(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.positive,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Claim All (${game.unclaimedChallengeRewards})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppThemeData theme;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            'Daily Challenges',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start a new day to get challenges!',
            style: TextStyle(
              fontSize: 12,
              color: theme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final DailyChallenge challenge;
  final double netWorth;
  final VoidCallback? onClaim;

  const _ChallengeCard({
    required this.challenge,
    required this.netWorth,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final difficultyColor = _getDifficultyColor(challenge.difficulty, theme);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: challenge.isCompleted
            ? theme.positive.withValues(alpha: 0.1)
            : theme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: challenge.isCompleted
              ? theme.positive.withValues(alpha: 0.3)
              : theme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(
                challenge.difficultyEmoji,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  challenge.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: difficultyColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  challenge.difficultyLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: difficultyColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Description
          Text(
            challenge.description,
            style: TextStyle(
              fontSize: 11,
              color: theme.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: challenge.progressPercent,
                    backgroundColor: theme.border,
                    valueColor: AlwaysStoppedAnimation(
                      challenge.isCompleted ? theme.positive : theme.accent,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                challenge.progressText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: challenge.isCompleted ? theme.positive : theme.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Reward row
          Row(
            children: [
              Text(
                '💰 \$${challenge.computeReward(netWorth).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.positive,
                ),
              ),
              if (challenge.bonusReward != null) ...[
                const SizedBox(width: 8),
                Text(
                  '+ ${challenge.bonusReward}',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.purple,
                  ),
                ),
              ],
              const Spacer(),
              if (challenge.isCompleted && !challenge.rewardClaimed)
                GestureDetector(
                  onTap: onClaim,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.positive,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Claim',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else if (challenge.rewardClaimed)
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: theme.positive),
                    const SizedBox(width: 4),
                    Text(
                      'Claimed',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.positive,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(ChallengeDifficulty difficulty, AppThemeData theme) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return theme.positive;
      case ChallengeDifficulty.medium:
        return theme.yellow;
      case ChallengeDifficulty.hard:
        return theme.orange;
      case ChallengeDifficulty.extreme:
        return theme.negative;
    }
  }
}

/// Compact version for dashboard
class ChallengesCompact extends StatelessWidget {
  const ChallengesCompact({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return Consumer<GameService>(
      builder: (context, game, _) {
        final completed = game.completedChallengesCount;
        final total = game.totalChallengesCount;

        if (total == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎯', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                '$completed/$total',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: completed == total ? theme.positive : theme.textPrimary,
                ),
              ),
              if (game.unclaimedChallengeRewards > 0) ...[
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.positive,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

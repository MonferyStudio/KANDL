import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/notification_service.dart';
import '../../services/sound_service.dart';
import '../../theme/app_themes.dart';

/// Bell icon with notification badge count
class NotificationBell extends StatelessWidget {
  final VoidCallback onTap;
  final double size;

  const NotificationBell({
    super.key,
    required this.onTap,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return Consumer<NotificationService>(
      builder: (context, notificationService, _) {
        final unreadCount = notificationService.unreadCount;
        final hasUnread = unreadCount > 0;

        return GestureDetector(
          onTap: () {
            SoundService().playClick();
            onTap();
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Bell icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hasUnread
                        ? theme.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    hasUnread
                        ? Icons.notifications_active
                        : Icons.notifications_outlined,
                    size: size,
                    color: hasUnread ? theme.primary : theme.textSecondary,
                  ),
                ),

                // Badge
                if (hasUnread)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: _NotificationBadge(
                      count: unreadCount,
                      theme: theme,
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

class _NotificationBadge extends StatelessWidget {
  final int count;
  final AppThemeData theme;

  const _NotificationBadge({
    required this.count,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final displayCount = count > 99 ? '99+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: theme.negative,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: theme.negative.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Center(
        child: Text(
          displayCount,
          style: TextStyle(
            color: Colors.white,
            fontSize: count > 99 ? 8 : 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

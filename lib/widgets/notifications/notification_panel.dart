import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/notification_item.dart';
import '../../services/notification_service.dart';
import '../../theme/app_themes.dart';
import '../../l10n/app_localizations.dart';
import '../../core/responsive.dart';

/// Panel showing all notifications
class NotificationPanel extends StatelessWidget {
  final VoidCallback onClose;
  final Function(NotificationItem)? onNotificationTap;

  const NotificationPanel({
    super.key,
    required this.onClose,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final l10n = AppLocalizations.of(context);
    final isMobile = context.isMobile;

    return Consumer<NotificationService>(
      builder: (context, notificationService, _) {
        final notifications = notificationService.notifications;

        return Container(
          width: isMobile ? double.infinity : 380,
          constraints: BoxConstraints(
            maxHeight: isMobile ? 400 : 500,
          ),
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _PanelHeader(
                theme: theme,
                l10n: l10n,
                unreadCount: notificationService.unreadCount,
                onClose: onClose,
                onMarkAllRead: () => notificationService.markAllAsRead(),
                onClearAll: () => notificationService.clearAll(),
              ),

              // Divider
              Container(
                height: 1,
                color: theme.border,
              ),

              // Notifications list
              if (notifications.isEmpty)
                _EmptyState(theme: theme, l10n: l10n)
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _NotificationCard(
                        notification: notification,
                        theme: theme,
                        onTap: () {
                          notificationService.markAsRead(notification.id);
                          onNotificationTap?.call(notification);
                        },
                        onDismiss: () {
                          notificationService.dismissNotification(notification.id);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final AppThemeData theme;
  final AppLocalizations l10n;
  final int unreadCount;
  final VoidCallback onClose;
  final VoidCallback onMarkAllRead;
  final VoidCallback onClearAll;

  const _PanelHeader({
    required this.theme,
    required this.l10n,
    required this.unreadCount,
    required this.onClose,
    required this.onMarkAllRead,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Title
          Text(
            l10n.get('notifications'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$unreadCount ${l10n.get('new')}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.primary,
                ),
              ),
            ),
          ],
          const Spacer(),

          // Actions
          if (unreadCount > 0)
            _HeaderAction(
              icon: Icons.done_all,
              tooltip: l10n.get('mark_all_read'),
              theme: theme,
              onTap: onMarkAllRead,
            ),
          _HeaderAction(
            icon: Icons.delete_sweep,
            tooltip: l10n.get('clear_all'),
            theme: theme,
            onTap: onClearAll,
          ),
          _HeaderAction(
            icon: Icons.close,
            tooltip: l10n.close,
            theme: theme,
            onTap: onClose,
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final AppThemeData theme;
  final VoidCallback onTap;

  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              icon,
              size: 20,
              color: theme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppThemeData theme;
  final AppLocalizations l10n;

  const _EmptyState({
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 48,
            color: theme.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.get('no_notifications'),
            style: TextStyle(
              fontSize: 14,
              color: theme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.get('no_notifications_desc'),
            style: TextStyle(
              fontSize: 12,
              color: theme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final AppThemeData theme;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.theme,
    required this.onTap,
    required this.onDismiss,
  });

  Color get _accentColor {
    switch (notification.type) {
      case NotificationType.priceAlert:
        return notification.isPositive ? theme.positive : theme.negative;
      case NotificationType.warning:
        return theme.orange;
      case NotificationType.achievement:
        return theme.cyan;
      case NotificationType.bonus:
        return theme.positive;
      case NotificationType.event:
        return notification.isPositive ? theme.cyan : theme.orange;
      default:
        return theme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.negative.withValues(alpha: 0.2),
        child: Icon(
          Icons.delete,
          color: theme.negative,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? Colors.transparent
                  : _accentColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: notification.isRead
                  ? null
                  : Border.all(
                      color: _accentColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      notification.icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                                color: theme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            notification.timeAgo,
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Percent change badge for price alerts
                      if (notification.percentChange != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${notification.percentChange! > 0 ? '+' : ''}${notification.percentChange!.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _accentColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Unread indicator
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 8, top: 4),
                    decoration: BoxDecoration(
                      color: _accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

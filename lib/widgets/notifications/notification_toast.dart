import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/notification_item.dart';
import '../../services/notification_service.dart';
import '../../theme/app_themes.dart';
import '../../core/responsive.dart';

/// Toast notification that appears temporarily at the top of the screen
class NotificationToast extends StatefulWidget {
  final VoidCallback? onTap;

  const NotificationToast({
    super.key,
    this.onTap,
  });

  @override
  State<NotificationToast> createState() => _NotificationToastState();
}

class _NotificationToastState extends State<NotificationToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showToast() {
    _controller.forward();
    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismissToast();
      }
    });
  }

  void _dismissToast() {
    _controller.reverse().then((_) {
      if (mounted) {
        context.read<NotificationService>().dismissToast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;
    final isMobile = context.isMobile;

    return Consumer<NotificationService>(
      builder: (context, notificationService, _) {
        final toast = notificationService.currentToast;

        if (toast == null) {
          return const SizedBox.shrink();
        }

        // Trigger animation when toast appears
        if (!_controller.isAnimating && _controller.status != AnimationStatus.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showToast();
          });
        }

        return Positioned(
          top: isMobile ? 8 : 16,
          left: isMobile ? 8 : null,
          right: isMobile ? 8 : 16,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _ToastCard(
                notification: toast,
                theme: theme,
                onTap: () {
                  widget.onTap?.call();
                  _dismissToast();
                },
                onDismiss: _dismissToast,
                isMobile: isMobile,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ToastCard extends StatelessWidget {
  final NotificationItem notification;
  final AppThemeData theme;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final bool isMobile;

  const _ToastCard({
    required this.notification,
    required this.theme,
    required this.onTap,
    required this.onDismiss,
    required this.isMobile,
  });

  Color get _accentColor {
    if (notification.type == NotificationType.warning) {
      return theme.orange;
    }
    if (notification.type == NotificationType.achievement) {
      return theme.cyan;
    }
    return notification.isPositive ? theme.positive : theme.negative;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 100) {
          onDismiss();
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 360,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _accentColor.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _accentColor.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  notification.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Dismiss button
            GestureDetector(
              onTap: onDismiss,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: theme.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

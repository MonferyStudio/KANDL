/// Types of notifications in the game
enum NotificationType {
  priceAlert,      // Stock price moved significantly
  news,            // Breaking news affecting player
  achievement,     // Achievement unlocked
  fintok,          // Influencer posted
  warning,         // Position at risk, margin call, etc.
  bonus,           // Reward received
  event,           // Special market event
  system,          // System messages
}

/// Priority levels for notifications
enum NotificationPriority {
  low,       // Can be dismissed, non-urgent
  medium,    // Should be seen but not blocking
  high,      // Important, shows toast
  urgent,    // Critical, may pause game
}

/// Action types when clicking a notification
enum NotificationAction {
  none,              // Just dismiss
  navigateStock,     // Go to stock trading page
  navigateSector,    // Go to sector view
  openFintok,        // Open FinTok feed
  openAchievements,  // Open achievements page
  claimReward,       // Claim a bonus/reward
  openNews,          // Open news panel
  openPositions,     // Open positions view
}

/// Represents a single notification in the game
class NotificationItem {
  final String id;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String message;
  final String icon;
  final DateTime timestamp;
  bool isRead;
  bool isDismissed;

  // Action data
  final NotificationAction actionType;
  final String? actionData; // stockId, sectorId, influencerId, etc.

  // Optional styling
  final bool isPositive; // Green vs red styling
  final double? percentChange; // For price alerts

  NotificationItem({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    required this.icon,
    required this.timestamp,
    this.isRead = false,
    this.isDismissed = false,
    this.actionType = NotificationAction.none,
    this.actionData,
    this.isPositive = true,
    this.percentChange,
  });

  /// Create a price alert notification
  factory NotificationItem.priceAlert({
    required String id,
    required String stockName,
    required String stockId,
    required double percentChange,
    required bool isPositive,
  }) {
    final direction = isPositive ? '📈' : '📉';
    final sign = isPositive ? '+' : '';
    return NotificationItem(
      id: id,
      type: NotificationType.priceAlert,
      priority: percentChange.abs() > 10
          ? NotificationPriority.high
          : NotificationPriority.medium,
      title: '$stockName $direction',
      message: '$sign${percentChange.toStringAsFixed(1)}% movement',
      icon: direction,
      timestamp: DateTime.now(),
      actionType: NotificationAction.navigateStock,
      actionData: stockId,
      isPositive: isPositive,
      percentChange: percentChange,
    );
  }

  /// Create a news notification
  factory NotificationItem.news({
    required String id,
    required String headline,
    required bool isPositive,
    String? companyId,
  }) {
    return NotificationItem(
      id: id,
      type: NotificationType.news,
      priority: NotificationPriority.medium,
      title: 'Breaking News',
      message: headline,
      icon: '📰',
      timestamp: DateTime.now(),
      actionType: companyId != null
          ? NotificationAction.navigateStock
          : NotificationAction.openNews,
      actionData: companyId,
      isPositive: isPositive,
    );
  }

  /// Create an achievement notification
  factory NotificationItem.achievement({
    required String id,
    required String achievementName,
    required String achievementIcon,
    required String reward,
  }) {
    return NotificationItem(
      id: id,
      type: NotificationType.achievement,
      priority: NotificationPriority.high,
      title: 'Achievement Unlocked!',
      message: '$achievementName - $reward',
      icon: achievementIcon,
      timestamp: DateTime.now(),
      actionType: NotificationAction.openAchievements,
      isPositive: true,
    );
  }

  /// Create a FinTok notification
  factory NotificationItem.fintok({
    required String id,
    required String influencerName,
    required String influencerId,
    required String preview,
  }) {
    return NotificationItem(
      id: id,
      type: NotificationType.fintok,
      priority: NotificationPriority.medium,
      title: '@$influencerName posted',
      message: preview,
      icon: '📱',
      timestamp: DateTime.now(),
      actionType: NotificationAction.openFintok,
      actionData: influencerId,
      isPositive: true,
    );
  }

  /// Create a warning notification
  factory NotificationItem.warning({
    required String id,
    required String title,
    required String message,
    String? stockId,
  }) {
    return NotificationItem(
      id: id,
      type: NotificationType.warning,
      priority: NotificationPriority.high,
      title: title,
      message: message,
      icon: '⚠️',
      timestamp: DateTime.now(),
      actionType: stockId != null
          ? NotificationAction.navigateStock
          : NotificationAction.openPositions,
      actionData: stockId,
      isPositive: false,
    );
  }

  /// Create a bonus notification
  factory NotificationItem.bonus({
    required String id,
    required String title,
    required String amount,
  }) {
    return NotificationItem(
      id: id,
      type: NotificationType.bonus,
      priority: NotificationPriority.high,
      title: title,
      message: amount,
      icon: '🎁',
      timestamp: DateTime.now(),
      actionType: NotificationAction.claimReward,
      actionData: id,
      isPositive: true,
    );
  }

  /// Create a special event notification
  factory NotificationItem.event({
    required String id,
    required String eventName,
    required String description,
    required bool isPositive,
  }) {
    return NotificationItem(
      id: id,
      type: NotificationType.event,
      priority: NotificationPriority.urgent,
      title: eventName,
      message: description,
      icon: isPositive ? '🎉' : '🌪️',
      timestamp: DateTime.now(),
      actionType: NotificationAction.none,
      isPositive: isPositive,
    );
  }

  /// Time ago text
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  /// Mark as read
  void markAsRead() {
    isRead = true;
  }

  /// Dismiss notification
  void dismiss() {
    isDismissed = true;
    isRead = true;
  }

  // JSON serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'priority': priority.name,
    'title': title,
    'message': message,
    'icon': icon,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'isDismissed': isDismissed,
    'actionType': actionType.name,
    'actionData': actionData,
    'isPositive': isPositive,
    'percentChange': percentChange,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.low,
      ),
      title: json['title'],
      message: json['message'],
      icon: json['icon'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      isDismissed: json['isDismissed'] ?? false,
      actionType: NotificationAction.values.firstWhere(
        (e) => e.name == json['actionType'],
        orElse: () => NotificationAction.none,
      ),
      actionData: json['actionData'],
      isPositive: json['isPositive'] ?? true,
      percentChange: json['percentChange']?.toDouble(),
    );
  }
}

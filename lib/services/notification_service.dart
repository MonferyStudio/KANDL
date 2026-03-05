import 'package:flutter/foundation.dart';

import '../models/notification_item.dart';
import 'sound_service.dart';

/// Service for managing in-game notifications
class NotificationService extends ChangeNotifier {
  static const int maxNotifications = 50;
  // Price alert threshold filtering is handled by GameService._checkPriceAlert()

  final List<NotificationItem> _notifications = [];
  int _notificationIdCounter = 0;

  // Settings
  bool _priceAlertsEnabled = true;
  bool _newsAlertsEnabled = true;
  bool _achievementAlertsEnabled = true;
  bool _fintokAlertsEnabled = true;
  bool _eventAlertsEnabled = true;

  // Toast queue for showing temporary notifications
  final List<NotificationItem> _toastQueue = [];
  NotificationItem? _currentToast;

  // Getters
  List<NotificationItem> get notifications =>
      _notifications.where((n) => !n.isDismissed).toList();

  List<NotificationItem> get unreadNotifications =>
      _notifications.where((n) => !n.isRead && !n.isDismissed).toList();

  int get unreadCount => unreadNotifications.length;

  bool get hasUnread => unreadCount > 0;

  NotificationItem? get currentToast => _currentToast;

  bool get hasToast => _currentToast != null;

  // Settings getters
  bool get priceAlertsEnabled => _priceAlertsEnabled;
  bool get newsAlertsEnabled => _newsAlertsEnabled;
  bool get achievementAlertsEnabled => _achievementAlertsEnabled;
  bool get fintokAlertsEnabled => _fintokAlertsEnabled;
  bool get eventAlertsEnabled => _eventAlertsEnabled;

  /// Generate unique notification ID
  String _generateId() {
    return 'notif_${_notificationIdCounter++}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Add a notification
  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);

    // Trim old notifications
    while (_notifications.length > maxNotifications) {
      _notifications.removeLast();
    }

    // Add to toast queue if high priority
    if (notification.priority == NotificationPriority.high ||
        notification.priority == NotificationPriority.urgent) {
      _toastQueue.add(notification);
      _processToastQueue();
    }

    // Play notification sound
    SoundService().playNotification();

    notifyListeners();
  }

  /// Process the toast queue
  void _processToastQueue() {
    if (_currentToast == null && _toastQueue.isNotEmpty) {
      _currentToast = _toastQueue.removeAt(0);
      notifyListeners();
    }
  }

  /// Dismiss the current toast
  void dismissToast() {
    _currentToast = null;
    notifyListeners();

    // Process next toast after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _processToastQueue();
    });
  }

  /// Add a price alert notification
  void addPriceAlert({
    required String stockName,
    required String stockId,
    required double percentChange,
  }) {
    if (!_priceAlertsEnabled) return;

    final notification = NotificationItem.priceAlert(
      id: _generateId(),
      stockName: stockName,
      stockId: stockId,
      percentChange: percentChange,
      isPositive: percentChange > 0,
    );

    addNotification(notification);
  }

  /// Add a news notification
  void addNewsAlert({
    required String headline,
    required bool isPositive,
    String? companyId,
  }) {
    if (!_newsAlertsEnabled) return;

    final notification = NotificationItem.news(
      id: _generateId(),
      headline: headline,
      isPositive: isPositive,
      companyId: companyId,
    );

    addNotification(notification);
  }

  /// Add an achievement notification
  void addAchievementAlert({
    required String achievementName,
    required String achievementIcon,
    required String reward,
  }) {
    if (!_achievementAlertsEnabled) return;

    final notification = NotificationItem.achievement(
      id: _generateId(),
      achievementName: achievementName,
      achievementIcon: achievementIcon,
      reward: reward,
    );

    addNotification(notification);
  }

  /// Add a FinTok notification
  void addFintokAlert({
    required String influencerName,
    required String influencerId,
    required String preview,
  }) {
    if (!_fintokAlertsEnabled) return;

    final notification = NotificationItem.fintok(
      id: _generateId(),
      influencerName: influencerName,
      influencerId: influencerId,
      preview: preview,
    );

    addNotification(notification);
  }

  /// Add a warning notification
  void addWarning({
    required String title,
    required String message,
    String? stockId,
  }) {
    final notification = NotificationItem.warning(
      id: _generateId(),
      title: title,
      message: message,
      stockId: stockId,
    );

    addNotification(notification);
  }

  /// Add a bonus notification
  void addBonusAlert({
    required String title,
    required String amount,
  }) {
    final notification = NotificationItem.bonus(
      id: _generateId(),
      title: title,
      amount: amount,
    );

    addNotification(notification);
  }

  /// Add an event notification
  void addEventAlert({
    required String eventName,
    required String description,
    required bool isPositive,
  }) {
    if (!_eventAlertsEnabled) return;

    final notification = NotificationItem.event(
      id: _generateId(),
      eventName: eventName,
      description: description,
      isPositive: isPositive,
    );

    addNotification(notification);
  }

  /// Mark a notification as read
  void markAsRead(String notificationId) {
    final notification = _notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => throw Exception('Notification not found'),
    );

    notification.markAsRead();
    notifyListeners();
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (final notification in _notifications) {
      notification.markAsRead();
    }
    notifyListeners();
  }

  /// Dismiss a notification
  void dismissNotification(String notificationId) {
    final notification = _notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => throw Exception('Notification not found'),
    );

    notification.dismiss();
    notifyListeners();
  }

  /// Clear all notifications
  void clearAll() {
    for (final notification in _notifications) {
      notification.dismiss();
    }
    notifyListeners();
  }

  /// Full reset - remove everything
  void resetAll() {
    _notifications.clear();
    _notificationIdCounter = 0;
    _toastQueue.clear();
    _currentToast = null;
    notifyListeners();
  }

  /// Get notifications by type
  List<NotificationItem> getByType(NotificationType type) {
    return notifications.where((n) => n.type == type).toList();
  }

  /// Get notifications by priority
  List<NotificationItem> getByPriority(NotificationPriority priority) {
    return notifications.where((n) => n.priority == priority).toList();
  }

  /// Update settings
  void updateSettings({
    bool? priceAlerts,
    bool? newsAlerts,
    bool? achievementAlerts,
    bool? fintokAlerts,
    bool? eventAlerts,
  }) {
    if (priceAlerts != null) _priceAlertsEnabled = priceAlerts;
    if (newsAlerts != null) _newsAlertsEnabled = newsAlerts;
    if (achievementAlerts != null) _achievementAlertsEnabled = achievementAlerts;
    if (fintokAlerts != null) _fintokAlertsEnabled = fintokAlerts;
    if (eventAlerts != null) _eventAlertsEnabled = eventAlerts;
    notifyListeners();
  }

  /// Reset service (for new game)
  void reset() {
    _notifications.clear();
    _toastQueue.clear();
    _currentToast = null;
    _notificationIdCounter = 0;
    notifyListeners();
  }

  // JSON serialization for save/load
  Map<String, dynamic> toJson() => {
    'notifications': _notifications.map((n) => n.toJson()).toList(),
    'notificationIdCounter': _notificationIdCounter,
    'priceAlertsEnabled': _priceAlertsEnabled,
    'newsAlertsEnabled': _newsAlertsEnabled,
    'achievementAlertsEnabled': _achievementAlertsEnabled,
    'fintokAlertsEnabled': _fintokAlertsEnabled,
    'eventAlertsEnabled': _eventAlertsEnabled,
  };

  void loadFromJson(Map<String, dynamic> json) {
    _notifications.clear();

    if (json['notifications'] != null) {
      for (final notifJson in json['notifications']) {
        _notifications.add(NotificationItem.fromJson(notifJson));
      }
    }

    _notificationIdCounter = json['notificationIdCounter'] ?? 0;
    _priceAlertsEnabled = json['priceAlertsEnabled'] ?? true;
    _newsAlertsEnabled = json['newsAlertsEnabled'] ?? true;
    _achievementAlertsEnabled = json['achievementAlertsEnabled'] ?? true;
    _fintokAlertsEnabled = json['fintokAlertsEnabled'] ?? true;
    _eventAlertsEnabled = json['eventAlertsEnabled'] ?? true;

    notifyListeners();
  }
}

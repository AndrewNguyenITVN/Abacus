import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/app_notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Callback để lưu notification vào storage
  Function(AppNotification)? onNotificationCreated;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Initialize the plugin
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    await _requestPermissions();

    _initialized = true;
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.requestNotificationsPermission();
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  /// Show a generic notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    required NotificationType type,
  }) async {
    // Determine color based on type
    Color color = const Color(0xFF2196F3); // Default blue
    if (type == NotificationType.spending) {
      color = const Color(0xFFFF9800); // Orange
    } else if (type == NotificationType.savingsGoal) {
      color = const Color(0xFF4CAF50); // Green
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'abacus_notifications',
      'Abacus Notifications',
      channelDescription: 'General notifications for Abacus',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: color,
      playSound: true,
      enableVibration: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      _generateNotificationId(),
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    // Lưu vào storage
    _saveToStorage(
      title: title,
      body: body,
      type: type,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Generate unique notification ID
  int _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    return await androidImplementation?.areNotificationsEnabled() ?? false;
  }

  // --- Settings Management (Instance Methods now) ---

  static const String _thresholdKey = 'spending_threshold';
  static const String _enabledKey = 'spending_notifications_enabled';
  static const String _savingsGoalEnabledKey =
      'savings_goal_notifications_enabled';

  /// Get user-defined spending threshold (%). Default 70.
  Future<int> getThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_thresholdKey) ?? 70;
  }

  /// Check if spending notifications are enabled (default true)
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true;
  }

  /// Set enable/disable spending notifications
  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }

  /// Check if savings goal notifications are enabled (default true)
  Future<bool> isSavingsGoalEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_savingsGoalEnabledKey) ?? true;
  }

  /// Set enable/disable savings goal notifications
  Future<void> setSavingsGoalEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_savingsGoalEnabledKey, value);
  }

  /// Save user-defined threshold
  Future<void> setThreshold(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_thresholdKey, value);
  }

  // --- State Management for Notifications ---

  /// Key for last notified percent eg last_notified_percent_2025_11
  String _notifiedKeyForMonth(DateTime date) =>
      'last_notified_percent_${date.year}_${date.month}';

  /// Get last percent notified this month
  Future<double> getLastNotifiedPercent(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _notifiedKeyForMonth(date);
    final storedPercent = prefs.getDouble(key) ?? -5; // ensure first alert

    if (storedPercent.truncate() != storedPercent && storedPercent != -5) {
      await prefs.remove(key);
      return -5;
    }

    return storedPercent;
  }

  /// Save last notified percent
  Future<void> setLastNotifiedPercent(
    DateTime date,
    double percent,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_notifiedKeyForMonth(date), percent);
  }

  /// Lưu notification vào storage thông qua callback
  void _saveToStorage({
    required String title,
    required String body,
    required NotificationType type,
  }) {
    if (onNotificationCreated != null) {
      final notification = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        type: type,
        createdAt: DateTime.now(),
      );
      onNotificationCreated!(notification);
    }
  }
}

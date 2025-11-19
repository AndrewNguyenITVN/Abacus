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

  /// Show notification when savings goal is reached (100%)
  Future<void> showSavingsGoalReachedNotification({
    required String goalName,
    required double amount,
  }) async {
    final title = '🎉 Chúc mừng! Bạn đã đạt mục tiêu!';
    final body =
        'Bạn đã đủ tiền để $goalName với số tiền ${_formatCurrency(amount)}!';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'savings_goals',
          'Savings Goals',
          channelDescription: 'Notifications for savings goals achievements',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF4CAF50),
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      _generateNotificationId(),
      title,
      body,
      notificationDetails,
      payload: 'savings_goal_reached',
    );

    // Lưu vào storage
    _saveToStorage(
      title: title,
      body: body,
      type: NotificationType.savingsGoal,
    );
  }

  /// Show notification when spending exceeds threshold
  Future<void> showSpendingWarningNotification({
    required double percentage,
    required double totalSpent,
    required double monthlyIncome,
  }) async {
    // Determine severity based on percentage
    final bool isCritical = percentage >= 90;
    final String emoji = isCritical ? '🚨' : '⚠️';
    final int color = isCritical ? 0xFFFF5252 : 0xFFFF9800;

    final String title = isCritical
        ? '$emoji Cảnh báo: Chi tiêu vượt mức!'
        : '$emoji Thông báo: Chi tiêu cao!';

    final String body =
        'Bạn đã chi ${_formatCurrency(totalSpent)} (${percentage.toStringAsFixed(0)}% thu nhập tháng ${_formatCurrency(monthlyIncome)})';

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'spending_warnings',
          'Spending Warnings',
          channelDescription: 'Notifications for spending alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(color),
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
      payload: 'spending_warning_$percentage',
    );

    // Lưu vào storage
    _saveToStorage(title: title, body: body, type: NotificationType.spending);
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

  /// Format currency for Vietnamese Dong
  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} tỷ';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} triệu';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)} nghìn';
    }
    return amount.toStringAsFixed(0);
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    return await androidImplementation?.areNotificationsEnabled() ?? false;
  }

  static const String _thresholdKey = 'spending_threshold';
  static const String _enabledKey = 'spending_notifications_enabled';
  static const String _savingsGoalEnabledKey =
      'savings_goal_notifications_enabled';

  /// Get user-defined spending threshold (%). Default 70.
  static Future<int> getThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_thresholdKey) ?? 70;
  }

  /// Check if spending notifications are enabled (default true)
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true;
  }

  /// Set enable/disable spending notifications
  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }

  /// Check if savings goal notifications are enabled (default true)
  static Future<bool> isSavingsGoalEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_savingsGoalEnabledKey) ?? true;
  }

  /// Set enable/disable savings goal notifications
  static Future<void> setSavingsGoalEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_savingsGoalEnabledKey, value);
  }

  /// Save user-defined threshold
  static Future<void> setThreshold(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_thresholdKey, value);
  }

  /// Key for last notified percent eg last_notified_percent_2025_11
  static String _notifiedKeyForMonth(DateTime date) =>
      'last_notified_percent_${date.year}_${date.month}';

  /// Get last percent notified this month
  static Future<double> getLastNotifiedPercent(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _notifiedKeyForMonth(date);
    final storedPercent = prefs.getDouble(key) ?? -5; // ensure first alert

    if (storedPercent.truncate() != storedPercent && storedPercent != -5) {
      print(
        '--- [Data Correction] Found old invalid lastPercent: $storedPercent. Resetting. ---',
      );
      await prefs.remove(key); // Remove the bad data
      return -5; // Return default to allow notifications to resume this month
    }

    return storedPercent;
  }

  /// Save last notified percent
  static Future<void> setLastNotifiedPercent(
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

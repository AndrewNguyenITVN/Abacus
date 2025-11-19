import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

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
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

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

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notifications.show(
      _generateNotificationId(),
      '🎉 Chúc mừng! Bạn đã đạt mục tiêu!',
      'Bạn đã đủ tiền để $goalName với số tiền ${_formatCurrency(amount)}!',
      notificationDetails,
      payload: 'savings_goal_reached',
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

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    final String title = isCritical
        ? '$emoji Cảnh báo: Chi tiêu vượt mức!'
        : '$emoji Thông báo: Chi tiêu cao!';

    final String body =
        'Bạn đã chi ${_formatCurrency(totalSpent)} (${percentage.toStringAsFixed(0)}% thu nhập tháng ${_formatCurrency(monthlyIncome)})';

    await _notifications.show(
      _generateNotificationId(),
      title,
      body,
      notificationDetails,
      payload: 'spending_warning_$percentage',
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
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    return await androidImplementation?.areNotificationsEnabled() ?? false;
  }
}


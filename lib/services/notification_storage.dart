import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/app_notification.dart';

/// Service lưu trữ thông báo vào SharedPreferences
class NotificationStorage {
  static const String _key = 'app_notifications';
  static const int _maxNotifications = 20;

  /// Load danh sách thông báo
  static Future<List<AppNotification>> loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_key);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading notifications: $e');
      return [];
    }
  }

  /// Lưu danh sách thông báo
  static Future<bool> saveNotifications(
    List<AppNotification> notifications,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Giới hạn số lượng, giữ 20 thông báo mới nhất
      final limitedNotifications = notifications.length > _maxNotifications
          ? notifications.sublist(0, _maxNotifications)
          : notifications;

      final jsonList = limitedNotifications.map((n) => n.toJson()).toList();
      final jsonString = json.encode(jsonList);

      return await prefs.setString(_key, jsonString);
    } catch (e) {
      print('Error saving notifications: $e');
      return false;
    }
  }

  /// Xóa tất cả thông báo
  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_key);
    } catch (e) {
      print('Error clearing notifications: $e');
      return false;
    }
  }
}


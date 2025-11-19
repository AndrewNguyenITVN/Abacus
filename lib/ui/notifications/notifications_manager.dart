import 'package:flutter/material.dart';
import '/models/app_notification.dart';
import '/services/notification_storage.dart';

/// Manager quản lý state của notifications
class NotificationsManager extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  List<AppNotification> get notifications => [..._notifications];
  bool get isLoading => _isLoading;

  /// Số lượng thông báo chưa đọc
  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  /// Có thông báo chưa đọc không
  bool get hasUnread => unreadCount > 0;

  /// Load notifications từ storage
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await NotificationStorage.loadNotifications();
      // Sort by createdAt desc (mới nhất ở trên)
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Thêm notification mới
  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
    await _saveToStorage();
    notifyListeners();
  }

  /// Đánh dấu đã đọc
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveToStorage();
      notifyListeners();
    }
  }

  /// Đánh dấu tất cả đã đọc
  Future<void> markAllAsRead() async {
    bool hasChanges = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await _saveToStorage();
      notifyListeners();
    }
  }

  /// Xóa một notification
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    await _saveToStorage();
    notifyListeners();
  }

  /// Xóa tất cả notifications
  Future<void> clearAll() async {
    _notifications.clear();
    await NotificationStorage.clearAll();
    notifyListeners();
  }

  /// Lưu vào storage
  Future<void> _saveToStorage() async {
    await NotificationStorage.saveNotifications(_notifications);
  }
}


import 'package:flutter/material.dart';

/// Loại thông báo
enum NotificationType {
  savingsGoal,  // Đạt mục tiêu tiết kiệm
  spending,     // Cảnh báo chi tiêu
  system,       // Thông báo hệ thống
}

/// Model thông báo trong app
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? payload;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.payload,
  });

  // Copy with
  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? payload,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      payload: payload ?? this.payload,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'payload': payload,
    };
  }

  // From JSON
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      payload: json['payload'] as String?,
    );
  }

  // Get icon theo loại
  IconData get icon {
    switch (type) {
      case NotificationType.savingsGoal:
        return Icons.celebration_rounded;
      case NotificationType.spending:
        return Icons.warning_amber_rounded;
      case NotificationType.system:
        return Icons.info_rounded;
    }
  }

  // Get color theo loại
  Color get color {
    switch (type) {
      case NotificationType.savingsGoal:
        return Colors.green;
      case NotificationType.spending:
        return Colors.orange;
      case NotificationType.system:
        return Colors.blue;
    }
  }
}


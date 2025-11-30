import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/models/notifications/notifications_model.dart';
import '../enum/enum_notification_helper.dart';

extension NotificationModelExtensions on NotificationModel {
  NotificationType get notificationType {
    return NotificationType.fromString(typeNotification);
  }

  NotificationStatus get notificationStatus {
    return NotificationStatus.fromString(statusNotification);
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(sentAt);

    if (difference.inDays > 7) {
      return '${sentAt.day}/${sentAt.month}/${sentAt.year}';
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora mismo';
    }
  }

  bool get hasLink => linkNotification != null && linkNotification!.isNotEmpty;

  Color get backgroundColor {
    if (!isRead) return Colors.blue.shade50;
    return Colors.transparent;
  }

  FontWeight get titleFontWeight {
    return isRead ? FontWeight.normal : FontWeight.bold;
  }

  Color get titleColor {
    return isRead ? Colors.grey.shade700 : Colors.black;
  }
}

extension NotificationListExtensions on List<NotificationModel> {
  List<NotificationModel> get unreadNotifications {
    return where((notification) => !notification.isRead).toList();
  }

  List<NotificationModel> get readNotifications {
    return where((notification) => notification.isRead).toList();
  }

  List<NotificationModel> get recentNotifications {
    return where((notification) => notification.isRecent).toList();
  }

  List<NotificationModel> get byDateDesc {
    return sorted((a, b) => b.sentAt.compareTo(a.sentAt));
  }

  List<NotificationModel> get byDateAsc {
    return sorted((a, b) => a.sentAt.compareTo(b.sentAt));
  }

  List<NotificationModel> sorted(int Function(NotificationModel, NotificationModel) compare) {
    return toList()..sort(compare);
  }

  Map<String, List<NotificationModel>> groupByType() {
    final Map<String, List<NotificationModel>> result = {};
    for (final notification in this) {
      final type = notification.typeNotification;
      if (!result.containsKey(type)) {
        result[type] = [];
      }
      result[type]!.add(notification);
    }
    return result;
  }

  Map<String, List<NotificationModel>> groupByDate() {
    final Map<String, List<NotificationModel>> result = {};
    for (final notification in this) {
      final dateKey = '${notification.sentAt.year}-${notification.sentAt.month}-${notification.sentAt.day}';
      if (!result.containsKey(dateKey)) {
        result[dateKey] = [];
      }
      result[dateKey]!.add(notification);
    }
    return result;
  }
}
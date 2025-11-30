import '../../models/notifications/notifications_model.dart';
import '../response_crop/response_crop.dart';

class NotificationResponse {
  final bool success;
  final String message;
  final NotificationModel? data;

  NotificationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? NotificationModel.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class NotificationListResponse {
  final bool success;
  final String message;
  final NotificationListData data;

  NotificationListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    return NotificationListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: NotificationListData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class NotificationListData {
  final List<NotificationModel> notifications;
  final PaginationInfo pagination;

  NotificationListData({
    required this.notifications,
    required this.pagination,
  });

  factory NotificationListData.fromJson(Map<String, dynamic> json) {
    return NotificationListData(
      notifications: (json['notifications'] as List? ?? [])
          .map((item) => NotificationModel.fromJson(item))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.map((n) => n.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class UnreadCountResponse {
  final bool success;
  final String? message;
  final int unreadCount;

  UnreadCountResponse({
    required this.success,
    this.message,
    required this.unreadCount,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      success: json['success'] ?? false,
      message: json['message'],
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'unread_count': unreadCount,
    };
  }
}
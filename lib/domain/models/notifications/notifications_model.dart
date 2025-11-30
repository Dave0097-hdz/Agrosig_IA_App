import 'dart:convert';

class NotificationModel {
  final int notificationId;
  final int userId;
  final String typeNotification;
  final String titleNotification;
  final String messageNotification;
  final String statusNotification;
  final String? linkNotification;
  final DateTime sentAt;
  final bool isRead;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.typeNotification,
    required this.titleNotification,
    required this.messageNotification,
    required this.statusNotification,
    this.linkNotification,
    required this.sentAt,
    required this.isRead,
  });

  // Factory constructor para crear instancia desde JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      typeNotification: json['type_notification'] ?? 'general',
      titleNotification: json['title_notification'] ?? '',
      messageNotification: json['message_notification'] ?? '',
      statusNotification: json['status_notification'] ?? 'sent',
      linkNotification: json['link_notification'],
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at']).toLocal()
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'type_notification': typeNotification,
      'title_notification': titleNotification,
      'message_notification': messageNotification,
      'status_notification': statusNotification,
      'link_notification': linkNotification,
      'sent_at': sentAt.toUtc().toIso8601String(),
      'is_read': isRead,
    };
  }

  // Método copyWith para inmutabilidad
  NotificationModel copyWith({
    int? notificationId,
    int? userId,
    String? typeNotification,
    String? titleNotification,
    String? messageNotification,
    String? statusNotification,
    String? linkNotification,
    DateTime? sentAt,
    bool? isRead,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      typeNotification: typeNotification ?? this.typeNotification,
      titleNotification: titleNotification ?? this.titleNotification,
      messageNotification: messageNotification ?? this.messageNotification,
      statusNotification: statusNotification ?? this.statusNotification,
      linkNotification: linkNotification ?? this.linkNotification,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }

  // Método para comparar notificaciones
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.notificationId == notificationId &&
        other.userId == userId &&
        other.typeNotification == typeNotification &&
        other.titleNotification == titleNotification &&
        other.messageNotification == messageNotification &&
        other.statusNotification == statusNotification &&
        other.linkNotification == linkNotification &&
        other.sentAt == sentAt &&
        other.isRead == isRead;
  }

  @override
  int get hashCode {
    return notificationId.hashCode ^
    userId.hashCode ^
    typeNotification.hashCode ^
    titleNotification.hashCode ^
    messageNotification.hashCode ^
    statusNotification.hashCode ^
    linkNotification.hashCode ^
    sentAt.hashCode ^
    isRead.hashCode;
  }

  // Método toString para debugging
  @override
  String toString() {
    return 'NotificationModel('
        'id: $notificationId, '
        'type: $typeNotification, '
        'title: $titleNotification, '
        'isRead: $isRead, '
        'sentAt: $sentAt'
        ')';
  }

  // Método para verificar si es reciente (últimas 24 horas)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(sentAt);
    return difference.inHours <= 24;
  }

  // Método para obtener icono basado en el tipo
  String get iconAsset {
    switch (typeNotification) {
      case 'weather':
        return 'assets/icons/weather.png';
      case 'activity_reminder':
        return 'assets/icons/activity.png';
      case 'system':
        return 'assets/icons/system.png';
      case 'alert':
        return 'assets/icons/alert.png';
      default:
        return 'assets/icons/notification.png';
    }
  }
}
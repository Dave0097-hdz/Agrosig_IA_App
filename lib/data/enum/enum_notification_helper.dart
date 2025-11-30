import 'package:flutter/material.dart';

enum NotificationType {
  weather('weather', 'Clima', Icons.cloud),
  activityReminder('activity_reminder', 'Actividad', Icons.calendar_today),
  system('system', 'Sistema', Icons.settings),
  alert('alert', 'Alerta', Icons.warning),
  general('general', 'General', Icons.notifications);

  final String value;
  final String displayName;
  final IconData icon;

  const NotificationType(this.value, this.displayName, this.icon);

  factory NotificationType.fromString(String value) {
    return NotificationType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => NotificationType.general,
    );
  }

  Color get color {
    switch (this) {
      case NotificationType.weather:
        return Colors.blue;
      case NotificationType.activityReminder:
        return Colors.green;
      case NotificationType.system:
        return Colors.orange;
      case NotificationType.alert:
        return Colors.red;
      case NotificationType.general:
        return Colors.grey;
    }
  }
}

enum NotificationStatus {
  sent('sent', 'Enviado'),
  read('read', 'Leído'),
  pending('pending', 'Pendiente');

  final String value;
  final String displayName;

  const NotificationStatus(this.value, this.displayName);

  factory NotificationStatus.fromString(String value) {
    return NotificationStatus.values.firstWhere(
          (status) => status.value == value,
      orElse: () => NotificationStatus.sent,
    );
  }
}
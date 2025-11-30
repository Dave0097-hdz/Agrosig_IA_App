import 'package:flutter/material.dart';
import '../../data/enum/enum_notification_helper.dart';
import '../../data/helper_notification/helper_notification_extension.dart';
import '../../domain/models/notifications/notifications_model.dart';

class NotificationDetailDialog extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailDialog({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final type = notification.notificationType;
    final isWeather = type == NotificationType.weather;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: type.color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: type.color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(type.icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        type.displayName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: type.color,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.titleNotification,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mensaje principal
                  _buildMessageContent(),

                  const SizedBox(height: 20),

                  // Información de fecha y estado
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          notification.formattedDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        if (!notification.isRead)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'NO LEÍDA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Información adicional específica por tipo
                  if (isWeather) _buildWeatherDetails(),
                ],
              ),
            ),

            // Botones de acción
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (!notification.isRead) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: type.color),
                        ),
                        child: Text(
                          'Marcar como leída',
                          style: TextStyle(
                            fontSize: 16,
                            color: type.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: type.color,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    if (notification.typeNotification == 'weather') {
      return _buildWeatherMessage();
    } else {
      return Text(
        notification.messageNotification,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.5,
        ),
      );
    }
  }

  Widget _buildWeatherMessage() {
    final message = notification.messageNotification;

    // Extraer información del mensaje de clima
    String description = '';
    String temperature = '';
    String maxTemp = '';
    String minTemp = '';
    String humidity = '';

    try {
      final descMatch = RegExp(r'Hoy:\s*([^.]*)').firstMatch(message);
      final tempMatch = RegExp(r'Temp:\s*([^°]*)°C').firstMatch(message);
      final maxMinMatch = RegExp(r'Max:\s*([^°]*)°C.*Min:\s*([^°]*)°C').firstMatch(message);
      final humidityMatch = RegExp(r'Humedad:\s*(\d+%)').firstMatch(message);

      description = descMatch?.group(1)?.trim() ?? '';
      temperature = tempMatch?.group(1)?.trim() ?? '';
      maxTemp = maxMinMatch?.group(1)?.trim() ?? '';
      minTemp = maxMinMatch?.group(2)?.trim() ?? '';
      humidity = humidityMatch?.group(1)?.trim() ?? '';
    } catch (e) {
      print('Error parsing weather message: $e');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (description.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.cloud, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Grid de información meteorológica
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              if (temperature.isNotEmpty) _buildWeatherInfoItem(
                'Temperatura Actual',
                '$temperature°C',
                Icons.thermostat,
                Colors.orange,
              ),
              if (maxTemp.isNotEmpty && minTemp.isNotEmpty) _buildWeatherInfoItem(
                'Temperatura (Max/Min)',
                '$maxTemp°C / $minTemp°C',
                Icons.arrow_upward,
                Colors.red,
              ),
              if (humidity.isNotEmpty) _buildWeatherInfoItem(
                'Humedad',
                humidity,
                Icons.water_drop,
                Colors.blue,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Información meteorológica actualizada',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherInfoItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Detalles Adicionales',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Esta información se actualiza automáticamente según los datos meteorológicos más recientes de tu ubicación.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
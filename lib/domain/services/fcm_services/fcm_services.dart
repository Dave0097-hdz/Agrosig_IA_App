import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../config/keys.dart';
import '../../../data/core/custom_http_client.dart';
import '../../../data/local_secure/secure_storage.dart';
import '../../models/notifications/notifications_model.dart';
import '../../response/response_crop/response_crop.dart';
import '../../response/response_notification/response_notification.dart';

class FcmServices {
  final SecureStorageAgroSig _secureStorage = SecureStorageAgroSig();
  final http.Client _client;

  FcmServices() : _client = CustomHttpClient.create();

  // Registrar token FCM
  Future<NotificationResponse> registerFCMToken(String fcmToken,
      {String deviceType = 'mobile'}) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.post(
        Uri.parse('${Environment.fcm}/register-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
        body: jsonEncode({
          'fcm_token': fcmToken,
          'device_type': deviceType,
        }),
      );

      print('Register FCM Token Status: ${response.statusCode}');
      print('Register FCM Token Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return NotificationResponse(
          success: true,
          message: decodedData['message'] ?? 'Token registrado exitosamente',
        );
      } else {
        final errorData = json.decode(response.body);
        return NotificationResponse(
          success: false,
          message: errorData['message'] ?? 'Error al registrar el token FCM',
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error registering FCM token: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  // Eliminar token FCM
  Future<NotificationResponse> unregisterFCMToken(String fcmToken) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.post(
        Uri.parse('${Environment.fcm}/unregister-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
        body: jsonEncode({
          'fcm_token': fcmToken,
        }),
      );

      print('Unregister FCM Token Status: ${response.statusCode}');
      print('Unregister FCM Token Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return NotificationResponse(
          success: true,
          message: decodedData['message'] ?? 'Token eliminado exitosamente',
        );
      } else {
        final errorData = json.decode(response.body);
        return NotificationResponse(
          success: false,
          message: errorData['message'] ?? 'Error al eliminar el token FCM',
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error unregistering FCM token: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  // Obtener notificaciones del usuario
  Future<NotificationListResponse> getUserNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
    bool todayOnly = false,
  }) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      // Calcula offset basado en página
      final offset = (page - 1) * limit;

      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
        'unread_only': unreadOnly.toString(),
      };

      final uri =
          Uri.parse('${Environment.notifications}/notifications').replace(
        queryParameters: queryParams,
      );

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Get Notifications Status: ${response.statusCode}');
      print('Get Notifications Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final notifications = (responseData['notifications'] as List? ?? [])
            .map((item) => NotificationModel.fromJson(item))
            .toList();

        final total = responseData['total'] ?? notifications.length;
        final hasMore = notifications.length == limit;

        return NotificationListResponse(
          success: true,
          message: 'Notificaciones obtenidas exitosamente',
          data: NotificationListData(
            notifications: notifications,
            pagination: PaginationInfo(
              currentPage: page,
              perPage: limit,
              total: total,
              totalPages: (total / limit).ceil(),
              hasNext: page < (total / limit).ceil(),
              hasPrev: page > 1,
            ),
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        return NotificationListResponse(
          success: false,
          message: errorData['message'] ?? 'Error al obtener notificaciones',
          data: NotificationListData(
            notifications: [],
            pagination: PaginationInfo(
              currentPage: page,
              perPage: limit,
              total: 0,
              totalPages: 1,
              hasNext: false,
              hasPrev: false,
            ),
          ),
        );
      }
    } catch (error) {
      print('Error in getUserNotifications: $error');
      return NotificationListResponse(
        success: false,
        message: 'Error de conexión: $error',
        data: NotificationListData(
          notifications: [],
          pagination: PaginationInfo(
            currentPage: page,
            perPage: limit,
            total: 0,
            totalPages: 1,
            hasNext: false,
            hasPrev: false,
          ),
        ),
      );
    }
  }

  // Marcar notificación como leída
  Future<NotificationResponse> markAsRead(String notificationId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.put(
        Uri.parse('${Environment.notifications}/read/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Mark as Read Status: ${response.statusCode}');
      print('Mark as Read Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return NotificationResponse(
          success: true,
          message: decodedData['message'] ?? 'Notificación marcada como leída',
        );
      } else {
        final errorData = json.decode(response.body);
        return NotificationResponse(
          success: false,
          message:
              errorData['message'] ?? 'Error al marcar notificación como leída',
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error marking notification as read: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  // Marcar todas como leídas
  Future<NotificationResponse> markAllAsRead() async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.put(
        Uri.parse('${Environment.notifications}/read-all'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Mark All as Read Status: ${response.statusCode}');
      print('Mark All as Read Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return NotificationResponse(
          success: true,
          message: decodedData['message'] ??
              'Todas las notificaciones marcadas como leídas',
        );
      } else {
        final errorData = json.decode(response.body);
        return NotificationResponse(
          success: false,
          message: errorData['message'] ??
              'Error al marcar todas las notificaciones como leídas',
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error marking all notifications as read: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  // Obtener conteo de no leídas
  Future<UnreadCountResponse> getUnreadCount() async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse('${Environment.notifications}/unread/count'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Get Unread Count Status: ${response.statusCode}');
      print('Get Unread Count Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        // ✅ SIMPLIFICADO - El backend devuelve unread_count directamente
        final unreadCount = decodedData['unread_count'] ?? 0;

        return UnreadCountResponse(
          success: true,
          unreadCount: unreadCount,
        );
      } else {
        final errorData = json.decode(response.body);
        return UnreadCountResponse(
          success: false,
          message:
              errorData['message'] ?? 'Error al obtener el conteo de no leídas',
          unreadCount: 0,
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error getting unread count: $error');
      return UnreadCountResponse(
        success: false,
        message: 'Error en el servidor: ${error.toString()}',
        unreadCount: 0,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

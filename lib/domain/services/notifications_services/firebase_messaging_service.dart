import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../../data/local_secure/secure_storage.dart';
import '../fcm_services/fcm_services.dart';
import '../../../screens/notifications/notifications_screen.dart';
import '../../models/notifications/notifications_model.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FcmServices _notificationRepo = FcmServices();

  // Local notifications
  late FlutterLocalNotificationsPlugin _localNotifications;

  // Stream para notificaciones en tiempo real
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  // Stream para actualización del contador
  final StreamController<int> _unreadCountController =
      StreamController<int>.broadcast();
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  Future<void> initialize() async {
    try {
      // Inicializar notificaciones locales
      await _initializeLocalNotifications();

      // Solicitar permisos
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('User granted permission: ${settings.authorizationStatus}');

      // Configurar token y handlers
      await _setupFCMToken();
      await _setupNotificationHandlers();

      // Configurar manejo de temas (opcional)
      await _setupTopicSubscription();
    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleLocalNotificationTap(response);
      },
    );
  }

  StreamController<List<NotificationModel>> _notificationsListController =
      StreamController<List<NotificationModel>>.broadcast();
  Stream<List<NotificationModel>> get notificationsListStream =>
      _notificationsListController.stream;

  Future<void> _setupFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM Token obtenido: $token');
        _storeFCMToken(token);
      }

      // Escuchar refresco de token
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        print('Token refrescado: $newToken');
        _storeFCMToken(newToken);
        final accessToken = await SecureStorageAgroSig().getAccessToken();
        if (accessToken != null) {
          await _notificationRepo.registerFCMToken(newToken);
        }
      });
    } catch (e) {
      print('Error setting up FCM token: $e');
    }
  }

  void _storeFCMToken(String token) {
    // Guardar token localmente para referencia
    SecureStorageAgroSig().setFCMToken(token);
  }

  Future<void> _setupNotificationHandlers() async {
    // Notificación en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificación en primer plano: ${message.notification?.title}');
      _handleForegroundNotification(message);
    });

    // App abierta desde notificación en segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App abierta desde notificación en segundo plano');
      _handleBackgroundNotificationTap(message);
    });

    // App abierta desde notificación estando cerrada
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundNotificationTap(initialMessage);
    }
  }

  Future<void> _setupTopicSubscription() async {
    try {
      // Suscribirse a temas globales si es necesario
      await _firebaseMessaging.subscribeToTopic('all_users');
      await _firebaseMessaging.subscribeToTopic('weather_updates');
      print('Subscribed to default topics');
    } catch (e) {
      print('Error subscribing to topics: $e');
    }
  }

  void _handleForegroundNotification(RemoteMessage message) {
    print(
        'Manejando notificación en foreground: ${message.notification?.title}');

    // Mostrar notificación local
    _showLocalNotification(message);

    // Crear un objeto NotificationModel temporal a partir del mensaje
    final tempNotification = NotificationModel(
      notificationId: DateTime.now().millisecondsSinceEpoch,
      userId: 0, // Se actualizará cuando se sincronice con el backend
      typeNotification: message.data['type'] ?? 'general',
      titleNotification: message.notification?.title ?? 'Nueva notificación',
      messageNotification: message.notification?.body ?? '',
      statusNotification: 'sent',
      linkNotification: null,
      sentAt: DateTime.now(),
      isRead: false,
    );

    // Emitir a través del stream para actualización en tiempo real
    _notificationController.add({
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
      'timestamp': DateTime.now(),
      'type': 'foreground',
      'notification': tempNotification.toJson(),
    });

    // Forzar actualización de la lista desde el backend
    _triggerNotificationsRefresh();

    // Incrementar contador de no leídas
    _incrementUnreadCount();
  }

  // método para forzar actualización
  void _triggerNotificationsRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Verificar si el StreamController está cerrado antes de enviar eventos
        if (!_notificationsListController.isClosed) {
          _notificationsListController.add([]);
        }
      } catch (e) {
        print('Error triggering notifications refresh: $e');
      }
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'agrosig_channel_id',
        'AgroSig Notifications',
        channelDescription: 'Canal para notificaciones de AgroSig',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        autoCancel: true,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        message.notification?.title ?? 'Nueva notificación',
        message.notification?.body ?? '',
        platformChannelSpecifics,
        payload: message.data.isNotEmpty ? message.data.toString() : null,
      );

      print('Notificación local mostrada');
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  void _handleLocalNotificationTap(NotificationResponse response) {
    print('Notificación local tocada: ${response.payload}');

    // Procesar el payload si existe
    if (response.payload != null) {
      try {
        // Aquí puedes parsear el payload y navegar a la pantalla correspondiente
        print('Payload: ${response.payload}');
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }

    // Navegar a la pantalla de notificaciones usando GetX
    _navigateToNotificationsScreen();
  }

  void _handleBackgroundNotificationTap(RemoteMessage message) {
    final data = message.data;
    print('Manejando tap en notificación de background: $data');

    // Procesar datos de la notificación
    _processNotificationData(message.data);

    // Navegar a la pantalla correspondiente
    _navigateFromNotification(message.data);
  }

  void _processNotificationData(Map<String, dynamic> data) {
    try {
      final type = data['type'];
      print('Procesando notificación de tipo: $type');

      switch (type) {
        case 'weather':
          _handleWeatherNotification(data);
          break;
        case 'activity_reminder':
          _handleActivityNotification(data);
          break;
        case 'system':
          _handleSystemNotification(data);
          break;
        default:
          _handleGeneralNotification(data);
      }
    } catch (e) {
      print('Error processing notification data: $e');
    }
  }

  void _handleWeatherNotification(Map<String, dynamic> data) {
    print('Manejando notificación de clima: $data');
  }

  void _handleActivityNotification(Map<String, dynamic> data) {
    print('Manejando notificación de actividad: $data');
  }

  void _handleSystemNotification(Map<String, dynamic> data) {
    print('Manejando notificación de sistema: $data');
  }

  void _handleGeneralNotification(Map<String, dynamic> data) {
    print('Manejando notificación general: $data');
  }

  void _navigateFromNotification(Map<String, dynamic> data) {
    _navigateToNotificationsScreen();
  }

  void _navigateToNotificationsScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Verificar si ya estamos en la pantalla de notificaciones para evitar duplicados
      if (Get.currentRoute != '/notifications') {
        Get.to(() => NotificationsScreen());
      }
    });
  }

  void _incrementUnreadCount() {
    // Emitir evento de incremento a través del stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _unreadCountController.add(1); // Incrementar en 1
    });
  }

  // Registrar token después del login
  Future<void> registerTokenAfterLogin() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('Registrando token FCM después del login: $token');
        final response = await _notificationRepo.registerFCMToken(token);

        if (response.success) {
          print('Token FCM registrado exitosamente después del login');
          // Suscribirse a temas específicos del usuario
          await _subscribeToUserTopics();
        } else {
          print('Error registrando token FCM: ${response.message}');
        }
      }
    } catch (e) {
      print('Exception registrando token después del login: $e');
    }
  }

  Future<void> _subscribeToUserTopics() async {
    try {
      // Suscribirse a temas específicos del usuario
      final userId = await SecureStorageAgroSig().getUserId();
      if (userId != null) {
        await _firebaseMessaging.subscribeToTopic('user_$userId');
        print('Subscribed to user topic: user_$userId');
      }
    } catch (e) {
      print('Error subscribing to user topics: $e');
    }
  }

  // Eliminar token al hacer logout
  Future<void> unregisterTokenOnLogout() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('Eliminando token FCM durante logout: $token');
        final response = await _notificationRepo.unregisterFCMToken(token);

        if (response.success) {
          print('Token FCM eliminado exitosamente durante logout');
          // Desuscribirse de temas
          await _unsubscribeFromAllTopics();
        } else {
          print('Error eliminando token FCM: ${response.message}');
        }
      }

      // Limpiar token local - usando el método correcto de tu SecureStorage
      await SecureStorageAgroSig().removeFCMToken();
    } catch (e) {
      print('Exception eliminando token durante logout: $e');
    }
  }

  Future<void> _unsubscribeFromAllTopics() async {
    try {
      final userId = await SecureStorageAgroSig().getUserId();
      if (userId != null) {
        await _firebaseMessaging.unsubscribeFromTopic('user_$userId');
      }
      await _firebaseMessaging.unsubscribeFromTopic('all_users');
      await _firebaseMessaging.unsubscribeFromTopic('weather_updates');
      print('Unsubscribed from all topics');
    } catch (e) {
      print('Error unsubscribing from topics: $e');
    }
  }

  // Método para obtener el token actual
  Future<String?> getCurrentToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting current token: $e');
      return null;
    }
  }

  // Método para verificar permisos
  Future<NotificationSettings> getNotificationPermissions() async {
    return await _firebaseMessaging.getNotificationSettings();
  }

  // Método para solicitar permisos manualmente
  Future<NotificationSettings> requestPermissions() async {
    return await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // Método para limpiar todas las notificaciones locales
  Future<void> clearAllLocalNotifications() async {
    await _localNotifications.cancelAll();
    print('Todas las notificaciones locales canceladas');
  }

  // Método para establecer el badge count
  Future<void> setBadgeCount(int count) async {
    try {
      // Limpiar notificaciones existentes
      await _localNotifications.cancelAll();
      if (count > 0) {
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'badge_channel_id',
          'Badge Updates',
          channelDescription: 'Canal para actualizaciones de badge',
          importance: Importance.low,
          priority: Priority.low,
          showWhen: false,
        );

        NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: DarwinNotificationDetails(badgeNumber: count),
        );

        await _localNotifications.show(
          0,
          null, // Sin título
          null, // Sin cuerpo
          platformChannelSpecifics,
        );
      }
    } catch (e) {
      print('Error setting badge count: $e');
    }
  }

  // Método para suscribirse a temas específicos
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
    }
  }

  // Método para desuscribirse de temas
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic $topic: $e');
    }
  }

  // Método para limpiar recursos
  void dispose() {
    _notificationController.close();
    _unreadCountController.close();
    _notificationsListController
        .close(); // ← Asegurar que este también se cierre
    print('FirebaseMessagingService disposed');
  }

  // Método para debug
  void printDebugInfo() async {
    final token = await getCurrentToken();
    final permissions = await getNotificationPermissions();

    print('=== FCM Debug Info ===');
    print('Token: $token');
    print('Permissions: $permissions');
    print('=====================');
  }
}

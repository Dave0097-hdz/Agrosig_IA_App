import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../components/dialogs/notification_detail_dialog.dart';
import '../../components/toast/toats.dart';
import '../../data/enum/enum_notification_helper.dart';
import '../../data/helper_notification/helper_notification_extension.dart';
import '../../domain/services/fcm_services/fcm_services.dart';
import '../../domain/models/notifications/notifications_model.dart';
import '../../domain/services/notifications_services/firebase_messaging_service.dart';

enum NotificationFilter { all, unread, today }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FcmServices _notificationRepo = FcmServices();
  final FirebaseMessagingService _messagingService = FirebaseMessagingService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  int _unreadCount = 0;
  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMore = true;
  NotificationFilter _currentFilter = NotificationFilter.all;

  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _notificationStreamSubscription;
  StreamSubscription? _notificationsListStreamSubscription;

  // Añadir bandera para controlar el estado del widget
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupScrollListener();
    _setupNotificationListeners();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreNotifications();
      }
    });
  }

  void _setupNotificationListeners() {
    // Escuchar nuevas notificaciones individuales
    _notificationStreamSubscription =
        _messagingService.notificationStream.listen((event) {
      if (_isDisposed) return;
      print('Nueva notificación recibida en tiempo real');
      // Recargar la lista cuando llegue una nueva notificación
      _loadNotifications(isInitial: true);
      _loadUnreadCount();
    });

    // Escuchar eventos de refresco de lista
    _notificationsListStreamSubscription =
        _messagingService.notificationsListStream.listen((event) {
      if (_isDisposed) return;
      print('Refrescando lista de notificaciones');
      _loadNotifications(isInitial: true);
      _loadUnreadCount();
    });
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
    });

    await Future.wait([
      _loadNotifications(isInitial: true),
      _loadUnreadCount(),
    ]);
  }

  Future<void> _loadNotifications({bool isInitial = false}) async {
    try {
      if (isInitial) {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
      } else {
        setState(() {
          _isLoadingMore = true;
        });
      }

      final bool unreadOnly = _currentFilter == NotificationFilter.unread;

      final response = await _notificationRepo.getUserNotifications(
        page: _currentPage,
        limit: _limit,
        unreadOnly: unreadOnly,
      );

      // Verificar si el widget sigue montado antes de setState
      if (_isDisposed) return;

      if (response.success) {
        setState(() {
          if (_currentPage == 1) {
            _notifications = response.data.notifications;
          } else {
            _notifications.addAll(response.data.notifications);
          }
          _hasMore = response.data.pagination.hasNext;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        if (_isDisposed) return;
        setState(() {
          _hasError = true;
          _isLoading = false;
          _isLoadingMore = false;
        });
        showToast(message: response.message);
      }
    } catch (error) {
      if (_isDisposed) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
        _isLoadingMore = false;
      });
      showToast(message: 'Error cargando notificaciones');
      print('Error loading notifications: $error');
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final response = await _notificationRepo.getUnreadCount();
      if (response.success) {
        if (_isDisposed) return;
        setState(() {
          _unreadCount = response.unreadCount;
        });
      } else {
        showToast(message: response.message ?? 'Error cargando contador');
      }
    } catch (error) {
      print('Error loading unread count: $error');
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (!_hasMore || _isLoadingMore || _isLoading) return;

    setState(() {
      _currentPage++;
    });

    await _loadNotifications();
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      final response =
          await _notificationRepo.markAsRead(notificationId.toString());

      if (response.success) {
        if (_isDisposed) return;
        setState(() {
          // Remover la notificación de la lista si estamos en el filtro de no leídas
          if (_currentFilter == NotificationFilter.unread) {
            _notifications
                .removeWhere((n) => n.notificationId == notificationId);
          } else {
            // Solo marcar como leída si estamos viendo todas
            final index = _notifications
                .indexWhere((n) => n.notificationId == notificationId);
            if (index != -1) {
              _notifications[index] =
                  _notifications[index].copyWith(isRead: true);
            }
          }

          // Actualizar contador
          if (_unreadCount > 0) {
            _unreadCount--;
          }
        });

        showToast(message: response.message);
      } else {
        showToast(message: response.message);
      }
    } catch (error) {
      showToast(message: 'Error marcando como leída');
      print('Error marking as read: $error');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final response = await _notificationRepo.markAllAsRead();

      if (response.success) {
        if (_isDisposed) return;
        setState(() {
          _notifications = _notifications
              .map((notification) => notification.copyWith(isRead: true))
              .toList();
          _unreadCount = 0;
        });

        showToast(message: response.message);
      } else {
        showToast(message: response.message);
      }
    } catch (error) {
      showToast(message: 'Error marcando todas como leídas');
      print('Error marking all as read: $error');
    }
  }

  void _changeFilter(NotificationFilter filter) {
    if (_isDisposed) return;
    setState(() {
      _currentFilter = filter;
      _currentPage = 1;
      _hasMore = true;
    });
    _loadNotifications(isInitial: true);
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final type = notification.notificationType;
    final isUnread = !notification.isRead;
    final isWeather = type == NotificationType.weather;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!notification.isRead) {
              _markAsRead(notification.notificationId);
            }
            _handleNotificationTap(notification);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: isUnread
                  ? Border.all(
                      color: type.color.withOpacity(0.3),
                      width: 2,
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
              gradient: isUnread
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        type.color.withOpacity(0.05),
                        type.color.withOpacity(0.02),
                      ],
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono con indicador de estado
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: type.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        type.icon,
                        color: type.color,
                        size: 24,
                      ),
                    ),
                    if (isUnread)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: type.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 16),

                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con título y badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título principal
                                Text(
                                  notification.titleNotification,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                // Subtítulo específico para clima
                                if (isWeather) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Clima',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 6),

                                // Mensaje de notificación
                                _buildNotificationMessage(notification),
                              ],
                            ),
                          ),

                          // Badge para no leídas
                          if (isUnread)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: type.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'NUEVO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: type.color,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Footer con fecha y acciones
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification.formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const Spacer(),

                          // Botón de acción
                          if (isUnread) _buildActionButton(notification),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationMessage(NotificationModel notification) {
    if (notification.typeNotification == 'weather') {
      // Parsear el mensaje de clima para mejor presentación
      final message = notification.messageNotification;

      // Extraer información del mensaje de clima
      String description = '';
      String temperature = '';
      String humidity = '';

      try {
        // Ejemplo de mensaje: "Hoy: nubes. Temp: 15.42°C (Max: 15.42°C, Min: 15.42°C). Humedad: 93%"
        final descMatch = RegExp(r'Hoy:\s*([^.]*)').firstMatch(message);
        final tempMatch = RegExp(r'Temp:\s*([^(]*)').firstMatch(message);
        final humidityMatch = RegExp(r'Humedad:\s*(\d+%)').firstMatch(message);

        description = descMatch?.group(1)?.trim() ?? '';
        temperature = tempMatch?.group(1)?.trim() ?? '';
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
                Icon(Icons.cloud, size: 16, color: Colors.blue),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
          ],

          if (temperature.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.thermostat, size: 16, color: Colors.orange),
                SizedBox(width: 4),
                Text(
                  'Temperatura: $temperature',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
          ],

          if (humidity.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.water_drop, size: 16, color: Colors.blue),
                SizedBox(width: 4),
                Text(
                  'Humedad: $humidity',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 8),

          // Botón de acción para clima
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Información del Clima',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      );
    } else {
      return Text(
        notification.messageNotification,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          height: 1.4,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _buildActionButton(NotificationModel notification) {
    final type = notification.notificationType;

    return InkWell(
      onTap: () => _markAsRead(notification.notificationId),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: type.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              size: 14,
              color: type.color,
            ),
            const SizedBox(width: 4),
            Text(
              'Marcar',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: type.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) =>
          NotificationDetailDialog(notification: notification),
    ).then((_) {
      // Recargar contador después de cerrar el diálogo, solo si el widget sigue activo
      if (!_isDisposed) {
        _loadUnreadCount();
      }
    });
  }

  Widget _buildLoadingIndicator() {
    return _isLoadingMore
        ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Container();
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error al cargar notificaciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'No pudimos cargar tus notificaciones. Por favor, verifica tu conexión e intenta de nuevo.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_off_outlined,
                  size: 64, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'No hay notificaciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _currentFilter == NotificationFilter.unread
                  ? 'No tienes notificaciones no leídas.'
                  : 'Cuando recibas notificaciones, aparecerán aquí para mantenerte informado.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnreadBadge() {
    if (_unreadCount <= 0) return Container();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5757), Color(0xFFC20808)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _unreadCount > 99 ? '99+' : _unreadCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('Todas', NotificationFilter.all),
          SizedBox(width: 8),
          _buildFilterChip('No leídas', NotificationFilter.unread),
          SizedBox(width: 8),
          _buildFilterChip('Hoy', NotificationFilter.today),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, NotificationFilter filter) {
    final isSelected = _currentFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _changeFilter(filter),
      backgroundColor: Colors.grey[200],
      selectedColor: Color(0xFF2E7D32),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildStatItem(IconData icon, String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          if (_unreadCount > 0) ...[
            Tooltip(
              message: 'Marcar todas como leídas',
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_read, color: Colors.green),
                ),
                onPressed: _markAllAsRead,
              ),
            ),
            const SizedBox(width: 8),
          ],
          _buildUnreadBadge(),
          const SizedBox(width: 16),
        ],
      ),
      body: _hasError
          ? _buildErrorWidget()
          : _isLoading && _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Cargando notificaciones...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header con estadísticas
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF2E7D32).withOpacity(0.05),
                            const Color(0xFF4CAF50).withOpacity(0.02),
                          ],
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            Icons.notifications,
                            'Total',
                            _notifications.length,
                            Colors.blue,
                          ),
                          _buildStatItem(
                            Icons.mark_email_unread,
                            'No leídas',
                            _unreadCount,
                            Colors.orange,
                          ),
                          _buildStatItem(
                            Icons.today,
                            'Hoy',
                            _notifications.where((n) => n.isRecent).length,
                            Colors.green,
                          ),
                        ],
                      ),
                    ),

                    // Filtros
                    _buildFilterChips(),

                    // Lista de notificaciones
                    Expanded(
                      child: _notifications.isEmpty
                          ? _buildEmptyWidget()
                          : RefreshIndicator(
                              onRefresh: () async {
                                await _loadInitialData();
                              },
                              color: const Color(0xFF2E7D32),
                              child: ListView.builder(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: _notifications.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == _notifications.length) {
                                    return _buildLoadingIndicator();
                                  }
                                  return _buildNotificationItem(
                                      _notifications[index]);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _notificationStreamSubscription?.cancel();
    _notificationsListStreamSubscription?.cancel();
    _scrollController.dispose();
    _notificationRepo.dispose();
    super.dispose();
  }
}

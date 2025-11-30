import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/services/plot_services/plot_services.dart';
import '../../controller/provider/notification_provider.dart';
import '../../screens/notifications/notifications_screen.dart';

class LocationHeader extends ConsumerStatefulWidget {
  final VoidCallback? onNotificationTap;

  const LocationHeader({super.key, this.onNotificationTap});

  @override
  ConsumerState<LocationHeader> createState() => _LocationHeaderState();
}

class _LocationHeaderState extends ConsumerState<LocationHeader> {
  final PlotServices _plotServices = PlotServices();
  String _location = "Cargando ubicación...";
  bool _isLoading = true;
  bool _isDisposed = false; // ← Añadir esta bandera

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) { // ← Verificar antes de ejecutar
        ref.read(notificationProvider.notifier).loadUnreadCount();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true; // ← Marcar como disposed
    super.dispose();
  }

  Future<void> _loadUserLocation() async {
    try {
      final response = await _plotServices.getPlotCoordinates();

      // Verificar si el widget sigue montado antes de setState
      if (_isDisposed) return;

      if (response.success && response.data.isNotEmpty) {
        final plot = response.data.first;
        setState(() {
          _location = plot.location.isNotEmpty
              ? plot.location
              : "Ubicación no especificada";
          _isLoading = false;
        });
      } else {
        if (_isDisposed) return;
        setState(() {
          _location = "No hay parcelas registradas";
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading location: $e');
      if (_isDisposed) return;
      setState(() {
        _location = "Error al cargar ubicación";
        _isLoading = false;
      });
    }
  }

  void _handleNotificationTap() {
    if (widget.onNotificationTap != null) {
      widget.onNotificationTap!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
      ).then((_) {
        if (!_isDisposed) { // ← Verificar antes de actualizar
          ref.read(notificationProvider.notifier).loadUnreadCount();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadCountProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.green,
                    size: 18,
                  ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _location,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _isLoading ? Colors.grey : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Notificaciones
        GestureDetector(
          onTap: _handleNotificationTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 20,
                  color: Colors.grey[700],
                ),
                if (unreadCount > 0) ...[
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
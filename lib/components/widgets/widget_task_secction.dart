import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controller/provider/activity_provider.dart';
import '../../controller/provider/crop_provider.dart';
import '../../domain/models/activitys/activitys_model.dart';
import '../../screens/activitys/activitys_screen.dart';
import '../animations/animation_route.dart';

class TasksToDoSection extends ConsumerStatefulWidget {
  final VoidCallback? onActivitySelected;

  const TasksToDoSection({
    super.key,
    this.onActivitySelected,
  });

  @override
  ConsumerState<TasksToDoSection> createState() => _TasksToDoSectionState();
}

class _TasksToDoSectionState extends ConsumerState<TasksToDoSection> {
  @override
  void initState() {
    super.initState();
    // Cargar actividades y cultivos cuando el widget se inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activityProvider.notifier).loadAllActivities();
      ref.read(cropProvider.notifier).loadAllCrops();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activityState = ref.watch(activityProvider);
    final cropState = ref.watch(cropProvider);

    // Filtrar actividades para los próximos 7 días
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysFromNow = today.add(const Duration(days: 7));

    List<Activity> upcomingActivities = activityState.activities.where((activity) {
      final activityDate = DateTime(
        activity.date.year,
        activity.date.month,
        activity.date.day,
      );
      return !activityDate.isBefore(today) &&
          !activityDate.isAfter(sevenDaysFromNow);
    }).toList();

    // Ordenar por fecha (más cercana primero)
    upcomingActivities.sort((a, b) => a.date.compareTo(b.date));

    // Limitar a mostrar máximo 3 actividades en el preview
    final activitiesToShow = upcomingActivities.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Actividades Pendientes",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            GestureDetector(
              onTap: () {
                if (widget.onActivitySelected != null) {
                  widget.onActivitySelected!();
                } else {
                  Navigator.push(
                    context,
                    routeAgroSig(page: const ActivitysScreen()),
                  );
                }
              },
              child: const Text(
                "Ver Todas",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Mostrar loading si están cargando actividades O cultivos
        if (activityState.isLoading || cropState.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )

        // Mostrar error de actividades
        else if (activityState.errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Error: ${activityState.errorMessage}',
              style: const TextStyle(color: Colors.red),
            ),
          )

        // Mostrar error de cultivos
        else if (cropState.errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Error cargando cultivos: ${cropState.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            )

          // Mostrar mensaje si no hay actividades
          else if (activitiesToShow.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "No hay actividades programadas para los próximos 7 días.",
                  style: TextStyle(color: Colors.grey),
                ),
              )

            // Mostrar actividades
            else
              ...activitiesToShow.map((activity) => _buildTaskItem(
                icon: _getIconForActivityType(activity.activityType),
                title: "${activity.activityType} - ${_getCropName(activity)}",
                subtitle: _formatDate(activity.date),
                isUrgent: _isUrgent(activity.date),
                onTap: () {
                  _navigateToActivityDetails(context, activity);
                },
              )).toList(),
      ],
    );
  }

  Widget _buildTaskItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isUrgent = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUrgent ? Colors.orange[100]! : Colors.grey[200]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isUrgent ? Colors.orange : Colors.green,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isUrgent ? Colors.orange[800] : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // Método para obtener icono según el tipo de actividad
  IconData _getIconForActivityType(String activityType) {
    final type = activityType.toLowerCase();

    if (type.contains('riego') || type.contains('water')) {
      return Icons.water_drop_outlined;
    } else if (type.contains('fertiliz') || type.contains('fert')) {
      return Icons.eco_outlined;
    } else if (type.contains('plaga') || type.contains('pest')) {
      return Icons.bug_report_outlined;
    } else if (type.contains('cosecha') || type.contains('harvest')) {
      return Icons.agriculture_outlined;
    } else if (type.contains('siembra') || type.contains('plant')) {
      return Icons.spa_outlined;
    } else {
      return Icons.assignment_outlined;
    }
  }

  // Método para formatear la fecha
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final activityDate = DateTime(date.year, date.month, date.day);

    if (activityDate == today) {
      return 'Hoy - ${_formatTime(date)}';
    } else if (activityDate == tomorrow) {
      return 'Mañana - ${_formatTime(date)}';
    } else {
      final daysDifference = activityDate.difference(today).inDays;
      return 'En $daysDifference días - ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Método para determinar si una actividad es urgente (hoy)
  bool _isUrgent(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activityDate = DateTime(date.year, date.month, date.day);

    return activityDate == today;
  }

  // Método para obtener el nombre del cultivo usando el provider
  String _getCropName(Activity activity) {
    return ref.read(cropProvider.notifier).getCropName(activity.cropId);
  }

  // Método para navegar a los detalles de la actividad
  void _navigateToActivityDetails(BuildContext context, Activity activity) {
    if (widget.onActivitySelected != null) {
      widget.onActivitySelected!();
    } else {
      Navigator.push(
        context,
        routeAgroSig(page: const ActivitysScreen()),
      );
    }
  }
}
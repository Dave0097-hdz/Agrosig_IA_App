import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/activitys/activitys_model.dart';
import '../../domain/services/crop_services/crop_services.dart';
import '../../domain/services/activitys_services/activitys_services.dart';

final weeklySummaryProvider = FutureProvider<WeeklySummaryData>((ref) async {
  final cropService = CropService();
  final activityService = ActivityService();

  try {
    // Obtener cultivos activos
    final cropsResponse = await cropService.getCrops();
    final activeCrops = cropsResponse.data.crops.where((crop) => crop.isActive).length;

    // Obtener actividades del mes actual
    final activities = await activityService.getAllActivities();
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // Filtrar actividades del mes actual
    final monthlyActivities = activities.where((activity) {
      return activity.date.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
          activity.date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
    }).toList();

    // Calcular costos totales del mes
    final monthlyCost = monthlyActivities.fold<double>(
        0,
            (sum, activity) => sum + activity.costTotal
    );

    // Calcular agua utilizada
    final waterUsed = _calculateWaterUsed(monthlyActivities);

    return WeeklySummaryData(
      activeCrops: activeCrops,
      waterUsed: waterUsed,
      monthlyCost: monthlyCost,
    );
  } catch (error) {
    throw Exception('Error al cargar el resumen: $error');
  }
});

double _calculateWaterUsed(List<Activity> activities) {
  double totalWater = 0;

  for (final activity in activities) {
    // Buscar insumos relacionados con agua
    for (final input in activity.inputs) {
      final inputName = input.inputName.toLowerCase();
      final unit = input.unit.toLowerCase();

      if (inputName.contains('agua') ||
          inputName.contains('water') ||
          inputName.contains('riego') ||
          unit.contains('l') ||
          unit.contains('litro') ||
          unit.contains('ml') ||
          unit.contains('galón') ||
          unit.contains('galon')) {
        totalWater += input.quantity;
      }
    }
  }

  return totalWater;
}

class WeeklySummaryData {
  final int activeCrops;
  final double waterUsed;
  final double monthlyCost;

  const WeeklySummaryData({
    required this.activeCrops,
    required this.waterUsed,
    required this.monthlyCost,
  });
}
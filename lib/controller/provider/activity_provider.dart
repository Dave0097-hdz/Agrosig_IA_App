import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/forms/activity_form_data.dart';
import '../../data/enum/enum_activity.dart';
import '../../domain/models/activitys/activitys_model.dart';
import '../../domain/services/activitys_services/activitys_services.dart';

class ActivityProvider extends StateNotifier<ActivityState> {
  final ActivityService _activityService;
  ActivityFilter _currentFilter = ActivityFilter.all;

  ActivityProvider(this._activityService) : super(ActivityState());

  // Cargar todas las actividades del usuario
  Future<void> loadAllActivities() async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final activities = await _activityService.getAllActivities();
      state = state.copyWith(
        activities: activities,
        filteredActivities: _applyFilter(activities, _currentFilter),
        isLoading: false,
        errorMessage: '',
        currentFilter: _currentFilter,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
        activities: [],
        filteredActivities: [],
      );
    }
  }

  // Aplicar filtros
  void applyFilter(ActivityFilter filter) {
    _currentFilter = filter;
    state = state.copyWith(
      filteredActivities: _applyFilter(state.activities, filter),
      currentFilter: filter,
    );
  }

  List<Activity> _applyFilter(List<Activity> activities, ActivityFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysFromNow = today.add(const Duration(days: 7));
    final sevenDaysAgo = today.subtract(const Duration(days: 7));

    switch (filter) {
      case ActivityFilter.today:
        return activities.where((activity) {
          final activityDate = DateTime(
            activity.date.year,
            activity.date.month,
            activity.date.day,
          );
          return activityDate == today;
        }).toList();

      case ActivityFilter.sevenDays:
        return activities.where((activity) {
          final activityDate = DateTime(
            activity.date.year,
            activity.date.month,
            activity.date.day,
          );
          return activityDate.isAfter(sevenDaysAgo) &&
              activityDate.isBefore(sevenDaysFromNow);
        }).toList();

      case ActivityFilter.upcoming:
        return activities.where((activity) {
          final activityDate = DateTime(
            activity.date.year,
            activity.date.month,
            activity.date.day,
          );
          return activityDate.isAfter(today);
        }).toList();

      case ActivityFilter.completed:
        return activities.where((activity) {
          final activityDate = DateTime(
            activity.date.year,
            activity.date.month,
            activity.date.day,
          );
          return activityDate.isBefore(today);
        }).toList();

      case ActivityFilter.all:
      default:
        return activities;
    }
  }

  // Calcular estadísticas basadas en el filtro actual
  ActivityStats calculateStats() {
    final activities = state.filteredActivities;

    final totalCost = activities.fold<double>(
        0,
            (sum, activity) => sum + activity.costTotal
    );

    final today = DateTime.now();
    final todayActivities = activities.where((activity) {
      final activityDate = DateTime(
        activity.date.year,
        activity.date.month,
        activity.date.day,
      );
      final todayDate = DateTime(today.year, today.month, today.day);
      return activityDate == todayDate;
    }).length;

    return ActivityStats(
      totalActivities: activities.length,
      totalCost: totalCost,
      todayActivities: todayActivities,
    );
  }

  Future<bool> registerActivity(int cropId, ActivityFormData formData) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final activity = formData.toActivity(cropId: cropId);
      final inputs = formData.inputs
          .map((inputForm) => inputForm.toInputUsed())
          .toList();

      final response = await _activityService.registerActivity(
        cropId,
        activity,
        inputs,
      );

      if (response.success) {
        await loadAllActivities(); // Recargar todas las actividades
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
        return false;
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: '');
  }

  void clearActivities() {
    state = state.copyWith(activities: [], filteredActivities: []);
  }
}

class ActivityState {
  final List<Activity> activities;
  final List<Activity> filteredActivities;
  final bool isLoading;
  final String errorMessage;
  final ActivityFilter currentFilter;

  ActivityState({
    this.activities = const [],
    this.filteredActivities = const [],
    this.isLoading = false,
    this.errorMessage = '',
    this.currentFilter = ActivityFilter.all,
  });

  ActivityState copyWith({
    List<Activity>? activities,
    List<Activity>? filteredActivities,
    bool? isLoading,
    String? errorMessage,
    ActivityFilter? currentFilter,
  }) {
    return ActivityState(
      activities: activities ?? this.activities,
      filteredActivities: filteredActivities ?? this.filteredActivities,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentFilter: currentFilter ?? this.currentFilter
    );
  }
}

class ActivityStats {
  final int totalActivities;
  final double totalCost;
  final int todayActivities;

  ActivityStats({
    required this.totalActivities,
    required this.totalCost,
    required this.todayActivities,
  });
}

// Provider global
final activityProvider = StateNotifierProvider<ActivityProvider, ActivityState>(
      (ref) {
    final activityService = ActivityService();
    return ActivityProvider(activityService);
  },
);
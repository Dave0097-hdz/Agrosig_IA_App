import '../../models/activitys/activitys_model.dart';
import '../../models/inputs/inputs_model.dart';

class ActivityResponse {
  final bool success;
  final String message;
  final ActivityData? data;

  ActivityResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ActivityResponse.fromJson(Map<String, dynamic> json) {
    return ActivityResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ActivityData.fromJson(json['data']) : null,
    );
  }
}

class ActivityData {
  final Activity activity;
  final List<InputUsed> inputs;
  final double cropCostTotal;

  ActivityData({
    required this.activity,
    required this.inputs,
    required this.cropCostTotal,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      activity: Activity.fromJson(json['activity']),
      inputs: (json['inputs'] as List)
          .map((inputJson) => InputUsed.fromJson(inputJson))
          .toList(),
      cropCostTotal: _parseCost(json['crop_cost_total']),
    );
  }

  static double _parseCost(dynamic cost) {
    if (cost == null) return 0.0;
    if (cost is double) return cost;
    if (cost is int) return cost.toDouble();
    if (cost is String) return double.tryParse(cost) ?? 0.0;
    return 0.0;
  }
}

class ActivityListResponse {
  final bool success;
  final String message;
  final List<Activity> activities;

  ActivityListResponse({
    required this.success,
    required this.message,
    required this.activities,
  });

  factory ActivityListResponse.fromJson(Map<String, dynamic> json) {
    return ActivityListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      activities: (json['data'] as List)
          .map((activityJson) => Activity.fromJson(activityJson))
          .toList(),
    );
  }
}
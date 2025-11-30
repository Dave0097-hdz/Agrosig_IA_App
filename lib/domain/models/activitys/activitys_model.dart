import '../inputs/inputs_model.dart';

class Activity {
  final int activityId;
  final int cropId;
  final int userId;
  final String activityType;
  final DateTime date;
  final String? description;
  final double costTotal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<InputUsed> inputs;

  Activity({
    required this.activityId,
    required this.cropId,
    required this.userId,
    required this.activityType,
    required this.date,
    this.description,
    required this.costTotal,
    required this.createdAt,
    required this.updatedAt,
    required this.inputs,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activityId: _parseInt(json['activity_id']) ?? 0,
      cropId: _parseInt(json['crop_id']) ?? 0,
      userId: _parseInt(json['user_id']) ?? 0,
      activityType: json['activity_type']?.toString() ?? 'Sin tipo',
      date: _parseDateTime(json['date']),
      description: json['description']?.toString(),
      costTotal: _parseCost(json['cost_total']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      inputs: (json['inputs'] as List<dynamic>? ?? [])
          .map((inputJson) => InputUsed.fromJson(inputJson))
          .toList(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static double _parseCost(dynamic cost) {
    if (cost == null) return 0.0;
    if (cost is double) return cost;
    if (cost is int) return cost.toDouble();
    if (cost is String) return double.tryParse(cost) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    if (date is String) {
      return DateTime.tryParse(date) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': activityId,
      'crop_id': cropId,
      'user_id': userId,
      'activity_type': activityType,
      'date': date.toIso8601String(),
      'description': description,
      'cost_total': costTotal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'inputs': inputs.map((input) => input.toJson()).toList(),
    };
  }

  // Para crear una nueva actividad (sin ID)
  Map<String, dynamic> toCreateJson() {
    return {
      'activity_type': activityType,
      'date': date.toIso8601String().split('T')[0],
      'description': description,
    };
  }

  Activity copyWith({
    String? activityType,
    DateTime? date,
    String? description,
    List<InputUsed>? inputs,
  }) {
    return Activity(
      activityId: activityId,
      cropId: cropId,
      userId: userId,
      activityType: activityType ?? this.activityType,
      date: date ?? this.date,
      description: description ?? this.description,
      costTotal: costTotal,
      createdAt: createdAt,
      updatedAt: updatedAt,
      inputs: inputs ?? this.inputs,
    );
  }
}
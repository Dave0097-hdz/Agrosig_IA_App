class CropReport {
  final CropReportData crop;
  final ReportSummary summary;
  final List<ActivityReport> activities;
  final List<InputReport> inputs;

  CropReport({
    required this.crop,
    required this.summary,
    required this.activities,
    required this.inputs,
  });

  factory CropReport.fromJson(Map<String, dynamic> json) {
    return CropReport(
      crop: CropReportData.fromJson(json['crop']),
      summary: ReportSummary.fromJson(json['summary']),
      activities: (json['activities'] as List)
          .map((activity) => ActivityReport.fromJson(activity))
          .toList(),
      inputs: (json['inputs'] as List)
          .map((input) => InputReport.fromJson(input))
          .toList(),
    );
  }

  // Validar si el cultivo tiene datos suficientes para generar reporte
  bool get hasSufficientData {
    return activities.isNotEmpty || summary.totalCost > 0;
  }

  // Obtener actividades con insumos
  List<ActivityReport> get activitiesWithInputs {
    return activities.where((activity) {
      final activityInputs = inputs.where((input) => input.activityId == activity.activityId).toList();
      return activityInputs.isNotEmpty;
    }).toList();
  }
}

class CropReportData {
  final int cropId;
  final int userId;
  final int plotId;
  final String cropType;
  final String? cropVariety;
  final DateTime? plantingDate;
  final DateTime? harvestDate;
  final double costTotal;

  CropReportData({
    required this.cropId,
    required this.userId,
    required this.plotId,
    required this.cropType,
    this.cropVariety,
    this.plantingDate,
    this.harvestDate,
    required this.costTotal,
  });

  factory CropReportData.fromJson(Map<String, dynamic> json) {
    return CropReportData(
      cropId: json['crop_id'],
      userId: json['user_id'],
      plotId: json['plot_id'],
      cropType: json['crop_type'],
      cropVariety: json['crop_variety'],
      plantingDate: json['planting_date'] != null
          ? DateTime.parse(json['planting_date'])
          : null,
      harvestDate: json['harvest_date'] != null
          ? DateTime.parse(json['harvest_date'])
          : null,
      costTotal: _parseCost(json['cost_total']),
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

class ReportSummary {
  final double totalCost;
  final List<CostByType> costByActivityType;
  final List<CostByType> costByInput;
  final List<CostEvolution> costEvolution;

  ReportSummary({
    required this.totalCost,
    required this.costByActivityType,
    required this.costByInput,
    required this.costEvolution,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      totalCost: _parseCost(json['totalCost']),
      costByActivityType: (json['costByActivityType'] as List)
          .map((item) => CostByType.fromJson(item))
          .toList(),
      costByInput: (json['costByInput'] as List)
          .map((item) => CostByType.fromJson(item))
          .toList(),
      costEvolution: (json['costEvolution'] as List)
          .map((item) => CostEvolution.fromJson(item))
          .toList(),
    );
  }
}

class CostByType {
  final String type;
  final double totalCost;

  CostByType({
    required this.type,
    required this.totalCost,
  });

  factory CostByType.fromJson(Map<String, dynamic> json) {
    return CostByType(
      type: json['activity_type'] ?? json['input_name'] ?? '',
      totalCost: _parseCost(json['total_cost']),
    );
  }
}

class CostEvolution {
  final DateTime month;
  final double totalCost;

  CostEvolution({
    required this.month,
    required this.totalCost,
  });

  factory CostEvolution.fromJson(Map<String, dynamic> json) {
    return CostEvolution(
      month: DateTime.parse(json['month']),
      totalCost: _parseCost(json['total_cost']),
    );
  }
}

class ActivityReport {
  final int activityId;
  final String activityType;
  final DateTime date;
  final String? description;
  final double costTotal;

  ActivityReport({
    required this.activityId,
    required this.activityType,
    required this.date,
    this.description,
    required this.costTotal,
  });

  factory ActivityReport.fromJson(Map<String, dynamic> json) {
    return ActivityReport(
      activityId: json['activity_id'],
      activityType: json['activity_type'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      costTotal: _parseCost(json['cost_total']),
    );
  }
}

class InputReport {
  final int inputId;
  final int activityId;
  final String inputName;
  final String unit;
  final double quantity;
  final double unitCost;
  final double costTotal;

  InputReport({
    required this.inputId,
    required this.activityId,
    required this.inputName,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    required this.costTotal,
  });

  factory InputReport.fromJson(Map<String, dynamic> json) {
    return InputReport(
      inputId: json['input_id'],
      activityId: json['activity_id'],
      inputName: json['input_name'],
      unit: json['unit'],
      quantity: _parseCost(json['quantity']),
      unitCost: _parseCost(json['unit_cost']),
      costTotal: _parseCost(json['cost_total']),
    );
  }
}

double _parseCost(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
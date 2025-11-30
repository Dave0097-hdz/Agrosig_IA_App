class InputUsed {
  final int inputId;
  final int activityId;
  final String inputName;
  final String unit;
  final double quantity;
  final double unitCost;
  final String costUnit;
  final String baseUnit;
  final double conversionFactor;
  final double costTotal;
  final DateTime createdAt;

  InputUsed({
    required this.inputId,
    required this.activityId,
    required this.inputName,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    required this.costUnit,
    required this.baseUnit,
    required this.conversionFactor,
    required this.costTotal,
    required this.createdAt,
  });

  factory InputUsed.fromJson(Map<String, dynamic> json) {
    return InputUsed(
      inputId: _parseInt(json['input_id']) ?? 0,
      activityId: _parseInt(json['activity_id']) ?? 0,
      inputName: json['input_name']?.toString() ?? 'Sin nombre',
      unit: json['unit']?.toString() ?? 'unidad',
      quantity: _parseQuantity(json['quantity']),
      unitCost: _parseQuantity(json['unit_cost']),
      costUnit: json['cost_unit']?.toString() ?? 'unidad',
      baseUnit: json['base_unit']?.toString() ?? 'unidad',
      conversionFactor: _parseQuantity(json['conversion_factor']),
      costTotal: _parseQuantity(json['cost_total']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static double _parseQuantity(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
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
      'input_id': inputId,
      'activity_id': activityId,
      'input_name': inputName,
      'unit': unit,
      'quantity': quantity,
      'unit_cost': unitCost,
      'cost_unit': costUnit,
      'base_unit': baseUnit,
      'conversion_factor': conversionFactor,
      'cost_total': costTotal,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Para crear un nuevo insumo (sin ID)
  Map<String, dynamic> toCreateJson() {
    return {
      'input_name': inputName,
      'unit': unit,
      'quantity': quantity,
      'unit_cost': unitCost,
      'cost_unit': costUnit,
    };
  }

  InputUsed copyWith({
    String? inputName,
    String? unit,
    double? quantity,
    double? unitCost,
    String? costUnit,
  }) {
    return InputUsed(
      inputId: inputId,
      activityId: activityId,
      inputName: inputName ?? this.inputName,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      costUnit: costUnit ?? this.costUnit,
      baseUnit: baseUnit,
      conversionFactor: conversionFactor,
      costTotal: costTotal,
      createdAt: createdAt,
    );
  }

  // Calcular costo total basado en cantidad y costo unitario
  double calculateTotalCost() {
    return quantity * unitCost;
  }
}
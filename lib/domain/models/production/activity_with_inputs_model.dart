class ActivityWithInputs {
  final int activityId;
  final String activityType;
  final DateTime date;
  final String description;
  final double costTotal;
  final DateTime createdAt;
  final List<InputUsed> inputs;

  ActivityWithInputs({
    required this.activityId,
    required this.activityType,
    required this.date,
    required this.description,
    required this.costTotal,
    required this.createdAt,
    required this.inputs,
  });

  factory ActivityWithInputs.fromJson(Map<String, dynamic> json) {
    var inputsList = json['inputs'] as List;
    List<InputUsed> inputs = inputsList.map((i) => InputUsed.fromJson(i)).toList();

    return ActivityWithInputs(
      activityId: json['activity_id'],
      activityType: json['activity_type'],
      date: DateTime.parse(json['date']),
      description: json['description'] ?? '',
      costTotal: _parseCostTotal(json['cost_total']),
      createdAt: DateTime.parse(json['created_at']),
      inputs: inputs,
    );
  }

  static double _parseCostTotal(dynamic costTotal) {
    if (costTotal == null) return 0.0;
    if (costTotal is double) return costTotal;
    if (costTotal is int) return costTotal.toDouble();
    if (costTotal is String) {
      return double.tryParse(costTotal) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_id': activityId,
      'activity_type': activityType,
      'date': date.toIso8601String(),
      'description': description,
      'cost_total': costTotal,
      'created_at': createdAt.toIso8601String(),
      'inputs': inputs.map((input) => input.toJson()).toList(),
    };
  }
}

class InputUsed {
  final String inputName;
  final double quantity;
  final String unit;
  final double? unitCost;

  InputUsed({
    required this.inputName,
    required this.quantity,
    required this.unit,
    this.unitCost,
  });

  factory InputUsed.fromJson(Map<String, dynamic> json) {
    return InputUsed(
      inputName: json['input_name'],
      quantity: _parseQuantity(json['quantity']),
      unit: json['unit'],
      unitCost: json['unit_cost'] != null ? _parseQuantity(json['unit_cost']) : null,
    );
  }

  static double _parseQuantity(dynamic quantity) {
    if (quantity == null) return 0.0;
    if (quantity is double) return quantity;
    if (quantity is int) return quantity.toDouble();
    if (quantity is String) {
      return double.tryParse(quantity) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'input_name': inputName,
      'quantity': quantity,
      'unit': unit,
      'unit_cost': unitCost,
    };
  }
}
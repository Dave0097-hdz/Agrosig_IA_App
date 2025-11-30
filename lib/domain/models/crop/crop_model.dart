class Crop {
  final int cropId;
  final int userId;
  final int plotId;
  final String cropType;
  final String? cropVariety;
  final DateTime? plantingDate;
  final DateTime? harvestDate;
  final bool isActive;
  final double costTotal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? plotName;

  Crop({
    required this.cropId,
    required this.userId,
    required this.plotId,
    required this.cropType,
    this.cropVariety,
    this.plantingDate,
    this.harvestDate,
    required this.isActive,
    required this.costTotal,
    required this.createdAt,
    required this.updatedAt,
    this.plotName,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
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
      isActive: json['is_active'] ?? true,
      costTotal: _parseCostTotal(json['cost_total']), // CORREGIDO
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      plotName: json['plot_name'],
    );
  }

  // Método auxiliar para parsear cost_total
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
      'crop_id': cropId,
      'user_id': userId,
      'plot_id': plotId,
      'crop_type': cropType,
      'crop_variety': cropVariety,
      'planting_date': plantingDate?.toIso8601String(),
      'harvest_date': harvestDate?.toIso8601String(),
      'is_active': isActive,
      'cost_total': costTotal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Para crear nuevo cultivo (sin ID)
  Map<String, dynamic> toCreateJson() {
    return {
      'crop_type': cropType,
      'crop_variety': cropVariety,
      'planting_date': plantingDate?.toIso8601String(),
      'harvest_date': harvestDate?.toIso8601String(),
      'plot_id': plotId,
    };
  }

  // Para actualizar cultivo
  Map<String, dynamic> toUpdateJson() {
    return {
      'crop_type': cropType,
      'crop_variety': cropVariety,
      'planting_date': plantingDate?.toIso8601String(),
      'harvest_date': harvestDate?.toIso8601String(),
      'plot_id': plotId,
    };
  }

  Crop copyWith({
    int? cropId,
    int? userId,
    int? plotId,
    String? cropType,
    String? cropVariety,
    DateTime? plantingDate,
    DateTime? harvestDate,
    bool? isActive,
    double? costTotal,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? plotName,
  }) {
    return Crop(
      cropId: cropId ?? this.cropId,
      userId: userId ?? this.userId,
      plotId: plotId ?? this.plotId,
      cropType: cropType ?? this.cropType,
      cropVariety: cropVariety ?? this.cropVariety,
      plantingDate: plantingDate ?? this.plantingDate,
      harvestDate: harvestDate ?? this.harvestDate,
      isActive: isActive ?? this.isActive,
      costTotal: costTotal ?? this.costTotal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      plotName: plotName ?? this.plotName,
    );
  }
}
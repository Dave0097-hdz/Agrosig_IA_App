class ProductionBatch {
  final int productionId;
  final int cropId;
  final String name;
  final String uniqueCode;
  final DateTime creationDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? cropType;
  final String? cropVariety;
  final String? qrCode;
  final DateTime? generationDate;
  final int activityCount;
  final bool hasActivities;

  ProductionBatch({
    required this.productionId,
    required this.cropId,
    required this.name,
    required this.uniqueCode,
    required this.creationDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.cropType,
    this.cropVariety,
    this.qrCode,
    this.generationDate,
    required this.activityCount,
    required this.hasActivities,
  });

  factory ProductionBatch.fromJson(Map<String, dynamic> json) {
    return ProductionBatch(
      productionId: json['production_id'] ?? 0,
      cropId: json['crop_id'] ?? 0,
      name: json['name'] ?? '',
      uniqueCode: json['unique_code'] ?? '',
      creationDate: _parseDateTime(json['creation_date']),
      isActive: json['is_active'] ?? true,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      cropType: json['crop_type'],
      cropVariety: json['crop_variety'],
      qrCode: json['qr_code'],
      generationDate: _parseDateTime(json['generation_date']),
      activityCount: json['activity_count'] ?? 0,
      hasActivities: json['has_activities'] ?? false,
    );
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'production_id': productionId,
      'crop_id': cropId,
      'name': name,
      'unique_code': uniqueCode,
      'creation_date': creationDate.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'crop_type': cropType,
      'crop_variety': cropVariety,
      'qr_code': qrCode,
      'generation_date': generationDate?.toIso8601String(),
      'activity_count': activityCount,
      'has_activities': hasActivities,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
    };
  }
}

class ProductionBatchDetail extends ProductionBatch {
  final DateTime? plantingDate;
  final DateTime? harvestDate;
  final String? firstName;
  final String? paternalSurname;
  final String? plotName;
  final String? location;

  ProductionBatchDetail({
    required super.productionId,
    required super.cropId,
    required super.name,
    required super.uniqueCode,
    required super.creationDate,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.cropType,
    super.cropVariety,
    super.qrCode,
    super.generationDate,
    required super.activityCount,
    required super.hasActivities,
    this.plantingDate,
    this.harvestDate,
    this.firstName,
    this.paternalSurname,
    this.plotName,
    this.location,
  });

  factory ProductionBatchDetail.fromJson(Map<String, dynamic> json) {
    return ProductionBatchDetail(
      productionId: json['production_id'] ?? 0,
      cropId: json['crop_id'] ?? 0,
      name: json['name'] ?? '',
      uniqueCode: json['unique_code'] ?? '',
      creationDate: ProductionBatch._parseDateTime(json['creation_date']),
      isActive: json['is_active'] ?? true,
      createdAt: ProductionBatch._parseDateTime(json['created_at']),
      updatedAt: ProductionBatch._parseDateTime(json['updated_at']),
      cropType: json['crop_type'],
      cropVariety: json['crop_variety'],
      qrCode: json['qr_code'],
      generationDate: ProductionBatch._parseDateTime(json['generation_date']),
      activityCount: json['activity_count'] ?? 0,
      hasActivities: json['has_activities'] ?? false,
      plantingDate: ProductionBatch._parseDateTime(json['planting_date']),
      harvestDate: ProductionBatch._parseDateTime(json['harvest_date']),
      firstName: json['first_name'],
      paternalSurname: json['paternal_surname'],
      plotName: json['plot_name'],
      location: json['location'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'planting_date': plantingDate?.toIso8601String(),
      'harvest_date': harvestDate?.toIso8601String(),
      'first_name': firstName,
      'paternal_surname': paternalSurname,
      'plot_name': plotName,
      'location': location,
    };
  }
}
import '../../models/crop/crop_model.dart';

class CropResponse {
  final bool success;
  final String message;
  final dynamic data;

  CropResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CropResponse.fromJson(Map<String, dynamic> json) {
    return CropResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}

class CropListResponse {
  final bool success;
  final String message;
  final CropListData data;

  CropListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CropListResponse.fromJson(Map<String, dynamic> json) {
    return CropListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CropListData.fromJson(json['data']),
    );
  }
}

class CropListData {
  final List<Crop> crops;
  final PaginationInfo pagination;

  CropListData({
    required this.crops,
    required this.pagination,
  });

  factory CropListData.fromJson(Map<String, dynamic> json) {
    final cropsList = (json['crops'] as List)
        .map((cropJson) => Crop.fromJson(cropJson))
        .toList();

    return CropListData(
      crops: cropsList,
      pagination: PaginationInfo.fromJson(json['pagination']),
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int perPage;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginationInfo({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'total': total,
      'total_pages': totalPages,
      'has_next': hasNext,
      'has_prev': hasPrev,
    };
  }

  PaginationInfo copyWith({
    int? currentPage,
    int? perPage,
    int? total,
    int? totalPages,
    bool? hasNext,
    bool? hasPrev,
  }) {
    return PaginationInfo(
      currentPage: currentPage ?? this.currentPage,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      hasNext: hasNext ?? this.hasNext,
      hasPrev: hasPrev ?? this.hasPrev,
    );
  }

  @override
  String toString() {
    return 'PaginationInfo('
        'page: $currentPage/$totalPages, '
        'perPage: $perPage, '
        'total: $total, '
        'hasNext: $hasNext, '
        'hasPrev: $hasPrev'
        ')';
  }
}
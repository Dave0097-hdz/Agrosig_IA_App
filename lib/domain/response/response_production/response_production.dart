import '../../models/production/activity_with_inputs_model.dart';
import '../../models/production/production_model.dart';
import '../response_crop/response_crop.dart';

class ProductionBatchResponse {
  final bool success;
  final String message;
  final dynamic data;

  ProductionBatchResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductionBatchResponse.fromJson(Map<String, dynamic> json) {
    return ProductionBatchResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}

class ProductionBatchListResponse {
  final bool success;
  final String message;
  final ProductionBatchListData data;

  ProductionBatchListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductionBatchListResponse.fromJson(Map<String, dynamic> json) {
    return ProductionBatchListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ProductionBatchListData.fromJson(json['data']),
    );
  }
}

class ProductionBatchListData {
  final List<ProductionBatch> batches;
  final PaginationInfo pagination;

  ProductionBatchListData({
    required this.batches,
    required this.pagination,
  });

  factory ProductionBatchListData.fromJson(Map<String, dynamic> json) {
    var batchesList = (json['batches'] as List)
        .map((batchJson) => ProductionBatch.fromJson(batchJson))
        .toList();

    return ProductionBatchListData(
      batches: batchesList,
      pagination: PaginationInfo.fromJson(json['pagination']),
    );
  }
}

class ProductionBatchDetailResponse {
  final bool success;
  final String message;
  final ProductionBatchDetail data;

  ProductionBatchDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductionBatchDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProductionBatchDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ProductionBatchDetail.fromJson(json['data']),
    );
  }
}

class ActivityListResponse {
  final bool success;
  final String message;
  final List<ActivityWithInputs> data;

  ActivityListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ActivityListResponse.fromJson(Map<String, dynamic> json) {
    var activitiesList = (json['data'] as List)
        .map((activityJson) => ActivityWithInputs.fromJson(activityJson))
        .toList();

    return ActivityListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: activitiesList,
    );
  }
}

class AssociateActivitiesResponse {
  final bool success;
  final String message;
  final dynamic data;

  AssociateActivitiesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AssociateActivitiesResponse.fromJson(Map<String, dynamic> json) {
    return AssociateActivitiesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}
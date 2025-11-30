import '../../models/crop/crop_model.dart';
import '../../models/report/report_model.dart';

class CropReportResponse {
  final bool success;
  final String message;
  final CropReport? data;

  CropReportResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CropReportResponse.fromJson(Map<String, dynamic> json) {
    return CropReportResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? CropReport.fromJson(json['data']) : null,
    );
  }
}

class CropReportListResponse {
  final bool success;
  final String message;
  final List<Crop> crops;

  CropReportListResponse({
    required this.success,
    required this.message,
    required this.crops,
  });

  factory CropReportListResponse.fromJson(Map<String, dynamic> json) {
    return CropReportListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      crops: (json['data'] as List)
          .map((cropJson) => Crop.fromJson(cropJson))
          .toList(),
    );
  }
}
import '../../models/weather/weather_model.dart';

class ClimateResponse {
  final bool success;
  final String message;
  final Climate? data;

  ClimateResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ClimateResponse.fromJson(Map<String, dynamic> json) => ClimateResponse(
    success: json["success"] ?? false,
    message: json["message"] ?? '',
    data: json["data"] != null ? Climate.fromJson(json["data"]) : null,
  );
}
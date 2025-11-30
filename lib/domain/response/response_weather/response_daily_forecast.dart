import '../../models/weather/weather_daily_model.dart';

class WeeklyForecastResponse {
  final bool success;
  final String message;
  final List<DailyForecast> data;

  WeeklyForecastResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory WeeklyForecastResponse.fromJson(Map<String, dynamic> json) => WeeklyForecastResponse(
    success: json["success"] ?? false,
    message: json["message"] ?? '',
    data: json["data"] != null ? (json["data"] as List).map((e) => DailyForecast.fromJson(e)).toList() : [],
  );
}
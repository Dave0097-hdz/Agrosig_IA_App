import '../../models/plot/plot_model.dart';

class PlotResponse {
  final bool success;
  final String message;
  final Plot? data;

  PlotResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory PlotResponse.fromJson(Map<String, dynamic> json) => PlotResponse(
    success: json["success"] ?? false,
    message: json["message"] ?? '',
    data: json["data"] != null ? Plot.fromJson(json["data"]) : null,
  );
}
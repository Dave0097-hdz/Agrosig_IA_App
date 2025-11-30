import '../../models/plot/plot_model.dart';

class PlotListResponse {
  final bool success;
  final String message;
  final List<Plot> data;

  PlotListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PlotListResponse.fromJson(Map<String, dynamic> json) => PlotListResponse(
    success: json["success"] ?? false,
    message: json["message"] ?? '',
    data: json["data"] != null
        ? List<Plot>.from(json["data"].map((x) => Plot.fromJson(x)))
        : [],
  );
}
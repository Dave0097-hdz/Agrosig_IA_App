import '../../models/plot/plot_model.dart';

class UbicationResponse {
  final bool success;
  final String message;
  final List<Plot> data;

  UbicationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UbicationResponse.fromJson(Map<String, dynamic> json) => UbicationResponse(
    success: json["success"] ?? false,
    message: json["message"] ?? '',
    data: json["data"] != null
        ? List<Plot>.from(json["data"].map((x) => Plot.fromJson(x)))
        : [],
  );
}
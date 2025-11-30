import '../../models/qr_code/qr_code_model.dart';

class QRCodeResponse {
  final bool success;
  final String message;
  final QRCodeData data;

  QRCodeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory QRCodeResponse.fromJson(Map<String, dynamic> json) {
    return QRCodeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: QRCodeData.fromJson(json['data']),
    );
  }
}

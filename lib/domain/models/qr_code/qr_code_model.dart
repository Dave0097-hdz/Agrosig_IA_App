class QRCodeData {
  final int qrId;
  final int productionId;
  final String qrCode;
  final DateTime generationDate;
  final Map<String, dynamic>? qrData;

  QRCodeData({
    required this.qrId,
    required this.productionId,
    required this.qrCode,
    required this.generationDate,
    this.qrData,
  });

  factory QRCodeData.fromJson(Map<String, dynamic> json) {
    return QRCodeData(
      qrId: json['qr_id'] ?? 0,
      productionId: json['production_id'] ?? 0,
      qrCode: json['qr_code'] ?? '', 
      generationDate: DateTime.parse(json['generation_date']), 
      qrData: json['qr_data'] != null ? Map<String, dynamic>.from(json['qr_data']) : null, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qr_id': qrId,
      'production_id': productionId,
      'qr_code': qrCode,
      'generation_date': generationDate.toIso8601String(),
      'qr_data': qrData,
    };
  }
}
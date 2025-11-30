class DailyForecast {
  final DateTime dateAt;
  final double temperature;
  final double humidity;
  final String description;
  final double precipitation;
  final double windSpeed;
  final double minTemperature;
  final double maxTemperature;

  DailyForecast({
    required this.dateAt,
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.precipitation,
    required this.windSpeed,
    required this.minTemperature,
    required this.maxTemperature,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
    dateAt: DateTime.parse(json["date_at"]),
    temperature: json["temperature"] != null ? double.tryParse(json["temperature"].toString()) ?? 0.0 : 0.0,
    humidity: json["humidity"] != null ? double.tryParse(json["humidity"].toString()) ?? 0.0 : 0.0,
    description: json["description"] ?? '',
    precipitation: json["precipitation"] != null ? double.tryParse(json["precipitation"].toString()) ?? 0.0 : 0.0,
    windSpeed: json["wind_speed"] != null ? double.tryParse(json["wind_speed"].toString()) ?? 0.0 : 0.0,
    minTemperature: json["min_temperature"] != null ? double.tryParse(json["min_temperature"].toString()) ?? 0.0 : 0.0,
    maxTemperature: json["max_temperature"] != null ? double.tryParse(json["max_temperature"].toString()) ?? 0.0 : 0.0,
  );
}
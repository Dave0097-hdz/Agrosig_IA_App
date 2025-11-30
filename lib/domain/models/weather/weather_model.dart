class Climate {
  final int climateId;
  final int plotId;
  final double temperature;
  final double humidity;
  final String description;
  final double precipitation;
  final double windSpeed;
  final double atmosphericPressure;
  final double windDirection;
  final double minTemp;
  final double maxTemp;
  final String cityName;
  final DateTime date;

  Climate({
    required this.climateId,
    required this.plotId,
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.precipitation,
    required this.windSpeed,
    required this.atmosphericPressure,
    required this.windDirection,
    required this.minTemp,
    required this.maxTemp,
    required this.cityName,
    required this.date,
  });

  factory Climate.fromJson(Map<String, dynamic> json) => Climate(
    climateId: json["climate_id"] != null ? int.tryParse(json["climate_id"].toString()) ?? 0 : 0,
    plotId: json["plot_id"] != null ? int.tryParse(json["plot_id"].toString()) ?? 0 : 0,
    temperature: json["temperature"] != null ? double.tryParse(json["temperature"].toString()) ?? 0.0 : 0.0,
    humidity: json["humidity"] != null ? double.tryParse(json["humidity"].toString()) ?? 0.0 : 0.0,
    description: json["description"] ?? '',
    precipitation: json["precipitation"] != null ? double.tryParse(json["precipitation"].toString()) ?? 0.0 : 0.0,
    windSpeed: json["wind_speed"] != null ? double.tryParse(json["wind_speed"].toString()) ?? 0.0 : 0.0,
    atmosphericPressure: json["atmospheric_pressure"] != null
        ? double.tryParse(json["atmospheric_pressure"].toString()) ?? 0.0
        : json["atmosphere_pressure"] != null
        ? double.tryParse(json["atmosphere_pressure"].toString()) ?? 0.0
        : 0.0,
    windDirection: json["wind_direction"] != null ? double.tryParse(json["wind_direction"].toString()) ?? 0.0 : 0.0,
    minTemp: json["min_temp"] != null ? double.tryParse(json["min_temp"].toString()) ?? 0.0 : 0.0,
    maxTemp: json["max_temp"] != null ? double.tryParse(json["max_temp"].toString()) ?? 0.0 : 0.0,
    cityName: json["city_name"] ?? '',
    date: json["date"] != null ? DateTime.tryParse(json["date"]) ?? DateTime.now() : DateTime.now(),
  );
}
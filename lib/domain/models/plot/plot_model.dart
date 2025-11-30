class Plot {
  final int user_id;
  final int plot_id;
  final String plot_name;
  final String location;
  final double lat;
  final double long;
  final double area;
  final bool is_active;

  Plot({
    required this.user_id,
    required this.plot_id,
    required this.plot_name,
    required this.location,
    required this.lat,
    required this.long,
    required this.area,
    required this.is_active,
  });

  factory Plot.fromJson(Map<String, dynamic> json) {
    // Debug: imprimir lo que llega
    print('Plot JSON received: $json');

    // Manejar diferentes formatos de coordenadas
    double latitude = 0.0;
    double longitude = 0.0;

    // Prioridad 1: Campos directos lat/long
    if (json["lat"] != null) {
      latitude = double.tryParse(json["lat"].toString()) ?? 0.0;
    } else if (json["latitude"] != null) {
      latitude = double.tryParse(json["latitude"].toString()) ?? 0.0;
    }

    if (json["long"] != null) {
      longitude = double.tryParse(json["long"].toString()) ?? 0.0;
    } else if (json["longitude"] != null) {
      longitude = double.tryParse(json["longitude"].toString()) ?? 0.0;
    }

    // Manejar el área que puede venir como String o double
    double areaValue = 0.0;
    if (json["area"] != null) {
      if (json["area"] is String) {
        areaValue = double.tryParse(json["area"]) ?? 0.0;
      } else {
        areaValue = json["area"].toDouble();
      }
    }

    return Plot(
      user_id: json["user_id"] ?? 0,
      plot_id: json["plot_id"] ?? 0,
      plot_name: json["plot_name"] ?? '',
      location: json["location"] ?? '',
      lat: latitude,
      long: longitude,
      area: areaValue,
      is_active: json["is_active"] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    "plot_name": plot_name,
    "location": location,
    "lat": lat,
    "long": long,
    "area": area,
  };
}
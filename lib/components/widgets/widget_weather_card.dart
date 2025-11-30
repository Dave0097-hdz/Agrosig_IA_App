import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../domain/models/weather/weather_model.dart';
import '../../domain/services/plot_services/plot_services.dart';
import '../../domain/services/weather_services/weather_service.dart';

class WeatherCard extends StatefulWidget {
  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> with SingleTickerProviderStateMixin {
  final ClimateServices _climateServices = ClimateServices();
  final PlotServices _plotServices = PlotServices();

  Climate? _currentClimate;
  bool _isLoading = true;
  bool _hasError = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _loadWeatherData();
  }

  @override
  void dispose() {
    _animationController.stop(); // Detener animación primero
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadWeatherData() async {
    try {
      // Verificar si el widget está montado
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final plot = await _plotServices.getUbicationPlot();

      // Verificar después de await
      if (!mounted) return;

      if (plot != null) {
        final climateResponse = await _climateServices.getWeather(plot.plot_id);

        // Verificar después de await
        if (!mounted) return;

        if (climateResponse.success && climateResponse.data != null) {
          setState(() {
            _currentClimate = climateResponse.data;
            _isLoading = false;
          });
        } else {
          throw Exception('No se pudieron obtener los datos del clima');
        }
      } else {
        throw Exception('No hay parcelas registradas');
      }
    } catch (e) {
      print('Error loading weather: $e');

      // Verificar antes de mostrar error
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  String _getWeatherAnimation(String description) {
    final desc = description.toLowerCase();

    if (desc.contains('soleado') || desc.contains('clear')) {
      return 'assets/animation/sunny.json';
    } else if (desc.contains('parcialmente') || desc.contains('partially')) {
      return 'assets/animation/partly_cloudy.json';
    } else if (desc.contains('nublado') || desc.contains('cloud')) {
      return 'assets/animation/cloudy.json';
    } else if (desc.contains('lluvia') || desc.contains('rain')) {
      return 'assets/animation/rain.json';
    } else if (desc.contains('tormenta') || desc.contains('storm')) {
      return 'assets/animation/storm.json';
    } else if (desc.contains('nieve') || desc.contains('snow')) {
      return 'assets/animation/snow.json';
    } else if (desc.contains('viento') || desc.contains('wind')) {
      return 'assets/animation/windy.json';
    } else {
      return 'assets/animation/sunny.json';
    }
  }

  List<Color> _getBackgroundGradient(String description) {
    final desc = description.toLowerCase();

    if (desc.contains('soleado') || desc.contains('clear')) {
      return [Color(0xFFFFD700), Color(0xFFFFA000)];
    } else if (desc.contains('parcialmente')) {
      return [Color(0xFF87CEEB), Color(0xFF4682B4)];
    } else if (desc.contains('nublado')) {
      return [Color(0xFFB0C4DE), Color(0xFF778899)];
    } else if (desc.contains('lluvia') || desc.contains('rain')) {
      return [Color(0xFF4169E1), Color(0xFF191970)];
    } else if (desc.contains('tormenta') || desc.contains('storm')) {
      return [Color(0xFF4A4A4A), Color(0xFF2F2F2F)];
    } else {
      return [Color(0xFF6366F1), Color(0xFF8B5CF6)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: _currentClimate != null
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getBackgroundGradient(_currentClimate!.description),
          )
              : LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.1),
          ),
          child: _isLoading
              ? _buildLoading()
              : _hasError
              ? _buildError()
              : _buildWeatherContent(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      height: 140,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 12),
            Text(
              'Cargando clima...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return SizedBox(
      height: 140,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 32),
            SizedBox(height: 8),
            Text(
              'Error al cargar',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: _loadWeatherData,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Reintentar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    if (_currentClimate == null) return _buildError();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_currentClimate!.temperature.round()}°',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatDescription(_currentClimate!.description),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  child: Lottie.asset(
                    _getWeatherAnimation(_currentClimate!.description),
                    controller: _animationController,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherMetric(
                value: '${_currentClimate!.humidity.round()}%',
                label: 'Humedad',
                icon: Icons.water_drop,
              ),
              _buildWeatherMetric(
                value: '${_currentClimate!.precipitation.toStringAsFixed(2)} in',
                label: 'Precipitación',
                icon: Icons.umbrella,
              ),
              _buildWeatherMetric(
                value: '${_currentClimate!.windSpeed.round()} mph/s',
                label: 'Viento',
                icon: Icons.air,
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _currentClimate!.cityName.isNotEmpty
                          ? _currentClimate!.cityName
                          : 'Ubicación',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _loadWeatherData,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Actualizar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherMetric({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.white,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  String _formatDescription(String description) {
    return description.split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return word;
    }).join(' ');
  }
}
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../components/theme/colors_agroSig.dart';
import '../../domain/models/weather/weather_daily_model.dart';
import '../../domain/services/plot_services/plot_services.dart';
import '../../domain/models/weather/weather_model.dart';
import '../../domain/services/weather_services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  final ClimateServices _climateServices = ClimateServices();
  final PlotServices _plotServices = PlotServices();

  Climate? _currentClimate;
  List<DailyForecast> _weeklyForecast = [];
  bool _isLoading = true;
  bool _hasError = false;
  late AnimationController _animationController;

  late AnimationController _sheetAnimationController;
  bool _isExpanded = false;
  final double _minHeight = 0.25;
  final double _maxHeight = 0.85;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _sheetAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _loadWeatherData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _sheetAnimationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _sheetAnimationController.forward();
      } else {
        _sheetAnimationController.reverse();
      }
    });
  }

  void _handleVerticalDrag(DragUpdateDetails details) {
    final sensitivity = 0.008;
    final newHeight = (_isExpanded ? _maxHeight : _minHeight) -
        (details.primaryDelta! * sensitivity);

    if (newHeight >= _minHeight && newHeight <= _maxHeight) {
      _sheetAnimationController.value =
          (newHeight - _minHeight) / (_maxHeight - _minHeight);
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    final threshold = 0.3;
    if (_sheetAnimationController.value > threshold) {
      _sheetAnimationController.forward();
      _isExpanded = true;
    } else {
      _sheetAnimationController.reverse();
      _isExpanded = false;
    }
  }

  Future<void> _loadWeatherData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final plot = await _plotServices.getUbicationPlot();
      if (plot != null) {
        final climateResponse = await _climateServices.getWeather(plot.plot_id);
        final weeklyResponse = await _climateServices.getWeeklyWeather(plot.plot_id);

        if (climateResponse.success && climateResponse.data != null && weeklyResponse.success) {
          setState(() {
            _currentClimate = climateResponse.data;
            _weeklyForecast = weeklyResponse.data;
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
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  // Mapeo para animaciones Lottie
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
    } else {
      return 'assets/animation/sunny.json';
    }
  }

  // Mapeo de iconos para la lista semanal
  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('soleado') || desc.contains('clear')) {
      return Icons.wb_sunny;
    } else if (desc.contains('parcialmente')) {
      return Icons.wb_twilight;
    } else if (desc.contains('nublado') || desc.contains('cloud')) {
      return Icons.cloud;
    } else if (desc.contains('lluvia') || desc.contains('rain')) {
      return Icons.water_drop;
    } else if (desc.contains('tormenta') || desc.contains('storm')) {
      return Icons.thunderstorm;
    } else {
      return Icons.wb_sunny;
    }
  }

  // Color del icono basado en el clima
  Color _getWeatherIconColor(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('soleado') || desc.contains('clear')) {
      return Colors.amber;
    } else if (desc.contains('lluvia') || desc.contains('rain')) {
      return Colors.blue;
    } else if (desc.contains('tormenta') || desc.contains('storm')) {
      return Colors.deepPurple;
    } else {
      return Colors.white;
    }
  }

  // CORRECCIÓN: Formatear fecha para mostrar como "Lun, 10 Oct"
  String _formatDate(DateTime date) {
    const days = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    int dayIndex = date.weekday - 1;
    if (date.weekday == 7) {
      dayIndex = 0;
    } else {
      dayIndex = date.weekday;
    }

    return '${days[dayIndex]}, ${date.day} ${months[date.month - 1]}';
  }

  // Degradado dinámico basado en el clima actual
  List<Color> _getBackgroundGradient(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('soleado') || desc.contains('clear')) {
      return [const Color(0xFFFFD700), const Color(0xFFFFA000)];
    } else if (desc.contains('parcialmente')) {
      return [const Color(0xFF87CEEB), const Color(0xFF4682B4)];
    } else if (desc.contains('nublado')) {
      return [const Color(0xFFB0C4DE), const Color(0xFF778899)];
    } else if (desc.contains('lluvia') || desc.contains('rain')) {
      return [const Color(0xFF4169E1), const Color(0xFF191970)];
    } else if (desc.contains('tormenta') || desc.contains('storm')) {
      return [const Color(0xFF4A4A4A), const Color(0xFF2F2F2F)];
    } else {
      return [const Color(0xFF5B2EFF), const Color(0xFF7846FF)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _currentClimate != null
                ? _getBackgroundGradient(_currentClimate!.description)
                : [const Color(0xFF5B2EFF), const Color(0xFF7846FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? _buildLoading()
              : _hasError
              ? _buildError()
              : _buildContent(screenHeight),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Cargando datos del clima...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar los datos',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadWeatherData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(double screenHeight) {
    return Column(
      children: [
        // ---------- Header ----------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "Clima",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _loadWeatherData,
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
            ],
          ),
        ),

        // ---------- Información principal ----------
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Ubicación
                Text(
                  _currentClimate?.cityName ?? "Ubicación",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Temperatura grande
                Text(
                  "${_currentClimate?.temperature.round()}°",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontWeight: FontWeight.w300,
                  ),
                ),

                // Icono animado del clima
                Container(
                  width: 150,
                  height: 150,
                  child: Lottie.asset(
                    _getWeatherAnimation(_currentClimate?.description ?? ""),
                    controller: _animationController,
                    fit: BoxFit.contain,
                  ),
                ),

                // Descripción del clima
                Text(
                  _formatDescription(_currentClimate?.description ?? ""),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),

                // Temperaturas mínima y máxima
                Text(
                  "Máx:${_currentClimate?.maxTemp.round()}°   Mín:${_currentClimate?.minTemp.round()}°",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),

                // Métricas del clima
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
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
                        value: '${_currentClimate!.precipitation.toStringAsFixed(1)} mm',
                        label: 'Precipitación',
                        icon: Icons.umbrella,
                      ),
                      _buildWeatherMetric(
                        value: '${_currentClimate!.windSpeed.round()} m/s',
                        label: 'Viento',
                        icon: Icons.air,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),

        // ---------- Contenedor inferior ----------
        AnimatedBuilder(
          animation: _sheetAnimationController,
          builder: (context, child) {
            final height = screenHeight *
                (_minHeight + (_maxHeight - _minHeight) * _sheetAnimationController.value);

            return GestureDetector(
              onVerticalDragUpdate: _handleVerticalDrag,
              onVerticalDragEnd: _handleVerticalDragEnd,
              child: Container(
                height: height,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Indicador de deslizar y botón de expandir
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Indicador
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Botón de expandir
                          GestureDetector(
                            onTap: _toggleExpanded,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: ColorsAgrosig.primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                _isExpanded ? Icons.expand_less : Icons.expand_more,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Pestañas
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _TabItem(
                            title: "Pronóstico Semanal",
                            isActive: true,
                            onTap: _toggleExpanded,
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.grey, height: 1),

                    // Contenido de la lista
                    Expanded(
                      child: _isExpanded
                          ? _buildExpandedWeeklyList()
                          : _buildCollapsedWeeklyList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCollapsedWeeklyList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _weeklyForecast.length,
      itemBuilder: (context, index) {
        final forecast = _weeklyForecast[index];
        return _WeatherRowCompact(
          date: _formatDate(forecast.dateAt),
          icon: _getWeatherIcon(forecast.description),
          iconColor: _getWeatherIconColor(forecast.description),
          temp: "${forecast.temperature.round()}°",
          description: forecast.description,
        );
      },
    );
  }

  Widget _buildExpandedWeeklyList() {
    return Column(
      children: [
        // Encabezados de la tabla expandida
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Día',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'Clima',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Precip.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Temp',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),

        // Lista de pronósticos
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 10),
            itemCount: _weeklyForecast.length,
            itemBuilder: (context, index) {
              final forecast = _weeklyForecast[index];
              return Container(
                decoration: BoxDecoration(
                  border: index < _weeklyForecast.length - 1
                      ? const Border(bottom: BorderSide(color: Colors.grey, width: 0.3))
                      : null,
                ),
                child: _WeatherRowExpanded(
                  date: _formatDate(forecast.dateAt),
                  icon: _getWeatherIcon(forecast.description),
                  iconColor: _getWeatherIconColor(forecast.description),
                  temp: "${forecast.temperature.round()}°",
                  precipitation: "${forecast.precipitation.toStringAsFixed(1)} mm",
                  description: forecast.description,
                ),
              );
            },
          ),
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
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
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

class _TabItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isActive ? ColorsAgrosig.primaryColor : Colors.grey,
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 50,
              decoration: BoxDecoration(
                color: ColorsAgrosig.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeatherRowCompact extends StatelessWidget {
  final String date;
  final IconData icon;
  final Color iconColor;
  final String temp;
  final String description;

  const _WeatherRowCompact({
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.temp,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          // Fecha
          Expanded(
            flex: 3,
            child: Text(
              date,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Icono del clima
          Expanded(
            flex: 1,
            child: Icon(icon, color: iconColor, size: 24),
          ),

          // Descripción compacta
          Expanded(
            flex: 3,
            child: Text(
              _capitalizeDescription(description),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Temperatura
          Expanded(
            flex: 2,
            child: Text(
              temp,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeDescription(String desc) {
    return desc.split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return word;
    }).join(' ');
  }
}

class _WeatherRowExpanded extends StatelessWidget {
  final String date;
  final IconData icon;
  final Color iconColor;
  final String temp;
  final String precipitation;
  final String description;

  const _WeatherRowExpanded({
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.temp,
    required this.precipitation,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Fecha
          Expanded(
            flex: 3,
            child: Text(
              date,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Icono y descripción
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _capitalizeDescription(description),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Precipitación
          Expanded(
            flex: 2,
            child: Text(
              precipitation,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Temperatura
          Expanded(
            flex: 2,
            child: Text(
              temp,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeDescription(String desc) {
    return desc.split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return word;
    }).join(' ');
  }
}
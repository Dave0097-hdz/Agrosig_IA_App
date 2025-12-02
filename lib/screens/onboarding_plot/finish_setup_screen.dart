import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import '../../components/helper/modal_success.dart';
import '../../components/toast/toats.dart';
import '../../components/theme/colors_agrosig.dart';
import '../../components/picker/map_picker.dart';
import '../../domain/models/plot/plot_model.dart';
import '../../domain/services/plot_services/geocodig_services.dart';
import '../../domain/services/plot_services/plot_services.dart';
import '../home/home_screen.dart';

class FinishSetupPlot extends StatefulWidget {
  const FinishSetupPlot({Key? key}) : super(key: key);

  @override
  _FinishSetupPlotState createState() => _FinishSetupPlotState();
}

class _FinishSetupPlotState extends State<FinishSetupPlot> {
  late TextEditingController _plotNameController;
  late TextEditingController _locationController;
  late TextEditingController _areaController;

  // Servicios
  final PlotServices _plotServices = PlotServices();
  final GeocodingService _geocodingService = GeocodingService();

  // Variables de estado
  Plot? _userPlot;
  LatLng? _selectedLocation;
  String _coordinatesText = 'selecciona en el mapa';
  String _address = '';
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isGettingAddress = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _plotNameController = TextEditingController();
    _locationController = TextEditingController();
    _areaController = TextEditingController();
    _loadUserPlot();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _plotNameController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showToast(message: 'Por favor, activa el servicio de ubicación');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showToast(message: 'Se necesitan permisos de ubicación');
      }
    }
  }

  Future<void> _loadUserPlot() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final plot = await _plotServices.getUbicationPlot();

      print('Parcela cargada: $plot');

      setState(() {
        _userPlot = plot;
        if (plot != null) {
          _plotNameController.text = plot.plot_name;
          _locationController.text = plot.location;
          _areaController.text = plot.area.toString();

          // IMPORTANTE: Validar y corregir coordenadas si es necesario
          double lat = plot.lat;
          double long = plot.long;

          // Verificar si las coordenadas están intercambiadas
          if (lat < -90 || lat > 90) {
            // Si lat está fuera de rango, probablemente esté intercambiada con long
            print('ADVERTENCIA: Latitud fuera de rango ($lat), intercambiando coordenadas');
            double temp = lat;
            lat = long;
            long = temp;
          }

          // Validar rango final
          if (lat >= -90 && lat <= 90 && long >= -180 && long <= 180) {
            _selectedLocation = LatLng(lat, long);
            _coordinatesText = '${lat.toStringAsFixed(6)}, ${long.toStringAsFixed(6)}';
            _address = plot.location;
          } else {
            print('Coordenadas inválidas después de la corrección: lat=$lat, long=$long');
          }

          print('Controladores configurados con: ${plot.plot_name}, ${plot.location}, ${plot.area}');
        } else {
          _errorMessage = 'No se encontró información de la parcela';
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando parcela: $e');
      setState(() {
        _errorMessage = 'Error cargando datos: ${e.toString()}';
        _isLoading = false;
      });
      showToast(message: 'Error cargando datos de la parcela');
    }
  }

  Future<void> _selectLocation() async {
    try {
      final Position currentPosition = await Geolocator.getCurrentPosition();

      // Usar ubicación actual o la seleccionada previamente
      LatLng initialPosition = _selectedLocation ??
          LatLng(currentPosition.latitude, currentPosition.longitude);

      final LatLng? selected = await Get.to(
            () => MapPickerScreen(
          initialPosition: initialPosition,
        ),
      );

      if (selected != null) {
        setState(() {
          _selectedLocation = selected;
          _coordinatesText = '${selected.latitude.toStringAsFixed(6)}, ${selected.longitude.toStringAsFixed(6)}';
          _isGettingAddress = true;
        });

        await _getAddressFromCoordinates(selected);
      }
    } catch (e) {
      print('Error seleccionando ubicación: $e');
      showToast(message: 'Error obteniendo ubicación: ${e.toString()}');
      setState(() {
        _isGettingAddress = false;
      });
    }
  }

  Future<void> _getAddressFromCoordinates(LatLng coordinates) async {
    try {
      final address = await GeocodingService.getAddressFromLatLng(
        coordinates.latitude,
        coordinates.longitude,
      );

      setState(() {
        _address = address;
        _locationController.text = address;
        _isGettingAddress = false;
      });

    } catch (e) {
      print('Error obteniendo dirección: $e');
      setState(() {
        _address = 'No se pudo obtener la dirección';
        _locationController.text = '';
        _isGettingAddress = false;
      });
      showToast(message: 'No se pudo obtener la dirección. Por favor, ingrésala manualmente.');
    }
  }

  Future<void> _updatePlot() async {
    if (_userPlot == null) {
      showToast(message: 'No hay datos de parcela para actualizar');
      return;
    }

    if (_plotNameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _areaController.text.isEmpty) {
      showToast(message: 'Por favor completa todos los campos');
      return;
    }

    if (_selectedLocation == null) {
      showToast(message: 'Por favor, selecciona una ubicación en el mapa');
      return;
    }

    // Validar coordenadas antes de enviar
    if (_selectedLocation!.latitude < -90 || _selectedLocation!.latitude > 90) {
      showToast(message: 'Latitud inválida. Debe estar entre -90 y 90');
      return;
    }

    if (_selectedLocation!.longitude < -180 || _selectedLocation!.longitude > 180) {
      showToast(message: 'Longitud inválida. Debe estar entre -180 y 180');
      return;
    }

    setState(() {
      _isEditing = true;
      _errorMessage = '';
    });

    try {
      final areaText = _areaController.text.trim().replaceAll(',', '.');
      final area = double.tryParse(areaText);

      if (area == null || area <= 0) {
        showToast(message: 'El tamaño debe ser un número positivo válido');
        return;
      }

      print('Enviando actualización con coordenadas:');
      print('Latitud: ${_selectedLocation!.latitude}');
      print('Longitud: ${_selectedLocation!.longitude}');

      final response = await _plotServices.updatePlot(
        plotId: _userPlot!.plot_id,
        plotName: _plotNameController.text.trim(),
        location: _locationController.text.trim(),
        lat: _selectedLocation!.latitude,
        long: _selectedLocation!.longitude,
        area: area,
      );

      if (response.success) {
        modalSuccess(context, 'Parcela actualizada exitosamente', () {
          Get.offAll(() => HomeScreen());
        });
      } else {
        setState(() {
          _errorMessage = response.message;
        });
        showToast(message: response.message);
      }
    } catch (e) {
      print('Error actualizando parcela: $e');
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
      showToast(message: 'Error actualizando parcela: ${e.toString()}');
    } finally {
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _goToHome() {
    Get.offAll(() => HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ColorsAgrosig.greenColor),
              ),
              SizedBox(height: 20),
              Text(
                'Cargando información de la parcela...',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
              )
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty && _userPlot == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 60),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _loadUserPlot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsAgrosig.greenColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Indicador de Progreso - 100%
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: Colors.grey.shade200,
                  color: ColorsAgrosig.greenColor,
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 6,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Paso 3 de 3",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "100%",
                    style: TextStyle(
                      color: ColorsAgrosig.greenColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Header con ícono de cerrar
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: ColorsAgrosig.greenColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, color: ColorsAgrosig.greenColor, size: 20),
                      onPressed: () => Get.offAll(() => HomeScreen()),
                    ),
                  ),
                  Spacer(),
                ],
              ),

              const SizedBox(height: 30),

              // Título
              Text(
                '¡Configuración Completada!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ColorsAgrosig.titleLight,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              // Descripción
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tu Parcela ha sido configurada exitosamente. Puedes revisar y actualizar los detalles a continuación.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),

              // Tarjeta de detalles de la parcela
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 25,
                      offset: Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la sección
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ColorsAgrosig.greenColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.agriculture_rounded,
                            color: ColorsAgrosig.greenColor,
                            size: 26,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Detalles de la Parcela',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ColorsAgrosig.titleLight,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 25),

                    // Campo Nombre de la Parcela
                    _buildDetailField(
                      label: 'Nombre de la Parcela',
                      icon: Icons.badge_outlined,
                      controller: _plotNameController,
                      hintText: "ej: Finca de la Familia",
                    ),

                    SizedBox(height: 20),

                    // Campo Localidad
                    _buildDetailField(
                      label: 'Localidad',
                      icon: Icons.location_on_outlined,
                      controller: _locationController,
                      hintText: 'Localidad de la parcela',
                    ),

                    SizedBox(height: 20),

                    // Campo Ubicación en el Mapa
                    _buildMapLocationField(),

                    SizedBox(height: 20),

                    // Campo Tamaño
                    _buildDetailField(
                      label: 'Tamaño (m²)',
                      icon: Icons.map_sharp,
                      controller: _areaController,
                      hintText: 'Tamaño en metros cuadrados',
                      isNumber: true,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Botón Actualizar Parcela
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsAgrosig.greenColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: ColorsAgrosig.greenColor.withOpacity(0.3),
                  ),
                  onPressed: _isEditing ? null : _updatePlot,
                  child: _isEditing
                      ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_rounded, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Actualizar Detalles',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Botón Ir al Inicio
              Container(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  icon: Icon(Icons.home_rounded, size: 22),
                  label: Text(
                    'Ir al Inicio',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(color: ColorsAgrosig.greenColor, width: 2),
                    foregroundColor: ColorsAgrosig.greenColor,
                    backgroundColor: Colors.transparent,
                  ),
                  onPressed: _goToHome,
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ColorsAgrosig.greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: ColorsAgrosig.greenColor, size: 18),
            ),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                fontSize: 15,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          height: 52,
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ColorsAgrosig.greenColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ColorsAgrosig.greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.map_outlined, color: ColorsAgrosig.greenColor, size: 18),
            ),
            SizedBox(width: 10),
            Text(
              'Ubicación en el Mapa',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                fontSize: 15,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _selectLocation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: _selectedLocation != null ? ColorsAgrosig.greenColor : Colors.grey,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _coordinatesText,
                        style: TextStyle(
                          color: _selectedLocation != null ? Colors.grey.shade800 : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      if (_isGettingAddress) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(ColorsAgrosig.greenColor),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Obteniendo dirección...',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                _isGettingAddress
                    ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(ColorsAgrosig.greenColor),
                  ),
                )
                    : Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade500,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
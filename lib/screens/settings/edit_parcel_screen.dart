import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import '../../components/helper/modal_success.dart';
import '../../components/picker/map_picker.dart';
import '../../components/toast/toats.dart';
import '../../domain/models/plot/plot_model.dart';
import '../../domain/services/plot_services/geocodig_services.dart';
import '../../domain/services/plot_services/plot_services.dart';

class EditParcelScreen extends StatefulWidget {
  const EditParcelScreen({Key? key}) : super(key: key);

  @override
  State<EditParcelScreen> createState() => _EditParcelScreenState();
}

class _EditParcelScreenState extends State<EditParcelScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  // Servicios
  final PlotServices _plotServices = PlotServices();
  final GeocodingService _geocodingService = GeocodingService();

  // Variables de estado
  Plot? _currentPlot;
  LatLng? _selectedLocation;
  String _coordinatesText = 'selecciona en el mapa';
  String _address = '';
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isGettingAddress = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPlotData();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _nameController.dispose();
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

  Future<void> _loadPlotData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final plot = await _plotServices.getUbicationPlot();

      print('Plot loaded: $plot');

      setState(() {
        _currentPlot = plot;
        if (plot != null) {
          _nameController.text = plot.plot_name;
          _locationController.text = plot.location;
          _areaController.text = plot.area.toString();

          // Si tenemos coordenadas, las establecemos
          if (plot.lat != 0.0 && plot.long != 0.0) {
            _selectedLocation = LatLng(plot.lat, plot.long);
            _coordinatesText = '${plot.lat.toStringAsFixed(6)}, ${plot.long.toStringAsFixed(6)}';
            _address = plot.location;
          }

          print('Controllers set with: ${plot.plot_name}, ${plot.location}, ${plot.area}');
        } else {
          _errorMessage = 'No se encontró información de la parcela';
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading plot data: $e');
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
      final LatLng? selected = await Get.to(
            () => MapPickerScreen(
          initialPosition: LatLng(
            currentPosition.latitude,
            currentPosition.longitude,
          ),
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
      print('Error getting address: $e');
      setState(() {
        _address = 'No se pudo obtener la dirección';
        _locationController.text = '';
        _isGettingAddress = false;
      });
      showToast(message: 'No se pudo obtener la dirección. Por favor, ingrésala manualmente.');
    }
  }

  Future<void> _updatePlot() async {
    if (_currentPlot == null) {
      showToast(message: 'No hay datos de parcela para actualizar');
      return;
    }

    if (_nameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _areaController.text.isEmpty) {
      showToast(message: 'Por favor, completa todos los campos');
      return;
    }

    if (_selectedLocation == null) {
      showToast(message: 'Por favor, selecciona una ubicación en el mapa');
      return;
    }

    setState(() {
      _isUpdating = true;
      _errorMessage = '';
    });

    try {
      final areaText = _areaController.text.trim().replaceAll(',', '.');
      final area = double.tryParse(areaText);

      if (area == null || area <= 0) {
        showToast(message: 'El área debe ser un número positivo válido');
        return;
      }

      final response = await _plotServices.updatePlot(
        plotId: _currentPlot!.plot_id,
        plotName: _nameController.text.trim(),
        location: _locationController.text.trim(),
        lat: _selectedLocation!.latitude,
        long: _selectedLocation!.longitude,
        area: area,
      );

      if (response.success) {
        modalSuccess(context, 'Parcela actualizada correctamente', () {
          Navigator.pop(context); // Cerrar el modal de éxito
          Navigator.pop(context); // Volver a la pantalla anterior
        });
      } else {
        setState(() {
          _errorMessage = response.message;
        });
        showToast(message: response.message);
      }
    } catch (e) {
      print('Error updating plot: $e');
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
      showToast(message: 'Error actualizando parcela: ${e.toString()}');
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Modificar parcela",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Cargando información de la parcela...')
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty && _currentPlot == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Modificar parcela",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 50),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadPlotData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D927F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Reintentar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Modificar parcela",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Editar nombre de la parcela",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            _buildTextField(
              hintText: "Ex: Parcela 1",
              controller: _nameController,
            ),
            const SizedBox(height: 15),

            const Text(
              "Localidad",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            _buildTextField(
              hintText: "Ex: Rayon, Chiapas",
              controller: _locationController,
            ),
            const SizedBox(height: 15),

            const Text(
              "Ubicación en el mapa",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _selectLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: _selectedLocation != null ? Colors.green : Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _coordinatesText,
                            style: TextStyle(
                              color: _selectedLocation != null ? Colors.green.shade700 : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_isGettingAddress) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Obteniendo dirección...',
                                  style: TextStyle(
                                    fontSize: 10,
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
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            const Text(
              "Área m²",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            _buildTextField(
              hintText: "500 m²",
              controller: _areaController,
              keyboardType: TextInputType.number,
            ),

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),

            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D927F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isUpdating ? null : _updatePlot,
                  child: _isUpdating
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    "Guardar",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6D927F)),
        ),
      ),
    );
  }
}
import 'package:agrosig_app/screens/onboarding_plot/start_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import '../../components/custom/text_custom.dart';
import '../../components/forms/form_fiel.dart';
import '../../components/helper/error_message.dart';
import '../../components/helper/modal_success.dart';
import '../../components/picker/map_picker.dart';
import '../../components/theme/colors_agrosig.dart';
import '../../components/toast/toats.dart';
import '../../domain/services/plot_services/geocodig_services.dart';
import '../../domain/services/plot_services/plot_services.dart';
import 'finish_setup_screen.dart';

class SettingPlotScreen extends StatefulWidget {
  @override
  _SettingPlotScreenState createState() => _SettingPlotScreenState();
}

class _SettingPlotScreenState extends State<SettingPlotScreen> {
  late TextEditingController _nameController;
  late TextEditingController _areaController;
  late TextEditingController _locationController;
  final _keyForm = GlobalKey<FormState>();

  LatLng? _selectedLocation;
  String _coordinatesText = 'Seleccionar ubicación en el mapa';
  String _address = '';
  bool _isLoading = false;
  bool _isGettingAddress = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _areaController = TextEditingController();
    _locationController = TextEditingController();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showToast(message: 'Por favor activa los servicios de ubicación');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showToast(message: 'Los permisos de ubicación fueron denegados');
      }
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
      print('Error obteniendo dirección: $e');
      setState(() {
        _address = 'No se pudo obtener la dirección';
        _locationController.text = '';
        _isGettingAddress = false;
      });
      showToast(message: 'No se pudo obtener la dirección automáticamente. Por favor ingrésala manualmente.');
    }
  }

  void _clearForm() {
    _nameController.clear();
    _areaController.clear();
    _locationController.clear();
    setState(() {
      _selectedLocation = null;
      _coordinatesText = 'Seleccionar ubicación en el mapa';
      _address = '';
    });
  }

  Future<void> _savePlot() async {
    if (_selectedLocation == null) {
      showToast(message: 'Por favor selecciona una ubicación en el mapa');
      return;
    }

    if (!_keyForm.currentState!.validate()) {
      showToast(message: 'Por favor completa todos los campos');
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      showToast(message: 'Por favor espera a que cargue la dirección o ingrésala manualmente');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final areaText = _areaController.text.trim().replaceAll(',', '.');
      final area = double.tryParse(areaText);

      if (area == null || area <= 0) {
        showToast(message: 'El tamaño debe ser un número positivo válido');
        return;
      }

      final response = await plotServices.registerPlot(
        plotName: _nameController.text.trim(),
        location: _locationController.text.trim(),
        lat: _selectedLocation!.latitude,
        long: _selectedLocation!.longitude,
        area: area,
      );

      if (response.success) {
        modalSuccess(context, 'Parcela registrada exitosamente', () {
          Get.offAll(() => FinishSetupPlot());
          _clearForm();
        });
      } else {
        errorMessageSnack(context, response.message);
      }
    } catch (e) {
      print('Error en _savePlot: $e');
      showToast(message: 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorsAgrosig.greenColor.withOpacity(0.1),
          ),
          child: IconButton(
            onPressed: () => Get.offAll(() => StarSetupScreen()),
            icon: Icon(Icons.arrow_back, color: ColorsAgrosig.greenColor, size: 20),
            padding: EdgeInsets.zero,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextCustom(
          text: "Configurar tu Parcela",
          color: ColorsAgrosig.titleLight,
          fontSize: 23,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _keyForm,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicador de Progreso
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: LinearProgressIndicator(
                    value: 0.5, // 50% de progreso
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
                      "Paso 2 de 3",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "50%",
                      style: TextStyle(
                        color: ColorsAgrosig.greenColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32),

                // Texto de Bienvenida
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorsAgrosig.greenColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ColorsAgrosig.greenColor.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.eco, color: ColorsAgrosig.greenColor, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Rellena los datos solicitados para acceder a AgroSig y comienza a descrubir el potencial de la aplicación.",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Sección del Formulario
                _buildFormSection(),

                SizedBox(height: 40),

                _buildSavePlotButton(),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre de la Parcela
        _buildLabel("Nombre de la Parcela", Icons.agriculture_outlined),
        SizedBox(height: 8),
        FormFieldAgro(
          controller: _nameController,
          hintText: "ej: Parcela de Alex",
          prefixIcon: Icon(Icons.agriculture_outlined, color: Colors.grey.shade500, size: 20),
          validator: RequiredValidator(errorText: 'El nombre es requerido'),
        ),

        SizedBox(height: 24),

        // Sección de Ubicación
        _buildLocationSection(),

        SizedBox(height: 24),

        // Tamaño de la Parcela
        _buildLabel("Tamaño de la Parcela (m²)", Icons.map_sharp),
        SizedBox(height: 8),
        FormFieldAgro(
          controller: _areaController,
          hintText: 'ej: 10000 (para 1 hectárea)',
          keyboardType: TextInputType.number,
          prefixIcon: Icon(Icons.map_sharp, color: Colors.grey.shade500, size: 20),
          validator: MultiValidator([
            RequiredValidator(errorText: 'El tamaño es requerido'),
            PatternValidator(r'^[0-9]+(\.[0-9]+)?$',
                errorText: 'Ingresa un número válido'),
          ]),
        ),

        // Nota sobre conversión
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '1 hectárea = 10,000 m² • 1 acre = 4,047 m²',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ColorsAgrosig.greenColor),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Ubicación", Icons.location_on_outlined),
        SizedBox(height: 12),

        // Botón de Selección en Mapa
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedLocation != null
                  ? ColorsAgrosig.greenColor.withOpacity(0.3)
                  : Colors.grey.shade300,
              width: _selectedLocation != null ? 2 : 1,
            ),
            color: _selectedLocation != null
                ? ColorsAgrosig.greenColor.withOpacity(0.02)
                : Colors.transparent,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _selectLocation,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorsAgrosig.greenColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.map_outlined,
                          color: ColorsAgrosig.greenColor, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seleccionar en el Mapa',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: ColorsAgrosig.greenColor,
                              fontSize: 15,
                            ),
                          ),
                          if (_coordinatesText != 'Seleccionar ubicación en el mapa') ...[
                            SizedBox(height: 4),
                            Text(
                              _coordinatesText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
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
                        color: ColorsAgrosig.greenColor,
                      ),
                    )
                        : Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: Colors.grey.shade500),
                  ],
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 16),

        // Campo de Dirección
        Text(
          'Dirección',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        FormFieldAgro(
          controller: _locationController,
          hintText: 'La dirección se completará automáticamente',
          prefixIcon: Icon(Icons.place_outlined, color: Colors.grey.shade500, size: 20),
          validator: RequiredValidator(errorText: 'La dirección es requerida'),
          enabled: !_isGettingAddress,
        ),

        // Indicadores de Carga y Estado
        if (_isGettingAddress) ...[
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Obteniendo dirección...',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],

        if (_address.isNotEmpty && !_isGettingAddress) ...[
          SizedBox(height: 12),
          if (_address != 'No se pudo obtener la dirección') ...[
            // ✅ Dirección detectada correctamente
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dirección detectada: $_address',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // 🟣 No se pudo detectar la dirección (mostrar en morado)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.deepPurple, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No fue posible detectar la ubicación automáticamente. '
                          'Por favor ingresa la dirección manualmente. '
                          'Esto puede deberse a problemas de conexión a Internet o GPS.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.deepPurple.shade700,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildSavePlotButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ColorsAgrosig.greenColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: (_isLoading || _isGettingAddress) ? null : _savePlot,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsAgrosig.greenColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 24),
          ),
          child: _isLoading
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continuar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
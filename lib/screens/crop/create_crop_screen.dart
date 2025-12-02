import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../../../components/custom/text_custom.dart';
import '../../../components/forms/form_fiel.dart';
import '../../../components/theme/colors_agrosig.dart';
import '../../../domain/models/crop/crop_model.dart';
import '../../../domain/services/crop_services/crop_services.dart';
import '../../components/helper/error_message.dart';
import '../../components/helper/modal_success.dart';

class CreateCropScreen extends StatefulWidget {
  const CreateCropScreen({Key? key}) : super(key: key);

  @override
  State<CreateCropScreen> createState() => _CreateCropScreenState();
}

class _CreateCropScreenState extends State<CreateCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final CropService _cropService = CropService();
  bool _isLoading = false;

  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _plantingDateController = TextEditingController();
  final TextEditingController _harvestDateController = TextEditingController();

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorsAgrosig.primaryColor,
              onPrimary: Colors.white,
              onSurface: ColorsAgrosig.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  // Convertir fecha de DD/MM/YYYY a YYYY-MM-DD para el backend
  String _formatDateForBackend(String date) {
    final parts = date.split('/');
    if (parts.length == 3) {
      return "${parts[2]}-${parts[1]}-${parts[0]}";
    }
    return date;
  }

  Future<void> _saveCrop() async {
    if (!_formKey.currentState!.validate()) {
      errorMessageSnack(context, "Por favor, completa todos los campos correctamente");
      return;
    }

    // Validar que la fecha de cosecha sea posterior a la de siembra
    if (_plantingDateController.text.isNotEmpty && _harvestDateController.text.isNotEmpty) {
      final plantingDate = _parseDate(_plantingDateController.text);
      final harvestDate = _parseDate(_harvestDateController.text);

      if (harvestDate.isBefore(plantingDate)) {
        errorMessageSnack(context, "La fecha de cosecha debe ser posterior a la fecha de siembra");
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear objeto Crop para enviar
      final newCrop = Crop(
        cropId: 0,
        userId: 0,
        plotId: 0,
        cropType: _typeController.text,
        cropVariety: _varietyController.text,
        plantingDate: _plantingDateController.text.isNotEmpty
            ? DateTime.parse(_formatDateForBackend(_plantingDateController.text))
            : null,
        harvestDate: _harvestDateController.text.isNotEmpty
            ? DateTime.parse(_formatDateForBackend(_harvestDateController.text))
            : null,
        isActive: true,
        costTotal: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        plotName: null,
      );

      final response = await _cropService.registerCrop(newCrop);

      if (response.success) {
        // Mostrar modal de éxito
        modalSuccess(
            context,
            'Cultivo creado exitosamente',
                () {
              Navigator.of(context).pop(); // Cerrar el modal
              Get.back(result: true); // Regresar a la lista de cultivos
            }
        );
      } else {
        errorMessageSnack(context, response.message);
      }
    } catch (error) {
      errorMessageSnack(context, "Error al crear el cultivo: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  DateTime _parseDate(String date) {
    final parts = date.split('/');
    return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
        ),
        title: const TextCustom(
          text: "Registrar Cultivo",
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
            children: [
              const SizedBox(height: 15.0),

              // Imagen decorativa
              /*Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: ColorsAgrosig.primaryColor.withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    Icons.agriculture_outlined,
                    size: 60,
                    color: ColorsAgrosig.primaryColor.withOpacity(0.7),
                  ),
                ),
              ),*/

              const TextCustom(
                text: "Tipo de cultivo",
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 8.0),
              FormFieldAgro(
                controller: _typeController,
                hintText: "Ex: Tomate, Fresa, Maíz",
                validator: RequiredValidator(errorText: "Este campo es obligatorio"),
              ),
              const SizedBox(height: 20.0),

              const TextCustom(
                text: "Variedad de cultivo",
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 8.0),
              FormFieldAgro(
                controller: _varietyController,
                hintText: "Ex: Bola, Camarosa, Criollo",
                validator: RequiredValidator(errorText: "Este campo es obligatorio"),
              ),
              const SizedBox(height: 20.0),

              const TextCustom(
                text: "Fecha de plantación",
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 8.0),
              GestureDetector(
                onTap: () => _selectDate(context, _plantingDateController),
                child: AbsorbPointer(
                  child: FormFieldAgro(
                    controller: _plantingDateController,
                    hintText: "Seleccionar fecha",
                    validator: RequiredValidator(errorText: "Selecciona una fecha"),
                    readOnly: true,
                    enabled: true,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        color: ColorsAgrosig.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              const TextCustom(
                text: "Fecha de cosecha",
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 8.0),
              GestureDetector(
                onTap: () => _selectDate(context, _harvestDateController),
                child: AbsorbPointer(
                  child: FormFieldAgro(
                    controller: _harvestDateController,
                    hintText: "Seleccionar fecha",
                    validator: RequiredValidator(errorText: "Selecciona una fecha"),
                    readOnly: true,
                    enabled: true,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        color: ColorsAgrosig.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35.0),

              _buildSaveButton(),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3F6D52).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _isLoading ? null : _saveCrop,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            height: 55,
            decoration: BoxDecoration(
              gradient: _isLoading
                  ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                  : const LinearGradient(
                colors: [Color(0xFF88B888), Color(0xFF3F6D52)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Guardar Cultivo",
                    style: GoogleFonts.getFont(
                      'Roboto',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
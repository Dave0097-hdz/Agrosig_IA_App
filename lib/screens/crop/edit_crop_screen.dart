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

class EditCropScreen extends StatefulWidget {
  final Crop crop;

  const EditCropScreen({Key? key, required this.crop}) : super(key: key);

  @override
  State<EditCropScreen> createState() => _EditCropScreenState();
}

class _EditCropScreenState extends State<EditCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final CropService _cropService = CropService();
  bool _isLoading = false;

  late TextEditingController _typeController;
  late TextEditingController _varietyController;
  late TextEditingController _plantingDateController;
  late TextEditingController _harvestDateController;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.crop.cropType);
    _varietyController = TextEditingController(text: widget.crop.cropVariety ?? '');
    _plantingDateController = TextEditingController(
        text: widget.crop.plantingDate != null
            ? _formatDateForDisplay(widget.crop.plantingDate!)
            : ''
    );
    _harvestDateController = TextEditingController(
        text: widget.crop.harvestDate != null
            ? _formatDateForDisplay(widget.crop.harvestDate!)
            : ''
    );
  }

  String _formatDateForDisplay(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  DateTime _parseDate(String date) {
    final parts = date.split('/');
    return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final initialDate = controller.text.isNotEmpty
        ? _parseDate(controller.text)
        : DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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
      controller.text = _formatDateForDisplay(picked);
    }
  }

  Future<void> _updateCrop() async {
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
      final updatedCrop = widget.crop.copyWith(
        cropType: _typeController.text,
        cropVariety: _varietyController.text,
        plantingDate: _plantingDateController.text.isNotEmpty
            ? _parseDate(_plantingDateController.text)
            : null,
        harvestDate: _harvestDateController.text.isNotEmpty
            ? _parseDate(_harvestDateController.text)
            : null,
      );

      final response = await _cropService.updateCrop(widget.crop.cropId, updatedCrop);

      if (response.success) {
        modalSuccess(
            context,
            'Cultivo actualizado exitosamente',
                () {
              Navigator.of(context).pop(); // Cerrar el modal
              Get.back(result: true); // Regresar a la lista de cultivos
            }
        );
      } else {
        errorMessageSnack(context, response.message);
      }
    } catch (error) {
      errorMessageSnack(context, "Error al actualizar el cultivo: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          text: "Editar Cultivo",
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

              // Información del cultivo actual
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorsAgrosig.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorsAgrosig.primaryColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.agriculture,
                      color: ColorsAgrosig.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Editando cultivo",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ColorsAgrosig.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${widget.crop.cropType} - ${widget.crop.plotName ?? 'Parcela ${widget.crop.plotId}'}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25.0),

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

              _buildUpdateButton(),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
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
          onTap: _isLoading ? null : _updateCrop,
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
                    Icons.update,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Actualizar Cultivo",
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/forms/activity_form_data.dart';
import '../../components/helper/error_message.dart';
import '../../components/helper/modal_success.dart';
import '../../components/helper/unit_helper.dart';
import '../../controller/provider/activity_provider.dart';

class AddActivityScreen extends ConsumerStatefulWidget {
  final int cropId;

  const AddActivityScreen({super.key, required this.cropId});

  @override
  ConsumerState<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends ConsumerState<AddActivityScreen> {
  final ActivityFormData _formData = ActivityFormData.newActivity();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final List<String> activityTypes = [
    'Siembra',
    'Riego',
    'Fertilización',
    'Poda',
    'Control de plagas',
    'Cosecha',
    'Limpieza',
    'Preparación de suelo',
    'Otro'
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header informativo
            _buildHeader(),
            const SizedBox(height: 8),

            // Formulario con scroll
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Información básica
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),

                    // Sección de insumos
                    _buildInputsSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Footer con total y botón
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: const Text(
        'Nueva Actividad',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
        color: Colors.black87,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline_rounded, size: 20),
          onPressed: _showHelpDialog,
          color: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_ind_rounded,
              color: Color(0xFF2E7D32),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrar Nueva Actividad',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Completa la información de la actividad agrícola',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de sección
            _buildSectionTitle('Información Básica', Icons.info_outline_rounded),
            const SizedBox(height: 16),

            // Tipo de actividad
            _buildActivityTypeField(),
            const SizedBox(height: 16),

            // Fecha
            _buildDateField(),
            const SizedBox(height: 16),

            // Descripción
            _buildDescriptionField(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Actividad *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: _formData.activityType.isEmpty ? null : _formData.activityType,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'Selecciona el tipo de actividad',
            ),
            items: activityTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _formData.activityType = newValue ?? '';
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor selecciona un tipo de actividad';
              }
              return null;
            },
            icon: const Icon(Icons.arrow_drop_down_rounded),
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha de la Actividad *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2E7D32)),
            ),
            hintText: 'Selecciona la fecha',
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: IconButton(
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                onPressed: _selectDate,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ),
          controller: TextEditingController(
            text: '${_formData.date.day}/${_formData.date.month}/${_formData.date.year}',
          ),
          validator: (value) {
            if (_formData.date == null) {
              return 'Por favor selecciona una fecha';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2E7D32)),
            ),
            hintText: 'Describe los detalles de la actividad realizada...',
            contentPadding: const EdgeInsets.all(12),
          ),
          onChanged: (value) {
            setState(() {
              _formData.description = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildInputsSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de insumos
            Row(
              children: [
                _buildSectionTitle('Insumos Utilizados', Icons.inventory_2_rounded),
                const Spacer(),
                _buildAddInputButton(),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de insumos
            if (_formData.inputs.isEmpty)
              _buildEmptyInputsState()
            else
              ..._formData.inputs.asMap().entries.map((entry) {
                final index = entry.key;
                final input = entry.value;
                return _buildInputCard(input, index);
              }).toList(),

            const SizedBox(height: 8),
            _buildTotalCost(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddInputButton() {
    return FloatingActionButton.small(
      onPressed: () {
        setState(() {
          _formData.addInput();
        });
        // Scroll al final después de agregar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      },
      backgroundColor: const Color(0xFF2E7D32),
      foregroundColor: Colors.white,
      child: const Icon(Icons.add_rounded, size: 18),
    );
  }

  Widget _buildEmptyInputsState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          const Text(
            'No hay insumos agregados',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Presiona el botón + para agregar el primer insumo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(InputFormData input, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Header del insumo
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.agriculture_rounded, size: 14, color: const Color(0xFF2E7D32)),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Insumo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (_formData.inputs.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    onPressed: () {
                      setState(() {
                        _formData.removeInput(index);
                      });
                    },
                    color: Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Campos del insumo
            _buildInputRow(input, index),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(InputFormData input, int index) {
    return Column(
      children: [
        // Nombre del insumo
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Nombre del Insumo *',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (value) {
            setState(() {
              input.inputName = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Requerido';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),

        // Cantidad y Unidad
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Cantidad *',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    input.quantity = double.tryParse(value) ?? 0.0;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Cantidad inválida';
                  }
                  if (double.tryParse(value)! <= 0) {
                    return 'La cantidad debe ser mayor a 0';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: input.unit,
                decoration: const InputDecoration(
                  labelText: 'Unidad',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                items: UnitHelper.getAllUnits().map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    input.unit = newValue ?? 'unidad';
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Costo unitario y Unidad de costo
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Costo Unitario *',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    input.unitCost = double.tryParse(value) ?? 0.0;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Costo inválido';
                  }
                  if (double.tryParse(value)! < 0) {
                    return 'El costo no puede ser negativo';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: input.costUnit,
                decoration: const InputDecoration(
                  labelText: 'Unidad Costo',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                items: UnitHelper.getAllUnits().map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    input.costUnit = newValue ?? 'unidad';
                  });
                },
              ),
            ),
          ],
        ),

        // Total del insumo
        if (input.inputName.isNotEmpty && input.quantity > 0 && input.unitCost > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Costo total del insumo:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '\$${input.calculateTotalCost().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTotalCost() {
    final totalCost = _formData.totalCost;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Costo Total de la Actividad',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Suma de todos los insumos',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Text(
            '\$${totalCost.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final isLoading = ref.watch(activityProvider).isLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSubmitButton(isLoading),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: const Color(0xFF2E7D32).withOpacity(0.3),
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Guardar Actividad',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _formData.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _formData.date) {
      setState(() {
        _formData.date = picked;
      });
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline_rounded, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Ayuda - Registrar Actividad',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Para registrar una actividad correctamente:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 12),
              _buildHelpItem('Selecciona el tipo de actividad realizada'),
              _buildHelpItem('Especifica la fecha de la actividad'),
              _buildHelpItem('Agrega una descripción detallada (opcional)'),
              _buildHelpItem('Registra todos los insumos utilizados'),
              _buildHelpItem('Verifica que los costos sean correctos'),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF2E7D32).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '💡 Puedes agregar múltiples insumos presionando el botón +',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2E7D32),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF2E7D32),
            ),
            child: Text('Entendido'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2, right: 8),
            child: Icon(
              Icons.circle,
              size: 6,
              color: Color(0xFF2E7D32),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _formData.isValid()) {
      final provider = ref.read(activityProvider.notifier);
      final success = await provider.registerActivity(widget.cropId, _formData);

      if (success) {
        if (mounted) {
          modalSuccess(
            context,
            'Actividad registrada exitosamente',
                () {
              Navigator.pop(context); // Cerrar el modal
              Navigator.pop(context); // Volver a la pantalla anterior
            },
          );
        }
      } else {
        if (mounted) {
          final errorMessage = ref.read(activityProvider).errorMessage;
          errorMessageSnack(context, errorMessage);
        }
      }
    } else {
      errorMessageSnack(context, 'Por favor completa todos los campos requeridos correctamente');
    }
  }
}
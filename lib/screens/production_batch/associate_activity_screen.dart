import 'package:flutter/material.dart';
import '../../domain/models/production/activity_with_inputs_model.dart';
import '../../domain/services/production_services/production_services.dart';

class AsociarActividadesScreen extends StatefulWidget {
  final int productionId;

  const AsociarActividadesScreen({super.key, required this.productionId});

  @override
  State<AsociarActividadesScreen> createState() => _AsociarActividadesScreenState();
}

class _AsociarActividadesScreenState extends State<AsociarActividadesScreen> {
  final ProductionBatchService _productionBatchService = ProductionBatchService();
  List<ActivityWithInputs> _availableActivities = [];
  List<int> _selectedActivityIds = [];
  bool _isLoading = true;
  bool _isAssociating = false;
  String _errorMessage = '';
  String _batchName = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAvailableActivities(),
      _loadBatchName(),
    ]);
  }

  Future<void> _loadAvailableActivities() async {
    try {
      final response = await _productionBatchService.getAvailableActivities(widget.productionId);

      if (response.success) {
        setState(() {
          _availableActivities = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBatchName() async {
    try {
      final response = await _productionBatchService.getProductionBatchDetail(widget.productionId);

      if (response.success) {
        setState(() {
          _batchName = response.data.name;
        });
      }
    } catch (e) {
      setState(() {
        _batchName = 'Lote ${widget.productionId}';
      });
    }
  }

  void _toggleActivitySelection(int activityId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedActivityIds.add(activityId);
      } else {
        _selectedActivityIds.remove(activityId);
      }
    });
  }

  Future<void> _associateActivities() async {
    if (_selectedActivityIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona al menos una actividad'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isAssociating = true;
    });

    try {
      final associateResponse = await _productionBatchService.associateActivities(
        widget.productionId,
        _selectedActivityIds,
      );

      if (associateResponse.success) {
        await Future.delayed(const Duration(milliseconds: 500));
        final qrResponse = await _productionBatchService.refreshQRCode(widget.productionId);

        if (qrResponse.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${associateResponse.message}\nQR actualizado con las nuevas actividades'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Actividades asociadas pero error al actualizar QR: ${qrResponse.message}'),
              duration: const Duration(seconds: 4),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(associateResponse.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al asociar actividades: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isAssociating = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Asociar Actividades",
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2E7D32)),
      ),
      body: Column(
        children: [
          // Header con información del lote
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.agriculture, color: Color(0xFF2E7D32), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _batchName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Selecciona las actividades a asociar",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _selectedActivityIds.length / (_availableActivities.length == 0 ? 1 : _availableActivities.length),
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                ),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Actividades Disponibles",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_isLoading)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cargando actividades...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_errorMessage.isNotEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[300], size: 48),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadData,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Reintentar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_availableActivities.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, color: Colors.grey[400], size: 64),
                              const SizedBox(height: 16),
                              const Text(
                                'No hay actividades disponibles',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Todas las actividades ya están asociadas o no hay actividades creadas',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: _availableActivities.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final activity = _availableActivities[index];
                            final isSelected = _selectedActivityIds.contains(activity.activityId);

                            return _ActividadCard(
                              isSelected: isSelected,
                              nombreActividad: activity.activityType,
                              fechaActividad: _formatDate(activity.date),
                              detalles: activity.inputs.map((input) =>
                              "${input.inputName} - ${input.quantity} ${input.unit}"
                              ).toList(),
                              costoTotal: activity.costTotal,
                              onSelectionChanged: (selected) {
                                _toggleActivitySelection(activity.activityId, selected);
                              },
                            );
                          },
                        ),
                      ),
                ],
              ),
            ),
          ),

          // Footer con botón
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "${_selectedActivityIds.length} actividad(es) seleccionada(s)",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: const Color(0xFF4CAF50).withOpacity(0.3),
                    ),
                    onPressed: _isAssociating ? null : _associateActivities,
                    child: _isAssociating
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.link, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Asociar Actividades",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActividadCard extends StatelessWidget {
  final bool isSelected;
  final String nombreActividad;
  final String fechaActividad;
  final List<String> detalles;
  final double costoTotal;
  final Function(bool) onSelectionChanged;

  const _ActividadCard({
    required this.isSelected,
    required this.nombreActividad,
    required this.fechaActividad,
    required this.detalles,
    required this.costoTotal,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSelectionChanged(!isSelected);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E8) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checkbox mejorado
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 12, top: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[400]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    nombreActividad,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Color(0xFF1B5E20),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FD),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    fechaActividad,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1976D2),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            if (costoTotal > 0) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Costo: \$${costoTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],

                            if (detalles.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Insumos:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...detalles.map(
                                    (detalle) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 4,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF4CAF50),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          detalle,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Badge de seleccionado
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
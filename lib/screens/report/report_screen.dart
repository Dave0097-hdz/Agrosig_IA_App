import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/helper/error_message.dart';
import '../../domain/models/crop/crop_model.dart';
import '../../domain/services/crop_services/crop_services.dart';
import '../../domain/services/report_services/crop_report_services.dart';
import '../crop/crop_report_preview_screen.dart';

class SelectCropReportScreen extends StatefulWidget {
  const SelectCropReportScreen({super.key});

  @override
  State<SelectCropReportScreen> createState() => _SelectCropReportScreenState();
}

class _SelectCropReportScreenState extends State<SelectCropReportScreen> {
  final CropService _cropService = CropService();
  final CropReportService _reportService = CropReportService();
  List<Crop> _crops = [];
  bool _isLoading = true;
  Crop? _selectedCrop;
  final Map<int, bool> _cropValidationCache = {};
  final Map<int, String> _cropValidationError = {};

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _cropService.getCrops(page: 1, limit: 100);
      if (response.success) {
        setState(() {
          _crops = response.data.crops;
          _isLoading = false;
        });
        // Pre-validar cultivos en segundo plano
        _prevalidateCrops();
      } else {
        errorMessageSnack(context, response.message);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      errorMessageSnack(context, 'Error al cargar cultivos: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _prevalidateCrops() async {
    for (final crop in _crops) {
      try {
        print('Validando cultivo ${crop.cropId}: ${crop.cropType}');

        final reportResponse = await _reportService.getReportData(crop.cropId);

        if (reportResponse.success && reportResponse.data != null) {
          final hasData = reportResponse.data!.activities.isNotEmpty ||
              reportResponse.data!.summary.totalCost > 0;

          _cropValidationCache[crop.cropId] = hasData;
          _cropValidationError.remove(crop.cropId);

          print('Cultivo ${crop.cropId} validado: $hasData');
        } else {
          _cropValidationCache[crop.cropId] = false;
          _cropValidationError[crop.cropId] = reportResponse.message;
          print(
              'Error en respuesta para cultivo ${crop.cropId}: ${reportResponse.message}');
        }
      } catch (e) {
        _cropValidationCache[crop.cropId] = false;
        _cropValidationError[crop.cropId] = e.toString();
        print('Excepción validando cultivo ${crop.cropId}: $e');
      }
    }
    setState(() {});
  }

  bool _canGenerateReport(Crop crop) {
    if (_cropValidationCache.containsKey(crop.cropId)) {
      return _cropValidationCache[crop.cropId]!;
    }

    return crop.costTotal > 0;
  }

  String _getCropStatus(Crop crop) {
    if (!_cropValidationCache.containsKey(crop.cropId)) {
      return crop.costTotal > 0 ? "Validando..." : "Sin datos";
    }

    if (_cropValidationError.containsKey(crop.cropId)) {
      return "Error en validación";
    }

    return _canGenerateReport(crop)
        ? "Listo para reporte"
        : "Datos insuficientes";
  }

  Color _getStatusColor(Crop crop) {
    if (!_cropValidationCache.containsKey(crop.cropId)) {
      return crop.costTotal > 0 ? Colors.orange : Colors.grey;
    }

    if (_cropValidationError.containsKey(crop.cropId)) {
      return Colors.red;
    }

    return _canGenerateReport(crop) ? Colors.green : Colors.red;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _generateReport() async {
    if (_selectedCrop == null) {
      errorMessageSnack(
          context, 'Selecciona un cultivo para generar el reporte');
      return;
    }

    if (!_canGenerateReport(_selectedCrop!)) {
      errorMessageSnack(context,
          'Este cultivo no tiene datos suficientes para generar un reporte. Agrega actividades e insumos primero.');
      return;
    }

    // Navegar a previsualización del reporte
    Get.to(() => CropReportPreviewScreen(cropId: _selectedCrop!.cropId));
  }

  void _showCropDetails(Crop crop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.agriculture, color: Colors.green[700]),
              const SizedBox(width: 12),
              const Text('Detalles del Cultivo'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Tipo', crop.cropType),
              _buildDetailRow(
                  'Variedad', crop.cropVariety ?? 'No especificada'),
              _buildDetailRow(
                  'Parcela', crop.plotName ?? 'Parcela ${crop.plotId}'),
              _buildDetailRow('Fecha Siembra', _formatDate(crop.plantingDate)),
              _buildDetailRow('Fecha Cosecha', _formatDate(crop.harvestDate)),
              _buildDetailRow(
                  'Costo Total', '\$${crop.costTotal.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(crop).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: _getStatusColor(crop).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _canGenerateReport(crop)
                          ? Icons.check_circle
                          : Icons.info,
                      color: _getStatusColor(crop),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getCropStatus(crop),
                        style: TextStyle(
                          color: _getStatusColor(crop),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
            if (_canGenerateReport(crop))
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedCrop = crop;
                  });
                  _generateReport();
                },
                child: const Text('Generar Reporte'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
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
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
        ),
        title: const Text(
          'Generar Reporte de Cultivo',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoading()
          : _crops.isEmpty
              ? _buildEmptyState()
              : _buildCropSelection(),
      floatingActionButton: _selectedCrop != null
          ? FloatingActionButton.extended(
              onPressed: _generateReport,
              icon: const Icon(Icons.assessment, color: Colors.white),
              label: const Text(
                'Generar Reporte',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: _canGenerateReport(_selectedCrop!)
                  ? const Color(0xFF4CAF50)
                  : Colors.grey,
            )
          : null,
    );
  }

  Widget _buildCropSelection() {
    return Column(
      children: [
        // Header informativo
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Selecciona un cultivo para generar un reporte detallado con actividades, insumos y costos.',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Lista de cultivos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _crops.length,
            itemBuilder: (context, index) {
              final crop = _crops[index];
              final canGenerate = _canGenerateReport(crop);
              final isSelected = _selectedCrop?.cropId == crop.cropId;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: isSelected ? Colors.blue.shade50 : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.blue.shade300
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(crop).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.agriculture,
                      color: _getStatusColor(crop),
                    ),
                  ),
                  title: Text(
                    crop.cropType,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Variedad: ${crop.cropVariety ?? "No especificada"}'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(crop.plantingDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(crop).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getCropStatus(crop),
                          style: TextStyle(
                            color: _getStatusColor(crop),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canGenerate)
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[700],
                          size: 20,
                        )
                      else
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[700],
                          size: 20,
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCrop = isSelected ? null : crop;
                    });
                  },
                  onLongPress: () => _showCropDetails(crop),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Cargando cultivos...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.agriculture, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text(
            'No hay cultivos registrados',
            style: TextStyle(
                fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Para generar reportes, primero necesitas crear algunos cultivos en tu sistema.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A38C2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            label: const Text(
              'Regresar a Cultivos',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

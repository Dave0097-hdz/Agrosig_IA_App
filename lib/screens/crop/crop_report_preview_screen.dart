import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/helper/error_message.dart';
import '../../domain/models/report/report_model.dart';
import '../../domain/services/report_services/crop_report_services.dart';

class CropReportPreviewScreen extends StatefulWidget {
  final int cropId;

  const CropReportPreviewScreen({super.key, required this.cropId});

  @override
  State<CropReportPreviewScreen> createState() =>
      _CropReportPreviewScreenState();
}

class _CropReportPreviewScreenState extends State<CropReportPreviewScreen>
    with WidgetsBindingObserver {
  final CropReportService _reportService = CropReportService();
  CropReport? _report;
  bool _isLoading = true;
  bool _isDownloading = false;
  bool _pdfOpened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadReportData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('🔄 Estado de la app cambiado: $state');

    if (state == AppLifecycleState.resumed && _pdfOpened) {
      // La app volvió a primer plano después de abrir el PDF
      print('✅ App reanudada después de abrir PDF');
      _pdfOpened = false;

      // Mostrar mensaje de éxito
      if (mounted) {
        _showSuccessMessage();
      }
    } else if (state == AppLifecycleState.paused) {
      // La app se está yendo a segundo plano
      print('⏸️ App en segundo plano - probablemente abriendo PDF');
    }
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _reportService.getReportData(widget.cropId);
      if (response.success && response.data != null) {
        setState(() {
          _report = response.data;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          errorMessageSnack(context, response.message);
          _safePop();
        }
      }
    } catch (error) {
      if (mounted) {
        errorMessageSnack(context, 'Error al cargar el reporte: $error');
        _safePop();
      }
    }
  }

  void _safePop() {
    if (mounted) {
      Get.back();
    }
  }

  Future<void> _downloadAndOpenPDF() async {
    if (_report == null) return;

    setState(() {
      _isDownloading = true;
      _pdfOpened = true;
    });

    try {
      print('📥 Iniciando descarga y apertura de PDF...');
      await _reportService.downloadAndOpenReportPDF(
        widget.cropId,
        _report!.crop.cropType,
      );

      print('✅ PDF procesado exitosamente');
    } catch (error) {
      print('❌ Error al procesar PDF: $error');
      if (mounted) {
        errorMessageSnack(context, 'Error al generar PDF: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _showSuccessMessage() {
    // Mostrar snackbar en lugar de modal para evitar problemas de contexto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Reporte PDF generado exitosamente',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No especificada';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Manejar el botón de retroceso físicamente
        if (_isDownloading) {
          // Mostrar advertencia
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Espere a que termine la descarga...'),
              duration: Duration(seconds: 2),
            ),
          );
          return false; // No permitir salir durante la descarga
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black87),
            onPressed: _isDownloading ? null : () => Get.back(),
          ),
          title: Text(
            'Reporte: ${_report?.crop.cropType ?? "Cargando..."}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            if (_report != null && !_isDownloading)
              IconButton(
                icon: const Icon(Icons.download, color: Colors.green),
                onPressed: _downloadAndOpenPDF,
                tooltip: 'Descargar PDF',
              ),
          ],
        ),
        body: _isLoading
            ? _buildLoading()
            : _report != null
                ? _buildReportPreview()
                : _buildErrorState(),
        floatingActionButton: _report != null && !_isDownloading
            ? FloatingActionButton.extended(
                onPressed: _downloadAndOpenPDF,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Descargar PDF'),
                backgroundColor: const Color(0xFF4CAF50),
              )
            : null,
      ),
    );
  }

  Widget _buildReportPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen del cultivo
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Resumen del Cultivo'),
                  _buildInfoRow('Tipo de cultivo', _report!.crop.cropType),
                  _buildInfoRow('Variedad',
                      _report!.crop.cropVariety ?? 'No especificada'),
                  _buildInfoRow('Fecha de siembra',
                      _formatDate(_report!.crop.plantingDate)),
                  _buildInfoRow('Fecha de cosecha',
                      _formatDate(_report!.crop.harvestDate)),
                  _buildInfoRow(
                      'Costo total', _formatCurrency(_report!.crop.costTotal)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Resumen de costos
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Resumen de Costos'),
                  _buildInfoRow('Costo total',
                      _formatCurrency(_report!.summary.totalCost)),
                  if (_report!.summary.costByActivityType.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Costos por Actividad:',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    ..._report!.summary.costByActivityType
                        .map((activity) => Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: _buildInfoRow(activity.type,
                                  _formatCurrency(activity.totalCost)),
                            )),
                  ],
                  if (_report!.summary.costByInput.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Costos por Insumo:',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    ..._report!.summary.costByInput.map((input) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: _buildInfoRow(
                              input.type, _formatCurrency(input.totalCost)),
                        )),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Actividades e insumos
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Actividades e Insumos'),
                  if (_report!.activities.isNotEmpty) ...[
                    ..._report!.activities.map((activity) {
                      final activityInputs = _report!.inputs
                          .where((input) =>
                              input.activityId == activity.activityId)
                          .toList();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.assignment,
                                    color: Colors.blue[700], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    activity.activityType,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatCurrency(activity.costTotal),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green[700],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow('Fecha', _formatDate(activity.date)),
                            if (activity.description != null)
                              _buildInfoRow(
                                  'Descripción', activity.description!),
                            if (activityInputs.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Insumos utilizados:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              ...activityInputs.map((input) => Padding(
                                    padding:
                                        const EdgeInsets.only(left: 16, top: 6),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '• ${input.inputName}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: Text(
                                            '${input.quantity} ${input.unit} - ${_formatCurrency(input.unitCost)}/unidad - Total: ${_formatCurrency(input.costTotal)}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    const Center(
                      child: Text(
                        'No hay actividades registradas para este cultivo',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 80), // Espacio para el FAB
        ],
      ),
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
            'Cargando reporte...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar el reporte',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Regresar'),
          ),
        ],
      ),
    );
  }
}

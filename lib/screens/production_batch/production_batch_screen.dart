import 'package:flutter/material.dart';
import '../../components/theme/colors_agroSig.dart';
import '../../components/toast/toats.dart';
import '../../domain/models/production/production_model.dart';
import '../../domain/services/production_services/production_services.dart';
import 'associate_activity_screen.dart';
import 'create_production_batch_screen.dart';
import 'qr_view_screen.dart';

class ProductionBatchScreen extends StatefulWidget {
  const ProductionBatchScreen({super.key});

  @override
  State<ProductionBatchScreen> createState() => _ProductionBatchScreenState();
}

class _ProductionBatchScreenState extends State<ProductionBatchScreen> {
  final ProductionBatchService _productionBatchService = ProductionBatchService();
  List<ProductionBatch> _productionBatches = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalBatches = 0;

  @override
  void initState() {
    super.initState();
    _loadProductionBatches();
  }

  Future<void> _loadProductionBatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _productionBatchService.getProductionBatches(
        page: _currentPage,
        limit: 10,
      );

      if (response.success) {
        setState(() {
          _productionBatches = response.data.batches;
          _totalPages = response.data.pagination.totalPages;
          _totalBatches = response.data.pagination.total;
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
        _errorMessage = 'Error al cargar los lotes: $e';
        _isLoading = false;
      });
    }
  }

  // FLUJO 1: Crear Lote
  void _navigateToCreateBatch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CrearLoteProduccionScreen()),
    ).then((_) {
      _loadProductionBatches();
    });
  }

  // FLUJO 2: Asociar Actividades
  void _navigateToAssociateActivities(int productionId, String batchName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AsociarActividadesScreen(productionId: productionId),
      ),
    ).then((_) {
      _loadProductionBatches();
    });
  }

  // FLUJO 3: Ver/Generar QR
  void _navigateToQRView(int productionId, String batchName, bool hasActivities) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRViewScreen(
          productionId: productionId,
          batchName: batchName,
        ),
      ),
    ).then((_) {
      _loadProductionBatches();
    });
  }

  void _showBatchDetails(int productionId, String batchName) {
    showToast(message: 'Detalles de $batchName');
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Widget _buildQRIndicator(bool hasActivities, int activityCount) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: hasActivities ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: hasActivities ? Colors.green : Colors.orange,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.qr_code_rounded,
            color: hasActivities ? Colors.green : Colors.orange,
            size: 20,
          ),
          if (hasActivities) ...[
            const SizedBox(width: 4),
            Text(
              '$activityCount',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivitiesButton(int productionId, int activityCount, String batchName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: activityCount > 0 ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: activityCount > 0 ? Colors.blue : Colors.grey,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$activityCount',
            style: TextStyle(
              color: activityCount > 0 ? Colors.blue : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.edit_note,
            color: activityCount > 0 ? Colors.blue : Colors.grey,
            size: 16,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: ColorsAgrosig.bgLight,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: ColorsAgrosig.primaryColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: ColorsAgrosig.donContainerColor,
        elevation: 1,
        title: Text(
          'Gestión de Lotes de Producción',
          style: TextStyle(
            color: Colors.black,
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: ColorsAgrosig.primaryColor,
            ),
            onPressed: _loadProductionBatches,
            tooltip: 'Recargar datos manualmente',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ENCABEZADO RESPONSIVO - IDÉNTICO AL DE CULTIVOS
                if (isSmallScreen)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Lista de Lotes de Producción",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          // Botón Crear Lote
                          SizedBox(
                            height: 40,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A38C2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _navigateToCreateBatch,
                              icon: const Icon(Icons.add, color: Colors.white, size: 16),
                              label: const Text(
                                "Crear Lote",
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Lista de Lotes de Producción",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A38C2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onPressed: _navigateToCreateBatch,
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: const Text(
                          "Crear Lote de Producción",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // CONTADOR DE REGISTROS (solo cuando hay datos)
                if (!_isLoading && _productionBatches.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Página $_currentPage de $_totalPages - Mostrando ${_productionBatches.length} de $_totalBatches lotes totales',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),

                // ESTADOS DE LA UI
                if (_isLoading)
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Cargando lotes de producción...'),
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
                          const Icon(Icons.error_outline, color: Colors.red, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _loadProductionBatches,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_productionBatches.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'No hay lotes de producción registrados',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Comienza creando tu primer lote de producción',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _navigateToCreateBatch,
                              icon: const Icon(Icons.add),
                              label: const Text('Crear Primer Lote'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A38C2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  Colors.grey.shade100,
                                ),
                                columnSpacing: 24,
                                dataRowHeight: 60,
                                horizontalMargin: 16,
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      "ID",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Nombre Lote",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Cultivo",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Fecha Creación",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Actividades",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Center(
                                      child: Text(
                                        "QR",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                                rows: _productionBatches.map((batch) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text("L${batch.productionId}"),
                                        onTap: () => _showBatchDetails(batch.productionId, batch.name),
                                      ),
                                      DataCell(
                                        Text(batch.name),
                                        onTap: () => _showBatchDetails(batch.productionId, batch.name),
                                      ),
                                      DataCell(
                                        Text(batch.cropType ?? 'N/A'),
                                        onTap: () => _showBatchDetails(batch.productionId, batch.name),
                                      ),
                                      DataCell(
                                        Text(_formatDate(batch.creationDate)),
                                        onTap: () => _showBatchDetails(batch.productionId, batch.name),
                                      ),
                                      DataCell(
                                        InkWell(
                                          onTap: () => _navigateToAssociateActivities(batch.productionId, batch.name),
                                          child: _buildActivitiesButton(
                                            batch.productionId,
                                            batch.activityCount,
                                            batch.name,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: InkWell(
                                            onTap: () => _navigateToQRView(
                                              batch.productionId,
                                              batch.name,
                                              batch.hasActivities,
                                            ),
                                            child: _buildQRIndicator(
                                              batch.hasActivities,
                                              batch.activityCount,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                const SizedBox(height: 20),

                // PAGINACIÓN MEJORADA - IDÉNTICA A LA DE CULTIVOS
                if (!_isLoading && _productionBatches.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 18),
                            onPressed: _currentPage > 1
                                ? () {
                              setState(() {
                                _currentPage--;
                              });
                              _loadProductionBatches();
                            }
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Página $_currentPage de $_totalPages',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 18),
                            onPressed: _currentPage < _totalPages
                                ? () {
                              setState(() {
                                _currentPage++;
                              });
                              _loadProductionBatches();
                            }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      // BOTÓN FLOTANTE SOLO PARA MÓVIL
      floatingActionButton: isSmallScreen
          ? FloatingActionButton(
        onPressed: _navigateToCreateBatch,
        backgroundColor: const Color(0xFF6A38C2),
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  @override
  void dispose() {
    _productionBatchService.dispose();
    super.dispose();
  }
}
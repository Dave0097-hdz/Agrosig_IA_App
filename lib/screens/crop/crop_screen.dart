import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/theme/colors_agroSig.dart';
import '../../domain/models/crop/crop_model.dart';
import '../../domain/services/crop_services/crop_services.dart';
import '../home/home_screen.dart';
import '../report/report_screen.dart';
import 'create_crop_screen.dart';
import 'edit_crop_screen.dart';

class CropScreen extends StatefulWidget {
  const CropScreen({super.key});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  final CropService _cropService = CropService();
  List<Crop> _crops = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _perPage = 10;

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops({int page = 1}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _cropService.getCrops(page: page, limit: _perPage);

      if (response.success) {
        setState(() {
          _crops = response.data.crops;
          _currentPage = response.data.pagination.currentPage;
          _totalPages = response.data.pagination.totalPages;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackbar(response.message);
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Error al cargar los cultivos: $error');
    }
  }

  Future<void> _deleteCrop(int cropId) async {
    try {
      final response = await _cropService.deleteCrop(cropId);

      if (response.success) {
        _showSuccessSnackbar(response.message);
        _loadCrops(page: _currentPage);
      } else {
        _showErrorSnackbar(response.message);
      }
    } catch (error) {
      _showErrorSnackbar('Error al eliminar el cultivo: $error');
    }
  }

  void _showDeleteConfirmationDialog(int cropId, String cropType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Confirmar Eliminación',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de que deseas eliminar el cultivo?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.agriculture_rounded,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cropType,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCrop(cropId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _navigateToCreateCrop() async {
    final result = await Get.to(() => const CreateCropScreen());
    if (result == true) {
      _loadCrops(page: _currentPage);
    }
  }

  Future<void> _navigateToEditCrop(Crop crop) async {
    final result = await Get.to(() => EditCropScreen(crop: crop));
    if (result == true) {
      _loadCrops(page: _currentPage);
    }
  }

  void _navigateToGenerateReport() {
    Get.to(() => SelectCropReportScreen());
    _showSuccessSnackbar('Generando reporte general de cultivos...');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
          onPressed: () {
            Get.offAll(() => HomeScreen());
          },
        ),
        backgroundColor: ColorsAgrosig.donContainerColor,
        elevation: 1,
        title: Text(
          'Gestión de Cultivos',
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
            onPressed: () => _loadCrops(page: _currentPage),
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
                // ENCABEZADO RESPONSIVE
                if (isSmallScreen)
                // DISEÑO PARA PANTALLAS PEQUEÑAS (Vertical)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Lista de Cultivos",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.start,
                        children: [
                          // Botón Generar Reporte
                          SizedBox(
                            height: 40,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _navigateToGenerateReport,
                              icon: const Icon(
                                  Icons.assessment,
                                  color: Colors.white,
                                  size: 16
                              ),
                              label: const Text(
                                "Generar Reporte",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14
                                ),
                              ),
                            ),
                          ),
                          // Botón Crear Cultivo
                          SizedBox(
                            height: 40,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A38C2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _navigateToCreateCrop,
                              icon: const Icon(Icons.add, color: Colors.white, size: 16),
                              label: const Text(
                                "Crear Cultivo",
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                // DISEÑO PARA PANTALLAS GRANDES (Horizontal)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Lista de Cultivos",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Botón Generar Reporte
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: _navigateToGenerateReport,
                            icon: const Icon(Icons.assessment, color: Colors.white, size: 18),
                            label: const Text(
                              "Generar Reporte",
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Botón Crear Cultivo
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A38C2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: _navigateToCreateCrop,
                            icon: const Icon(Icons.add, color: Colors.white, size: 18),
                            label: const Text(
                              "Crear Cultivo",
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 24),

                if (_isLoading)
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Cargando cultivos...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_crops.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.agriculture, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No hay cultivos registrados',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Presiona "Crear Cultivo" para agregar uno nuevo',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
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
                                    "Tipo de Cultivo",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Variedad",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Fecha Siembra",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Fecha Cosecha",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Costo Total",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Center(
                                    child: Text(
                                      "Acciones",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                              rows: _buildTableRows(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                if (_crops.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: _currentPage > 1
                              ? () => _loadCrops(page: _currentPage - 1)
                              : null,
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back_ios, size: isSmallScreen ? 12 : 14),
                              const SizedBox(width: 4),
                              Text("Anterior", style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ..._buildPaginationButtons(),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: _currentPage < _totalPages
                              ? () => _loadCrops(page: _currentPage + 1)
                              : null,
                          child: Row(
                            children: [
                              Text("Siguiente", style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios, size: isSmallScreen ? 12 : 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildTableRows() {
    return _crops.map((crop) {
      return DataRow(
        cells: [
          DataCell(
            Center(
              child: Text(
                crop.cropId.toString(),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          DataCell(Text(crop.cropType)),
          DataCell(Text(crop.cropVariety ?? "No especificada")),
          DataCell(Center(child: Text(_formatDate(crop.plantingDate)))),
          DataCell(Center(child: Text(_formatDate(crop.harvestDate)))),
          DataCell(
            Center(
              child: Text(
                "\$${crop.costTotal.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: crop.costTotal > 0 ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ),
          DataCell(
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: Color(0xFF6A38C2),
                      size: 22,
                    ),
                    onPressed: () => _navigateToEditCrop(crop),
                    tooltip: 'Editar cultivo',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.red,
                      size: 22,
                    ),
                    onPressed: () => _showDeleteConfirmationDialog(
                      crop.cropId,
                      crop.cropType,
                    ),
                    tooltip: 'Eliminar cultivo',
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  List<Widget> _buildPaginationButtons() {
    List<Widget> buttons = [];
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    final int startPage = _currentPage > 2 ? _currentPage - 1 : 1;
    final int endPage = _currentPage < _totalPages - 1 ? _currentPage + 1 : _totalPages;

    // En pantallas pequeñas, mostrar solo página actual y total
    if (isSmallScreen && _totalPages > 3) {
      buttons.add(
        Text(
          '$_currentPage / $_totalPages',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else {
      // Botón primera página
      if (startPage > 1) {
        buttons.add(_buildPageButton(
          "1",
          isSelected: false,
          onPressed: () => _loadCrops(page: 1),
        ));
        if (startPage > 2) {
          buttons.add(const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text("...", style: TextStyle(color: Colors.grey)),
          ));
        }
      }

      // Botones de páginas
      for (int i = startPage; i <= endPage; i++) {
        buttons.add(_buildPageButton(
          i.toString(),
          isSelected: i == _currentPage,
          onPressed: () => _loadCrops(page: i),
        ));
      }

      // Botón última página
      if (endPage < _totalPages) {
        if (endPage < _totalPages - 1) {
          buttons.add(const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text("...", style: TextStyle(color: Colors.grey)),
          ));
        }
        buttons.add(_buildPageButton(
          _totalPages.toString(),
          isSelected: false,
          onPressed: () => _loadCrops(page: _totalPages),
        ));
      }
    }

    return buttons;
  }

  Widget _buildPageButton(String text, {bool isSelected = false, VoidCallback? onPressed}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6A38C2) : Colors.transparent,
        border: Border.all(
          color: isSelected ? const Color(0xFF6A38C2) : Colors.grey.shade400,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 12,
              vertical: 4
          ),
          minimumSize: Size.zero,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
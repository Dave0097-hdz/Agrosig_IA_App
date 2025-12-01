import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../config/keys.dart';
import '../../domain/models/production/activity_with_inputs_model.dart';
import '../../domain/services/production_services/production_services.dart';
import 'associate_activity_screen.dart';

class QRViewScreen extends StatefulWidget {
  final int productionId;
  final String batchName;

  const QRViewScreen({
    super.key,
    required this.productionId,
    required this.batchName,
  });

  @override
  State<QRViewScreen> createState() => _QRViewScreenState();
}

class _QRViewScreenState extends State<QRViewScreen>
    with WidgetsBindingObserver {
  final ProductionBatchService _productionBatchService =
  ProductionBatchService();
  String? _qrCode;
  bool _isLoading = true;
  bool _hasActivities = false;
  int _activityCount = 0;
  String _errorMessage = '';
  List<ActivityWithInputs> _activities = [];
  Uint8List? _qrImageBytes;
  bool _isGeneratingQR = false;
  String _traceabilityUrl = '';
  String _uniqueCode = '';
  bool _isAppInBackground = false;
  bool _activitiesLoading = false;
  String _activitiesError = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAllData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _productionBatchService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    setState(() {
      _isAppInBackground = state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive;
    });

    if (state == AppLifecycleState.resumed && _isAppInBackground) {
      _checkForUpdates();
    }
  }

  Future<void> _checkForUpdates() async {
    await _loadActivitiesInBackground();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _activitiesError = '';
    });

    try {
      await _loadQRData();
      await _loadActivitiesInBackground();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar datos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadQRData() async {
    try {
      print('🔄 Cargando QR para productionId: ${widget.productionId}');

      final response =
      await _productionBatchService.getQRCodeData(widget.productionId);

      if (response.success) {
        setState(() {
          _qrCode = response.data.qrCode;
          _uniqueCode = response.data.qrData?['unique_code'] ?? '';
          _convertQRToImage();
          _buildTraceabilityUrl();
        });

        setState(() {
          _isLoading = false;
        });

        print('QR cargado - Unique Code: $_uniqueCode');
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
        print('Error cargando QR: ${response.message}');
      }
    } catch (e) {
      print('Error en _loadQRData: $e');
      setState(() {
        _errorMessage = 'Error al cargar QR: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadActivitiesInBackground() async {
    if (_activitiesLoading) return;

    setState(() {
      _activitiesLoading = true;
      _activitiesError = '';
    });

    try {
      final response =
      await _productionBatchService.getBatchActivities(widget.productionId);

      if (response.success) {
        setState(() {
          _activities = response.data;
          _activityCount = _activities.length;
          _hasActivities = _activities.isNotEmpty;
        });
      } else {
        setState(() {
          _activitiesError = response.message;
        });
        print('Error cargando actividades: ${response.message}');
      }
    } catch (e) {
      setState(() {
        _activitiesError = 'Error: $e';
      });
      print('Error en _loadActivitiesInBackground: $e');
    } finally {
      setState(() {
        _activitiesLoading = false;
      });
    }
  }

  void _buildTraceabilityUrl() {
    if (_uniqueCode.isNotEmpty) {
      setState(() {
        _traceabilityUrl = '${Environment.vercelUrl}/trazabilidad/$_uniqueCode';
      });
      print('URL de trazabilidad construida: $_traceabilityUrl');
    } else {
      print('unique_code está vacío, no se puede construir la URL');
    }
  }

  void _convertQRToImage() {
    if (_qrCode == null || _qrCode!.isEmpty) return;

    try {
      if (_qrCode!.contains(',')) {
        final String base64String = _qrCode!.split(',').last;
        _qrImageBytes = base64.decode(base64String);
      }
    } catch (e) {
      print('Error converting QR to image: $e');
      _qrImageBytes = null;
    }
  }

  Future<void> _forceRefreshQR() async {
    setState(() {
      _isGeneratingQR = true;
    });

    try {
      final response =
      await _productionBatchService.refreshQRCode(widget.productionId);

      if (response.success) {
        await _loadQRData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR regenerado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al regenerar QR: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingQR = false;
      });
    }
  }

  void _navigateToAssociateActivities() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AsociarActividadesScreen(productionId: widget.productionId),
      ),
    ).then((_) {
      _loadActivitiesInBackground();
    });
  }

  Future<void> _copyTraceabilityUrl() async {
    if (_traceabilityUrl.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _traceabilityUrl));
      _showSuccessSnackBar('URL copiada al portapapeles');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // MEJORA: Widget simplificado sin botón de abrir navegador
  Widget _buildUrlDisplay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 400;

        return Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            children: [
              // Título responsive
              Text(
                'URL de trazabilidad:',
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),

              // Contenedor de URL responsive
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // URL texto con tamaño responsive
                    SelectableText(
                      _traceabilityUrl,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.blue.shade700,
                        fontFamily: 'RobotoMono',
                        height: 1.4,
                      ),
                      textAlign: TextAlign.left,
                    ),

                    // Información adicional responsive
                    SizedBox(height: isSmallScreen ? 6 : 8),
                    Text(
                      'Copia esta URL y ábrela en tu navegador',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 9 : 10,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isSmallScreen ? 12 : 16),

              // MEJORA: Solo botón de copiar URL, centrado y responsive
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _copyTraceabilityUrl,
                  icon: Icon(
                    Icons.copy,
                    size: isSmallScreen ? 16 : 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Copiar URL al Portapapeles',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 12 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // Información adicional responsive
              SizedBox(height: isSmallScreen ? 8 : 8),
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                        Icons.info_outline,
                        size: isSmallScreen ? 12 : 14,
                        color: Colors.blue.shade700
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 6),
                    Expanded(
                      child: Text(
                        'Pega la URL en cualquier navegador para ver la trazabilidad',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 9 : 10,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQRImage() {
    if (_isGeneratingQR) {
      return Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A38C2)),
              ),
              SizedBox(height: 12),
              Text(
                'Generando QR...',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    if (_qrImageBytes != null) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Image.memory(
          _qrImageBytes!,
          width: 220,
          height: 220,
          fit: BoxFit.contain,
        ),
      );
    } else {
      return _buildErrorWidget();
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          SizedBox(height: 8),
          Text(
            'Error al cargar QR',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesError() {
    if (_activitiesError.isNotEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                _activitiesError,
                style: TextStyle(color: Colors.red[700], fontSize: 12),
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh, size: 16),
              onPressed: _loadActivitiesInBackground,
              color: Colors.red,
            ),
          ],
        ),
      );
    }
    return SizedBox();
  }

  Widget _buildNoActivitiesCard() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 56),
            SizedBox(height: 20),
            Text(
              'No hay actividades asociadas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Para generar el código QR, primero debes asociar actividades a este lote.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToAssociateActivities,
              icon: Icon(Icons.add_task, size: 20),
              label:
              Text('Asociar Actividades', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 400;

        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            child: Column(
              children: [
                // Header con información del lote
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.batchName,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '$_activityCount actividad(es) asociada(s)',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isSmallScreen ? 16 : 24),

                // QR Code
                Column(
                  children: [
                    Text(
                      'Código QR de Trazabilidad',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    _buildQRImage(),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    Text(
                      'Escanea este código QR para ver la trazabilidad completa',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                if (_traceabilityUrl.isNotEmpty) ...[
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  _buildUrlDisplay(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 400;

        return Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _navigateToAssociateActivities,
                  icon: Icon(
                      Icons.edit_note,
                      size: isSmallScreen ? 18 : 20
                  ),
                  label: Text(
                    _hasActivities
                        ? 'Gestionar Actividades'
                        : 'Asociar Actividades',
                    style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 12 : 14,
                    ),
                    side: BorderSide(color: Color(0xFF6A38C2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isGeneratingQR ? null : _forceRefreshQR,
                  icon: _isGeneratingQR
                      ? SizedBox(
                    height: isSmallScreen ? 16 : 18,
                    width: isSmallScreen ? 16 : 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: isSmallScreen ? 18 : 20,
                  ),
                  label: Text(
                    _isGeneratingQR ? 'Generando...' : 'Regenerar QR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 13 : 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6A38C2),
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 12 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Código QR - ${widget.batchName}',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor:
              AlwaysStoppedAnimation<Color>(Color(0xFF6A38C2)),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando código QR...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : _errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 72),
              SizedBox(height: 20),
              Text(
                'Error al cargar',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              Text(
                _errorMessage,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadAllData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6A38C2),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                      horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
      )
          : SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActivitiesError(),

              if (_activitiesLoading)
                Container(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Cargando actividades...'),
                      ],
                    ),
                  ),
                ),

              if (!_hasActivities && _qrCode == null)
                _buildNoActivitiesCard(),
              if (_qrCode != null) _buildQRCodeCard(),
              SizedBox(height: 20),
              _buildActionButtons(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../config/keys.dart';
import '../../../data/core/custom_http_client.dart';
import '../../../data/local_secure/secure_storage.dart';
import '../../models/production/production_model.dart';
import '../../response/response_crop/response_crop.dart';
import '../../response/response_production/response_production.dart';
import '../../response/response_qr/response.qr.dart';

class ProductionBatchService {
  final SecureStorageAgroSig _secureStorage = SecureStorageAgroSig();
  final http.Client _client;

  ProductionBatchService() : _client = CustomHttpClient.create();

  // Crear nuevo lote de producción
  Future<ProductionBatchResponse> registerProductionBatch(
      int cropId, String name) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.post(
        Uri.parse('${Environment.production}/register/$cropId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
        body: jsonEncode({'name': name}),
      );

      print('Register Production Batch Status: ${response.statusCode}');
      print('Register Production Batch Response: ${response.body}');

      if (response.statusCode == 201) {
        final decodedData = jsonDecode(response.body);
        return ProductionBatchResponse(
          success: true,
          message: decodedData['message'] ??
              'Lote de producción creado exitosamente',
          data: ProductionBatch.fromJson(decodedData['data']),
        );
      } else {
        final errorData = json.decode(response.body);
        return ProductionBatchResponse(
          success: false,
          message:
              errorData['message'] ?? 'Error al crear el lote de producción',
          data: null,
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error register production batch: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  // Obtener lista de lotes de producción con paginación
  Future<ProductionBatchListResponse> getProductionBatches(
      {int page = 1, int limit = 10}) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse(
            '${Environment.production}/productions?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Production Batches status: ${response.statusCode}');
      print('Production Batches Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ProductionBatchListResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        return ProductionBatchListResponse(
          success: false,
          message:
              errorData['message'] ?? 'Error al obtener lotes de producción',
          data: ProductionBatchListData(
            batches: [],
            pagination: PaginationInfo(
              currentPage: page,
              perPage: limit,
              total: 0,
              totalPages: 1,
              hasNext: false,
              hasPrev: false,
            ),
          ),
        );
      }
    } catch (error) {
      return ProductionBatchListResponse(
        success: false,
        message: 'Error de conexión: $error',
        data: ProductionBatchListData(
          batches: [],
          pagination: PaginationInfo(
            currentPage: page,
            perPage: limit,
            total: 0,
            totalPages: 1,
            hasNext: false,
            hasPrev: false,
          ),
        ),
      );
    }
  }

  // Obtener detalle de un lote de producción
  Future<ProductionBatchDetailResponse> getProductionBatchDetail(
      int productionId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse('${Environment.production}/production/$productionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        // Crear un objeto vacío si no hay datos
        final data = decodedData['data'] ?? {};

        return ProductionBatchDetailResponse(
          success: true,
          message: decodedData['message'] ??
              'Detalle del lote obtenido exitosamente',
          data: ProductionBatchDetail.fromJson(data),
        );
      } else {
        final errorData = json.decode(response.body);
        return ProductionBatchDetailResponse(
          success: false,
          message:
              errorData['message'] ?? 'Error al obtener el detalle del lote',
          data: ProductionBatchDetail.fromJson({}),
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error getting production batch detail: $error');
      return ProductionBatchDetailResponse(
        success: false,
        message: 'Error en el servidor: ${error.toString()}',
        data: ProductionBatchDetail.fromJson({}),
      );
    }
  }

  // Obtener actividades disponibles para asociar a un lote
  Future<ActivityListResponse> getAvailableActivities(int productionId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse(
            '${Environment.production}/available-activities/$productionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Get Available Activities Status: ${response.statusCode}');
      print('Get Available Activities Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ActivityListResponse.fromJson(responseData);
      } else {
        final errorData = json.decode(response.body);
        return ActivityListResponse(
          success: false,
          message: errorData['message'] ??
              'Error al obtener las actividades disponibles',
          data: [],
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error getting available activities: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  // Obtener actividades asociadas a un lote
  Future<ActivityListResponse> getBatchActivities(int productionId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      print('🔄 Obteniendo actividades para productionId: $productionId');

      final response = await _client.get(
        Uri.parse('${Environment.production}/activities/$productionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final activityResponse = ActivityListResponse.fromJson(responseData);

        print('✅ Actividades obtenidas: ${activityResponse.data.length}');

        // Debug: Imprimir cada actividad
        for (var activity in activityResponse.data) {
          print(
              '📋 Actividad: ${activity.activityType} - ${activity.description}');
          print('   Inputs: ${activity.inputs.length}');
        }

        return activityResponse;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Error al obtener las actividades del lote';

        print('❌ Error: $errorMessage');

        return ActivityListResponse(
          success: false,
          message: errorMessage,
          data: [],
        );
      }
    } on SocketException {
      print('🌐 Error de conexión');
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('💥 Error getting batch activities: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  // Asociar actividades a un lote
  Future<AssociateActivitiesResponse> associateActivities(
      int productionId, List<int> activityIds) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.post(
        Uri.parse(
            '${Environment.production}/associate-activities/$productionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
        body: jsonEncode({'activity_ids': activityIds}),
      );

      print('Associate Activities Status: ${response.statusCode}');
      print('Associate Activities Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return AssociateActivitiesResponse(
          success: true,
          message:
              decodedData['message'] ?? 'Actividades asociadas exitosamente',
          data: decodedData['data'],
        );
      } else {
        final errorData = json.decode(response.body);
        return AssociateActivitiesResponse(
          success: false,
          message: errorData['message'] ?? 'Error al asociar las actividades',
          data: null,
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error associating activities: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  // Generar/Regenerar QR Code
  Future<ProductionBatchResponse> generateQRCode(int productionId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.post(
        Uri.parse('${Environment.production}/generate-qr/$productionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return ProductionBatchResponse(
          success: true,
          message: decodedData['message'] ?? 'QR generado exitosamente',
          data: ProductionBatch.fromJson(decodedData['data']),
        );
      } else {
        final errorData = json.decode(response.body);
        return ProductionBatchResponse(
          success: false,
          message: errorData['message'] ?? 'Error al generar QR',
          data: null,
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error generating QR code: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  // Regenerar QR code después de asociar actividades
  Future<ProductionBatchResponse> refreshQRCode(int productionId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.post(
        Uri.parse('${Environment.production}/generate-qr/$productionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Refresh QR Status: ${response.statusCode}');
      print('Refresh QR Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return ProductionBatchResponse(
          success: true,
          message: decodedData['message'] ?? 'QR actualizado exitosamente',
          data: ProductionBatch.fromJson(decodedData['data']),
        );
      } else {
        final errorData = json.decode(response.body);
        return ProductionBatchResponse(
          success: false,
          message: errorData['message'] ?? 'Error al actualizar QR',
          data: null,
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error refreshing QR code: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  Future<String> getBatchUniqueCode(int productionId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse('${Environment.production}/production/$productionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return decodedData['data']['unique_code'] ?? '';
      } else {
        throw Exception('Error al obtener el código único del lote');
      }
    } catch (error) {
      print('Error getting batch unique code: $error');
      throw Exception('Error al obtener el código único: $error');
    }
  }

  Future<QRCodeResponse> getQRCodeData(int productionId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse('${Environment.production}/get-qr/$productionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Get QR Code Data Status: ${response.statusCode}');
      print('Get QR Code Data Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return QRCodeResponse.fromJson(decodedData);
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? 'Error al obtener el código QR';
        print('Error response: $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error getting QR code data: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  Future<ProductionBatchDetailResponse> getProductionBatchDetailSafe(
      int productionId) async {
    try {
      final response = await getProductionBatchDetail(productionId);
      if (response.success) {
        return response;
      } else {
        // Si falla, intentar una segunda vez después de un breve delay
        await Future.delayed(Duration(milliseconds: 500));
        return await getProductionBatchDetail(productionId);
      }
    } catch (e) {
      print('Error in getProductionBatchDetailSafe: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}

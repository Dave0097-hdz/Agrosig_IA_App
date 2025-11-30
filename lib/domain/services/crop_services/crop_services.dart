import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../config/keys.dart';
import '../../../data/core/custom_http_client.dart';
import '../../../data/local_secure/secure_storage.dart';
import '../../models/crop/crop_model.dart';
import '../../response/response_crop/response_crop.dart';

class CropService {
  final SecureStorageAgroSig _secureStorage = SecureStorageAgroSig();
  final http.Client _client;

  CropService() : _client = CustomHttpClient.create();

  // Crear nuevo cultivo
  Future<CropResponse> registerCrop(Crop crop) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.post(
        Uri.parse('${Environment.crop}/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
        body: jsonEncode(crop.toCreateJson()),
      );

      print('Crop Status: ${response.statusCode}');
      print('Crop Response: ${response.body}');

      if (response.statusCode == 201) {
        // 201 para creación exitosa
        final decodedData = jsonDecode(response.body);
        return CropResponse(
          success: true,
          message: decodedData['message'] ?? 'Cultivo creado exitosamente',
          data: Crop.fromJson(decodedData['data']),
        );
      } else {
        final errorData = json.decode(response.body);
        return CropResponse(
          success: false,
          message: errorData['message'] ?? 'Error al crear el cultivo',
          data: null,
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error crop: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  // Obtener lista de cultivos con paginación
  Future<CropListResponse> getCrops({int page = 1, int limit = 10}) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse('${Environment.crop}/crops?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Crops status: ${response.statusCode}');
      print('Crops Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return CropListResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        return CropListResponse(
          success: false,
          message: errorData['message'] ?? 'Error al obtener cultivos',
          data: CropListData(
            crops: [],
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
      return CropListResponse(
        success: false,
        message: 'Error de conexión: $error',
        data: CropListData(
          crops: [],
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

  // Obtener cultivo por ID
  Future<CropResponse> getCropById(int cropId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse('${Environment.crop}/crop/$cropId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Get Crop Status: ${response.statusCode}');
      print('Get Crop Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return CropResponse(
          success: true,
          message: decodedData['message'] ?? 'Cultivo obtenido exitosamente',
          data: Crop.fromJson(decodedData['data']),
        );
      } else {
        final errorData = json.decode(response.body);
        return CropResponse(
          success: false,
          message: errorData['message'] ?? 'Error al obtener el cultivo',
          data: null,
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error getting crop: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  // Actualizar cultivo
  Future<CropResponse> updateCrop(int cropId, Crop crop) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.patch(
        Uri.parse('${Environment.crop}/update/$cropId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
        body: jsonEncode(crop.toUpdateJson()),
      );

      print('Update Crop Status: ${response.statusCode}');
      print('Update Crop Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return CropResponse(
          success: true,
          message: decodedData['message'] ?? 'Cultivo actualizado exitosamente',
          data: Crop.fromJson(decodedData['data']),
        );
      } else {
        final errorData = json.decode(response.body);
        return CropResponse(
          success: false,
          message: errorData['message'] ?? 'Error al actualizar el cultivo',
          data: null,
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error updating crop: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  // Eliminar cultivo
  Future<CropResponse> deleteCrop(int cropId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.delete(
        Uri.parse('${Environment.crop}/delete/$cropId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Delete Crop Status: ${response.statusCode}');

      // Manejo simplificado para 204
      if (response.statusCode == 204) {
        return CropResponse(
          success: true,
          message: 'Cultivo eliminado exitosamente',
          data: null,
        );
      }

      // Para otros códigos de éxito
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final decodedData = jsonDecode(response.body);
          return CropResponse(
            success: true,
            message: decodedData['message'] ?? 'Cultivo eliminado exitosamente',
            data: null,
          );
        }
        return CropResponse(
          success: true,
          message: 'Cultivo eliminado exitosamente',
          data: null,
        );
      }

      // Manejo de errores
      final errorData = response.body.isNotEmpty
          ? json.decode(response.body)
          : {'message': 'Error al eliminar el cultivo'};

      return CropResponse(
        success: false,
        message: errorData['message'],
        data: null,
      );
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error deleting crop: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}

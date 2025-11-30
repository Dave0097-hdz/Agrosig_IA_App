import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../config/keys.dart';
import '../../../data/core/custom_http_client.dart';
import '../../../data/local_secure/secure_storage.dart';
import '../../models/user/user_model.dart';
import '../../response/response_default/response_default.dart';

class UserServices {
  final SecureStorageAgroSig _secureStorage = SecureStorageAgroSig();
  final http.Client _client;

  UserServices() : _client = CustomHttpClient.create();

  // ========== GET USER PROFILE ==========
  Future<User> getUserProfile() async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      print('Token: $token');
      print('RefreshToken: $refreshToken');

      if (token == null || refreshToken == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client.get(
        Uri.parse('${Environment.users}/profile/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Get Profile Status: ${response.statusCode}');
      print('Get Profile Headers: ${response.headers}');
      print('Get Profile Response: ${response.body}');

      // Verificar si hay nuevo token en los headers
      final newAccessToken = response.headers['x-new-access-token'];
      if (newAccessToken != null) {
        print('Nuevo token recibido: $newAccessToken');
        await _secureStorage.setAccessToken(newAccessToken);
      }

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          return User.fromJson(decodedData['data']);
        } else {
          throw Exception(decodedData['message'] ?? 'Error al obtener perfil');
        }
      } else if (response.statusCode == 401) {
        await _secureStorage.clearAllData();
        throw Exception('Sesión expirada, por favor inicie sesión nuevamente');
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error del servidor: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Get profile error: $e');
      rethrow;
    }
  }

  // ========== UPDATE USER PROFILE ==========
  Future<User> updateUserProfile({
    required String first_name,
    required String paternal_surname,
    required String maternal_surname,
    required String email,
  }) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client.patch(
        Uri.parse('${Environment.users}/profile/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
        body: jsonEncode({
          'first_name': first_name,
          'paternal_surname': paternal_surname,
          'maternal_surname': maternal_surname,
          'email': email,
        }),
      );

      final newAccessToken = response.headers['x-new-access-token'];
      if (newAccessToken != null) {
        await _secureStorage.setAccessToken(newAccessToken);
      }

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          return User.fromJson(decodedData['data']);
        } else {
          throw Exception(decodedData['message'] ?? 'Error al actualizar perfil');
        }
      } else if (response.statusCode == 401) {
        await _secureStorage.clearAllData();
        throw Exception('Sesión expirada');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al actualizar perfil');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Update profile error: $e');
      rethrow;
    }
  }

  // ========== UPDATE PROFILE IMAGE ==========
  Future<User> updateProfileImage(File imageFile) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('Usuario no autenticado');
      }

      // Crear la solicitud multipart
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('${Environment.users}/image/me'),
      );

      // Agregar headers de autorización
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['x-refresh-token'] = refreshToken;

      // Agregar archivo de imagen
      request.files.add(
        await http.MultipartFile.fromPath(
          'image_user',
          imageFile.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      print('Enviando imagen: ${imageFile.path}');

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      print('Respuesta del servidor: ${response.statusCode}');
      print('Body de respuesta: ${responseData.body}');

      // Verificar si hay nuevo token en los headers
      final newAccessToken = response.headers['x-new-access-token'];
      if (newAccessToken != null) {
        await _secureStorage.setAccessToken(newAccessToken);
      }

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(responseData.body);
        if (decodedData['success'] == true) {
          // La respuesta incluye la URL de la imagen
          return await getUserProfile();
        } else {
          throw Exception(decodedData['message'] ?? 'Error al actualizar imagen');
        }
      } else if (response.statusCode == 401) {
        await _secureStorage.clearAllData();
        throw Exception('Sesión expirada');
      } else {
        final errorData = jsonDecode(responseData.body);
        throw Exception(errorData['message'] ?? 'Error al actualizar imagen: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Update image error: $e');
      rethrow;
    }
  }

  // ========== UPDATE USER PASSWORD ==========
  Future<ResponseDefault> updateUserPassword({
    required String oldPassword,
    required String newPassword,
    required String repeatedPassword,
  }) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client.patch(
        Uri.parse('${Environment.users}/password/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'repeatedPassword': repeatedPassword,
        }),
      );

      print('Update Password Status: ${response.statusCode}');
      print('Update Password Response: ${response.body}');

      final newAccessToken = response.headers['x-new-access-token'];
      if (newAccessToken != null) {
        await _secureStorage.setAccessToken(newAccessToken);
      }

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          return ResponseDefault(
            resp: true,
            msg: decodedData['data']['message'] ?? 'Contraseña actualizada correctamente',
          );
        } else {
          throw Exception(decodedData['message'] ?? 'Error al actualizar contraseña');
        }
      } else if (response.statusCode == 401) {
        await _secureStorage.clearAllData();
        throw Exception('Sesión expirada');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al actualizar contraseña');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Update password error: $e');
      rethrow;
    }
  }

  // ========== DELETE USER ==========
  Future<ResponseDefault> deleteUser() async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();
      final userId = await _secureStorage.getUserId();

      if (token == null || refreshToken == null || userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client.delete(
        Uri.parse('${Environment.users}/delete-user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken
        },
      );

      print('Delete User Status: ${response.statusCode}');
      print('Delete User Response: ${response.body}');

      final newAccessToken = response.headers['x-new-access-token'];
      if (newAccessToken != null) {
        await _secureStorage.setAccessToken(newAccessToken);
      }

      if (response.statusCode == 204 || response.statusCode == 200) {
        await _secureStorage.clearAllData();
        return ResponseDefault(
          resp: true,
          msg: 'Usuario eliminado exitosamente',
        );
      } else if (response.statusCode == 401) {
        await _secureStorage.clearAllData();
        throw Exception('Sesión expirada');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para realizar esta acción');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al eliminar usuario');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Delete user error: $e');
      rethrow;
    }
  }

  // ========== GET IMAGE URL ==========
  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      print('Image path is null or empty');
      return '';
    }

    // Si ya es una URL completa
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Si es solo el nombre del archivo (como se almacena ahora)
    if (!imagePath.contains('/')) {
      final url = '${Environment.baseUrl}/uploads/profile/$imagePath';
      print('URL construida: $url');
      return url;
    }

    // Si incluye parte de la ruta pero no la base URL
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    final url = '${Environment.baseUrl}/$cleanPath';
    print('URL construida (con ruta): $url');
    return url;
  }

  void dispose() {
    _client.close();
  }
}

final userServices = UserServices();
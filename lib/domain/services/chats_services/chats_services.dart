import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../config/keys.dart';
import '../../../data/core/custom_http_client.dart';
import '../../../data/local_secure/secure_storage.dart';
import '../../response/response_chats/response_chats.dart';

class CommentServices {
  final SecureStorageAgroSig _secureStorage = SecureStorageAgroSig();
  final http.Client _client;

  CommentServices() : _client = CustomHttpClient.create();

  // ========== CREATE COMMENT ==========
  Future<CommentResponse> createComment(String message) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client.post(
        Uri.parse('${Environment.baseUrl}/comment/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
        body: jsonEncode({
          'message': message,
        }),
      );

      print('Create Comment Status: ${response.statusCode}');
      print('Create Comment Response: ${response.body}');

      // Verificar si hay nuevo token en los headers
      final newAccessToken = response.headers['x-new-access-token'];
      if (newAccessToken != null) {
        await _secureStorage.setAccessToken(newAccessToken);
      }

      if (response.statusCode == 201) {
        final decodedData = jsonDecode(response.body);
        return CommentResponse.fromJson(decodedData);
      } else if (response.statusCode == 401) {
        await _secureStorage.clearAllData();
        throw Exception('Sesión expirada, por favor inicie sesión nuevamente');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al crear comentario');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Create comment error: $e');
      rethrow;
    }
  }

  // ========== GET ALL COMMENTS ==========
  Future<CommentsListResponse> getAllComments() async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client.get(
        Uri.parse('${Environment.baseUrl}/comment/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Get Comments Status: ${response.statusCode}');
      print('Get Comments Response: ${response.body}');

      // Verificar si hay nuevo token en los headers
      final newAccessToken = response.headers['x-new-access-token'];
      if (newAccessToken != null) {
        await _secureStorage.setAccessToken(newAccessToken);
      }

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return CommentsListResponse.fromJson(decodedData);
      } else if (response.statusCode == 401) {
        await _secureStorage.clearAllData();
        throw Exception('Sesión expirada, por favor inicie sesión nuevamente');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al obtener comentarios');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Get comments error: $e');
      rethrow;
    }
  }

  // ========== UPDATE COMMENT ==========
  Future<CommentResponse> updateComment(int commentId, String message) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client.patch(
        Uri.parse('${Environment.baseUrl}/comment/update/$commentId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
        body: jsonEncode({
          'message': message,
        }),
      );

      print('Update Comment Status: ${response.statusCode}');
      print('Update Comment Response: ${response.body}');

      // Verificar si hay nuevo token en los headers
      final newAccessToken = response.headers['x-new-access-token'];
      if (newAccessToken != null) {
        await _secureStorage.setAccessToken(newAccessToken);
      }

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return CommentResponse.fromJson(decodedData);
      } else if (response.statusCode == 401) {
        await _secureStorage.clearAllData();
        throw Exception('Sesión expirada, por favor inicie sesión nuevamente');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al actualizar comentario');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Update comment error: $e');
      rethrow;
    }
  }

  // ========== DELETE COMMENT ==========
  Future<bool> deleteComment(int commentId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client.delete(
        Uri.parse('${Environment.baseUrl}/comment/delete/$commentId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Delete Comment Status: ${response.statusCode}');
      print('Delete Comment Response: ${response.body}');

      // Verificar si hay nuevo token en los headers
      final newAccessToken = response.headers['x-new-access-token'];
      if (newAccessToken != null) {
        await _secureStorage.setAccessToken(newAccessToken);
      }

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return decodedData['success'] == true;
      } else if (response.statusCode == 401) {
        await _secureStorage.clearAllData();
        throw Exception('Sesión expirada, por favor inicie sesión nuevamente');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al eliminar comentario');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Delete comment error: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}

final commentServices = CommentServices();
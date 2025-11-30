import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import '../../../config/keys.dart';
import '../../../data/core/custom_http_client.dart';
import '../../../data/local_secure/secure_storage.dart';
import '../../models/user/user_model.dart';
import '../../response/response_default/response_default.dart';
import '../../response/response_user/response_login.dart';
import '../notifications_services/firebase_messaging_service.dart';

class AuthServices {
  final SecureStorageAgroSig _secureStorage = SecureStorageAgroSig();
  final http.Client _client;

  AuthServices() : _client = CustomHttpClient.create();

  // ========== REGISTER ==========
  Future<ResponseDefault> registerUser(
    String firstName,
    String paternalSurname,
    String maternalSurname,
    String? imagePath,
    String email,
    String password,
  ) async {
    try {
      // Si no hay imagen, enviar como JSON normal
      if (imagePath == null) {
        final response = await _client.post(
          Uri.parse('${Environment.auth}/register'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'first_name': firstName,
            'paternal_surname': paternalSurname,
            'maternal_surname': maternalSurname,
            'email': email,
            'password': password,
          }),
        );

        print('Register Status: ${response.statusCode}');
        print('Register Response: ${response.body}');

        if (response.statusCode == 201) {
          final decodedData = jsonDecode(response.body);
          return ResponseDefault(
            resp: true,
            msg: decodedData['message'] ?? 'Usuario registrado exitosamente',
          );
        } else {
          final errorData = jsonDecode(response.body);
          return ResponseDefault(
            resp: false,
            msg: errorData['message'] ?? 'Error en el registro',
          );
        }
      } else {
        // Si hay imagen, usar multipart (como lo tienes actualmente)
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${Environment.auth}/register'),
        );

        request.fields['first_name'] = firstName;
        request.fields['paternal_surname'] = paternalSurname;
        request.fields['maternal_surname'] = maternalSurname;
        request.fields['email'] = email;
        request.fields['password'] = password;

        request.files.add(
          await http.MultipartFile.fromPath(
            'image_user',
            imagePath,
          ),
        );

        var response = await request.send();
        var responseData = await http.Response.fromStream(response);

        print('Register Status: ${response.statusCode}');
        print('Register Response: ${responseData.body}');

        if (response.statusCode == 201) {
          final decodedData = jsonDecode(responseData.body);
          return ResponseDefault(
            resp: true,
            msg: decodedData['message'] ?? 'Usuario registrado exitosamente',
          );
        } else {
          final errorData = jsonDecode(responseData.body);
          return ResponseDefault(
            resp: false,
            msg: errorData['message'] ?? 'Error en el registro',
          );
        }
      }
    } on SocketException {
      return ResponseDefault(
        resp: false,
        msg: 'Error de conexión: No hay internet',
      );
    } catch (e) {
      print('Register error: $e');
      return ResponseDefault(
        resp: false,
        msg: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  // ========== LOGIN ==========
  Future<ResponseLogin> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting login for: $email');

      final response = await _client.post(
        Uri.parse('${Environment.auth}/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login Status: ${response.statusCode}');
      print('Login Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData['success'] == true) {
          final responseLogin = ResponseLogin.fromJson(decodedData);

          await _secureStorage.persistUserData(
            responseLogin.token,
            responseLogin.refreshToken,
            responseLogin.user.user_id,
          );

          print('=== TOKENS SAVED SUCCESSFULLY ===');
          print('User ID: ${responseLogin.user.user_id}');
          print('Token: ${responseLogin.token}');
          print('Refresh Token: ${responseLogin.refreshToken}');

          // Verificar que se guardaron correctamente
          final savedToken = await _secureStorage.getAccessToken();
          final savedRefreshToken = await _secureStorage.getRefreshToken();
          final savedUserId = await _secureStorage.getUserId();

          return responseLogin;
        } else {
          throw Exception(decodedData['message'] ?? 'Error during login');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // ========== DECODE JWT TOKEN ==========
  Map<String, dynamic> _decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Token inválido');
      }

      final payload = parts[1];
      var normalized = base64Url.normalize(payload);
      var decoded = utf8.decode(base64Url.decode(normalized));

      return jsonDecode(decoded);
    } catch (e) {
      print('Error decoding token: $e');
      return {};
    }
  }

  // ========== REFRESH TOKEN ==========
  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      final userId = await _secureStorage.getUserId();

      if (refreshToken == null) return null;

      final response = await _client.post(
        Uri.parse('${Environment.users}/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final newAccessToken = decodedData['accessToken'];
        final newRefreshToken = decodedData['refreshToken'];

        if (userId != null && newAccessToken != null) {
          await _secureStorage.persistUserData(
            newAccessToken,
            newRefreshToken ?? refreshToken,
            userId,
          );
        }

        return newAccessToken;
      } else {
        await _secureStorage.clearAllData();
        return null;
      }
    } catch (e) {
      await _secureStorage.clearAllData();
      return null;
    }
  }

  // ========== VERIFY TOKEN VALIDITY ==========
  Future<bool> verifyTokenValidity() async {
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) return false;

      // Decodificar el token para verificar expiración
      final tokenData = _decodeToken(token);
      final exp = tokenData['exp'] * 1000; // Convertir a milliseconds
      final now = DateTime.now().millisecondsSinceEpoch;

      // Si el token expira en menos de 5 minutos, considerarlo inválido
      if (exp - now < 5 * 60 * 1000) {
        // Intentar refresh
        final newToken = await refreshAccessToken();
        return newToken != null;
      }

      return true;
    } catch (e) {
      print('Token verification error: $e');
      return false;
    }
  }

  // ========== LOGOUT ==========
  Future<ResponseDefault> logout() async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      // Verificar que los tokens NO sean nulos
      if (token == null || refreshToken == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client.post(
        Uri.parse('${Environment.auth}/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken, 
        },
      );

      if (response.statusCode == 200) {
        return ResponseDefault.fromJson(jsonDecode(response.body));
      } else {
        // Si el logout del backend falla, igual limpiamos localmente
        throw Exception('Error en logout del servidor');
      }
    } catch (e) {
      print('Logout error: $e');
      // En caso de error, igual limpiamos localmente
      await FirebaseMessagingService().unregisterTokenOnLogout();
      await SecureStorageAgroSig().clearAllData();
      return ResponseDefault(resp: true, msg: 'Logout exitoso');
    }
  }

  void dispose() {
    _client.close();
  }
}

final authServices = AuthServices();

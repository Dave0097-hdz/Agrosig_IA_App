import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../config/keys.dart';
import '../../../data/core/custom_http_client.dart';
import '../../../data/local_secure/secure_storage.dart';
import '../../models/activitys/activitys_model.dart';
import '../../models/inputs/inputs_model.dart';
import '../../response/response_activitys/response_activitys.dart';

class ActivityService {
  final SecureStorageAgroSig _secureStorage = SecureStorageAgroSig();
  final http.Client _client;

  ActivityService() : _client = CustomHttpClient.create();

  // Registrar una nueva actividad con insumos
  Future<ActivityResponse> registerActivity(
      int cropId,
      Activity activity,
      List<InputUsed> inputs,
      ) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final requestBody = {
        'activityType': activity.activityType,
        'date': activity.date.toIso8601String().split('T')[0],
        'description': activity.description,
        'inputs': inputs.map((input) => input.toCreateJson()).toList(),
      };

      print('Request Body: ${jsonEncode(requestBody)}');

      final response = await _client.post(
        Uri.parse('${Environment.activity}/register/$cropId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
        body: jsonEncode(requestBody),
      );

      print('Register Activity Status: ${response.statusCode}');
      print('Register Activity Response: ${response.body}');

      if (response.statusCode == 201) {
        final decodedData = jsonDecode(response.body);
        return ActivityResponse.fromJson(decodedData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al registrar la actividad');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error registering activity: $error');
      throw Exception('Error registrando actividad: ${error.toString()}');
    }
  }

  // Obtener todas las actividades del usuario
  Future<List<Activity>> getAllActivities() async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await _client.get(
        Uri.parse('${Environment.activity}/all'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Get Activities Status: ${response.statusCode}');
      print('Get Activities Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> activitiesJson = responseData['data'] ?? [];

          final List<Activity> activities = activitiesJson.map((activityJson) {
            try {
              return Activity.fromJson(activityJson);
            } catch (e) {
              print('Error parseando actividad: $e');
              print('Datos problemáticos: $activityJson');
              return null;
            }
          }).whereType<Activity>().toList();

          print('Total de actividades obtenidas: ${activities.length}');
          return activities;
        } else {
          throw Exception(responseData['message'] ?? 'Error al obtener las actividades.');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Error al obtener actividades. Código HTTP: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet disponible.');
    } on http.ClientException {
      throw Exception('Error de conexión: No se pudo conectar al servidor.');
    } catch (error) {
      print('Error general al obtener todas las actividades: $error');
      throw Exception('Error obteniendo todas las actividades: ${error.toString()}');
    }
  }

  // Obtener actividades por cultivo
  Future<List<Activity>> getActivitiesByCrop(int cropId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await _client.get(
        Uri.parse('${Environment.activity}/crop/$cropId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Get Activities Status: ${response.statusCode}');
      print('Get Activities Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> activitiesJson = responseData['data'] ?? [];

          // Validar que cada actividad se pueda parsear correctamente
          final List<Activity> activities = [];
          for (final json in activitiesJson) {
            try {
              final activity = Activity.fromJson(json);
              activities.add(activity);
            } catch (e) {
              print('Error parsing activity: $e');
              print('Problematic activity data: $json');
              // Continuar con las demás actividades
            }
          }

          return activities;
        } else {
          throw Exception(responseData['message'] ?? 'Error al obtener actividades');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al obtener las actividades. Código: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet disponible');
    } on http.ClientException {
      throw Exception('Error de conexión: No se pudo conectar al servidor');
    } catch (error) {
      print('Error getting activities: $error');
      throw Exception('Error obteniendo actividades: ${error.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}
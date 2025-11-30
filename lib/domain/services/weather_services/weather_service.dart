import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../config/keys.dart';
import '../../../data/core/custom_http_client.dart';
import '../../../data/local_secure/secure_storage.dart';
import '../../response/response_weather/response_daily_forecast.dart';
import '../../response/response_weather/response_weather.dart';

class ClimateServices {
  final SecureStorageAgroSig _secureStorage = SecureStorageAgroSig();
  final http.Client _client;

  ClimateServices() : _client = CustomHttpClient.create();

  // ========== GET CURRENT WEATHER ==========
  Future<ClimateResponse> getWeather(int plotId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();
      final userId = await _secureStorage.getUserId();

      if (token == null || refreshToken == null || userId == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse('${Environment.weather}/get-weather/$plotId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Weather Status: ${response.statusCode}');
      print('Weather Response: ${response.body}');

      if (response.statusCode == 200) {
        return ClimateResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error fetching weather');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Get weather error: $e');
      throw Exception('Error fetching weather: ${e.toString()}');
    }
  }

  // ========== GET WEEKLY WEATHER ==========
  Future<WeeklyForecastResponse> getWeeklyWeather(int plotId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();
      final userId = await _secureStorage.getUserId();

      if (token == null || refreshToken == null || userId == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse('${Environment.weather}/get-weekly/$plotId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Weekly Weather Status: ${response.statusCode}');
      print('Weekly Weather Response: ${response.body}');

      if (response.statusCode == 200) {
        return WeeklyForecastResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error fetching weekly weather');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Get weekly weather error: $e');
      throw Exception('Error fetching weekly weather: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}

final climateServices = ClimateServices();
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageAgroSig {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _fcmTokenKey  = 'fmc_token';

  Future<void> persistUserData(String accessToken, String refreshToken, int userId) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    await _storage.write(key: 'user_id', value: userId.toString());

    print('SecureStorage - Data saved:');
    print('  User ID: $userId');
    print('  Access Token: ${accessToken.substring(0, 20)}...');
    print('  Refresh Token: ${refreshToken.substring(0, 20)}...');
  }

  // Guardar access token individual
  Future<void> setAccessToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
    print('SecureStorage - Access token updated');
  }

  // Guardar refresh token individual
  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
    print('SecureStorage - Refresh token updated');
  }

  // Obtener access token
  Future<String?> getAccessToken() async {
    final token = await _storage.read(key: 'access_token');
    print('SecureStorage - Get access token: ${token != null ? "EXISTS" : "NULL"}');
    return token;
  }

  // Obtener refresh token
  Future<String?> getRefreshToken() async {
    final token = await _storage.read(key: 'refresh_token');
    print('SecureStorage - Get refresh token: ${token != null ? "EXISTS" : "NULL"}');
    return token;
  }

  // Obtener user ID
  Future<int?> getUserId() async {
    final idString = await _storage.read(key: 'user_id');
    final userId = idString != null ? int.tryParse(idString) : null;
    print('SecureStorage - Get user ID: $userId');
    return userId;
  }

  // Verificar si el usuario está logueado
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    print('SecureStorage - Is logged in: $isLoggedIn');
    return isLoggedIn;
  }

  Future<void> setPolicyAccepted(bool accepted) async {
    await _storage.write(key: 'policy_accepted', value: accepted.toString());
    print('SecureStorage - Policy accepted: $accepted');
  }

  Future<bool> isPolicyAccepted() async {
    try {
      final accepted = await _storage.read(key: 'policy_accepted');
      print('SecureStorage - Reading policy_accepted: $accepted');
      return accepted == 'true';
    } catch (e) {
      print('Error reading policy acceptance: $e');
      return false;
    }
  }

  Future<void> setFCMToken(String token) async {
    await _storage.write(key: _fcmTokenKey, value: token);
  }

  Future<String?> getFCMToken() async {
    return await _storage.read(key: _fcmTokenKey);
  }

  Future<void> removeFCMToken() async {
    await _storage.delete(key: _fcmTokenKey);
  }

  // Limpiar todos los datos (logout)
  Future<void> clearAllData() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_id');
    print('SecureStorage - All data cleared');
  }
}

final secureStorage = SecureStorageAgroSig();
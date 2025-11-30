class Environment {
  // Firebase
  static const String firebaseApiKey = 'YOUR_FIREBASE_API_KEY';
  static const String firebaseProjectId = 'YOUR_FIREBASE_PROJECT_ID';
  static const String firebaseMessagingSenderId = 'YOUR_SENDER_ID';
  static const String firebaseAppId = 'YOUR_FIREBASE_APP_ID';

  // Google Maps
  static const String googleMapsKey = 'AIzaSyAl5TtsfNcQL0iLuG_STqqYcW5zgEV19no';

  // Endpoints del Backend
  static const String baseUrl = 'https://api-agrosig-backend.onrender.com';

  static const String auth = '$baseUrl/auth';
  static const String users = '$baseUrl/users';
  static const String plots = '$baseUrl/plots';
  static const String weather = '$baseUrl/weather';
  static const String crop = '$baseUrl/crop';
  static const String activity = '$baseUrl/activity';
  static const String report = '$baseUrl/report';
  static const String production = '$baseUrl/production';
  static const String fcm = '$baseUrl/fcm';
  static const String notifications = '$baseUrl/notifications';

  // Otras APIs
  static const String weatherApiKey = '8a308194915c5e323ce60f1f4d9f2508';
  static const googleApi = 'AIzaSyA7-gQBW41OcosCQswZJrfFAGuUXFXMrdw';

  static String vercelUrl = 'https://soluciones-agrotech.vercel.app';
}
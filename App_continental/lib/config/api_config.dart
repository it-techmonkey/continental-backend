// API Configuration
class ApiConfig {
  // Base URL - passed via --dart-define at build time, with fallback
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://continental-backend-ajnc.onrender.com/api',
  );

  // MapTiler key for dashboard tiles and geocoding. Keep empty to use fallback tiles.
  static const String mapTilerApiKey = String.fromEnvironment(
    'MAPTILER_API_KEY',
    defaultValue: '',
  );

  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String occupantRecordsMaps = '/occupant-records/maps';

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String? token) {
    final headers = Map<String, String>.from(defaultHeaders);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}


// API Configuration
class ApiConfig {
  // Base URL - Change this to your production URL
  // For iOS simulator, use localhost
  // For Android emulator, use 10.0.2.2R
  // For physical device, use your Mac's IP address
  // static const String baseUrl = 'http://192.168.1.2:3500/api'; // For your local device
  // static const String baseUrl = 'http://localhost:3500/api'; // For simulator
  static const String baseUrl = 'https://continental-backend-ajnc.onrender.com/api'; // For production/sharing
  // Google Maps/Places API key (used for autocomplete/location selection)
  static const String googleMapsApiKey = 'AIzaSyAg1QBIXXbGLiNO26G6GvHQwmdJJ0usUV0';
  // API EndpointsR
  
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String occupantRecordsMaps = '/occupant-records/maps';
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Get authorization header with token
  static Map<String, String> getAuthHeaders(String? token) {
    final headers = Map<String, String>.from(defaultHeaders);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}


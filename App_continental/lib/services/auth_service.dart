import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../storage/token_storage.dart';

// API Response Models
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJson) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJson != null ? fromJson(json['data']) : null,
      statusCode: 200,
    );
  }
}

class LoginResponse {
  final User? user;
  final String? token;

  LoginResponse({this.user, this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      token: json['token'],
    );
  }
}

class User {
  final int id;
  final String email;
  final String name;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : (json['id'] is String ? int.tryParse(json['id']) ?? 0 : 0),
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// Auth Service
class AuthService {
  final Dio _dio = Dio();
  final TokenStorage _tokenStorage = TokenStorage();

  AuthService() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.headers = ApiConfig.defaultHeaders;
  }

  // Login
  Future<ApiResponse<LoginResponse>> login(String email, String password) async {
    try {
      print('🔐 [LOGIN] Starting login for: $email');
      
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        print('❌ [LOGIN] Email or password empty');
        return ApiResponse(
          success: false,
          message: 'Email and password are required',
          data: null,
        );
      }

      final request = LoginRequest(email: email, password: password);
      print('📡 [LOGIN] Sending request to: ${ApiConfig.baseUrl}${ApiConfig.login}');
      print('📋 [LOGIN] Request data: ${request.toJson()}');
      
      final response = await _dio.post(
        ApiConfig.login,
        data: request.toJson(),
      );

      print('✅ [LOGIN] Response status: ${response.statusCode}');
      print('📦 [LOGIN] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => LoginResponse.fromJson(data),
        );

        // Save token if login successful
        if (apiResponse.success && apiResponse.data?.token != null) {
          print('💾 [LOGIN] Saving token: ${apiResponse.data!.token!.substring(0, 20)}...');
          await _tokenStorage.saveToken(apiResponse.data!.token!);
          await _tokenStorage.saveUser(apiResponse.data!.user);
          print('✅ [LOGIN] Token saved successfully!');
          print('👤 [LOGIN] User: ${apiResponse.data!.user?.name} (${apiResponse.data!.user?.email})');
        }

        return apiResponse;
      } else {
        print('❌ [LOGIN] Failed with status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: 'Login failed',
          data: null,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [LOGIN] DioException: ${e.message}');
      print('📋 [LOGIN] Error details: ${e.response?.data}');
      return _handleError(e);
    } catch (e) {
      print('❌ [LOGIN] Unexpected error: $e');
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  // Get current token
  Future<String?> getToken() async {
    final token = await _tokenStorage.getToken();
    if (token != null) {
      print('🔑 [AUTH] Retrieved token: ${token.substring(0, 20)}...');
    } else {
      print('⚠️ [AUTH] No token found');
    }
    return token;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    final user = await _tokenStorage.getUser();
    if (user != null) {
      print('👤 [AUTH] Retrieved user: ${user.name} (${user.email})');
    } else {
      print('⚠️ [AUTH] No user found');
    }
    return user;
  }

  // Logout
  Future<void> logout() async {
    print('🚪 [LOGOUT] Clearing token and user data...');
    await _tokenStorage.clearToken();
    await _tokenStorage.clearUser();
    print('✅ [LOGOUT] Logout complete');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.getToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    print('🔍 [AUTH] Is logged in: $isLoggedIn');
    return isLoggedIn;
  }

  // Error handler
  ApiResponse<T> _handleError<T>(DioException error) {
    if (error.response != null) {
      // Server responded with error
      final statusCode = error.response!.statusCode;
      final message = error.response!.data?['message'] ?? 'Server error occurred';
      
      return ApiResponse<T>(
        success: false,
        message: message,
        data: null,
        statusCode: statusCode,
      );
    } else if (error.type == DioExceptionType.connectionTimeout ||
               error.type == DioExceptionType.receiveTimeout) {
      return ApiResponse<T>(
        success: false,
        message: 'Connection timeout. Please check your internet connection.',
        data: null,
      );
    } else if (error.type == DioExceptionType.connectionError) {
      return ApiResponse<T>(
        success: false,
        message: 'Unable to connect to server. Please check your internet connection.',
        data: null,
      );
    } else {
      return ApiResponse<T>(
        success: false,
        message: error.message ?? 'An error occurred',
        data: null,
      );
    }
  }
}


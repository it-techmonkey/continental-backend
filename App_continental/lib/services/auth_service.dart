import 'package:flutter/foundation.dart';
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
    // Timeouts — the backend (Render free tier) cold-starts and can take ~30s
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.sendTimeout = const Duration(seconds: 30);
  }

  /// Pre-warm the backend so cold-start delay occurs during splash,
  /// not during login. Fire-and-forget — failures are silently ignored.
  static Future<void> warmUpServer() async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 90);
      dio.options.receiveTimeout = const Duration(seconds: 90);
      final healthUrl = ApiConfig.baseUrl.replaceAll('/api', '/health');
      debugPrint('🔥 [WARMUP] Pinging server: $healthUrl');
      await dio.get(healthUrl);
      debugPrint('🔥 [WARMUP] Server is awake');
    } catch (e) {
      debugPrint('⚠️ [WARMUP] Server warmup failed (may still be starting): $e');
    }
  }

  // Login
  Future<ApiResponse<LoginResponse>> login(String email, String password) async {
    try {
      debugPrint('🔐 [LOGIN] Starting login for: $email');
      
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        debugPrint('❌ [LOGIN] Email or password empty');
        return ApiResponse(
          success: false,
          message: 'Email and password are required',
          data: null,
        );
      }

      final request = LoginRequest(email: email, password: password);
      debugPrint('📡 [LOGIN] Sending request to: ${ApiConfig.baseUrl}${ApiConfig.login}');
      debugPrint('📋 [LOGIN] Request data: ${request.toJson()}');
      
      final response = await _dio.post(
        ApiConfig.login,
        data: request.toJson(),
      );

      debugPrint('✅ [LOGIN] Response status: ${response.statusCode}');
      debugPrint('📦 [LOGIN] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => LoginResponse.fromJson(data),
        );

        // Save token if login successful
        if (apiResponse.success && apiResponse.data?.token != null) {
          debugPrint('💾 [LOGIN] Saving token: ${apiResponse.data!.token!.substring(0, 20)}...');
          await _tokenStorage.saveToken(apiResponse.data!.token!);
          await _tokenStorage.saveUser(apiResponse.data!.user);
          debugPrint('✅ [LOGIN] Token saved successfully!');
          debugPrint('👤 [LOGIN] User: ${apiResponse.data!.user?.name} (${apiResponse.data!.user?.email})');
        }

        return apiResponse;
      } else {
        debugPrint('❌ [LOGIN] Failed with status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: 'Login failed',
          data: null,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ [LOGIN] DioException: ${e.message}');
      debugPrint('📋 [LOGIN] Error details: ${e.response?.data}');
      return _handleError(e);
    } catch (e) {
      debugPrint('❌ [LOGIN] Unexpected error: $e');
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
      debugPrint('🔑 [AUTH] Retrieved token: ${token.substring(0, 20)}...');
    } else {
      debugPrint('⚠️ [AUTH] No token found');
    }
    return token;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    final user = await _tokenStorage.getUser();
    if (user != null) {
      debugPrint('👤 [AUTH] Retrieved user: ${user.name} (${user.email})');
    } else {
      debugPrint('⚠️ [AUTH] No user found');
    }
    return user;
  }

  // Logout
  Future<void> logout() async {
    debugPrint('🚪 [LOGOUT] Clearing token and user data...');
    await _tokenStorage.clearToken();
    await _tokenStorage.clearUser();
    debugPrint('✅ [LOGOUT] Logout complete');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.getToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    debugPrint('🔍 [AUTH] Is logged in: $isLoggedIn');
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


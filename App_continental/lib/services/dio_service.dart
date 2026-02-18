import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/api_config.dart';
import '../storage/token_storage.dart';
import '../providers/auth_state_provider.dart';
import '../utils/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Global router reference and container for navigation from interceptors
GoRouter? _globalRouter;
ProviderContainer? _globalContainer;

// Set router reference (called from main.dart)
void setRouterReference(GoRouter router, ProviderContainer container) {
  _globalRouter = router;
  _globalContainer = container;
}

// Dio Service Provider
final dioServiceProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    headers: ApiConfig.defaultHeaders,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  final tokenStorage = TokenStorage();

  // Add interceptor for authentication
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add token to requests
        final token = await tokenStorage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized errors
        if (error.response?.statusCode == 401) {
          print('🔒 [DIO] 401 Unauthorized - Token expired or invalid');
          
          // Clear token and user data
          await tokenStorage.clearAll();
          
          // Update auth state and navigate to login
          try {
            // Update auth state using global container
            if (_globalContainer != null) {
              final authNotifier = _globalContainer!.read(authStateProvider.notifier);
              await authNotifier.logout();
            }
            
            // Navigate to login using global router
            if (_globalRouter != null) {
              _globalRouter!.go('/login');
            }
          } catch (e) {
            print('⚠️ [DIO] Error handling logout: $e');
            // Try to navigate anyway if router is available
            if (_globalRouter != null) {
              try {
                _globalRouter!.go('/login');
              } catch (navError) {
                print('⚠️ [DIO] Navigation error: $navError');
              }
            }
          }
          
          // Return error response
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: DioExceptionType.badResponse,
              error: 'Session expired. Please login again.',
            ),
          );
        }
        
        // For other errors, pass through
        return handler.next(error);
      },
    ),
  );

  return dio;
});


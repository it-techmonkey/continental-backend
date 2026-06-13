import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/api_config.dart';
import '../storage/token_storage.dart';
import '../providers/auth_state_provider.dart';
import 'occupants_service.dart';
import 'payments_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Global router reference and container for navigation from interceptors
GoRouter? _globalRouter;
ProviderContainer? _globalContainer;

// Guard to prevent multiple simultaneous 401 logout triggers
bool _isHandling401 = false;

// During app startup, the server (Render free tier) may cold-start and briefly return 401.
// We suppress logout during this window so users aren't kicked out immediately.
bool _isAppInitializing = true;

// Called by auth_state_provider once startup check is done
void markAppInitialized() {
  _isAppInitializing = false;
}

// Set router reference (called from main.dart)
void setRouterReference(GoRouter router, ProviderContainer container) {
  _globalRouter = router;
  _globalContainer = container;
  _isHandling401 = false; // reset on each new session
  // Note: _isAppInitializing is intentionally NOT reset here.
  // It starts as true at declaration and is cleared by markAppInitialized()
  // after the auth check completes. Resetting it here on every rebuild
  // would permanently suppress legitimate 401 logouts.
}

// Dio Service Provider
final dioServiceProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      headers: ApiConfig.defaultHeaders,
      connectTimeout: const Duration(seconds: 90),
      receiveTimeout: const Duration(seconds: 90),
      sendTimeout: const Duration(seconds: 60),
    ),
  );

  final tokenStorage = TokenStorage();

  // Retry interceptor for Render cold-starts (connection errors / timeouts)
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
        // Retry once on connection error or timeout (Render cold-start)
        final isColdStartError =
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError;
        final retryKey = '${error.requestOptions.uri}_retried';
        final alreadyRetried = error.requestOptions.extra[retryKey] == true;

        if (isColdStartError && !alreadyRetried) {
          debugPrint(
            '🔄 [DIO] Retrying request after cold-start error: ${error.requestOptions.path}',
          );
          error.requestOptions.extra[retryKey] = true;

          // Wait 3 seconds for server to wake up, then retry
          await Future.delayed(const Duration(seconds: 3));
          try {
            final response = await dio.fetch(error.requestOptions);
            return handler.resolve(response);
            // ignore: avoid_catches_without_on_clauses
          } catch (_) {
            // If retry also fails, fall through to normal error handling
          }
        }

        // Handle 401 Unauthorized errors — but only once at a time,
        // and never during the initial cold-start loading window.
        if (error.response?.statusCode == 401 &&
            !_isHandling401 &&
            !_isAppInitializing) {
          _isHandling401 = true;
          debugPrint('🔒 [DIO] 401 Unauthorized - Token expired or invalid');

          // Clear token and user data
          await tokenStorage.clearAll();

          // Update auth state and navigate to login
          try {
            if (_globalContainer != null) {
              final authNotifier = _globalContainer!.read(
                authStateProvider.notifier,
              );
              await authNotifier.logout();
            }

            if (_globalRouter != null) {
              _globalRouter!.go('/login');
            }
          } catch (e) {
            debugPrint('⚠️ [DIO] Error handling logout: $e');
            if (_globalRouter != null) {
              try {
                _globalRouter!.go('/login');
              } catch (navError) {
                debugPrint('⚠️ [DIO] Navigation error: $navError');
              }
            }
          } finally {
            // Reset the flag after a short delay so future 401s can still trigger logout
            Future.delayed(
              const Duration(seconds: 3),
              () => _isHandling401 = false,
            );
          }

          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: DioExceptionType.badResponse,
              error: 'Session expired. Please login again.',
            ),
          );
        }

        // For other errors (or if already handling a 401), pass through
        return handler.next(error);
      },
    ),
  );

  return dio;
});

// Service providers that use the shared Dio (with auth interceptor + retry)
final paymentsServiceProvider = Provider<PaymentsService>((ref) {
  final dio = ref.read(dioServiceProvider);
  return PaymentsService(dio);
});

final occupantsServiceProvider = Provider<OccupantsService>((ref) {
  final dio = ref.read(dioServiceProvider);
  return OccupantsService(dio);
});

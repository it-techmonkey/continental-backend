import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../storage/token_storage.dart';

// Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

// Auth State Provider
final authStateProvider = NotifierProvider<AuthStateNotifier, AuthState>(() {
  return AuthStateNotifier();
});

// Auth State
class AuthState {
  final bool isAuthenticated;
  final User? user;
  final String? token;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.token,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    String? token,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Auth State Notifier
class AuthStateNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Initialize auth state
    final initialState = AuthState(isLoading: true);
    // Check auth status after initialization
    Future.microtask(() => _checkAuthStatus());
    return initialState;
  }

  AuthService get _authService => ref.read(authServiceProvider);

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      User? user;
      String? token;

      if (isLoggedIn) {
        token = await _authService.getToken();
        user = await _authService.getCurrentUser();
      }

      state = state.copyWith(
        isAuthenticated: isLoggedIn,
        user: user,
        token: token,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        errorMessage: 'Error checking auth status',
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.login(email, password);

      if (response.success && response.data != null) {
        state = state.copyWith(
          isAuthenticated: true,
          user: response.data!.user,
          token: response.data!.token,
          isLoading: false,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          errorMessage: response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        errorMessage: 'Login failed: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        token: null,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Logout failed: ${e.toString()}',
      );
    }
  }

  // Get current token (for API calls)
  String? getCurrentToken() {
    return state.token;
  }

  // Get current user
  User? getCurrentUser() {
    return state.user;
  }
}


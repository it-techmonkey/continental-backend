// lib/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../storage/token_storage.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;
  Timer? _safetyTimer;
  ProviderSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();

    // Fire-and-forget: wake up the backend during splash
    // so Render cold-start completes before user reaches login
    AuthService.warmUpServer();

    // Safety net: if auth takes more than 5 seconds for any reason,
    // force navigate so the app never gets permanently stuck.
    _safetyTimer = Timer(const Duration(seconds: 5), () {
      _navigate(ref.read(authStateProvider));
    });

    // Subscribe to auth state changes once (not on every rebuild).
    // The moment isLoading flips to false, _navigate is called.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authSubscription = ref.listenManual<AuthState>(authStateProvider, (
        previous,
        next,
      ) {
        if (!next.isLoading) {
          _navigate(next);
        }
      });

      // If auth is already resolved by the time the widget builds, navigate immediately.
      final authState = ref.read(authStateProvider);
      if (!authState.isLoading) {
        _navigate(authState);
      }
    });
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _authSubscription?.close();
    super.dispose();
  }

  Future<void> _navigate(AuthState authState) async {
    // Guard: only navigate once, and only if the widget is still mounted.
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    _safetyTimer?.cancel();
    _authSubscription?.close();

    // Remove the native splash right before we navigate away.
    FlutterNativeSplash.remove();

    if (authState.isAuthenticated) {
      context.goNamed('bottomnav');
    } else {
      final tokenStorage = TokenStorage();
      final onboardingCompleted = await tokenStorage.isOnboardingCompleted();
      if (!mounted) return;
      if (onboardingCompleted) {
        context.goNamed('login');
      } else {
        context.goNamed('onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = ref.watch(languageProvider);
    final translate = (String key) =>
        LanguageService.translate(key, languageCode);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = MediaQuery.of(context).size;
                    final isTablet = size.shortestSide >= 600;
                    final logoWidth = isTablet
                        ? size.width * 0.35
                        : size.width * 0.45;
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: logoWidth.clamp(120.0, 220.0),
                        maxHeight: size.height * 0.25,
                      ),
                      child: Image.asset(
                        'assets/images/splash.png',
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Center(
                  child: Text(
                    translate('A Product By Torodo Group'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

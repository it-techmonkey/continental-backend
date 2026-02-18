// lib/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/language_provider.dart';
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

  @override
  void initState() {
    super.initState();

    // Safety net: if auth takes more than 5 seconds for any reason,
    // force navigate to login so the app never gets permanently stuck.
    _safetyTimer = Timer(const Duration(seconds: 5), () {
      _navigate(ref.read(authStateProvider));
    });

    // If auth is already done by the time the widget builds, navigate immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authStateProvider);
      if (!authState.isLoading) {
        _navigate(authState);
      }
    });
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    super.dispose();
  }

  Future<void> _navigate(AuthState authState) async {
    // Guard: only navigate once, and only if the widget is still mounted.
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    _safetyTimer?.cancel();

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
    final translate = (String key) => LanguageService.translate(key, languageCode);

    // Listen to auth state changes. The moment isLoading flips to false,
    // _navigate is called — no blind delays needed.
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (!next.isLoading) {
        _navigate(next);
      }
    });

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
                child: Image.asset(
                  'assets/images/splash.png',
                  height: 400,
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
                      color: Colors.white.withOpacity(0.7),
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
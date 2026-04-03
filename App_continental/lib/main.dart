import 'package:continental/utils/app_routes.dart';
import 'package:continental/services/dio_service.dart';
import 'package:continental/services/language_service.dart';
import 'package:continental/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Load translations
  await LanguageService.loadTranslations();

  // DevicePreview disabled - no preview bar shown
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize Dio service to set up interceptors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dioServiceProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    // Watch language provider to rebuild app when language changes
    ref.watch(languageProvider);
    
    // Store router and container reference for Dio interceptor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final container = ProviderScope.containerOf(context);
      setRouterReference(router, container);
    });
    
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Continental',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
    );
  }
}

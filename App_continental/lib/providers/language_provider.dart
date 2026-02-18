import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/language_service.dart';

class LanguageNotifier extends Notifier<String> {
  @override
  String build() {
    // Initialize with default language, then load saved preference
    Future.microtask(() => _loadLanguage());
    return 'en';
  }
  
  Future<void> _loadLanguage() async {
    final language = await LanguageService.getLanguage();
    state = language;
  }
  
  Future<void> setLanguage(String languageCode) async {
    if (state == languageCode) return; // No change needed
    await LanguageService.setLanguage(languageCode);
    // Update state to trigger rebuilds - use state = to notify listeners
    state = languageCode;
    // Force a small delay to ensure state propagation
    await Future.delayed(const Duration(milliseconds: 50));
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, String>(() {
  return LanguageNotifier();
});

// Helper function to get translated text
String translate(String key, String languageCode) {
  return LanguageService.translate(key, languageCode);
}


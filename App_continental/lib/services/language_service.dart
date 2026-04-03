import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'app_language';
  static const String _translationsPath = 'assets/data/translations.json';
  static Map<String, dynamic>? _translations;
  static bool _isLoading = false;
  static Completer<void>? _loadCompleter;
  
  static Future<void> loadTranslations() async {
    // If already loaded, return immediately
    if (_translations != null) {
      return;
    }
    
    // If currently loading, wait for the existing load to complete
    if (_isLoading && _loadCompleter != null) {
      return _loadCompleter!.future;
    }
    
    // Start loading
    _isLoading = true;
    _loadCompleter = Completer<void>();
    
    try {
      debugPrint('🔄 Loading translations from: $_translationsPath');
      final String jsonString = await rootBundle.loadString(_translationsPath);
      _translations = json.decode(jsonString) as Map<String, dynamic>;
      debugPrint('✅ Translations loaded successfully. Keys: ${_translations!.length}');
      _loadCompleter!.complete();
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading translations: $e');
      debugPrint('Stack trace: $stackTrace');
      _translations = {};
      _loadCompleter!.completeError(e);
    } finally {
      _isLoading = false;
    }
  }
  
  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }
  
  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }
  
  static String translate(String key, String languageCode) {
    // Ensure translations are loaded (synchronous check after async load in main)
    if (_translations == null || _translations!.isEmpty) {
      // If translations aren't loaded yet, return key as fallback
      // This should only happen during initial app load
      return key;
    }
    
    final translation = _translations![key];
    if (translation is Map<String, dynamic>) {
      final result = translation[languageCode] ?? translation['en'] ?? key;
      return result;
    }
    
    // Key not found in translations
    return key;
  }
  
  static Future<String> translateAsync(String key) async {
    await loadTranslations();
    final languageCode = await getLanguage();
    return translate(key, languageCode);
  }
}


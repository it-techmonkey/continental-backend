import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

// Token Storage using SharedPreferences
class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  // Save token
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  // Get token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Clear token
  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      print('Error clearing token: $e');
    }
  }

  // Save user
  Future<void> saveUser(User? user) async {
    try {
      if (user == null) {
        await clearUser();
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userKey, userJson);
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  // Get user
  Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson == null || userJson.isEmpty) {
        return null;
      }
      
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Clear user
  Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      print('Error clearing user: $e');
    }
  }

  // Clear all auth data
  Future<void> clearAll() async {
    await clearToken();
    await clearUser();
  }

  // Mark onboarding as completed
  Future<void> markOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompletedKey, true);
    } catch (e) {
      print('Error marking onboarding completed: $e');
    }
  }

  // Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompletedKey) ?? false;
    } catch (e) {
      print('Error checking onboarding status: $e');
      return false;
    }
  }
}


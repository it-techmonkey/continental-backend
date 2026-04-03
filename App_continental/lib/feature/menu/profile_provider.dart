// lib/profile_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:dio/dio.dart';
import '../../services/dio_service.dart';

// --- 1. Data Model ---
@immutable
class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String imageUrl;

  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.imageUrl,
  });

  // copyWith method to easily update the model
  UserProfile copyWith({String? name, String? email, String? phone, String? imageUrl}) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

// --- 2. Repository ---
class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<UserProfile> fetchUserProfile() async {
    debugPrint("Fetching user profile...");
    try {
      // Token is automatically added by Dio interceptor
      final response = await _dio.get('/auth/profile');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        debugPrint('📦 [PROFILE] Response data: $data');
        return UserProfile.fromJson({
          'name': data['name'] ?? '',
          'email': data['email'] ?? '',
          'phone': data['phone'] ?? '',
          'imageUrl': data['profileImage'] ?? 'https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=774&q=80',
        });
      }
      throw Exception('Failed to fetch profile');
    } catch (e) {
      debugPrint('❌ [PROFILE] Error fetching profile: $e');
      rethrow;
    }
  }

  Future<bool> saveUserProfile(UserProfile profile) async {
    debugPrint("Saving user profile for ${profile.name}...");
    try {
      // Token is automatically added by Dio interceptor
      final response = await _dio.put(
        '/auth/profile',
        data: {
          'name': profile.name,
          'phone': profile.phone,
          'profileImage': profile.imageUrl,
        },
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint("Profile saved successfully!");
        return true;
      }
      throw Exception('Failed to save profile');
    } catch (e) {
      debugPrint('❌ [PROFILE] Error saving profile: $e');
      rethrow;
    }
  }
}

// --- 3. State Notifier ---
class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.fetchUserProfile();
      state = AsyncValue.data(profile);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> saveProfile(UserProfile updatedProfile) async {
    // The current state already holds the previous data. We don't need to do anything
    // special here. Riverpod automatically sets the `isRefreshing` flag on the state.
    try {
      await _repository.saveUserProfile(updatedProfile);
      // On success, update the state with the new data.
      state = AsyncValue.data(updatedProfile);
    } catch (e, s) {
      // On error, set an error state. The UI can decide how to show it.
      state = AsyncValue.error(e, s);
    }
  }
}

// --- 4. Riverpod Providers ---
final profileRepoProvider = Provider((ref) {
  final dio = ref.read(dioServiceProvider);
  return ProfileRepository(dio);
});

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile>>((ref) {
  return ProfileNotifier(ref.watch(profileRepoProvider));
});
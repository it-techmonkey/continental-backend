
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:continental/config/api_config.dart';
import 'package:continental/storage/token_storage.dart';

enum PropertyMode { rental, offPlan }

@immutable
class NewProperty {
  final PropertyMode mode;
  final String propertyName;
  final String developerName;
  final String? propertyType;
  final String? market;
  final String? noOfBedrooms;
  final String? noOfBathrooms;
  final String? furnishing;
  final String? city;
  final String? location;
  final String? locality;
  final double? latitude;
  final double? longitude;
  final String? viewsFromProperty;
  final List<String>? amenities;
  // Rental Specific
  final String? rent;
  final String? rentFrequency;
  final String? paymentCount; // mandatory count from UI
  // Off-Plan Specific
  final String? price;
  final DateTime? handover;
  // Tenant/Owner Details
  final String name;
  final String email;
  final String phone;
  // Charges
  final String? dld;
  final String? quood;
  final String? otherCharges;
  final String? penalties;
  // Image URLs (from S3 upload)
  final String? propertyImageUrl;
  final String? agreementUrl;

  const NewProperty({
    required this.mode,
    required this.propertyName,
    required this.developerName,
    this.propertyType,
    this.market,
    this.noOfBedrooms,
    this.noOfBathrooms,
    this.furnishing,
    this.city,
    this.location,
    this.locality,
    this.latitude,
    this.longitude,
    this.viewsFromProperty,
    this.amenities,
    this.rent,
    this.rentFrequency,
    this.paymentCount,
    this.price,
    this.handover,
    required this.name,
    required this.email,
    required this.phone,
    this.dld,
    this.quood,
    this.otherCharges,
    this.penalties,
    this.propertyImageUrl,
    this.agreementUrl,
  });
}
// --- 2. Repository ---
class AddPropertyRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
  final TokenStorage _tokenStorage = TokenStorage();

  Future<bool> saveProperty(NewProperty property) async {
    print("Saving ${property.mode.name} property: ${property.propertyName}...");

    final body = _buildRequestBody(property);
    print('[ADD_PROPERTY] Request body => ' + body.toString());
    try {
      final token = await _tokenStorage.getToken();
      final headers = ApiConfig.getAuthHeaders(token);
      final response = await _dio.post(
        '/occupant-records',
        data: body,
        options: Options(headers: headers),
      );
      final ok = response.statusCode == 200 || response.statusCode == 201;
      if (ok) print("Property saved successfully!");
      return ok;
    } on DioException catch (e) {
      print('[ADD_PROPERTY] Error status: ${e.response?.statusCode}');
      print('[ADD_PROPERTY] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('[ADD_PROPERTY] Unexpected error: $e');
      rethrow;
    }
  }

  Future<bool> updateProperty(int id, NewProperty property) async {
    print("Updating ${property.mode.name} property: ${property.propertyName} (ID: $id)...");

    final body = _buildRequestBody(property);
    print('[UPDATE_PROPERTY] Request body => ' + body.toString());
    try {
      final token = await _tokenStorage.getToken();
      final headers = ApiConfig.getAuthHeaders(token);
      final response = await _dio.put(
        '/occupant-records/$id',
        data: body,
        options: Options(headers: headers),
      );
      final ok = response.statusCode == 200;
      if (ok) print("Property updated successfully!");
      return ok;
    } on DioException catch (e) {
      print('[UPDATE_PROPERTY] Error status: ${e.response?.statusCode}');
      print('[UPDATE_PROPERTY] Error data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('[UPDATE_PROPERTY] Unexpected error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _buildRequestBody(NewProperty p) {
    final common = <String, dynamic>{
      'name': p.name,
      'phone': p.phone,
      'email': p.email,
      'property_name': p.propertyName,
      'developer_name': p.developerName,
      'property_type': p.mode == PropertyMode.rental ? 'Rental' : 'OffPlan',
      'home_type': p.propertyType,
      'market': p.market,
      'bedrooms': _toInt(p.noOfBedrooms),
      'bathrooms': _toInt(p.noOfBathrooms),
      'furnishing': _mapFurnishing(p.furnishing),
      'city': p.city,
      'location': p.location,
      'locality': p.locality,
      'latitude': p.latitude,
      'longitude': p.longitude,
      'property_views': p.viewsFromProperty,
      'amenities': p.amenities,
      'handover': p.handover?.toIso8601String(),
      'payment_frequency': _mapPaymentFrequency(p.rentFrequency),
      'payment_count': _toInt(p.paymentCount),
      'completion_date': p.handover?.toIso8601String(),
      'dld': _toInt(p.dld),
      'quood': _toInt(p.quood),
      'other_charges': _toInt(p.otherCharges),
      'penalties': _toInt(p.penalties),
    }..removeWhere((k, v) => v == null);

    // Add image URLs
    if (p.propertyImageUrl != null) {
      common['image_url'] = p.propertyImageUrl;
    }

    // Add price for both Rental and Off Plan
    if (p.price != null && p.price!.isNotEmpty) {
      common['price'] = _toInt(p.price);
    }

    if (p.mode == PropertyMode.offPlan) {
      common['emi'] = 15000; // placeholder
      if (p.agreementUrl != null) {
        common['offplan_agreement'] = p.agreementUrl;
      } else {
        common['offplan_agreement'] = 'https://example.com/offplan-agreement.pdf';
      }
    } else {
      common['rent'] = _toInt(p.rent);
      if (p.agreementUrl != null) {
        common['rental_agreement'] = p.agreementUrl;
      } else {
        common['rental_agreement'] = 'https://example.com/rental-agreement.pdf';
      }
    }
    return common;
  }

  int? _toInt(String? s) {
    if (s == null || s.isEmpty) return null;
    // Directly parse the string as integer (now we have 0-10 options)
    return int.tryParse(s.trim());
  }

  String? _mapFurnishing(String? f) {
    if (f == null) return null;
    final v = f.toLowerCase().trim();
    if (v.contains('fully')) return 'fully_furnished';
    if (v.contains('partly') || v.contains('partial')) return 'partially_furnished';
    if (v.contains('unfurnished')) return 'unfurnished';
    if (v.contains('kitchen')) return 'kitchen_appliances_only';
    // fallback: map "furnished" to fully_furnished
    if (v == 'furnished') return 'fully_furnished';
    return null;
  }

  String? _mapPaymentFrequency(String? f) {
    if (f == null) return null;
    final v = f.toLowerCase().trim();
    if (v.contains('month')) return 'monthly';
    if (v.contains('quarter')) return 'quarterly';
    if (v.contains('year')) return 'yearly';
    return v; // pass-through
  }
}

class PropertyModeNotifier extends Notifier<PropertyMode> {
  @override
  PropertyMode build() => PropertyMode.rental;
  void setMode(PropertyMode mode) => state = mode;
}

final propertyModeProvider = NotifierProvider<PropertyModeNotifier, PropertyMode>(() {
  return PropertyModeNotifier();
});

class AddPropertyNotifier extends Notifier<AsyncValue<void>> {
  late final AddPropertyRepository _repository;

  @override
  AsyncValue<void> build() {
    _repository = ref.read(addPropertyRepoProvider);
    return const AsyncValue.data(null);
  }

  Future<void> save(NewProperty property) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveProperty(property);
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> update(int id, NewProperty property) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateProperty(id, property);
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}


final addPropertyRepoProvider = Provider<AddPropertyRepository>((ref) => AddPropertyRepository());

final addPropertyProvider = NotifierProvider<AddPropertyNotifier, AsyncValue<void>>(() {
  return AddPropertyNotifier();
});
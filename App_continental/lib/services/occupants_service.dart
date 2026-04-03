import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:continental/config/api_config.dart';
import 'package:continental/storage/token_storage.dart';

class OccupantDetailDto {
  final int id;
  final String propertyName;
  final String developerName;
  final String name;
  final String phone;
  final String? email;
  final String propertyType; // Rental | OffPlan
  final String? locality;
  final String? homeType; // Apartment, Villa, Townhouse
  final String? market;
  final int? bedrooms;
  final int? bathrooms;
  final String? furnishing;
  final String? city;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? propertyViews;
  final List<String>? amenities;
  final num? price;
  final num? emi;
  final num? rent;
  final String? paymentFrequency;
  final int? paymentCount;
  final DateTime? handover;
  final String? imageUrl;
  final String? rentalAgreement;
  final String? offplanAgreement;
  final String? completionDate;
  final int? dld;
  final int? quood;
  final int? otherCharges;
  final int? penalties;

  OccupantDetailDto({
    required this.id,
    required this.propertyName,
    required this.developerName,
    required this.name,
    required this.phone,
    this.email,
    required this.propertyType,
    this.locality,
    this.homeType,
    this.market,
    this.bedrooms,
    this.bathrooms,
    this.furnishing,
    this.city,
    this.location,
    this.latitude,
    this.longitude,
    this.propertyViews,
    this.amenities,
    this.price,
    this.emi,
    this.rent,
    this.paymentFrequency,
    this.paymentCount,
    this.handover,
    this.imageUrl,
    this.rentalAgreement,
    this.offplanAgreement,
    this.completionDate,
    this.dld,
    this.quood,
    this.otherCharges,
    this.penalties,
  });

  factory OccupantDetailDto.fromJson(Map<String, dynamic> json) {
    // Parse amenities (can be List or null)
    List<String>? amenitiesList;
    if (json['amenities'] != null) {
      if (json['amenities'] is List) {
        amenitiesList = (json['amenities'] as List).map((e) => e.toString()).toList();
      }
    }

    // Parse handover date
    DateTime? handoverDate;
    if (json['handover'] != null) {
      try {
        handoverDate = DateTime.parse(json['handover'].toString());
      } catch (e) {
        handoverDate = null;
      }
    }

    // Parse completion date (string format)
    String? completionDateStr;
    if (json['completion_date'] != null) {
      try {
        final date = DateTime.parse(json['completion_date'].toString());
        completionDateStr = DateFormat('yyyy-MM-dd').format(date);
      } catch (e) {
        completionDateStr = json['completion_date'].toString();
      }
    }

    return OccupantDetailDto(
      id: json['id'] ?? 0,
      propertyName: json['property_name'] ?? '—',
      developerName: json['developer_name'] ?? '—',
      name: json['name'] ?? '—',
      phone: json['phone'] ?? '',
      email: json['email'],
      propertyType: json['property_type'] ?? 'Rental',
      locality: json['locality'],
      homeType: json['home_type'],
      market: json['market'],
      bedrooms: json['bedrooms'] is int ? json['bedrooms'] : (json['bedrooms'] is String ? int.tryParse(json['bedrooms']) : null),
      bathrooms: json['bathrooms'] is int ? json['bathrooms'] : (json['bathrooms'] is String ? int.tryParse(json['bathrooms']) : null),
      furnishing: json['furnishing'],
      city: json['city'],
      location: json['location'],
      latitude: json['latitude'] is double ? json['latitude'] : (json['latitude'] is num ? json['latitude'].toDouble() : null),
      longitude: json['longitude'] is double ? json['longitude'] : (json['longitude'] is num ? json['longitude'].toDouble() : null),
      propertyViews: json['property_views'],
      amenities: amenitiesList,
      price: (json['price'] is num) ? json['price'] : num.tryParse('${json['price']}'),
      emi: (json['emi'] is num) ? json['emi'] : num.tryParse('${json['emi']}'),
      rent: (json['rent'] is num) ? json['rent'] : num.tryParse('${json['rent']}'),
      paymentFrequency: json['payment_frequency'],
      paymentCount: json['payment_count'] is int ? json['payment_count'] : (json['payment_count'] is String ? int.tryParse(json['payment_count']) : null),
      handover: handoverDate,
      imageUrl: json['image_url'],
      rentalAgreement: json['rental_agreement'],
      offplanAgreement: json['offplan_agreement'],
      completionDate: completionDateStr,
      dld: json['dld'] is int ? json['dld'] : (json['dld'] is String ? int.tryParse(json['dld']) : null),
      quood: json['quood'] is int ? json['quood'] : (json['quood'] is String ? int.tryParse(json['quood']) : null),
      otherCharges: json['other_charges'] is int ? json['other_charges'] : (json['other_charges'] is String ? int.tryParse(json['other_charges']) : null),
      penalties: json['penalties'] is int ? json['penalties'] : (json['penalties'] is String ? int.tryParse(json['penalties']) : null),
    );
  }
}

class OccupantsService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 30),
  ));
  final TokenStorage _tokenStorage = TokenStorage();

  Future<OccupantDetailDto?> fetchOccupantDetail(int id) async {
    final token = await _tokenStorage.getToken();
    final headers = ApiConfig.getAuthHeaders(token);
    final response = await _dio.get('/occupant-records/$id', options: Options(headers: headers));
    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      return OccupantDetailDto.fromJson(data);
    }
    return null;
  }

  Future<bool> updateCharges(int id, Map<String, int?> charges) async {
    try {
      final token = await _tokenStorage.getToken();
      final headers = ApiConfig.getAuthHeaders(token);
      final data = <String, dynamic>{};

      // Only include fields that are in the map (explicitly provided)
      // Note: We allow null values to clear a field, and 0 is a valid charge amount
      if (charges.containsKey('dld')) {
        data['dld'] = charges['dld']; // Can be null to clear, or a number (including 0)
      }
      if (charges.containsKey('quood')) {
        data['quood'] = charges['quood'];
      }
      if (charges.containsKey('otherCharges')) {
        data['other_charges'] = charges['otherCharges']; // Backend uses snake_case
      }
      if (charges.containsKey('penalties')) {
        data['penalties'] = charges['penalties'];
      }

      // If no fields to update, return false
      if (data.isEmpty) {
        debugPrint('⚠️ [UPDATE_CHARGES] No fields to update');
        return false;
      }

      debugPrint('📤 [UPDATE_CHARGES] Updating charges for ID $id: $data');

      final response = await _dio.put(
        '/occupant-records/$id',
        data: data,
        options: Options(headers: headers),
      );

      debugPrint('✅ [UPDATE_CHARGES] Response status: ${response.statusCode}');
      debugPrint('📦 [UPDATE_CHARGES] Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Verify the updated values in response
        final updatedData = response.data['data'];
        if (updatedData != null) {
          debugPrint('📊 [UPDATE_CHARGES] Updated values: dld=${updatedData['dld']}, quood=${updatedData['quood']}, other_charges=${updatedData['other_charges']}, penalties=${updatedData['penalties']}');
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ [UPDATE_CHARGES] Error: $e');
      return false;
    }
  }

  Future<bool> updateOccupantRecord(int id, Map<String, dynamic> data) async {
    try {
      final token = await _tokenStorage.getToken();
      final headers = ApiConfig.getAuthHeaders(token);

      debugPrint('📤 [UPDATE_PROPERTY] Updating property ID $id with data: $data');

      final response = await _dio.put(
        '/occupant-records/$id',
        data: data,
        options: Options(headers: headers),
      );

      debugPrint('✅ [UPDATE_PROPERTY] Response status: ${response.statusCode}');
      debugPrint('📦 [UPDATE_PROPERTY] Response data: ${response.data}');

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      debugPrint('❌ [UPDATE_PROPERTY] Error: $e');
      return false;
    }
  }

  Future<bool> deleteOccupantRecord(int id) async {
    try {
      final token = await _tokenStorage.getToken();
      final headers = ApiConfig.getAuthHeaders(token);

      debugPrint('📤 [DELETE_PROPERTY] Deleting property ID $id');

      final response = await _dio.delete(
        '/occupant-records/$id',
        options: Options(headers: headers),
      );

      debugPrint('✅ [DELETE_PROPERTY] Response status: ${response.statusCode}');
      debugPrint('📦 [DELETE_PROPERTY] Response data: ${response.data}');

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      debugPrint('❌ [DELETE_PROPERTY] Error: $e');
      return false;
    }
  }

  Future<List<OccupantDetailDto>> fetchAllOccupantRecords({String? propertyType}) async {
    try {
      final token = await _tokenStorage.getToken();
      final headers = ApiConfig.getAuthHeaders(token);
      
      final queryParams = <String, dynamic>{};
      if (propertyType != null && propertyType.isNotEmpty) {
        // Map "Off Plan" to "OffPlan" for backend
        queryParams['property_type'] = propertyType == 'Off Plan' ? 'OffPlan' : propertyType;
      }
      
      final response = await _dio.get(
        '/occupant-records',
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: Options(headers: headers),
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        // Backend returns { records: [...], total: ... }
        final records = responseData['records'] as List? ?? responseData as List;
        return records.map((e) => OccupantDetailDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ [FETCH_ALL_OCCUPANTS] Error: $e');
      return [];
    }
  }
}



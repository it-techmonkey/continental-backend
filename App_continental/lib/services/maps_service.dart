import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/property_map_model.dart';

// Maps Service — fetches ONLY backend API property records
class MapsService {
  final Dio _dio;

  MapsService(this._dio);

  Future<PropertyMapResponse> fetchPropertyRecords() async {
    try {
      debugPrint('🗺️ [MAPS] Fetching property records from backend...');

      debugPrint(
        '📡 [MAPS] Request URL: ${ApiConfig.baseUrl}${ApiConfig.occupantRecordsMaps}',
      );

      final response = await _dio.get(ApiConfig.occupantRecordsMaps);

      debugPrint('✅ [MAPS] Response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = PropertyMapResponse.fromJson(response.data);
        final apiData =
            apiResponse.data ?? PropertyMapData(records: const [], total: 0);

        debugPrint('📊 [MAPS] Backend records: ${apiData.records.length}');
        debugPrint(
          '📍 [MAPS] With valid coordinates: ${apiData.records.where((r) => r.hasValidCoordinates).length}',
        );

        return PropertyMapResponse(
          success: true,
          message: apiResponse.message,
          data: apiData,
        );
      } else {
        debugPrint('❌ [MAPS] Failed with status: ${response.statusCode}');
        return PropertyMapResponse(
          success: false,
          message: 'Failed to fetch property records',
          data: null,
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ [MAPS] DioException: ${e.message}');
      debugPrint('📋 [MAPS] Error details: ${e.response?.data}');
      return PropertyMapResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Network error occurred',
        data: null,
      );
    } catch (e) {
      debugPrint('❌ [MAPS] Unexpected error: $e');
      return PropertyMapResponse(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Client-side filtering by property type and search query.
  static PropertyMapData applyFilters(
    PropertyMapData data, {
    String? filter,
    String? searchQuery,
  }) {
    List<PropertyRecord> filteredRecords = data.records;

    if (filter != null && filter != 'All') {
      filteredRecords = filteredRecords
          .where((record) => record.matchesFilter(filter))
          .toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredRecords = filteredRecords
          .where(
            (record) =>
                record.propertyName.toLowerCase().contains(query) ||
                record.developerName.toLowerCase().contains(query) ||
                record.location.toLowerCase().contains(query),
          )
          .toList();
    }

    return PropertyMapData(
      records: filteredRecords,
      total: filteredRecords.length,
    );
  }
}

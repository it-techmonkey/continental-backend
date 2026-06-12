import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/property_map_model.dart';

// Maps Service
class MapsService {
  final Dio _dio;

  MapsService(this._dio);

  /// Fetch all property records (backend + bundled catalog), unfiltered.
  /// Filtering by type/search is applied client-side by the provider layer.
  Future<PropertyMapResponse> fetchPropertyRecords() async {
    try {
      debugPrint('🗺️ [MAPS] Fetching property records...');

      debugPrint('📡 [MAPS] Request URL: ${ApiConfig.baseUrl}${ApiConfig.occupantRecordsMaps}');

      // Token is automatically added by Dio interceptor
      final response = await _dio.get(
        ApiConfig.occupantRecordsMaps,
      );

      debugPrint('✅ [MAPS] Response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = PropertyMapResponse.fromJson(response.data);
        final apiData =
            apiResponse.data ?? PropertyMapData(records: const [], total: 0);
        final catalogData = await _loadCatalogFallback();

        // API records and catalog records come from unrelated ID spaces,
        // so they are concatenated rather than merged by id.
        final merged = PropertyMapData(
          records: [...apiData.records, ...catalogData.records],
          total: apiData.records.length + catalogData.records.length,
        );

        debugPrint(
          '📊 [MAPS] API records: ${apiData.records.length}, catalog: ${catalogData.records.length}, merged: ${merged.records.length}',
        );
        debugPrint(
          '📍 [MAPS] With valid coordinates: ${merged.records.where((r) => r.hasValidCoordinates).length}',
        );

        return PropertyMapResponse(
          success: true,
          message: apiResponse.message,
          data: merged,
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
      final fallbackData = await _loadCatalogFallback();
      if (fallbackData.records.isNotEmpty) {
        return PropertyMapResponse(
          success: true,
          message: 'Loaded map records from local property catalog',
          data: fallbackData,
        );
      }
      return PropertyMapResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Network error occurred',
        data: null,
      );
    } catch (e) {
      debugPrint('❌ [MAPS] Unexpected error: $e');
      final fallbackData = await _loadCatalogFallback();
      if (fallbackData.records.isNotEmpty) {
        return PropertyMapResponse(
          success: true,
          message: 'Loaded map records from local property catalog',
          data: fallbackData,
        );
      }
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
      filteredRecords =
          filteredRecords.where((record) => record.matchesFilter(filter)).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredRecords = filteredRecords
          .where((record) =>
              record.propertyName.toLowerCase().contains(query) ||
              record.developerName.toLowerCase().contains(query) ||
              record.location.toLowerCase().contains(query))
          .toList();
    }

    return PropertyMapData(
      records: filteredRecords,
      total: filteredRecords.length,
    );
  }

  Future<PropertyMapData> _loadCatalogFallback() async {
    const candidatePaths = <String>[
      'data/all_data_uae_en.json',
      'assets/data/all_data_uae_en.json',
      'all_data_uae_en.json',
    ];

    Object? lastError;
    for (final path in candidatePaths) {
      try {
        final raw = await rootBundle.loadString(path);
        final decoded = json.decode(raw) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>?;
        final items = (data?['items'] as List<dynamic>? ?? const []);

        final records = items
            .whereType<Map<String, dynamic>>()
            .map(PropertyRecord.fromCatalogItem)
            .where((record) => record.hasValidCoordinates)
            .toList();

        debugPrint('📦 [MAPS] Loaded local catalog from $path with ${records.length} map records');
        return PropertyMapData(records: records, total: records.length);
      } catch (e) {
        lastError = e;
      }
    }

    debugPrint('❌ [MAPS] Failed to load local catalog fallback: $lastError');
    return PropertyMapData(records: const [], total: 0);
  }
}

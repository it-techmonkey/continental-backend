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

  // Fetch property records for maps
  Future<PropertyMapResponse> fetchPropertyRecords({String? filter, String? searchQuery}) async {
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
        final filteredData = _applyFilters(
          apiResponse.data,
          filter: filter,
          searchQuery: searchQuery,
        );

        final catalogData = await _loadCatalogFallback(
          filter: filter,
          searchQuery: searchQuery,
        );

        // Fallback to bundled catalog only when API has no usable coordinates.
        final hasValidApiCoords =
            filteredData?.records.any((r) => r.hasValidCoordinates) ?? false;
        if (!hasValidApiCoords) {
          debugPrint(
            '⚠️ [MAPS] API dataset has no valid coordinates. Using local catalog.',
          );
          return PropertyMapResponse(
            success: true,
            message: 'Loaded map records from local property catalog',
            data: catalogData,
          );
        }

        // Merge: show bundled JSON properties plus API rows (same id → API wins).
        final merged = _mergeCatalogWithApi(
          api: filteredData!,
          catalog: catalogData,
        );

        debugPrint(
          '📊 [MAPS] API records: ${filteredData.records.length}, catalog: ${catalogData.records.length}, merged: ${merged.records.length}',
        );
        debugPrint(
          '📍 [MAPS] With valid coordinates: ${merged.records.where((r) => r.hasValidCoordinates).length}',
        );

        return PropertyMapResponse(
          success: apiResponse.success,
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
      final fallbackData = await _loadCatalogFallback(filter: filter, searchQuery: searchQuery);
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
      final fallbackData = await _loadCatalogFallback(filter: filter, searchQuery: searchQuery);
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

  /// Same [id]: prefer API record; include catalog-only ids; append API rows without id.
  PropertyMapData _mergeCatalogWithApi({
    required PropertyMapData api,
    required PropertyMapData catalog,
  }) {
    final byId = <int, PropertyRecord>{};

    for (final r in catalog.records) {
      if (r.id != null) {
        byId[r.id!] = r;
      }
    }

    for (final r in api.records) {
      if (r.id != null) {
        byId[r.id!] = r;
      }
    }

    final extra = <PropertyRecord>[];
    for (final r in api.records) {
      if (r.id == null && r.hasValidCoordinates) {
        extra.add(r);
      }
    }
    for (final r in catalog.records) {
      if (r.id == null && r.hasValidCoordinates) {
        extra.add(r);
      }
    }

    return PropertyMapData(
      records: [...byId.values, ...extra],
      total: byId.length + extra.length,
    );
  }

  PropertyMapData? _applyFilters(
    PropertyMapData? data, {
    String? filter,
    String? searchQuery,
  }) {
    if (data == null) return null;

    List<PropertyRecord> filteredRecords = data.records;
    debugPrint('📊 [MAPS] Total records before filter: ${filteredRecords.length}');
    debugPrint('📊 [MAPS] Property types: ${filteredRecords.map((r) => r.propertyType).toSet().toList()}');
    debugPrint('📊 [MAPS] Applying filter: $filter');

    if (filter != null && filter != 'All') {
      filteredRecords = filteredRecords.where((record) => record.matchesFilter(filter)).toList();
      debugPrint('🔍 [MAPS] Filtered to ${filteredRecords.length} $filter properties');
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredRecords = filteredRecords
          .where((record) =>
              record.propertyName.toLowerCase().contains(query) ||
              record.developerName.toLowerCase().contains(query))
          .toList();
      debugPrint('🔍 [MAPS] Filtered to ${filteredRecords.length} properties matching "$searchQuery"');
    }

    return PropertyMapData(
      records: filteredRecords,
      total: filteredRecords.length,
    );
  }

  Future<PropertyMapData> _loadCatalogFallback({String? filter, String? searchQuery}) async {
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

        final filtered = _applyFilters(
          PropertyMapData(records: records, total: records.length),
          filter: filter,
          searchQuery: searchQuery,
        );

        debugPrint('📦 [MAPS] Loaded local catalog from $path with ${filtered?.records.length ?? 0} map records');
        return filtered ?? PropertyMapData(records: const [], total: 0);
      } catch (e) {
        lastError = e;
      }
    }

    debugPrint('❌ [MAPS] Failed to load local catalog fallback: $lastError');
    return PropertyMapData(records: const [], total: 0);
  }
}


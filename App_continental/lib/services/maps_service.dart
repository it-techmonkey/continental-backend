import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/property_map_model.dart';
import 'dio_service.dart';

// Maps Service
class MapsService {
  final Dio _dio;

  MapsService(this._dio);

  // Fetch property records for maps
  Future<PropertyMapResponse> fetchPropertyRecords({String? filter, String? searchQuery}) async {
    try {
      print('🗺️ [MAPS] Fetching property records...');
      
      print('📡 [MAPS] Request URL: ${ApiConfig.baseUrl}${ApiConfig.occupantRecordsMaps}');
      
      // Token is automatically added by Dio interceptor
      final response = await _dio.get(
        ApiConfig.occupantRecordsMaps,
      );

      print('✅ [MAPS] Response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = PropertyMapResponse.fromJson(response.data);
        
        // Filter records based on property type and search query
        PropertyMapData? filteredData = apiResponse.data;
        if (filteredData != null) {
          List<PropertyRecord> filteredRecords = filteredData.records;
          // Debug: log property types
          print('📊 [MAPS] Total records before filter: ${filteredRecords.length}');
          print('📊 [MAPS] Property types: ${filteredRecords.map((r) => r.propertyType).toSet().toList()}');
          print('📊 [MAPS] Applying filter: $filter');
          
          // Apply property type filter
          if (filter != null && filter != 'All') {
            filteredRecords = filteredRecords
                .where((record) => record.matchesFilter(filter))
                .toList();
            print('🔍 [MAPS] Filtered to ${filteredRecords.length} ${filter} properties');
          }
          
          // Apply search query filter (by property name or developer name)
          if (searchQuery != null && searchQuery.isNotEmpty) {
            final query = searchQuery.toLowerCase();
            filteredRecords = filteredRecords
                .where((record) => 
                    record.propertyName.toLowerCase().contains(query) ||
                    record.developerName.toLowerCase().contains(query))
                .toList();
            print('🔍 [MAPS] Filtered to ${filteredRecords.length} properties matching "$searchQuery"');
          }
          
          filteredData = PropertyMapData(
            records: filteredRecords,
            total: filteredRecords.length,
          );
        }
        
        print('📊 [MAPS] Total records: ${filteredData?.total ?? 0}');
        print('📍 [MAPS] Records with valid coordinates: ${filteredData?.records.where((r) => r.hasValidCoordinates).length ?? 0}');
        
        // Return new response with filtered data
        return PropertyMapResponse(
          success: apiResponse.success,
          message: apiResponse.message,
          data: filteredData,
        );
      } else {
        print('❌ [MAPS] Failed with status: ${response.statusCode}');
        return PropertyMapResponse(
          success: false,
          message: 'Failed to fetch property records',
          data: null,
        );
      }
    } on DioException catch (e) {
      print('❌ [MAPS] DioException: ${e.message}');
      print('📋 [MAPS] Error details: ${e.response?.data}');
      return PropertyMapResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Network error occurred',
        data: null,
      );
    } catch (e) {
      print('❌ [MAPS] Unexpected error: $e');
      return PropertyMapResponse(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        data: null,
      );
    }
  }
}


// Property Map Models
class PropertyMapResponse {
  final bool success;
  final String message;
  final PropertyMapData? data;

  PropertyMapResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory PropertyMapResponse.fromJson(Map<String, dynamic> json) {
    return PropertyMapResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? PropertyMapData.fromJson(json['data']) : null,
    );
  }
}

class PropertyMapData {
  final List<PropertyRecord> records;
  final int total;

  PropertyMapData({
    required this.records,
    required this.total,
  });

  factory PropertyMapData.fromJson(Map<String, dynamic> json) {
    return PropertyMapData(
      records: (json['records'] as List<dynamic>?)
              ?.map((record) => PropertyRecord.fromJson(record))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }
}

class PropertyRecord {
  final int? id;
  final String developerName;
  final String propertyName;
  final num? price;
  final String? imageUrl;
  final String propertyType; // "Rental" or "OffPlan"
  final String location;
  final double? longitude;
  final double? latitude;

  PropertyRecord({
    this.id,
    required this.developerName,
    required this.propertyName,
    this.price,
    this.imageUrl,
    required this.propertyType,
    required this.location,
    this.longitude,
    this.latitude,
  });

  factory PropertyRecord.fromJson(Map<String, dynamic> json) {
    return PropertyRecord(
      id: json['id'] as int?,
      developerName: json['developer_name'] ?? '',
      propertyName: json['property_name'] ?? '',
      price: json['price'],
      imageUrl: json['image_url'],
      propertyType: json['property_type'] ?? 'Rental',
      location: json['location'] ?? '',
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
    );
  }

  // Check if record has valid coordinates
  bool get hasValidCoordinates =>
      longitude != null && latitude != null &&
      longitude! >= -180 && longitude! <= 180 &&
      latitude! >= -90 && latitude! <= 90;

  // Check if property type matches filter
  bool matchesFilter(String? filter) {
    if (filter == null || filter == 'All') return true;
    
    // Normalize filter: "Off Plan" -> "OffPlan" to match API
    String normalizedFilter = filter.toLowerCase().replaceAll(' ', '');
    String normalizedPropertyType = propertyType.toLowerCase();
    
    return normalizedPropertyType == normalizedFilter;
  }
}


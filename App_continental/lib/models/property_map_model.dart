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
    final dynamic rawRecords = json['records'];
    final dynamic rawFeatures = json['features'];

    List<PropertyRecord> parsedRecords = [];

    // Primary format: { data: { records: [...] } }
    if (rawRecords is List) {
      parsedRecords = rawRecords
          .whereType<Map<String, dynamic>>()
          .map((record) => PropertyRecord.fromJson(record))
          .toList();
    }

    // GeoJSON format fallback:
    // { data: { features: [{ properties: {...}, geometry: {...} }] } }
    if (parsedRecords.isEmpty && rawFeatures is List) {
      parsedRecords = rawFeatures
          .whereType<Map<String, dynamic>>()
          .map((feature) => PropertyRecord.fromGeoJsonFeature(feature))
          .toList();
    }

    return PropertyMapData(
      records: parsedRecords,
      total: json['total'] ?? parsedRecords.length,
    );
  }
}

/// Where a map record came from: the backend API (user's own properties)
/// or the bundled offline market catalog.
enum PropertySource { api, catalog }

class PropertyRecord {
  final int? id;
  final String developerName;
  final String propertyName;
  final num? price;
  final num? priceFrom;
  final num? priceTo;
  final String? imageUrl;
  final String propertyType; // "Rental" or "OffPlan"
  final String location;
  final double? longitude;
  final double? latitude;
  final Map<String, dynamic>? properties;
  final PropertySource source;

  PropertyRecord({
    this.id,
    required this.developerName,
    required this.propertyName,
    this.price,
    this.priceFrom,
    this.priceTo,
    this.imageUrl,
    required this.propertyType,
    required this.location,
    this.longitude,
    this.latitude,
    this.properties,
    this.source = PropertySource.api,
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
      properties: json,
    );
  }

  factory PropertyRecord.fromGeoJsonFeature(Map<String, dynamic> feature) {
    final props = (feature['properties'] as Map?)?.cast<String, dynamic>() ?? {};
    final geometry = (feature['geometry'] as Map?)?.cast<String, dynamic>();
    final coordinates = geometry?['coordinates'];

    double? lng;
    double? lat;
    if (coordinates is List && coordinates.length >= 2) {
      final c0 = coordinates[0];
      final c1 = coordinates[1];
      if (c0 is num) lng = c0.toDouble();
      if (c1 is num) lat = c1.toDouble();
    }

    lng ??= props['longitude'] is num ? (props['longitude'] as num).toDouble() : null;
    lat ??= props['latitude'] is num ? (props['latitude'] as num).toDouble() : null;

    return PropertyRecord(
      id: props['id'] is num ? (props['id'] as num).toInt() : null,
      developerName: props['developer_name']?.toString() ?? '',
      propertyName: props['property_name']?.toString() ?? '',
      price: props['price'] is num ? props['price'] as num : null,
      imageUrl: props['image_url']?.toString(),
      propertyType: props['property_type']?.toString() ?? 'Rental',
      location: props['location']?.toString() ?? '',
      longitude: lng,
      latitude: lat,
      properties: props,
    );
  }

  factory PropertyRecord.fromCatalogItem(Map<String, dynamic> item) {
    final itemId = item['id'];
    final title = item['title']?.toString().trim() ?? '';
    final builder = item['builder']?.toString().trim() ?? '';
    final location =
        (item['district'] is Map && (item['district'] as Map)['title'] != null)
            ? (item['district'] as Map)['title'].toString()
            : (item['location']?.toString() ?? '');

    final latRaw = item['latitude'];
    final lngRaw = item['longitude'];
    final lat = latRaw is num ? latRaw.toDouble() : null;
    final lng = lngRaw is num ? lngRaw.toDouble() : null;

    final typeRaw = item['property_type']?.toString().toLowerCase();
    final fallbackType = (typeRaw == 'rental') ? 'Rental' : 'OffPlan';

    // Catalog items carry their price range in statistics.total
    num? priceFrom;
    num? priceTo;
    final stats = item['statistics'];
    if (stats is Map && stats['total'] is Map) {
      final total = stats['total'] as Map;
      if (total['price_from'] is num) priceFrom = total['price_from'] as num;
      if (total['price_to'] is num) priceTo = total['price_to'] as num;
    }

    return PropertyRecord(
      id: itemId is num ? itemId.toInt() : null,
      developerName: builder.isNotEmpty ? builder : 'Unknown Developer',
      propertyName: title.isNotEmpty ? title : (item['slug']?.toString() ?? 'Property'),
      price: item['price'] is num ? item['price'] as num : null,
      priceFrom: priceFrom,
      priceTo: priceTo,
      imageUrl: (item['cover'] is Map)
          ? (item['cover'] as Map)['src']?.toString()
          : item['image_url']?.toString(),
      propertyType: fallbackType,
      location: location.isNotEmpty ? location : 'UAE',
      longitude: lng,
      latitude: lat,
      properties: item,
      source: PropertySource.catalog,
    );
  }

  /// Cover / logo image for map pins and listings (HTTPS normalized by callers).
  String? get mapImageUrl {
    final fromField = imageUrl?.trim();
    if (fromField != null && fromField.isNotEmpty) return fromField;
    final p = properties;
    if (p == null) return null;
    final logo = p['logo'];
    if (logo is Map) {
      for (final k in ['logo', 'src']) {
        final v = logo[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }
    for (final key in ['logo', 'logo_url', 'builder_logo', 'image_url']) {
      final v = p[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    final cover = p['cover'];
    if (cover is Map && cover['src'] is String) {
      final s = (cover['src'] as String).trim();
      if (s.isNotEmpty) return s;
    }
    return null;
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


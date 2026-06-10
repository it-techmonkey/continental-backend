import 'package:dio/dio.dart';
import 'package:continental/config/api_config.dart';

class PlaceSuggestion {
  final String description;
  final String placeId; // reused as feature index string
  final double lat;
  final double lng;
  PlaceSuggestion(this.description, this.placeId, this.lat, this.lng);
}

class PlaceDetailsResult {
  final String name;
  final double lat;
  final double lng;
  PlaceDetailsResult({required this.name, required this.lat, required this.lng});
}

class PlacesService {
  final Dio _dio = Dio();

  /// MapTiler geocoding autocomplete — restricted to UAE bounding box.
  Future<List<PlaceSuggestion>> autocomplete(String input) async {
    if (input.isEmpty) return [];
    try {
      // MapTiler geocoding API
      final res = await _dio.get(
        'https://api.maptiler.com/geocoding/${Uri.encodeComponent(input)}.json',
        queryParameters: {
          'key': ApiConfig.mapTilerApiKey,
          'autocomplete': 'true',
          'country': 'ae',           // restrict to UAE
          'language': 'en',
          'limit': '5',
        },
      );

      final features = (res.data['features'] as List?) ?? [];
      return features.map((f) {
        final coords = f['geometry']['coordinates'] as List;
        final lng = (coords[0] as num).toDouble();
        final lat = (coords[1] as num).toDouble();
        final name = (f['place_name'] ?? f['text'] ?? '').toString();
        final id = f['id']?.toString() ?? name;
        return PlaceSuggestion(name, id, lat, lng);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Returns the details for a suggestion — coordinates are already embedded
  /// in PlaceSuggestion so we just wrap them.
  Future<PlaceDetailsResult?> details(String placeId) async {
    // placeId is not used — the caller should use the lat/lng from the
    // PlaceSuggestion directly. This method exists for API compatibility.
    return null;
  }

  /// Convenience: resolve a suggestion directly (preferred over details()).
  PlaceDetailsResult fromSuggestion(PlaceSuggestion s) {
    return PlaceDetailsResult(name: s.description, lat: s.lat, lng: s.lng);
  }
}

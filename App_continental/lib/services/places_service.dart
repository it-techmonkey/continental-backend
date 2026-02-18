import 'package:dio/dio.dart';
import 'package:continental/config/api_config.dart';

class PlaceSuggestion {
  final String description;
  final String placeId;
  PlaceSuggestion(this.description, this.placeId);
}

class PlaceDetailsResult {
  final String name;
  final double lat;
  final double lng;
  PlaceDetailsResult({required this.name, required this.lat, required this.lng});
}

class PlacesService {
  final Dio _dio = Dio();

  Future<List<PlaceSuggestion>> autocomplete(String input) async {
    if (input.isEmpty) return [];
    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    final res = await _dio.get(url, queryParameters: {
      'input': input,
      'key': ApiConfig.googleMapsApiKey,
      'types': 'geocode',
      'components': 'country:ae', // Restrict to UAE
    });
    final predictions = (res.data['predictions'] as List?) ?? [];
    return predictions
        .map((p) => PlaceSuggestion(p['description'], p['place_id']))
        .toList();
  }

  Future<PlaceDetailsResult?> details(String placeId) async {
    final url = 'https://maps.googleapis.com/maps/api/place/details/json';
    final res = await _dio.get(url, queryParameters: {
      'place_id': placeId,
      'key': ApiConfig.googleMapsApiKey,
      'fields': 'name,geometry/location',
    });
    final r = res.data['result'];
    if (r == null) return null;
    final loc = r['geometry']['location'];
    return PlaceDetailsResult(
      name: r['name'],
      lat: (loc['lat'] as num).toDouble(),
      lng: (loc['lng'] as num).toDouble(),
    );
  }
}


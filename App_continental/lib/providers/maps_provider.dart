import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/maps_service.dart';
import '../services/dio_service.dart';
import '../models/property_map_model.dart';

// Maps Service Provider
final mapsServiceProvider = Provider<MapsService>((ref) {
  final dio = ref.read(dioServiceProvider);
  return MapsService(dio);
});

// Filter Notifier
class MapsFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';
  
  void setFilter(String filter) {
    state = filter;
  }
}

final mapsFilterProvider = NotifierProvider<MapsFilterNotifier, String>(() {
  return MapsFilterNotifier();
});

// Search Query Notifier
class MapsSearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  
  void setSearch(String query) {
    state = query;
  }
  
  void clearSearch() {
    state = '';
  }
}

final mapsSearchProvider = NotifierProvider<MapsSearchNotifier, String>(() {
  return MapsSearchNotifier();
});

// Maps Data Provider - now depends on both filter and search
final mapsDataProvider = FutureProvider<PropertyMapData?>((ref) async {
  final filter = ref.watch(mapsFilterProvider);
  final searchQuery = ref.watch(mapsSearchProvider);
  final mapsService = ref.read(mapsServiceProvider);
  final response = await mapsService.fetchPropertyRecords(filter: filter, searchQuery: searchQuery);
  
  if (response.success && response.data != null) {
    return response.data;
  }
  return null;
});


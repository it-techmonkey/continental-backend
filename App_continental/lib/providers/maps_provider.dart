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

// Search Query Notifier (set by the UI after debouncing)
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

/// Fetches all records once (backend + bundled catalog). Does NOT depend on
/// filter/search, so typing or switching filters never re-hits the network.
final mapsRawDataProvider = FutureProvider<PropertyMapData>((ref) async {
  final mapsService = ref.read(mapsServiceProvider);
  final response = await mapsService.fetchPropertyRecords();

  if (response.success && response.data != null) {
    return response.data!;
  }
  throw Exception(response.message.isNotEmpty
      ? response.message
      : 'Failed to load properties');
});

/// Filtered view of the raw data — recomputed in memory when the filter or
/// (debounced) search query changes.
final mapsDataProvider = Provider<AsyncValue<PropertyMapData>>((ref) {
  final filter = ref.watch(mapsFilterProvider);
  final searchQuery = ref.watch(mapsSearchProvider);
  final rawAsync = ref.watch(mapsRawDataProvider);

  return rawAsync.whenData(
    (data) => MapsService.applyFilters(
      data,
      filter: filter,
      searchQuery: searchQuery,
    ),
  );
});

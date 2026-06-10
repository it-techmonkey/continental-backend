import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/maps_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/language_service.dart';
import '../../models/property_map_model.dart';
import '../../config/api_config.dart';

/// Tiles: primary MapTiler; fallback CARTO/OSM if key missing or tile fails.
const String _kTileUrlMapTiler =
    'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key={key}';
const String _kTileUrlCarto =
    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
const String _kTileUrlOsmFallback =
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

class Dashboardscreen extends ConsumerStatefulWidget {
  const Dashboardscreen({super.key});

  @override
  ConsumerState<Dashboardscreen> createState() => _DashboardscreenState();
}

class _DashboardscreenState extends ConsumerState<Dashboardscreen> {
  final MapController _mapController = MapController();
  bool get _hasMapTilerKey => ApiConfig.mapTilerApiKey.trim().isNotEmpty;
  static const int _kHeavyMarkerThreshold = 250;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<Marker> _buildMapMarkers(List<PropertyRecord> records) {
    final markers = <Marker>[];
    final useLightweightMarkers = records.length > _kHeavyMarkerThreshold;

    for (var i = 0; i < records.length; i++) {
      final record = records[i];

      if (!record.hasValidCoordinates) continue;

      markers.add(
        Marker(
          point: LatLng(record.latitude!, record.longitude!),
          width: useLightweightMarkers ? 24 : 64,
          height: useLightweightMarkers ? 24 : 64,
          child: useLightweightMarkers
              ? _LightweightPinMarker(
                  record: record,
                  onTap: () => _openRecordDetailsSheet(record),
                )
              : _PropertyPinMarker(
                  record: record,
                  onTap: () => _openRecordDetailsSheet(record),
                ),
        ),
      );
    }

    return markers;
  }

  void _openRecordDetailsSheet(PropertyRecord record) {
    final detailEntries = _flattenRecordProperties(record);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.propertyName.isNotEmpty ? record.propertyName : 'Property Details',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.developerName,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: detailEntries.isEmpty
                      ? Center(
                          child: Text(
                            'No properties found for this record.',
                            style: GoogleFonts.inter(color: Colors.white70),
                          ),
                        )
                      : ListView.separated(
                          itemCount: detailEntries.length,
                          separatorBuilder: (_, __) =>
                              Divider(color: Colors.white.withValues(alpha: 0.12)),
                          itemBuilder: (context, index) {
                            final item = detailEntries[index];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    item.key,
                                    style: GoogleFonts.inter(
                                      color: Colors.yellow[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    item.value,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                if (record.id != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.goNamed(
                          'details',
                          pathParameters: {'itemId': record.id.toString()},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Open Property Details',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  List<MapEntry<String, String>> _flattenRecordProperties(PropertyRecord record) {
    final dynamic source = (record.properties != null && record.properties!.isNotEmpty)
        ? record.properties
        : <String, dynamic>{
            'id': record.id,
            'developer_name': record.developerName,
            'property_name': record.propertyName,
            'price': record.price,
            'image_url': record.imageUrl,
            'property_type': record.propertyType,
            'location': record.location,
            'longitude': record.longitude,
            'latitude': record.latitude,
          };

    final out = <MapEntry<String, String>>[];

    void walk(String prefix, dynamic value) {
      if (value is Map) {
        final map = value.cast<dynamic, dynamic>();
        if (map.isEmpty) {
          out.add(MapEntry(prefix, '{}'));
          return;
        }
        for (final entry in map.entries) {
          final key = entry.key?.toString() ?? 'null';
          final nextPrefix = prefix.isEmpty ? key : '$prefix.$key';
          walk(nextPrefix, entry.value);
        }
        return;
      }

      if (value is List) {
        if (value.isEmpty) {
          out.add(MapEntry(prefix, '[]'));
          return;
        }
        for (var i = 0; i < value.length; i++) {
          final nextPrefix = '$prefix[$i]';
          walk(nextPrefix, value[i]);
        }
        return;
      }

      out.add(MapEntry(prefix, _stringifyJsonValue(value)));
    }

    walk('', source);
    return out;
  }

  String _stringifyJsonValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? '""' : trimmed;
    }
    return value.toString();
  }

  void _scheduleFitToRecords(List<PropertyRecord> records) {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _fitMarkersInView(records);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentFilter = ref.watch(mapsFilterProvider);
    final mapsDataAsync = ref.watch(mapsDataProvider);
    final languageCode = ref.watch(languageProvider);
    String translate(String key) =>
        LanguageService.translate(key, languageCode);

    ref.listen(mapsDataProvider, (previous, next) {
      next.whenData((data) {
        if (data == null || data.records.isEmpty) return;
        final valid = data.records.where((r) => r.hasValidCoordinates).toList();
        if (valid.isEmpty) return;
        _scheduleFitToRecords(valid);
      });
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translate('A Product By Torodo Group'),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: translate('Search for Properties'),
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      ref.read(mapsSearchProvider.notifier).setSearch(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _FilterButton(
                          label: translate('All'),
                          isSelected: currentFilter == 'All',
                          onTap: () {
                            ref
                                .read(mapsFilterProvider.notifier)
                                .setFilter('All');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FilterButton(
                          label: translate('Rental'),
                          isSelected: currentFilter == 'Rental',
                          onTap: () {
                            ref
                                .read(mapsFilterProvider.notifier)
                                .setFilter('Rental');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FilterButton(
                          label: translate('Off Plan'),
                          isSelected: currentFilter == 'Off Plan',
                          onTap: () {
                            ref
                                .read(mapsFilterProvider.notifier)
                                .setFilter('Off Plan');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: mapsDataAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.yellow),
                ),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading map',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        err.toString(),
                        style: GoogleFonts.inter(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                data: (data) {
                  if (data == null || data.records.isEmpty) {
                    return Center(
                      child: Text(
                        'No properties found',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    );
                  }

                  final validRecords = data.records
                      .where((r) => r.hasValidCoordinates)
                      .toList();

                  if (validRecords.isEmpty) {
                    return Center(
                      child: Text(
                        'No properties with valid locations',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    );
                  }

                  final initial = LatLng(
                    validRecords.first.latitude!,
                    validRecords.first.longitude!,
                  );

                  return Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: initial,
                          initialZoom: 14,
                          minZoom: 3,
                          maxZoom: 19,
                          backgroundColor: const Color(0xFF16213E),
                          onTap: (_, point) {
                            // Intentionally no-op to avoid per-tap debug overhead during pan.
                          },
                          onMapReady: () => _scheduleFitToRecords(validRecords),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                _hasMapTilerKey ? _kTileUrlMapTiler : _kTileUrlCarto,
                            additionalOptions: _hasMapTilerKey
                                ? {'key': ApiConfig.mapTilerApiKey.trim()}
                                : const {},
                            fallbackUrl:
                                _hasMapTilerKey ? _kTileUrlCarto : _kTileUrlOsmFallback,
                            subdomains: const ['a', 'b', 'c', 'd'],
                            userAgentPackageName: 'com.continentalapp.mobile',
                          ),
                          MarkerLayer(markers: _buildMapMarkers(validRecords)),
                          SimpleAttributionWidget(
                            source:
                                Text(_hasMapTilerKey ? 'MapTiler / OSM' : 'OSM / CARTO'),
                            onTap: () => launchUrl(
                              Uri.parse(
                                _hasMapTilerKey
                                    ? 'https://www.maptiler.com/copyright/'
                                    : 'https://carto.com/help/legal/',
                              ),
                              mode: LaunchMode.externalApplication,
                            ),
                            alignment: Alignment.bottomRight,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.9),
                          ),
                        ],
                      ),
                      Positioned(
                        right: 10,
                        bottom: 140,
                        child: Column(
                          children: [
                            Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              elevation: 4,
                              child: InkWell(
                                onTap: () {
                                  final cam = _mapController.camera;
                                  _mapController.move(
                                    cam.center,
                                    (cam.zoom + 1).clamp(
                                      cam.minZoom ?? 3,
                                      cam.maxZoom ?? 19,
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.add,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              elevation: 4,
                              child: InkWell(
                                onTap: () {
                                  final cam = _mapController.camera;
                                  _mapController.move(
                                    cam.center,
                                    (cam.zoom - 1).clamp(
                                      cam.minZoom ?? 3,
                                      cam.maxZoom ?? 19,
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.remove,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fitMarkersInView(List<PropertyRecord> records) {
    if (records.isEmpty) return;

    final boundsList = records
        .where((r) => r.hasValidCoordinates)
        .map((r) => LatLng(r.latitude!, r.longitude!))
        .toList();

    if (boundsList.isEmpty) return;

    double minLat = boundsList.first.latitude;
    double maxLat = boundsList.first.latitude;
    double minLng = boundsList.first.longitude;
    double maxLng = boundsList.first.longitude;

    for (final point in boundsList) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    const pad = 0.01;
    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds(
            LatLng(minLat - pad, minLng - pad),
            LatLng(maxLat + pad, maxLng + pad),
          ),
          padding: const EdgeInsets.all(48),
        ),
      );
    } catch (e, st) {
      debugPrint('⚠️ fitCamera failed: $e\n$st');
    }
  }
}

/// Circular pin: property image when available, otherwise themed initial.
class _PropertyPinMarker extends StatelessWidget {
  final PropertyRecord record;
  final VoidCallback onTap;

  const _PropertyPinMarker({
    required this.record,
    required this.onTap,
  });

  bool get _isRental =>
      record.propertyType.toLowerCase().replaceAll(' ', '') == 'rental';

  @override
  Widget build(BuildContext context) {
    final borderColor =
        _isRental ? const Color(0xFF6C2BD9) : const Color(0xFFF7B500);
    final url = _normalizeUrl(record.mapImageUrl);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Tooltip(
        message:
            '${record.propertyName}\n${record.developerName}\n${record.propertyType}',
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: url != null
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: borderColor,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) =>
                      _PinFallback(record: record, borderColor: borderColor),
                )
              : _PinFallback(record: record, borderColor: borderColor),
        ),
      ),
    );
  }
}

String? _normalizeUrl(String? raw) {
  if (raw == null) return null;
  var u = raw.trim();
  if (u.isEmpty) return null;
  if (u.startsWith('//')) u = 'https:$u';
  if (u.startsWith('http://')) u = 'https://${u.substring(7)}';
  return u;
}

class _PinFallback extends StatelessWidget {
  final PropertyRecord record;
  final Color borderColor;

  const _PinFallback({
    required this.record,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final letter = record.propertyName.trim().isNotEmpty
        ? record.propertyName.trim()[0].toUpperCase()
        : '?';
    return Container(
      color: borderColor.withValues(alpha: 0.25),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: borderColor,
          fontWeight: FontWeight.w800,
          fontSize: 22,
        ),
      ),
    );
  }
}

class _LightweightPinMarker extends StatelessWidget {
  final PropertyRecord record;
  final VoidCallback onTap;

  const _LightweightPinMarker({
    required this.record,
    required this.onTap,
  });

  bool get _isRental =>
      record.propertyType.toLowerCase().replaceAll(' ', '') == 'rental';

  @override
  Widget build(BuildContext context) {
    final borderColor =
        _isRental ? const Color(0xFF6C2BD9) : const Color(0xFFF7B500);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: borderColor,
          border: Border.all(color: Colors.white, width: 1.4),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow[700] : Colors.grey[800],
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
